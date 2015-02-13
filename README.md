<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [LDAP Tools](#ldap-tools)
  - [Requirements](#requirements)
  - [Installation](#installation)
    - [Installation from rubygems](#installation-from-rubygems)
    - [Installation from source](#installation-from-source)
  - [Configuration](#configuration)
    - [ldap_info.yaml](#ldap_infoyaml)
    - [ldap.secret](#ldapsecret)
  - [Commands](#commands)
    - [ldaptools](#ldaptools)
      - [Currently supported subcommands](#currently-supported-subcommands)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

LDAP Tools
==

This LDAP tools gem is designed as a wrapper around Net/LDAP to make interacting with LDAP easier.  No knowledge of LDIF required.

## Requirements
* Ruby 2.1
* Trollop gem
* Net/LDAP gem

## Installation
### Installation from rubygems
*not yet supported*
### Installation from source
```
git clone git@github.com:Tapjoy/ldap_tools.git
cd ldap_tools
gem build ldap_tools.gemspec
gem install ldap_tools*.gem --no-ri --no-rdoc
cd ..
```

## Configuration
There are two files used by this application.  The default location is $HOME/.ldap; however, this can be overridden using the ```$LDAP_CONFIG_DIR``` environment variable

### ldap_info.yaml
This config file provides basic information about your LDAP server setup.

  ```yaml
  ---
  basedn: #LDAP Base DN
  servers:
    - # LDAP master servers (one per line)
  port: # LDAP port
  rootdn: # LDAP root DN
  service_ou: # Organization Unit (OU) for service accounts
  email_domain: # Domain to be used for user email addresses
  ```

### ldap.secret
This is a plaintext file with the LDAP root password.

## Commands
### ldaptools
This is the base command from which all other commands are launched

```
Usage: ldaptools  [SUB_COMMAND] [options]

Tool to manage LDAP resources.
Available subcommands are: ["user", "group", "key", "audit"]

Options:
  -h, --help    Show this message
```

Help is available for all subcommands in a similar fashion.

#### Currently supported subcommands
* user create
* user delete
* group create
* group delete
* group add_user
* key add
* key remove
* key install
* audit by_user
* audit by_group
* audit raw
