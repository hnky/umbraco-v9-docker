FROM mcr.microsoft.com/dotnet/sdk AS build-env
WORKDIR /app

# Install & Build
RUN dotnet nuget add source "https://www.myget.org/F/umbracoprereleases/api/v3/index.json" -n "Umbraco Prereleases"
RUN dotnet new -i Umbraco.Templates::9.0.0-alpha004
RUN dotnet new umbraco -n UmbracoV9-alpha004 -ce
RUN dotnet build UmbracoV9-alpha004/UmbracoV9-alpha004.csproj -c Release -o ./out/build

# Publish
FROM build-env AS publish
RUN dotnet publish UmbracoV9-alpha004/UmbracoV9-alpha004.csproj -c Release -o ./out/publish --no-restore

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:80
COPY --from=publish /app/out/publish ./
ENTRYPOINT ["dotnet", "UmbracoV9-alpha004.dll"]