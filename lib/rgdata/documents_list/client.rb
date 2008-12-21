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
        header ={}
        data = ''
        if metadata and content
          boundary = "MULTIPART_BOUNDARY-#{Time.now.to_i}-#{rand(1000000)}"
          data = upload_body(content, metadata, filepath, boundary)
          header['Content-Type'] = "multipart/related; boundary=#{boundary}"
          header['Slug'] = File.basename(filepath)
        elsif metadata
          data = metadata
          header['Content-Type'] = "application/atom+xml"
        elsif content
          data = content
          header['Content-Type'] = content_type(filepath)
          header['Slug'] = title
        else
          raise ArgumentError.new('filepath or metadata must exist')
        end
        header['Content-Length'] = data.size.to_s

        response = post_request(service.new_path, data, header)
      end

      def update(entry, opts)
        eid = entry['id'].split('%3A').last
        etag = entry['gd:etag']
        metadata = opts[:title] ? metadata(opts[:title], true, etag) : nil
        filepath = opts[:filepath]
        content = opts[:content] || (filepath ? File.read(filepath) : nil)
        header ={}
        data = nil
        link = nil
        if metadata and content
          boundary = "MULTIPART_BOUNDARY-#{Time.now.to_i}-#{rand(1000000)}"
          data = upload_body(content, metadata, filepath, boundary)
          header['Content-Type'] = "multipart/related; boundary=#{boundary}"
          header['Slug'] = File.exist?(filepath) ? File.basename(filepath) : "teporary.#{filepath}"
          link = service.edit_media_path(entry.category.label, eid)
        elsif metadata
          data = metadata
          header['Content-Type'] = "application/atom+xml"
          link = service.edit_path(entry.category.label, eid)
        elsif content
          data = content
          header['Content-Type'] = content_type(filepath)
          header['Slug'] = File.exist?(filepath) ? File.basename(filepath) : "temporary.#{filepath}"
          header['If-Match'] = etag
          link = service.edit_media_path(entry.category.label, eid)
        else
          raise ArgumentError.new('filepath or metadata must exist')
        end
        header['Content-Length'] = data.size.to_s

        response = put_request(link, data, header)
      end

      protected

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

