module StoreSearch
  class AppStoreParser < BaseParser
    def title
      params['trackName']
    end

    def description
      params['description']
    end

    def publisher
      params['sellerName']
    end

    def developer
      params['artistName']
    end

    def version
      params['version']
    end

    def memory
      number_to_human_size params['fileSizeBytes'].to_i
    end

    def release_date
      params['releaseDate'] && Time.parse(params['releaseDate'])
    end

    def age_rating
      params['contentAdvisoryRating'] || params['trackContentRating']
    end

    def rating
      params['averageUserRating'].to_s
    end

    def categories
      params['genres']
    end

    def icon_url
      find_image_url [params['artworkUrl512'], params['artworkUrl100'], params['artworkUrl60']]
    end

    def screenshot_urls
      params['screenshotUrls'] | params['ipadScreenshotUrls']
    end

    def platforms
      params['features']
    end

    def supported_devices
      params['supportedDevices']
    end

    def total_ratings
      params['userRatingCount']
    end

    def installs
      ''
    end
  end
end
