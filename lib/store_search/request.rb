require 'rack/utils'
require 'addressable/uri'
require 'open-uri'

module StoreSearch
  class Request
    attr_accessor :path, :params, :uri

    def initialize(path, params = {})
      @path = path
      @params = params
      @uri = generate_uri(path, params)
    end

    # Public: Make an actual API calls.
    #
    # Examples
    #
    #   StoreSearch::Request.new('apps/ios', id: 'com.spotify').get # => <Response raw: '...', body: {}, .. />
    #
    # Returns wrapped and parsed StoreSearch::Response object.
    def get
      Response.new open(uri, http_options)
    end

    private

    # Internal: Generates URI based on configured URI, given path and params.
    #
    # Examples
    #
    #   generate_uri('apps/ios', id: '12341234', country_codes: %w[FR DE])
    #     # => http://storesearch.applift.com/api/v1/apps/ios?id=12341234&country_codes[]=FR&country_codes[]=DE
    #
    # Returns builded Addressable::URI object.
    def generate_uri(path, params)
      Addressable::URI.join(StoreSearch.configuration.base_uri, path).tap do |base_uri|
        base_uri.query = Rack::Utils.build_nested_query stringify_numbers_deep!(params.dup)
      end
    end

    # Fix for rack/utils issue: https://github.com/rack/rack/issues/557
    def stringify_numbers_deep!(hash)
      hash.each do |key, value|
        hash[key] = value.to_s         if value.kind_of?(Numeric)
        stringify_numbers_deep!(value) if value.kind_of?(Hash)
      end
    end

    def http_options
      {
        http_basic_authentication: [StoreSearch.configuration.username, StoreSearch.configuration.password]
      }
    end
  end
end
