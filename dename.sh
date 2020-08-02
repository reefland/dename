#!/bin/bash

function process_grep()
{
    ps -e | grep -E "$1" &> /dev/null
    return $?
}

function detect_gnome()
{
    if ( process_grep '^.* gnome-session*' ); then
        VERSION=$(gnome-session --version | awk '{print $2}')
        # If that is empty try gnome shell's version
        if [[ -z $VERSION ]]; then
          VERSION=$(gnome-shell --version | awk '{print $3}')
        fi
        DESKTOP="GNOME"
        return 1
    fi
}

function detect_kde()
{
    if ( process_grep '^.* kded[0-9]$' ); then
        # Check for KDE4 
        if ( which kded4 &> /dev/null ); then
            VERSION=$(kded4 --version | grep -m 1 'KDE' | awk -F ':' '{print $2}' | awk '{print $1}')
        else
            # Check for KDE5
            if ( which kded5 &> /dev/null ); then
                VERSION=$(kded5 --version| awk '{print $2}')
            fi
        fi
        DESKTOP="KDE"
        return 1
    fi
}

function detect_unity()
{
    if ( process_grep 'unity-panel' ); then
        VERSION=$(unity --version | awk '{print $2}')
        DESKTOP="UNITY"
        return 1
    fi
}

function detect_xfce()
{
    if ( process_grep '^.* xfce[0-9]-session*' ); then
        VERSION=$(xfce4-session --version | grep xfce4-session | awk '{print $2}')
        DESKTOP="XFCE"
        return 1
    fi
}

function detect_cinnamon()
{
    if ( process_grep '^.* cinnamon*' ); then
        VERSION=$(cinnamon --version | awk '{print $2}')
        DESKTOP="CINNAMON"
        return 1
    fi
}

function detect_mate()
{
    if ( process_grep '^.* mate-panel*' ); then
        VERSION=$(mate-about --version | awk '{print $4}')
        DESKTOP="MATE"
        return 1
    fi
}

function detect_lxde()
{
    if ( process_grep '^.* lxsession*' ); then
        # We can detect LXDE version only thru package manager
        if ( which apt-cache &> /dev/null ); then
            # For Lubuntu and Knoppix
            VERSION=$(apt-cache show lxde-common /| grep 'Version:' | awk '{print $2}' | awk -F '-' '{print $1}')
        else
            if ( which yum &> /dev/null ); then
                # For Fedora
                VERSION=$(yum list lxde-common | grep lxde-common | awk '{print $2}' | awk -F '-' '{print $1}')
            else
                VERSION="UNKNOWN"
            fi
        fi
        DESKTOP="LXDE"
        return 1
    fi
}

function detect_sugar()
{
    if [ "$DESKTOP_SESSION" == "sugar" ]; then
        VERSION=$(python -c "from jarabe import config; print config.version")
        DESKTOP="SUGAR"
        return 1
    fi
}

# Only one should match, so call them all.
DESKTOP="UNKNOWN"
detect_unity
detect_kde
detect_gnome
detect_xfce
detect_cinnamon
detect_mate
detect_lxde
detect_sugar

case $1 in
  "-v"|"-V")
    echo $VERSION
  ;;
  "-n"|"-N")
	echo $DESKTOP
  ;;
  *)
	echo $DESKTOP $VERSION
  ;;
esac
