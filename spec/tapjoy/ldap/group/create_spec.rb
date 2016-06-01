require_relative '../group'
RSpec.describe 'Tapjoy::LDAP::CLI::Group::Create.create' do
  include_context 'group'

  let!(:ldap_attr) {
    {cn: "testgroup", objectclass: %w(top posixGroup), gidnumber: 10001}
  }

  it 'creates a group' do
    ARGV << %w(create -n testgroup); ARGV.flatten!
    expect(fake_ldap).to receive(:add).with(distinguished_name, ldap_attr)

    Tapjoy::LDAP::CLI::Group.commands
  end
end
