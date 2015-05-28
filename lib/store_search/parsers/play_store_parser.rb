require 'htmlentities'
require 'sanitize'

module StoreSearch
  class PlayStoreParser < BaseParser
    def title
      params.title
    end

    def description
      description = params.description.gsub(/<\s*br\s*\/?\s*>/, "\n")       # replace <br/> with \n
      description = description.gsub(/(?=<\s*p\s*>)/, "\n")                 # add \n before <p>
      description = description.gsub(/(display\s*:\s*none.*?>)(.*)/m, '\1') # remove text after style="display:none">
      HTMLEntities.new.decode Sanitize.fragment(description, Sanitize::Config::RESTRICTED).strip
    end

    def publisher
      developer
    end

    def developer
      params.developer.to_s.strip
    end

    def version
      params.current_version
    end

    def memory
      params.size
    end

    def release_date
      Time.parse params.updated.to_s
    end

    def min_os_version
      params.requires_android.to_s.scan(/^\d+(?:\.\d+)*/).first
    end

    def age_rating
      params.content_rating
    end

    def rating
      params.rating
    end

    def categories
      [params.category]
    end

    def icon_url
      find_image_url [params.banner_icon_url, params.banner_image_url]
    end

    def screenshot_urls
      params.screenshot_urls
    end

    def platforms
      ['Android']
    end

    def supported_devices
      []
    end

    def total_ratings
      params.votes.to_s.gsub(/\D/, '')
    end

    def installs
      params.installs
    end
  end
end
