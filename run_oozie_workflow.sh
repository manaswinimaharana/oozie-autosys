#script name: run_oozie_workflow.sh



#$1 = hdfs application path - /er/ajd/adhak/sample_job.xml
#$2 = properties file for Oozie
source profile.sh

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
#getOozieJobStatus()
# you can check status and do things like send informative emails or log something
