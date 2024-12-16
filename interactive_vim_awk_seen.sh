vim -c '%!awk "\!seen[\$0]++"' "$file"
