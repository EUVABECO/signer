module Utils
  class KeyStore
    def initialize(pub: false)
      @pub = pub
      @keys = {}
    end

    def add(jwk_key)
      # raise 'Wrong store' if @pub && jwk_key.private?

      @keys[jwk_key[:kid]] = jwk_key
    end

    def get(kid)
      @keys[kid]
    end

    def current_key
      if @keys.size == 1
        @keys.values.first
      else
        raise 'Not implemented yet'
      end
    end

    def all
      return [] if !@pub
      @keys.values
    end
  end
end
