# frozen_string_literal: true

require 'bundler/setup'
require_relative '../initializers'

DEPENDENCIES = Initializers.init_all

RSpec.configure do |rspec_config|
  rspec_config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  rspec_config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  rspec_config.shared_context_metadata_behavior = :apply_to_host_groups


  rspec_config.backtrace_exclusion_patterns = []
end

