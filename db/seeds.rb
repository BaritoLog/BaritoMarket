# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#LogTemplate
LogTemplate.destroy_all

#Small TPS
LogTemplate.create(
    name: 'Small',
    tps_limit: 100,
    zookeeper_instances: 2,
    kafka_instances: 2,
    es_instances: 2,
    consul_instances: 1,
    yggdrasil_instances: 1,
    kibana_instances: 1,
)

#Medium TPS
LogTemplate.create(
    name: 'Medium',
    tps_limit: 500,
    zookeeper_instances: 4,
    kafka_instances: 4,
    es_instances: 4,
    consul_instances: 1,
    yggdrasil_instances: 1,
    kibana_instances: 1,
)

#Large TPS
LogTemplate.create(
    name: 'Large',
    tps_limit: 1000,
    zookeeper_instances: 8,
    kafka_instances: 8,
    es_instances: 8,
    consul_instances: 1,
    yggdrasil_instances: 1,
    kibana_instances: 1,
)

#ApplicationGroup
AppGroup.destroy_all
AppGroup.create([
    {name: 'Mobility'},
    {name: 'Food'},
    {name: 'Logistics'},
    {name: 'Payments'},
    {name: 'Operations'},
])
