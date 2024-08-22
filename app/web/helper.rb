# frozen_string_literal: true

module Web
  module Helper
    HEADERS = { 'content-type' => 'application/json' }
    RPC_RESPONSE = { jsonrpc: :"2.0", result: nil, error: nil, id: nil }

    def json_response(code:, body: "")
      [code, HEADERS, [body]]
    end

    def rpc_response(result: nil, error: nil, id: nil)
      [200, HEADERS, [{ jsonrpc: :"2.0", result:, error:, id: }.compact.to_json]]
    end
  end
end
