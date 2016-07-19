#!/bin/bash

parentDir="$(dirname $(dirname "$(pwd)"))"
hdfs dfs -mkdir -p  /tmp/oozie-autosys
hdfs dfs -rm -r /tmp/oozie-autosys/*
hdfs dfs -put ${parentDir}/examples/scripts/workflow.xml /tmp/oozie-autosys
hdfs dfs -put ${parentDir}/examples/scripts/script.q /tmp/oozie-autosys
