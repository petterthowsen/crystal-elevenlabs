require "./request"
require "./voice"

module Elevenlabs
  # Request to generate speech from text
  class SpeechRequest < Request
    enum TextNormalization
      Auto
      On
      Off

      def to_s : String
        case self
        when Auto then "auto"
        when On   then "on"
        when Off  then "off"
        else "auto"
        end
      end
    end

    enum OutputFormat
      # MP3 formats with different sample rates and bitrates
      Mp3_22050_32  # 22.05kHz, 32kbps
      Mp3_44100_32  # 44.1kHz, 32kbps
      Mp3_44100_64  # 44.1kHz, 64kbps
      Mp3_44100_96  # 44.1kHz, 96kbps
      Mp3_44100_128 # 44.1kHz, 128kbps
      Mp3_44100_192 # 44.1kHz, 192kbps
      
      # PCM formats with different sample rates
      Pcm_16000  # 16kHz PCM
      Pcm_22050  # 22.05kHz PCM
      Pcm_44100  # 44.1kHz PCM
      
      # µ-law format
      Ulaw_8000  # 8kHz µ-law

      def to_s : String
        case self
        when Mp3_22050_32  then "mp3_22050_32"
        when Mp3_44100_32  then "mp3_44100_32"
        when Mp3_44100_64  then "mp3_44100_64"
        when Mp3_44100_96  then "mp3_44100_96"
        when Mp3_44100_128 then "mp3_44100_128"
        when Mp3_44100_192 then "mp3_44100_192"
        when Pcm_16000     then "pcm_16000"
        when Pcm_22050     then "pcm_22050"
        when Pcm_44100     then "pcm_44100"
        when Ulaw_8000     then "ulaw_8000"
        else "mp3_22050_32"
        end
      end
    end

    # Required parameters
    getter voice_id : String
    getter text : String

    # Optional parameters
    getter voice_settings : VoiceSettings?
    getter seed : Int32?
    getter previous_text : String?
    getter next_text : String?
    getter previous_request_ids : Array(String)?
    getter next_request_ids : Array(String)?
    getter use_pvc_as_ivc : Bool?
    getter text_normalization : TextNormalization?
    getter output_format : OutputFormat?
    getter optimize_streaming_latency : Int32?

    def initialize(
      voice_id : String | Voice,
      @text : String,
      @voice_settings : VoiceSettings? = nil,
      @seed : Int32? = nil,
      @previous_text : String? = nil,
      @next_text : String? = nil,
      @previous_request_ids : Array(String)? = nil,
      @next_request_ids : Array(String)? = nil,
      @use_pvc_as_ivc : Bool? = nil,
      @text_normalization : TextNormalization? = nil,
      @output_format : OutputFormat? = nil,
      @optimize_streaming_latency : Int32? = nil
    )
      @voice_id = voice_id.is_a?(Voice) ? voice_id.voice_id : voice_id
    end

    def method : String
      "POST"
    end

    def endpoint : String
      "/text-to-speech/#{voice_id}"
    end

    def body : String?
      payload = {
        text: @text,
        voice_settings: @voice_settings,
        seed: @seed,
        previous_text: @previous_text,
        next_text: @next_text,
        previous_request_ids: @previous_request_ids,
        next_request_ids: @next_request_ids,
        use_pvc_as_ivc: @use_pvc_as_ivc
      }
      to_json_body(payload)
    end

    def query_params : Hash(String, String)?
      filter_query_params(
        text_normalization: @text_normalization.try(&.to_s),
        output_format: @output_format.try(&.to_s),
        optimize_streaming_latency: @optimize_streaming_latency
      )
    end
  end
end