require 'net/ldap'
require 'yaml'
require 'trollop'
require 'memoist'
require_relative 'ldap/cli'
require_relative 'ldap/base'
require_relative 'ldap/key'
require_relative 'ldap/version'


module Tapjoy
  module LDAP
    class << self
      attr_reader :client
      extend Memoist

      def client
        Tapjoy::LDAP::Base.new
      end
      memoize :client
    end

    class InvalidArgument < ArgumentError
      def initialize
        Trollop.educate
      end
    end
  end
end
