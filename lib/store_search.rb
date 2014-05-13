module StoreSearch
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configuration=(new_configuration)
      @configuration = new_configuration
    end

    def configure
      yield(configuration)
    end
  end
end

require "store_search/version"
require "store_search/configuration"
