class RejectAmbiguousRequests
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.env["HTTP_CONTENT_LENGTH"] && request.env["HTTP_TRANSFER_ENCODING"]
      return [400, { "Content-Type" => "text/plain" }, ["Ambiguous request headers"]]
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.insert_before Rack::Runtime, RejectAmbiguousRequests
