module Web
  class JwksServer
    include Web::Helper

    def initialize(pub_key_store:, logger:)
      @pub_key_store = pub_key_store
    end
    def call(_)
      json_response(code: 200, body: @pub_key_store.all.map(&:export).to_json)
    end
  end
end