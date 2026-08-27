# ---- Stage 1: Build ----
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022 AS build
WORKDIR C:/src

# Copy all source files and restore
COPY . .
RUN nuget restore DotnetEcsDemo\DotnetEcsDemo.csproj

# Build the project directly (not the .sln) to avoid solution-configuration skip issues
RUN msbuild DotnetEcsDemo\DotnetEcsDemo.csproj /p:Configuration=Release /p:Platform="AnyCPU"

# DEBUG: list everything under the project folder after build
RUN powershell -Command "Get-ChildItem -Recurse C:/src/DotnetEcsDemo | Select-Object FullName"

# ---- Stage 2: Runtime ----
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2022
WORKDIR C:/inetpub/wwwroot

# Clear default IIS website contents
RUN powershell -Command "Remove-Item -Recurse -Force C:/inetpub/wwwroot/*"

# Copy the entire project folder (all .aspx, .config, static assets, and /bin)
COPY --from=build C:/src/DotnetEcsDemo .

# DEBUG: list everything that actually ended up in the runtime image
RUN powershell -Command "Get-ChildItem -Recurse C:/inetpub/wwwroot | Select-Object FullName"

EXPOSE 80
