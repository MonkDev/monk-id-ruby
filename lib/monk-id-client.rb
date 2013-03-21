require 'typhoeus'
require 'yaml'

module MonkId
  class << self

    def config_file
      'config/monkid.yml'
    end

    def config
      if defined? Rails
        @@_config ||= YAML.load_file(File.join(Rails.root, config_file))[Rails.env]
      elsif defined? Sinatra
        @@_config ||= YAML.load_file(File.join(settings.root, config_file))[settings.environment]
      else
        @@_config ||= YAML.load_file(ENV['MONKID_CONFIG'])[ENV['MONKID_ENV']]
      end
    end

    def endpoint
      scheme = MonkId.config['ssl'] ? 'https' : 'http'
      "#{scheme}://#{MonkId.config['host']}:#{MonkId.config['port']}"
    end

    def user_params(opts = {})
      user_hash = {
        email: opts[:email],
        password: opts[:password],
        first_name: opts[:first_name],
        last_name: opts[:last_name],
        birth_day: opts[:birth_day],
        birth_month: opts[:birth_day],
        birth_year: opts[:birth_day],
        one_time_token: opts[:one_time_token],
        authentication_token: opts[:authentication_token]
      }.delete_if { |k, v| v.nil? }

      {
        api_key: MonkId.config['api_key'],
        user: user_hash
      }
    end

    # FIXME: Disable this once MonkID has a real SSL cert.
    def api_request(method, path, opts)
      response = Typhoeus::Request.send(method.to_sym, endpoint + path, params: user_params(opts), ssl_verifypeer: false)
      JSON.parse(response.body)
    end

    # The following methods do not require a user authentication token.

    # Opts must contain:
    #   {
    #     email: [required] New email to update the user
    #     password: [required] New password for this user
    #   }
    #

    def login!(opts)
      api_request(:post, '/api/users/sign_in', opts)
    end

    def send_password_reset_instructions!(opts)
      api_request(:post, '/api/users/password', opts)
    end

    # Register opts may contain:
    #   {
    #     email: [required] New email to update the user
    #     password: [required] New password for this user
    #     first_name: [optional] first name of user,
    #     last_name: [optional] last name of user,
    #     birth_day: [optional] birth day of user,
    #     birth_month: [optional] birth month of user,
    #     birth_year: [optional] birth year of user,
    #   }
    #

    def register!(opts)
      api_request(:post, '/api/users', opts)
    end

    # The following methods require a user authentication token.
    # The update method allows for updating any of the user's PII,
    # and those fields only take effect in the update! method.

    # Opts may contain:
    #   {
    #     email: [required] New email to update the user
    #     password: [required] New password for this user
    #     first_name: [optional] first name of user,
    #     last_name: [optional] last name of  user,
    #     birth_day: [optional] birth day of user,
    #     birth_month: [optional] birth month of user,
    #     birth_year: [optional] birth year ouser,
    #     authentication_token: REQUIRED - authentication_token for this user
    #   }
    #
    def update!(opts)
      api_request(:put, '/api/users', opts)
    end

    def status(opts)
      api_request(:post, '/api/users/status', opts)
    end

    def logout!(opts)
      api_request(:delete, '/api/users/sign_out', opts)
    end
  end
end
