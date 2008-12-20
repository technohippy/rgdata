require 'rgdata/service'
require 'rgdata/documents_list/client'

module RGData
  module DocumentsList
    class Service < RGData::Service
      SERVICE_NAME = 'writely'
      SERVICE_URI = 'docs.google.com'

      def initialize
        super SERVICE_NAME, SERVICE_URI
      end

      def client_class
        ::RGData::DocumentsList::Client
      end

      def list_path
        '/feeds/documents/private/full'
      end

      def metadata(title)
        # http://code.google.com/intl/en/apis/documents/docs/2.0/developers_guide_protocol.html#UploadingWMetadata
        %Q{
<?xml version='1.0' encoding='UTF-8'?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:category scheme="http://schemas.google.com/g/2005#kind"
      term="http://schemas.google.com/docs/2007#document" />
  <atom:title>#{title}</atom:title>
</atom:entry>        
        }
      end
    end
  end
end
