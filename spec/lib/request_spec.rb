require 'spec_helper'

describe StoreSearch::Request do
  describe '.new' do
    subject { StoreSearch::Request.new 'ios', id: 12341234, country_codes: %w[DE FR] }

    its(:platform_id) { should be == :ios }
    its(:params) { should be == {id: 12341234, country_codes: %w[DE FR]} }
  end

  describe '#get' do
    it 'should call AppStore when ios' do
      expect(StoreSearch::AppStore).to receive(:fetch_app_details)
      StoreSearch::Request.new('ios', id: 'com.spotify.mobile.android.ui').get
    end

    it 'should call PlayStore when android' do
      expect(StoreSearch::PlayStore).to receive(:fetch_app_details)
      StoreSearch::Request.new('android', id: 'com.spotify.mobile.android.ui').get
    end
  end
end
