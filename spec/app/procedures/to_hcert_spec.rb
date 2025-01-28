module Procedures
  class DummyTime
    def now
      1736785067
    end
  end
  RSpec.describe ToHcert do
    let(:time) { DummyTime.new }
    let(:dependencies) { Initializers.init_all(time:) }

    before do
      dependencies[:priv_key_store].add(
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
      dependencies[:pub_key_store].add(
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
    end

    let(:hcert_data) do
      {
        ver: "1.0.0",
        nam: {
          fnt: "JEAN",
          gnt: "Michel"
        },
        dob: "1978-01-01",
        v: []
      }
    end
    
    subject { dependencies[:procedures][:to_hcert] }

    it "generates an evc as a string" do
      result = subject.call(hcert_data:)
      expect(result).to be_a(String)
    end

    it "can be decoded" do
      result = subject.call(hcert_data:)
      expect { Base45.decode(result) }.not_to raise_error
    end

    it "can be uncompressed" do
      result = subject.call(hcert_data:)
      compressed = Base45.decode(result)
      expect { Zlib::Inflate.inflate(compressed) }.not_to raise_error
    end

    it "can be cbord decoded" do
      result = subject.call(hcert_data:)
      compressed = Base45.decode(result)
      uncompressed = Zlib::Inflate.inflate(compressed)
      expect { CBOR.decode(uncompressed) }.not_to raise_error
    end

    it "respect the cwt contract" do
      result = subject.call(hcert_data:)
      compressed = Base45.decode(result)
      uncompressed = Zlib::Inflate.inflate(compressed)
      cwt = CBOR.decode(uncompressed)
      expect(cwt.to_h).to include({ tag: 18, value: Array })
    end

    it "as valid value" do
      result = subject.call(hcert_data:)
      compressed = Base45.decode(result)
      uncompressed = Zlib::Inflate.inflate(compressed)
      cwt = CBOR.decode(uncompressed)
      protected, unprotected, claims, signature = cwt[:value]
      expect(protected).to be_a(String)
      expect(unprotected).to include({ 4=>"AsymmetricECDSA256" })
      expect(claims).to be_a(String)
      expect(signature).to be_a(String)
    end

    it "as a valid claims" do
      result = subject.call(hcert_data:)
      compressed = Base45.decode(result)
      uncompressed = Zlib::Inflate.inflate(compressed)
      cwt = CBOR.decode(uncompressed)
      _protected, _unprotected, claims, _signature = cwt[:value]
      decoded_claims = CBOR.decode(claims, symbolize_keys: true)
      expect(decoded_claims).to include({ -260 => hcert_data })
    end
  end
end