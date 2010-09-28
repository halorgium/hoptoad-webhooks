require 'net/imap'
require 'net/imap/date'
require 'net/imap/idle'

module Psychomail
  def self.create(host, port, username, password, mailbox, &block)
    Agent.new(host, port, username, password, mailbox, &block)
  end
end

require 'psychomail/agent'
require 'psychomail/email'
require 'psychomail/hacks'
