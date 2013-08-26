require 'base64'
require 'json'
require 'openssl'
require 'yaml'

module Monk
  module Id
    CONFIG_FILE = 'config/monkid.yml'.freeze
    COOKIE_NAME = '_monkIdPayload'.freeze

    class << self
      @@config = nil
      @@payload = nil

      def load_config(path = nil, environment = 'development')
        unless path
          if defined? Rails
            path = File.join(Rails.root, CONFIG_FILE)
            environment = Rails.env
          elsif defined? Sinatra
            path = File.join(Sinatra::Application.settings.root, CONFIG_FILE)
            environment = Sinatra::Application.settings.environment.to_s
          else
            path = ENV['MONKID_CONFIG']
            environment = ENV['MONKID_ENV']
          end
        end

        @@config = YAML.load_file(path)[environment]
      end

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

      def user_id
        payload_user :id
      end

      def user_email
        payload_user :email
      end

      protected

      def config
        @@config || load_config
      end

      def decode_payload(encoded_payload)
        JSON.parse(Base64.decode64(encoded_payload), :symbolize_names => true)
      end

      def expected_signature(payload)
        payload_clone = payload.clone
        payload_clone[:user].delete(:signature)

        OpenSSL::HMAC.digest(OpenSSL::Digest::SHA512.new, config['app_secret'], JSON.generate(payload_clone[:user]))
      end

      def verify_payload(payload)
        signature = Base64.decode64(payload[:user][:signature])

        signature == expected_signature(payload)
      end

      def payload
        @@payload || load_payload
      end

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
