require 'base64'
require 'pathname'
require 'rgdata/client'

module RGData
  module DocumentsList
    class Client < RGData::Client
      def upload(title, filepath=nil, meta=nil)
        if filepath.is_a?(Hash)
          meta = filepath[:metadata]
          filepath = filepath[:filepath]
        end
        metadata = metadata(title, meta)
        content = filepath ? File.read(filepath) : nil
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

        response = post_request('/feeds/documents/private/full', data, header)
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

      def metadata(title, meta)
        case meta
        when TrueClass; service.metadata(title)
        when FalseClass; nil
        when String;    meta
        else raise TypeError.new('metadata must be bool or string')
        end
      end
    end
  end
end

