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

    def list_xml
      token.list_xml
    end

    def list_hash
      xml2hash list_xml
    end

    def list_obj
      xml2obj list_xml
    end

    def list(format='obj')
      case format.to_s.downcase
      when 'hash';          list_hash
      when 'xml', 'string'; list_xml
      else;                 list_obj
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
