module Procedures
  class ToHcert
    def initialize(signer:, to_cwt:)
      @signer = signer
      @to_cwt = to_cwt
    end

    def call(hcert_data:, kid: nil, internal_call: false)
      internal_call(hcert_data:, kid:)
    end

    def internal_call(hcert_data:, kid: nil)
      Base45.encode(Zlib::Deflate.deflate(@to_cwt.internal_call(kid: kid, hcert_data:)))
    end
  end
end
