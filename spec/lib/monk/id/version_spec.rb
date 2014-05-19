require 'spec_helper'

describe Monk::Id do
  describe '::VERSION' do
    it { expect(Monk::Id::VERSION).to be_a(String) }
  end
end
