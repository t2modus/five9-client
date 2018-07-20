
# Five9::Client
A client library written in plain old Ruby to facilitate working with the Five9 API from within our projects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'five9-client', git: 'https://github.com/t2modus/five9-client'
```

You will also need to add credentials to your git setup on each computer that will use the gem (including servers!) so that your application can actually access the repo. You can do that like this:
`bundle config https://github.com/t2modus/five9-client <github_username>:<github_password>`

And then execute:

    $ bundle

## Usage

For initial setup, you'll need to either configure the client via an initializer, or set the FIVE9_URL, FIVE9_USER, and FIVE9_PASSWORD environment variables. If you don't set these variables, you'll need to configure the client with an initializer as follows:
```ruby
Five9::Client.configure do |config|
	config.url = <FIVE9_URL_HERE>
	config.username = <FIVE9_USERNAME_HERE>
	config.password = <FIVE9_PASSWORD>
end
```
Usage is pretty straightforward. Each class is used as both a way of communicating with the API and a thin wrapper around the
data returned by the API as well. You can think about it as working similarly to ActiveRecord, except that instead of interacting
with the database you're interacting with Five9's API.

```ruby
campaign = Five9::Client::Campaign.list.first
lists = campaign.lists
ai_list = campaign.ai_list
ai_list.add_records(records)
Five9::Client::Report.new.run(start_time: 10.years.ago, end_time: Time.current, campaigns: campaign.name)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/t2modus/five9-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Five9::Client project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/t2modus/five9-client/blob/master/CODE_OF_CONDUCT.md).

