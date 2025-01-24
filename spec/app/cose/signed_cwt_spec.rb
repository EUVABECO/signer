module Cose
  RSpec.describe SignedCwt do
    # https://www.rfc-editor.org/rfc/rfc8392.html#appendix-A.2.3
    let(:hex_cwt) { "d28443a10126a104524173796d6d657472696345434453413235365850a70175636f61703a2f2f61732e6578616d706c652e636f6d02656572696b77037818636f61703a2f2f6c696768742e6578616d706c652e636f6d041a5612aeb0051a5610d9f0061a5610d9f007420b7158405427c1ff28d23fbad1f29c4c7c6a555e601d6fa29f9179bc3d7438bacaca5acd08c8d4d4f96131680c429a01f85951ecee743a52b9b63632c57209120e1c9e30" }

    let(:priv_key_store) { Utils::KeyStore.new }
    let(:pub_key_store) { Utils::KeyStore.new(pub: true) }
    let(:signer) { Signer.new(priv_key_store:, pub_key_store:) }
    let(:key) {
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
    }

    before do
      priv_key_store.add(key)
      pub_key_store.add(key)
    end

    subject { SignedCwt.from_hex(hex_cwt) }

    it 'should return a valid CWT' do
      expect { subject }.not_to raise_error
      expect(subject).to be_a(SignedCwt)
    end

    it 'should parse the claim set' do
      claims = subject.claims
      expect(claims).to be_a(SignedCwt::Claims)
      expect(claims.iss).to eq('coap://as.example.com')
      expect(claims.sub).to eq('erikw')
      expect(claims.aud).to eq('coap://light.example.com')
      expect(claims.exp).to eq(1444064944)
      expect(claims.nbf).to eq(1443944944)
      expect(claims.iat).to eq(1443944944)
      expect(claims.cti.unpack1("H*")).to eq('0b71')
    end

    context '#signature_data' do
      # See https://github.com/cose-wg/Examples/blob/master/CWT/A_3.json
      let(:valida_data) { '846A5369676E61747572653143A10126405850A70175636F61703A2F2F61732E6578616D706C652E636F6D02656572696B77037818636F61703A2F2F6C696768742E6578616D706C652E636F6D041A5612AEB0051A5610D9F0061A5610D9F007420B71'.encode('ASCII-8BIT') }

      it 'should return the computed signature data' do
        result        = subject.signature_data
        parsed_result = CBOR.decode(result)
        context_result, protected_result, external_data_result, payload_result = parsed_result

        expected_data  = CBOR.decode([valida_data].pack('H*'))
        expected_context, expected_protected, expected_external_data, expected_payload = expected_data
        
        expect(context_result).to eq(expected_context)
        expect(CBOR.decode(protected_result)).to eq(CBOR.decode(expected_protected))
        expect(external_data_result).to eq(expected_external_data)
        expect(CBOR.decode(payload_result)).to eq(CBOR.decode(expected_payload))
      end
    end

    it 'parse the signature' do
      expect(subject.hex_signature).to eq('5427c1ff28d23fbad1f29c4c7c6a555e601d6fa29f9179bc3d7438bacaca5acd08c8d4d4f96131680c429a01f85951ecee743a52b9b63632c57209120e1c9e30')
    end
  end
end