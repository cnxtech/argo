require 'spec_helper'
describe ItemsController do
  before :each do
    #TODO use fixtures here, this is too much stubbing
    @item = mock(Dor::Item)
    @item.stub(:to_solr)
    @current_user=mock(:webauth_user, :login => 'sunetid', :logged_in? => true,:privgroup=>ADMIN_GROUPS.first)
    @current_user.stub(:is_admin).and_return(true)
    @current_user.stub(:roles).and_return([])
    @current_user.stub(:is_manager).and_return(false)
    ItemsController.any_instance.stub(:current_user).and_return(@current_user)
    Dor::Item.stub(:find).and_return(@item)
    @event_ds=mock(Dor::EventsDS)
    @event_ds.stub(:add_event)
    @ds={}
    idmd=mock()
    idmd.stub(:dirty=)
    @item.stub(:save)
    @ds['identityMetadata']=idmd
    @item.stub(:identityMetadata).and_return(idmd)
    @ds['events'] = @event_ds
    @item.stub(:datastreams).and_return(@ds)
    @item.stub(:allows_modification?).and_return(true)
    @item.stub(:can_manage_item?).and_return(false)
    @item.stub(:can_manage_content?).and_return(false)
    @item.stub(:can_view_content?).and_return(false)
    @item.stub(:pid).and_return('object:pid')
    @item.stub(:delete)
    @apo=mock()
    @apo.stub(:pid).and_return('druid:apo')
    @item.stub(:admin_policy_object).and_return(@apo)
    Dor::SearchService.solr.stub(:add)
    @pid='oo201oo0001'

  end
  describe 'datastream_update' do
    it 'should allow a non admin to update the datastream' do
      @item.stub(:can_manage_content?).and_return(true)
      @item.stub(:can_manage_desc_metadata?).and_return(true)
      xml="<some> xml</some>"
      @item.datastreams['identityMetadata'].stub(:content=)
      post :datastream_update, :id => @pid, :dsid => 'identityMetadata', :content => xml
      response.code.should == "302"
    end
  end

  describe 'release_hold' do
    it 'should release an item that is on hold if its apo has been ingested' do
      Dor::WorkflowService.should_receive(:get_workflow_status).with('dor', 'object:pid', 'accessionWF','sdr-ingest-transfer').and_return('hold')
      Dor::WorkflowService.should_receive(:get_lifecycle).with('dor', 'druid:apo', 'accessioned').and_return(true)
      Dor::WorkflowService.should_receive(:update_workflow_status)
      post :release_hold, :id => @pid
    end
    it 'should refuse to release an item that isnt on hold' do
      Dor::WorkflowService.should_receive(:get_workflow_status).with('dor', 'object:pid', 'accessionWF','sdr-ingest-transfer').and_return('waiting')
      Dor::WorkflowService.should_not_receive(:update_workflow_status)
      post :release_hold, :id => @pid
    end
    it 'should refuse to release an item whose apo hasnt been ingested' do
      Dor::WorkflowService.should_receive(:get_workflow_status).with('dor', 'object:pid', 'accessionWF','sdr-ingest-transfer').and_return('hold')
      Dor::WorkflowService.should_receive(:get_lifecycle).with('dor', 'druid:apo', 'accessioned').and_return(false)
      Dor::WorkflowService.should_not_receive(:update_workflow_status)
      post :release_hold, :id => @pid
    end
  end 
  describe 'purge' do
    it 'should 403' do
      @current_user.stub(:is_admin).and_return(false)
      post 'purge_object', :id => 'oo201oo0001'
      response.code.should == "403"
    end
  end
  describe "embargo_update" do
    it "should 403 if you arent an admin" do
      @current_user.stub(:is_admin).and_return(false)
      post 'embargo_update', :id => 'oo201oo0001', :date => "12/19/2013"
      response.code.should == "403"
    end
    it "should call Dor::Item.update_embargo" do
      runs=0
      @item.stub(:update_embargo)do |a| 
      runs=1
      true
    end

    post :embargo_update, :id => 'oo201oo0001',:embargo_date => "2012-10-19T00:00:00Z"
    response.code.should == "302"
    runs.should ==1
  end
end
describe "register" do
  it "should load the registration form" do
    get :register
    response.should render_template('register')
  end
