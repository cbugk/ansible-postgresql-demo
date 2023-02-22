# Ansible Playbook Demo

This is a template/demo repository for using ansible on one's workstation/laptop. It is an accumulation of conventions I came accross on the internet and Ansible docs.

Example installs a single database with a single priveledged user on PostgreSQL (single-instance). Makes use of [Geerlingguy's ansible role](https://github.com/geerlingguy/ansible-role-postgresql), see his repo for details on parameters and behaviour. Ansible version 2.9.27 is used, can be adaptation should be fairly easy as namespaces are used where possible.

```
Warning: Running this on existing PostgreSQL instances is not advised, as it is likely to break its configuration.
```


## 1. Configuring Ansible Workstation

Below instructions are for Debian/Ubuntu. Feel free to modify `apt` commands for your repository. Mind that `main.sh` is tested on Ubuntu, your milage may vary on other OSes.

1. Ensure virtualenv is installed
	```sh
	sudo apt install -y python3-pip
	pip3 install virtualenv
	```

2. Create sandbox for Ansible
	```sh
	mkdir -p ~/Bench  # as per cbugk's convention
	virtualenv ~/Bench/ansible-2.9.27_postgresql_demo
	```

3. Download this repository into the environment (as directory src)
	```sh
	git clone https://github.com/cbugk/ansible-postgresql-demo.git ~/Bench/ansible-2.9.27_postgresql_demo/src
	```

4. Perform edits for your environment, see Part 2.


5. Run the script to complete environment preperation and trigger ansible-playbook
	```sh
	~/Bench/ansible-2.9.27_postgresql_demo/src/main.sh
	```

	Following error indicates that inventory was not modified according to the environment for which `main.sh` is being run. Change the hosts and run again.

		fatal: [256-256-256-256]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: Could not resolve hostname 256.256.256.256: Name or service not known", "unreachable": true}

## 2. Editing the configuration

### Files and directories

Prioritized tree of `src`:

		.
		├── README.md
		├── main.sh
		├── ansible.cfg
		├── inventory
		│   ├── group_vars
		│   │   ├── all
		│   │   │   └── ansible_ssh.yml
		│   │   └── postgresql
		│   │       └── params.yml
		│   ├── hosts.yml
		│   └── host_vars
		│       └── 256-256-256-256
		│           ├── ansible_ssh.yml
		│           └── postgresql.yml
		├── collections
		│   └── requirements.yml
		├── roles
		│   └── requirements.yml
		└── playbooks
		    └── postgresql.yml

Explanation:
* `./ansible.cfg`; Standard INI configuration file. Specifies non-standard inventory file, collections directory, and roles directory paths.
* `./inventory`: Non-standard directory to hold any configuration regarding groups and hosts.
* `./inventory/hosts.yml`: Standard file which holds groups and hosts in YAML format. However, non-standard path
* `./inventory/group_vars/foo/`: any YAML file under this directory defines variables of group `foo`. Files can partition concerns.
* `./inventory/host_vars/bar/`: any YAML file under this directory defines variables of host `bar`. Again, files can partition concerns.
* `./collections/`: Non-standard directory to isolate/contain all collection installations for the environment
* `./collections/requirements.yml`: Standard collection list to be installed by `main.sh`
* `./roles/`: Non-standard directory to isolate/contain all role installations for this environment
* `./roles/requirements.yml`: Standard role list to be installed by `main.sh`
* `./playbooks/`: Directory containing all playbooks, which will be called by `main.sh` in correct order.
* `./playbooks/baz.yml`: Playbook YAML file, hosts directive should be `var_hosts` and filled in at `main.sh`'s correspoding line with `-e var_hosts=foo` (group) or `-e var_hosts=bar` (host).

### Parameters

Below are the essential parameters, which can be overwritten at group or host level in this example. They are defined in host level without makinguse of a vault, in that case in-vault parameters would be arguments of below parameters and a decryption step would need to be inserted into `main.sh`.

One could also set these in group level if desired.

PotgreSQL related parameters (does not support lists):
* `postgresql_db`: name of the database to be created
* `postgresql_db_user`: privileged username
* `postgresql_db_password`: priveleged user's password

### Hosts

Example host is given a non-existing IP address `256.256.256.256` on purpose. It can be modifed to make use of IP addresses or domain names. Following is an example of changing to `192.168.1.1` (generaly IP address of the home router, somewhat fool-proof):

* Within `./inventory/hosts.yml`,

	from:

		      hosts:
		        256-256-256-256
	to:

			  hosts:
			    192-168-1-1
* Host directory, from: `./inventory/host_vars/256-256-256-256` to: `./inventory/host_vars/192-168-1-1`.
* Within `./inventory/host_vars/192-168-1-1`,

	from:

		---
		ansible_host: 256.256.256.256

	to:

		---
		ansible_host: 192.168.1.1

Above changes should effectively change a host's address. Any further variables defined on top of this template would require to be documented of course.

In this case, it is the PostgreSQL's listen addres being same as the host address used for SSH by Ansible. Later, one may desire to keep the listen address same while adding another network interface for managing the machine. In such case following line from `./inventory/group_vars/postgresql/params.yml` requires attention, as the original assumption is broken:

		postgresql_global_listen_addresses: 'localhost,{{ ansible_host }}'

### Requirements YAML

See official docs for [collections](https://docs.ansible.com/ansible/devel/collections_guide/collections_installing.html#install-multiple-collections-with-a-requirements-file) and [roles](https://galaxy.ansible.com/docs/using/installing.html).

PostgreSQL role is defined as a Github commit as an example (good for versioning and fast deploy of fixes), while Pip role just uses the latest on the ansible-galaxy.

No collection was required on this demo, yet it should be trivially similar.

#### Extracting the `version`:

`version` below is the commit string, which is `e8db6bb5c8632f99eb486f35a314377e95d0bce5` for Geerlingguy'
s postgresql role for [tag 3.4.3](https://github.com/geerlingguy/ansible-role-postgresql/releases/tag/3.4.3). Simply clicking the commit (located below tag) string takes one to the commit on Github in this instance. Thereon simply copy the string from URI. This is trvial if one has a clone of the repository on their workstation/laptop.