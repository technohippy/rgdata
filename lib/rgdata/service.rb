require 'rgdata/client'
require 'rgdata/token/client_token'
require 'rgdata/token/authsub_token'

module RGData
  class Service
    attr_accessor :name, :uri, :company_name, :application_name, :version_id, :token

    def initialize(service_name, service_uri)
      @name = service_name
      @uri = service_uri
      @company_name = 'N/A'
      @application_name = 'RGData'
      @version_id = RGData::VERSION
    end

    def login(email, password)
      client_class.new Token::ClientToken.new(self, email, password)
    end

    def self.login_uri(next_uri, scope, opts={})
      Token::AuthSubToken.login_uri(next_uri, scope, opts)
    end

    def login_uri(next_uri, opts={})
      options = {:scope => scope, :secure => false, :session => true}.update opts
      self.class.login_uri(next_uri, options[:scope], options)
    end

    def accept(token_value, want_upgrade=true)
      client = client_class.new Token::AuthSubToken.new(self, token_value)
      client.upgrade! if want_upgrade
      client
    end

    def self.oauth_login_uri
      raise StandardError.new('Not implemented yet')
    end

    def oauth_login_uri
      self.class.oauth_login_uri
    end

    ## extension points for subclasses ##

    def scope
      "http://#{uri}/feeds"
    end

    def client_class
      ::RGData::Client
    end
  end
end
