require 'net/ldap'
require 'yaml'
require 'optimist'
require 'memoist'
require 'pry'
require_relative 'ldap/cli'
require_relative 'ldap/base'
require_relative 'ldap/key'
require_relative 'ldap/audit'
require_relative 'ldap/version'
require_relative 'ldap/errors'


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
        Optimist.educate
      end
    end
  end
end
