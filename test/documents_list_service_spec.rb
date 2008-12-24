require 'rgdata'
require 'rgdata/documents_list/service'

describe RGData::DocumentsList::Service do
  before(:each) do
    @service = RGData::DocumentsList::Service.new
    @client = @service.login 'RGData.Library@gmail.com', 'rgdatatest'
  end

  it 'should retrieve documents' do
    response = @client.retrieve :category => 'document'
    response.code.should == 200
    list = response.body
    list.entry.size.should > 0
  end

  it 'should retrieve starred presentations' do
    response = @client.retrieve :category => ['presentation', 'starred']
    response.code.should == 200
    list = response.body
    list.totalResults.should == 0
  end

  it 'should retrieve documents in a folder named starred' do
    response = @client.retrieve :category => {'starred' => 'RGData.Library@gmail.com'}
    response.code.should == 200
    list = response.body
    list.totalResults.should == 0
  end

  it 'should retrieve document by a text query' do
    response = @client.retrieve :query => 'example query'
    response.code.should == 200
    list = response.body
    list.totalResults.should == 0
  end

  it 'should retrieve all documents and folders' do
    response = @client.retrieve :show_folders => true
    response.code.should == 200
    list = response.body
    list.entry.size.should > 0
  end

  it 'should retrieve a list of folder contents' do
    folder_id = 'hello'
    response = @client.retrieve :folder => folder_id
    response.code.should == 200
    list = response.body
    list.totalResults.should == 0
  end
=begin

  it 'should create a folder' do
    response = @client.create_folder('New Folder')
    response.code.should == 201
    response.body.author.name.should == 'rgdata.library'
  end

  it 'should update metadata' do
    list_response = @client.list
    entry = list_response.body.entry.first
    response = @client.update(entry, :title => 'updated')
    response.code.should == 200
  end

  it 'should update metadata with hash' do
    list_response = @client.list
    entry = list_response.body.entry.first
    response = entry.update!(:title => 'updated title')
    response.code.should == 200
  end

  it 'should update metadata with equal method' do
    list_response = @client.list
    entry = list_response.body.entry.first
    entry.title = 'updated title'
    response = entry.update!
    response.code.should == 200
  end

  it 'should update content' do
    list_response = @client.list
    entry = list_response.body.entry.first
    response = @client.update(entry, :content => "1,2,3\n4,5,6\n7,8,#{rand(10000)}", :filepath => 'txt')
    response.code.should == 200
    response.body.author.name.should == 'RGData.Library'
  end

  it 'should update title and content' do
    list_response = @client.list
    entry = list_response.body.entry.first
    response = @client.update(entry, :title => 'modify title and content', :content => "#{rand(10000)},2,3\n4,5,6\n7,8,9", :filepath => 'txt')
    response.code.should == 200
    response.body.author.name.should == 'RGData.Library'
  end

  it 'should upload csv file with metadata' do
    title = "RGData Test (#{Time.now})"
    filepath = "#{File.dirname(__FILE__)}/rsc/documents_list_upload.csv"
    need_metadata = true

    response = @client.upload title, :filepath => filepath, :metadata => need_metadata

    print "CODE:"
    puts response.code
    print "MESSAGE:"
    puts response.message
    print "BODY:"
    puts response.raw_body

    response.code.should == 201 # fail!
  end

  it 'should upload csv file without metadata' do
    title = "RGData Test (#{Time.now})"
    filepath = "#{File.dirname(__FILE__)}/rsc/documents_list_upload.csv"
    need_metadata = false

    response = @client.upload title, :filepath => filepath, :metadata => need_metadata
    response.code.should == 201
    response.body.author.name.should == 'RGData.Library'
  end

  it 'should upload only metadata' do
    title = "RGData Test (#{Time.now})"

    response = @client.upload 'new document', :metadata => true
    response.code.should == 201

    response = @client.upload 'new document2'
    response.code.should == 201
  end

  it 'should get a list of documents by method access' do
    response = @client.list
    list = response.body

    list.totalResults.should =~ /\d+/
    list.totalResults.should_not equal('0')
    list.entry.size.should_not equal(0)
    list.entry[0].author.name.should == 'RGData.Library'
  end

  it 'should get a list of documents by hash access' do
    response = @client.list
    list = response.body

    list['totalResults'].should =~ /\d+/
    list['totalResults'].should_not equal('0')
    list['entry'].size.should_not equal(0)
    list['entry'][0]['author'][0]['name'].should == 'RGData.Library'
  end

  it 'should get a list of documents by pseudo xpath access' do
    response = @client.list
    list = response.body

    list['/entry'].size.should_not equal(0)
    list['/entry/0/author/name'].should == 'RGData.Library'
    list['/entry/author/name'].should == 'RGData.Library'
    list['/entry[0]/author@name'].should == 'RGData.Library'

    first_entry = list.entry[0]
    first_entry['/author/name'].should == 'RGData.Library'
    first_entry['/author@name'].should == 'RGData.Library'
  end

  it 'should trash documents and folders if not changed' do
    list_response = @client.list
    entry = list_response.body.entry.first
    response = @client.trash(entry)
    response.code.should == 200
  end

  it 'should trash documents and folders anyway' do
    list_response = @client.list
    entry = list_response.body.entry.first
    response = @client.trash(entry, :force => true)
    response.code.should == 200
  end

  it 'should trash documents and folders with method' do
    list_response = @client.list
    entry = list_response.body.entry.first
    response = entry.delete!
    response.code.should == 200
  end
=end

  after(:each) do
    @service = nil
    @client = nil
  end
end

