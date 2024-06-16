## README.md for Time Capsule Proxy Project

This project allows mounting a Time Capsule as a NAS on Linux systems with kernels above 5.15, which no longer support the `sec=ntlm` mount flag.

**How it works:**

* The project runs a virtual machine (VM) using QEMU with Alpine Linux 3.13, a kernel version that supports mounting Time Capsules.
* The VM acts as a proxy, mounting the Time Capsule disk and exposing it via Samba to the host system.
* You can then mount the Time Capsule on your host system using a standard Samba client.

**Requirements:**

* Linux system with kernel version above 5.15
* Docker & docker-compose
* smbclient
* kvm support (qemu-kvm)

**User Inputs:**

* **Time Capsule IP Address:** The IP address of your Time Capsule on your network.
* **Disk Name:** The name of the disk on your Time Capsule that you want to mount.
* **Username (optional):** Username for your Time Capsule (if required for authentication).
* **Password:** Password for your Time Capsule.

**Installation Script:**

The project includes a script `install_Time_Capsule_Proxy.sh` that automates the following steps:

1. Prompts you for user input.
2. (Optional) Extracts the pre-provisioned VM image if it doesn't exist.
3. Starts the VM using Docker Compose.
4. Sets up passwordless SSH connection to the VM.
5. Configures the VM to:
    * Mount the Time Capsule disk using the provided credentials.
    * Set up Samba to share the mounted disk with the host system.
6. Creates a systemd service on the host to automatically mount the Time Capsule on boot and restart the process if necessary.

**Installation Steps:**

Open a terminal in the project directory.

Method 1: Installation via setup.sh 

Run the following command:v
```
wget -O - https://github.com/leobrigassi/Time_Capsule_Proxy/raw/main/setup.sh | bash
cd Time_Capsule_Proxy
./install_Time_Capsule_Proxy.sh 
```

Method 2: Clone repository

Run the following command:

```
git clone https://github.com/leobrigassi/Time_Capsule_Proxy.git
cd Time_Capsule_Proxy
chmod +x install_Time_Capsule_Proxy.sh
./install_Time_Capsule_Proxy.sh
```
Follow the prompts to enter your Time Capsule credentials.

**Files:**

* `LICENSE`: License for the project code.
* `README.md`: This file (you are reading it now).
* `docker-compose.yml`: Defines the Docker Compose configuration for the VM.
* `install_Time_Capsule_Proxy.sh`: Script to install and configure the Time Capsule proxy.
* `mount_Time_Capsule_Proxy.sh`: Script that runs on the VM to mount the Time Capsule and start Samba.
* `timecapsule_proxy.tar.gz`: Compressed archive containing the pre-provisioned VM image (Alpine Linux 3.13).
* `setup.sh`: Script that downloads compressed archive of this repo and extracts it in Time_Capsule_Proxy subfolder and runs `install_Time_Capsule_Proxy.sh` to initiate install.

**Note:**

* This script modifies system files and configurations. Make sure to understand the risks involved before running it.
* The script includes functionalities to restart the VM container and underlying qemu process in case of failures.

**Getting Started:**

1. Open a terminal in the project directory.
2. Clone or download this project to your local machine.
3. Run the installation script: `install_Time_Capsule_Proxy.sh`
4. Follow the on-screen prompts to provide the required information.
5. Wait for the script to complete the installation process.

**Using the Time Capsule:**

Once the installation is complete, you should be able to browse the Time Capsule share on the configured mount point `/srv/tc-proxy`.

**Additional Notes:**

* You can customize the behavior of the script and VM by editing the relevant files (e.g., `docker-compose.yml`).
* Consult the documentation of `docker-compose`, `qemu`, and `Alpine Linux` for further details on configuration options.


I hope this README.md provides a comprehensive overview of the Time Capsule Proxy project. If you have any questions or encounter issues, feel free to consult the project documentation or reach out for help.
