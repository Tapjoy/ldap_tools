require_relative '../../../spec_helper'
require_relative '../group'
describe 'Tapjoy::LDAP::Group::Delete.delete' do
  include_context 'group'

  it 'creates a group' do
    ARGV << %w(delete -n testgroup -f); ARGV.flatten!
    expect(fake_ldap).to receive(:delete).with(distinguished_name)
    Tapjoy::LDAP::Group.commands
  end
end
