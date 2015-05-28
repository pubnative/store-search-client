require 'rack/utils'
require 'addressable/uri'
require 'open-uri'

module StoreSearch
  class Request
    attr_accessor :platform_id, :params

    PLATFORMS = {
      ios:  { search: AppStore },
      android:  { search: PlayStore }
    }

    def initialize(platform_id, params = {})
      @platform_id = platform_id.to_sym
      @params = params
    end

    # Public: Fetch details from plataform.
    #
    # Returns details Hash.
    def get
      search = PLATFORMS[platform_id][:search]
      search.fetch_app_details params[:id], params
    end

    private
    # Fix for rack/utils issue: https://github.com/rack/rack/issues/557
    def stringify_numbers_deep!(hash)
      hash.each do |key, value|
        hash[key] = value.to_s         if value.kind_of?(Numeric)
        stringify_numbers_deep!(value) if value.kind_of?(Hash)
      end
    end
  end
end
