require_relative 'key/add'
require_relative 'key/remove'
require_relative 'key/show'
require_relative 'key/install'

module Tapjoy
  module LDAP
    # Entry point for all key subcommands
    module Key
      class << self
        SUB_COMMANDS = %w(add remove install list show)

        def commands
          Trollop::options do
            usage 'key [SUB_COMMAND] [options]'
            synopsis "\nThis object is used for user key management\nAvailable subcommands are: #{SUB_COMMANDS}"

            stop_on SUB_COMMANDS
          end

          cmd = ARGV.shift

          case cmd
          when 'add', 'remove', 'install', 'list', 'show'
            send(cmd) # call method with respective name
          else
            raise Tapjoy::LDAP::InvalidArgument
          end
        end

        def add
          key = Tapjoy::LDAP::Key::Add.new
          key.add
        end

        def remove
          key = Tapjoy::LDAP::Key::Remove.new
          key.remove
        end

        def install
          key = Tapjoy::LDAP::Key::Install.new
          key.install
        end

        def list
          Tapjoy::LDAP::Key.get_keys_from_ldap
        end

        def show
          key = Tapjoy::LDAP::Key::Show.new
          key.show
        end

        def get_keys_from_ldap

          key_results = {}
          filter = Net::LDAP::Filter.eq('sshPublicKey', '*')
          attributes = %w(uid sshPublicKey)
          results = Tapjoy::LDAP::client.search(attributes, filter)
          results.each {|result| key_results[result.uid[0]] = result.sshPublicKey}
          key_results
        end

        # Retrieve keys from file/stdin
        def get_keys_from_commandline(filename=nil)
          ARGV << filename unless filename.nil?
          return_keys = []

          ARGF.each do |line|
            return_keys << line.chomp!
          end
          ARGV << '-'  # close ARGF
          return_keys.each { |key| verify_key(key) }
          return_keys
        end

        def verify_key(key)
          unless key.start_with?('ssh')
            puts "Invalid key due to missing ssh key type:\n\n"
            puts "\t#{ key }\n\n"
            abort "Please verify your key and try again"
          end
        end

        def verify_user(user, results)
          # Make sure we return one, and only one user DN
          if results.size < 1
            puts "User (#{user}) not found."
            abort 'Please check the username and try again'
          elsif results.size > 1
            abort 'Multiple users found. Please narrow your search.'
          end
        end
      end
    end
  end
end
