module Cose
  class Signer
    NAMED_CURVES = {
      'prime256v1' => {
        algorithm: 'ES256',
        digest: 'sha256'
      },
      'secp256r1' => {
        algorithm: 'ES256',
        digest: 'sha256'
      },
      'secp384r1' => {
        algorithm: 'ES384',
        digest: 'sha384'
      },
      'secp521r1' => {
        algorithm: 'ES512',
        digest: 'sha512'
      },
      'secp256k1' => {
        algorithm: 'ES256K',
        digest: 'sha256'
      }
    }.freeze

    SUPPORTED = NAMED_CURVES.map { |_, c| c[:algorithm] }.uniq.freeze

    def initialize(priv_key_store:, pub_key_store:)
      @priv_key_store = priv_key_store
      @pub_key_store = pub_key_store
    end

    def curve_by_name(name)
      NAMED_CURVES.fetch(name) { raise UnsupportedEcdsaCurve, "The ECDSA curve '#{name}' is not supported" }
    end

    def sign(msg, kid)
      key = @priv_key_store.get(kid).signing_key
      curve_definition = curve_by_name(key.group.curve_name)

      digest = OpenSSL::Digest.new(curve_definition[:digest])
      asn1_to_raw(key.dsa_sign_asn1(digest.digest(msg)), key)
      # key.sign(digest, msg)
    end

    def hex_signature(msg, kid)
      sign(msg, kid).unpack1('H*')
    end

    def asn1_to_raw(signature, public_key)
      byte_size = (public_key.group.degree + 7) / 8
      OpenSSL::ASN1.decode(signature).value.map { |value| value.value.to_s(2).rjust(byte_size, "\x00") }.join
    end

    def verify_cwt(cwt)
      verify(
        kid: cwt.kid,
        msg: cwt.signature_data,
        sig: cwt.signature
      )
    end

    def verify(kid:, msg:, sig:)
      public_key = @pub_key_store.get(kid).verify_key
      curve_definition = curve_by_name(public_key.group.curve_name)
      digest = OpenSSL::Digest.new(curve_definition[:digest])
      public_key.dsa_verify_asn1(digest.digest(msg), raw_to_asn1(sig, public_key))
    rescue OpenSSL::PKey::PKeyError
      raise 'Signature verification raised'
    end

    def raw_to_asn1(signature, private_key)
      byte_size = (private_key.group.degree + 7) / 8
      sig_bytes = signature[0..(byte_size - 1)]
      sig_char = signature[byte_size..-1] || ''
      OpenSSL::ASN1::Sequence.new(
        [sig_bytes, sig_char].map { |int| OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(int, 2)) }
      ).to_der
    end
  end
end
