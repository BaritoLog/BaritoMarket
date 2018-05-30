module ChefHelper
  class ElasticsearchRoleAttributesGenerator
    def initialize(opts = {})
      @role_name = opts[:role_name] || 'elasticsearch'
    end

    def generate
      {
        'java' => {
          'jdk_version' => '8'
        },
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
