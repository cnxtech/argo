class ItemsController < ApplicationController
  before_filter :authorize!
  
  def crop
    @druid = params[:id].sub(/^druid:/,'')
    files = Legacy::Object.find_by_druid(@druid).files.find_all_by_file_role('00').sort { |a,b| a.id <=> b.id }
    @image_data = files.collect do |file|
      hash = file.webcrop
      hash[:fileSrc] = "#{ENV['RACK_BASE_URI']}/images/.dpg_pool/#{hash[:fileSrc]}"
      hash
    end
    render :crop, :layout => 'webcrop'
  end
  
  def save_crop
    @druid = params[:id].sub(/^druid:/,'')
    @image_data = JSON.parse(request.body.read)
    @image_data.each { |file_data|
      file_data.symbolize_keys!
      file_data[:cropCoords].symbolize_keys! if file_data.has_key?(:cropCoords)
      file = Legacy::File.find(file_data[:id])
      file.webcrop = file_data
    }
    render :json => @image_data.to_json
  end
  
  def register
    @perm_keys = ["sunetid:#{current_user.login}"] 
    if webauth and webauth.privgroup.present?
      @perm_keys += webauth.privgroup.split(/\|/).collect { |g| "workgroup:#{g}" }
    end
    render :register, :layout => 'application'
  end

  def workflow_view
    @obj = Dor.find params[:id], :lightweight => true
    @workflow_id = params[:wf_name]
    @workflow = @workflow_id == 'workflow' ? @obj.workflows : @obj.workflows[@workflow_id]

    respond_to do |format|
      format.html
      format.xml  { render :xml => @workflow.ng_xml.to_xml }
      format.any(:png,:svg,:jpeg) {
        graph = @workflow.graph
        raise ActionController::RoutingError.new('Not Found') if graph.nil?
        image_data = graph.output(request.format.to_sym => String)
        send_data image_data, :type => request.format.to_s, :disposition => 'inline'
      }
    end
  end
  def datastream_update
  	found=false
  	ADMIN_GROUPS.each do |group|
			if current_user.groups.include? group
				found=true   
			end
    end
    if not found
    	render :status=> :forbidden, :text =>'forbidden'
 			return
 		else
    	req_params=['id','dsid','content']
    	item = Dor.find params[:id]
    	ds=item.datastreams[params[:dsid]]
    	#check that the content is valid xml
    	begin
    		content=Nokogiri::XML(params[:content]){ |config| config.strict }
    	rescue
    		raise 'XML was not well formed!'
    	end
    	ds.content=content.to_s
    	puts ds.content
    	ds.save
    	if ds.dirty?
    		raise 'datastream didnt write'
    	end
    	respond_to do |format|
        format.any { redirect_to catalog_path(params[:id]), :notice => 'Datastream was successfully updated' }
      end
    end
  end
end
