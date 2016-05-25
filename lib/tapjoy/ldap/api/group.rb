require 'memoist'
module Tapjoy::LDAP::API
  # API methods for managing LDAP Groups
  module Group
    class << self
      extend Memoist
      def create(group_name, group_type)
        Tapjoy::LDAP.client.add(
          distinguished_name(group_name),
          ldap_attr(group_name, group_type)
        )
      end

      def destroy(group_name)
        Tapjoy::LDAP.client.delete(distinguished_name(group_name))
      end

      def update(group_name, username, operation)
        Tapjoy::LDAP.client.modify(
          distinguished_name(group_name),
          [[operation, :memberUid, username]]
        )
      end

      def index
        Tapjoy::LDAP.client.search('*', group_object_class_filter)
      end

      # Lookup GID for the given group
      def lookup_id(groupname)
        gidnumber = []

        cn_filter = Net::LDAP::Filter.eq('cn', groupname)
        filter    = Net::LDAP::Filter.join(
          group_object_class_filter, cn_filter)

        results = Tapjoy::LDAP.client.search(['gidNumber'], filter)

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

      def group_object_class_filter
        Net::LDAP::Filter.eq('objectClass', 'posixGroup')
      end
      memoize :group_object_class_filter

      def distinguished_name(group_name)
        %W(
          cn=#{group_name}
          ou=Group
          #{Tapjoy::LDAP.client.basedn}).join(',')
      end
      memoize :distinguished_name

      def ldap_attr(group_name, group_type)
        {
          cn:          group_name,
          objectclass: %w(top posixGroup),
          gidnumber:   Tapjoy::LDAP.client.get_max_id('group', group_type)
        }
      end
      memoize :ldap_attr
    end
  end
end
