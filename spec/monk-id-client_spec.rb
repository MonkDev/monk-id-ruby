require 'spec_helper'
require 'ostruct'

describe MonkId do
  describe "loading config file" do
    before :each do
      MonkId.stub(:config_file).and_return('config/monkid.sample.yml')
    end

    context "in a Rails environment" do
      it "loads the YAML file" do
        Rails = OpenStruct.new(:root => Dir.pwd, :env => 'development')
        expect(MonkId.config['api_key']).to eq 'someapikey'
      end
    end

    context "in a Sinatra environment" do
      it "loads the YAML file" do
        settings = OpenStruct.new(:root => Dir.pwd, :environment => 'development')
        expect(MonkId.config['api_key']).to eq 'someapikey'
      end
    end

    context "in any other Ruby environment" do
      it "loads the YAML file" do
        ENV = { 'MONKID_CONFIG' => Dir.pwd, 'MONKID_ENV' => 'development' }
        expect(MonkId.config['api_key']).to eq 'someapikey'
      end
    end
  end
end