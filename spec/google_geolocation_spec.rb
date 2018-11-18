require 'faraday'

RSpec.describe Google::Geolocation do
  it 'has a version number' do
    expect(Google::Geolocation::VERSION).not_to be nil
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
    Google::Geolocation.configure do |c|
      c.api_key = 'test_apikey'
      c.client = mocked_faraday
    end
  end

  it 'returns response looked up with address' do
    Google::Geolocation.lookup('unique test address')
  end

  it 'returns response looked up with latitude and longitude' do
    latlng = Google::Geolocation::LatLng.new(0.123, 0.123)
    Google::Geolocation.lookup(latlng)
  end
end
