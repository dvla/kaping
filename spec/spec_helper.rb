# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'
require 'simplecov_json_formatter'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::JSONFormatter,
    SimpleCov::Formatter::Console,
  ],
  )
SimpleCov.minimum_coverage 80
SimpleCov.start do
  track_files 'lib/**/*.rb'
  add_filter '/spec'
end

require 'dvla/kaping'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# RSpec::Mocks.configuration do
#   mock_config |
#     mock_config.allow_message_expectations_on_nil = true
# end
