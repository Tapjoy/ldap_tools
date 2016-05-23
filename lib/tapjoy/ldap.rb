require 'net/ldap'
require 'yaml'
require 'trollop'
require_relative 'ldap/cli'
require_relative 'ldap/base'
require_relative 'ldap/group'
require_relative 'ldap/key'
require_relative 'ldap/audit'
require_relative 'ldap/version'

module Tapjoy
  module LDAP

    def self.client
      @@client ||= Tapjoy::LDAP::Base.new
    end

    class InvalidArgument < ArgumentError
      def initialize
        Trollop::educate
      end
    end
  end
end
