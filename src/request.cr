module Elevenlabs
  # Base class for all API requests
  abstract class Request
    # The HTTP method to use for this request
    abstract def method : String

    # The endpoint path for this request
    abstract def endpoint : String

    # The request body, if any
    abstract def body : String?

    # Any query parameters for this request
    abstract def query_params : Hash(String, String)?

    # Convert the request to a JSON string
    protected def to_json_body(payload)
      payload.to_json
    end

    # Helper method to filter out nil values from query params
    protected def filter_query_params(**params) : Hash(String, String)?
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