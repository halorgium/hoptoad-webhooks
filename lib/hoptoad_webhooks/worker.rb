module HoptoadWebhooks
  class Worker
    def initialize(host, port, username, password, mbox, email, account_name, hook_url)
      @host         = host
      @port         = port
      @username     = username
      @password     = password
      @mbox         = mbox
      @email        = email
      @account_name = account_name
      @hook_url     = hook_url
      @failures     = []
      @succeeded    = 0
      @failed       = 0
    end
    attr_reader :failures, :succeeded, :failed

    def run
      Thread.new {
        begin
          psychomail.run do |email|
            handle(email)
          end
        rescue Exception
          add_exception($!)
        end
      }
    end

    def psychomail
      @psychomail ||= Psychomail.create(@host, @port, @username, @password, @mbox)
    end

    def handle(email)
      if email.addresses.include?(@email)
        error = Error.process(@account_name, email)
        data = {
          :error   => error.to_hash,
          :message => error.pretty_message
        }

        response = Rack::Client.post(@hook_url,
                                     {"HTTP_CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json"},
                                     data.to_json)
        if response.successful?
          @succeeded += 1
        else
          log "Failed for #{email.message_id}"
          log response.status
          log response.body
          log ""
          @failed += 1
        end
      else
        log "Not handling email: #{email.from.inspect}"
        log ""
        false
      end
    rescue Exception
      add_exception($!)
      @failed += 1
      true
    end

    def add_exception(exception)
      log "Exception at #{Time.now}: #{exception.class}: #{exception.message}"
      exception.backtrace.each do |line|
        log line
      end
      log ""
    end

    def log(message)
      @failures << message
      $stderr.puts message
    end

    def processed_emails
      psychomail.processed
    end

    def succeeded_emails
      @succeeded
    end

    def failed_emails
      @failed
    end
  end
end
