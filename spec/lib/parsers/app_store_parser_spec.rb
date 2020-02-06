require 'spec_helper'

RSpec.describe StoreSearch::AppStoreParser do
  let(:response) do
    fixture = File.read('spec/fixtures/spotify_ios.json')

    JSON.parse(fixture)['results'][0].merge(
    {
      "trackName" => "some title",
      "description" => "some description\n\n",
      "artworkUrl512" => "http://artwork.512",
      "artworkUrl100" => "http://artwork.100",
      "artworkUrl60" => "http://artwork.60"
    })
  end

  let(:results_hash) do
    {
      title: "some title",
      description: "some description\n\n",
      publisher: "Spotify",
      developer: "Spotify Ltd.",
      version: "1.1.0",
      memory: "25.8 MB",
      release_date: Time.parse("2011-07-14T11:22:37Z"),
      min_os_version: nil,
      age_rating: "12+",
      rating: "4.5",
      categories: ["Music", "Entertainment"],
      icon_url: "http://artwork.512",
      screenshot_urls: [
        "http://a5.mzstatic.com/us/r30/Purple4/v4/71/ee/98/71ee9852-99ba-885a-ee43-8a44a7a62fe4/screen1136x1136.jpeg",
        "http://a3.mzstatic.com/us/r30/Purple/v4/34/d3/08/34d308a1-1dca-e610-1183-85e9adcda309/screen1136x1136.jpeg",
        "http://a1.mzstatic.com/us/r30/Purple/v4/c6/c7/54/c6c7543d-0344-dc52-cb90-ea378a21f266/screen1136x1136.jpeg",
        "http://a5.mzstatic.com/us/r30/Purple4/v4/cb/44/27/cb4427d1-f9a8-c97c-d003-ac0589abcb7d/screen1136x1136.jpeg",
        "http://a1.mzstatic.com/us/r30/Purple6/v4/02/98/63/02986371-e050-7ef2-3805-c35424e828d1/screen480x480.jpeg",
        "http://a3.mzstatic.com/us/r30/Purple/v4/12/92/01/12920170-e609-ffde-68bd-4966e90e2d0e/screen480x480.jpeg",
        "http://a2.mzstatic.com/us/r30/Purple4/v4/8b/52/0f/8b520f9e-df9d-58b0-f921-dd0d6188d87b/screen480x480.jpeg"
      ],
      platforms: %w[iosUniversal],
      supported_devices: %w[iPhone5s iPodTouchourthGen iPadThirdGen4G iPadFourthGen4G iPhone-3GS iPad2Wifi iPodTouchFifthGen iPadThirdGen iPhone5c iPhone5 iPad23G iPhone4 iPadMini4G iPadMini iPhone4S iPadFourthGen],
      total_ratings: 306794,
      installs: "",
      developer_website: 'http://www.spotify.com/'
    }
  end

  subject { StoreSearch::AppStoreParser.new response }

  its(:title) { should be == 'some title' }
  its(:description) { should be == "some description\n\n" }
  its(:publisher) { should be == "Spotify" }
  its(:developer) { should be == "Spotify Ltd." }
  its(:version) { should be == "1.1.0" }
  its(:memory) { should be == "25.8 MB" }
  its(:release_date) { should be == Time.parse("2011-07-14T11:22:37Z") }
  its(:min_os_version) { should be_nil }
  its(:age_rating) { should be == "12+" }
  its(:rating) { should be == "4.5" }
  its(:categories) { should match_array(%w[Music Entertainment]) }
  its(:screenshot_urls) { should match_array(results_hash[:screenshot_urls]) }
  its(:platforms) { should match_array(%w[iosUniversal]) }
  its(:supported_devices) { should match_array(%w[iPhone5s iPodTouchourthGen iPadThirdGen4G iPadFourthGen4G iPhone-3GS iPad2Wifi iPodTouchFifthGen iPadThirdGen iPhone5c iPhone5 iPad23G iPhone4 iPadMini4G iPadMini iPhone4S iPadFourthGen]) }
  its(:total_ratings) { should be == 306794 }
  its(:installs) { should be == "" }
  its(:developer_website) { should be == 'http://www.spotify.com/' }

  its(:to_hash) { should be == results_hash }

  describe '.parse' do
    subject { StoreSearch::AppStoreParser.parse(response) }
    it { should be == results_hash }
  end
end
