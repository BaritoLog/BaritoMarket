module Traceable
  def traced
    extracted_ctx = OpenTracing.extract(OpenTracing::FORMAT_RACK, request.headers)
    span_name = "#{trace_prefix}.#{params[:controller].gsub(/\//, '.')}.#{params[:action]}"
    span = OpenTracing.start_span(span_name, child_of: extracted_ctx)
    OpenTracing.scope_manager.activate(span)
    _scope = OpenTracing.scope_manager.active

    begin
      yield if block_given?
    rescue Exception => error
      raise error
    ensure
      span.finish
    end
  end
end
