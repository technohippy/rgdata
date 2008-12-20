require 'xmlsimple'
require 'rgdata/util/hash_with_accessor'

module RGData
  class Response
    def initialize(http_response)
      @http_response = http_response
    end

    def code
      @http_response.code.to_i
    end

    def success?
      code / 100 == 2
    end

    def error?
      not success?
    end

    def message
      @http_response.message
    end

    def raw_body
      @http_response.body
    end

    def body(type=nil)
      case type
      when NilClass; body_obj rescue raw_body
      when :raw; raw_body
      when :obj; body_obj
      when :hash; body_hash
      else raw_body
      end
    end

    def body_hash
      xml2hash raw_body
    end

    def body_obj
      xml2obj raw_body
    end

    protected

    def xml2obj(xml)
      hash = xml2hash xml
      Util::HashWithAccessor.from_hash hash
    end

    def xml2hash(xml)
      XmlSimple.xml_in xml
    end
  end
end
