require_relative '../../../spec_helper'
require_relative '../group'
describe 'Tapjoy::LDAP::Group::AddUser.add_user' do
  include_context 'group'
  let(:operations) {[[:add, :memberUid, 'test.user']]}

  it 'creates a group' do
    ARGV << %w(add_user -g testgroup -u test.user); ARGV.flatten!
    expect(fake_ldap).to receive(:modify).with(dn, operations)
    Tapjoy::LDAP::Group.commands
  end
end
