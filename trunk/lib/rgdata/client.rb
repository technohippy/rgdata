require 'base64'
require 'xmlsimple'
require 'rgdata/response'
require 'rgdata/util/hash_with_accessor'

module RGData
  class Client
    attr_accessor :token, :service

    def initialize(service, token)
      @service = service
      @token = token
    end

    def upgrade!
      token.upgrade!
    end

    def get_request(path, header={})
      http_response = Net::HTTP.start(service.uri, 80) do |http|
        http.get(path, token.header.merge(header))
      end
      Response.new(http_response)
    end

    def post_request(path, data, header={})
      Net::HTTP.start(service.uri, 80) do |http|
puts token.header.merge(header).inspect
        http.post(path, data, token.header.merge(header))
      end
    end

    def list(etag=nil)
      token.login? or raise NeedLoggedInError
      header = etag ? {'If-None-Match' => etag} : {}
      response = get_request(service.list_path, header)
      check_response(response)
      response.body
    end

    def check_response(response)
      # TODO check and raise an error if something is wrong
    end

    protected

    # http://code.google.com/intl/en/apis/documents/faq.html#WhatKindOfFilesCanIUpload
    def content_type(filepath)
      {
        ".csv" => 'text/csv', 
        ".tsv" => 'text/tab-separated-values', 
        ".tab" => 'text/tab-separated-values', 
        ".html" => ' text/html', 
        ".htm" => 'text/html', 
        ".doc" => 'application/msword', 
        ".ods" => 'application/x-vnd.oasis.opendocument.spreadsheet', 
        ".odt" => 'application/vnd.oasis.opendocument.text', 
        ".rtf" => 'application/rtf', 
        ".sxw" => 'application/vnd.sun.xml.writer', 
        ".txt" => 'text/plain', 
        ".xls" => 'application/vnd.ms-excel', 
        ".ppt" => 'application/vnd.ms-powerpoint', 
        ".pps" => 'application/vnd.ms-powerpoint'
      }[File.extname(filepath).downcase]
    end

  end
end
