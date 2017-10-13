module Tapjoy
  module LDAP
    module Key
      # Remove a user key from user profile
      class Remove
        # Remove key from LDAP
        def remove
          keys  # Get keys first
          Tapjoy::LDAP::Key.verify_user(opts[:username], results)

          confirm unless opts[:force]
          Tapjoy::LDAP.client.replace_attribute(
            @user_dn, :sshPublicKey, keep_keys)
        end

        private
        def opts
          @opts ||= Trollop.options do
            # Set help message
            usage 'key remove [options]'
            synopsis "\nThis command is for removing a user's SSH key(s)"

            opt :username, 'Specify username to delete key from', type: :string,
                required: true
            opt :filename, 'File to load key deletion list from', type: :string
            opt :force, 'Force delete', short: '-F'
          end
        end

        def keys
          @keys ||= Tapjoy::LDAP::Key.get_keys_from_commandline(opts[:filename])
        end

        def filter
          @filter ||= Net::LDAP::Filter.eq('uid', opts[:user])
        end

        def results
          @results ||= Tapjoy::LDAP.client.search(['sshPublicKey'], filter)
        end

        def current_keys
          @current_keys ||= begin
            current_keys_array = []
            results.each do |result|
              @user_dn = result.dn
              current_keys_array = result.sshPublicKey
            end

            current_keys_array
          end
        end

        def keep_keys
          @keep_keys ||= current_keys.flatten - keys.flatten
        end

        def delete_keys
          @delete_keys ||= current_keys & keys
        end

        def keys_not_found
          @keys_not_found ||= keys - current_keys
        end

        def confirm
          puts 'Please confirm the following operations:'
          puts "Keep these keys:\n\n"
          print "\t #{ keep_keys }\n\n"
          puts "Delete these keys:\n\n"
          print "\t #{ delete_keys }\n\n"
          puts "Ignore these keys (not found in LDAP for #{ opts[:user]}):\n\n"
          print "\t #{ keys_not_found }\n\n"
          get_confirmation
        end

        def get_confirmation
          print '>'
          confirm = STDIN.gets.chomp.downcase
          abort('Deletion of key aborted') unless confirm.start_with?('y')
        end
      end
    end
  end
end
