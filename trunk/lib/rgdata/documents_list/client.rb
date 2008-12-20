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
        boundary = "MULTIPART_BOUNDARY-#{Time.now.to_i}-#{rand(1000000)}"

        data = ''
        data += <<-eos if metadata
--#{boundary}
Content-Type: application/atom+xml

#{metadata}
        eos
        data += <<-eos if content
--#{boundary}
Content-Type: #{content_type(filepath)}

#{content}
        eos
        #{Base64.encode64(content)}
        data += "--#{boundary}--\n"
=begin
puts '****'
puts data
puts '****'
=end

        header = {
          'Content-Type' => "multipart/related; boundary=#{boundary}",
          'Content-Length' => data.size.to_s
        }
        if content
          metadata \
            ? header.update('Slug' => File.basename(filepath)) \
            : header.update('Slug' => title)
        end

        response = post_request('/feeds/documents/private/full', data, header)
      end

      protected

      def metadata(title, meta)
        case meta
        when TrueClass; service.metadata(title)
        when String;    meta
        else raise TypeError.new('metadata must be bool or string')
        end
      end
    end
  end
end

