require 'uri'
require 'rgdata'
require 'rgdata/token/base'

module RGData
  module Token
    class AuthSubToken < Base
      AUTHSUB_REQUEST_URI = URI.parse('https://www.google.com/accounts/AuthSubRequest')
      AUTHSUB_SESSION_URI = URI.parse('https://www.google.com/accounts/AuthSubSessionToken')

      def self.login_uri(next_uri, scope, opts={})
        options = {:secure => false, :session => true}.update opts
        scope = scope.join(' ') if scope.is_a? Array
        AUTHSUB_REQUEST_URI.to_s +
          "?next=#{URI.encode(next_uri)}" +
          "&scope=#{URI.encode(scope)}" +
          "&secure=#{options[:secure] ? 1 : 0}" +
          "&session=#{options[:session] ? 1 : 0}" +
          "&hd=#{options[:hd]}"
      end

      def initialize(service, token_value)
        @service, @token_value = service, token_value
        @expiration = nil
      end

      def upgrade_to_session_token!
        raise AlreadyUpgradedError if session_token?
        login_or_raise

        https = RGData.get_https(AUTHSUB_SESSION_URI)
        res = https.get(AUTHSUB_SESSION_URI.path,
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Authorization' => "AuthSub token=\"#{token_value}\"",
          'User-Agent' => "RGData/#{RGData::VERSION}"
        )
        @token_value = api_result_to_hash(res)['Token']
        @expiration = api_result_to_hash(res)['Expiration']
      end
      alias upgrade! upgrade_to_session_token!

      def session_token?
        not @expiration.nil?
      end

      def header
        #{'Authorization' => %Q[AuthSub token="#{@token_value}"]}
        {'Authorization' => %Q[AuthSub token="#{@token_value}"], 'GData-Version' => '2'}
      end
    end
  end
end

