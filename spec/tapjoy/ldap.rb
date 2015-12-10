require_relative '../spec_helper'
RSpec.shared_context 'ldap' do

  before(:each) do
    allow(Tapjoy::LDAP).to receive(:client).and_return(fake_ldap)
    allow(fake_ldap).to receive(:basedn).and_return('dc=example,dc=net')
    ARGV.clear
  end
end
