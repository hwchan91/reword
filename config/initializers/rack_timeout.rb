if Rails.env.production?
  Rack::Timeout.service_timeout = 20  # seconds
end