#!/bin/bash
# 
# arg1: mq_write
# arg2: message

mq_write=${1}
message=${2}

# example output of kubetools when there is a message in the queue
#-----------------------------------------------------------------
# 2020/05/01 17:23:43 queue message sent at: 2020-05-01 17:23:43.951256941 +0200 CEST
#-----------------------------------------------------------------

# if the message successfully, it will return a line having key words of 'queue message sent'
result=$(kubetools queue send "${mq_write}" "${message}" 2>&1 | grep 'queue message sent')

echo ${result}


