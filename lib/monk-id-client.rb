module MonkId
  class << self
    def config
      @@_config ||= YAML.load_file(File.join(Rails.root, 'config', 'monkid.yml'))[Rails.env]
    end

    def endpoint
      scheme = MonkId.config['ssl'] ? 'https' : 'http'
      "#{scheme}://#{MonkId.config['host']}:#{MonkId.config['port']}"
    end

    def user_params(opts = {})
      user_hash = {
        email: opts[:email],
        password: opts[:password],
        authentication_token: opts[:authentication_token]
      }.delete_if { |k, v| v.blank? }

      {
        api_key: MonkId.config['api_key'],
        user: user_hash
      }
    end

    # FIXME: Disable this once MonkID has a real SSL cert.
    def api_request(method, path, opts)
      response = Typhoeus::Request.send(method.to_sym, endpoint + path, params: user_params(opts), disable_ssl_peer_verification: true)
      JSON.parse(response.body)
    end

    # The following methods do not require a user authentication token.

    # Opts may contain:
    #   {
    #     email: New email to update the user
    #     password: New password for this user
    #   }
    #

    def register!(opts)
      api_request(:post, '/api/users', opts)
    end

    def login!(opts)
      api_request(:post, '/api/users/sign_in', opts)
    end

    def send_password_reset_instructions!(opts)
      api_request(:post, '/api/users/password', opts)
    end

    # The following methods require a user authentication token.

    # Opts may contain:
    #   {
    #     email: New email to update the user
    #     password: New password for this user
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
