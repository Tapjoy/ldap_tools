module Tapjoy
  module LDAP
    class Base

      attr_reader :hosts, :basedn, :conn, :service_ou, :group, :key

      # Instantiate class
      def initialize
        ldap_config_file = "#{ldap_config_directory}/ldap_info.yaml"
        ldap_password_file = "#{ldap_config_directory}/ldap.secret"

        begin
          if can_read_files?(ldap_config_file, ldap_password_file)
            load_config_from_files(ldap_config_file, ldap_password_file)
          else
            load_config_from_env
          end
        rescue => err
          STDERR.puts "Error message: #{err.inspect}"
          abort("Config not specified.  Either provide #{ldap_config_file} and #{ldap_password_file} or environment variables")
        else
          @conn = find_valid_host
        end
      end

      # Set LDAP Config Directory
      def ldap_config_directory
        return "#{ENV['LDAP_CONFIG_DIR'] ? ENV['LDAP_CONFIG_DIR'] : ENV['HOME'] + '/.ldap'}"
      end

      # Search the LDAP directory
      def search(attributes = ['*'],
                 filter = Net::LDAP::Filter.eq('objectclass','*'))
        @entries = []
        if @conn
          @conn.search base: @basedn,
                       filter: filter,
                       attributes: attributes do |entry|
            @entries.push(entry)
          end
        else
          abort('Could not connect to any LDAP servers')
        end

        return @entries
      end

      # Add objects to LDAP
      def add(distinguished_name, attributes)
        @conn.add(dn: distinguished_name, attributes: attributes)
        return return_result
      end

      def add_attribute(distinguished_name, attribute, value)
        @conn.add_attribute(distinguished_name, attribute, value)
        return return_result
      end

      def replace_attribute(distinguished_name, attribute, value)
        @conn.replace_attribute(distinguished_name, attribute, value)
        return_result
      end

      # Modify objects in LDAP
      def modify(distinguished_name, operations)
        @conn.modify(:dn => distinguished_name, :operations => operations)
        return return_result
      end

      # Delete objects from LDAP
      def delete(distinguished_name)
        @conn.delete(:dn => distinguished_name)
        return return_result
      end

      # Format return codes
      def return_result
        msg1 = "Return Code: #{ @conn.get_operation_result.code }\n"
        msg2 = "Message: #{ @conn.get_operation_result.message }"
        return msg1 + msg2
      end

      # Get highest used ID
      def get_max_id(object_type, role)
        case object_type
        when 'user'
          objectclass = 'person'
          ldap_attr   = 'uidNumber'
        when 'group'
          objectclass = 'posixGroup'
          ldap_attr   = 'gidNumber'
        else
          abort('Unknown object type')
        end

        minID, maxID = set_id_boundary(role)

        # LDAP Filters
        oc_filter   = Net::LDAP::Filter.eq('objectclass', objectclass)
        attr_filter = Net::LDAP::Filter.eq(ldap_attr, '*')
        filter      = Net::LDAP::Filter.join(oc_filter, attr_filter)

        highid = minID - 1  #subtract 1, so we can add 1 later

        id_list = search([ldap_attr], filter)
        id_list.each do |item|

          # parse attribute associated with object
          # users => uidnumber
          # groups => gidnumber
          if object_type == 'user'
            id = item.uidnumber[0].to_i
          elsif object_type == 'group'
            id = item.gidnumber[0].to_i
          else
            abort('Unknown object')
          end

          # Now that we have the appropriate attribute
          # let's find the first useable id.
          # I *really* hate the pattern I use here, but
          # can't think of a better one atm.
          if id > highid
            highid = id
          end
          if maxID.nil?
            next
          else
            if id > maxID
              highid = maxID
            end
          end
        end

        if !highid.nil?
          id = highid + 1
          return id.to_s
        else
          abort("Unable to find highest #{ldap_attr}")
        end
      end


      ## Private methods start here ##
      private

      # Connect to LDAP server
      def ldap_connect(host)
        auth = {
          method:   :simple,
          username: @rootdn,
          password: @ldap_password
        }

        Net::LDAP.new(host: host, port: @port, base: @basedn, auth: auth)
      end

      # Find valid LDAP host
      def find_valid_host
        @hosts.each do |host|
          @ldap = ldap_connect(host)
          begin
            if @ldap.bind
              return @ldap
            else
              next
            end
          rescue Net::LDAP::LdapError
            next
          end
        end
        abort('Could not connect to any LDAP servers')
      end

      # Set acceptable range for IDs
      def set_id_boundary(role)
        case role
        when 'user'
          minID = 10000
          maxID = 19999
        when 'service'
          minID = 20000
          maxID = nil
        else
          abort('Unknown role')
        end

        return minID, maxID
      end

      # Load config from files
      def load_config_from_files(ldap_config_file, ldap_password_file)
        ldap_info      = YAML.load_file(ldap_config_file)
        @rootdn        = ldap_info['rootdn']
        @hosts         = ldap_info['servers']
        @basedn        = ldap_info['basedn']
        @service_ou    = ldap_info['service_ou']
        @email_domain  = ldap_info['email_domain']
        @port          = ldap_info['port']
        @ldap_password = File.read(ldap_password_file).chomp
      end

      # Load config from ENV
      def load_config_from_env
        raise Tapjoy::LDAP::Errors::UndefinedServers if ENV['LDAP_SERVERS'].nil?

        @rootdn        = ENV['LDAP_BIND_DN']
        @basedn        = ENV['LDAP_BASE_DN']
        @service_ou    = ENV['LDAP_SERVICE_OU']
        @email_domain  = ENV['LDAP_EMAIL_DOMAIN']
        @port          = ENV['LDAP_PORT']
        @ldap_password = ENV['LDAP_BIND_PASS']
        @hosts         = ENV['LDAP_SERVERS'].split(',')
      end

      # Check if config files are readable
      def can_read_files?(ldap_config_file, ldap_password_file)
        File.readable?(ldap_config_file) && File.readable?(ldap_password_file)
      end
    end
  end
end
