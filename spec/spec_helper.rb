require 'simplecov'
require 'codecov'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require "bundler/setup"
require "lazy_xml_model"
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# TODO: Make this require all *.rb files in support
require_relative 'support/models/xml_record'
require_relative 'support/models/company'
require_relative 'support/models/company_basic'
require_relative 'support/shared_contexts/example_xml'

