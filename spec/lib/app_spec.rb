require 'spec_helper'

describe StoreSearch::App do
  class HTTPResponse < Struct.new(:status, :read)
    def self.build(status, body)
      new [status.to_s, ''], body
    end
  end

  def build_response(status, body)
    StoreSearch::Response.new HTTPResponse.build(status, body)
  end

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
      let(:response) { build_response 200, %q|{"success":true,"app":{"title":"Spotify","description":"Music player","icon_url":"http://icon.url"}}| }

      its(:fetch_basic_info!) { should be == {'title' => 'Spotify', 'description' => 'Music player', 'icon_url' => 'http://icon.url'}
 }
      context 'app details' do
        before { subject.fetch_basic_info! }
        its(:title) { should be == 'Spotify' }
        its(:description) { should be == 'Music player' }
        its(:icon_url) { should be == 'http://icon.url' }
      end
    end

    context 'when game was not found' do
      let(:response) { build_response 404, '{}' }
      its(:fetch_basic_info!) { should be_nil }
    end

    context 'when there were issues along the way' do
      let(:response) { build_response 500, 'Sorry, something went wrong.' }

      it 'does raise an request exception' do
        expect { subject.fetch_basic_info! }.to raise_error(StoreSearch::App::RequestError)
      end
    end

    context 'when there were validation errors' do
      let(:response) { 'no_response' }
      subject { StoreSearch::App.new nil, 'windows_phone' }

      it 'does raise an attributes error' do
        expect { subject.fetch_basic_info! }.to raise_error(StoreSearch::App::InvalidAttributesError)
        expect(subject.errors).to be == ['missing app id', 'unknown platform_id']
      end
    end
  end
end
