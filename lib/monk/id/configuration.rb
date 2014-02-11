module Monk
  module Id
    class Configuration
      # Expected path of config file in Rails and Sinatra relative to the app's
      # root directory.
      CONFIG_FILE = 'config/monk_id.yml'.freeze

      attr_accessor :app_secret, :app_id

      def initialize
        load_with_file if path_from_environment
      end

      def load_with_file(path = nil, environment = nil)
        path ||= path_from_environment
        environment ||= get_environment
        load_with_hash(load_yaml(path, environment)) if path
      end

      def load_with_hash(hash)
        hash.each do |k,v|
          setter_command = "#{k}="
          send(setter_command, v) if respond_to? setter_command
        end
      end

      protected
        def path_from_environment
          if defined? Rails
            File.join(Rails.root, CONFIG_FILE)
          elsif defined? Sinatra
            File.join(Sinatra::Application.settings.root, CONFIG_FILE)
          elsif ENV['MONK_ID_CONFIG']
            ENV['MONK_ID_CONFIG']
          end
        end

        def get_environment
          if defined? Rails
            Rails.env
          elsif defined? Sinatra
            Sinatra::Application.settings.environment.to_s
          else
            ENV['MONK_ID_CONFIG'] || 'development'
          end
        end

        def load_yaml(path, environment)
          begin
            yaml_config = YAML.load_file(path)[environment]
          rescue Errno::ENOENT
            puts "WARNING: YAML configuration file not found at supplied path: #{path}"
          rescue Psych::SyntaxError
            puts "WARNING: YAML configuration file at #{path} has invalid syntax"
          end
          yaml_config || { }
        end
    end
  end
end
