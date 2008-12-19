require 'rgdata/service'

module RGData
  module DocumentsList
    class Service < RGData::Service
      SERVICE_NAME = 'writely'
      SERVICE_URI = 'docs.google.com'

      def initialize
        super SERVICE_NAME, SERVICE_URI
      end

      def list_path
        '/feeds/documents/private/full'
      end
    end
  end
end
