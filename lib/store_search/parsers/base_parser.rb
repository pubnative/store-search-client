require 'time'

module StoreSearch
  class BaseParser < Struct.new(:params)
    UNITS = %W(B KB MB GB TB).freeze

    class << self
      def parse(params)
        new(params).to_hash
      end
    end

    APPLICATION_FIELDS = %i[
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

    APPLICATION_FIELDS.each do |field|
      define_method(field) {}
    end

    def to_hash
      APPLICATION_FIELDS.reduce({}) do |hash, field|
        hash.merge field => send(field)
      end
    end

    private

    def find_image_url(image_urls)
      url = image_urls.compact.reject(&:empty?).first
      if url && url.start_with?('//')
        'http:' + url
      else
        url
      end
    end

    def number_to_human_size number
      if number.to_i < 1024
        exponent = 0

      else
        max_exp  = UNITS.size - 1

        # Convert
        exponent = ( Math.log( number ) / Math.log( 1024 ) ).to_i
        # Avoid overflow
        exponent = max_exp if exponent > max_exp

        number = number.to_f / 1024 ** exponent
      end

      "#{number.round(1)} #{UNITS[ exponent ]}"
    end
  end
end
