require 'rgdata'
require 'rgdata/documents_list/service'

describe RGData::DocumentsList::Service do
  before(:each) do
    @service = RGData::DocumentsList::Service.new
    @client = @service.login 'RGData.Library@gmail.com', 'rgdatatest'
  end

  it 'should upload csv file' do
    title = "RGData Test (#{Time.now})"
    filepath = "#{File.dirname(__FILE__)}/rsc/documents_list_upload.csv"
    need_metadata = true

    response = @client.upload title, filepath, need_metadata

    print "CODE:"
    puts response.code
    print "MESSAGE:"
    puts response.message
    print "BODY:"
    puts response.body

    response.code.should == '201'
  end

  it 'should get a list of documents by method access' do
    list = @client.list

    list.totalResults[0].should =~ /\d+/
    list.totalResults[0].should_not equal('0')
    list.entry.size.should_not equal(0)
    list.entry[0].title[0].type.should == 'text'
    list.entry[0].title.type.should == 'text'
  end

  it 'should get a list of documents by hash access' do
    list = @client.list

    list['totalResults'][0].should =~ /\d+/
    list['totalResults'][0].should_not equal('0')
    list['entry'].size.should_not equal(0)
    list['entry'][0]['title'][0]['type'].should == 'text'
  end

  it 'should get a list of documents by pseudo xpath access' do
    list = @client.list

    list['/entry'].size.should_not equal(0)
    list['/entry/0/title/0/type'].should == 'text'
    list['/entry/title/type'].should == 'text'
    list['/entry[0]/title@type'].should == 'text'

    first_entry = list.entry[0]
    first_entry['/title/0/type'].should == 'text'
    first_entry['/title/type'].should == 'text'
    first_entry['/title@type'].should == 'text'
  end

  after(:each) do
    @service = nil
    @client = nil
  end
end

