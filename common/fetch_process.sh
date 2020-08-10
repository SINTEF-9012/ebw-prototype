#!/bin/bash
# arg1: input file spec              
# arg2: process_job      
# arg3: sandbox directory
# arg4: code directory
# arg5: input directory
# arg6: work directory
# arg7: output directory
# arg8: message queue read url
# arg9: message write read url

input_file_spec=${1}
process_job=${2}
sandbox_directory=${3}
code_directory=${4}
input_directory=${5}
work_directory=${6}
output_directory=${7}
mq_read=${8}
mq_write=${9}

echo '***'

echo '#'
echo '#   Starting: fetch_process'
echo '#'

echo "input_file_spec: ${input_file_spec}"
echo "process_job: ${process_job}"
echo "sandbox_directory: ${sandbox_directory}"
echo "sand: ${code_directory}"
echo "code_directory: ${code_directory}"
echo "input_directory: ${input_directory}"
echo "work_directory: ${work_directory}"
echo "output_directory: ${output_directory}"
echo "mq_read: ${mq_read}"
echo "mq_write: ${mq_write}"
echo '***'


#import log util functions 
. ${code_directory}/util.sh

# Remove the first three arguments to make it easy to pass the remaining params
shift 3

file_directory=${input_directory}

if [ $mq_read != "-" ]; then
    # READ from Message Queue
    echo "Read from message queue"
    file_name=$(${code_directory}/read_from_mq.sh "${mq_read}")
else
    # Check if there are files to process in the input directory
    file_name=$(fetch_file "${input_directory}" "${input_file_spec}")    
fi

# Visit sandbox directory if there are no more files in the input directory or no file names comming from the message queue
if [ -z "${file_name}" ]; then
    file_name=$(fetch_file "${sandbox_directory}" "${input_file_spec}")

    # Point to sandbox directory instead of the input directory
    if [ -n "${file_name}" ]; then
        file_directory=${sandbox_directory}
    fi
fi


if [ -n "${file_name}" ]; then

    echo "// File to process: ${file_name}"
    log_info "Got a file name to be processed" "${file_name}" "$0"

    # Construct Paths
    input_path=${file_directory}/${file_name}
    work_path=${work_directory}/${file_name}

    # Check if file already there
    found_existing="$(find "${work_directory}" -name "${file_name}" | wc -l)"

    if [ "${found_existing}" -eq "0" ]; then

        # Move to Workspace
        echo "  Moving to Workspace ${input_path} ${work_path}"
        mv ${input_path} ${work_path} \
            || handle_error "Error in moving file ${input_path} into workspace ${work_path}" "${file_name}" "$0" "$LINENO"

        log_info "File moved to workspace" "${file_name}" "$0"
        
        # Run the job 
        if [ "${LOG_JOBS}" -eq "1" ]; then
            log_directory=${work_directory}/logs
            mkdir -p $log_directory

            start_process=$(date --utc +%FT%TZ)
            ${process_job} "${work_path}" "$@"
            retn_code=$?
            end_process=$(date --utc +%FT%TZ)

            # Append to common log file
	        ${code_directory}/append_to_log_common.sh "${log_directory}" "${start_process}" "${end_process}" ${file_name} 

        else 
            ${process_job} "${work_path}" "$@"
            retn_code=$?
        fi
        
        if [ ${retn_code} -ne 0 ]; then

            # check if the file been sandboxed before 
            if [[ $file_name == *"SANDBOXFILE"* ]]; then
                sandbox_path="${sandbox_directory}/${file_name}.archived"
            else
                # Attach current timestamp to the filename to make it unique in the sandbox directory
                timestamp=$(date +%s%N) 
                sandbox_path="${sandbox_directory}/SANDBOXFILE_${timestamp}_${file_name}"
            fi

            # Move the file from workspace into the sandbox            
            echo "  Moving to Workspace workspace file into sandbox"
            mv ${work_path} ${sandbox_path}            

            # handle the exception with exit 1
            handle_error "Unable to process file: ${file_name} ... moved to sandbox ${sandbox_path}" "${file_name}" "$0" "$LINENO"

        fi

        # Cleanup
        rm -rf $work_path \
            || handle_error "Error occured while removing file: ${work_path} from the workspace" "${file_name}" "$0" "$LINENO"
            
        log_info "File removed from workspace" "${file_name}" "$0"

        exit 0

    else
        echo "// File ${file_name} already exists in working dir ... skipping operation"        
        log_warning "File already exists in working dir ... skipping operation" "${file_name}" "$0" "$LINENO"

        exit 1
    fi
else
    echo "// No file to process"
    exit 1
fi
