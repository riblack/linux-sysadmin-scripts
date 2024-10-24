#!/bin/bash

ipa config-mod --defaultshell=/bin/bash

# verify the change
# ipa config-show

# verify by testing
# ipa user-add testuser --first="Test" --last="User"
# ipa user-show testuser

