@timer = Concurrent::TimerTask.new(execution_interval: ENV['ROUTINE_INTERVAL'] || 5,
                                   timeout_interval: ENV['ROUTINE_TIMEOUT'] || 5) do
  CountersService.sync
end

@timer.execute
