#!/bin/bash
#        Set Default utility (approximation of VAX SD utility)
#            by Brien Barton (2/1/93).
#
#   To use SD, first source this file to set up the aliases and 
#   initialize the variables (add "source path-to-this-file" to your .bashrc).
#   Then enter the command "sd -h" for help.
#   Try "alias cd=sd" to continue using 'cd' but with the added 'sd' functionality.
#   Set variable _sd_noarg=home to get sd to go to your home directory when
#   invoked with no arguments instead of just displaying the current directory.
#
#   6/23/93 bhb  Created Korn shell version
#   2/6/14  bhb  Ported Korn shell version to bash
#

# This script defines one array variable (_sds) and two functions (sdl and sd)
# that are entered into the user's variable space.  If you use the prompt modification
# feature "sd -p", it also adds the variable "_sdprompt".

# Initialize the array that holds out previous directory paths
if [ -z "$_sds" ]; then
    declare -a _sds=( "." "." "." "." "." "." "." "." "." "." "." )
fi

# Define the 'set directory last' function (shortcut for "sd -l")
sdl() { 
  sd "${_sds[9]}" 
}

# Define the 'set directory' function
sd() {
  
  # If no args, just print current directory and return
  if [ $# -lt 1 ]; then 
    if [ "x${_sd_noarg}" = "xhome" ]; then
        sd ~
    else
        pwd
    fi
    return 0
  fi


  # Process arguments
  while [ $# -ge 1 ]
  do
    local sdarg=$1
    shift

    local sdtmp=""
    local sdfound=""

    case $sdarg in 
    
    -s)     # Save current directory
            _sds[10]="$PWD"
            echo "Saved directory $PWD.  Use command sd -x to return here."
            ;;

    -x)     # Go to saved directory (saved with sd -s command)
            sd "`echo ${_sds[10]}`"
            ;;

    %)      # Go to home directory
            sd "$HOME"
            ;;

    -[lL])  # Go to last (previous) directory
            sd "${_sds[9]}"
            ;;

    -[tT])  # Display directory tree
            if [ -x /usr/bin/tree ]; then
                tree -d
            else
                ls -R | grep ':$' | sed -e 's/[^-][^\/]*\//|--/g;s/:$//;s/$|//;s/--|/  |/g'
            fi
            ;;

    -[hH])  # Help!
            echo ' 
    SD remembers the last 9 unique directories you visited. 
    Usage: 
        sd        ==> display current directory 
        sd dir    ==> goto directory "dir" 
        sd ~      ==> goto home directory
        sd %      ==> goto home directory
        sd ..     ==> go up one directory level
        sd ...dir ==> goto "dir" if found in directory tree
        sd -[0-8] ==> change to one of saved directories
        sd -b     ==> display and select from saved directories
        sd -h     ==> display this help message
        sd -l     ==> go back to last directory you visited
                (also "sdl" does this)
        sd -p     ==> change prompt to reflect current directory
                (enter command again to reset prompt)
        sd -s     ==> explicitly save current directory
        sd -t     ==> display all subdirectories (tree)
        sd -x     ==> goto explicitly saved directory (see sd -s)
  
        '
        ;;

    -[0-8]) # Select a directory by number
        sdtmp=${sdarg#-}
        sd "${_sds[$sdtmp]}"
        ;;

    -[pP])  # Toggle prompt setting feature
        if [ -z "$_sdprompt" ]
        then
            _sdprompt=$PS1        # save current prompt
            PS1="\w(\!) "    # use current dir as prompt
        else
            PS1=$_sdprompt        # set it back
            unset _sdprompt
        fi
        ;;
            
    -[bB])    # Prompt user for one of auto-saved directories
        echo ""
        echo 0 = ${_sds[0]}
        echo 1 = ${_sds[1]}
        echo 2 = ${_sds[2]}
        echo 3 = ${_sds[3]}
        echo 4 = ${_sds[4]}
        echo 5 = ${_sds[5]}
        echo 6 = ${_sds[6]}
        echo 7 = ${_sds[7]}
        echo 8 = ${_sds[8]}
        echo "l = ${_sds[9]} (last)"
        echo "x = ${_sds[10]} (saved)"
        echo ""
        echo -n "Select directory (0-8, x, l): "; read sdtmp
        if [ "x$sdtmp" != "x" ] 
        then
            if [ "x$sdtmp" = "xl" ]; then sdtmp=9 ; fi
            if [ "x$sdtmp" = "xx" ]; then sdtmp=10 ; fi
            sd "${_sds[$sdtmp]}"
        fi
        ;;

    ...*)    # Search for subdirectory
        sdtmp=${sdarg#...}    # remove the ellipses
        sdtmp=( `find . -type d -print 2>/dev/null|grep "/${sdtmp}$"` )
        case ${#sdtmp[*]} in
          1) sd "$sdtmp" ;;
          0) echo "Directory '${sdarg#...}' not found below $PWD" ;;
          *) echo "Multiple matches: "
             for (( i=0; i < ${#sdtmp[*]}; i++ ))
             do
                 echo "$i = ${sdtmp[$i]}"
             done
             echo -n "Enter number of desired directory: "
             local n
             read n
             # Make sure it's a valid choice before using it
             for (( i=0; i < ${#sdtmp[*]}; i++ ))
             do
                 if [ "x$i" = "x$n" ]
                 then
                     sd "${sdtmp[$n]}"
                     break
                 fi
             done
             ;;
        esac
        ;;

    *)    # Assume argument is a directory and attempt to go there
        sdtmp="$PWD"
        builtin cd "$sdarg" >/dev/null
        if [ $? != 0 ] 
        then
            return
        fi
        echo $PWD
        # Don't change saved last directory if we haven't moved
        if [ "$sdtmp" != "$PWD" ] 
        then
          i=0
          while (( i <= 9 ))
          do
            if [ "$sdtmp" = "${_sds[$i]}" ]
            then
                sdfound=yes
                break
            fi
            (( i++ ))
          done

          if [ "x$sdfound" = "x" ]
          then
            # push last dir on "stack"
            _sds=("$sdtmp" "${_sds[0]}" "${_sds[1]}" "${_sds[2]}" "${_sds[3]}" "${_sds[4]}" "${_sds[5]}" "${_sds[6]}" "${_sds[7]}" "$sdtmp" "${_sds[10]}")   
          else
            _sds[9]="$sdtmp"    # just save last directory
          fi
        fi
    esac
  done

  if [ "$sdprompt" != "" ]
  then
    PS1="$PWD(!) "
  fi

}    # end of sd function definition

