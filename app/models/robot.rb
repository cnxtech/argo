class Robot < ActiveRecord::Base
  #attr_accessible is deprecated after Rails 3.  also: the only thing that sets these fields 
  #is a migration, and no other models in argo use this mass assignment prevention approach.
  # attr_accessible :wf, :process

  def status
    ready_docs=Dor::SearchService.query("wf_wps_facet:\"#{wf}:#{process}:ready\"")['response']['docs']
    if ready_docs.length > 0

      docs = Dor::SearchService.query("wf_#{wf}_#{process}_dt:[NOW-7HOURS-1HOUR TO NOW]", {:rows => 20, :fl => 'id'})['response']['docs']
      if docs.length >0
        @status = 'activity'
      else
        @status = 'no_activity'
      end
    else
      @status = 'sleep'
    end
    puts @status
    @status
  end
  def status_long
    ready_docs=Dor::SearchService.query("wf_wps_facet:\"#{wf}:#{process}:ready\"")['response']['docs']
    if ready_docs.length > 0

      docs = Dor::SearchService.query("wf_#{wf}_#{process}_dt:[NOW-7HOURS-4HOURS TO NOW]", {:rows => 20, :fl => 'id'})['response']['docs']
      if docs.length >0
        @status = 'activity'
      else
        @status = 'no_activity'
      end
    else
      @status = 'sleep'
    end
    @status
  end
  def recent_work
    docs = Dor::SearchService.query("wf_#{wf}_#{process}_dt:[NOW-7HOURS-1HOUR  TO NOW]", {:rows => 20, :fl => 'id,dc_title_t,apo_title_facet'})['response']['docs']
  end
end
