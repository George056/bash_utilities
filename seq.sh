#!/bin/bash

if [ $# = 1 ]; then
        for (( i=0; i < $1; i++ )); do
                echo $i;
        done

elif [ $# = 2 ]; then
        for (( i=$1; i < $2; i++ )); do
                echo $i
        done

elif [ $# = 3 ]; then
        for (( i=$1; $i < $2; i=$i+$3 )); do
                echo $i;
        done

else
        echo seq takes 1 - 3 arguments
        echo syntax: seq endpoint
        echo \t starts at 0, enpoint excluded
        echo syntax: seq startpoint endpoint
        echo \t starts at startpoint, endpoint excluded
        echo syntax: seq startpoint endpoint incramentvalue
        echo \t starts at startpoint, endpoint excluded
fi
