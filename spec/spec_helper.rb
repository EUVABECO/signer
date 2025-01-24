# frozen_string_literal: true

require 'bundler/setup'
require 'byebug'
require_relative '../initializers'

DEPENDENCIES = Initializers.init_all

DEPENDENCIES[:priv_key_store].add(
  JWT::JWK.new(
    {
      kty: 'EC',
      crv: 'P-256',
      alg: 'ES256', # required for JWT.encode
      x: 'FDMpzOeGjkFpJ1mc9lo0884v/aVafspp7YkZo5TULw8',
      y: 'YPfxp4DYp4O/t6LdayeW6BKNu87509Fo25Uplxo257k',
      d: 'bBOCdlrsU1jxF3M9KBwce9w5iE0EpFoebGfIWLwgbBk',
      kid: 'AsymmetricECDSA256'
    }
  )
)
DEPENDENCIES[:pub_key_store].add(
  JWT::JWK.new(
    {
      kty: 'EC',
      crv: 'P-256',
      alg: 'ES256', # required for JWT.encode
      x: 'FDMpzOeGjkFpJ1mc9lo0884v/aVafspp7YkZo5TULw8',
      y: 'YPfxp4DYp4O/t6LdayeW6BKNu87509Fo25Uplxo257k',
      d: 'bBOCdlrsU1jxF3M9KBwce9w5iE0EpFoebGfIWLwgbBk',
      kid: 'AsymmetricECDSA256'
    }
  )
)

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

