@timer = Concurrent::TimerTask.new(execution_interval: 5, timeout_interval: 5) do
  CountersService.sync
end
@timer.execute
