# frozen_string_literal: true

module Procedures
  class ToCwt
    ALGORITHM_VALUES_BY_TYPE_AND_CURV = { 'EC' => { 'P-256' => -7, 'P-384' => -35, 'P-521' => -36 } }.freeze

    def initialize(priv_key_store:, signer:, time: Time)
      @priv_key_store = priv_key_store
      @signer = signer
      @time = time
    end

    def call(hcert_data:, kid: nil)
      Base64.strict_encode64(internal_call(kid:, hcert_data:))
    end

    def internal_call(hcert_data:, kid: nil)
      jwk = kid.nil? ? @priv_key_store.current_key : @priv_key_store.get(kid)
      protected = { 1 => ALGORITHM_VALUES_BY_TYPE_AND_CURV[jwk[:kty]][jwk[:crv]] }
      unprotected = { Cose::SignedCwt::KID_HEADER => jwk[:kid].b }
      cwt = Cose::SignedCwt.new(
        protected:,
        unprotected:,
        claims: Cose::SignedCwt::HcertClaims.new(iss: 'SYA', iat: @time.now.to_i, exp: @time.now.to_i + 315360000, nbf: @time.now.to_i,  hcert: hcert_data)
      )
      Cose::SignedCwt.new(**cwt.deconstruct_keys, signature: @signer.sign(cwt.signature_data, jwk[:kid])).to_bin
    end
  end
end
