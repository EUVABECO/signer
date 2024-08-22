module Procedures
  class ToJwt
    def initialize(priv_key_store:)
      @priv_key_store = priv_key_store
    end

    def call(payload:, kid: nil)
      internal_call(payload:, kid:)
    end

    def internal_call(payload:, kid: nil)
      jwk = kid.nil? ? @priv_key_store.current_key : @priv_key_store.get(kid)
      JWT.encode(payload, jwk.signing_key, jwk[:alg], kid: jwk[:kid])
    end
  end
end