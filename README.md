# vagrant-openshift

This repository delivers OpenShift Cluster deployment using Vagrant and VirtualBox.
It allows to install RPM based installation of the OC v3.7.1 on CentOS 7.4.

### Quick start

```bash
make up deps install
```

> See `Vagrantfile` if you want to change `MASTER_COUNT` or `NODE_COUNT` in order to deploy multi-master configuration.
