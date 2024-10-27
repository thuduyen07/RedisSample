echo "Current directory: $(pwd)"

echo "Running the program..."
dotnet add package NRedisStack
dotnet build
dotnet run