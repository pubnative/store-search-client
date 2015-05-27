require 'spec_helper'

describe StoreSearch::App do

  describe '#valid?' do
    context 'when attributes are ok' do
      subject { StoreSearch::App.new 'com.android.spotify', 'android' }
      it { should be_valid }
    end

    context 'when attributes are blank' do
      subject { StoreSearch::App.new '', '' }
      it { should_not be_valid }
    end

    context 'when attributes are nils' do
      subject { StoreSearch::App.new nil, nil }
      it { should_not be_valid }
    end

    context 'when platform_id is not supported' do
      subject { StoreSearch::App.new '', 'windows_phone' }
      it { should_not be_valid }
    end
  end

  describe '#fetch_basic_info!' do
    subject { StoreSearch::App.new 'com.android.spotify', 'android' }

    before do
      StoreSearch::Request.stub_chain(:new, :get).and_return(response)
    end

    context 'when app was found' do
      let(:results_hash) do
        {
          :title => "Spotify",
          :description => "Music player",
          :publisher => "Spotify Ltd.",
          :developer => "Spotify Ltd.",
          :version => "1.0.1",
          :memory => "28.5 MB",
          :release_date => "2014-05-14 15:54:22",
          :min_os_version => "2.2+",
          :age_rating => "Everyone",
          :rating => "4.4",
          :categories => ["Music & Audio"],
          :icon_url => "http://icon.url",
          :screenshot_urls => ["http://screen.com/1","http://screen.com/2","http://screen.com/3"]
        }
      end

      let(:response) { results_hash }
      its(:fetch_basic_info!) { should be == results_hash }

      context 'app details' do
        before { subject.fetch_basic_info! }
        its(:title) { should be == 'Spotify' }
        its(:description) { should be == 'Music player' }
        its(:icon_url) { should be == 'http://icon.url' }
        its(:publisher) { should be == "Spotify Ltd." }
        its(:developer) { should be == "Spotify Ltd." }
        its(:version) { should be == "1.0.1" }
        its(:memory) { should be == "28.5 MB" }
        its(:release_date) { should be == "2014-05-14 15:54:22" }
        its(:min_os_version) { should be == "2.2+" }
        its(:age_rating) { should be == "Everyone" }
        its(:rating) { should be == "4.4" }
        its(:categories) { should match_array(["Music & Audio"]) }
        its(:screenshot_urls) { should be == 1.upto(3).map { |i|"http://screen.com/#{i}"} }
      end
    end

    context 'when game was not found' do
      let(:response) { {} }

      it 'should raise and error' do
        expect { subject.fetch_basic_info! }.to raise_error(StoreSearch::RequestError)
      end
    end

    context 'when there were issues along the way' do
      let(:response) { {} }
      subject { StoreSearch::App.new 123, 'ios' }

      it 'does raise an request exception' do
        expect { subject.fetch_basic_info! }.to raise_error(StoreSearch::RequestError)
      end
    end

    context 'when there were validation errors' do
      let(:response) { 'no_response' }
      subject { StoreSearch::App.new nil, 'windows_phone' }

      it 'does raise an attributes error' do
        expect { subject.fetch_basic_info! }.to raise_error(StoreSearch::InvalidAttributesError)
        expect(subject.errors).to be == ['missing app id', 'unknown platform_id']
      end
    end
  end
end
