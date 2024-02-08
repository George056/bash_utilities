#!/bin/bash
version=1.3
date=2/5/2024
info_exit=30
default_dir=
file_type=info

if [ $1 = -h ] || [ $1 = --help ] || [ ! $1 ]; then
        echo "notes_viewer.sh [{-c, --clear}, {-v, --version}, {-h, --help} [command [filter1 [filter2]]]"
        echo -e "\tthis command provides help information for various commands, help commands are located in $default_dir, this can be overwritten with environment variable \$LOCAL_QUICK_HELP_DIR"
        echo -e "\t-c, --clear will clear the screen before printing help"
        echo -e "\t-v, --version will print the version and version date; this will terminate command exicution"
        echo -e "\t-h, --help or no argument will print this help; this will terminate command exicution"
        echo -e "\tcommand is the command you are looking for more information on, if no filter is provided it will either show the help information or the subfiles that are valid for filter1"
        echo -e "\tfilter1 is used to show just one section of the help file or to open a sub file"
        echo -e "\tfilter2 is only used if you are opening a subfile, where it will then be used to show just one section"
        echo -e "\tGlobal files"
        ls $default_dir | sed 's/\.info//' | awk '{print "\t\t"$1}'
        echo "-------------------------------------------------------------"
        if [ $LOCAL_QUICK_HELP_DIR ]; then
                echo -e "\tLocal files @ $LOCAL_QUICK_HELP_DIR"
                ls $LOCAL_QUICK_HELP_DIR | sed 's/\.info//' | awk '{print "\t\t"$1}'
                echo "-------------------------------------------------------------"
        fi
        echo -e "\tOther commands"
        echo -e "\t\tscp"
        echo -e "\t\ttssh"
        echo -e "\t\tscd"
        exit $info_exit
elif [ $1 = -c ] || [ $1 = --clear ]; then
        clear
        shift
elif [ $1 = -v ] || [ $1 = --version ]; then
        echo $version
        echo $date
        exit $info_exit
fi

if [ $1 = scp ]; then
        echo 'scp [-r] [user@][source_host:]path [user@][dest_host:]path'
        echo -e '\t use -r for copying directories or multiple files'
elif [ $1 = scd ] || [ $1 = smart_cd ]; then
        scd --help
elif [ $1 = tssh ]; then
        tssh --help
else
        #get the right version of multiline grep
        if [ `uname` = Linux ]; then
                search_cmd=grep
        else
                #unix suport for legacy
                search_cmd=ggrep
        fi

        #check if there are any local help files first
        if [ $LOCAL_QUICK_HELP_DIR ]; then
                #if it ends in a /, remove it
                if [ ${LOCAL_QUICK_HELP_DIR: -1} = / ]; then
                        help_dir=${LOCAL_QUICK_HELP_DIR:0:-1}
                else
                        help_dir=$LOCAL_QUICK_HELP_DIR
                fi

                if [ -f $help_dir/${1}.${file_type} ]; then
                        if [ $2 ]; then
                                line_count=`$search_cmd -i -B1 "^$2" $help_dir/${1}.${file_type} | head -1 | awk '{print \$2}' | xargs -I NNN echo NNN + 1 | bc`
                                if [ ! $line_count ]; then
                                        eval $search_cmd -i "$2" $help_dir/${1}.${file_type}
                                else
                                        eval $search_cmd -i -A${line_count} "^$2" $help_dir/${1}.${file_type}
                                fi
                        else
                                grep -v '^[#]' $help_dir/${1}.${file_type}
                        fi
                elif [ -d $help_dir/${1} ] && [ $2 ]; then
                        if [ $3 ]; then
                                line_count=`$search_cmd -i -B1 "^$3" $help_dir/${1}/${2}.${file_type} | head -1 | awk '{print \$2}' | xargs -I NNN echo NNN + 1 | bc`
                                if [ ! $line_count ]; then
                                        eval $search_cmd -i "$2" $help_dir/${1}.${file_type}
                                else
                                        eval $search_cmd -i -A${line_count} "^$3" $help_dir/${1}/${2}.${file_type}
                                fi
                        else
                                grep -v '^[#]' $help_dir/${1}/${2}.${file_type}
                        fi
                elif [ -d $help_dir/${1} ]; then
                        ls $help_dir/${1} | tr '.' ' ' | awk '{print $1}'
                fi
        fi

        #check the global help files
        help_dir=$default_dir
        if [ -f $help_dir/${1}.${file_type} ]; then
                if [ $2 ]; then
                        line_count=`$search_cmd -i -B1 "^$2" $help_dir/${1}.${file_type} | head -1 | awk '{print \$2}' | xargs -I NNN echo NNN + 1 | bc`
                        if [ ! $line_count ]; then
                                eval $search_cmd -i "$2" $help_dir/${1}.${file_type}
                        else
                                eval $search_cmd -i -A${line_count} "^$2" $help_dir/${1}.${file_type}
                        fi
                else
                        grep -v '^[#]' $help_dir/${1}.${file_type}
                fi
        elif [ -d $help_dir/${1} ] && [ $2 ]; then
                if [ $3 ]; then
                        line_count=`$search_cmd -i -B1 "^$3" $help_dir/${1}/${2}.${file_type} | head -1 | awk '{print \$2}' | xargs -I NNN echo NNN + 1 | bc`
                        if [ ! $line_count ]; then
                                eval $search_cmd -i "$2" $help_dir/${1}.${file_type}
                        else
                                eval $search_cmd -i -A${line_count} "^$3" $help_dir/${1}/${2}.${file_type}
                        fi
                else
                        grep -v '^[#]' $help_dir/${1}/${2}.${file_type}
                fi
        elif [ -d $help_dir/${1} ]; then
                ls $help_dir/${1} | tr '.' ' ' | awk '{print $1}'
        fi
fi

# version log
# 1.0 -- George Cook -- 1/24/2024
# initial version
# 1.1 -- George Cook -- 1/25/2024
# added support for user defined help files using $LOCAL_QUICK_HELP_DIR environment variable
# finds help files programatically instead of being hard coded
# support for help directories instead of just files (ie. $help_dir/bash/variables.info)
# 1.2 -- George Cook -- 1/31/2024
# added version/date and a version flag
# added clear flag
# added help for notes_viewer
# 1.3 -- George Cook -- 2/5/2024
# added the ability to search for non-header sections
