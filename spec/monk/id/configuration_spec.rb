require 'spec_helper'

describe Monk::Id::Configuration do
  let(:configuration) { Monk::Id::Configuration.new }
  subject { configuration }

  before do
    configuration.app_id = 'TEST APP ID'
    configuration.app_secret = 'TEST APP SECRET'
  end

  it { should respond_to :app_id }
  it { should respond_to :app_id= }
  it { should respond_to :app_secret }
  it { should respond_to :app_secret= }

  describe ".load_with_file" do
    context "when the provided path is not a valid file" do
      it "raises an error saying 'WARNING: YAML configuration file not found at supplied path: BAD_PATH' " do
        bad_path = "this_is_a_bad_path.yml"
        expect { configuration.load_with_file(bad_path) }
        .to raise_error "WARNING: YAML configuration file not found at supplied path: #{bad_path}"
      end
    end
  end

  describe ".load_with_hash" do
    context "when supplied a hash with keys that are configuration attributes" do
      it "sets the attributes to the values" do
        configuration.app_secret = nil
        app_secret_value = 'New App Secret'
        configuration.load_with_hash('app_secret' => app_secret_value )
        expect(configuration.app_secret).to be app_secret_value
      end
    end

    context "when supplied a hash with keys that are not configuration attributes" do
      it "does not raise an error" do
        expect { configuration.load_with_hash('bad_key' => 'bad_value') }
        .not_to raise_error
      end
    end
  end
end
