module Tapjoy
  module LDAP
    module Key
      # Install key on localhost
      class Install
        def install
          Tapjoy::LDAP::Key.get_keys_from_ldap.each do |user, values|
            directory = directory(user)
            FileUtils.mkdir_p(directory) unless File.exists?directory
            authorized_keys_file = "#{directory}/authorized_keys"
            keys = load_keys_from_file(authorized_keys_file)
            insert_keys(authorized_keys_file, keys, values)
          end
        end

        private
        def opts
          @opts ||= Trollop.options do
              # Set help message
              usage 'key install'
              synopsis "\nThis command is for adding keys to the appropriate authorized_keys file"

          end
        end

        def load_keys_from_file(authorized_keys_file)
          if File.exists?(authorized_keys_file)
            keys = File.read(authorized_keys_file)
          else
            keys = []
          end
        end

        def insert_keys(authorized_keys_file, keys, values)
          File.open(authorized_keys_file, 'a+') do |file|
            file.puts values.reject { |value| keys.include?(value) }
          end
        end

        def directory(user)
          File.join('etc', 'ssh', 'users', user)
        end
      end
    end
  end
end
