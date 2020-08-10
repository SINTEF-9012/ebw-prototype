#!/bin/bash
# arg1: work_path
# arg2: code directory
# arg3: input directory
# arg4: work directory
# arg5: output directory
# arg6: mq_read
# arg7: mq_write
# arg8: transformation_json_full_path

work_path=${1}
code_directory=${2}
input_directory=${3}
work_directory=${4}
output_directory=${5}
mq_write=${7}
transformation_json_full_path=${8}

echo '#'
echo "#  Starting Process: toarango ${work_path}"
echo '#'

#import log util functions 
. ${code_directory}/util.sh

# Construct Paths
file_name=${work_path##*/}
file_name_no_ext=${file_name%.*}
temp_work_directory=${work_directory}/${file_name_no_ext}
work_path_results=${temp_work_directory}/results


# Debug: Show Paths
echo "!! work_path_results", ${work_path_results}
log_info "Started transforming a csv file ${file_name} to Arango-DB values" ${file_name} "$0" 

# Making Results Directory
mkdir -p ${temp_work_directory}
mkdir -p ${work_path_results}

# Transforming
echo "   Transforming to Arango Graph"
cd ${temp_work_directory}
node \
    /code/Datagraft-RDF-to-Arango-DB/transformscript.js \
    -t ${transformation_json_full_path} \
    -f ${work_path} \
    || handle_error "Error while transforming a file: ${file_name} into arango graph" "${file_name}" "$0" "$LINENO"

# back to root directory 
cd /

log_info "Done transforming a csv file ${file_name} into arango graph" ${file_name} "$0"

# Move the files to output and write the new url to the message queue
${code_directory}/move_to_output.sh ${code_directory} ${mq_write} ${output_directory} ${work_path_results}/* \
    || handle_error "Error occured while moving a tranformed file into output directory" "${file_name}" "$0" "$LINENO"


# Cleanup
rm -rf $temp_work_directory
log_info "Removed temporary working directory: ${temp_work_directory}" ${file_name} "$0"

echo '   Done'

