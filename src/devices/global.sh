#!/sbin/sh
#####
# This file is part of the Injector Project: https://github.com/spazedog/injector
#  
# Copyright (c) 2013 Daniel Bergløv
#
# Injector is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Injector is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Injector. If not, see <http://www.gnu.org/licenses/>
#####

## A global config file for devices not added to the support tree

if $CONFIG_BUSYBOX [ -e /proc/mtd ]; then
    lDevice=boot

else
    for i in /recovery.fstab /etc/recovery.fstab; do
        if $CONFIG_BUSYBOX [ -e $i ]; then
            $lDevice=$($CONFIG_BUSYBOX grep '/boot' $i | $CONFIG_BUSYBOX awk '{print $3}'); break
        fi
    done
fi

case "$1" in 
    read)
        if $CONFIG_BUSYBOX [[ -e "$lDevice" || "$lDevice" = "boot" ]]; then
            if dump_image $lDevice $CONFIG_FILE_BOOTIMG; then
                exit 0
            fi
        fi
    ;;

    write)
        if $CONFIG_BUSYBOX [[ -e "$lDevice" || "$lDevice" = "boot" ]]; then
            if flash_image $lDevice $CONFIG_FILE_BOOTIMG; then
                exit 0
            fi
        fi
    ;;

    pack)
        # The main injector script will use mkbootimg if abootimg fails. But without a specific device config,
        # we do not have the information needed like kernel base, cmdline etc. So if abootimg fails, there is no more we can do.
        if $CONFIG_BUSYBOX [ -f $CONFIG_FILE_CFG ] && abootimg -u $CONFIG_FILE_BOOTIMG -r $CONFIG_FILE_INITRD -f $CONFIG_FILE_CFG; then
            exit 0
        fi
    ;;
esac

exit 1