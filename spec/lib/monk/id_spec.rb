require 'spec_helper'

describe Monk::Id do
  before(:all) { load_config }

  describe '::CONFIG_FILE' do
    it { expect(described_class::CONFIG_FILE).to eq('config/monk_id.yml') }
  end

  describe '::COOKIE_NAME' do
    it { expect(described_class::COOKIE_NAME).to eq('_monkIdPayload') }
  end

  describe '.config' do
    context 'when a config value is set' do
      it 'returns the config value' do
        expect(described_class.config('app_id'))
          .to eq('ca13c9d1-6600-490e-a448-adb99e2eb906')
      end
    end

    context 'when a config value is not set' do
      it { expect(described_class.config('not_set')).to be_nil }
    end

    context 'when a config is not loaded' do
      before { reset_config }
      after(:all) { load_config }

      it 'loads a config from the environment' do
        set_config_env

        expect(described_class.config('app_id')).to eq('env_app_id')
      end
    end
  end

  describe '.load_config' do
    before { reset_config }
    after(:all) { load_config }

    describe '(path)' do
      context 'when the path is specified' do
        it 'loads the config file from the path' do
          expect(described_class.load_config(config_file_path, config_env))
            .to eq(expected_config_test)
        end
      end

      context 'when the path is not specified' do
        it 'loads the config file from ENV["MONK_ID_CONFIG"]' do
          set_config_env

          expect(described_class.load_config(nil, 'env'))
            .to eq(expected_config('env'))
        end
      end

      context 'when the path does not exist' do
        it do
          path = '/does/not/exist.yml'

          expect { described_class.load_config(path, config_env) }
            .to raise_error(StandardError)
        end
      end
    end

    describe '(environment)' do
      context 'when the environment is specified' do
        it 'loads the environment' do
          expect(described_class.load_config(config_file_path, config_env))
            .to eq(expected_config_test)
        end
      end

      context 'when the environment is not specified' do
        it 'uses the environment from ENV["MONK_ID_ENV"]' do
          set_config_env

          expect(described_class.load_config(config_file_alt_path, nil))
            .to eq(expected_config('env'))
        end

        it 'defaults to "development"' do
          expect(described_class.load_config(config_file_path, nil))
            .to eq(expected_config('development'))
        end
      end

      context 'when the environment does not exist' do
        it do
          expect { described_class.load_config(config_file_path, 'invalid') }
            .to raise_error(StandardError)
        end
      end
    end

    context 'when the environment is Rails' do
      before { mock_rails }
      after { remove_rails }

      context 'when the path is not specified' do
        it 'loads ::CONFIG_FILE relative to Rails' do
          expect(described_class.load_config(nil, 'rails'))
            .to eq(expected_config('rails'))
        end
      end

      context 'when the environment is not specified' do
        it 'uses the Rails environment' do
          expect(described_class.load_config(config_file_path, nil))
            .to eq(expected_config('rails'))
        end
      end
    end

    context 'when the environment is Sinatra' do
      before { mock_sinatra }
      after { remove_sinatra }

      context 'when the path is not specified' do
        it 'loads ::CONFIG_FILE relative to Sinatra' do
          expect(described_class.load_config(nil, 'sinatra'))
            .to eq(expected_config('sinatra'))
        end
      end

      context 'when the environment is not specified' do
        it 'uses the Sinatra environment' do
          expect(described_class.load_config(config_file_path, nil))
            .to eq(expected_config('sinatra'))
        end
      end
    end

    context 'when the config is not valid' do
      it do
        path = "#{config_path}/monk_id_invalid.yml"

        expect { described_class.load_config(path, config_env) }
          .to raise_error(StandardError)
      end
    end

    context 'when a required config value is not set' do
      it 'fails with a StandardError' do
        error_message = 'no `app_secret` config value'

        expect { described_class.load_config(config_file_alt_path, 'required') }
          .to raise_error(StandardError, error_message)
      end
    end
  end

  describe '.load_payload' do
    before { reset_payload }
    after(:all) { reset_payload }

    context 'when the payload is valid' do
      context 'when the payload is a string' do
        it 'loads the payload' do
          expect(described_class.load_payload(valid_payload))
            .to eq(expected_payload)
        end
      end

      context 'when the payload responds to #[]' do
        it 'loads the payload from ::COOKIE_NAME' do
          cookies = { Monk::Id::COOKIE_NAME => valid_payload }

          expect(described_class.load_payload(cookies)).to eq(expected_payload)
        end
      end
    end

    context 'when the payload is not valid' do
      context 'when the payload cannot be decoded' do
        it { expect(described_class.load_payload('invalid')).to be_empty }
      end

      context 'when the payload cannot be validated (wrong signature)' do
        it { expect(described_class.load_payload(invalid_payload)).to be_empty }
      end

      context 'when the payload is nil' do
        it { expect(described_class.load_payload(nil)).to be_empty }
      end
    end
  end

  context 'when signed in' do
    before(:all) { described_class.load_payload(valid_payload) }
    after(:all) { reset_payload }

    describe '.signed_in?' do
      it { expect(described_class.signed_in?).to eq(true) }
    end

    describe '.user_email' do
      it 'returns the email of the user' do
        expect(described_class.user_email).to eq('jstayton@monkdevelopment.com')
      end
    end

    describe '.user_id' do
      it 'returns the UUID of the user' do
        expect(described_class.user_id)
          .to eq('62c988ba-13d8-473e-adeb-8f7d2c62846a')
      end
    end
  end

  context 'when signed out' do
    describe '.signed_in?' do
      it { expect(described_class.signed_in?).to eq(false) }
    end

    describe '.user_email' do
      it { expect(described_class.user_email).to be_nil }
    end

    describe '.user_id' do
      it { expect(described_class.user_id).to be_nil }
    end
  end
end
