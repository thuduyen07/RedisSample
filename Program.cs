using NRedisStack;
using NRedisStack.RedisStackCommands;
using StackExchange.Redis;

public class Program{
    public static void Main(){

        // // Connection single redis
        // ConnectionMultiplexer redis = ConnectionMultiplexer.Connect("localhost");
        // IDatabase db = redis.GetDatabase();

        // Connection redis cluster
        ConfigurationOptions options = new ConfigurationOptions {
            EndPoints = {
                { "127.0.0.1", 7001 },
                { "127.0.0.1", 7002}
            },
            User = "thuduyen07",
            Password = "Admin@123",
            AbortOnConnectFail = false,
            AllowAdmin = true,
        };
        ConnectionMultiplexer cluster = ConnectionMultiplexer.Connect(options);
        IDatabase db = cluster.GetDatabase();

        // String
        db.StringSet("project_01", "Redis Sample");
        Console.WriteLine(db.StringGet("project_01"));

        // Hash
        var hash = new HashEntry[]{
            new HashEntry("name", "thuduyen07"),
            new HashEntry("job", "sdet"),
            new HashEntry("company", "jl")
        };
        db.HashSet("user_01", hash);
        var user = db.HashGetAll("user_01");
        Console.WriteLine(string.Join("; ", user));

        var server = cluster.GetServer("127.0.0.1", 7001);
        Console.WriteLine(String.Join(';', server.ClusterNodes()));

        // Dispose
        cluster.Dispose();
        
    }
}
