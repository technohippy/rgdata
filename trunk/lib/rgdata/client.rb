require 'base64'
require 'xmlsimple'
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
      Net::HTTP.start(service.uri, 80) do |http|
        http.get(path, token.header.merge(header))
      end
    end

    def post_request(path, data, header={})
      Net::HTTP.start(service.uri, 80) do |http|
puts token.header.merge(header).inspect
        http.post(path, data, token.header.merge(header))
      end
    end

    def list_xml(etag=nil)
      token.login? or raise NeedLoggedInError
      header = etag ? {'If-None-Match' => etag} : {}
      result = get_request(service.list_path, header)
      check_result(result)
      result.body
    end

    def check_result(result)
      # TODO check and raise an error if something is wrong
    end

    def list_hash(etag=nil)
      xml2hash list_xml(etag)
    end

    def list_obj(etag=nil)
      xml2obj list_xml(etag)
    end

    def list(etag=nil, format='obj')
      case format.to_s.downcase
      when 'hash';          list_hash(etag)
      when 'xml', 'string'; list_xml(etag)
      else;                 list_obj(etag)
      end
    end

    protected

    def xml2obj(xml)
      hash = xml2hash xml
      Util::HashWithAccessor.from_hash hash
    end

    def xml2hash(xml)
      XmlSimple.xml_in xml
    end

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
