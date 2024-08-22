module Procedures
  class ToZip
    def call(data: nil, binary_data: nil)
      data = binary_data ? Base64.decode64(binary_data) : data

      Base64.strict_encode64(Zlib::Deflate.deflate(data))
    end
  end
end