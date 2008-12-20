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

      def login?
        not token_value.nil?
      end

      def login_or_raise
        raise NeedLoggedInError unless login?
      end
    end
  end
end
