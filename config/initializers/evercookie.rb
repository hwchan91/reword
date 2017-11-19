Evercookie.setup do |config|
  # path for evercookie controller
  config.namespace = :evercookie

  # name of javascript class to be used for evercookie
  config.js_class = :evercookie

  # hash name base for session storage variables
  config.hash_name = :evercookie

  # cookie name for cache storage
  config.cookie_cache = :evercookie_cache

  # cookie name for png storage
  config.cookie_png = :evercookie_png

  # cookie name for etag storage
  config.cookie_etag = :evercookie_etag

  # enable/disable http basic auth (leads to problems if your app uses http basic auth)
  config.basic_auth = true
end