require 'memoist'
module Tapjoy
  module LDAP
    module API
      module User
        class << self
          extend Memoist
          def create(fname, lname, type, group)
            # Properly capitalize names
            fname, lname = [fname, lname].map(&:titleize)
            
            puts Tapjoy::LDAP::client.add(
              distinguished_name(fname, lname, type),
              ldap_attr(fname, lname, type, group)
            )
          end

          private

          def username(fname, lname)
            [fname, lname].join('.').downcase
          end
          memoize :username

          def distinguished_name(fname, lname, type)
            %W(
              uid=#{username(fname, lname)}
              ou=#{organizational_unit(type)}
              #{Tapjoy::LDAP::client.basedn}).join(',')
          end
          memoize :distinguished_name

          def organizational_unit(type)
            case type
            when 'user'
              'People'
            when 'service'
              Tapjoy::LDAP::client.service_ou
            else
              puts 'Unknown type'
            end
          end
          memoize :organizational_unit

          def ldap_attr(fname, lname, type, group)
            uid = username(fname, lname)
            {
              uid:            uid,
              cn:             [fname, lname].join(' '),
              objectclass:    %w(top posixAccount shadowAccount inetOrgPerson
                                   organizationalPerson person ldapPublicKey),
              sn:             fname,
              givenname:      lname,
              # Empty string is an alias for the root of the FS
              homedirectory:  File.join('','home', uid),
              loginshell:     File.join('','bin', 'bash'),
              mail:           "#{uid}@tapjoy.com",
              uidnumber:      uidnumber(type),
              gidnumber:      gidnumber(group),
              userpassword:   '{SSHA}' + create_password
            }
          end
          memoize :ldap_attr

          def uidnumber(type)
            Tapjoy::LDAP::client.get_max_id('user', type)
          end
          memoize :uidnumber

          def gidnumber(group)
            Tapjoy::LDAP::Group.lookup_id(group)
          end
          memoize :gidnumber

          def create_password
            # Super-Salt: bad for blood pressure, good for secure passwords
            # We can get away with this, since we're not planning on using passwords
              salt = SecureRandom.base64(32)
              password = SecureRandom.base64(64)
              password = Digest::SHA1.base64digest(password + salt)
          end
          memoize :create_password
        end
      end
    end
  end
end
