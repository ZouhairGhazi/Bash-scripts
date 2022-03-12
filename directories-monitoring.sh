#!/bin/bash 

humanReadable='' # Set the output to be human readable (Size in K) if -h is passed as argument.

sortResult="" # Sort the output by size in reverse order if -s is passed as argument.

regex='.' # Target specific directories and possibly files depending on the passed regular expression after -r argument.

directFiles='-type d' # Show only directories by default, and if -f is passed as argument, files will be considered too.

hiddenFiles='--exclude "*/.*"' # Exclude hidden directories and files by default, show them if -a is passed as argument.

outputInFile= # Flag variable to manage if the output is to be displayed in console, or written in a seperate file. 
outputFile="" # if -o is passed as argument, and a direction file is passed after it, which is handled by this variable.

directory=$(pwd) # Current directory, to serve as default if -d with argument aren't passed.

args=("$@") # An array containing the arguments passed so we can loop over them.

# Looping over the array to handle the output depending on each argument.

for i in ${!args[@]}
    do
        if [ ${args[i]} == '-d' ]; 
        then # If the -d argument is passed, we add the -d parameter followed by the targetted directory in the du command.
            if [[ ${args[i+1]} == /* ]]; # This if block is to test on how the passed directory is written, with a leading /.
            then
                directory=${args[i+1]}
            else
                directory=$(pwd)/${args[i+1]}
            fi
        elif [ ${args[i]} == '-h' ]; 
        then # If the -h argument is passed, we add the -h paramter to the du command since it is a native functionality.
            humanReadable=' -h '
        elif [ ${args[i]} == '-s' ]; 
        then # If the -s argument is passed, we add the sort command in a pipeline to sort the output of the first command, it being the unsorted result.
            sortResult=" | sort -rh   " # The -hr option is for reverse sorting 
        elif [ ${args[i]} == '-r' ]; 
        then # If the -r argument is passed, a regular expression is expected after it to control the output of the command.
            regex=${args[i+1]}
        elif [ ${args[i]} == '-f' ]; 
        then # If the -f argument is passed, we will also consider files in the output.
            directFiles=' -type d,f '
        elif [ ${args[i]} == '-a' ]; 
        then # If the -a argument is passed, we empty the hiddenFiles flag to be able to show the hidden files.
            hiddenFiles=""
        elif [ ${args[i]} == '-o' ]; 
        then # If the -o argument is passed, we put the output in the indicated file, which is passed right after.
            outputFile=${args[i+1]}
            outputInFile=">> ${args[i+1]} "
        fi
    done
if [ ! -d $directory ]; then  # We handle the case where the passed argument after -d is either non existant, or a file.
    echo "The sought directory cannot be found, or the passed argument is in fact a file."
    exit 1
fi
if  [ -w outputFile ]; then  # We check if the file exists, and if the user has access to write in it.
    echo "The file cannot be found, or you don't have the required level of access to write in it."
    exit 1
fi
# The last test is on the output flag, to see if we should write to the console or in the indicated file. 
if [ ! "$outputFile" ==  "" ]; then
    echo  -e 'Size \t Directory' > $outputFile
else 
    echo  -e 'Size \t Directory'
fi

# With all the gathered variables, we replace them in the following find expression to get the final output.
# the max depth parameter is to indicated that we don't want the files going in deeper than the first level, which are direct directories.
# As indicated above, the sort command is put in a pipeline so it had to go last in the expression in order to sort the final result before outputing
sh  -c  "find $directory  -maxdepth 1 -regex ".*${regex}.*"  ${directFiles} -exec du --max-depth=0  $hiddenFiles  $humanReadable  {}   \; ${sortResult} ${outputInFile}" 