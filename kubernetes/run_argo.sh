#!/bin/bash

for i in $(seq -w 02 10); do

    echo "Run argo for ${i} times"

    echo "Submit worklfow"
    argo submit kubernetes/argo/pipeline.yaml --watch

    echo "Move log and copy data"
    ./copy_logs.sh argo/multiple/${i}

done

