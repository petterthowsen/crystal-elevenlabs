module Elevenlabs
    
    # Voice API returns the following:
    # {
    #    "voice_id": "21m00Tcm4TlvDq8ikWAM",
    #    "name": "Rachel",
    #    "category": "premade",
    #    "fine_tuning": {
    #      "is_allowed_to_fine_tune": false,
    #      "verification_failures": [],
    #      "verification_attempts_count": 0,
    #      "manual_verification_requested": false,
    #      "finetuning_state": "not_started"
    #    },
    #    "labels": {
    #      "accent": "american",
    #      "description": "calm",
    #      "age": "young",
    #      "gender": "female",
    #      "use_case": "narration"
    #    },
    #    "preview_url": "https://storage.googleapis.com/eleven-public-prod/premade/voices/21m00Tcm4TlvDq8ikWAM/df6788f9-5c96-470d-8312-aab3b3d8f50a.mp3",
    #    "available_for_tiers": [],
    #    "high_quality_base_model_ids": [],
    #    "voice_verification": {
    #      "requires_verification": false,
    #      "is_verified": false,
    #      "verification_failures": [],
    #      "verification_attempts_count": 0
    #    }
    #  }


    # Represents the fine-tuning status of a voice
    struct FineTuning
        include JSON::Serializable

        enum State
            NotStarted
            Queued
            FineTuning
            FineTuned
            Failed
            Delayed
        end

        @[JSON::Field(key: "is_allowed_to_fine_tune")]
        getter is_allowed_to_fine_tune : Bool

        @[JSON::Field(key: "verification_failures")]
        getter verification_failures : Array(String)

        @[JSON::Field(key: "verification_attempts_count")]
        getter verification_attempts_count : Int32

        @[JSON::Field(key: "manual_verification_requested")]
        getter manual_verification_requested : Bool

        @[JSON::Field(key: "finetuning_state")]
        getter finetuning_state : FineTuning::State?
    end

    # Represents the voice verification status
    struct VoiceVerification
        include JSON::Serializable

        @[JSON::Field(key: "requires_verification")]
        getter requires_verification : Bool

        @[JSON::Field(key: "is_verified")]
        getter is_verified : Bool

        @[JSON::Field(key: "verification_failures")]
        getter verification_failures : Array(String)

        @[JSON::Field(key: "verification_attempts_count")]
        getter verification_attempts_count : Int32
    end

    # Represents a voice in the ElevenLabs API
    struct Voice
        include JSON::Serializable

        enum Category
            Generated
            Cloned
            Premade
            Professional
            Famous
            HighQuality
        end

        enum Safety
            None
            Ban
            Captcha
            CatchaAndModeration
            EnterpriseBan
            EnterpriseCaptcha
        end

        @[JSON::Field(key: "voice_id")]
        getter voice_id : String

        getter name : String

        getter category : Category?

        @[JSON::Field(key: "fine_tuning")]
        getter fine_tuning : FineTuning?

        getter labels : Hash(String, String)?

        @[JSON::Field(key: "preview_url")]
        getter preview_url : String?

        @[JSON::Field(key: "available_for_tiers")]
        getter available_for_tiers : Array(String)?

        @[JSON::Field(key: "settings")]
        getter settings : VoiceSettings?

        @[JSON::Field(key: "high_quality_base_model_ids")]
        getter high_quality_base_model_ids : Array(String)?

        getter safety_control : Voice::Safety?

        @[JSON::Field(key: "voice_verification")]
        getter voice_verification : VoiceVerification?

        getter permission_on_resource : String?

        getter is_owner : Bool?

        getter is_legacy : Bool? = false

        getter is_mixed : Bool? = false

        getter created_at_unix : Int64?

        @[JSON::Field(key: "sharing")]
        getter sharing : VoiceSharing?

        @[JSON::Field(key: "description")]
        getter description : String?
    end

    # Represents voice settings
    struct VoiceSettings
        include JSON::Serializable

        getter stability : Float32
        getter similarity_boost : Float32
        getter style : Float32? = 0.0
        getter use_speaker_boost : Bool? = true
        getter style_exaggeration : Float32? = 0.0
    end

    # Represents voice sharing settings
    struct VoiceSharing
        include JSON::Serializable

        getter status : String?
        getter history_item_sample_id : String?
        getter original_voice_id : String?
        getter public_owner_id : String?
        getter liked_by_count : Int32?
        getter cloned_by_count : Int32?
        getter whitelisted_emails : Array(String)?
        getter name : String?
        getter labels : Hash(String, String)?
        getter description : String?
    end
end