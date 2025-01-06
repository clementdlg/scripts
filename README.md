# Bash Scripting
This repo hosts my bash scripts. Bash is my third language. I can create anything that I think of, quickly using bash.
Let's have an overview of some of the script in this repo :
### OVA converter
- an **OVA** file is an export of a VM from VMware (or virtualbox)
- this scripts converts all the disks-images of the VM into **qcow2**, the preferred format for Proxmox and KVM
- **qemu-img** is a dependency

### Shell logger
- this scripts logs every command typed into the current shell and every output.
- This is like a better version of the bash_history because it will only store the sucessful commands
- I use the logs as a base for future bash scripts
- usage :
```
source shell_logger.sh
```

### Build Nvim From Source
- This scripts is used to build the text editor Neovim using source files.
- Neovim is my primary editor. But on some distros (*cough* debian *cough*), the available version is outdated, so I build from source
- As with all scripts, I was tired of doing it manually so I automated it