end
describe "open_version" do
  it 'should call dor-services to open a new version' do
    ran=false
    @item.stub(:open_new_version)do 
    ran=true
  end
  version_metadata=mock(Dor::VersionMetadataDS)
  version_metadata.stub(:current_version_id).and_return(2)
  version_metadata.should_receive(:update_current_version)
  @item.stub(:versionMetadata).and_return(version_metadata)
  @item.stub(:current_version).and_return('2')
  @item.should_receive(:save)
  Dor::SearchService.solr.should_receive(:add)
  get 'open_version', :id => 'oo201oo0001', :severity => 'major', :description => 'something'
  ran.should == true
end 
it 'should 403 if you arent an admin' do
  @current_user.stub(:is_admin).and_return(false)
  get 'open_version', :id => 'oo201oo0001', :severity => 'major', :description => 'something'
  response.code.should == "403"
end
end
describe "close_version" do
  it 'should call dor-services to close the version' do
    ran=false
    @item.stub(:close_version)do 
    ran=true
  end
  version_metadata=mock(Dor::VersionMetadataDS)
  version_metadata.stub(:current_version_id).and_return(2)
  @item.stub(:versionMetadata).and_return(version_metadata)
  version_metadata.should_receive(:update_current_version)
  @item.stub(:current_version).and_return('2')
  @item.should_receive(:save)
  Dor::SearchService.solr.should_receive(:add)
  get 'close_version', :id => 'oo201oo0001', :severity => 'major', :description => 'something'
  ran.should == true
end
it 'should 403 if you arent an admin' do
  @current_user.stub(:is_admin).and_return(false)
  get 'close_version', :id => 'oo201oo0001'
  response.code.should == "403"
end
end
describe "source_id" do
  it 'should update the source id' do
    @item.should_receive(:set_source_id).with('new:source_id')
    Dor::SearchService.solr.should_receive(:add)
    post 'source_id', :id => 'oo201oo0001', :new_id => 'new:source_id'
  end
end
describe "tags" do
  before :each do
    @item.stub(:tags).and_return(['some:thing'])
    Dor::SearchService.solr.should_receive(:add)
  end
  it 'should update tags' do
    @item.should_receive(:update_tag).with('some:thing', 'some:thingelse')
    post 'tags', :id => 'oo201oo0001', :update=>'true', :tag1 => 'some:thingelse'
  end
  it 'should delete tag' do
    @item.should_receive(:remove_tag).with('some:thing').and_return(true)
    post 'tags', :id => 'oo201oo0001', :tag => '1', :del => 'true'
  end
  it 'should add a tag' do
    @item.should_receive(:add_tag).with('new:thing')
    post 'tags', :id => 'oo201oo0001', :new_tag1 => 'new:thing', :add => 'true'
  end
end
describe 'tags_bulk' do
  before :each do
    @item.stub(:tags).and_return(['some:thing'])
    Dor::SearchService.solr.should_receive(:add)
  end
  it 'should remve an old tag an add a new one' do
    @item.should_receive(:remove_tag).with('some:thing').and_return(true)
    @item.should_receive(:add_tag).with('new:thing').and_return(true)
    post 'tags_bulk', :id => 'oo201oo0001', :tags => 'new:thing'
  end
  it 'should add multiple tags' do
    @item.should_receive(:add_tag).twice
    @item.should_receive(:remove_tag).with('some:thing').and_return(true)
    @item.should_receive(:save)
    post 'tags_bulk', :id => 'oo201oo0001', :tags => 'Process : Content Type : Book (flipbook, ltr)	 Registered By : labware'
  end
  
end
describe "set_rights" do
  it 'should set an item to dark' do
    @item.should_receive(:set_read_rights).with('dark')
    get 'set_rights', :id => 'oo201oo0001', :rights => 'dark'
  end
end

describe "add_file" do
  it 'should recieve an uploaded file and add it to the requested resource' do
    pending 'Mock isnt working correctly'
    file=mock(ActionDispatch::Http::UploadedFile)
    ran=false
    @item.stub(:add_file) do
      ran=true
    end
    file.stub(:original_filename).and_return('filename')
    post 'add_file', :uploaded_file => file, :id => 'oo201oo0001', :resource => 'resourceID'
    ran.should == true

  end   
  it 'should 403 if you arent an admin' do
    @current_user.stub(:is_admin).and_return(false)
    post 'add_file', :uploaded_file => nil, :id => 'oo201oo0001', :resource => 'resourceID'
    response.code.should == "403"
  end     
end
describe "delete_file" do
  it 'should call dor services to remove the file' do
    ran=false
    @item.stub(:remove_file)do 
    ran=true
  end
  get 'delete_file', :id => 'oo201oo0001', :file_name => 'old_file'
  ran.should == true
