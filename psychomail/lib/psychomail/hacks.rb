require 'date'

module Psychomail
  module DateTimeHacks
    def httpdate
      t = dup.utc
      sprintf('%s, %02d %s %d %02d:%02d:%02d GMT',
        Time::RFC2822_DAY_NAME[t.wday],
        t.day, Time::RFC2822_MONTH_NAME[t.mon-1], t.year,
        t.hour, t.min, t.sec)
    end

    def utc
      to_s =~ /([-+])(\d\d:\d\d)$/
      sign, hours, mins = $~.to_a[1..3]
      diff = hours.to_i * 60 + mins.to_i
      signed_diff = sign == "-" ? -diff : diff
      shifted = self - (signed_diff / 1440.0)
      self.class.parse(shifted.strftime("%Y-%m-%dT%H:%M:%S") + "+00:00")
    end
  end
end

class DateTime
  include Psychomail::DateTimeHacks
end
