require 'digest'
require 'securerandom'

module Tapjoy
  module LDAP
    class User

      # Instantiate class
      def initialize
        command = ARGV.shift

        case command
        when 'create', 'delete'
          send(command)
        else
          raise Tapjoy::LDAP::InvalidArgument
        end
      end

      private
      # Create user in LDAP
      def create
        opts = Trollop::options do
          # Set help message
          usage "user create [options]"

          # Username is two arguments
          # Trollop will accept more, but we will only parse two later
          # TODO: support given names that include a space
          opt(:user, "Specify user's first and last name",
              :type => :strings, :required => true)

          # Groupname is a single string, for primary group setting
          opt(:group, 'Specify name of primary group', :type => :string, :required => true)

          opt(:type, 'Specfy if this is a user or service account',
              :type => :string, :default => 'user')
        end

        Trollop::die :user, 'argument count must be two' if opts[:user].size != 2
        Trollop::die :type, "argument must be 'user' or 'service'" unless ['user', 'service'].include?opts[:type]

        fname, lname = opts[:user]

        # format username
        username = "#{fname}.#{lname}"
        username = username.downcase
        group = Tapjoy::LDAP::Group.new

        uidnumber = Tapjoy::LDAP::client.get_max_id('user', opts[:type])
        gidnumber = group.lookup_id(opts[:group])

        case opts[:type]
        when 'user'
          ou = 'People'
        when 'service'
          ou = Tapjoy::LDAP::client.service_ou
        else
          puts 'Unknown type'
        end

        # Super-Salt: bad for blood pressure, good for secure passwords
        # We can get away with this, since we're not planning on using passwords
        salt = SecureRandom.base64(32)
        password = SecureRandom.base64(64)
        password = Digest::SHA1.base64digest(password + salt)
        dn = "uid=#{ username },ou=People,#{ Tapjoy::LDAP::client.basedn }"
        ldap_attr = {
          :uid           => username,
          :cn            => "#{ fname } #{ lname }",
          :objectclass   => ['top','posixAccount','shadowAccount','inetOrgPerson',
                             'organizationalPerson','person', 'ldapPublicKey'],
          :sn            => lname,
          :givenname     => fname,
          :homedirectory => "/home/#{ username }",
          :loginshell    => '/bin/bash',
          :mail          => "#{fname}.#{lname}@tapjoy.com".downcase,
          :uidnumber     => uidnumber,
          :gidnumber     => gidnumber,
          :userpassword  => '{SSHA}' + password
        }
        puts Tapjoy::LDAP::client.add(dn, ldap_attr)

      end

      # Delete user from LDAP
      def delete
        options = {}
        prompt = '>'

        opts = Trollop::options do
          # Set help message
          usage "user delete [options]"

          opt(:user, 'Specify username', :type => :string, :required => true)
          opt(:force, 'Force delete')
        end

        dn = "uid=#{ opts[:user] },ou=People,#{ Tapjoy::LDAP::client.basedn }"
        unless opts[:force]
          puts "Confirm that you want to delete user: #{ opts[:user] }"
          print prompt
          confirm = STDIN.gets.chomp().downcase
          unless confirm.eql?('y') || confirm.eql?('yes')
            abort("Deletion of #{ opts[:user] } aborted")
          end
        end

        puts Tapjoy::LDAP::client.delete(dn)
      end

    end
  end
end
