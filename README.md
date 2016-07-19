oozie-autosys
Autosys (CA workload automation) is a batch job scheduling and monitoring tool, mostly used to automate unix based production workloads. Three of the most enticing features of Autosys are “Maturity”, “Ease of use” and “GUI based”, which makes it a preferred enterprise scheduler. Apache Oozie is a web-server based and most recommended workflow scheduler for Hadoop jobs. Each of system has its own idiosyncrasies , but a seamless integration benefits all.

The assumption here is Autosys is already installed on the CDH cluster. It is recommended to set it up on one of the edge node/gateway(s).

Follow the below instructions to setup your first test/sample oozie-autosys workflow

Step 1: Download the project from this repository.

Step 2: untar/unzip the downloaded directory

Step 3: run setup.sh under the common directory

$ bash setup.sh

Ensure you have write permission to /tmp directory in HDFS. This example will use the /tmp location instead of application.

This script will create the application workflow directory under /tmp/oozie-autosys.

Step 4: edit the profile.sh under common directory and replace the <<..>>

    export nameNode=<<NAME_NODE_URL>>:8020
    export jobTracker=<<JOBTRACKER>>:8032
    export OOZIE_URL=<<OOZIE_SERVER>>:11000/oozie/
    e.g.
    export nameNode=hdfs://quickstart.cloudera:8020
    export jobTracker=quickstart.cloudera:8032
    export OOZIE_URL=http://quickstart.cloudera:11000/oozie/
Step 5: You are now all set to test the workflow locally before running it from Autosys

    [ec2-user@ip-172-31-7-34 common]$ bash start.sh 

    oozie job -D oozie.wf.application.path=/tmp/oozie-autosys/workflow.xml -D       jobTracker=ip-172-31-10-118.ec2.internal:8032 -D nameNode=hdfs://ip-172-31- 10-118.ec2.internal:8020 -config /home/ec2-user/oozie-autosys-master/scripts/job.properties -run
    Running the Oozie job
    job: 0000001-160527173457260-oozie-oozi-W
    The Oozie workflow id is: 0000001-160527173457260-oozie-oozi-W
    *************************************************
     Oozie job status for 0000001-160527173457260-oozie-oozi-W
    *************************************************
    The workflow status is : RUNNING
    The workflow status is : RUNNING
    The workflow status is : RUNNING
    The workflow status is : RUNNING
    The workflow status is : RUNNING
    The workflow status is : RUNNING
    The workflow status is : RUNNING
    The workflow status is : RUNNING
    The workflow status is : RUNNING
    The workflow status is : SUCCEEDED

    [ec2-user@ip-172-31-7-34 common]$ 
Step 6: Once the above command runs successfully, create the below command job in Autosys.Replace ${APP_PATH} with the path of the above directory and the ${GATEWAY_HOST_NAME} with the hostname of the egde node

    /****** SAMPLE CMD JOB *********/
    insert_job: SAMPLE_CMD_JOB job_type: CMD
    box_name: SAMPLE_BOX_JOB
    command: ${APP_PATH}/run_oozie_workflow.sh  sample_job.properties
    machine: ${GATEWAY_HOST_NAME}
    owner: sample
    permission: 
    date_conditions: 0
    description: “Runs the sample oozie workflow”
    std_out_file: “${APP_PATH}/autosys/${AUTO_JOB_NAME}_${AUTORUN}.log”
    std_err_file: “${APP_PATH}/autosys/${AUTO_JOB_NAME}_${AUTORUN}.err”
    alarm_if_fail: 1
    profile: “${APP_PATH}/scripts/profile.sh”
    timezone: EasternTime
Step 7 : Once the Autosys box job has been created, force-start the Job and watch the magic. You can both run and re-run the jobs now.
