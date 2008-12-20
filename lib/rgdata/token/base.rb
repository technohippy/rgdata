module RGData
  module Token
    class Base
      attr_accessor :token_value, :service

      def api_result_to_hash(res)
        Hash[*res.body.split(/[\n|=]/)]
      end

      def upgrade!
        raise InvalidTokenError
      end

      def login_or_raise
        raise NeedLoggedInError unless token_value
      end

      def get_request(path, etag=nil)
        Net::HTTP.start(service.uri, 80) do |http|
          etag_header = etag ? {'If-None-Match' => etag} : {}
          http.get(path, header.update(etag_header))
        end
      end

      def list_xml(etag=nil)
        login_or_raise
        result = get_request(service.list_path, etag)
        check_result(result)
        result.body
      end

      def check_result(result)
        # TODO check and raise an error if something is wrong
      end
    end
  end
end
