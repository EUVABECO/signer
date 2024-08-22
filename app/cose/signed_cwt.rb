module Cose
  class SignedCwt
    TAG = 18
    KID_HEADER = 4
    attr_reader :protected, :unprotected, :payload, :signature

    class Claims
      attr_reader :iss, :sub, :aud, :exp, :nbf, :iat, :cti
      # +------+-----+----------------------------------+
      # | Name | Key | Value Type                       |
      # +------+-----+----------------------------------+
      # | iss  | 1   | text string                      |
      # | sub  | 2   | text string                      |
      # | aud  | 3   | text string                      |
      # | exp  | 4   | integer or floating-point number |
      # | nbf  | 5   | integer or floating-point number |
      # | iat  | 6   | integer or floating-point number |
      # | cti  | 7   | byte string                      |
      # +------+-----+----------------------------------+

      KEY_MAPPER = { 1 => :iss, 2 => :sub, 3 => :aud, 4 => :exp, 5 => :nbf, 6 => :iat, 7 => :cti }

      def self.from_hash(hash)
        new(**hash.transform_keys { |k| KEY_MAPPER[k] })
      end

      def initialize(iss: nil, sub: nil, aud: nil, exp: nil, nbf: nil, iat: nil, cti: nil)
        @iss = iss
        @sub = sub
        @aud = aud
        @exp = exp
        @nbf = nbf
        @iat = iat
        @cti = cti
      end
    end

    def self.from_hex(hex)
      # hex.scan(/../).map { |x| x.hex.chr }.join
      from_bin([hex].pack('H*'))
    end

    def self.from_bin(bin)
      cwt = CBOR.decode(bin)
      raise "Can't read" unless cwt.tag == TAG

      protected, unprotected, payload, signature = cwt.value

      return SignedCwt.new(protected:, unprotected:, payload:, signature:)
    end

    def initialize(protected:, unprotected:, payload:, signature: nil)
      @protected = protected.class == String ? CBOR.decode(protected) : protected
      @unprotected = unprotected
      @claims = payload.class == String ? CBOR.decode(payload) : payload
      @payload = payload
      @signature = signature
    end

    def alg
      case @protected[1]
      when -7
        return 'ES256'
      when -35
        return 'ES384'
      when -36
        return 'ES512'
      else
        raise 'Unsupported algorithm'
      end
    end

    def hex_signature
      @signature.unpack1('H*')
    end

    def signature_data(external_data = nil)
      CBOR.encode(['Signature1', @protected.empty? ? ''.b : protected.to_cbor, external_data || ''.b, @payload])
    end

    def claims
      Claims.from_hash(**@payload.slice(1, 2, 3, 4, 5, 6, 7))
    end

    def to_bin
      CBOR::Tagged.new(18, [CBOR.encode(@protected), @unprotected, @payload, @signature]).to_cbor
    end

    def to_hex
      to_bin.unpack1('H*')
    end

    def kid
      @unprotected[KID_HEADER]
    end

    def deconstruct_keys(_k: nil)
      {
        protected: @protected,
        unprotected: @unprotected,
        payload: @payload,
        signature: @signature
      }
    end
  end
end
