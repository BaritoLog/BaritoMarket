InfrastructureLocation.create!(
  name: Figaro.env.default_infrastructure_location,
  destination_server: "https://kubernetes.default.svc",
  kibana_address_format: Figaro.env.KIBANA_ADDRESS_FORMAT,
  producer_address_format: Figaro.env.PRODUCER_ADDRESS_FORMAT,
  is_active: true
)
