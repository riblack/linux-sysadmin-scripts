# Vim Notes

Note: tldr; As a sysadmin I use s,,, for my sed commands instead of s///
If I were grading English papers then I would certainly use s/// for my sed commands, but the "/" gets in the way of actual sysadmin work (you know, pathnames and much more), so another sed delimiter must be chosen. Since I'm not using sed on English papers then my likelyhood of encoutering a comma (,) is way less than a slash (/), sure there are the occasional commas, but by and large by choosing a comma as my sed delimeter then my life as a sysadmin is a lot easier. I don't know why every sed example out there is listed with slashes (s///) but oh well. A sysadmin worth his (or her) salt is going to be using s,,, instead of s///. So don't be confused if you see my sed commands with commas instead of slashes, ex: s,replace this,with that,  Now that I've written up this note I can go back to using s,,, as is my normal instead of rewriting every sed attempt as s///.

Yes, there are a lot of vim cheat sheets out there. This here is a subset of the vim commands that I know from (generally) most used to least used. One doesn't need to be a master to get a lot of use out of vim. With this knowledge I work with vim pretty well, I hope it helps you as well.

Changes from within vim are not (not usually) permanent, so feel free to try all the commands here.
Permanent vim changes are specified in ~/.vimrc.

Before we go too far let's cover how to get out in case you mess up:

:q 	normal quit (exit), informs you if there are unsaved changes
:q! 	force quit - use this if you goofed the file and you just want to get out without saving any changes.
:qa! 	force quit all files - use this if you goofed the file and you just want to get out without saving any changes.

If you are stuck, then maybe you are in an insert mode (you should see "-- INSERT --" in the lower left line), so try ESC followed by :q to exit.

If you are still stuck, then maybe you are busy recording a macro (you should see "Recording @..." in the lower left line), press q and "Recording @..." should go away, then you can exit with :q

And in case you actually want to save something, then here is how to save (write):

:w 	save changes
:wq 	save changes and quit (exit)

Note: Please be careful with the force (!) operator. If I catch you using combinations with force (!) as common practice then please know this, I will find you.

Vim Read Only Mode

Also worth noting is that vim has a "read only" mode if you want to use vim features (line numbers, !grep, etc) but don't want to risk damaging a file. I love using the vim editor to look at things because the interface is familiar and I have access to tools such as grep, sed, awk, sort, uniq, etc. I make sure to use -R (read only mode) when looking at files I don't intend to make a change to - as a sysadmin this also shows to anyone looking at my history that I'm just looking and not touching:

vim -R 	Open the file(s) as read only. Example: vim -R README.txt

Commands

There are a lot of actions that can be performed, including internal commands and external commands. Often you begin by specifying the lines to operate on. I know of three choices 1) % all lines, 2) visual selection using one of the v keystrokes, or 3) specifying a range via line numbers.

Note - Line Numbers:

:set nu 	turn on line numbers
:set nonu 	turn off line numbers

If you will be visually selecting content then begin with one of the v keys, then begin command mode (:)

v 		begin selecting by characters
shift + v 	select by lines
ctrl + v 	select a block

: 	to begin command mode

If you will be using all lines (%) or a range of lines then begin with starting command mode (:), then give the range:

: 	to begin command mode

i.e.

:% 	specify all lines
:1,	specify from line 1 to this line (including this line)
:,$ 	specify from this line (including ths line) to the end of the file
:5,30 	specify lines 5 through 30 (inclusive)

Once you are done specifying the lines (whether visually or by range) and entered command mode (:), then give a command:

Two such command examples are internal sed and external sed:

s 	internal sed command
!sed 	external sed command
!grep 	external grep command

Note - unhighlight items:

:nohls 	unhighlight items due to your last search (or sed command)
:set nohls 	turn off highlighting (this session only - not permanent)
:set hls 	turn on highlighting (this session only - not permanent)

Some examples could look like the following:

:1,20s/^/HI MOM: /
:,$!sed -e 's/^/THIS IS REALLY COOL: /'
:%!grep .
:8,10!grep .

Visual selection and command will look differently because it automatically specifies the visual range as :'<,'> once you enter command mode. So just carry on as normal:
:'<,'>
:'<,'>s/^/OH THIS IS COOL/

You can duplicate the previous selection by just calling it back without specifying the visual range again. In this example let's indent 4 spaces, then let's repeat that without visually selecting:
shift +v and select some lines
:s/^/    / 	to add 4 spaces to the beginning of the line
: (up) (enter) 	to repeat the last one without re-specifying the range again
: (up) (enter) 	to repeat the last one without re-specifying the range again
: (up) (enter) 	to repeat the last one without re-specifying the range again
: (up) (enter) 	to repeat the last one without re-specifying the range again

