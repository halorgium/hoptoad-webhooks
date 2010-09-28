module HoptoadWebhooks
  class Error
    def self.process(account_name, email)
      new(account_name, email)
    end

    def initialize(account_name, email)
      @account_name = account_name
      @email        = email
    end
    attr_reader :account_name

    def to_hash
      {
        :account_name => account_name,
        :app_name     => app_name,
        :env_name     => env_name,
        :message      => message,
        :url          => url
      }
    end

    def pretty_message
      "[HOPTOAD] App #{app_name} (#{env_name}) errored: #{url} -- #{message}"
    end

    def app_name
      match_data[1]
    end

    def env_name
      match_data[2]
    end

    def message
      match_data[3]
    end

    def url
      urls = []
      @email.body.scan(%r{((http|https)://[^\s]+)}) do |(url,scheme)|
        if url =~ /^http:\/\/#{@account_name}\.hoptoadapp\.com\/errors\/\d+$/
          urls << url
        end
      end
      urls.first || raise("Could not find a hoptoad url: #{@email.inspect}")
    end

    def match_data
      @email.subject.match(/^\[([^\]]*)\] ([^:]+): (.*)$/) || raise("Not a hoptoad message: #{@email.inspect}")
    end
  end
end
