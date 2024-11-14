## This goes into /etc/profile.d and does not need +x

# Append history after each command and reload from the file
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Increase the in-memory history list size
export HISTSIZE=10000

# Increase the maximum history file size
export HISTFILESIZE=20000

# Ensure all commands are logged, even those starting with spaces
export HISTCONTROL=ignoredups

# Add timestamps to history entries
export HISTTIMEFORMAT="%F %T "

