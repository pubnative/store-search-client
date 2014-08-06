require 'spec_helper'

describe StoreSearch::Request do
  describe '.new' do
    subject { StoreSearch::Request.new 'apps/ios', id: 12341234, country_codes: %w[DE FR] }

    its(:path) { should be == 'apps/ios' }
    its(:params) { should be == {id: 12341234, country_codes: %w[DE FR]} }

    context 'when generated uri' do
      subject { super().uri }
      it { should be_an Addressable::URI }
      its(:to_s) { should be == 'http://storesearch.applift.com/api/v1/apps/ios?id=12341234&country_codes[]=DE&country_codes[]=FR' }
    end
  end

  describe '#get' do
    subject { StoreSearch::Request.new('apps/android', id: 'com.spotify.mobile.android.ui') }

    before do
      StoreSearch.configure do |c|
        c.username, c.password = %w[user pass]
      end
    end

    context 'when success' do
      it 'should make API call' do
        request = stub_request(:get, "http://user:pass@storesearch.applift.com/api/v1/apps/android?id=com.spotify.mobile.android.ui")
          .to_return(status: 200, body: File.read('spec/fixtures/spotify_android.json'))

        expect(subject.get).to be_a StoreSearch::Response

        request.should have_been_requested
      end
    end

    context "when 4xx status code" do
      it "doesn't raise the OpenURI::HTTPError" do
        request = stub_request(:get, "http://user:pass@storesearch.applift.com/api/v1/apps/android?id=com.spotify.mobile.android.ui")
          .to_return(status: 404, body: {success: false, error: "No app"}.to_json)

        expect do
          expect(subject.get).to be_a StoreSearch::Response
        end.to raise_error

        request.should have_been_requested
      end
    end

    context "when 5xx status code" do
      it "doesn't raise the OpenURI::HTTPError" do
        request = stub_request(:get, "http://user:pass@storesearch.applift.com/api/v1/apps/android?id=com.spotify.mobile.android.ui")
          .to_return(status: 500, body: "Something went wrong.")

        expect do
          expect(subject.get).to be_a StoreSearch::Response
        end.to raise_error

        request.should have_been_requested
      end
    end
  end
end
