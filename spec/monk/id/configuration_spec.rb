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
end
