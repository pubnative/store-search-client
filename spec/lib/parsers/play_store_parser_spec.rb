require 'spec_helper'

RSpec.describe StoreSearch::PlayStoreParser do
  let(:bot) do
    OpenStruct.new({
      title: 'some title',
      description: '<html> <h1>&bdquo;&#9733; some<br>more <br/>description<p>and</p> other<br />stuff &#9733;&ldquo;</h1> hidden<div style="display: none;">text </html>',
      developer: ' Spotify Ltd. ',
      current_version: 'Varies on device',
      size: 'Varies on device',
      updated: 'May 21, 2014',
      requires_android: '1.1',
      content_rating: 'Everyone',
      rating: "4.4",
      category: "Music & Audio",
      screenshot_urls: %w[http://img.com/1 http://img.com/2],
      votes: "1500",
      installs: "10,000 - 20,000",
      website_url: 'https://www.spotify.com/',
      cover_image_url: 'http://banner.icon'
    })
  end

  let(:results_hash) do
    {
      title: 'some title',
      description: "„★ some\nmore \ndescription\n and  other\nstuff ★“  hidden",
      publisher: 'Spotify Ltd.',
      developer: 'Spotify Ltd.',
      version: 'Varies on device',
      memory: 'Varies on device',
      release_date: Time.parse("2014-05-21 00:00:00"),
      min_os_version: '1.1',
      age_rating: 'Everyone',
      rating: "4.4",
      categories: ["Music & Audio"],
      icon_url: 'http://banner.icon',
      screenshot_urls: %w[http://img.com/1 http://img.com/2],
      platforms: %w[Android],
      supported_devices: [],
      total_ratings: "1500",
      installs: "10,000 - 20,000",
      developer_website: 'https://www.spotify.com/'
    }
  end

  subject { StoreSearch::PlayStoreParser.new bot }

  its(:title) { should be == 'some title' }
  its(:description) { should be == "„★ some\nmore \ndescription\n and  other\nstuff ★“  hidden" }
  its(:publisher) { should be == "Spotify Ltd." }
  its(:developer) { should be == "Spotify Ltd." }
  its(:version) { should be == "Varies on device" }
  its(:memory) { should be == "Varies on device" }
  its(:release_date) { should be == Time.parse("2014-05-21 00:00:00") }
  its(:min_os_version) { should be == "1.1" }
  its(:age_rating) { should be == "Everyone" }
  its(:rating) { should be == "4.4" }
  its(:categories) { should match_array(["Music & Audio"]) }
  its(:screenshot_urls) { should be == %w[http://img.com/1 http://img.com/2] }
  its(:platforms) { should be == %w[Android] }
  its(:supported_devices) { should be == [] }
  its(:total_ratings) { should be == "1500" }
  its(:installs) { should be == "10,000 - 20,000" }
  its(:developer_website) { should be == 'https://www.spotify.com/' }
  its(:icon_url) { should be == 'http://banner.icon' }

  its(:to_hash) { should be == results_hash }

  describe '.parse' do
    subject { StoreSearch::PlayStoreParser.parse(bot) }
    it { should be == results_hash }
  end

  describe '#min_os_version' do
    def parse_min_os_version(version)
      StoreSearch::PlayStoreParser.new(OpenStruct.new(requires_android: version)).min_os_version
    end

    context 'when requires_android is nil' do
      it 'returns nil' do
        expect(parse_min_os_version(nil)).to be(nil)
      end
    end

    context 'when requires_android has a valid format' do
      it 'converts it to version string' do
        expect(parse_min_os_version('1')).to eq('1')
        expect(parse_min_os_version('1.')).to eq('1')
        expect(parse_min_os_version('1.2')).to eq('1.2')
        expect(parse_min_os_version('1.2.3')).to eq('1.2.3')
        expect(parse_min_os_version('12.34.56')).to eq('12.34.56')
        expect(parse_min_os_version('1.2a')).to eq('1.2')
        expect(parse_min_os_version('1.2 and up')).to eq('1.2')
      end
    end

    context 'when requires_android has invalid format' do
      it 'returns nil' do
        expect(parse_min_os_version('.1')).to be(nil)
        expect(parse_min_os_version('a1.2')).to be(nil)
        expect(parse_min_os_version('Varies with device')).to be(nil)
      end
    end
  end
end
