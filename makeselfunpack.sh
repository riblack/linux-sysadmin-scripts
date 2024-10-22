#!/usr/bin/env bash

unset -f makeselfunpack
makeselfunpack () 
{ 
    cat <<'EOF'
selfunpack () 
{ 
    read -p "Are you in the right directory? (ctrl + c to abort) ";
cat <<'EOFTARBASE64' | base64 -d | tar -xzvf -
EOF

    tar -czf - "$1" | base64;
    cat <<'EOF'
EOFTARBASE64
}
selfunpack 
EOF

}
makeselfunpack "$@"

