# Firebase::Authentication

A Ruby wrapper for [Firebase Auth REST API](https://firebase.google.com/docs/reference/rest/auth)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'firebase-authentication'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install firebase-authentication

## Usage

First, initialize service client with your Web API Key.<br>

```ruby
require "firebase/authentication"
service = Firebase::Authentication::Service.new(ENV['API_KEY'])
```

Then, call the [method](https://github.com/shuntagami/firebase-authentication/blob/main/lib/firebase/authentication/service.rb) you need like below.<br>

```ruby
service.sign_up(email, password)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/firebase-authentication. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/firebase-authentication/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Firebase::Authentication project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/firebase-authentication/blob/main/CODE_OF_CONDUCT.md).
