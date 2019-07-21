class UpdateImageComponentTemplate < ActiveRecord::Migration[5.2]
  def up
    component_templates = ComponentTemplate.all

    component_templates.each do |ct|
      case ct.name
      when "consul"
        ct.update(image: 'lxd-consul-1.1.0-3')
      when "zookeeper"
        ct.update(image: 'lxd-zookeeper-3.4.12-1')
      when "kafka"
        ct.update(image: 'lxd-kafka-2.11-1')
      when "elasticsearch"
        ct.update(image: 'lxd-elasticsearch-6.4.1-1')
      when "barito-flow-producer"
        ct.update(image: 'lxd-barito-flow-producer-0.8.0-1')
      when "barito-flow-consumer"
        ct.update(image: 'lxd-barito-flow-consumer-0.8.0-1')
      when "kibana"
        ct.update(image: 'lxd-kibana-6.3.0-1')
      else
        ct.update(image: '18.04')
      end
    end
  end

  def down
    component_templates = ComponentTemplates.all
    component_templates.each do |ct|
      ct.update(
        image: "18.04",
      )
    end
  end
end
