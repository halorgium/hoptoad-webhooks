module HerokuKeepalive
  def self.run(base_dir)
    Thread.new {
      loop do
        Heroku::LastAccess.new(nil, "#{base_dir}/tmp").touch
        sleep 600
      end
    }
  end
end
