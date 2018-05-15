#!/bin/bash
 for h in $(dconf read /org/virt-manager/virt-manager/connections/uris  |  sed 's;[^@]*@\([^/]*\)\/system[^@]*;\1\n;g')
    do for d in $(ssh $h 'virsh -q list --name --all')
        do echo $d $h; done
    done | tee ~/all-vms-on-hosts.txt

