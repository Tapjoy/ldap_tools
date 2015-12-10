RSpec.shared_context 'ldap' do
  ARGV.clear
  before(:each) do
    allow(Tapjoy::LDAP).to receive(:client).and_return(fake_ldap)

    allow(fake_ldap).to receive(:basedn).and_return('dc=example,dc=net')
  end
end