end
it 'should 403 if you arent an admin' do
  @current_user.stub(:is_admin).and_return(false)
  get 'delete_file', :id => 'oo201oo0001', :file_name => 'old_file'
  response.code.should == "403"
end
end
describe "replace_file" do
  it 'should recieve an uploaded file and call dor-services' do
    file=mock(ActionDispatch::Http::UploadedFile)
    ran=false
    @item.stub(:replace_file) do
      ran=true
    end
    file.stub(:original_filename).and_return('filename')
    post 'replace_file', :uploaded_file => file, :id => 'oo201oo0001', :resource => 'resourceID', :file_name => 'somefile.txt'
    ran.should == true
  end
  it 'should 403 if you arent an admin' do
    @current_user.stub(:is_admin).and_return(false)
    post 'replace_file', :uploaded_file => nil, :id => 'oo201oo0001', :resource => 'resourceID', :file_name => 'somefile.txt'
    response.code.should == "403"
  end
end
describe "update_parameters" do
  it 'should update the shelve, publish and preserve to yes (used to be true)' do
    contentMD=mock(Dor::ContentMetadataDS)
    @item.stub(:contentMetadata).and_return(contentMD)
    contentMD.stub(:update_attributes) do |file, publish, shelve, preserve|
      shelve.should == "yes"
      preserve.should == "yes"
      publish.should == "yes"
    end
    post 'update_attributes', :shelve => 'on', :publish => 'on', :preserve => 'on', :id => 'oo201oo0001', :file_name => 'something.txt'
  end
  it 'should work ok if not all of the values are set' do
    contentMD=mock(Dor::ContentMetadataDS)
    @item.stub(:contentMetadata).and_return(contentMD)
    contentMD.stub(:update_attributes) do |file, publish, shelve, preserve|
      shelve.should == "no"
      preserve.should == "yes"
      publish.should == "yes"
    end
    post 'update_attributes',  :publish => 'on', :preserve => 'on', :id => 'oo201oo0001', :file_name => 'something.txt'
  end
  it 'should update the shelve, publish and preserve to no (used to be false)' do
    contentMD=mock(Dor::ContentMetadataDS)
    @item.stub(:contentMetadata).and_return(contentMD)
    contentMD.stub(:update_attributes) do |file, publish, shelve, preserve|
      shelve.should == "no"
      preserve.should == "no"
      publish.should == "no"
    end
    contentMD.should_receive(:update_attributes)
    post 'update_attributes', :shelve => 'no', :publish => 'no', :preserve => 'no', :id => 'oo201oo0001', :file_name => 'something.txt'
  end
  it 'should 403 if you arent an admin' do
    @current_user.stub(:is_admin).and_return(false)
    post 'update_attributes', :shelve => 'no', :publish => 'no', :preserve => 'no', :id => 'oo201oo0001', :file_name => 'something.txt'
    response.code.should == "403"
  end
end
describe 'get_file' do
  it 'should have dor-services fetch a file from the workspace' do
    @item.stub(:get_file).and_return('abc')
    @item.should_receive(:get_file)
    get 'get_file', :file => 'somefile.txt', :id => 'oo201oo0001'
  end
  it 'should 403 if you arent an admin' do
    @current_user.stub(:is_admin).and_return(false)
    get 'get_file', :file => 'somefile.txt', :id => 'oo201oo0001'
    response.code.should == "403"
  end
end
describe 'datastream_update' do
  it 'should 403 if you arent an admin' do
    @current_user.stub(:is_admin).and_return(false)
    post 'datastream_update', :dsid => 'contentMetadata', :id => 'oo201oo0001', :content => '<contentMetadata/>'
    response.code.should == "403"
  end
  it 'should error on malformed xml' do
    lambda {post 'datastream_update', :dsid => 'contentMetadata', :id => 'oo201oo0001', :content => '<this>isnt well formed.'}.should raise_error
  end
  it 'should call save with good xml' do
    mock_ds=mock(Dor::ContentMetadataDS)
    mock_ds.stub(:content=)
    @item.should_receive(:save)
    @item.stub(:datastreams).and_return({'contentMetadata' => mock_ds})
    mock_ds.stub(:dirty?).and_return(false)
    post 'datastream_update', :dsid => 'contentMetadata', :id => 'oo201oo0001', :content => '<contentMetadata><text>hello world</text></contentMetadata>'
  end
