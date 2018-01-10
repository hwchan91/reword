class DailyWorker < ActiveJob::Base

  def perform
    Rails.cache.delete('first_zen_today')
    Level.automated.destroy_all
    Level.generate_daily_zen
  end
end
