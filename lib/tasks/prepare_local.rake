desc 'Prepare local env'
task :prepare_local => [:environment] do
  Group.create!(name: 'Dummy Group', receiver_host: 'localhost', zookeeper_hosts: 'localhost', kafka_broker_hosts: 'localhost', kafka_topic_partition: 10)
  Store.create!(name: 'Dummy Store', elasticsearch_host: 'localhost', kibana_host: 'localhost')
  Forwarder.create!(name: 'Dummy Forwarder', host: 'localhost', kafka_topics: 'kafka-dummy-topic')
  puts 'Done'
end