require 'rgdata/service'
require 'rgdata/documents_list/client'

module RGData
  module DocumentsList
    class Service < RGData::Service
      SERVICE_NAME = 'writely'
      SERVICE_URI = 'docs.google.com'

      def initialize
        super SERVICE_NAME, SERVICE_URI
        @visibility = 'private'
        @projection = 'full'
      end

      def client_class
        ::RGData::DocumentsList::Client
      end

      def folder_path
        '/feeds/folders/private/full'
      end

      def list_path(opts={})
        "/feeds/documents/#{opts[:visibility] || @visibility}/#{opts[:projection] || @projection}"
      end

      def new_path(opts={})
        list_path(opts)
      end

      def create_folder_path(opts={})
        list_path(opts)
      end

      def edit_path(category, eid, opts={})
        "/feeds/documents/#{opts[:visibility] || @visibility}/#{opts[:projection] || @projection}/#{category}%3A#{eid}"
      end

      def edit_media_path(category, eid)
        "/feeds/media/private/full/#{category}%3A#{eid}"
      end

      def delete_path(category, eid)
        edit_path(category, eid)
      end

      # http://code.google.com/intl/en/apis/documents/docs/2.0/developers_guide_protocol.html#UploadingWMetadata
      # http://code.google.com/intl/ja/apis/documents/docs/2.0/developers_guide_protocol.html#UpdatingMetadata
      def metadata(title, etag=nil)
        template('documents_list/document.xml', binding)
      end

      # http://code.google.com/intl/en/apis/documents/docs/2.0/developers_guide_protocol.html#CreateFolders
      def folder_metadata(title)
        template('documents_list/folder.xml', binding)
      end
    end
  end
end
