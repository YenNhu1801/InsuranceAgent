FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/AuthService/AuthService/AuthService.csproj src/AuthService/AuthService/
RUN dotnet restore src/AuthService/AuthService/AuthService.csproj
COPY src/AuthService/AuthService/ src/AuthService/AuthService/
RUN dotnet publish src/AuthService/AuthService/AuthService.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:6060
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "AuthService.dll"]
