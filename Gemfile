source "https://rubygems.org"

if RUBY_VERSION >= '1.8.7' and RUBY_VERSION < '1.9'
  gem 'rspec', '~> 2.0'
else
  gem "rspec", '< 3.2.0'
  gem 'rubocop', '0.33.0'
end

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_GEM_VERSION'] || '~> 3.8.0'
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'

  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-leading_zero-check"
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-version_comparison-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-unquoted_string-check"
  gem 'puppet-lint-appends-check'
  gem 'puppet-lint-empty_string-check'
  gem 'puppet-lint-file_ensure-check'
  gem 'puppet-lint-spaceship_operator_without_tag-check'
  gem 'puppet-lint-undef_in_function-check'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "puppet-blacksmith"
  gem "guard-rake"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-puppet_install_helper"
end
