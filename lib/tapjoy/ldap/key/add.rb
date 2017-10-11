module Tapjoy
  module LDAP
    module Key
      # Add user key to user profile
      class Add
        # Add key to LDAP
        def add
          filter_users.each  do |result|
            confirm_ldap_schema(result)
            keys.each do |key|
              puts Tapjoy::LDAP.client.add_attribute(result.dn, :sshPublicKey, key)
            end
          end
        end

        private
        def opts
          @opts ||= Trollop.options do
              # Set help message
              usage 'key add [options]'
              synopsis "\nThis command is for adding user keys to a given user's profile"

              opt :username, 'Specify username to add key to', type: :string,
                required: true
              opt :filename, 'File to load keys from', type: :string
          end
        end

        def keys
          @keys ||= Tapjoy::LDAP::Key.get_keys_from_commandline(opts[:filename] || nil)
        end

        def filter_users
          filter = Net::LDAP::Filter.eq('uid', opts[:user])
          results = Tapjoy::LDAP.client.search(attributes = ['*'], filter = filter)

          Tapjoy::LDAP::Key.verify_user(opts[:user], results)

          results
        end

        def confirm_ldap_schema(result)
          unless result.objectclass.include?('ldapPublicKey')
            puts 'LDAP Public Key Object Class not found.'
            abort 'Please ensure user was created correctly.'
          end
        end
      end
    end
  end
end
