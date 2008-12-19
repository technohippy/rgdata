require 'rgdata'
require 'rgdata/service'

describe RGData::Service do
  before(:each) do
    @service = RGData::Service.new('writely', 'docs.google.com')
  end

  it 'should login and get valid client' do
    client = @service.login 'RGData.Library@gmail.com', 'rgdatatest'
    client.should_not nil
  end

  after(:each) do
    @service = nil
  end
end
