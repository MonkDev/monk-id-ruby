# encoding: utf-8

require 'base64'
require 'json'
require 'openssl'
require 'yaml'

require 'monk/id/version'

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
      #         read from environment (`MONK_ID_CONFIG` variable, Rails,
      #         Sinatra).
      # @param  environment [String] Environment section to use. Leave `nil` to
      #         read from environment (`MONK_ID_ENV` variable, Rails, Sinatra).
      #         Defaults to `development`.
      # @raise  [StandardError] If the file doesn't exist or can't be read.
      # @return [Hash<String>] Loaded config values.
      def load_config(path = nil, environment = nil)
        path ||= config_path_from_environment
        environment ||= config_environment

        config = YAML.load_file(path)[environment]

        valid_config?(config)

        @config = config
      end

      # Get a config value. Attempts to load the config if it hasn't already
      # been loaded.
      #
      # @param  key [String] Name of config value.
      # @raise  [StandardError] If the config can't be loaded.
      # @return [*] Config value.
      def config(key)
        load_config unless @config

        @config[key]
      end

      # Load a payload from the client-side.
      #
      # @param  encoded_payload [String, #[]] Encoded payload or Hash-like
      #         cookies object to automatically load the payload from.
      # @return [Hash<Symbol>] Decoded and validate payload. Empty if there's no
      #         payload or it fails validation.
      def load_payload(encoded_payload = nil)
        payload = select_payload(encoded_payload)

        return @payload = {} unless payload

        begin
          payload = decode_payload(payload)
          valid = valid_payload?(payload)
        rescue
          valid = false
        end

        @payload = valid ? payload : {}
      end

      # Get the signed in user's UUID.
      #
      # @return [String] If signed in user.
      # @return [nil] If no signed in user.
      def user_id
        payload_user(:id)
      end

      # Get the signed in user's email address.
      #
      # @return [String] If signed in user.
      # @return [nil] If no signed in user.
      def user_email
        payload_user(:email)
      end

      # Check whether there's a signed in user.
      #
      # @return [Boolean] Whether there's a signed in user.
      def signed_in?
        !user_id.nil?
      end

      protected

      # Loaded config values.
      @config = nil

      # Loaded payload.
      @payload = nil

      # Get the path to the config file from the environment. Supports `ENV`
      # variable, Rails, and Sinatra.
      #
      # @return [String] Path to the config file.
      # @return [nil] If not set by the environment.
      def config_path_from_environment
        if ENV['MONK_ID_CONFIG']
          ENV['MONK_ID_CONFIG']
        elsif defined? Rails
          File.join(Rails.root, CONFIG_FILE)
        elsif defined? Sinatra
          File.join(Sinatra::Application.settings.root, CONFIG_FILE)
        end
      end

      # Get the environment to load within the config. Supports `ENV` variable,
      # Rails, and Sinatra. Defaults to `development` if none specify.
      #
      # @return [String] Environment name.
      def config_environment
        if ENV['MONK_ID_ENV']
          ENV['MONK_ID_ENV']
        elsif defined? Rails
          Rails.env
        elsif defined? Sinatra
          Sinatra::Application.settings.environment.to_s
        else
          'development'
        end
      end

      # Validate that a config has all the required values.
      #
      # @param  config [Hash<String>] Config values.
      # @raise  [RuntimeError] If invalid.
      # @return [true] If valid.
      def valid_config?(config)
        raise 'no config loaded' unless config
        raise 'no `app_id` config value' unless config['app_id']
        raise 'no `app_secret` config value' unless config['app_secret']

        true
      end

      # Select a payload from the first place one can be found.
      #
      # @param  encoded_payload [String, #[]] Encoded payload or Hash-like
      #         cookies object to select the payload from.
      # @return [String] Encoded payload.
      # @return [nil] If one can't be found.
      def select_payload(encoded_payload)
        if encoded_payload.is_a? String
          encoded_payload
        elsif encoded_payload.respond_to? :[]
          encoded_payload[COOKIE_NAME]
        end
      end

      # Decode a payload from the client-side.
      #
      # @param  encoded_payload [String] Encoded payload.
      # @raise  [JSON::ParserError] If invalid JSON.
      # @return [Hash<Symbol>] Decoded payload.
      def decode_payload(encoded_payload)
        JSON.parse(Base64.decode64(encoded_payload), symbolize_names: true)
      end

      # Generate the expected signature of a payload using the app's secret.
      #
      # @param  payload [Hash<Symbol>] Decoded payload.
      # @return [String] Expected signature of the payload.
      def expected_signature(payload)
        payload_clone = payload.clone
        payload_clone[:user].delete(:signature)

        OpenSSL::HMAC.digest(
          OpenSSL::Digest::SHA512.new,
          config('app_secret'),
          JSON.generate(payload_clone[:user])
        )
      end

      # Validate that a payload hasn't been tampered with or faked by comparing
      # signatures.
      #
      # @param  payload [Hash<Symbol>] Decoded payload.
      # @return [Boolean] Whether the payload is valid.
      def valid_payload?(payload)
        signature = Base64.decode64(payload[:user][:signature])

        signature == expected_signature(payload)
      end

      # Get the loaded payload.
      #
      # @return [Hash<Symbol>] Loaded payload. Empty if there's no payload or it
      #         failed validation.
      def payload
        @payload || load_payload
      end

      # Get a value from the `user` hash of the loaded payload.
      #
      # @param  key [Symbol] Name of value.
      # @return [*] Requested value or `nil` if not set.
      def payload_user(key)
        payload = self.payload

        payload.key?(:user) ? payload[:user][key] : nil
      end
    end
  end
end
