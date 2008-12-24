require 'erb'
require 'rgdata/client'
require 'rgdata/token/client_token'
require 'rgdata/token/authsub_token'

module RGData
  class Service
    include ERB::Util

    attr_accessor :name, :uri, :company_name, :application_name, :version_id, :token

    def initialize(service_name='xapi', service_uri=nil)
      @name = service_name
      @uri = service_uri
      @company_name = 'N/A'
      @application_name = 'RGData'
      @version_id = RGData::VERSION
    end

    def login(email, password)
      client_class.new self, Token::ClientToken.new(self, email, password)
    end

    def self.login_uri(next_uri, scope, opts={})
      Token::AuthSubToken.login_uri(next_uri, scope, opts)
    end
    class <<self; alias login_url login_uri; end

    def login_uri(next_uri, opts={})
      options = {:secure => false, :session => true}.update opts
      options[:scope] ||= scope
      self.class.login_uri(next_uri, options[:scope], options)
    end
    alias login_url login_uri

    def accept(token_value, want_upgrade=true)
      client = client_class.new self, Token::AuthSubToken.new(self, token_value)
      client.upgrade! if want_upgrade
      client
    end

    def self.oauth_login_uri
      raise NotImplementedError
    end
    class <<self; alias oauth_login_url oauth_login_uri; end

    def oauth_login_uri
      self.class.oauth_login_uri
    end
    alias oauth_login_url oauth_login_uri

    protected

    def template(template_path, binding=TOP_LEVEL_BINDING)
      script = File.read("#{File.dirname(__FILE__)}/#{template_path}.erb")
      ERB.new(script, nil, '-').result(binding)
    end

    ## extension points for subclasses ##

    def scope
      raise NotInitializedError.new('@uri') unless uri
      "http://#{uri}/feeds"
    end

    def client_class
      ::RGData::Client
    end
  end
end
