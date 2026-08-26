# ---- Stage 1: Build ----
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022 AS build
WORKDIR C:/src

# Copy all repository files
COPY . .

# Restore dependencies
RUN nuget restore DotnetEcsDemo.sln

# Build and publish the project to C:\publish
RUN msbuild DotnetEcsDemo/DotnetEcsDemo.csproj /p:Configuration=Release /p:Platform="AnyCPU" /p:VisualStudioVersion=17.0 /p:DeployOnBuild=true /p:WebPublishMethod=FileSystem /p:PublishUrl=C:\publish

# ---- Stage 2: Runtime ----
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2022
WORKDIR C:/inetpub/wwwroot

# Clear default IIS website contents
RUN powershell -Command "Remove-Item -Recurse -Force C:/inetpub/wwwroot/*"

# Copy the published artifacts from the build stage
COPY --from=build C:/publish .

EXPOSE 80
