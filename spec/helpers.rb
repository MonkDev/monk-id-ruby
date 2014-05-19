module Helpers
  def spec_path
    File.expand_path(File.dirname(__FILE__))
  end

  def config_path
    "#{spec_path}/config"
  end

  def config_file_path
    "#{config_path}/monk_id.yml"
  end

  def config_file_alt_path
    "#{config_path}/monk_id_alt.yml"
  end

  def valid_payload
    'eyJ1c2VyIjp7ImVtYWlsIjoianN0YXl0b25AbW9ua2RldmVsb3BtZW50LmNvbSIsImlkIjoiNjJjOTg4YmEtMTNkOC00NzNlLWFkZWItOGY3ZDJjNjI4NDZhIiwic2lnbmF0dXJlIjoiOWlGYStLWHlTZTEvS29uM0hXRitLZlRQVDJ2MVl3QyttVEFBQko0QXpsRWZkNmR0UG1HWWpVend2OUtYXG5vbXJreWFMQi9oQjcrWExHQW41OTlLKzlFdz09XG4ifX0='
  end

  def expected_payload
    {
      :user => {
        :id    => '62c988ba-13d8-473e-adeb-8f7d2c62846a',
        :email => 'jstayton@monkdevelopment.com'
      }
    }
  end

  def invalid_payload
    'eyJ1c2VyIjp7ImVtYWlsIjoianN0YXl0b25AbW9ua2RldmVsb3BtZW50LmNvbSIsImlkIjoiNjJjOTg4YmEtMTNkOC00NzNlLWFkZWItOGY3ZDJjNjI4NDZhIiwic2lnbmF0dXJlIjoiUlRGcXhIK3dPbzh4V0JGQko0cTNTRnVSc3VOTWxUTE5iak1wTjBFclYxNzh0U3pwS2VlU2J2T29SQzNUXG4zVTkxVCtLK3FQc3JoMjVycEN5QVMrYlFEdz09XG4ifX0='
  end

  def reset_payload
    Monk::Id.class_variable_set :@@payload, nil
  end

  def config_env
    'test'
  end

  def load_config
    Monk::Id.load_config(config_file_path, config_env)
  end

  def expected_config(environment)
    {
      'app_id'     => "#{environment}_app_id",
      'app_secret' => "#{environment}_app_secret"
    }
  end

  def expected_config_test
    {
      'app_id'     => 'ca13c9d1-6600-490e-a448-adb99e2eb906',
      'app_secret' => '98d7ac3f9e22e52f9f23b83ca791db055acad39a27e17dc7'
    }
  end

  def set_config_env
    ENV['MONK_ID_CONFIG'] = config_file_alt_path
    ENV['MONK_ID_ENV'] = 'env'
  end

  def reset_config
    Monk::Id.class_variable_set :@@config, nil

    ENV['MONK_ID_CONFIG'] = nil
    ENV['MONK_ID_ENV'] = nil
  end

  def mock_rails
    Object.const_set(:Rails, Class.new)

    Rails.stub(:root) { spec_path }
    Rails.stub(:env) { 'rails' }
  end

  def remove_rails
    Object.send(:remove_const, :Rails)
  end

  def mock_sinatra
    Object.const_set(:Sinatra, Module.new)
    Sinatra.const_set(:Application, Module.new)

    Sinatra::Application.stub_chain(:settings, :root) { spec_path }
    Sinatra::Application.stub_chain(:settings, :environment) { :sinatra }
  end

  def remove_sinatra
    Sinatra.send(:remove_const, :Application)
    Object.send(:remove_const, :Sinatra)
  end
end
