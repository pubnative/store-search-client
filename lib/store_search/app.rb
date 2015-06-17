module StoreSearch
  class App
    PLATFORM_IDS = %w[ios android]

    APPLICATION_FIELDS = %w[
      title
      description
      publisher
      developer
      version
      memory
      release_date
      min_os_version
      age_rating
      rating
      categories
      icon_url
      screenshot_urls
      platforms
      supported_devices
      total_ratings
      installs
    ]

    attr_accessor :id, :platform_id, :errors
    attr_accessor *APPLICATION_FIELDS

    def initialize(id, platform_id)
      @id          = id
      @platform_id = platform_id
    end

    # Public: Makes an API call to grab the application details from app store, if the app is valid.
    #
    # country_code           - valid "ISO 3166-1 alpha-2" store country code
    # language_code          - valid language code, i.e. 'en', 'en_GB', 'es_MX', etc.
    # fallback_country_codes - an array of valid "ISO 3166-1 alpha-2" country_codes,
    #                          which API will use as fallback for search in store.
    #
    # Exaples
    #
    #   app = StoreSearch::App.new('com.android.spotify', :android)
    #   app.fetch_basic_info!(country_code: 'US', fallback_country_codes: %w[DE FR GB])
    #   # => {'title' => 'Spotify', 'description' => '...', 'icon_url' => '...'}
    #   app.title
    #   # => 'Spotify'
    #
    #   app = StoreSearch::App.new('000000', :ios)
    #   app.fetch_basic_info! # => nil
    #   app.title # => nil
    #
    # Returns a hash with app details if app was found, nil otherwise.
    # Raises StoreSearch::App::InvalidAttributesError if application is invalid.
    # Raises StoreSearch::App::RequestError if request failed.
    def fetch_basic_info!(country_code: nil, language_code: nil, fallback_country_codes: nil)
      raise InvalidAttributesError, errors.join(', ') unless valid?
      country_code ||= 'US'
      language_code ||= 'en'
      fallback_country_codes ||= []

      response = Request.new(platform_id,
        {
          id: id,
          country_code:  country_code,
          language_code: language_code,
          fallback_country_codes: fallback_country_codes,
        }
      ).get

      if !response.empty?
        assign_attributes response
      else
        raise RequestError
      end
    end

    # Public: Validates the app attributes. Stores errors for futher investigation.
    #
    # Examples
    #
    #   app = StoreSearch::App.new nil, 'windows'
    #   app.valid? # => false
    #   app.errors # => ['missing app id', 'unknown platform_id']
    #
    # Returns boolean based on validation rules.
    def valid?
      @errors = []

      @errors << "missing app id"      if id.to_s.empty?
      @errors << "unknown platform_id" unless PLATFORM_IDS.include?(platform_id.to_s)

      @errors.empty?
    end

    private

    def assign_attributes(hash)
      APPLICATION_FIELDS.each do |field|
        send "#{field}=", hash[field.to_sym]
      end

      hash
    end
  end
end
