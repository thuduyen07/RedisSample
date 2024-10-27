# Redis Sample

## How to run program:

On macos, double click on `run_program.app`

## Tóm tắt nội dung kiến thức:

![](./redis_explain_img.jpg)


Redis là một hệ thống lưu trữ dữ liệu dạng key-value giúp truy xuất nhanh.

Về cơ bản, Redis lưu trữ dữ liệu hoàn toàn trong RAM (`in-memory`) dưới dạng các cặp `key-value`, đây là lý do lớn nhất giúp chúng truy xuất nhanh. 

Tuy nhiên, việc lưu dữ liệu trong RAM có thể gặp một số bất cập, vì thế redis còn hỗ trợ  `persistency` , là khả  lưu trữ dữ liệu vào đĩa cứng tránh mất dữ liệu khi khởi động lại Redis hoặc khi máy chủ gặp sự cố. Có 2 phương  persistency là `snapshot` và `append only file (AOF)` 

Với snapshot, redis sẽ tạo các ảnh chụp dữ liệu sau một khoảng thời gian hoặc một lượng thao tác nhất dùng cơ chế `forking`, lưu thành tệp .rdb, các tệp này được lưu trên đĩa cứng và có thể phục hồi khi khởi động lại Redis.

Cơ chế forking là một tiến trình tạo bản sao dữ liệu trong khi hệ thống vẫn xử lý các request từ client mà không làm gián đoạn dịch vụ(`copy-on-write`). Cụ thể, rong quá trình snapshot, nếu có dữ liệu thay đổi trên dữ liệu trong tiến trình , redis sẽ chỉ sao chép các phần dữ liệu vùng bộ nhớ mới, giúp tối ưu hoá bộ nhớ

Với AOF, ghi lại mọi theo  ghi dưới dạng log thành các tệp .aof, các tệp này cũng được lưu trên đĩa cứng và có thể phục hồi khi khởi động lại Redis.

Hơn thế nữa, Redis cung cấp `Redis Cluster`, là tính năng giúp phân phối dữ liệu trên nhiều  nút trong một  nhằm mở rộng quy mô. Về kiến trúc, redis cluster gồm nhiều nút, mỗi nút là một máy chủ độc lập. Các nút có thể là `master` , là nút chính chịu trách nhiệm lưu trữ và quản lí một phần dữ liệu; hoặc là các `replica` , là các nút sao lưu giúp tăng tính khả dụng (tự thay master khi gặp sự cố) và phục hồi dữ liệu khi xảy ra sự cố. Để chia nhỏ dữ liệu và phân phối chúng giữa các nút, redis cluster phương pháp `sharding` 

Redis cluster không gian key thành 16384 slots, mỗi slot sẽ được gán cho một master node trong cluster. Mỗi key sẽ được ánh xạ đến một slot dựa trên hàm băm để xác định vị trí lưu trữ. Khi một key được thêm vào, hàm băm sẽ tính toán giá trị slot để xác định node sẽ lưu trữ dữ liệu của key đó. Như vậy, dữ liệu sẽ được phân phối đều giữa các nút giúp hệ thống tự động cân bằng tải. Ví dụ có một cluster có 4 master node và 16 replicas, xác định vị trí lưu dữ liệu của key 42328:

1. Sử dụng hàm băm modulo 16384 để tính slot thuộc về:
    
    slot = hash(42328)%16384 = 9560
    
2. Giả sử phân phối slot quản lí của 4 master node như sau
    - master 1: 0-4095
    - master 2: 4096-8191
    - master 3: 8192-12287
    - master 4: 12288-16384
3. Xác định master node mà key thuộc về: master 3
4. Các replica của master 3 cũng có thể sao lưu dữ liệu của key 42328.

Như vậy, master 3 và các replica của nó là các vị trí lưu dữ liệu của key 42328

Ngoài ra, `Redis Sentinal` là một tính năng khá hay của Redis, nó cho phép giám sát, tự động khôi phục, thông báo và cung cấp thông tin. Cụ thể:

Sentinal `giám sát` tình trạng các máy chủ (kể cả master và replicas) bằng cách thường xuyên gửi lệnh  để phát hiện sự cố. Khi một máy chủ master không phản hồi lệnh ping sau một số lần nhất định, sentinal `tự động khôi phục` bằng cách chuyển một replica thành master thông qua phương thức bầu cử, tiếp theo sentinal gửi `thông báo` cho quản trị viên và `cung cấp thông tin` về vị trí master và các replicas cho các ứng dụng client, cho phép chúng kết nối với master mới mà không cần triển khai thủ công.

## Steps in repo
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

    c. start redis 7001: `redis-server ./redis.conf`

    check slot assignment: `redis-cli -h 127.0.0.1 -p 7001 CLUSTER NODES`

    d. create cluster: 

    ```
    redis-cli --cluster create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 127.0.0.1:7006 --cluster-replicas 1
    ```

    e. test cluster's health: `redis-cli --cluster check 127.0.0.1:7001`

## References
- https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/#create-a-redis-cluster
- https://thuduyen07.wordpress.com/2024/10/28/redis-co-ban/