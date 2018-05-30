module ChefHelper
  class BaritoFlowConsumerRoleAttributesGenerator
    def initialize(opts = {})
      @role_name = opts[:role_name] || 'barito-flow-consumer'
    end

    def generate
      {
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
