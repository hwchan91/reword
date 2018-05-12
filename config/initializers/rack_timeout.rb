if !Rails.env.development?
  Rack::Timeout.service_timeout = 20  # seconds
end
