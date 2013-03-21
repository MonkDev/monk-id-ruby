# Monk::Id::Client

Client for Monk ID.

## Installation

Add this line to your application's Gemfile:

    gem 'monk-id-client', :git => 'https://github.com/MonkDev/monk-id-client.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monk-id-client

### Rails

Create a 'monkid.yml' file in your Rails config/ directory. Reference the sample monkid.yml for information.

### Rails / Sinatra

Place `monkid.yml` in your `config` directory. Reference `config/monkid.sample.yml` for more information.

### Ruby

Place `monkid.yml` (reference `config/monkid.sample.yml` for more information) in a directory of your choosing and set the following two environment variables:

    ENV['MONKID_CONFIG'] = '/path/to/monkid.yml'
    ENV['MONKID_ENV'] = 'production|development'

## Usage

### Overview

The first step is to embed the monkid.yml configuration file into your Rails tree. You can copy the example file into RAILS_ROOT/config. The structure is similar to that of database.yml - specify a set of configuration options for a given environment. You MUST supply an api key (provided to you) to perform any of the below commands. All possible options are in the example yml file.

You will also receive both a status_key and status_code attribute that provides for a descriptive response. For example, if you try to register with an email that exists:

     => {"success"=>false, "status_key"=>"email_exists", "status_code"=>2}

List of possible error codes:

    :unknown_error => -1,
    :success => 0,
    :invalid_email => 1,
    :email_exists => 2,
    :invalid_password => 3,
    :short_password => 4,
    :blank_password => 5,


#### UUID

All users will be identified by a global UID, which is returned as the 'guid' attribute. If you are storing users locally, use this ID to tie them to their Monk ID user.

### Interaction

All usage of monk-id-client is through class methods.

Registering a user (you can also pass in first_name, last_name, birth_day, birth_month, and birth_year):

    MonkId.register!(:email => 'some@email.com', :password => 'somepassword')

Logging in a user (email and password are required):

    MonkId.login!(:email => 'some@email.com', :password => 'somepassword')

Sending password reset instructions:

    MonkId.send_password_reset_instructions!(:email => 'hey@forgotit.com')

NOTE: you need an authentication token for the following methods.

Updating a user's PII (first name, last name, email, birth_day, etc.).:

    MonkId.update!(:email => 'hey@you.com', :authentication_token => '123456')

Checking on their status (return a full hash containing all the user's info):

    MonkId.status(:authentication_token => '123123')

Logging a user out:

    MonkId.logout!(:authentication_token => '123123')

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
