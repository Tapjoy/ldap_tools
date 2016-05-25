module Tapjoy
  module LDAP
    module CLI
      module Group
        # Manipulates data to a format usable
        # by the API structure for group display
        class Index
          # Make the API call to show an LDAP user
          def index
            Tapjoy::LDAP::API::Group.index.each do |entry|
              puts "#{entry.cn.first}:\t#{entry.gidnumber.first}"
            end
          end
        end
      end
    end
  end
end
