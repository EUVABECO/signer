module Cose
  class SignedCwt
    TAG = 18
    KID_HEADER = 4
    attr_reader :protected, :unprotected, :payload, :signature, :claims

    class Claims
      attr_reader :iss, :sub, :aud, :exp, :nbf, :iat, :cti, :other
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

      def self.from_hash(hash)
        new(hash)
      end

      def initialize(hash)
        @other = {}
        hash.each do |k, v|
          case k
          in :iss | 1
            @iss = v
          in :sub | 2
            @sub = v
          in :aud | 3
            @aud = v
          in :exp | 4
            @exp = v
          in :nbf | 5
            @nbf = v
          in :iat | 6
            @iat = v
          in :cti | 7
            @cti = v
          else
            @other[k] = v
          end
        end
      end

      def to_h
        {
          1 => @iss,
          2 => @sub,
          3 => @aud,
          4 => @exp,
          5 => @nbf,
          6 => @iat,
          7 => @cti
        }.compact
      end
    end

    class HcertClaims < Claims
      attr_reader :hcert # specific to the hcert
      def initialize(hash)
        super(hash)
        @hcert = hash[:hcert] || hash[-260]
      end

      def to_h
        super.merge({ -260 => @hcert })
      end
    end

    def self.from_hex(hex)
      from_bin([hex].pack('H*'))
    end

    def self.from_bin(bin)
      cwt = CBOR.decode(bin)
      raise "Can't read" unless cwt.tag == TAG

      protected, unprotected, payload, signature = cwt.value

      return SignedCwt.new(protected:, unprotected:, payload:, signature:)
    end

    def initialize(protected:, unprotected:, payload: {}, signature: nil, claims: nil)
      @protected = protected.class == String ? CBOR.decode(protected) : protected
      @unprotected = unprotected
      @payload = payload.class == String ? CBOR.decode(payload) : payload
      @claims = claims || HcertClaims.new(@payload)
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
        payload: @claims.to_h,
        signature: @signature
      }
    end
  end
end
