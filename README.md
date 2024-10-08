## README.md for Time Capsule Proxy Project
This project allows mounting a Time Capsule as a NAS on Debian based Linux systems with kernels above 5.15, which no longer support the `sec=ntlm` mount flag.

**Installation via script (from a standard terminal):**
```
wget -O - https://github.com/leobrigassi/time_capsule_proxy/raw/main/tcproxy 2>/dev/null | bash
```
[Release notes and legacy versions](https://github.com/leobrigassi/time-capsule-proxy/releases)


**Test BETA version:**
```
wget -O - https://github.com/leobrigassi/time_capsule_proxy/raw/beta/tcproxy 2>/dev/null | BETA= bash
```
Features being tested are listed in first prompt.



**How it works:**
* The project runs a virtual machine (VM) using QEMU with Alpine Linux 3.13, a kernel version that supports mounting Time Capsules.
* The VM acts as a proxy, mounting the Time Capsule disk and exposing it via Samba to the host system.
* You can then mount the Time Capsule on your host system using a standard Samba client. This part is also automated via systemd after user confirmation.

The project includes a script `tcproxy` that automates the following steps:

1. Prompts you for user inputs.
2. Extracts the pre-provisioned VM image if it doesn't exist.
3. Starts the VM using qemu-system-aarch64
4. Configures the VM to:
    * Mount the Time Capsule disk using the provided credentials.
    * Set up Samba to share the mounted disk with the host system.
5. Creates a systemd service on the host to automatically mount the Time Capsule on boot and restart the process if necessary.

Follow the prompts to enter your Time Capsule credentials.
Access your files in /srv/tcproxy

To access program options type: `./tcproxy --help`


**Requirements:**

* Linux system with kernel version above 5.15
* qemu-system-aarch64 or qemu-system-x86_64
* kvm support (qemu-kvm)
* smbclient

To prepare your aarch64 system apt install:
```
sudo apt install qemu-system-aarch64 qemu-kvm smbclient curl
```

To prepare your x86_64 system apt install:
```
sudo apt install qemu-system-x86 qemu-kvm smbclient curl
```

**User Inputs:**

* **Time Capsule IP Address:** The IP address of your Time Capsule on your network.
* **Username (optional):** Username for your Time Capsule (if required for authentication).
* **Password:** Password for your Time Capsule.
* **Disk Name:** The name of the disk on your Time Capsule that you want to mount.
* **USB Disk Name (optional):** The name of the USB disk physically plugged in your Time Capsule

**Files:**

* `LICENSE`: License for the project code.
* `README.md`: This file (you are reading it now).
* `id_rsa_vm`: Private ssh key used to access the VM.
* `id_rsa_vm.pub`: Public ssh key used to access the VM.
* `qemu.mac`: MAC address of the VM.
* `data.img`: volume file of the VM.
* `uefi.rom`: uefi file required for VM boot (only aarch64).
* `tcproxy`: Script to control the VM and mounts.
* `after_tcproxy_up` if script named after_tcproxy_up exists in tcproxy folder it will be executed after tcproxy mount is successfull.


**Note:**

* This script modifies system files and configurations. Make sure to understand the risks involved before running it.
* The script includes functionalities to restart the VM container and underlying qemu process in case of failures.

**Getting Started:**

1. Open a terminal in the project directory.
2. Clone or download this project to your local machine.
3. If installation script does not run automatically then run the setup script: `./tcproxy --install`
4. Follow the on-screen prompts to provide the required information.
5. Wait for the script to complete the provisioning process.
6. Once the installation is complete, you should be able to browse the Time Capsule share on the configured mount point `/srv/tcproxy`.

**Additional Notes:**

* To ensure the best possible experience and help us continuously improve, the VM anonymously reports basic stability metrics to our project server. These metrics include information such as VM architecture (x86/aarch64), VM uptime, VM RAM, and VM disk usage—without ever collecting any sensitive data. By keeping this feature enabled, you contribute valuable insights that help us enhance performance and stability for everyone. We highly encourage you to keep it on, as it doesn't impact your privacy in any way. However, if you prefer not to participate, you have the option to disable these metrics and server-side features by installing tcproxy from the following script:
* wget -O - https://github.com/leobrigassi/time_capsule_proxy/raw/main/tcproxy 2>/dev/null | STATS=0 bash
* Please note, this will also disable helpful features like --update and --remote-log. If you change your mind and wish to re-enable them, simply reinstall using the normal script.
Your support is appreciated!
* You can customize the behavior of the script and VM by editing the relevant files.
* Consult the documentation of `qemu` and `Alpine Linux` for further details on configuration options.

I hope this README.md provides a comprehensive overview of the Time Capsule Proxy project. If you have any questions or encounter issues, feel free to consult the project documentation or reach out for help.