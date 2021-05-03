## Linux basics
[More detailed notes of the course](https://github.com/kodekloudhub/linux-basics-course)

- `/home` is where all users by default get their space (think of it as locker)
![home dir](./images/home_dir.png)
- `type <command>` : tells if command is internal(comes with shell) or external(installed by linux distribution)
- `uptime` shows how long system has been running
- `ls -lt` long list files in order created (newest to oldest)
- `ls -ltr` long list files in reverse order created (oldest first)
-----
## Environment variable
- `echo $SHELL` prints value of shell (which is an environment variable)
- `env` lists all environment variables
- `export NAME=VALUE` creates
- `.profile` or `.pam_environment` to persist environment variable from logout/reboot
-----
## Path variable
- `echo $PATH` list of paths where shell searches for when an external command is used
- `which <command>` to check the location/path of the command; if no result then path not in _path variable_
- `export PATH=$PATH:<path/of/command>` to add location of external command to path variable

- `alias up=uptime` will set shortcut up for the actual command uptime
- `echo 'alias up=uptime' >> ~/.profile` to make persistent alias by putting it on profile
-----
## Kernel
- Analogy of a librarian as an intermediator b/w books and students
- `uname` info about the kernel
- `uname -r` info about the kernel version
__Hardwares__
- `lsblk` lists information about the block devices (physical disk and its partitions)

- `lscpu` detailed information about the cpu, its cores and threads

- `lsmem --summary` gives information about the total memory
- `free -m` gives information about the total vs used memory in "mb" (-k for kb and -g for gb)

- `lshw` to get detailed information about the entire hardware configuration
-----
## Boot Sequence Stages
1. `BIOS POST`(Power On Self Test)
    - Here BIOS runs test to ensure hardwares attached to the device are healthy
    - If found unhealthy, the system may not be operable and may not proceed to second stage
2. `Bootloader (GRUB2)`
    - BIOS loads the boot code from the boot device which is located on the first sector of the hard drive
    - In linux it is located at the `/boot` file system
    - Bootloader provides the user with the boot screen often with an option to boot Ubuntu or Windows in an example of a dual boot system
    - Once the selection is made at the boot screen, the bootloader loads the kernel(based on the selection) into the memory, supplies it with some parameters and handover the control to the kernel
    - A popular example of bootloader is GRUB2 (Grand Unified Bootlaoder)
3. `Kernel Initialization`
    - Kernels are usually in compressed state to save space
    - After the kernel is selected, it is decompreseed
    - It performs hardware initialization and some other memory management tasks among other things
    - After it is completely operational, the kernel looks for INIT Process to run which sets up the __USER SPACE__ and the processes needed for the user environment
4. `INIT Process (systemd)`
    - In most linux distros, the INIT process calls the __systemd__
    - __systemd__ is responsible for bringing the linux system into a usable state
    - __systemd__ is responsible for
        1. mounting file system
        2. starting and managing services
    - In some linux distros, the INIT process have sys5 instead of systemd
    - `ls -la /sbin/init` **to check the INIT system used**
-----
## Run level (systemd targets)
- During boot, INIT process checks the value of `runlevel`
- Linux can run in different runlevels. If runlevel=5, systemd of INIT process calls function to enable display manager service for GUI. With runlevel=3, it boots into CLI
- `runlevel` to check your systems runlevel value
- In systemd's language 5 is called __graphical.target__ while 3 is called __multi-user.target__
- `systemctl get-default` to see the default target in your system
> This command looks at the file located at `ls -ltr /etc/systemd/system/default.target`
- `systemctl set-default multi-user.target` to change the default systemd target (runlevel)
-----
## File types (everything is file in linux)
1. **Regular** file: e.g images, scripts, configuration files
2. **Directory** file: e.g /home/bob, /home/bob/code-directory
3. **Special** files
    1. *Character* files: represents devices under `/dev` file system which allows the OS to communicate to IO devices serially e.g mouse, keyboard
    2. *Block* files: representing block devices located under `/dev` e.g hard-disk and RAM
    3. *Links*: to associate 2 or more filenames to the same set of file data
        - Hardlinks: 2 or more filenames sharing same data. deleting one deletes the data
        - softlinks (symlinks): pointers to another file. deleting syslink doesn't delete data
    4. *Socket*: files that enable the communication b/w 2 processes
    5. *Named pipes*: allows connecting one process as an input to another process. data flows unidirectionally from one process to another

![filetypes](./images/filetypes.png)
-----
## Filesystem Hierarchy
- `df -hP` (disk free or disk filesystem) prints info about all the mounted filesystem
- Detailed info about each file system - https://www.linux.com/training-tutorials/linux-filesystem-explained/
![filesystem](./images/filesystem.png)
> /etc : **E**verything related **T**o **C**onfiguration
-----
## Package Managers
### Some of the packages types
1. __.deb__
- Debian, Ubuntu, Linux Mint etc.
- Example of package managers for this kind of packages
    1. `dpkg` - base package manager for debian based distributions
    2. `apt` - newer frontend for dpkg system
    3. `apt-get` - traditional frontend for dpkg system
2. __.rpm__
- RHEL (Red Hat Enterprise Linux), Fedora, CentOS
- Example of package managers for this kind of packages
    1. `rpm` - base package manager for red hat based distributions
    2. `yum` - frontend for rpm system
    3. `dnf` - more feature rich frontend for rpm system

### YUM
- depends on software repos which contains 100s of packages (rpm package files)
- these repos can be hosted locally or remotely
- `/etc/yum.repos.d` contains info about the repos
- `/etc/yum.repos.d/redhat.repo` file that contains info about the official red hat repo
- What happens when we run `yum install <package>`
    1. yum runs a transaction check
        1. checks if package is already installed
        2. If not, then yum checks the configured repos under `/etc/yum.repos.d` for the availability of the requested package
        3. It also checks if any of the dependency packages are already installed or need to be upgraded
    2. transaction summary is displayed for review
    3. If user types 'yes' to summary, package gets installed
- `yum repolist` shows all the repos added to your system
- `yum install <package> | remove <package> | update <package> | update`
- `man yum` for yum related commands
- `rpm -qa | grep wget` to know the exact package of wget(and version) installed (q: query; a: all)

### APT
- `/etc/apt/sources.list` contains info about the repos; you can edit it to add more repos to it
- `apt update` refresh repo
- `apt upgrade` update packages installed
- `apt install <package> | remove <package>`
- `apt search <package>` to search for package in the repos e.g `apt search chromium` will give you exact name of the package to install
- `apt list` available, installed and upgradable packages
- `apt list | grep <package>`
-----
## Files
- `du -sh <file>` **tells you the size of the file (-s: specified file, -h: human readable format)**
- `ls -lh <file>` can also tell you about the size of the file

### tar (take archive)
- files created with tar are often called __tar balls__
- `tar -cf test.tar file1 file2 file3` -c: create -f: filename/tar ball to be created
- `tar -tf test.tar` to see contents of tar ball
- `tar -xf test.tar` to extract content of tar ball
- `tar -zcf test.tar file1 file2 file3` -z: to compress the tarball to reduce its size

### compression
- some pre-installed compression tools in Linux
![compression tools](./images/compression.png)
- they vary by their compression algorithms and hence notice the compressed size in the above picture
- `zcat | bzcat | xzcat` tools to read content of compressed file without uncompressing it
![read uncompressed](./images/read_compressed.png)
