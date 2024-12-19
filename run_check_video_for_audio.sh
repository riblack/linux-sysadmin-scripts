mkdir -p ../noaudio
while read file 0<&3; do audio=$(ffprobe -i "$file" 2>&1 | grep -i Audio); if [ -z "$audio" ]; then mv -vi "$file" ../noaudio/; fi; done 3< <(ls)
