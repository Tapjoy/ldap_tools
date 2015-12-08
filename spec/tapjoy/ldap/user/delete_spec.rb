require_relative '../../../spec_helper'
require_relative '../user'
describe 'Tapjoy::LDAP::User::Delete.delete' do
  include_context 'user'

  it 'deletes a user' do
    ARGV << %w(delete -u test.user -f); ARGV.flatten!
    allow_any_instance_of(Tapjoy::LDAP::User::Create).to receive(:create_password).and_return('testpass')
    expect(fake_ldap).to receive(:delete).with(dn)
    Tapjoy::LDAP::User.commands
  end
end
