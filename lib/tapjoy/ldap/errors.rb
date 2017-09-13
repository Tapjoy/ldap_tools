module Tapjoy
  module LDAP
    module Errors
      # Raise if error LDAP_SERVERS is incorrect
      class UndefinedServers < NoMethodError
        def initialize
          abort("FATAL: LDAP_SERVERS is undefined.")
        end
      end
    end
  end
end