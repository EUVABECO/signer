module Cose
  RSpec.describe Signer do
    let(:priv_key_store) { Utils::KeyStore.new }
    let(:pub_key_store) { Utils::KeyStore.new(pub: true) }
    let(:signer) { Signer.new(priv_key_store:, pub_key_store:) }

    before do
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
      pub_key_store.add(
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

    describe '#sign' do
      it 'should return a valid signature' do
        signature = signer.sign("Hello", 'AsymmetricECDSA256')

        expect(signer.verify(msg: "Hello", sig: signature, kid: 'AsymmetricECDSA256')).to be_truthy
      end
    end

    describe '#hex_signature' do
      it 'should return a hexadecimal string of size 128' do
        expect(signer.hex_signature("Hello", 'AsymmetricECDSA256').size).to eq(128)
      end
    end
  end
end
