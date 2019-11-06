module Tapjoy
  module LDAP
    module Key
      # Show all of a user's keys
      class Show
        def show
          username = opts[:username]
          keys = Tapjoy::LDAP::Key.get_keys_from_ldap[username]
          puts "No keys found for #{opts[:username]}" if keys.nil?
          puts keys
        end

        private
        def opts
          @opts ||= Optimist.options do
              # Set help message
              usage 'key show [options]'
              synopsis "\nThis command is for showing a specific user's SSH keys"

              opt :username, 'Specify username', type: :string, required: true
          end
        end

      end
    end
  end
end
