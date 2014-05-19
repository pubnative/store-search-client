require 'spec_helper'

describe StoreSearch::Response do
  describe '.new' do
    subject { StoreSearch::Response.new http_response_body }

    context 'when correct http response' do
      let(:http_response_body) do
        double 'response',
          read: %q|{"success":true,"app":{"title":"Spotify","description":"Music player","icon_url":"http://icon.url"}}|,
          status: ['200', 'success']
      end

      its(:raw) { should be == http_response_body.read }
      its(:success) { should be_true }
      its(:body) do
        should be == {
          'success' => true,
          'app' => {'title' => 'Spotify', 'description' => 'Music player', 'icon_url' => 'http://icon.url'}
        }
      end
      its(:error) { should be_nil }
    end

    context 'when invalid http response' do
      let(:http_response_body) { double 'response', read: 'Sorry, something went wrong.', status: %w[500 error] }
      its(:raw) { should be == http_response_body.read }
      its(:success) { should be_false }
      its(:body) { should be_nil }
      its(:error) { should be_an(JSON::ParserError) }
    end
  end
end
