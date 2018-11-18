require 'byebug'

RSpec.describe Google::Geolocation do
  it 'has a version number' do
    expect(Google::Geolocation::VERSION).not_to be nil
  end

  it 'returns objectified response' do
    Google::Geolocation.configure { |c| c.api_key = 'test' }
    Google::Geolocation.lookup('hoge')
  end
end
