module Tapjoy
  module LDAP
    class Key

      # Instantiate class
      def initialize
        command = ARGV.shift

        case command
        when 'add', 'remove', 'install'
          send(command)
        else
          raise Tapjoy::LDAP::InvalidArgument
        end
      end

      ## Private methods start here ##
      private
      # Get key listing from LDAP
      def get_keys_from_ldap

        key_results = {}

        results = Tapjoy::LDAP::client.search(attributes = ['uid', 'sshPublicKey'],
                    filter = Net::LDAP::Filter.eq('sshPublicKey', '*'))

        results.each { |result| key_results[result.uid[0]] = result.sshPublicKey }

        return key_results
      end

      # Retrieve keys from file/stdin
      def get_keys_from_commandline(filename)
        return_keys = []

        if filename.eql?('-')
          STDIN.each do |str|
            return_keys << str.chomp!
          end
        else
          return_keys = Array(File.open(filename))
        end

        return_keys.each { |key| verify(key) }
        return return_keys
      end

      # Verify key format
      def verify(key)
        unless key.start_with?('ssh')
          puts "Invalid key due to missing ssh key type:\n\n"
          puts "\t#{ key }\n\n"
          abort "Please verify your key and try again"
        end
      end

      # Add key to LDAP
      def add
        opts = Trollop::options do
          # Set help message
          banner("#{$0} key add [options]")

          opt :user, 'Specify username to add key to', :type => :string,
              :required => true
          opt :filename, 'File to load keys from', :type => :string, :default => '-'
        end

        keys = get_keys_from_commandline(opts[:filename])

        filter = Net::LDAP::Filter.eq('uid', opts[:user])
        results = Tapjoy::LDAP::client.search(attributes = ['*'], filter = filter)

        # Make sure we return one, and only one user DN
        if results.size < 1
          abort 'user not found'
        elsif results.size > 1
          abort 'Multiple users found. Please narrow your search.'
        end

        results.each  do |result|
          unless result.objectclass.include?('ldapPublicKey')
            puts 'LDAP Public Key Object Class not found.'
            abort 'Please ensure user was created correctly.'
          end
          keys.each do |key|
            Tapjoy::LDAP::client.conn.add_attribute(result.dn, :sshPublicKey, key)
            puts Tapjoy::LDAP::client.return_result
          end
        end
      end

      # Remove key from LDAP
      def remove
        opts = Trollop::options do
          # Set help message
          banner("#{$0} key remove [options]")

          opt :user, 'Specify username to delete key from', :type => :string,
              :required => true
          opt :filename, 'File to load key deletion list from', :type => :string,
              :default => '-'
          opt(:force, 'Force delete')
        end

        keys = get_keys_from_commandline(opts[:filename])

        filter = Net::LDAP::Filter.eq('uid', opts[:user])
        attributes = ['sshPublicKey']
        old_array = []

        new_array = []

        results = Tapjoy::LDAP::client.search(attributes, filter)
        if results.size < 1
          puts "User (#{ opts[:user] }) not found."
          abort 'Please check the username and try again'
        elsif results.size > 1
          abort 'Multiple users found. Please narrow your search.'
        end

        results.each do |result|
          @user_dn = result.dn
          puts "User DN: #{ @user_dn }"
          old_array = result.sshPublicKey
        end

        keep_keys = old_array - keys
        delete_keys = old_array & keys
        keys_not_found = keys - old_array

        puts 'Please confirm the following operations:'
        puts "Keep these keys:\n\n"
        print "\t #{ keep_keys }\n\n"
        puts "Delete these keys:\n\n"
        print "\t #{ delete_keys }\n\n"
        puts "Ignore these keys (not found in LDAP for #{ opts[:user]}):\n\n"
        print "\t #{ keys_not_found }\n\n"

        # We have to create a new stdin here, because we already use stdin
        # in the get_keys_from_commandline method.
        fd = IO.sysopen('/dev/tty', 'w+')
        unless opts[:force]
          print '>'
          confirm = ''
          IO.open(fd, 'w+')  { |io| confirm = io.gets.chomp }
          unless confirm.eql?('y') || confirm.eql?('yes')
            abort("Deletion of #{ opts[:user] } aborted")
          end
        end

        Tapjoy::LDAP::client.conn.replace_attribute(@user_dn, :sshPublicKey, keep_keys)
      end

      # Install key on localhost
      def install
        opts = Trollop::options do
          # Set help message
          banner("#{$0} key install [options]")

          opt :debug, 'Enable debug/dry-run mode'
        end

        # Store results of query
        if opts[:debug]
          puts search_results
          exit 1
        end

        get_keys_from_ldap.each do |key,values|
          directory = "/etc/ssh/users/#{key}"
          FileUtils.mkdir_p(directory) unless File.exists?directory
          keypath = "#{directory}/authorized_keys"
          if File.exists?(keypath)
            keys = File.read(keypath)
          else
            keys = []
          end
          File.open(keypath, 'a+') do |file|
            file.puts values.reject { |value| keys.include?(value) }
          end
        end

        # TODO method to remove from authorized_keys any key that is not in LDAP
      end
    end
  end
end
