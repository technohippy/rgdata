require 'uri'
require 'net/http'
require 'rgdata/token/base'

module RGData
  module Token
    class ClientToken < Base
      CLIENT_LOGIN_URI = URI.parse('https://www.google.com/accounts/ClientLogin')

      def initialize(service, email, password)
        @service = service
        client_login(email, password)
      end

      def client_login(email, password)
        req = Net::HTTP::Post.new(CLIENT_LOGIN_URI.path)
        req.set_form_data(
          :acountType => 'HOSTED_OR_GOOGLE',
          :Email => email,
          :Passwd => password,
          :service => service.name,
          :source => request_source
        )
        https = RGData.get_https(CLIENT_LOGIN_URI)
        res = https.start {|conn| conn.request req}
        if res.kind_of? Net::HTTPSuccess
          @token_value = api_result_to_hash(res)['Auth']
        else
          res.error!
        end
      end

      def request_source
        "#{service.company_name}-#{service.application_name}-#{service.version_id}"
      end

      def header
        #{'Authorization' => "GoogleLogin auth=#{@token_value}"}
        {'Authorization' => "GoogleLogin auth=#{@token_value}", 'GData-Version' => '2'}
      end
    end
  end
end
