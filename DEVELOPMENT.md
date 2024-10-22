# linux-sysadmin-scripts
Script Development Tips

When starting a new script I usually perform the following:

vim (not vi, not nano), maybe vim-enhanced or at minimum vim-common
filename to be the new function name + .sh

#!/usr/bin/env bash

unset -f myfunc
myfunc () 
{ 
    :
}
declare -f myfunc
myfunc

When the script runs then the "cleaned up" function declaration is printed on screen due to the "declare -f myfunc" line.

Additionally you can, in vim, highlight your function definition and the following "declare -f myfunc" line by using the capital V, then send all of this to bash which will then reformat it for you and dump it back in place in the vim editor. Please note that this is a somewhat destructive process because YOU WILL LOSE ANY COMMENTS IN THAT SECTION. The commands in vim would look like this: 1) go to the first line of the function definition 2) press shift+v to begin line highlighting 3) press the down cursor until you reach the end of the function definition and include the next line which is "declare -f myfunctionname" 4) press : 5) complete out this with !bash. Bash will take this and run it which will define the function and declare it back to you.

Functions behave more like you want to expect when dropping multiple lines. If you paste multiple lines without a function wrapper into the bash shell then later lines can be taken as input to previous lines and you aren't getting the results you want. Wrapping your lines in a minimal function definition will allow each line to ask you for input instead of taking a pasted line as input.

chmod +x myfunc.sh

You can make use of bash's -xv to help debug. You can turn it on for the entire script file via "#!/usr/bin/env bash -xv" and it should turn off when the script is done. Additionally you can just focus on a section by surrounding it with "set -xv" (to turn on eXtra Verbosity) and "set +xv" (to turn off extra verbose). If you find that it was left on then you can turn it off with "set +xv".

An additional method for running -xv without modifying the bash script is to have "bash -xv" call the script, like so: bash -xv myfunc.sh arg1 arg2

