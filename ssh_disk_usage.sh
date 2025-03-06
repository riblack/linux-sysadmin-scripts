#!/bin/bash

while read -r sys 0<&3; do
    echo -n "##### $sys ##### "
    \ssh -o ConnectTimeout=5 "$sys" '
        echo -n "$(hostname) "
        df -P -k -x tmpfs -x devtmpfs -x overlay -x squashfs -x nfs -x cifs 2>/dev/null |
        awk "
        NR>1 && !seen[\$1]++ && \$2 ~ /^[0-9]+$/ {
            total+=\$2 / 1024 / 1024
            used+=\$3 / 1024 / 1024
        }
        END {
            if (total>0) printf \"%.2fG %.2fG\n\", total, used;
            else print \"ERROR\"
        }"
    ' || echo "SSH_FAILED"
done 3< <(cat -) 2>&1 | tee report_ssh_disk_details_$(date +"%Y%m%d_%H%M%S").txt

