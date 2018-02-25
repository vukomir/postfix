#!/usr/bin/env bash

umask 0002

INIT_DIR=$(dirname $0)/init

for file in `ls -1 $INIT_DIR/ | sort`; do
    file=$INIT_DIR/$file

    if [ -x $file ]; then
        sh $file
    fi
done

supervisord