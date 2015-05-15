Gem::Specification.new do |s|
  s.name                  = 'ldap_tools'
  s.version               = '0.1.1'
  s.date                  = '2015-02-09'
  s.summary               = 'Tapjoy LDAP Tools'
  s.description           = 'A set of tools to make managing LDAP users, groups, and keys easier'
  s.authors               = ['Ali Tayarani']
  s.email                 = 'ali.tayarani@tapjoy.com'
  s.files                 = Dir['lib/tapjoy/**/**']
  s.homepage              = 'https://github.com/Tapjoy/ldap_tools'
  s.license               = 'MIT'
  s.executables           = ['ldaptools']
  s.required_ruby_version = '>= 2.1'
  s.add_runtime_dependency('trollop',  '~> 2.1')
  s.add_runtime_dependency('net-ldap', '= 0.11')

end
