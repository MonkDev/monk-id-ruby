Monk ID Ruby
============

[![Gem Version](https://badge.fury.io/rb/monk-id.png)](http://badge.fury.io/rb/monk-id)
[![Code Climate](https://codeclimate.com/github/MonkDev/monk-id-ruby.png)](https://codeclimate.com/github/MonkDev/monk-id-ruby)
[![Dependency Status](https://gemnasium.com/MonkDev/monk-id-ruby.svg)](https://gemnasium.com/MonkDev/monk-id-ruby)

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

```bash
$ bundle
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

Development
-----------

Start by installing the development dependencies with Bundler:

```bash
$ bundle
```

This requires all subsequent commands be prepended with `bundle exec`, which has
been ommitted for conciseness.

During development, changes must be tested manually since an automated test
suite does not yet exist. This is best done by requiring the library locally in
an app or website that integrates it already. There are a few ways to do this.

### With Bundler

Not to be confused with the fact that Bundler is used for development of this
library, if Bundler is used in the test app or website, you can either specify a
path to the library locally:

```ruby
gem 'monk-id', :path => '/path/to/monk-id-ruby'
```

Or configure Bundler to use a local repository instead of the GitHub repository
(more details [in the documentation](http://bundler.io/v1.5/git.html#local)):

```ruby
gem 'monk-id', :github => 'MonkDev/monk-id-ruby', :branch => 'master'
```

```bash
$ bundle config local.monk-id /path/to/monk-id-ruby
```

### Without Bundler

If Bundler is not used, you can either build and install the gem as a system
gem (this must be done for every change):

```bash
$ rake install
```

```ruby
require 'monk/id'
```

Or require the library directly:

```ruby
require '/path/to/monk-id-ruby/lib/monk/id'
```

### Documentation

[YARD](http://yardoc.org) is used for code documentation. During development,
you can preview as you document by starting the YARD server:

```bash
$ yard server --reload
```

This hosts the documentation at http://localhost:8808 and automatically watches
for changes on page refresh.

The documentation can also be built to a `doc` directory (that is ignored by
git):

```bash
$ yard
```

### Quality

[Code Climate](https://codeclimate.com) is setup to perform continuous code
quality inspection on every commit. The quality badge is displayed at the top of
this README, with the [full report available here](https://codeclimate.com/github/MonkDev/monk-id-ruby).

Deployment
----------

[gem-release](https://github.com/svenfuchs/gem-release) is used to

1.  bump the version in `lib/monk/id/version.rb`,
2.  tag and push the release to GitHub,
3.  and release to [RubyGems](https://rubygems.org).

These steps can be executed individually, but it's easiest to do all at once:

```bash
$ gem bump --version major|minor|patch --tag --release
```

Be sure to choose the correct version by following
[Semantic Versioning](http://semver.org).

### Publish Documentation

After releasing a new version, the documentation must be manually built and
published to the `gh-pages` branch.
