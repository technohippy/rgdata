require 'rgdata/service'
require 'net/http'
require 'net/https'

module RGData
  VERSION = '1.0.0'

  class NeedLoggedInError < StandardError; end
  class InvalidTokenError < StandardError; end
  class AlreadyUpgradedError < StandardError; end
  class NotInitializedError < StandardError; end

  # http://code.google.com/support/bin/answer.py?answer=62712&topic=10711
  module ServiceNames
    CALENDAR = 'cl'
    GOOGLE_BASE = 'gbase'
    BLOGGER = 'blogger'
    CONTACTS = 'cp'
    DOCUMENTS_LIST = 'writely'
    PICASA_WEB_ALBUMS = 'lh2'
    GOOGLE_APPS_PROVISIONING = 'apps'
    SPREADSHEETS = 'wise'
    YOUTUBE = 'youtube'

    def self.lookup(str)
      case str.downcase
      when /calend/;  CALENDAR
      when /base/;    GOOGLE_BASE
      when /blog/;    BLOGGER
      when /contact/; CONTACTS
      when /doc/;     DOCUMENTS_LIST
      when /pic/;     PICASA_WEB_ALBUMS
      when /app/;     GOOGLE_APPS_PROVISIONING
      when /sheet/;   SPREADSHEETS
      when /tube/;    YOUTUBE
      end
    end
  end

  def self.get_https(uri)
    https = Net::HTTP.new(uri.host, 443)
    https.use_ssl = true
    https
  end
end