Note - undo and redo:

u 		undo previous actions
ctrl + r 	redo previous undo

More examples of internal command would be:
:1,s/^/THIS IS COOL: /

An example external command would be:
:,$!sed -e 's/^/THIS IS REALLY COOL: /'

An example run wich will filter out blank lines

1) shift + v to begin highlighting lines
2) move cursor to highlight desired lines
3) : to start entering a command
4) ! for external command
5) grep . to keep lines with content and get rid of blank lines, so in all:
:!grep .

Have bash reformat a function for you (see the example to highlight lines)

1) After your function definition add "declare -f yourfunctionname"
2) Use shift + v to highlight your function as well as the declare -f myfunc
3) have Bash perform this reformat with :!bash
In all it would look like the following:
(add declare -f thisismyfunction just after your function definition)
shfit + v, highlight all of your function including the declare -f line, 
:!bash, success. Warning: this "declare -f xyz" process deletes comments.

common task - add a variable to the middle of a line
go find the variable you need to add in either from a previous use or from its definition
i.e. "${mycoolvariable}" or mycoolvariable
delete and undelete the variable from its original location with something like any of:
b or B to jump to the beginning of the variable
deu
dEu
ddu
split the line at the spot that needs the variable (i or a for insert, enter to split)
o to open a new line
p to paste in the variable that you brought
k to go up to the first of the 3 lines,
J (or gJ) to join these two lines, and again to join lines 2 and 3.
or can do 3J or 3gJ to do all 3 lines with (or without) spaces

swap two lines with: ddp

~ 		on a character to toggle case
cw 		to "change word" from cursor to end of word
u 		undo
ctrl + r 	redo
ctrl + e 	move the contents of the screen up (stationary cursor)
ctrl + y 	move the contents of the screen down (stationary cursor)
:f 		what is this filename
:w newfilename 	save this file contents to somewhere else (does not change the behavior of :w)
/ 		search
# 		search this word backwards
* 		search this word forwards
n		next match (continue in "this" direction)
N		previous match (continue in the "opposite" direction)
:n 		next filename to edit if editing multiple files
:N 		previous filename to edit if editing multiple files
:prev 		previous filename to edit if editing multiple files
:vsplit 	split the screen vertically
ctrl + w ctrl + w 	to jump to the other split
:split 		split the screen horizontally
ctrl + w q 	close out a split
gg 	jump to the beginning of the file
G 	juump to the end of the file
o 	open a new line after this line
O 	open a new line before this line
i 	begin insert mode right here before the cursor
I 	begin insert mode at the beginning of this line
a 	begin insert mode after the cursor
A 	begin insert mode at the end of this line
^ 	jump to the beginning of this line
$ 	jump to the end of this line
dd 	delete a line (also places deleted contents into the buffer)
D 	delete from cursor to end of line (also places deleted contents into the buffer)
yy 	yank a line (places the yanked contents into the buffer)
p 	paste contents from buffer
b 	back (small)
w 	forward (small)
B 	back (big)
W 	forward (big)
e 	end of word
E 	end of word (big)
J	join two lines (with the usual single space)
gJ 	join two lines (without a space)
2 	use a number before any of these for a multiplier effect (i.e. 5w)
dd 	delete line

Use external sort, uniq, grep, sed, awk, or whatever
shift + v
:!grep .
:!sort

:set nu 	Turn on line numbers
:set number
:set nonu 	Turn off line numbers

:set nohls 	Unhighlight stuff (i.e. from the last search you did)

% 	specify all lines
: 	begin command mode
:w 	write
:w! 	force write (be careful - uhh, don't do this)
:wq 	write quit
:wq! 	force write quit (do you know what you are doing? - don't do this)
:q 	quit
:q! 	force quit (I don't want to save any content, I goofed, just let me out without saving anything)

:r 	read

x 	delete the character under the cursor
X 	delete the character to the left of the cursor

dw 	delete this word
dW 	delete this word (big)
5dw 	delete the next 5 words
5dW 	delete the next 5 words (big)

d(down arrow) 	delete this line and the next
d(up arrow) 	delete this line and the one above
k 	move up one line
d 	move down one line
l 	move right one character
h 	move left one character

Comman tasks

Open a new line and paste in the buffer
o ESC p
Often followed by up (k) and join (J)
k shift + j

r 	replace character
R 	overwrite mode
s 	delete character and enter insert mode
S 	delete this entire line and enter insert mode

U 	undo all edits on this single line

Let's say you want to pull in stuff from ls, or ls and grep, from within vim:

:r!ls /path/to/dir
:r!ls /path/to/dir | grep mysearchstring

Open two files and then can yyp from one file to the other
vim file1 file2
yy
:n
p

