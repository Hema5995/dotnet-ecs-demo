# ---- Stage 1: Build ----
# Uses the .NET Framework SDK image (has MSBuild + NuGet) to compile the
# Web Application project into a deployable output.
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022 AS build
WORKDIR C:/src

# Copy just the csproj first so NuGet restore is cached across builds
COPY . .

# 2. Restore dependencies using the solution file now that it exists
RUN nuget restore DotnetEcsDemo.sln

# 3. Use DeployOnBuild/WebPublishMethod to extract the fully compiled website (not just raw bins)
RUN msbuild DotnetEcsDemo.sln /p:Configuration=Release /p:DeployOnBuild=true /p:DeployTarget=WebPublish /p:WebPublishMethod=FileSystem /p:publishUrl=C:\publish

# ---- Stage 2: Runtime ----
# This is the actual image that runs in ECS - only the compiled output
# gets copied in, not the source, csproj, or build tools.
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022
WORKDIR C:/inetpub/wwwroot

# Clear IIS's default sample site content, then copy the published app
RUN powershell -Command "Remove-Item -Recurse -Force C:/inetpub/wwwroot/*"
COPY --from=build C:/publish .

EXPOSE 80
