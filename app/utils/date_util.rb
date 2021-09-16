module DateUtil
  def self.time_key
    Time.now.strftime('%Y-%m-%d %H:%M')
  end
end
