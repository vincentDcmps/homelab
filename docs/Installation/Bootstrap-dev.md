# How to Bootstrap dev env

## prerequisite
dev environment is manage by molecule job who launch container via LXD you need following software to launch it:

- LXD server up on your local machine
- molecule install ``` pip install molecule```
- molecule-LXD plugins ```pip install molecule-lxd```


## provissionning

you can launch ```make create-dev``` on root project

molecule will create 3 container on different distribution

- archlinux
- rockylinux 9
- debian 11

To bootstrap the container (base account, sudo configuration) role [ansible_bootstrap](https://git.ducamps.win/ansible-roles/ansible_bootstrap) will be apply


Converge step call playbook [site.yml](https://git.ducamps.win/vincent/homelab/src/commit/c5ff235b9768d91b240ec97e7ff8e2ad5a9602ca/ansible/site.yml) to provission the cluster

