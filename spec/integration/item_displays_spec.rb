# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'mods_view', type: :request do
  let(:object) { instantiate_fixture('druid_zt570tx3016', Dor::Item) }
  let(:current_user) { create(:user) }

  before do
    sign_in current_user, groups: ['sdr:administrator-role']
    allow(Dor).to receive(:find).and_return(object)
  end

  context 'main page tests' do
    it 'has the expected heading for search facets' do
      visit root_path
      expect(page).to have_content('Limit your search')
    end

    it 'should have the expected search facets', js: true do
      search_facets = ['Object Type', 'Content Type', 'Admin Policy']
      visit root_path
      search_facets.each do |facet|
        expect(page).to have_content(facet)
      end
    end
  end
  context 'mods view' do
    it 'should render the mods view including a title' do
      visit '/items/druid:zt570tx3016/purl_preview'
      expect(page).to have_content('Ampex')
    end
  end
  context 'item dialogs' do
    context 'open version ui' do
      it 'should render the open version ui' do
        visit '/items/druid:zt570tx3016/open_version_ui'
        expect(page).to have_content('description')
      end
    end
    context 'close version ui' do
      it 'should render the close version ui' do
        visit '/items/druid:zt570tx3016/close_version_ui'
        expect(page).to have_content('description')
      end
    end
    context 'add workflow' do
      it 'should render the add workflow ui' do
        visit '/items/druid:zt570tx3016/add_workflow'
        expect(page).to have_content('Add workflow')
      end
    end
    context 'open version ui' do
      it 'should render the add collection ui' do
        allow(current_user).to receive(:permitted_collections).and_return(['druid:ab123cd4567'])
        visit '/items/druid:zt570tx3016/collection_ui'
        expect(page).to have_content('Add Collection')
      end
    end

    context 'content type' do
      it 'renders the edit content type ui' do
        visit '/items/druid:zt570tx3016/content_type'
        expect(page).to have_content('Set content type')
      end
    end

    context 'embargo form' do
      it 'should render the embargo update ui' do
        visit '/items/druid:zt570tx3016/embargo_form'
        expect(page).to have_content('Embargo')
      end
    end
    context 'rights form' do
      it 'should render the access rights update ui' do
        visit '/items/druid:zt570tx3016/rights'
        expect(page).to have_content('Dark (Preserve Only)')
      end
    end
    context 'source id ui' do
      it 'should render the source id update ui' do
        idmd = double(Dor::IdentityMetadataDS)
        allow(object).to receive(:identityMetadata).and_return(idmd)
        allow(idmd).to receive(:sourceId).and_return('something123')
        visit '/items/druid:zt570tx3016/source_id_ui'
        expect(page).to have_content('Update')
      end
    end
    context 'tag ui' do
      it 'should render the tag ui' do
        idmd = double(Dor::IdentityMetadataDS)
        allow(Dor::Item).to receive(:identityMetadata).and_return(idmd)
        allow(idmd).to receive(:tags).and_return(['something:123'])
        visit '/items/druid:zt570tx3016/tags_ui'
        expect(page).to have_content('Update tags')
      end
    end
    context 'register' do
      it 'should load the registration form' do
        skip "appears to pass even if blacklight JS isn't included in application.js or register.js, which you'd expect to break things. skipping since it might be useless anyway."
        visit '/items/register'
        expect(page).to have_content('Admin Policy')
        expect(page).to have_content('Register')
      end
    end
  end
end
