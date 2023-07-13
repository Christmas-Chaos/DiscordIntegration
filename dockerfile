# Use a specific version of Node.js as a parent image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env

# Set the working directory in the container to /app
WORKDIR /app

# Copy the solution file and restore dependencies
COPY DiscordIntegration.sln ./
COPY DiscordIntegration.Dependency/*.csproj ./DiscordIntegration.Dependency/
COPY DiscordIntegration.Bot/*.csproj ./DiscordIntegration.Bot/

# Restore NuGet packages for the Dependency project
WORKDIR /app/DiscordIntegration.Dependency
RUN dotnet restore

# Restore NuGet packages for the Bot project
WORKDIR /app/DiscordIntegration.Bot
RUN dotnet restore

# Go back to the root directory
WORKDIR /app

# Copy the rest of your bot's source code from your host to your image filesystem
COPY . .

# Publish the bot project
RUN dotnet publish -c Release -o out --no-restore DiscordIntegration.Bot/DiscordIntegration.Bot.csproj

# Using .NET runtime image to run the Docker app
FROM mcr.microsoft.com/dotnet/runtime:6.0

WORKDIR /app
COPY --from=build-env /app/out .

# Expose ports 9000 and 9001
EXPOSE 9000
EXPOSE 9001

# Run the bot when the container launches
ENTRYPOINT ["dotnet", "DiscordIntegration.Bot.dll"]