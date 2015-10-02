require "store_search/version"
require "store_search/parsers/base_parser"
require "store_search/parsers/app_store_parser"
require "store_search/parsers/play_store_parser"
require "store_search/app_store"
require "store_search/play_store"
require "store_search/request"
require "store_search/app"

module StoreSearch
  NoResultsError              = Class.new(StandardError)
  RequestError                = Class.new(StandardError)
  InvalidCountryError         = Class.new(StandardError)
  InvalidAttributesError      = Class.new(ArgumentError)
  HTTPEmptyBodyError          = Class.new(StandardError)
  HTTPUnauthorizedError       = Class.new(StandardError)
  HTTPForbiddenError          = Class.new(StandardError)
  UnexpectedHTTPResponseError = Class.new(StandardError)
  MalformedResponseError      = Class.new(StandardError)
end
