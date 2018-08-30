module BaritoBlueprint
  class Provisioner
    DEFAULTS = {
      timeout: 5.minutes,
      check_interval: 5.seconds
    }

    def initialize(infrastructure, executor, opts = {})
      @infrastructure = infrastructure
      @infrastructure_components = @infrastructure.infrastructure_components
      @executor = executor
      @defaults = {
        timeout: opts[:timeout] || DEFAULTS[:timeout],
        check_interval: opts[:check_interval] || DEFAULTS[:check_interval],
      }
    end

    def provision_instances!
      Processor.produce_log(@infrastructure, 'Provisioning started')
      @infrastructure.update_provisioning_status('PROVISIONING_STARTED')

      @infrastructure_components.each do |component|
        success = provision_instance!(component)
        unless success
          Processor.produce_log(@infrastructure, 'Provisioning error')
          @infrastructure.update_provisioning_status('PROVISIONING_ERROR')
          return false
        end
      end

      Processor.produce_log(@infrastructure, 'Provisioning finished')
      @infrastructure.update_provisioning_status('PROVISIONING_FINISHED')
      return true
    end

    def provision_instance!(component)
      Processor.produce_log(
        @infrastructure,
        "InfrastructureComponent:#{component.id}",
        "Provisioning #{component.hostname} started")
      component.update_status('PROVISIONING_STARTED')

      # Execute provisioning
      res = @executor.provision!(component.hostname)
      Processor.produce_log(
        @infrastructure,
        "InfrastructureComponent:#{component.id}",
        "#{res}")

      if res['success'] == true
        Processor.produce_log(
          @infrastructure,
          "InfrastructureComponent:#{component.id}",
          "Provisioning #{component.hostname} finished")
        component.update_status('PROVISIONING_FINISHED')
        return true
      else
        Processor.produce_log(
          @infrastructure,
          "InfrastructureComponent:#{component.id}",
          "Provisioning #{component.hostname} error",
          "#{res['error']}")
        component.update_status('PROVISIONING_ERROR', res['error'].to_s)
        return false
      end
    end

    def reschedule_instance!(component)
      Processor.produce_log(
        @infrastructure,
        "InfrastructureComponent:#{component.id}",
        "Provisioning #{component.hostname} started")
      component.update_status('PROVISIONING_STARTED')

      # Execute rescheduling
      res = @executor.reschedule!(component.hostname)
      Processor.produce_log(
        @infrastructure,
        "InfrastructureComponent:#{component.id}",
        "#{res}")

      if res['success'] == true
        Processor.produce_log(
          @infrastructure,
          "InfrastructureComponent:#{component.id}",
          "Provisioning #{component.hostname} finished")
        component.update_status('PROVISIONING_FINISHED')
        return true
      else
        Processor.produce_log(
          @infrastructure,
          "InfrastructureComponent:#{component.id}",
          "Provisioning #{component.hostname} error",
          "#{res['error']}")
        component.update_status('PROVISIONING_ERROR', res['error'].to_s)
        return false
      end
    end

    def check_and_update_instances
      @infrastructure.update_provisioning_status('PROVISIONING_CHECK_STARTED')

      success = valid_instances?(@infrastructure_components)
      start_time = DateTime.current
      while !success &&
        DateTime.current <= start_time + @defaults[:timeout]

        sleep(@defaults[:check_interval])
        @infrastructure_components.each do |component|
          unless valid_instance?(component)
            component.update_status('PROVISIONING_CHECK_STARTED')
            check_success, attrs = check_instance(component)
            component.update(ipaddress: attrs[:ipaddress]) if check_success
          end
        end

        success = valid_instances?(@infrastructure_components)
      end

      @infrastructure_components.each do |component|
        check_success, attrs = check_instance(component)
        if check_success
          component.update_status('PROVISIONING_CHECK_SUCCEED')
        else
          component.update_status('PROVISIONING_CHECK_FAILED', attrs['error'])
        end
      end

      if success
        @infrastructure.
          update_provisioning_status('PROVISIONING_CHECK_SUCCEED')
        return true
      else
        @infrastructure.update_provisioning_status('PROVISIONING_CHECK_FAILED')
        return false
      end
    end

    def check_instance(component)
      res = @executor.show_container(component.hostname)
      ipaddress = res.dig('data', 'ipaddress')
      return false, error: res['error'].to_s unless ipaddress
      return true, ipaddress: ipaddress
    end

    def valid_instances?(components)
      components.all?{ |component| valid_instance?(component)}
    end

    def valid_instance?(component)
      return false unless component.ipaddress
      return true
    end
  end
end
