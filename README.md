Monk ID Ruby
============

Add to your `Gemfile`:

```ruby
gem 'monk-id', :github => 'MonkDev/monk-id-client', :branch => 'next'
```

For Rails and Sinatra, copy `config/monkid.sample.yml` in this repository to
`config/monkid.yml` in your app. This will be loaded automatically. All other
apps need to load their config explicitly:

```ruby
Monk::Id.load_config('/path/to/monkid.yml', 'development')
```

Next, load the payload:

```ruby
Monk::Id.load_payload(params[:monk_id_payload])
```

Or, if using the `cookie` option, simply pass in a hash-like cookies object:

```ruby
Monk::Id.load_payload(cookies)
```

Then you can access the user's ID and email:

```ruby
Monk::Id.user_id
Monk::Id.user_email
```

`nil` is returned if the user isn't signed in or the payload can't be decoded
and verified.
