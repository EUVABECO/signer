
module Cose
  RSpec.describe SignedCwt do
    let(:protected) { { 1 => -7 } }
    let(:unprotected) { { 4 => 'AsymmetricECDSA256' } }

    # https://www.rfc-editor.org/rfc/rfc8392.html#appendix-A.2.3
    let(:hex_cwt) { "d28443a10126a104524173796d6d657472696345434453413235365850a70175636f61703a2f2f61732e6578616d706c652e636f6d02656572696b77037818636f61703a2f2f6c696768742e6578616d706c652e636f6d041a5612aeb0051a5610d9f0061a5610d9f007420b7158405427c1ff28d23fbad1f29c4c7c6a555e601d6fa29f9179bc3d7438bacaca5acd08c8d4d4f96131680c429a01f85951ecee743a52b9b63632c57209120e1c9e30" }

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

    it 'parse the signature' do
      expect(subject.hex_signature).to eq('5427c1ff28d23fbad1f29c4c7c6a555e601d6fa29f9179bc3d7438bacaca5acd08c8d4d4f96131680c429a01f85951ecee743a52b9b63632c57209120e1c9e30')
    end
  end
end