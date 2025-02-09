# frozen_string_literal: true

module WorkflowHelper
  def show_workflow_grid?
    controller_name == 'report' && action_name == 'workflow_grid'
  end

  def render_workflow_grid
    workflow_data = facet_tree('wf_wps')['wf_wps_ssim']
    return '' if workflow_data.nil?

    workflow_data.keys.sort.collect do |wf_name|
      render partial: 'workflow_table', locals: { wf_name: wf_name, wf_data: workflow_data[wf_name] }
    end.join("\n").html_safe
  end

  def render_workflow_name(name)
    new_params = search_state.add_facet_params('wf_wps_ssim', name).merge(controller: 'catalog', action: 'index')
    link_to(name, new_params)
  end

  def render_workflow_process_name(name, process)
    new_params = search_state.add_facet_params('wf_wps_ssim', [name, process].compact.join(':')).merge(controller: 'catalog', action: 'index')
    link_to(process, new_params)
  end

  def render_workflow_reset_link(wf_hash, name, process, status)
    return unless wf_hash[process] && wf_hash[process][status] && wf_hash[process][status][:_]

    new_params = search_state.add_facet_params(
      'wf_wps_ssim',
      [name, process, status].compact.join(':')
    )
                             .merge(
                               reset_workflow: name,
                               reset_step: process
                             )
    raw ' | ' + link_to('reset', report_reset_path(new_params), remote: true, method: :post)
  end

  def render_workflow_item_count(wf_hash, name, process, status)
    new_params = search_state.add_facet_params('wf_wps_ssim', [name, process, status].compact.join(':')).merge(controller: 'catalog', action: 'index')
    rotate_facet_params('wf_wps', 'wps', facet_order('wf_wps'), new_params)
    item_count = 0
    if wf_hash[process] && wf_hash[process][status] && item = wf_hash[process][status][:_] # rubocop:disable Lint/AssignmentInCondition
      item_count = item.hits
    end
    if item_count == 0
      item_count = content_tag :span, item_count, class: 'zero'
    end
    link_to(item_count, new_params)
  end

  def proc_names_for_wf(wf_name, wf_data)
    proc_names = wf_data.keys.delete_if { |k, v| !k.is_a?(String) }
    wf = Dor::WorkflowObject.find_by_name(wf_name)
    if wf.nil?
      proc_names = ActiveSupport::OrderedHash[*(proc_names.sort.collect { |n| [n, nil] }.flatten)]
    else
      proc_names = ActiveSupport::OrderedHash[*(wf.definition.processes.collect { |p| [p.name, p.label] }.flatten)]
    end
    proc_names
  end
end
