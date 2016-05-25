require 'memoist'
module Tapjoy
  module LDAP
    module API
      module User
        class << self
          extend Memoist
          def create(fname, lname, type, group)
            # Properly capitalize names
            fname, lname = [fname, lname].map(&:capitalize)

            Tapjoy::LDAP.client.add(
              distinguished_name(fname, lname, type),
              ldap_attr(fname, lname, type, group)
            )
          end

          def destroy(username, type)
            Tapjoy::LDAP.client.delete(
              distinguished_name(*name_of_user(username), type)
            )
          end

          def index
            Tapjoy::LDAP.client.search('*', filter(uid: '*'))
          end

          def show(username)
            Tapjoy::LDAP.client.search('*', filter(uid: username))
          end

          private

          # Filter users for #show and #index
          def filter(uid: '*')
            Net::LDAP::Filter.eq('uid', uid)
          end

          # Given a username, return First and Last names
          def name_of_user(username)
            username.split('.').map(&:capitalize)
          end
          memoize :name_of_user

          # Given First and Last names, return a username
          def username(fname, lname)
            [fname, lname].join('.').downcase
          end
          memoize :username

          def distinguished_name(fname, lname, type)
            %W(
              uid=#{username(fname, lname)}
              ou=#{organizational_unit(type)}
              #{Tapjoy::LDAP.client.basedn}).join(',')
          end
          memoize :distinguished_name

          def organizational_unit(type)
            case type
            when 'user'
              'People'
            when 'service'
              Tapjoy::LDAP.client.service_ou
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
              sn:             lname,
              givenname:      fname,
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
            Tapjoy::LDAP.client.get_max_id('user', type)
          end
          memoize :uidnumber

          def gidnumber(group)
            Tapjoy::LDAP::API::Group.lookup_id(group)
          end
          memoize :gidnumber

          def create_password
            # Super-Salt: bad for blood pressure, good for secure passwords
            # We can get away with this, since we're not planning on using passwords
              salt = SecureRandom.base64(32)
              password = SecureRandom.base64(64)
              password = Digest::SHA1.base64digest(password + salt)
          end
        end
      end
    end
  end
end
