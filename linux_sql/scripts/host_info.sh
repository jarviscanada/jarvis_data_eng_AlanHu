#!/bin/bash

# assign command line positional arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5


# check number of args
if [ "$#" -ne 5  ]; then
	echo "Illegal number of parameters"
	exit 1
fi

# save machine statistics
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

# system hardware info
lscpu_out=$(lscpu)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | awk -F: '/L2/ {print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | awk -F: '/Model name/ {
    match($2, /([0-9.]+)GHz/, m);
    if (m[1] != "") print m[1] * 1000;
}')
l2_cache=$(echo "$lscpu_out" | awk -F: '/L2/ {print $2}' | xargs | cut -d" " -f1)
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

insert_stmt="INSERT INTO host_info (
  hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem
) VALUES (
  '$hostname', $cpu_number, '$cpu_architecture', '$cpu_model',
  $cpu_mhz, $l2_cache, '$timestamp', '$total_mem'
);"

#set up env var for pql cmd
export PGPASSWORD=$psql_password
#Insert date into a database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
