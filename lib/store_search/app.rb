module StoreSearch
  class App
    PLATFOMR_IDS = %w[ios android]

    RequestError           = Class.new(StandardError)
    InvalidAttributesError = Class.new(ArgumentError)

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
    ]

    attr_accessor :id, :platform_id, :errors
    attr_accessor *APPLICATION_FIELDS

    def initialize(id, platform_id)
      @id          = id
      @platform_id = platform_id
      @errors      = []
    end

    # Public: Makes an API call to grab the application details from app store, if the app is valid.
    #
    # country_codes - an array of valid "ISO 3166-1 alpha-2" country_codes,
    #                 which API will use as addition in search for the basic info.
    #
    # Exaples
    #
    #   app = StoreSearch::App.new('com.android.spotify', :android)
    #   app.fetch_basic_info!(%w[DE FR GB]) # => {'title' => 'Spotify', 'description' => '...', 'icon_url' => '...'}
    #   app.title # => 'Spotify'
    #
    #   app = StoreSearch::App.new('000000', :ios)
    #   app.fetch_basic_info! # => nil
    #   app.title # => nil
    #
    # Returns a hash with app details if app was found, nil otherwise.
    # Raises StoreSearch::App::InvalidAttributesError if application is invalid.
    # Raises StoreSearch::App::Returns if request failed.
    def fetch_basic_info!(country_codes = [])
      raise InvalidAttributesError, errors.join(', ') unless valid?

      response = Request.new("apps/#{ platform_id }", id: id, country_codes: country_codes).get

      case response.status
      when 200
        assign_attributes response.body['app']
      when 404
        nil
      else
        raise RequestError, response.error
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
      @errors << "unknown platform_id" unless PLATFOMR_IDS.include?(platform_id.to_s)

      @errors.empty?
    end

    private

    def assign_attributes(hash)
      APPLICATION_FIELDS.each do |field|
        send "#{field}=", hash[field]
      end

      hash
    end
  end
end
