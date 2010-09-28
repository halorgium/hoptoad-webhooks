module Psychomail
  class Email
    def initialize(data)
      @data = data
    end

    def to_hash
      { "message_id" => message_id,
        "from" => from,
        "subject" => subject,
        "addresses" => addresses,
        "body" => body,
      }.to_json
    end

    def envelope
      @data.attr['ENVELOPE']
    end

    def message_id
      @data.attr['UID']
    end

    def subject
      @subject ||= utf8_fix(envelope.subject)
    end

    def body
      @data.attr['BODY[TEXT]']
    end

    def from
      @from ||= utf8_fix(envelope.from[0].name)
    end

    def addresses
      addresses = []
      %w[ to cc bcc ].each do |key|
        (envelope.send(key) || []).map do |n|
          address = "#{n.mailbox}@#{n.host}"
          addresses << utf8_fix(address)
        end
      end
      addresses
    end

    def date
      @date ||= DateTime.parse(envelope.date).utc
    end

    def diff
      DateTime.now.utc - date
    end

    def interval
      seconds = diff * 86400
      days, r = seconds.divmod(86400)
      hours, r = r.divmod(3600)
      minutes, seconds = r.divmod(60)

      data = [days, hours, minutes, seconds.ceil].zip %w[ days hours minutes seconds ]
      data.reject! do |(amount,unit)|
        amount == 0
      end

      pieces = data.map do |(amount,unit)|
        if amount == 1
          unit = unit[0..-1]
        end

        "#{amount} #{unit}"
      end

      "#{pieces.join(', ')} ago"
    end

    def utf8_fix(raw_content)
      content = (raw_content || "").dup
      replaces = []
      content.scan(/=\?UTF-8\?[BQ]\?([^?]*)\?=/) do |match|
        replaces << $~.to_a
      end
      replaces.each do |(s,r)|
        v = case s
        when /^=\?UTF-8\?B\?.*\?=$/
          Base64.decode64(r)
        when /^=\?UTF-8\?Q\?(.*)\?=$/
          r.gsub('=20', ' ')
        else
          r
        end
        content.sub!(s, v)
      end
      content
    end
  end
end
