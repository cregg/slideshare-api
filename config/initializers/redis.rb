config = {:redis => Redis.new, :url => ENV['REDIS_URL'] || 'localhost:6379'}

$redis = Redis::Namespace.new("slideshare", config)