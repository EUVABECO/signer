module Procedures
  class ToJwtQrCode
    def initialize(to_jwt:)
      @to_jwt = to_jwt
    end

    def call(payload:, kid: nil, file_format: nil)
      case file_format
      when nil
        RQRCode::QRCode.new(@to_jwt.internal_call(payload:, kid:)).as_ansi
      when 'svg'
        RQRCode::QRCode.new(@to_jwt.internal_call(payload:, kid:)).as_svg
      when 'png'
        Base64.strict_encode64(RQRCode::QRCode.new(@to_jwt.internal_call(payload:, kid:)).as_png.to_s)
      end
    end
  end
end
