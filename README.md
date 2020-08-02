dename - Desktop Environment NAME
======

Bash script to detect linux desktop environment name and version

## How to use:

* `wget https://raw.github.com/reefland/dename/master/dename.sh`
* `chmod +x dename.sh`
* `./dename.sh` - prints name and version
* `./dename.sh -n` - prints only name
* `./dename.sh -v` - prints only version

## Can detect (Detected name - Original name):

* GNOME - Gnome 2, Gnome 3
* KDE - KDE4, KDE5
* UNITY - Ubuntu Unity
* XFCE - XFCE
* CINNAMON - Cinnamon
* MATE - Mate
* LXDE - LXDE
* SUGAR - Sugar on a Stick

## Tested in:

* CentOS 6.5
* Fedora 20
* Knoppix 7.0.5
* Kubuntu 13.10
* Lubuntu 12.04, 12.10, 13.04, 13.10
* Manjaro with KDE5
* Red Hat Enterprise Edition 6.2
* Ubuntu 20.04

_NOTE: much of the above was tested by the original author and I cannot verify it works, if you test something not list please let me know._

Use within Ansible
======
The following can provide some ideas how you can detect a Linux GUI environment from within Ansible.

1. Download the `dename.sh` script and place in your `files` directory.
2. Create a file in your `tasks` directory such as `detect_GUI.yml` and add the following yaml code to it.

```yaml
# This script sets a variable named "dename" that contains the Linux GUI Environment Detected otherwise will return "UNKNOWN"

- name: Detect if Running under a GUI Block
  block:
    # Reference only, one should never execute a script directly from the internet!
    #- name: Fetch GUI Detection Script
    #  get_url:
    #    url: "https://raw.github.com/reefland/dename/master/dename.sh"
    #    mode: 0755
    #    dest: "/tmp"
    #    force: yes
    
    - name: Transfer GUI Detection Script
      copy: 
        src: "dename.sh"
        mode: 0755
        dest: "/tmp"

    # Parameter "-n" returns GUI name only, remove it for GUI and Version
    - name: Run GUI Detection Script
      shell: "/tmp/dename.sh -n"
      register: dename_output
    
    - set_fact: 
        dename: "{{dename_output.stdout}}"
      
  tags:
    - detect-gui-environment
```

3. Somewhere in your playbook, call the tasks.  I use a helper task early and call it within the `pre-task` block of my `main.yml` file. Adjust this to meet your playbook needs.

```yaml
 pre_tasks:
  - include_role: 
       name: helper_tasks
       tasks_from: "detect_GUI.yml"
```

4. You now have a variable named `dename` which can be used throughout the rest of your playbook to make decisions with.

```yaml
- fail: 
    msg: "This playbook requires a Linux GUI Environment."
    when: dename == "UNKNOWN"

- debug:
    msg: "Linux GUI Environment Detected: {{dename}}"
```


Thanks to Ansible, this variable will be set per host allowing host specific decisions to be made.

```yaml
ok: [testlinux.localdomain] => {
    "msg": "UNKNOWN"
}
ok: [acepc01.localdomain] => {
    "msg": "GNOME"
}

# Can be set to provide version number as well
ok: [acepc01.localdomain] => {
    "msg": "GNOME 3.36.3"
}
```
