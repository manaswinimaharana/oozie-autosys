#!/bin/bash
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#script name: run_oozie_workflow.sh
#$1 = hdfs application workflow path - /er/ajd/adhak/sample_job.xml
#$2 = properties file for Oozie

#Sourcing the common properties for the script 
# e.g. jobTracker, nameNode , oozie URL, impala connection string ....
#This could be a file on the edge node or you may place these configurations in a Database
#write a light weight java client to fetch te values

sourceDir=`dirname $0`
source ${sourceDir}/profile.sh

#This step ensures the oozie job is killed with any interupt signal
trap 'killOozieJob' SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP SIGQUIT

killOozieJob() {
echo "Killing the Oozie job"
if [ '${oz_job_id}' == '' ] ; then
          echo "The oozie job_id cannot be empty.Failed to kill the oozie job"
          exit 1
fi
$(oozie job -kill ${oz_job_id})
exit 1
}

#Runs a given oozie workflow
runOozieJob(){
echo "Running the Oozie job"
run_result=`eval ${job}`
echo ${run_result}
if [ $? -ne 0 ]; then
    #do something
      exit 1 
else 
     oz_job_id=`echo ${run_result} | awk -F ":" '{print $2}' | tr -d ' '` 
     echo "The Oozie workflow id is:" ${oz_job_id}
fi
}

#Poll oozie for status - method 1  
#use this method when an interval of less than 60 seconds is needed

getOozieJobStatus(){
   oz_job_id=${1}
    if [ '${oz_job_id}' == '' ] ; then
          echo "The oozie job_id cannot be empty"
          exit 1
   fi
   echo "*************************************************"
   echo " Oozie job status for ${oz_job_id}"
   echo "*************************************************"

  job_status=$(oozie job -info ${oz_job_id} | grep Status | sed -e '2d;s/ //g;' | awk -F ":" '{print $2}') ;
  echo "The workflow status is : ${job_status}"
 
if [ "${job_status}" == "SUCCEEDED" ]; then 
        echo "The workflow status is : ${job_status}"  
	return 0
elif [ "${job_status}"  ==  "KILLED" ]  ||  [ "${job_status}" == "FAILED" ]; then 
        echo "The workflow status is : ${job_status}"  
	return 1
elif [ "${job_status}" == "RUNNING" ]; then 
     while [ "${job_status}" == "RUNNING" ]; do 
       sleep 5 
      action_name=$(oozie job -info ${oz_job_id} | grep RUNNING | awk -F " "  '{print $1}' | awk 'NR==2');
      echo "The workflow status is : ${job_status}"
      job_status=$(oozie job -info ${oz_job_id} | grep Status | sed -e '2d;s/ //g;' | awk -F ":" '{print $2}') ; 
      if [ "${job_status}" == "SUCCEEDED" ]; then
      echo "The workflow status is : ${job_status}" 
      return 0 
    elif [ "${job_status}" == "KILLED" ] || [ "${job_status}" == "FAILED" ]; then
       echo "The workflow status is : ${job_status}" 
	return 1
    fi 
  done 
fi 
}



job="oozie job -D oozie.wf.application.path=${1} -D jobTracker=${jobTracker} -D nameNode=${nameNode} -config ${2} -run" 

echo ${job}
runOozieJob
getOozieJobStatus ${oz_job_id}

