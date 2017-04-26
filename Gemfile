source "https://rubygems.org/"

# App Stack
gem "passenger", "~> 5.1"
gem "sinatra",   "~> 1.4"

if RUBY_VERSION < '2.0'
  gem 'json', '1.8.3'
else
  gem 'json', '~> 2.1'
end

group :development do

end

group :test do
  gem "minitest",           "~> 5.10"
  gem "minitest-reporters", "~> 1.1"
  gem "rack-test",          "~> 0.6"
end
