# Redis Sample

## How to run program:

On macos, double click on `run_program.app`

## Steps
1. Install redis: `brew install redis`
2. Create dotnet project: `dotnet new console -n RedisSample`
3. Add redis for dotnet: `dotnet add package NRedisStack`
4. [Code C#](./Program.cs)
5. Redis cluster:
    a. create cluster test folder:

    ```
    mkdir cluster-test
    cd cluster-test
    mkdir 7001 7002 7003 7004 7005 7006
    ```

    b. add redis configuration file:

    ```
    cd 7001
    echo -e "port 7001\ncluster-enabled yes\ncluster-config-file nodes_7001.conf\ncluster-node-timeout 5000\nappendonly yes" > redis.conf
 
    ```

    c. start redis 7001

    ```
    redis-server ./redis.conf
    ```

    check slot assignment: `redis-cli -h 127.0.0.1 -p 7001 CLUSTER NODES`

    d. create cluster: `redis-cli --cluster create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 127.0.0.1:7006 --cluster-replicas 1`

    e. test cluster's health: `redis-cli --cluster check 127.0.0.1:7001`

## References
- https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/#create-a-redis-cluster
