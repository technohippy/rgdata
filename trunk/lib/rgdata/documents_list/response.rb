require 'rgdata/response'

module RGData
  module DocumentsList
    class Response < RGData::Response
      protected

      def xml2obj(xml)
        obj = super
        if obj['totalResults']
          obj['totalResults'] = obj['totalResults'].to_i
          obj['entry'] = [] if obj['totalResults'] == 0
        end
        if obj['entry']
          obj.entry.each do |entry|
            def entry.delete!(opts={})
              self[:client].trash(self, opts)
            end

            def entry.trush!(opts={})
              self[:client].trash(self, opts)
            end

            def entry.update!(opts={})
              @new_title = opts[:title] if opts[:title]
              @new_content = opts[:content] if opts[:content]
              self[:client].update(self, :title => @new_title, :content => @new_content)
            end

            def entry.title=(val)
              @new_title = val
            end

            def entry.content=(val)
              @new_content = val
            end

            def entry.id?
              self['id'].split('%3A').last
            end
          end
        end
        obj
      end
    end
  end
end
