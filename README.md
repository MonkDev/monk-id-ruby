Monk ID Ruby
============

[![Gem Version](https://badge.fury.io/rb/monk-id.png)](http://badge.fury.io/rb/monk-id)

Integrate Monk ID authentication and single sign-on for apps and websites on the
server-side.

*   [Documentation](http://monkdev.github.io/monk-id-ruby/Monk/Id.html)

Overview
--------

Monk ID authentication and single sign-on works in the browser by integrating
[Monk ID JS](https://github.com/MonkDev/monk-id-js). Only being able to check
whether a user is signed in on the client-side is limiting, however, which is
where this library is helpful. It takes a payload from the client-side
JavaScript and decodes it for access in your Ruby code. There is no Monk ID API
that can be accessed on the server-side, so this library depends on client-side
integration.

### Install

Add the gem to your `Gemfile` if using [Bundler](http://bundler.io):

```ruby
gem 'monk-id'
```

Or install manually:

```bash
$ gem install monk-id
```

### Configure

Configuration is done in an external YAML file. There's a sample file in this
repository: `config/monk_id.sample.yml`.

Rails and Sinatra apps need only copy this file to `config/monk_id.yml` for it
to be loaded automatically.

All other apps need to load the file explicitly:

```ruby
Monk::Id.load_config('/path/to/monk_id.yml', 'development')
```

Remember, replace the sample values with your own, and keep the file safe as it
contains your app secret.

### Access

If you have Monk ID JS configured to store the payload automatically in a cookie
(the default), simply pass a hash-like cookies object to load the payload from:

```ruby
Monk::Id.load_payload(cookies)
```

The encoded payload can also be passed directly, which is useful if you're
sending it in a GET/POST request instead:

```ruby
Monk::Id.load_payload(params[:monk_id_payload])
```

Loading the payload must be done before trying to access any values stored in
the payload. In Rails, this usually means placing it in a `before_action` in
your `ApplicationController`.

Once the payload is loaded, you can ask whether the user is signed in:

```ruby
Monk::Id.signed_in?
```

Or for their ID and email:

```ruby
Monk::Id.user_id
Monk::Id.user_email
```

`nil` is returned if the user isn't signed in or the payload can't be decoded
and verified.
