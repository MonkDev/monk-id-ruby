require 'spec_helper'

describe Monk::Id do
  RELATIVE_APP_PATH = 'config/monk_id.yml'
  let(:valid_config_hash) { {'app_id' => 'AN APP ID',
                             'app_secret' => 'A SECRET'} }

  it { should respond_to :load_config }
  it { should respond_to :load_payload }
  it { should respond_to :user_id }
  it { should respond_to :user_email }
  it { should respond_to :config }
  it { should respond_to :signed_in? }

  describe "initialization" do
  end

  describe ".load_config" do
    context "when the gem is included in a Rails app" do
      before do
        class ::Rails
        end
        @rails_root = '/rails/root'
        @rails_environment = 'development'
        Rails.stub(:root) { @rails_root }
        Rails.stub(:env) { @rails_environment }
        Monk::Id.stub(:verify_config) { true }
      end

      it "loads the appropriate environment configuration from a file at #{RELATIVE_APP_PATH} relative to Rails root" do
        loaded_hash = {}
        expect(loaded_hash).to receive(:[]).with(@rails_environment)
                                            .and_return(valid_config_hash)
        expect(YAML).to receive(:load_file)
                        .with(File.join(@rails_root, RELATIVE_APP_PATH))
                        .and_return(loaded_hash)
        Monk::Id.load_config
      end

      after { Object.send(:remove_const, :Rails) }
    end

    context "when the gem is included in a Sinatra app" do
      before do
        module Sinatra
          module Application
          end
        end
        @sinatra_root = '/sinatra/root'
        @sinatra_environment = 'development'
        Sinatra::Application.stub_chain(:settings, :root) { @sinatra_root }
        Sinatra::Application.stub_chain(:settings, :environment) { @sinatra_environment }
      end

      it "loads the appropriate environment configuration from a file at #{RELATIVE_APP_PATH} relative to Sinatra root" do
        loaded_hash = {}
        expect(loaded_hash).to receive(:[])
                               .with(@sinatra_environment)
                               .and_return(valid_config_hash)
        expect(YAML).to receive(:load_file)
                        .with(File.join(@sinatra_root, RELATIVE_APP_PATH))
                        .and_return(loaded_hash)
        Monk::Id.load_config
      end

      after { Object.send(:remove_const, :Sinatra) }
    end

    context "when path to config file and an environment are passed as arguments" do
      it "loads the config file at that path and the environment options from it" do
        path = '/test/path.yml'
        environment = 'development'
        loaded_hash = {}
        expect(loaded_hash).to receive(:[])
                               .with(environment)
                               .and_return(valid_config_hash)
        YAML.should_receive(:load_file).with(path).and_return(loaded_hash)
        Monk::Id.load_config(path, environment)
      end
    end

    context "when the config loaded from the file does not contain a 'app_id' key" do
      before do
        without_id = valid_config_hash.reject { |k, v| k == 'app_id' }
        YAML.stub(:load_file).and_return('development' => without_id)
      end

      it "raises an error saying 'no `app_id` config value'" do
        expect { Monk::Id.load_config }.to raise_error 'no `app_id` config value'
      end
    end

    context "when the config loaded from the file does not contain a 'app_secret' key" do
      before do
       without_secret = valid_config_hash.reject { |k, v| k == 'app_secret' }
       YAML.stub(:load_file).and_return('development' => without_secret)
     end

      it "raises an error saying 'no `app_secret` config value'" do
        expect { Monk::Id.load_config }.to raise_error 'no `app_secret` config value'
      end
    end
  end

  describe ".config(key)" do
    context "when the config is properly loaded" do
      before do
        @app_secret = 'THIS IS THE EXPECTED SECRET VALUE'
        path = 'fake_path.yml'
        environment = 'development'
        environment_hash = valid_config_hash.dup
        environment_hash['app_secret'] = @app_secret
        YAML.stub(:load_file).with(path)
            .and_return('development' => environment_hash)
        Monk::Id.load_config(path, environment)
      end

      it "returns the value for that key" do
        expect(Monk::Id.config('app_secret')).to eq @app_secret
      end
    end
  end
end
