# Omniauth for Gab

Ruby gem for authenticating with [Gab](https://gab.com), using an OAuth2 strategy.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-gab'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-gab

## Pre-requisites

Register your Gab App by logging into your account and going to [Settings > Developer Apps](https://gab.com/settings/clients). Click `Create app` and fill in the requested information. Make note of the `REDIRECT URL` as you will need the exact url for your configuration.

## Usage

### Configuration

In your Rails app, add `config/initializers/omniauth.rb` with the following:

If you are using environment variables or [dotenv](https://github.com/bkeepers/dotenv) (recommended):

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :gab, ENV['GAB_CLIENT_ID'], ENV['GAB_CLIENT_SECRET'],
    scope: ENV['GAB_SCOPES'],
    redirect_uri: ENV['GAB_REDIRECT_URI'],
    provider_ignores_state: true
end
```

Or you can hardcode your credentials (not recommended):

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :gab, 'your-app-client-id', 'your-app-secret-id',
    scope: 'your scopes separated with a single space',
    redirect_uri: 'the redirect uri from above',
    provider_ignores_state: true
end
```

### Routing

You'll need to configure the following routes or something similar, in `routes.rb`.

```ruby
get '/auth/:provider/callback' => 'sessions#create'
get '/signin' => 'sessions#new', as: :signin
get '/signout' => 'sessions#destroy', as: :signout
get '/auth/failure' => 'sessions#failure'
```

### Model

Make sure to add at least the following columns to your `User` model:

```ruby
t.string :provider
t.string :uid
```

### Controller

You can create a sessions controller something like this:

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def new
    redirect_to '/auth/gab'
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.where(
      provider: auth['provider'],
      uid: auth['uid'].to_s
    ).first || User.create_with_omniauth(auth)
    reset_session
    session[:user_id] = user.id
    redirect_to root_url, notice: 'Signed in!'
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'Signed out!'
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end
end
```

### View

For a sign-in link:

```haml
= link_to 'Login to Gab', signin_path
```

## Resources

* [The Gab API Docs](https://developers.gab.com/)
* [OmniAuth](https://github.com/omniauth/omniauth)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/midwire/omniauth-gab. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Omniauth::Gab project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/midwire/omniauth-gab/blob/master/CODE_OF_CONDUCT.md).
