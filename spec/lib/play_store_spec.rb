require 'spec_helper'

RSpec.describe StoreSearch::PlayStore do
  let(:bot) do
    double MarketBot::Play::App,
      title: 'some title',
      description: 'Description',
      banner_icon_url: 'http://banner.icon',
      banner_image_url: 'http://banner.image',
      developer: ' Spotify Ltd. ',
      current_version: 'Varies on device',
      size: 'Varies on device',
      updated: 'May 21, 2014',
      requires_android: 'Varies on device',
      content_rating: 'Everyone',
      rating: "4.4",
      category: "Music & Audio",
      screenshot_urls: %w[http://img.com/1 http://img.com/2],
      votes: "55,000",
      installs: "5,000 - 10,000",
      cover_image_url: 'http://banner.icon',
      website_url: 'http://www.spotify.com/'
  end

  context 'when having app details' do
    before do
      expect(bot).to receive(:update)
      expect(MarketBot::Play::App).to receive(:new).and_return(bot)
    end

    subject { OpenStruct.new StoreSearch::PlayStore.fetch_app_details('id') }

    its(:title) { should be == 'some title' }
    its(:description) { should be == 'Description' }
    its(:icon_url) { should be == 'http://banner.icon' }
    its(:developer_website) { should be == 'http://www.spotify.com/' }
  end

  context "when there's no app details" do
    subject { StoreSearch::PlayStore }

    it 'should raise NoResultsError' do
      expect(bot).to receive(:update).and_raise StoreSearch::NoResultsError
      expect(MarketBot::Play::App).to receive(:new).and_return(bot)
      expect{ subject.fetch_app_details('id') }.to raise_error StoreSearch::NoResultsError
    end
  end
end
