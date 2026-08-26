# ---- Stage 1: Build ----
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019 AS build
WORKDIR C:/src

# Copy all source files and restore
COPY . .
RUN nuget restore DotnetEcsDemo.sln

# Standard compilation
RUN msbuild DotnetEcsDemo.sln /p:Configuration=Release /p:Platform="Any CPU"

# ---- Stage 2: Runtime ----
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
WORKDIR C:/inetpub/wwwroot

# Clear default IIS website contents
RUN powershell -Command "Remove-Item -Recurse -Force C:/inetpub/wwwroot/*"

# Copy the entire project folder (all .aspx, .config, static assets, and /bin)
COPY --from=build C:/src/DotnetEcsDemo .

# Optional cleanup: Remove raw C# source files and obj temp folder from runtime image
RUN powershell -Command "Remove-Item -Recurse -Force -Include *.cs,*.csproj,*.user,obj -Path C:/inetpub/wwwroot/* -ErrorAction SilentlyContinue"

EXPOSE 80
