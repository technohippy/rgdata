require 'rgdata'
require 'rgdata/documents_list/service'

describe RGData::DocumentsList::Service do
  before(:each) do
    @service = RGData::DocumentsList::Service.new
  end

  it 'should get a list of documents by method access' do
    client = @service.login 'RGData.Library@gmail.com', 'rgdatatest'
    list = client.list

    list.totalResults[0].should =~ /\d+/
    list.totalResults[0].should_not equal('0')
    list.entry.size.should_not equal(0)
    list.entry[0].title[0].type.should == 'text'
    list.entry[0].title.type.should == 'text'
  end

  it 'should get a list of documents by hash access' do
    client = @service.login 'RGData.Library@gmail.com', 'rgdatatest'
    list = client.list

    list['totalResults'][0].should =~ /\d+/
    list['totalResults'][0].should_not equal('0')
    list['entry'].size.should_not equal(0)
    list['entry'][0]['title'][0]['type'].should == 'text'
  end

  it 'should get a list of documents by pseudo xpath access' do
    client = @service.login 'RGData.Library@gmail.com', 'rgdatatest'
    list = client.list

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
  end
end

