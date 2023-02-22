#!/bin/bash

# To be able to run this script from any path, using absolute paths
declare -r script_dir="$(dirname $(readlink -f $0))"

# Exit if script_dir is empty
if [ -z "${script_dir}" ]; then
	exit 1
fi

# For `ansible.cfg` to work, and for relative paths
cd "${script_dir}"

# Activate this virtual environment
source ../bin/activate

# Ensure Ansible version 2.9.27 is installed
# installs ansible-playbook and ansible-galaxy, which are used below
pip3 install 'ansible<2.10'

# Ensure requirements are met
ansible-galaxy install -r ./collections/requirements.yml
ansible-galaxy install -r ./roles/requirements.yml

# Flags:
# -k asks login password
# -K asks become (sudo) password
# -e overwrites a variable, see: Presedence order for Ansible
ansible-playbook -k -K -e "var_hosts=postgresql" ./playbooks/postgresql.yml
