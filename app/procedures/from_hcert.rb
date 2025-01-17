module Procedures
  class FromHcert
    def initialize(signer:)
      @signer = signer
    end

    def call(hcert:)
      cwt = Base45
        .decode(hcert)
        .then do |ziped|
          Zlib::Inflate.inflate(ziped).then do |signed_cwt|
            Cose::SignedCwt.from_bin(signed_cwt)
          end
        end

        {
          **cwt.deconstruct_keys,
          signature: Base64.strict_encode64(cwt.signature),
          verified: @signer.verify_cwt(cwt)
        }
    end
  end
end
