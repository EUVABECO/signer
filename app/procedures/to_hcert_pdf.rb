module Procedures
  class ToHcertPdf
    def initialize(to_hcert:, md2pdf:, nuva:)
      @to_hcert = to_hcert
      @md2pdf = md2pdf
      @nuva = nuva
    end

    def call(hcert_data:, kid: nil)
      hcert = @to_hcert.internal_call(hcert_data:, kid:)
      qrcode =
        Base64.strict_encode64(
          RQRCode::QRCode.new(hcert).as_png(size: 300, border_modules: 0).to_s
        )
      dob = Date.parse(hcert_data[:dob])
      pdf_hcert_data = {
        **hcert_data,
        v:
          hcert_data[:v].map do |v|
            vaccine = @nuva.repositories.vaccines.all.find { |nuva_vaccine| nuva_vaccine.code == v[:mp] }
            { date: (dob + v[:a]), name: vaccine.name }
          end
      }
      Base64.strict_encode64(@md2pdf.call(hcert_data: pdf_hcert_data, qrcode:, hcert:))
    end
  end
end
