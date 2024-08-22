module Procedures
  class Pipeline
    def initialize(router:)
      @router = router
    end

    def call(pipeline:, params:)
      pipeline.reduce(params) do |result, procedure|
        method = @router.call(method: procedure[:method])
        method.call(**{procedure[:param].to_sym => result})
      end
    end
  end
end
