module Initializers
  module Router
    def self.init(procedures:)
      router = Web::Router.new
      router.route(path: '/to_base45', method: 'POST', to: procedures[:to_base45])
      router.route(path: '/cwt', method: 'POST', to: procedures[:cwt])
      router.route(path: '/jwt', method: 'POST', to: procedures[:jwt])
      router.route(path: '/zip', method: 'POST', to: procedures[:zip])
    end
  end
end