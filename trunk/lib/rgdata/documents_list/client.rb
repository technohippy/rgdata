require 'uri'
require 'rgdata/client'
require 'rgdata/documents_list/response'

module RGData
  module DocumentsList
    class Client < RGData::Client
      def upload(title, opts={:metadata => true})
        metadata = metadata(title, opts[:metadata])
        filepath = opts[:filepath]
        content = opts[:content] || (filepath ? File.read(filepath) : nil)
        post_request(*create_upload_params(metadata, content, filepath))
      end

      def update(entry, opts)
        metadata = opts[:title] ? metadata(opts[:title], true, entry['gd:etag']) : nil
        filepath = opts[:filepath]
        content = opts[:content] || (filepath ? File.read(filepath) : nil)
        put_request(*create_upload_params(metadata, content, filepath, entry))
      end

      def create_folder(title)
        link = service.create_folder_path
        data = service.folder_metadata(title)
        header = {
          'Content-Length' => data.size.to_s,
          'Content-Type' => 'application/atom+xml'
        }
        post_request(link, data, header)
      end

      def trash(entry, opts={})
        eid = entry ? entry['id'].split('%3A').last : nil
        header = {'IF-Match' => (opts[:force] ? entry['gd:etag'] : '*')}
        link = service.delete_path(entry.category.label, eid)
        delete_request(link, header)
      end
      alias delete trash

      def retrieve(opts={})
        if opts.empty?
          list
        elsif opts[:folder]
          retrieve_folder opts[:folder]
        else
          retrieve_category opts
        end
      end

      def retrieve_folder(folder_id)
        get_request("#{service.folder_path}/folder%3A#{folder_id}")
      end

      def retrieve_category(opts={})
        category_path = lambda do |arg|
          case arg
          when String, Symbol
            arg.to_s
          when Hash
            cat, email = arg.to_a.first
            "{http:%2F%2Fschemas.google.com%2Fdocs%2F2007%2Ffolders%2F#{email}}#{cat}"
          when Array
            arg.map{|c| category_path.call(c)}.join('/')
          else
            raise ArgumentError.new('argument should be string, symbol, array, or hash')
          end
        end

        link = service.list_path
        link += "/-/#{category_path.call(opts[:category])}" if opts[:category]
        link += "?q=#{URI.encode(opts[:query])}" if opts[:query]
        link += "#{opts[:query] ? '&' : '?'}showfolders=true" if opts[:show_folders] or opts[:showfolders]
        get_request(link)
      end

      protected

      def response_class
        ::RGData::DocumentsList::Response
      end

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

