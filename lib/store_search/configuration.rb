module StoreSearch
  class Configuration
    attr_accessor :protocol, :host, :api_version, :username, :password

    def initialize
      @protocol = 'http'
      @host = 'storesearch.applift.com'
      @api_version = 'v1'
      @username = ''
      @password = ''
    end

    def base_uri
      "#{ @protocol }://#{ @host }/api/#{ @api_version }/"
    end
  end
end