end
describe 'update_sequence' do
  it 'should 403 if you arent an admin' do
    @current_user.stub(:is_admin).and_return(false)
    post 'update_resource', :resource => '0001', :position => '3', :id => 'oo201oo0001'
    response.code.should == "403"
  end
  it 'should call dor-services to reorder the resources' do
    mock_ds=mock(Dor::ContentMetadataDS)
    @item.stub(:move_resource)
    @item.should_receive(:move_resource)
    mock_ds.stub(:save)
    @item.stub(:datastreams).and_return({'contentMetadata' => mock_ds})
    mock_ds.stub(:dirty?).and_return(false)
    post 'update_resource', :resource => '0001', :position => '3', :id => 'oo201oo0001'
  end
  it 'should call dor-services to change the label' do
    mock_ds=mock(Dor::ContentMetadataDS)
    @item.stub(:update_resource_label)
    @item.should_receive(:update_resource_label)
    mock_ds.stub(:save)
    @item.stub(:datastreams).and_return({'contentMetadata' => mock_ds})
    mock_ds.stub(:dirty?).and_return(false)
    post 'update_resource', :resource => '0001', :label => 'label!', :id => 'oo201oo0001'
  end
  it 'should call dor-services to update the resource type' do
    mock_ds=mock(Dor::ContentMetadataDS)
    @item.stub(:update_resource_type)
    @item.should_receive(:update_resource_type)
    mock_ds.stub(:save)
    @item.stub(:datastreams).and_return({'contentMetadata' => mock_ds})
    mock_ds.stub(:dirty?).and_return(false)
    post 'update_resource', :resource => '0001', :type => 'book', :id => 'oo201oo0001'
  end
end
describe 'resource' do
  it 'should set the object and datastream, then call the view' do
    Dor::Item.should_receive(:find)
    mock_ds=mock(Dor::ContentMetadataDS)
    @item.stub(:datastreams).and_return({'contentMetadata' => mock_ds})
    get 'resource', :id => 'oo201oo0001', :resource => '0001'
  end
end
describe 'add_collection' do
  it 'should add a collection' do
    @item.should_receive(:add_collection).with('druid:1234')
    post 'add_collection', :id => 'oo201oo0001', :collection => 'druid:1234'
  end
  it 'should 403 if they arent permitted' do
    @current_user.stub(:is_admin).and_return(false)
    post 'add_collection', :id => 'oo201oo0001', :collection => 'druid:1234'
    response.code.should == "403"
  end
end
describe 'remove_collection' do
  it 'should remove a collection' do
    @item.should_receive(:remove_collection).with('druid:1234')
    post 'remove_collection', :id => 'oo201oo0001', :collection => 'druid:1234'
  end
  it 'should 403 if they arent permitted' do
    @current_user.stub(:is_admin).and_return(false)
    post 'remove_collection', :id => 'oo201oo0001', :collection => 'druid:1234'
    response.code.should == "403"
  end
end
describe 'mods' do
  it 'should return the mods xml for a GET' do
    @request.env["HTTP_ACCEPT"] = "application/xml"
    xml='<somexml>stuff</somexml>'
    descmd=mock()
    descmd.should_receive(:content).and_return(xml)
    @item.should_receive(:descMetadata).and_return(descmd)
    get 'mods', :id => 'oo201oo0001'
    response.body.should == xml
  end
  it 'should 403 if they arent permitted' do
    @current_user.stub(:is_admin).and_return(false)
    get 'mods', :id => 'oo201oo0001'
    response.code.should == "403"
  end
end
describe 'update_mods' do
  it 'should update the mods for a POST' do
    xml='<somexml>stuff</somexml>'
    descmd=mock()
    descmd.should_receive(:content=).with(xml)
    @item.should_receive(:descMetadata).and_return(descmd)
    post 'update_mods', :id => 'oo201oo0001', :xmlstr => xml
  end
  it 'should 403 if they arent permitted' do
    @current_user.stub(:is_admin).and_return(false)
    get 'update_mods', :id => 'oo201oo0001'
    response.code.should == "403"
  end
end
describe "add_workflow" do
  it 'should initialize the new workflow' do
    @item.should_receive(:initialize_workflow)
    wf=mock
    wf.stub(:[]).and_return(nil)
    @item.stub(:workflows).and_return wf
    post 'add_workflow', :id => 'oo201oo0001', :wf => 'accessionWF'
  end
  it 'shouldnt initialize the workflow if one is already active' do
    @item.should_not_receive(:initialize_workflow)
    wf=mock
    mock_wf=mock
    mock_wf.stub(:active?).and_return(true)
    wf.stub(:[]).and_return(mock_wf)
    @item.stub(:workflows).and_return wf
    post 'add_workflow', :id => 'oo201oo0001', :wf => 'accessionWF'
  end
end
end
