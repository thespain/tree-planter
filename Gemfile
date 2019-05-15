source 'https://rubygems.org/'

# App Stack
gem 'json',      '~> 2.2'
gem 'passenger', '~> 6.0', '>= 6.0.2'
gem 'sinatra',   '~> 2.0', '>= 2.0.5'

# rack is pulled as a dep of passenger but needs to be above 2.0.6 for security reasons
gem 'rack',      '~> 2.0', '>= 2.0.7'

group :development do
end

group :test do
  gem 'minitest',           '~> 5.11'
  gem 'minitest-reporters', '~> 1.3'
  gem 'rack-test',          '~> 1.1'
  gem 'rubocop',            '~> 0.69'
end
