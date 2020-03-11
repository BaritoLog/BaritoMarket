module BaritoBlueprint
  class Provisioner
    include Wisper::Publisher

    DEFAULTS = {
      timeout: 5.minutes,
      check_interval: 5.seconds
    }

    def initialize(infrastructure, executor, opts = {})
      @infrastructure = infrastructure
      @infrastructure_manifests = infrastructure.manifests
      @executor = executor
      @defaults = {
        timeout: opts[:timeout] || DEFAULTS[:timeout],
        check_interval: opts[:check_interval] || DEFAULTS[:check_interval],
      }
    end

    def bulk_apply!
      Processor.produce_log(
        @infrastructure,
        "Infrastructure:#{@infrastructure.name}",
        "Deployment Bulk Apply started")
      @infrastructure.update_provisioning_status('DEPLOYMENT_STARTED')

      # Execute reprovisioning
      res = @executor.bulk_apply!(@infrastructure_manifests)
      Processor.produce_log(
        @infrastructure,
        "Infrastructure:#{@infrastructure.name}",
        "#{res}")

      if res['success'] == true
        Processor.produce_log(
          @infrastructure,
          "Infrastructure:#{@infrastructure.name}",
          "Deployment Bulk Apply finished")
        @infrastructure.update_provisioning_status('DEPLOYMENT_FINISHED')
        return true
      else
        Processor.produce_log(
          @infrastructure,
          "Infrastructure:#{@infrastructure.name}",
          "Deployment Bulk Apply error",
          "#{res['error']}")
        @infrastructure.update_provisioning_status('DEPLOYMENT_ERROR')
        return false
      end 
    end
  end
end
