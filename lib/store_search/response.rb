require 'json'

module StoreSearch
  class Response
    attr_accessor :raw, :body, :status, :success, :error

    def initialize(http_response)
      @status = http_response.status.first.to_i
      @raw    = http_response.read

      begin
        @body    = JSON.parse @raw
        @success = @body['success']
        @error   = @body['error']
      rescue => e
        @success = false
        @error   = e
      end
    end
  end
end
