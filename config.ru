require 'rubygems'
require 'bundler/setup'
Bundler.require

if defined?(Heroku)
  HerokuKeepalive.run(Dir.pwd)
end

def env_fetch(key, default = nil)
  ENV.fetch(key, default) || abort("No #{key.inspect} specified in the ENV: #{ENV.keys.inspect}")
end

host         = env_fetch("hoptoad_webhooks.imap.host")
port         = env_fetch("hoptoad_webhooks.imap.port", 993)
username     = env_fetch("hoptoad_webhooks.imap.username")
password     = env_fetch("hoptoad_webhooks.imap.password")
mbox         = env_fetch("hoptoad_webhooks.imap.mbox", "INBOX")
email        = env_fetch("hoptoad_webhooks.email")
account_name = env_fetch("hoptoad_webhooks.account_name")
hook_url     = env_fetch("hoptoad_webhooks.hook_url")

HoptoadWebhooks.setup(host, port, username, password, mbox, email, account_name, hook_url)
HoptoadWebhooks.run

use Rack::CommonLogger
run HoptoadWebhooks::App
