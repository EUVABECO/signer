# frozen_string_literal: true

module Web
  class App
    include Web::Helper
    ALLOWED_PATHS = ['/', ''].freeze

    def initialize(web_router:)
      @web_router = web_router
    end

    def call(env)
      path, verb = env.values_at('PATH_INFO', 'REQUEST_METHOD')
      return 200, {}, [{ error: 'This json rpc server only accept POST' }.to_json] if verb != 'POST'

      return 200, {}, [{ error: 'Only request on / are allowed' }.to_json] if !ALLOWED_PATHS.include?(path)
      id, params, method, _jsonrpc =
        JSON.parse(env['rack.input'].read, symbolize_names: true).values_at(:id, :params, :method, :jsonrpc)
      begin
        rpc_response(result: @web_router.call(method:).call(**params), id:)
      rescue Exception => e
        puts e.message
        puts e.backtrace
        json_response(code: 500, body: { error: e.message }.to_json)
      end
    end
  end
end
