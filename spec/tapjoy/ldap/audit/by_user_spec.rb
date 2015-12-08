require_relative '../audit'
describe 'Tapjoy::LDAP::Audit::ByUser.by_user' do
  include_context 'audit'
  # let(:operations) {[[:add, :memberUid, 'test.user']]}

  let(:ldap_hash) {
    {dn: dn, uid: [username]}
  }
  let(:ldap_group_hash) {
    [
      { dn: ['cn=test_group,ou=Group,dc=example,dc=net'],
        cn: ['test_group'],
        memberUid: [username]
      },
      {
        dn: ['cn=test_group2,ou=Group,dc=example,dc=net'],
        cn: ['test_group2'],
        memberUid: ['notTest']
      }
    ]
  }
  let(:dn) {"uid=#{username},ou=People,dc=example,dc=net"}
  let(:username) {'test.user'}
  let(:results) { OpenStruct.new ldap_hash}
  let(:printed_hash) {
    {'test.user' => ['test_group']}
  }

  it 'audits by group' do
    ARGV << %w(by_user); ARGV.flatten!
    allow(fake_ldap).to receive(:search).and_return([results])
    allow(Tapjoy::LDAP::Audit).to receive(:get_groups_with_membership).and_return(ldap_group_hash)

    expect(Tapjoy::LDAP::Audit).to receive(:print_hash).with('Groups by user', printed_hash)
    Tapjoy::LDAP::Audit.commands
  end
end
