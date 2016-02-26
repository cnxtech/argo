module BlacklightSolrExtensions
  extend ActiveSupport::Concern
  include Blacklight::SearchHelper

  def add_params_to_current_search(new_params)
    p = session[:search] ? session[:search].dup : {}
    p[:f] = (p[:f] || {}).dup # the command above is not deep in rails3, !@#$!@#$

    new_params.each_pair do |field, value|
      p[:f][field] = (p[:f][field] || []).dup
      p[:f][field].push(value)
    end
    p
  end

  def add_params_to_current_search_and_redirect(params_to_add)
    new_params = add_params_to_current_search(params_to_add)

    # Delete page, if needed.
    new_params.delete(:page)

    # Delete any request params from facet-specific action, needed
    # to redir to index action properly.
    Blacklight::Solr::FacetPaginator.request_keys.values.each do |paginator_key|
      new_params.delete(paginator_key)
    end
    new_params.delete(:id)

    # Force action to be index.
    new_params[:action] = 'index'
    new_params
  end
end
