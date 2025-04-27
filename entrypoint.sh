#!/bin/bash
set -e

# Start SSH for Hadoop
service ssh start

# Format NameNode (only if not formatted)
if [ ! -f /usr/local/hadoop/HDFS/dfs/name/current/VERSION ]; then
    echo "Formatting NameNode..."
    hadoop namenode -format -force
fi

# Start Hadoop services
echo "Starting Hadoop..."
start-dfs.sh
start-mapred.sh

# Keep container alive
tail -f /dev/null

