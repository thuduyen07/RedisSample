# check if redis installed
if command -v redis-server &> /dev/null
then
    echo "Redis is installed."
    echo "$(redis-server --version)"
else
    echo "Redis is not installed."
    echo "Installing Redis..."
    brew install redis
    echo "$(redis-server --version)"
fi

# # ask user for kill process on port 7001..7006
# echo "Do you want to kill process on port 7001..7006? (y/n)"
# read kill_process
# if [ "$kill_process" == "yes" ]; then
    for port in {7001..7006}
    do
        pid=$(lsof -t -i:$port)
        if [ -n "$pid" ]; then
            echo "Stopping service on port $port (PID: $pid)"
            kill -9 $pid
        else
            echo "No service running on port $port"
        fi
    done
    ports=(7001 7002 7003 7004 7005 7006)
# # ask other 6 ports for using
# else 
#     echo "Give me 6 ports for using (e.g. 7001 7002 7003 7004 7005 7006)"
#     read port1 port2 port3 port4 port5 port6
#     for port in $port1 $port2 $port3 $port4 $port5 $port6
#     do
#         pid=$(lsof -t -i:$port)
#         if [ -n "$pid" ]; then
#             echo "Stopping service on port $port (PID: $pid)"
#             kill -9 $pid
#         else
#             echo "No service running on port $port"
#         fi
#     done
#     ports=($port1 $port2 $port3 $port4 $port5 $port6)
# fi

# check if cluster-test folder exists
if [ -d "cluster-test" ]; then
    echo "cluster-test folder exists"
else
    echo "cluster-test folder does not exist"
    mkdir cluster-test
    cd cluster-test
    echo "cluster-test folder created"
fi

# check if port instances folders exist
for i in  ${ports[@]}
do
    if [ -d "$i" ]; then
        echo "$i folder exists"
    else
        echo "$i folder does not exist"
        mkdir $i
        echo "$i folder created"
    fi
done

# check if redis.conf file exists
for i in ${ports[@]}
do
    if [ -f "$i/redis.conf" ]; then
        echo "$i/redis.conf file exists"
    else
        echo "$i/redis.conf file does not exist"
        touch $i/redis.conf
        # add content to redis.conf file
        echo -e "port $i\ncluster-enabled yes\ncluster-config-file "$i/nodes_$i.conf"\ncluster-node-timeout 5000\nappendonly yes\nappendfilename "appendonly_$i.aof"" >> $i/redis.conf
        echo "$i/redis.conf file created"
    fi
done

# check if redis-server running
if pgrep -x "redis-server" > /dev/null
then
    echo "redis-server is running"
else
    echo "redis-server is not running"
    # start redis-server
    for i in  ${ports[@]}
    do
        echo "Starting redis-server on port $i"
        redis-server $i/redis.conf &
    done
fi