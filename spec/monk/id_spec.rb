require 'spec_helper'

describe Monk::Id do

  it { should respond_to :load_config }
  it { should respond_to :load_payload }
  it { should respond_to :user_id }
  it { should respond_to :user_email }
  it { should respond_to :config }
  it { should respond_to :signed_in? }

end
