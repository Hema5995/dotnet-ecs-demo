# ---- Stage 1: Build ----
# Uses the .NET Framework SDK image (has MSBuild + NuGet) to compile the
# Web Application project into a deployable output.
FROM ://microsoft.com AS build
WORKDIR C:/src

# Copy just the csproj first so NuGet restore is cached across builds
COPY DotnetEcsDemo/DotnetEcsDemo.csproj DotnetEcsDemo/
RUN nuget restore DotnetEcsDemo/DotnetEcsDemo.csproj

# Now copy the rest of the source and build/publish it
COPY . .
RUN dotnet publish DotnetEcsDemo/DotnetEcsDemo.csproj -c Release -o C:/publish

# ---- Stage 2: Runtime ----
# This is the actual image that runs in ECS - only the compiled output
# gets copied in, not the source, csproj, or build tools.
FROM ://microsoft.com
WORKDIR C:/inetpub/wwwroot

# Clear IIS's default sample site content, then copy the published app
RUN powershell -Command "Remove-Item -Recurse -Force C:/inetpub/wwwroot/*"
COPY --from=build C:/publish .

EXPOSE 80
