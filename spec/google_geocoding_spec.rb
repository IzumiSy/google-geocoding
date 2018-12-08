require 'faraday'

RSpec.shared_examples 'Results object' do
  it 'must have flawless Result objects' do
    expect(results.first.address_components).to_not eq nil
    expect(results.first.formatted_address).to_not eq nil

    expect(results.first.geometry).to_not eq nil
    expect(results.first.geometry.location).to_not eq nil
    expect(results.first.geometry.location.latitude).to eq 35.6894875
    expect(results.first.geometry.location.longitude).to eq 139.6917064

    expect(results.first.place_id).to eq 'ChIJ51cu8IcbXWARiRtXIothAS4'
    expect(results.first.types).to include 'administrative_area_level_1', 'locality', 'political'
  end
end

RSpec.describe Google::Geocoding do
  it 'has a version number' do
    expect(Google::Geocoding::VERSION).not_to be nil
  end

  let(:mocked_json_result) do
<<EOS
    {
       "results" : [
          {
             "address_components" : [
                {
                   "long_name" : "Tokyo",
                   "short_name" : "Tokyo",
                   "types" : [ "administrative_area_level_1", "locality", "political" ]
                },
                {
                   "long_name" : "Japan",
                   "short_name" : "JP",
                   "types" : [ "country", "political" ]
                }
             ],
             "formatted_address" : "Tokyo, Japan",
             "geometry" : {
                "bounds" : {
                   "northeast" : {
                      "lat" : 35.8986468,
                      "lng" : 153.9876115
                   },
                   "southwest" : {
                      "lat" : 24.2242626,
                      "lng" : 138.942758
                   }
                },
                "location" : {
                   "lat" : 35.6894875,
                   "lng" : 139.6917064
                },
                "location_type" : "APPROXIMATE",
                "viewport" : {
                   "northeast" : {
                      "lat" : 35.817813,
                      "lng" : 139.910202
                   },
                   "southwest" : {
                      "lat" : 35.528873,
                      "lng" : 139.510574
                   }
                }
             },
             "place_id" : "ChIJ51cu8IcbXWARiRtXIothAS4",
             "types" : [ "administrative_area_level_1", "locality", "political" ]
          }
       ],
       "status" : "OK"
    }
EOS
  end

  let(:mocked_faraday) do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/?address=unique+test+address&key=test_apikey') do |env|
        [ 200, {}, mocked_json_result ]
      end

      stub.get('?latlng=0.123,0.123&key=test_apikey') do |env|
        [ 200, {}, mocked_json_result ]
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

  context 'response looked up with address' do
    it_behaves_like 'Results object' do
      let(:results) do
        Google::Geocoding.lookup('unique test address')
      end
    end
  end

  context 'response looked up with latitude and longitude' do
    it_behaves_like 'Results object' do
      let(:results) do
        latlng = Google::Geocoding::LatLng.new(0.123, 0.123)
        Google::Geocoding.lookup(latlng)
      end
    end
  end
end
