require "rack/client"
require "json"
require "sinatra/base"

module HoptoadWebhooks
  class App < Sinatra::Base
    get "/emails" do
      content_type :text
      worker = HoptoadWebhooks.worker

      <<-EOT
             Emails processed: #{worker.processed_emails}
Emails successfully delivered: #{worker.succeeded_emails}
   Emails failed to delivered: #{worker.failed_emails}

Errors:
#{worker.failures.join("\n")}
        EOT
    end
  end

  def self.setup(host, port, username, password, mbox, email, account_name, hook_url)
    @host         = host
    @port         = port
    @username     = username
    @password     = password
    @mbox         = mbox
    @email        = email
    @account_name = account_name
    @hook_url     = hook_url
  end

  def self.worker
    @worker ||= Worker.new(@host, @port, @username, @password, @mbox, @email, @account_name, @hook_url)
  end

  def self.run
    worker.run
  end
end

require "hoptoad_webhooks/worker"
require "hoptoad_webhooks/error"
