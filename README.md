# StoreSearch

Service for accessing App/Play Store search in an unified way.

## Installation

Add this line to your application's Gemfile:

    gem 'store_search'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install store_search

## Usage

There's an rake task where you can test out the client, just run `rake console` and configure it

Fetch iOS Spotify details in German, use Switzerland and Austria app stores as fallbacks.

```ruby
app = StoreSearch::App.new '324684580', 'ios'
app.fetch_basic_info! country_code: 'DE', language_code: 'de', fallback_country_codes: %w[CH AT] # => {...}
# => {...}
app.title     # => Spotify
app.developer # => Spotify Ltd.
```

Fetch android Spotify details in Spanish.

```ruby
app = StoreSearch::App.new('com.spotify.music', 'android')
app.fetch_basic_info!(language_code: 'en') # => { ... }
app.title     # => Spotify
app.developer # => Spotify Ltd.
```
