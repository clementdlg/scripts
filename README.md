# Bash Scripting
I write a whole lot of bash scripts to automate my workflow as a devops.
In this repo you will find System Administration scripts, and developpement scripts. I tried to specific for each script the timeframe of developpement.
Let's have an overview of some of the script in this repo :

## Administration scripts
### Ansible Prepare
**Context** :
- Ansible is a powerful administration framework for fleets of servers
- It has two main prerequisists : SSH and Python3.

**Scope** :
- The goal of this script is to be the only thing that you have to run on the host before being able to manage it using Ansible

**Features** :
- Create dedicated ansible user
- Install ssh service
- Harden ssh service

**Timeframe** :
- Written in one day: 02/07/25

### OVA converter
**Context** :
- an **OVA** file is an export of a VM from VMware (or virtualbox)

**Features** :
- this scripts converts all the disks-images of the VM into **qcow2**, the preferred format for Proxmox and KVM
- It is a wrapper for **qemu-img convert** with automation

**Timeframe** :
- Written in one day: 12/10/24

---
## Dev scripts

### Build Nvim From Source
**Context** :
- Neovim is a fork of Vim that includes a powerful Lua API, and the capability for async plugins
- Neovim is my primary text editor. But on some distros (*cough* debian *cough*), the available version is outdated, so I build from source

**Features** :
- This scripts is used to build Neovim from source files automatically.

**Timeframe** :
- Written in one day: 27/12/24

### Dockertag
**Context**
- When packaging applications using docker, you often need to go to dockerhub to check which tags are available for a specific image that you want to use
- I dont want to leave my CLI so i wrote a script to get me the tags directy into my terminal

**Features**
- retrieve all tags for a specific docker image

**Timeframe**
- Written in one day: 07/02/25
