#!/usr/bin/env bash

install_rust ()
{
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

# Source footer if it exists
if [ -f "bash_footer.template.live" ]; then
    source bash_footer.template.live
else
    echo "Footer template missing. Skipping..."
fi

