module Tapjoy
  module LDAP
    class Group
      class << self
        # Lookup GID for the given group
        def lookup_id(groupname)
          gidnumber = []

          oc_filter = Net::LDAP::Filter.eq('objectclass', 'posixGroup')
          cn_filter = Net::LDAP::Filter.eq('cn', groupname)
          filter    = Net::LDAP::Filter.join(oc_filter, cn_filter)

          results = Tapjoy::LDAP::client.search(['gidNumber'], filter)

          # Make sure we return one, and only one group
          if results.size < 1
            abort('Group not found')
          elsif results.size > 1
            abort('Multiple groups found. Please narrow your search.')
          end

          results.each { |result| gidnumber = result.gidnumber }
          return gidnumber[0]
        end
      end

      attr_reader :groupname, :servers, :conn

      # Instantiate class
      def initialize
        # This is a necessary construct, because init could be called from
        # places other than the commandline.  As result, we want to overload
        # init, without *really* overloading it.
        if ARGV.length >= 1
          command = ARGV.shift

          case command
          when 'create', 'delete', 'add_user'
            send(command)
          else
            raise Tapjoy::LDAP::InvalidArgument
          end
        end
      end

      # Lookup GID for the given group
      # @TODO: Remove this in favor of class method
      def lookup_id(groupname)
        gidnumber = []

        oc_filter = Net::LDAP::Filter.eq('objectclass', 'posixGroup')
        cn_filter = Net::LDAP::Filter.eq('cn', groupname)
        filter    = Net::LDAP::Filter.join(oc_filter, cn_filter)

        results = Tapjoy::LDAP::client.search(['gidNumber'], filter)

        # Make sure we return one, and only one group
        if results.size < 1
          abort('Group not found')
        elsif results.size > 1
          abort('Multiple groups found. Please narrow your search.')
        end

        results.each { |result| gidnumber = result.gidnumber }
        return gidnumber[0]
      end

      private
      # Create group
      def create
        opts = Trollop::options do
          # Set help message
          banner("#{$0} group create [options]")

          opt :name, 'Specify group to create', :type => :string
          opt :type, 'Specfy if this is a user or service group', :type => :string, :default => 'user'
        end

        Trollop::die :name, 'argument count must be one' if opts[:name].nil?
        Trollop::die :type, "argument must be 'user' or 'service'" unless ['user', 'service'].include?opts[:type]

        dn = "cn=#{ opts[:name] },ou=Group,#{ Tapjoy::LDAP::client.basedn }"

        ldap_attr = {
          :cn          => opts[:name],
          :objectclass => ['top','posixGroup'],
          :gidnumber   => Tapjoy::LDAP::client.get_max_id('group', opts[:type])
        }
        puts Tapjoy::LDAP::client.add(dn, ldap_attr)
      end

      # Delete group
      def delete
        opts = Trollop::options do
          # Set help message
          banner("#{$0} group delete [options]")

          opt(:group, 'Specify group', :type => :string, :required => true)
          opt(:force, 'Force delete')
        end

        dn = "cn=#{ opts[:group] },ou=Group,#{ Tapjoy::LDAP::client.basedn }"
        unless opts[:force]
          puts "Confirm that you want to delete group: #{ opts[:group] }"
          print '>'
          confirm = STDIN.gets.chomp().downcase
          unless confirm.eql?('y') || confirm.eql?('yes')
            abort("Deletion of #{ opts[:group] } aborted")
          end
        end

        puts Tapjoy::LDAP::client.delete(dn)
      end

      # Add user to group
      def add_user
        opts = Trollop::options do
          banner("#{0} group add_user [options]")

          opt(:group, 'Specify group', :type => :string, :required => true)
          opt(:username, 'Specify username', :type => :string, :required => true)
        end

        dn = "cn=#{ opts[:group] },ou=Group,#{ Tapjoy::LDAP::client.basedn }"
        operations = [
          [:add, :memberUid, opts[:username]]
        ]
        puts Tapjoy::LDAP::client.modify(dn, operations)
      end
    end
  end
end
