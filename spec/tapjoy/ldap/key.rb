require_relative '../ldap'
require 'ostruct'
RSpec.shared_context 'key' do
  include_context 'ldap'
  ARGV.clear
  let(:filename) {
    "#{File.expand_path("#{'../'*3}fixtures", __FILE__)}/keyfile_user_main"
  }
end
