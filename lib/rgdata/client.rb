require 'xmlsimple'
require 'rgdata/util/hash_with_accessor'

module RGData
  class Client
    attr_accessor :token

    def initialize(token)
      @token = token
    end

    def upgrade!
      token.upgrade!
    end

    def list_xml(etag=nil)
      token.list_xml(etag)
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

    def xml2obj(xml)
      hash = xml2hash xml
      Util::HashWithAccessor.from_hash hash
    end

    def xml2hash(xml)
      XmlSimple.xml_in xml
    end
  end
end
