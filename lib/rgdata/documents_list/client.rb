require 'base64'
require 'pathname'
require 'uri'
require 'rgdata/client'

module RGData
  module DocumentsList
    class Client < RGData::Client
      def upload(title, opts={:metadata => true})
        metadata = metadata(title, opts[:metadata])
        filepath = opts[:filepath]
        content = opts[:content] || (filepath ? File.read(filepath) : nil)
        response = post_request(*create_upload_params(metadata, content, filepath))
      end

      def update(entry, opts)
        metadata = opts[:title] ? metadata(opts[:title], true, entry['gd:etag']) : nil
        filepath = opts[:filepath]
        content = opts[:content] || (filepath ? File.read(filepath) : nil)
        response = put_request(*create_upload_params(metadata, content, filepath, entry))
      end

      protected

      def create_upload_params(metadata, content, filepath, entry=nil)
        eid = entry ? entry['id'].split('%3A').last : nil
        header = {}
        data = nil
        link = nil
        if metadata and content
          boundary = "MULTIPART_BOUNDARY-#{Time.now.to_i}-#{rand(1000000)}"
          data = upload_body(content, metadata, filepath, boundary)
          header['Content-Type'] = "multipart/related; boundary=#{boundary}"
          header['Slug'] = File.exist?(filepath) ? File.basename(filepath) : "teporary.#{filepath}"
          link = entry \
            ? service.edit_media_path(entry.category.label, eid) \
            : service.new_path
        elsif metadata
          data = metadata
          header['Content-Type'] = "application/atom+xml"
          link = entry \
            ? service.edit_path(entry.category.label, eid) \
            : service.new_path
        elsif content
          data = content
          header['Content-Type'] = content_type(filepath)
          header['Slug'] = File.exist?(filepath) ? File.basename(filepath) : "temporary.#{filepath}"
          header['If-Match'] = entry['gd:etag'] if entry
          link = entry \
            ? service.edit_media_path(entry.category.label, eid) \
            : service.new_path
        else
          raise ArgumentError.new('filepath or metadata must exist')
        end
        header['Content-Length'] = data.size.to_s

        [link, data, header]
      end

      def upload_body(content, metadata, filepath, boundary)
        return content unless metadata
        return metadata unless content

        <<-eos
--#{boundary}
Content-Type: application/atom+xml

#{metadata}
--#{boundary}
Content-Type: #{content_type(filepath)}

#{content}
--#{boundary}--
        eos
        #{Base64.encode64(content)}
      end

      def metadata(title, meta, etag=nil)
        case meta
        when TrueClass; service.metadata(title, etag)
        when FalseClass; nil
        when String;    meta
        else raise TypeError.new('metadata must be bool or string')
        end
      end
    end
  end
end

