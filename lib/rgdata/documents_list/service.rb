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

      def new_path
        list_path
      end

      def create_folder_path
        list_path
      end

      def edit_path(category, eid)
        "/feeds/documents/private/full/#{category}%3A#{eid}"
      end

      def edit_media_path(category, eid)
        "/feeds/media/private/full/#{category}%3A#{eid}"
      end

      # http://code.google.com/intl/en/apis/documents/docs/2.0/developers_guide_protocol.html#UploadingWMetadata
      # http://code.google.com/intl/ja/apis/documents/docs/2.0/developers_guide_protocol.html#UpdatingMetadata
      def metadata(title, etag=nil)
        %Q{
<?xml version='1.0' encoding='UTF-8'?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom"#{etag ? %Q( xmlns:gd="http://schemas.google.com/g/2005" gd:etag="#{etag.gsub('"', '&quot;')}") : ''}>
  <atom:category scheme="http://schemas.google.com/g/2005#kind"
      term="http://schemas.google.com/docs/2007#document" />
  <atom:title>#{title}</atom:title>
</atom:entry>        
        }.strip
      end

      # http://code.google.com/intl/en/apis/documents/docs/2.0/developers_guide_protocol.html#CreateFolders
      def folder_metadata(title)
        %Q{
<?xml version='1.0' encoding='UTF-8'?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:category scheme="http://schemas.google.com/g/2005#kind" 
      term="http://schemas.google.com/docs/2007#folder" label="folder"/>
  <atom:title>#{title}</atom:title>
</atom:entry>
        }.strip
      end
    end
  end
end
