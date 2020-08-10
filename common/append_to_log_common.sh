#!/bin/bash
# arg1: log directory
# arg2: start_process_date
# arg3: end_process_date
# arg4...: files to append


log_directory=${1}
start_process_date=${2}
end_process_date=${3}
file_name=${4}

common_log_file=${log_directory}/common.log
output_lock_file="${log_directory}/dir_rw.lock"

# Aquire lock
exec 9>$output_lock_file
echo "// Aquire lock ${output_lock_file}"
if flock 9; then   # Blocking wait

    # Append file name, start and end date
    echo "File Name: ${file_name}, Start time: ${start_process_date}, End time: ${end_process_date}" >> ${common_log_file}
    
fi
# Release the lock
exec 9>&-

