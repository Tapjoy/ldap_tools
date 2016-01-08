require_relative '../group'
describe 'Tapjoy::LDAP::Group::AddUser.add_user' do
  include_context 'group'
  let(:operations) {[[:add, :memberUid, 'test.user']]}

  it 'adds a user to a group' do
    ARGV << %w(add_user -g testgroup -u test.user); ARGV.flatten!
    expect(fake_ldap).to receive(:modify).with(distinguished_name, operations)

    Tapjoy::LDAP::Group.commands
  end
end
