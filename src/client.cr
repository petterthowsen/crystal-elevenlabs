require "json"
require "http/client"
require "uri"
require "./voice"
require "./speech_request"

module Elevenlabs
  # Base error class for all ElevenLabs errors
  class Error < Exception; end

  # Raised when the API returns a 4xx error
  class ClientError < Error
    getter response : HTTP::Client::Response

    def initialize(@response)
      super("HTTP #{@response.status_code}: #{@response.body}")
    end
  end

  # Raised when the API returns a 5xx error
  class ServerError < Error
    getter response : HTTP::Client::Response

    def initialize(@response)
      super("HTTP #{@response.status_code}: #{@response.body}")
    end
  end

  # Raised when the API returns an unexpected content type
  class ContentTypeError < Error; end

  # Raised when the API key is invalid or missing
  class AuthenticationError < ClientError; end

  # Represents the response from the /voices endpoint
  private struct VoicesResponse
    include JSON::Serializable

    getter voices : Array(Voice)
  end

  class Client
    BASE_URL = "https://api.elevenlabs.io/v1"

    property api_key : String

    def initialize(api_key : String)
      @api_key = api_key
    end

    def sound_generation(text : String, duration : Int32 = 0, prompt_influence : Float32 = 0.3, &block)
      payload = {
        "text" => text,
        "prompt_influence" => prompt_influence,
        "duration_seconds" => duration
      }
      request "POST", "/sound-generation", payload.to_json, do |response|
        handle_response(response) do
          if response.content_type != "audio/mpeg"
            raise ContentTypeError.new("Sound Generation response has unexpected content type: #{response.content_type}")
          end
          yield response
        end
      end
    end

    # Get all available voices
    # Returns an Array of Voice objects.
    #
    # Parameters:
    # - show_legacy : If true, includes legacy premade voices in the response
    def voices(show_legacy : Bool? = nil) : Array(Voice)
      query_params = filter_query_params(
        show_legacy: show_legacy
      )
      
      response = request("GET", "/voices", query_params: query_params)
      handle_response(response) do
        if response.content_type != "application/json"
          raise ContentTypeError.new("Voices response has unexpected content type: #{response.content_type}")
        end
        VoicesResponse.from_json(response.body).voices
      end
    end

    # Get a specific voice
    #
    # Parameters:
    # - id : The ID of the voice to retrieve
    # - with_settings : If true, includes the voice settings in the response
    def voice(id : String, with_settings : Bool? = nil) : Voice
      query_params = filter_query_params(
        with_settings: with_settings
      )
      
      response = request("GET", "/voices/#{id}", query_params: query_params)
      handle_response(response) do
        if response.content_type != "application/json"
          raise ContentTypeError.new("Voice response has unexpected content type: #{response.content_type}")
        end
        Voice.from_json(response.body)
      end
    end

    # Execute a request
    def execute(request : Request)
      response = self.request(request.method, request.endpoint, request.body, request.query_params)
      handle_response(response)
    end

    def create_speech(text : String, voice : String | Voice, output_format : SpeechRequest::OutputFormat? = nil)
      request = SpeechRequest.new(
        voice_id: voice,
        text: text,
        output_format: output_format
      )
      create_speech(request) { |response| yield response }
    end

    # Create speech from a pre-configured request
    def create_speech(request : SpeechRequest)
      request(request.method, request.endpoint, request.body, request.query_params) do |response|
        handle_response(response) do
          if response.content_type != "audio/mpeg" && response.content_type != "audio/wav"
            raise ContentTypeError.new("Speech response has unexpected content type: #{response.content_type}")
          end
          yield response
        end
      end
    end

    # Get a specific endpoint
    #
    # This is a low-level method that is available for edge cases.
    def get(endpoint : String) : HTTP::Client::Response
      request("GET", endpoint)
    end

    # Post to a specific endpoint
    #
    # This is a low-level method that is available for edge cases.
    def post(endpoint : String, body : String?) : HTTP::Client::Response
      request("POST", endpoint, body)
    end

    private def handle_response(response : HTTP::Client::Response)
      case response.status_code
      when 200..299
        yield
      when 401, 403
        raise AuthenticationError.new(response)
      when 400..499
        raise ClientError.new(response)
      when 500..599
        raise ServerError.new(response)
      else
        raise Error.new("Unexpected response status: #{response.status_code}")
      end
    end

    # Send a request to the ElevenLabs API on a given http verb + endpoint with an optional body and query parameters
    private def request(method : String, endpoint : String, body : String? = nil, query_params : Hash(String, String)? = nil)
      method = method.upcase

      # build the headers
      headers = HTTP::Headers.new
      headers["xi-api-key"] = @api_key
      headers["Content-Type"] = "application/json"
      
      # build the URL with query parameters
      uri = URI.parse("#{BASE_URL}#{endpoint}")
      if query_params && !query_params.empty?
        uri.query = URI::Params.encode(query_params)
      end

      HTTP::Client.new(uri) do |client|
        client.exec(method, uri.request_target, headers: headers, body: body)
      end
    end

    # Overload for block-based requests
    private def request(method : String, endpoint : String, body : String? = nil, query_params : Hash(String, String)? = nil, &block : HTTP::Client::Response -> _)
      method = method.upcase

      # build the headers
      headers = HTTP::Headers.new
      headers["xi-api-key"] = @api_key
      headers["Content-Type"] = "application/json"
      
      # build the URL with query parameters
      uri = URI.parse("#{BASE_URL}#{endpoint}")
      if query_params && !query_params.empty?
        uri.query = URI::Params.encode(query_params)
      end

      HTTP::Client.exec(method, uri, headers: headers, body: body) do |response|
        yield response
      end
    end

    # Helper method to filter out nil values from query params
    private def filter_query_params(**params) : Hash(String, String)?
      # Convert NamedTuple to Hash and filter out nil values
      filtered = params.to_h.reject { |_, v| v.nil? }
      # Convert remaining values to strings and keys to strings
      string_hash = {} of String => String
      filtered.each do |k, v|
        string_hash[k.to_s] = v.to_s
      end
      string_hash.empty? ? nil : string_hash
    end
  end
end