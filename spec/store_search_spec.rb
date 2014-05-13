require 'spec_helper'
require_relative '../lib/store_search'

describe StoreSearch do
  subject { StoreSearch }

  describe '.configuration' do
    its(:configuration) { should be_a StoreSearch::Configuration }
  end

  describe '.configure' do
    before { StoreSearch.configuration = nil }
    let(:conf) { subject.configuration }

    it 'should change configuration' do
      expect do
        subject.configure do |config|
          config.username = 'new defined user'
          config.password = 'new password'
          config.api_version = 'v70'
          config.protocol = 'ftps'
          config.host = 'api.storesearch.com'
        end
      end.to change{ subject.configuration.username }

      expect(conf.username).to be == 'new defined user'
      expect(conf.password).to be == 'new password'
      expect(conf.api_version).to be == 'v70'
      expect(conf.protocol).to be == 'ftps'
      expect(conf.host).to be == 'api.storesearch.com'
    end
  end
end
