require "market_bot"

module StoreSearch
  class PlayStore
    class << self
      def fetch_app_details(app_store_id, params = {})
        begin
          language_code = params[:language_code].nil? ? 'en' : params[:language_code]

          app = MarketBot::Android::App.new app_store_id, language: language_code
          app.update

          PlayStoreParser.parse(app)
        rescue => e
          raise NoResultsError, 'Could not find game in Play Store'
        end
      end
    end
  end
end
