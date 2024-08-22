# frozen_string_literal: true
module Web
  class Router
    def initialize(hash = {})
      @hash = hash
    end

    def route(method:, to:)
      @hash[method] = to
      self
    end

    def call(method:)
      @hash[method]
    end
  end
end
