#!/bin/bash
sleep 90
# Mount after delay (not via fstab) since NFS node needs time to boot too
mount nfs:/nfs /nfs