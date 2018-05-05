SHELL             := bash
.SHELLFLAGS       := -eu -o pipefail -c -s
.DEFAULT_GOAL     := default
.DELETE_ON_ERROR:
.SUFFIXES:
.SILENT:

MASTER_COUNT="$(shell grep MASTER_COUNT Vagrantfile | head -n 1 | awk '{ print $$3 }')"
NODE_COUNT=$(shell grep NODE_COUNT Vagrantfile | head -n 1 | awk '{ print $$3 }')
PROJECT=$(shell basename $$(pwd))

ifndef OPENSHIFT_VERSION
OPENSHIFT_VERSION = 3.7
OPENSHIFT_RELEASE_BRANCH = release-$(OPENSHIFT_VERSION)-hotfix
DOCKER_VERSION = 1.12.6
endif
ifeq ($(OPENSHIFT_VERSION), 3.9)
OPENSHIFT_RELEASE_BRANCH = release-$(OPENSHIFT_VERSION)
DOCKER_VERSION = 1.13.1
endif

ifdef NODE
VAGRANT_EXTRA_ARGS += $(NODE)
endif

ifeq ($(DEBUG), y)
ANSIBLE_EXTRA_ARGS += -vvv
endif

ifeq ($(FORCE), y)
VAGRANT_EXTRA_ARGS += -f
endif

.PHONY: all
all: default

.PHONY: default
default:

.PHONY: keygen
keygen:
	[ -d keys ]				 || mkdir keys
	[ -f keys/id_rsa ] || ssh-keygen -t rsa -b 4096 -f keys/id_rsa -q -N ''


.PHONY: keyscan
keyscan:
	ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook \
		--ssh-extra-args="-o IdentitiesOnly=yes" \
		-i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory \
		-e "MASTER_COUNT=$(MASTER_COUNT)" \
		-e "NODE_COUNT=$(NODE_COUNT)" \
		ansible/keyscan.yml $(ANSIBLE_EXTRA_ARGS)

.PHONY: deps
deps: keyscan
ifeq ($(SKIP_VAGRANT), n)
	vagrant up --provision
endif
	ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook \
		--ssh-extra-args="-o IdentitiesOnly=yes" \
		-i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory \
		-e "MASTER_COUNT=$(MASTER_COUNT)" \
		-e "NODE_COUNT=$(NODE_COUNT)" \
		-e "OPENSHIFT_VERSION=$(OPENSHIFT_VERSION)" \
		-e "OPENSHIFT_RELEASE_BRANCH=$(OPENSHIFT_RELEASE_BRANCH)" \
		-e "DOCKER_VERSION=$(DOCKER_VERSION)" \
		ansible/pre-install.yml $(ANSIBLE_EXTRA_ARGS)

.PHONY: install
install:
ifeq ($(OPENSHIFT_VERSION), 3.7)
	vagrant ssh $(PROJECT)-master1 -c \
		"sudo su - -c 'ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml'"
endif
ifeq ($(OPENSHIFT_VERSION), 3.9)
	vagrant ssh $(PROJECT)-master1 -c \
		"sudo su - -c 'ansible-playbook ~/openshift-ansible/playbooks/prerequisites.yml'" && \
	vagrant ssh $(PROJECT)-master1 -c \
		"sudo su - -c 'ansible-playbook ~/openshift-ansible/playbooks/deploy_cluster.yml'"
endif
	ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook \
		--ssh-extra-args="-o IdentitiesOnly=yes" \
		-i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory \
		ansible/post-install.yml $(ANSIBLE_EXTRA_ARGS)

.PHONY: up
up: keygen
	vagrant up $(VAGRANT_EXTRA_ARGS)

.PHONY: halt
halt:
	vagrant halt $(VAGRANT_EXTRA_ARGS)

.PHONY: destroy
destroy:
	vagrant destroy $(VAGRANT_EXTRA_ARGS)

.PHONY: status
status:
	vagrant status $(VAGRANT_EXTRA_ARGS)

.PHONY: clean
clean:
	rm -rf .vagrant keys
