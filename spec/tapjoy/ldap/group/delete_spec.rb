require_relative '../group'
RSpec.describe 'Tapjoy::LDAP::CLI::Group::Delete.delete' do
  include_context 'group'

  it 'deletes a group' do
    ARGV << %w(delete -n testgroup -f); ARGV.flatten!
    expect(fake_ldap).to receive(:delete).with(distinguished_name)

    Tapjoy::LDAP::CLI::Group.commands
  end
end
