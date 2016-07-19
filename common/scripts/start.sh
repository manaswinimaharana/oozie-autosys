#!/bin/bash
parentdir="$(dirname $(dirname "$(pwd)"))"
bash run_oozie_workflow.sh /tmp/oozie-autosys/workflow.xml ${parentdir}/examples/scripts/job.properties
