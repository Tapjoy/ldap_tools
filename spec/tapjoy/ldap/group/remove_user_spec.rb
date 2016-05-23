require_relative '../group'
RSpec.describe 'Tapjoy::LDAP::Group::RemoveUser.remove_user' do
  include_context 'group'
  let(:operations) {[[:delete, :memberUid, 'test.user']]}

  it 'removes a user from an existing group' do
    ARGV << %w(remove_user -g testgroup -u test.user); ARGV.flatten!
    expect(fake_ldap).to receive(:modify).with(distinguished_name, operations)
    allow_any_instance_of(Tapjoy::LDAP::Group::RemoveUser).to receive(:confirm)
    Tapjoy::LDAP::Group.commands
  end
end
