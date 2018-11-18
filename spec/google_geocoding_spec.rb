require 'faraday'

RSpec.describe Google::Geocoding do
  it 'has a version number' do
    expect(Google::Geocoding::VERSION).not_to be nil
  end

  let(:mocked_faraday) do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/?address=unique+test+address&key=test_apikey') do |env|
        [ 200, {}, '{}' ] # TODO
      end

      stub.get('?latlng=0.123,0.123&key=test_apikey') do |env|
        [ 200, {}, '{}' ] # TODO
      end
    end

    Faraday.new do |builder|
      builder.adapter :test, stubs
    end
  end

  before do
    Google::Geocoding.configure do |c|
      c.api_key = 'test_apikey'
      c.client = mocked_faraday
    end
  end

  it 'returns response looked up with address' do
    Google::Geocoding.lookup('unique test address')
  end

  it 'returns response looked up with latitude and longitude' do
    latlng = Google::Geocoding::LatLng.new(0.123, 0.123)
    Google::Geocoding.lookup(latlng)
  end
end
