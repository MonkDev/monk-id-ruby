require 'base64'
require 'json'
require 'openssl'
require 'yaml'

# Global Monk namespace.
module Monk
  # Integrate Monk ID on the server-side by accessing payloads from the
  # client-side JavaScript.
  #
  # @author Monk Development, Inc.
  module Id
    # Expected path of config file in Rails and Sinatra relative to the app's
    # root directory.
    CONFIG_FILE = 'config/monk_id.yml'.freeze

    # Name of the cookie that (optionally) stores the payload.
    COOKIE_NAME = '_monkIdPayload'.freeze

    class << self
      # Load a YAML config file for a specific environment. Rails and Sinatra
      # apps don't need to call this method if the config file is stored at
      # {CONFIG_FILE}, as it's loaded automatically.
      #
      # @param  path [String] Path of YAML config file to load. Leave `nil` to
      #         read from environment's `MONK_ID_CONFIG` value.
      # @param  environment [String] Environment section to use. Leave `nil` to
      #         read from environment's `MONK_ID_ENV` value. Defaults to
      #         `development`.
      # @raise  [StandardError] If the file doesn't exist or can't be read.
      # @return [Hash<String>] Loaded config values.
      def load_config(path = nil, environment = nil)
        if defined? Rails
          path ||= File.join(Rails.root, CONFIG_FILE)
          environment ||= Rails.env
        elsif defined? Sinatra
          path ||= File.join(Sinatra::Application.settings.root, CONFIG_FILE)
          environment ||= Sinatra::Application.settings.environment.to_s
        else
          path ||= ENV['MONK_ID_CONFIG']
          environment ||= ENV['MONK_ID_ENV'] || 'development'
        end

        config = YAML.load_file(path)[environment]

        verify_config(config)

        @@config = config
      end

      # Get a config value. Attempts to load the config if it hasn't already
      # been loaded.
      #
      # @param  key [String] Name of config value.
      # @raise  [StandardError] If the config can't be loaded.
      # @return [*] Config value.
      def config(key)
        load_config unless @@config

        @@config[key]
      end

      # Load a payload from the client-side.
      #
      # @param  encoded_payload [String, #[]] Encoded payload or Hash-like
      #         cookies object to automatically load the payload from.
      # @return [Hash<Symbol>] Decoded and verified payload. Empty if there's no
      #         payload or it fails verification.
      def load_payload(encoded_payload = nil)
        if encoded_payload.is_a? String
          payload = encoded_payload
        elsif encoded_payload.respond_to? :[]
          payload = encoded_payload[COOKIE_NAME]
        end

        return @@payload = {} unless payload

        begin
          payload = decode_payload(payload)
          verified = verify_payload(payload)
        rescue
          verified = false
        end

        @@payload = verified ? payload : {}
      end

      # Get the signed in user's UUID.
      #
      # @return [String] If signed in user.
      # @return [nil] If no signed in user.
      def user_id
        payload_user :id
      end

      # Get the signed in user's email address.
      #
      # @return [String] If signed in user.
      # @return [nil] If no signed in user.
      def user_email
        payload_user :email
      end

      # Check whether there's a signed in user.
      #
      # @return [Boolean] Whether there's a signed in user.
      def signed_in?
        !!user_id
      end

    protected

      # Loaded config values.
      @@config = nil

      # Loaded payload.
      @@payload = nil

      # Verify that a config has all the required values.
      #
      # @param  config [Hash<String>] Config values.
      # @raise  [RuntimeError] If invalid.
      # @return [true] If valid.
      def verify_config(config)
        raise 'no config loaded' unless config
        raise 'no `app_id` config value' unless config['app_id']
        raise 'no `app_secret` config value' unless config['app_secret']

        true
      end

      # Decode a payload from the client-side.
      #
      # @param  encoded_payload [String] Encoded payload.
      # @raise  [JSON::ParserError] If invalid JSON.
      # @return [Hash<Symbol>] Decoded payload.
      def decode_payload(encoded_payload)
        JSON.parse(Base64.decode64(encoded_payload), :symbolize_names => true)
      end

      # Generate the expected signature of a payload using the app's secret.
      #
      # @param  payload [Hash<Symbol>] Decoded payload.
      # @return [String] Expected signature of the payload.
      def expected_signature(payload)
        payload_clone = payload.clone
        payload_clone[:user].delete(:signature)

        OpenSSL::HMAC.digest(OpenSSL::Digest::SHA512.new, config('app_secret'), JSON.generate(payload_clone[:user]))
      end

      # Verify that a payload hasn't been tampered with or faked by comparing
      # signatures.
      #
      # @param  payload [Hash<Symbol>] Decoded payload.
      # @return [Boolean] Whether the payload is legit.
      def verify_payload(payload)
        signature = Base64.decode64(payload[:user][:signature])

        signature == expected_signature(payload)
      end

      # Get the loaded payload.
      #
      # @return [Hash<Symbol>] Loaded payload. Empty if there's no payload or it
      #         failed verification.
      def payload
        @@payload || load_payload
      end

      # Get a value from the `user` hash of the loaded payload.
      #
      # @param  key [Symbol] Name of value.
      # @return [*] Requested value or `nil` if not set.
      def payload_user(key)
        payload = self.payload

        if payload.key?(:user)
          payload[:user][key]
        else
          nil
        end
      end
    end
  end
end
