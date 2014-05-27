# StoreSearch

Client for accessing the StoreSearch::API.

## Installation

Add this line to your application's Gemfile:

    gem 'store_search'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install store_search

## Usage

Configure client, i.e. rails initializer.

```ruby
StoreSearch.configure do |config|
  config.username = 'apiusername'
  config.password = 'apipassword'
end
```

Fetch iOS Spotify details in German, use Switzerland and Austria app stores as fallbacks.

```ruby
app = StoreSearch::App.new '', 'ios'
app.fetch_basic_info! country_code: 'DE', language_code: 'de', fallback_country_codes: %w[CH AT] # => {...}
# => {...}
app.title     # => Spotify
app.developer # => Spotify Ltd.
```

Fetch android Spotify details in Spanish.

```ruby
app = StoreSearch::App.new('com.android.spotify', 'android')
app.fetch_basic_info!(language_code: 'es') # => { ... }
app.title     # => Spotify
app.developer # => Spotify Ltd.
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/store_search/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
