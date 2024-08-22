# frozen_string_literal: true
require 'jwt'
require 'rack/cors'
require 'rack/deflater'

require_relative './initializers'

Initializers.init_all => { app:, jwks_server:, pub_key_store:, priv_key_store: }

use Rack::CommonLogger
use Rack::Deflater

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: %i[get post]
  end
end

full_app =
  Rack::Builder.app do
    map '/jsonrpc' do
      run app
    end
    map '/.well-known/jwks.json' do
      run jwks_server
    end
  end


# A.2.3.  Elliptic Curve Digital Signature Algorithm (ECDSA) P-256 256-Bit
# https://datatracker.ietf.org/doc/html/rfc8392#appendix-A.2.3
pub_key_store.add(
  JWT::JWK.new(
    {
      kty: 'EC',
      crv: 'P-256',
      x: 'FDMpzOeGjkFpJ1mc9lo0884v/aVafspp7YkZo5TULw8',
      y: 'YPfxp4DYp4O/t6LdayeW6BKNu87509Fo25Uplxo257k',
      kid: 'AsymmetricECDSA256'
    }
  )
)
priv_key_store.add(
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
# RubyVM::YJIT.enable

run full_app
