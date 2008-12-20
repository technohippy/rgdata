require 'rgdata'
require 'rgdata/documents_list/service'

describe RGData::DocumentsList::Service do
  before(:each) do
    @service = RGData::DocumentsList::Service.new
    @client = @service.login 'RGData.Library@gmail.com', 'rgdatatest'
  end

  it 'should update metadata' do
    entry = @client.list.entry.first
    response = @client.update(entry, :title => 'updated')

    print "CODE:"
    puts response.code
    print "MESSAGE:"
    puts response.message
    print "BODY:"
    puts response.raw_body.gsub('&quot;', '"')

    response.code.should == 201

    #entry = @client.list.entry[1]
    #entry.update(:title => 'updated2')

    #entry = @client.list.entry[1]
    #entry.title = 'updated title'
    #entry.content = 'updated content'
    #entry.update!
  end

=begin
  it 'should update content' do
    entry = @client.list.entry.first
    response = @client.update(entry, :content => "1,2,3\n4,5,6\n7,8,#{rand(10000)}", :filepath => 'csv')

    print "CODE:"
    puts response.code
    print "MESSAGE:"
    puts response.message
    print "BODY:"
    puts response.raw_body

    response.code.should == 201
  end
=end

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
  end

  it 'should get a list of documents by method access' do
    list = @client.list

    list.totalResults.should =~ /\d+/
    list.totalResults.should_not equal('0')
    list.entry.size.should_not equal(0)
    list.entry[0].author.name.should == 'RGData.Library'
  end

  it 'should get a list of documents by hash access' do
    list = @client.list

    list['totalResults'].should =~ /\d+/
    list['totalResults'].should_not equal('0')
    list['entry'].size.should_not equal(0)
    list['entry'][0]['author'][0]['name'].should == 'RGData.Library'
  end

  it 'should get a list of documents by pseudo xpath access' do
    list = @client.list

    list['/entry'].size.should_not equal(0)
    list['/entry/0/author/name'].should == 'RGData.Library'
    list['/entry/author/name'].should == 'RGData.Library'
    list['/entry[0]/author@name'].should == 'RGData.Library'

    first_entry = list.entry[0]
    first_entry['/author/name'].should == 'RGData.Library'
    first_entry['/author@name'].should == 'RGData.Library'
  end

  after(:each) do
    @service = nil
    @client = nil
  end
end

