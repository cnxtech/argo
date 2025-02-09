# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArgoHelper, type: :helper do
  describe '#render_buttons' do
    let(:user) do
      instance_double(User,
                      is_admin?: true,
                      is_webauth_admin?: false,
                      is_manager?: false,
                      is_viewer?: false,
                      roles: false)
    end

    let(:item_id) { 'druid:kv840rx2720' }
    let(:object) { instantiate_fixture(item_id, Dor::Item) }
    let(:governing_apo_id) { 'druid:hv992ry2431' }
    let(:doc) { SolrDocument.new('id' => item_id, SolrDocument::FIELD_APO_ID => [governing_apo_id]) }

    before do
      allow(Dor::Config.workflow.client).to receive(:active_lifecycle).and_return(true)
      allow(Dor::Config.workflow.client).to receive(:lifecycle).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      allow(helper).to receive(:current_user).and_return(user)
      allow(object).to receive(:allows_modification?).and_return(true)
      allow(object).to receive(:pid).and_return(item_id)
      desc_md = double(Dor::DescMetadataDS)
      @id_md = double(Dor::IdentityMetadataDS)
      governing_apo = double(Dor::AdminPolicyObject, pid: governing_apo_id)
      allow(desc_md).to receive(:new?).and_return(true)
      allow(@id_md).to receive(:otherId).with('catkey').and_return([])
      allow(@id_md).to receive(:ng_xml).and_return(Nokogiri::XML('<identityMetadata><identityMetadata>'))
      # nil datastreams don't need content for these tests, they just need to be present
      datastreams = { 'contentMetadata' => nil, 'rightsMetadata' => nil, 'descMetadata' => desc_md, 'identityMetadata' => @id_md }
      allow(object).to receive(:datastreams).and_return(datastreams)
      allow(object).to receive(:admin_policy_object).and_return(governing_apo)
      allow(helper).to receive(:registered_only?).with(doc).and_return(false)
      allow(object).to receive(:embargoed?).and_return(false)
    end

    context 'a Dor::Item the user can manage, with the usual data streams, and no catkey or embargo info' do
      let(:default_buttons) do
        [
          {
            label: 'Close Version',
            url: "/items/#{item_id}/close_version_ui",
            check_url: "/workflow_service/#{item_id}/closeable"
          },
          {
            label: 'Open for modification',
            url: "/items/#{item_id}/open_version_ui",
            check_url: "/workflow_service/#{item_id}/openable"
          },
          {
            label: 'Reindex',
            url: "/dor/reindex/#{item_id}",
            new_page: true
          },
          {
            label: 'Set governing APO',
            url: "/items/#{item_id}/set_governing_apo_ui",
            disabled: false
          },
          {
            label: 'Add workflow',
            url: new_item_workflow_path(item_id)
          },
          {
            label: 'Republish',
            url: "/dor/republish/#{item_id}",
            check_url: "/workflow_service/#{item_id}/published",
            new_page: true
          },
          {
            label: 'Purge',
            url: "/items/#{item_id}/purge",
            new_page: true,
            confirm: 'This object will be permanently purged from DOR. This action cannot be undone. Are you sure?',
            disabled: true
          },
          {
            label: 'Change source id',
            url: "/items/#{item_id}/source_id_ui"
          },
          {
            label: 'Manage catkey',
            url: "/items/#{item_id}/catkey_ui"
          },
          {
            label: 'Edit tags',
            url: "/items/#{item_id}/tags_ui"
          },
          {
            label: 'Edit collections',
            url: "/items/#{item_id}/collection_ui"
          },
          {
            label: 'Set content type',
            url: "/items/#{item_id}/content_type"
          },
          {
            label: 'Set rights',
            url: "/items/#{item_id}/rights"
          },
          {
            label: 'Manage release',
            url: "/view/#{item_id}/manage_release"
          }
        ]
      end

      it 'creates a hash with the needed button info for an admin' do
        buttons = helper.render_buttons(doc, object)
        default_buttons.each do |button|
          expect(buttons).to include(button)
        end
        expect(buttons.length).to eq default_buttons.length
      end
      it 'generates the same button set for a non Dor-wide admin with APO specific mgmt privileges' do
        allow(user).to receive(:is_admin?).and_return(false)
        allow(Argo::Ability).to receive(:can_manage_item?).and_return(true)
        allow(Argo::Ability).to receive(:can_manage_content?).and_return(true)
        buttons = helper.render_buttons(doc, object)
        default_buttons.each do |button|
          expect(buttons).to include(button)
        end
        expect(buttons.length).to eq default_buttons.length
      end
      it 'only includes the embargo update button if the user is an admin and the object is embargoed' do
        allow(object).to receive(:embargoed?).and_return(true)
        buttons = helper.render_buttons(doc, object)
        default_buttons.push(
          label: 'Update embargo',
          url: "/items/#{item_id}/embargo_form"
        ).each do |button|
          expect(buttons).to include(button)
        end
        expect(buttons.length).to eq default_buttons.length
      end
      it "does not generate errors given an object that has no associated APO and a user that can't manage the object" do
        allow(user).to receive(:is_admin?).and_return(false)
        allow(doc).to receive(:apo_pid).and_return(nil)
        allow(object).to receive(:admin_policy_object).and_return(nil)
        allow(user).to receive(:roles).with(nil).and_return([])
        buttons = helper.render_buttons(doc, object)
        expect(buttons).not_to be_nil
        expect(buttons.length).to eq 0
      end
      it 'includes the refresh descMetadata button for items with catkey' do
        allow(@id_md).to receive(:otherId).with('catkey').and_return(['1234567'])
        buttons = helper.render_buttons(doc, object)
        default_buttons.push(
          label: 'Refresh descMetadata',
          url: "/items/#{item_id}/refresh_metadata",
          new_page: true,
          disabled: false
        ).each do |button|
          expect(buttons).to include(button)
        end
        expect(buttons.length).to eq default_buttons.length
      end
    end

    context 'a Dor::AdminPolicyObject the user can manage' do
      let(:view_apo_id) { 'druid:zt570tx3016' }
      let(:default_buttons) do
        [
          {
            label: 'Close Version',
            url: "/items/#{view_apo_id}/close_version_ui",
            check_url: "/workflow_service/#{view_apo_id}/closeable"
          },
          {
            label: 'Open for modification',
            url: "/items/#{view_apo_id}/open_version_ui",
            check_url: "/workflow_service/#{view_apo_id}/openable"
          },
          {
            label: 'Edit APO',
            url: edit_apo_path(view_apo_id),
            new_page: true
          },
          {
            label: 'Create Collection',
            url: new_apo_collection_path(view_apo_id)
          },
          {
            label: 'Reindex',
            url: "/dor/reindex/#{view_apo_id}",
            new_page: true
          },
          {
            label: 'Set governing APO',
            url: "/items/#{view_apo_id}/set_governing_apo_ui",
            disabled: false
          },
          {
            label: 'Add workflow',
            url: new_item_workflow_path(view_apo_id)
          },
          {
            label: 'Republish',
            url: "/dor/republish/#{view_apo_id}",
            check_url: "/workflow_service/#{view_apo_id}/published",
            new_page: true
          },
          {
            label: 'Purge',
            url: "/items/#{view_apo_id}/purge",
            new_page: true,
            confirm: 'This object will be permanently purged from DOR. This action cannot be undone. Are you sure?',
            disabled: true
          },
          {
            label: 'Change source id',
            url: "/items/#{view_apo_id}/source_id_ui"
          },
          {
            label: 'Edit tags',
            url: "/items/#{view_apo_id}/tags_ui"
          },
          {
            label: 'Set rights',
            url: "/items/#{view_apo_id}/rights"
          },
          {
            label: 'Manage release',
            url: "/view/#{view_apo_id}/manage_release"
          }
        ]
      end

      it 'renders the appropriate default buttons for an apo' do
        object = instantiate_fixture(view_apo_id, Dor::AdminPolicyObject)
        doc = SolrDocument.new('id' => view_apo_id, SolrDocument::FIELD_APO_ID => [governing_apo_id])
        allow(Dor).to receive(:find).with(view_apo_id).and_return(object)
        allow(helper).to receive(:registered_only?).with(doc).and_return(false)
        buttons = helper.render_buttons(doc, object)
        default_buttons.each do |button|
          expect(buttons).to include(button)
        end
        expect(buttons.length).to eq default_buttons.length
      end
    end
  end

  describe 'render_facet_value' do
    it 'does not override Blacklight version' do
      expect(helper).to respond_to(:render_facet_value)
      expect(helper.method(:render_facet_value).owner).to eq(Blacklight::FacetsHelperBehavior)
    end
  end

  describe '#registered_only?' do
    it 'returns true for registered only item' do
      expect(helper.registered_only?('processing_status_text_ssi' => 'Registered')).to eq true
      expect(helper.registered_only?('processing_status_text_ssi' => 'Unknown Status')).to eq true
    end
    it 'returns false for items beyond registered only' do
      expect(helper.registered_only?('processing_status_text_ssi' => 'In accessioning')).to eq false
    end
  end
end
