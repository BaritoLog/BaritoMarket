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

    def batch!
      Processor.produce_log(
        @infrastructure,
        "Infrastructure:#{@infrastructure.name}",
        "Deployment Batch started")
      @infrastructure.update_provisioning_status('DEPLOYMENT_STARTED')

      # Execute reprovisioning
      res = @executor.batch!(@infrastructure_manifests)
      Processor.produce_log(
        @infrastructure,
        "Infrastructure:#{@infrastructure.name}",
        "#{res}")

      if res['success'] == true
        Processor.produce_log(
          @infrastructure,
          "Infrastructure:#{@infrastructure.name}",
          "Deployment Batch finished")
        @infrastructure.update_provisioning_status('DEPLOYMENT_FINISHED')
        return true
      else
        Processor.produce_log(
          @infrastructure,
          "Infrastructure:#{@infrastructure.name}",
          "Deployment Batch error",
          "#{res['error']}")
        @infrastructure.update_provisioning_status('DEPLOYMENT_ERROR')
        return false
      end 
    end

    def delete!
      Processor.produce_log(
        @infrastructure,
        "Infrastructure:#{@infrastructure.name}",
        "Deployment delete started")
      @infrastructure.update_provisioning_status('DELETE_STARTED')

      update_manifests_by_params!({desired_num_replicas: 0, min_available_replicas: 0})
      @infrastructure.reload
      
      res = @executor.batch!(@infrastructure.manifests)
      Processor.produce_log(
        @infrastructure,
        "Infrastructure:#{@infrastructure.name}",
        "#{res}")

      if res['success'] == true
        Processor.produce_log(
          @infrastructure,
          "Infrastructure:#{@infrastructure.name}",
          "Deployment deleted")
        @infrastructure.update_provisioning_status('DELETED')
        return true
      else
        Processor.produce_log(
          @infrastructure,
          "Infrastructure:#{@infrastructure.name}",
          "Deployment delete error",
          "#{res['error']}")
        @infrastructure.update_provisioning_status('DELETE_ERROR')
        return false
      end 
    end

    def update_manifests_by_params!(params)
      @infrastructure_manifests.each_with_index do |manifest, idx|
        params.each do |k,v|
          manifest["#{k}"] = v
        end
        @infrastructure.manifests[idx] = manifest
        @infrastructure.save
      end
    end
  end
end
