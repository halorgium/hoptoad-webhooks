module Psychomail
  class Agent
    def initialize(host, port, username, password, mbox)
      @host      = host
      @port      = port
      @username  = username
      @password  = password
      @mbox      = mbox
      @processed = 0
    end
    attr_reader :processed

    def run(&block)
      connect

      @imap.select(@mbox)

      loop do
        process(&block) until empty?
        idle
      end
    end

    def connect
      @imap = Net::IMAP.new(@host, @port, true)
      @imap.login(@username, @password)
    end

    def empty?
      @imap.status(@mbox, ["MESSAGES"])["MESSAGES"] == 0
    end

    def idle
      @imap.idle do |response|
        if response.class ==  Net::IMAP::UntaggedResponse
          if response.name == 'EXISTS'
            @imap.idle_done
          end
        end
      end
    end

    def process(&block)
      if messages = @imap.fetch(1..-1, ["UID", "ENVELOPE", "BODY[TEXT]"])
        messages.each do |message|
          email = Email.new(message)
          if yield email
            @processed += 1
            @imap.store(message.seqno, "+FLAGS", [:Deleted])
          end
        end
      end
      @imap.expunge
    end
  end
end
