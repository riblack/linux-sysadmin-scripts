#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/load_color_codes.def"

ssh-wait-loop() {

    # === Usage ===
    # ./ssh-wait-loop.sh --host 192.168.1.100 --port 2222 --ssh-opts "-X -A -l user"

    # === Config ===
    host=""
    port=""
    ssh_opts=""
    spinner=('|' '/' '-' '\')

    print_usage() {
        echo "Usage: $0 --host <host-or-alias> [--port <port>] [--ssh-opts \"-X -A\"]"
        echo
        echo "Example: $0 --host host1 --ssh-opts \"-X\""
        echo "NOTE: Username is inferred from \$USER unless you use --ssh-opts '-l <user>'"
        echo "Host aliases from ~/.ssh/config are fully supported."
    }

    # === Parse arguments ===
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --host)
                host="$2"
                shift 2
                ;;
            --port)
                port="$2"
                shift 2
                ;;
            --ssh-opts)
                ssh_opts="$2"
                shift 2
                ;;
            -h | --help)
                print_usage
                exit 0
                ;;
            *)
                echo "Unknown argument: $1"
                print_usage
                exit 1
                ;;
        esac
    done

    if [[ -z "$host" ]]; then
        echo "Error: --host is required"
        print_usage
        exit 1
    fi

    # === Trap Ctrl+C to allow clean exit ===
    stop_requested=false
    trap 'stop_requested=true' SIGINT

    # === Wait for SSH ===
    wait_for_ssh() {
        local count=0
        printf "Waiting for %s to become available " "$host"
        while ! nc -z "$host" "${port:-22}" 2>/dev/null; do
            printf "\b%s" "${spinner[$((count % 4))]}"
            sleep 0.5
            ((count++))
            $stop_requested && echo -e "\nExit requested. Quitting..." && exit 0
        done
        echo -e "\n✅ SSH is available on $host"
    }

    # === Main loop ===
    while true; do
        wait_for_ssh
        echo "🔐 Connecting via SSH..."
        ssh ${port:+-p "$port"} $ssh_opts "$host"
        exit_code=$?

        if $stop_requested; then
            echo -e "\nExit requested. Quitting..."
            break
        elif [[ $exit_code -eq 255 ]]; then
            echo -e "\n🔁 SSH dropped (code 255). Waiting to reconnect..."
            sleep 2
        else
            echo -e "\n🚪 SSH exited normally (code $exit_code). Not reconnecting."
            break
        fi
    done

}

# Source footer if it exists
if [ -f "$SCRIPT_DIR/bash_footer.template.live" ]; then
    source "$SCRIPT_DIR/bash_footer.template.live"
else
    echo -e "${RED}Footer template missing. Skipping...${RESET}"
    echo -e "Please ensure 'bash_footer.template.live' exists in the same directory."
fi
