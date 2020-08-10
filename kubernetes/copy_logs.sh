#!/bin/bash
# 

dir_name=${1}
path="/bigdata/yared-experiment/logs/${dir_name}"

#create dir 
mkdir -p ${path}

# Copy log files 
echo " Copying log files to ${path}"
cp /bigdata/yared-experiment/00-unzip/work/logs/common.log "${path}/00-unzip.log" 
cp /bigdata/yared-experiment/01-tsv2csv/work/logs/common.log "${path}/01-tsv2csv.log" 
cp /bigdata/yared-experiment/02-split/work/logs/common.log "${path}/02-split.log" 
cp /bigdata/yared-experiment/03-transform/work/logs/common.log "${path}/03-transform.log" 
cp /bigdata/yared-experiment/04-toarango/work/logs/common.log "${path}/04-toarango.log" 


# Remove 
echo " Removing work, sandox and output files"
rm -r /bigdata/yared-experiment/00-unzip/{work,sandbox,output} 
rm -r /bigdata/yared-experiment/01-tsv2csv/{work,sandbox,output} 
rm -r /bigdata/yared-experiment/02-split/{work,sandbox,output}  
rm -r /bigdata/yared-experiment/03-transform/{work,sandbox,output}  
rm -r /bigdata/yared-experiment/04-toarango/{work,sandbox,output} 

# Copy input data for next round 
echo " Copying input data for next round"
cp /bigdata/yared-experiment/data/201603.zip /bigdata/yared-experiment/00-unzip/input/
cp /bigdata/yared-experiment/data/201604.zip /bigdata/yared-experiment/00-unzip/input/
cp /bigdata/yared-experiment/data/201605.zip /bigdata/yared-experiment/00-unzip/input/
cp /bigdata/yared-experiment/data/201606.zip /bigdata/yared-experiment/00-unzip/input/
cp /bigdata/yared-experiment/data/201607.zip /bigdata/yared-experiment/00-unzip/input/
cp /bigdata/yared-experiment/data/201608.zip /bigdata/yared-experiment/00-unzip/input/

echo " Done"
