# Boxen SSH Configuration 

### Installs:
- ssh-copy-id
- sshpass 1.05

### Configures:
- If modules/people/files/[github username]/ssh_config exists, it will be moved into place
- Creates a new rsa key if one does not exist
- Sets up key-authentication to all the hosts in your config file


### Usage:

```
  class { 'sshconfig':
    check_server  => 'servername',
    password_file => '/tmp/mp',
    before        => Class['dependent_class']
  }
```
Arguments:
* `check_server`: a server to attempt key auth access. If successful, the module will not try to redistribute they key
* `password_file`: file containing user's password used to log into the remote server and push the key to the authorized_keys file.  Creation of this file is something you can script into the script/bootstrap script.  You should clean this file up when it is no longer needed. See example below.
* ordering/relationship: ensure this is done before any other classes which need ssh access to servers

Users can add their configuration files in modules/people/files/[github username]/ssh_config


### Creating the password_file
Typically you will want to wrap this in some kind of conditional statement to prevent it from prompting the user on every execution.  

```
ssh -o BatchMode=yes [sameas-check_server] 'exit' > /dev/null 2>&1
keyauth_installed=$?

if [ 0 -ne $keyauth_installed ]; then 
	echo "Enter network password:"
	read -s SSHPASS
	echo OK

	echo $SSHPASS > /tmp/mp
	chmod 700 /tmp/mp
fi
```

### Required Puppet Modules

* `boxen`