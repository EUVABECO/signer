module Procedures
  class ToHcertQrCode
    def initialize(to_hcert:)
      @to_hcert = to_hcert
    end

    def call(hcert_data:, kid: nil, file_format: nil)
      case file_format
      when nil
        RQRCode::QRCode.new(@to_hcert.internal_call(hcert_data:, kid:)).as_ansi.to_s
      when 'svg'
        RQRCode::QRCode.new(@to_hcert.internal_call(hcert_data:, kid:)).as_svg
      when 'png'
        Base64.strict_encode64(RQRCode::QRCode.new(@to_hcert.internal_call(hcert_data:, kid:)).as_png(size: 300, border_modules: 0).to_s)
      end
    end
  end
end

