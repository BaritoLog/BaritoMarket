# noinspection RubyResolve
OpenTracing.global_tracer = Jaeger::Client.build(
  service_name: Figaro.env.JAEGER_SERVICE_NAME,
  reporter: Jaeger::Reporters::RemoteReporter.new(
    sender: Jaeger::HttpSender.new(
      url: Figaro.env.JAEGER_ENDPOINT,
      encoder: Jaeger::Encoders::ThriftEncoder.new(service_name: Figaro.env.JAEGER_SERVICE_NAME)
    ),
    flush_interval: 10
  ),
  injectors: {
    OpenTracing::FORMAT_RACK => [Jaeger::Injectors::B3RackCodec]
  },
  extractors: {
    OpenTracing::FORMAT_RACK => [Jaeger::Extractors::B3RackCodec]
  },
  sampler: Jaeger::Client::Samplers::RemoteControlled.new(
    service_name: Figaro.env.JAEGER_SERVICE_NAME,
    sampler: Jaeger::Samplers::Probabilistic.new(rate: 0.01),
    host: Figaro.env.JAEGER_SAMPLING_HOST,
    port: Figaro.env.JAEGER_SAMPLING_PORT
  )
)
