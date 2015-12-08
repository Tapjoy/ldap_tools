require 'digest'
require 'securerandom'
module Tapjoy
  module LDAP
    module User
      # Create LDAP user
      class Create
        def opts
          @opts ||= Trollop::options do
            # Set help message
            usage 'user create [options]'
            synopsis "\nThis command is for creating new LDAP users"

            # Username is two arguments
            # Trollop will accept more, but we will only parse two later
            # TODO: support given names that include a space
            opt :user, "Specify user's first and last name", type: :strings, required: true

            # Groupname is a single string, for primary group setting
            opt :group, 'Specify name of primary group', type: :string, required: true
            opt :type, 'Specfy if this is a user or service account', type: :string, default: 'user'
          end
        end

        def uidnumber
          @uidnumber ||= Tapjoy::LDAP::client.get_max_id('user', opts[:type])
        end

        def gidnumber
          @gidnumber ||= Tapjoy::LDAP::Group.lookup_id(opts[:group])
        end

        def create
          # Check for errors
          Trollop::die :user, 'argument count must be two' if opts[:user].size != 2
          Trollop::die :type, "argument must be 'user' or 'service'" unless ['user', 'service'].include?opts[:type]

          puts Tapjoy::LDAP::client.add(dn, ldap_attr)
        end

        private
        def create_password
          # Super-Salt: bad for blood pressure, good for secure passwords
          # We can get away with this, since we're not planning on using passwords
          salt = SecureRandom.base64(32)
          password = SecureRandom.base64(64)
          password = Digest::SHA1.base64digest(password + salt)
        end

        def username
          @username ||= opts[:user].join('.').downcase
        end

        def ldap_attr
          @ldap_attr ||= {
            :uid           => username,
            :cn            => "#{opts[:user].join}",
            :objectclass   => ['top','posixAccount','shadowAccount','inetOrgPerson',
                               'organizationalPerson','person', 'ldapPublicKey'],
            :sn            => opts[:user][1],
            :givenname     => opts[:user][0],
            :homedirectory => "/home/#{ username }",
            :loginshell    => '/bin/bash',
            :mail          => "#{username}@tapjoy.com".downcase,
            :uidnumber     => uidnumber,
            :gidnumber     => gidnumber,
            :userpassword  => '{SSHA}' + create_password
          }
        end

        def dn
          @dn ||= "uid=#{username},ou=#{ou},#{Tapjoy::LDAP::client.basedn}"
        end

        def ou
          @ou ||= begin
            case opts[:type]
            when 'user'
              ou = 'People'
            when 'service'
              ou = Tapjoy::LDAP::client.service_ou
            else
              puts 'Unknown type'
            end
          end
        end
      end
    end
  end
end
