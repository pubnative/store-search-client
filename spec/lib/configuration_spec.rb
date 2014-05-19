require 'spec_helper'

describe StoreSearch::Configuration do
  describe '#base_uri' do
    context 'when defaults' do
      its(:base_uri) { should be == 'http://storesearch.applift.com/api/v1/' }
    end

    context 'when setup was done' do
      subject do
        StoreSearch::Configuration.new.tap do |config|
          config.protocol = 'ftps'
          config.host = '87.185.35.15:8080'
          config.api_version = 'v70'
        end
      end

      its(:base_uri) { should be == 'ftps://87.185.35.15:8080/api/v70/' }
    end
  end

end
