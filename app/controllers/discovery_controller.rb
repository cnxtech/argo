# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class DiscoveryController < CatalogController

  include BlacklightSolrExtensions
  include Blacklight::Catalog
  helper ArgoHelper
  copy_blacklight_config_from CatalogController
  
  def default_html_head
    super
    stylesheet_links << ['ui.jqgrid']
    javascript_includes << ['report']
  end
  
  def rsolr_request_error(exception)
    raise exception
  end
  def bulk
    (@response, @document_list) = get_search_results
  end
  def data
    if not params[:sord]
      params[:sord] = 'asc'
    end
    rows_per_page = params[:rows] ? params.delete(:rows).to_i : 10
    params[:per_page] = rows_per_page * [params.delete(:npage).to_i,1].max

    delete_or_assign_search_session_params
    @report = Discovery.new(params)
    
    respond_to do |format|
      format.json { 
        render :json => {
          :page => params[:page].to_i,
          :records => @report.num_found,
          :total => (@report.num_found / rows_per_page.to_f).ceil,
          :rows => @report.report_data
        }
      }
      format.xml  { render :xml  => @report.report_data }
    end
  end

  def download
    fields = params['fields'] ? params.delete('fields').split(/\s*,\s*/) : nil
    params[:per_page]=10
    self.response.headers["Content-Type"] = "application/octet-stream" 
    self.response.headers["Content-Disposition"] = "attachment; filename=report.csv"
    self.response.headers['Last-Modified'] = Time.now.ctime.to_s
    self.response_body = Discovery.new(params,fields).csv2
  end
end
