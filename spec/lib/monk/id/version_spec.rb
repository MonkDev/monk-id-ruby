require 'spec_helper'

describe Monk::Id do
  describe '::VERSION' do
    it { expect(described_class::VERSION).to be_a(String) }
  end
end
