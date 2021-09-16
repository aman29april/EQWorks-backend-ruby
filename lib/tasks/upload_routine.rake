namespace :upload_routine do
  desc 'Sync counters to storage'
  task :sync_at_5_sec do
    Concurrent::TimerTask.new(execution_interval: 5, timeout_interval: 5) do
      CountersService.sync
    end
  end
end
