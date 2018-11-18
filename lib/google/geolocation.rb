module Google
  module Geolocation
    class Configuration
      attr_accessor :api_key, :client

      BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json"

      def initialize(client)
        @client = Faraday.new(url: BASE_URL)
      end
    end

    class << self
      def config
        @config ||= Configuration.new
      end

      def configure(&block)
        yield(config) if block_given?
      end
    end

    LatLng = Struct.new(:latitude, :longitude)

    # TODO needs better exception handling for Faraday using a custom middleware
    def lookup(arg)
      request_url =
        case arg
        when String
          "?address=#{arg}&key=#{self.config.api_key}"
        when LatLng
          "?latlng=#{arg.latitude},#{arg.longitude}&key=#{self.config.api_key}"
        else
          raise ArgumentError, "lookup method only accepts either String or LatLng"
        end

      parse_response self.config.client.get(request_url)
    end

    private

    class Result
      attr_reader :address_components, :formatted_address, :geometry, :place_id, :types

      def initialize(address_components, formatted_address, geometry, place_id, types)
        @address_components = address_components
        @formatted_address = formatted_address
        @geometry = geometry
        @place_id = place_id
        @types = types
      end
    end

    class Address
      attr_reader :long_name, :short_name, :types

      def initialize(long_name, short_name, types)
        @long_name = long_name
        @short_name = short_name
        @types = types
      end
    end

    class Geometry
      attr_reader :bounds, :location, :location_type, :viewport

      def initialize(bounds, location, location_type, viewport)
        @bounds = bounds.map { |k, v| [k.to_sym, LatLng.new(v["lat"], v["lng"])] }.to_h
        @location = LatLng.new(location["lat"], location["lng"])
        @location_type = location_type
        @viewport = viewport.map { |k, v| [k.to_sym, LatLng.new(v["lat"], v["lng"])] }.to_h
      end
    end

    def parse_response(response)
      _results = JSON.parse(response.body)
      _results = _results["results"]
      _results.map do |r|
        address_components = r["address_components"].map { |a| Address.new(a["long_name"], a["short_name"], a["types"]) }
        g = r["geometry"]
        geometry = Geometry.new(g["bounds"], g["location"], g["location_type"], g["viewport"])
        Result.new(address_components, r["formatted_address"], geometry, r["place_id"], r["types"])
      end
    end
  end
end
