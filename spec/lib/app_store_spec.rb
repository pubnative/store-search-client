require 'spec_helper'

RSpec.describe StoreSearch::AppStore do
  def stub_api_request!(response_body, country_code = 'US', language_code = 'en')
    stub_request(:get, "https://itunes.apple.com/lookup?id=1&country=#{ country_code }&lang=#{ language_code }")
      .to_return body: response_body
  end

  def make_request!(country_code = 'US', language_code = 'en')
    subject.lookup! id: '1', country: country_code, lang: language_code
  end

  let(:correct) { %Q!{"resultCount":1,"results": [{"trackName":"This is Halloween ^^","description":"some desc\\n\\n","artworkUrl100":"http://url.com"}]}! }
  let(:empty)   { %Q!{"resultCount":0,"results": []}! }
  let(:failed)  { %Q!{"error":"Shit Happens"}! }

  before :each do
    WebMock.disable_net_connect! allow_localhost: true
  end

  describe '#fetch_app_details' do
    context 'when single country' do
      subject { OpenStruct.new StoreSearch::AppStore.fetch_app_details('1', country_code: 'US', language_code: 'en') }

      before(:each) { stub_api_request! correct }

      its(:title) { should be == 'This is Halloween ^^' }
      its(:description) { should be == "some desc\n\n" }
      its(:icon_url) { should be == 'http://url.com' }
    end

    context 'when multiple countries' do
      subject { OpenStruct.new StoreSearch::AppStore.fetch_app_details('1', country_code: 'FR', language_code: 'en', fallback_country_codes: %w[DE PL]) }

      before :each do
        stub_api_request! empty, 'FR'
        stub_api_request! empty, 'DE'
        stub_api_request! correct, 'PL'
      end

      its(:title) { should be == 'This is Halloween ^^' }
      its(:description) { should be == "some desc\n\n" }
      its(:icon_url) { should be == 'http://url.com' }
    end
  end

  describe '.new' do
    context 'when country_code is not specified' do
      its(:country_codes) { should be == [] }
    end

    context 'when fallback_country_codes are specified' do
      subject { StoreSearch::AppStore.new(fallback_country_codes: %w[DE FR US]) }
      its(:country_codes) { should be == %w[DE FR US] }
    end

    context 'when country_code and fallback_country_codes are specified' do
      subject { StoreSearch::AppStore.new(country_code: 'IT', fallback_country_codes: %w[DE FR US]) }
      its(:country_codes) { should be == %w[IT DE FR US] }
    end
  end

  describe '.find' do
    subject { StoreSearch::AppStore.new country_code: 'US', language_code: 'en', fallback_country_codes: %w[DE FR] }

    context 'when could find app within countries' do
      it 'should return first found app' do
        expect(subject).to receive(:lookup!).with(id: '1', country: 'US', lang: 'en').and_raise(StoreSearch::NoResultsError)
        expect(subject).to receive(:lookup!).with(id: '1', country: 'DE', lang: 'en').and_return({"trackName" => "Correct"})
        expect(subject.find('1')).to be == {"trackName" => "Correct"}
      end

      it 'should not raise NoResultsError' do
        expect(subject).to receive(:lookup!).with(id: '1', country: 'US', lang: 'en').and_raise(StoreSearch::NoResultsError)
        expect(subject).to receive(:lookup!).with(id: '1', country: 'DE', lang: 'en').and_return({"trackName" => "Correct"})
        expect { subject.find('1') }.to_not raise_error
      end

      it 'should reraise other exceptions' do
        expect(subject).to receive(:lookup!).with(id: '1', country: 'US', lang: 'en').and_raise(StoreSearch::MalformedResponseError)
        expect(subject).to_not receive(:lookup!).with(id: '1', country: 'DE', lang: 'en')
        expect { subject.find('1') }.to raise_error(StoreSearch::MalformedResponseError)
      end
    end

    context 'when could not find app within countries' do
      it 'should raise NoResultsError' do
        expect(subject).to receive(:lookup!).exactly(3).times.and_raise(StoreSearch::NoResultsError)
        expect { subject.find('1') }.to raise_error(StoreSearch::NoResultsError)
      end

      it 'should reraise other exceptions' do
        expect(subject).to receive(:lookup!).twice.and_raise(StoreSearch::NoResultsError)
        expect(subject).to receive(:lookup!).with(id: '1', country: 'FR', lang: 'en').and_raise(StoreSearch::MalformedResponseError)
        expect { subject.find('1') }.to raise_error(StoreSearch::MalformedResponseError)
      end
    end
  end

  describe '.lookup!' do
    subject { StoreSearch::AppStore.new country_code: 'US' }
    before(:each) { allow(subject).to receive(:wait_before_next_try) }

    context 'when request have been successful' do
      before :each do
        stub_api_request! correct
      end

      it 'should return application hash' do
        expect( make_request! ).to be == {
          'trackName' => 'This is Halloween ^^',
          'description' =>"some desc\n\n",
          'artworkUrl100' => 'http://url.com'
        }
      end

      it 'should not raise errors' do
        expect { make_request! }.to_not raise_error
      end
    end

    context 'when request have failed' do
      it 'should raise RequestError for invalid json' do
        stub_api_request! 'Shit Happens'
        expect { make_request! }.to raise_error JSON::ParserError
      end

      it 'should raise InvalidCountryError' do
        stub_api_request! %Q!{"errorMessage": "Invalid value(s) for key(s): [country]"}!, 'all'

        expect { make_request! 'all' }.to raise_error StoreSearch::InvalidCountryError,
                                                      'Could not find app for given country, or country code is invalid: "all".'
      end

      it 'should raise RequestError' do
        stub_api_request! %Q!{"errorMessage": "Shit Happens"}!
        expect { make_request! }.to raise_error StoreSearch::RequestError,
                                                'Request have failed with given error message: "Shit Happens".'
      end
    end

    context 'when response format is invalid' do
      it 'should raise MalformedResponseError' do
        stub_api_request! failed
        expect { make_request! }.to raise_error StoreSearch::MalformedResponseError
      end
    end

    context 'when there are no results' do
      it 'should raise NoResultsError' do
        stub_api_request! empty
        expect { make_request! }.to raise_error StoreSearch::NoResultsError
      end
    end
  end
end
