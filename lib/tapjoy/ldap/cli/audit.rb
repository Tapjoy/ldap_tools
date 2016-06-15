require_relative 'audit/by_user'
require_relative 'audit/by_group'
require_relative '../api/audit'
module Tapjoy::LDAP::CLI
  # CLI commands around auditing
  module Audit
    class << self
      SUB_COMMANDS = %w(by_user by_group raw)

      def commands
        Trollop.options do
          usage 'user [SUB_COMMAND] [options]'
          synopsis "\nThis object is used for auditing LDAP permissions\nAvailable subcommands are: #{SUB_COMMANDS}"

          stop_on SUB_COMMANDS
        end

        cmd = ARGV.shift

        case cmd
        when 'by_user', 'by_group', 'raw'
          send(cmd) # call method with respective name
        else
          raise Tapjoy::LDAP::InvalidArgument
        end
      end

      def by_group
        audit = Tapjoy::LDAP::CLI::Audit::ByGroup.new
        audit.by_group
      end

      def by_user
        audit = Tapjoy::LDAP::CLI::Audit::ByUser.new
        audit.by_user
      end

      def raw
        puts Tapjoy::LDAP::API::Audit.index
      end

      # Clean output of hashes
      def print_hash(header_string, object_hash)
        puts header_string
        puts "=" * header_string.length
        object_hash.each_pair do |key, values|
          next if values.empty?
          puts "- #{key}"
          values.each { |value| puts "  - #{value}" }
        end
      end
    end
  end
end
