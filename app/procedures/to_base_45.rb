module Procedures
  class ToBase45
    def call(binary_data: nil, data: Base64.decode64(binary_data))
      Base45.encode(data)
    end
  end
end