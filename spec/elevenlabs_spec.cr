require "./spec_helper"
require "../src/elevenlabs"

API_KEY = begin
    File.read("./spec/api_key.txt")
rescue e
    raise "Please create a file called './spec/api_key.txt' containing your OpenRouter API key"
end

VOICE_ID = "YYsSP4lxLdkPqJH0L4YV"

describe Elevenlabs do
  # TODO: Write tests

  it "can generate sounds" do
    client = Elevenlabs::Client.new(API_KEY)

    client.sound_generation "small river ambience, looping, loopable, seamless", duration: 5, prompt_influence: 0.5 do |response|
        File.write("./spec/small_river_ambience_looping.mp3", response.body_io)
    end
  end

  it "can get voices", focus: false do
    client = Elevenlabs::Client.new(API_KEY)

    voices = client.voices

    # it's an array of Voice objects
    voices.should be_a(Array(Elevenlabs::Voice))
  end

  it "can get info about voice", focus: false do
    client = Elevenlabs::Client.new(API_KEY)

    voice = client.voice VOICE_ID

    # it's a Voice object
    voice.should be_a(Elevenlabs::Voice)

    puts voice.to_pretty_json
  end

  it "can do text to speech", focus: true do
    client = Elevenlabs::Client.new(API_KEY)

    # Get audio data
    client.create_speech(
      text: "Hello, world!",
      voice: VOICE_ID,
      output_format: Elevenlabs::SpeechRequest::OutputFormat::Mp3_44100_96
    ) do |response|
      # Save to file
      output_file = "./spec/speech_hello_world.mp3"
      File.write(output_file, response.body_io)
    end
  end
end
