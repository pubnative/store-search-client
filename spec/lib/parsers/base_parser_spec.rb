require 'spec_helper'

RSpec.describe StoreSearch::BaseParser do
  subject { StoreSearch::BaseParser.new({}) }
  let(:empty_fields_hash) do
    {
      title: nil,
      description: nil,
      publisher: nil,
      developer: nil,
      version: nil,
      memory: nil,
      release_date: nil,
      min_os_version: nil,
      age_rating: nil,
      rating: nil,
      categories: nil,
      icon_url: nil,
      screenshot_urls: nil,
      platforms: nil,
      supported_devices: nil,
      total_ratings: nil,
      installs: nil,
      developer_website: nil
    }
  end

  StoreSearch::BaseParser::APPLICATION_FIELDS.each do |field|
    its(field) { should be_nil }
  end

  its(:to_hash) { should be == empty_fields_hash }

  describe '.parse' do
    subject { StoreSearch::BaseParser.parse({}) }
    it { should be == empty_fields_hash }
  end
end
