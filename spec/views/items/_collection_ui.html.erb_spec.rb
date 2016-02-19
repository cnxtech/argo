require 'spec_helper'

RSpec.describe 'items/_collection_ui.html.erb' do
  let(:collection) do
    double('collection', label: 'Dogs are better than catz', pid: 'druid:abc123')
  end
  let(:object) do
    double('object', collections: [collection, collection], pid: 'druid:abc123')
  end
  let(:current_user) do
    double('current_user', permitted_collections: ['Catz are our legacy'])
  end
  it 'renders the partial content' do
    assign(:object, object)
    expect(view).to receive(:current_user).and_return(current_user)
    render
    expect(rendered).to have_css '.panel .panel-heading h3.panel-title', text: 'Remove existing collections'
    expect(rendered).to have_css '.panel-body .list-group li.list-group-item', text: 'Dogs are better than catz'
    expect(rendered).to have_css '.panel-body .list-group li.list-group-item a span.glyphicon.glyphicon-remove.text-danger'
    expect(rendered).to have_css '.panel .panel-heading h3.panel-title', text: 'Add a collection'
    expect(rendered).to have_css '.panel-body form .form-group select.form-control option', text: 'Catz are our legacy'
    expect(rendered).to have_css '.panel-body form button.btn.btn-primary', text: 'Add Collection'
  end
end
