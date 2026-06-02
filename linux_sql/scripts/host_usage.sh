#!/bin/bash

# assign positional arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# check number of parameters
if [ "$#" -ne 5 ]; then
	echo "Illegal number of parameters"
	exit 1	
fi

# save machine statistics to variables
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

# fetch system usage data

memory_free=$(echo "$vmstat_mb" | awk '{print $4}' | tail -n1 | xargs)
cpu_idle=$(echo "$vmstat_mb" | tail -n1 | awk -v col="15" '{print $col}')
cpu_kernel=$(echo "$vmstat_mb" | tail -n1 | awk -v col="14" '{print $col}')
disk_io=$(echo "$vmstat_mb" | tail -n1 | awk -v col="10" '{print $col}')
disk_available=$(df -m / | awk 'NR==2 {print $4}')

# find timestamp
timestamp=$(vmstat -t | tail -n1 | awk '{print $18, $19}')

# subquery to find matching id in host_info table
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

# insert statement 
insert_stmt="INSERT INTO host_usage (\"timestamp\", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) \
VALUES ('$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"

#set up env var for pql cmd
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
