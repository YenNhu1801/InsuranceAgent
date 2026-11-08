FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY AgentPortalApiGateway/AgentPortalApiGateway/AgentPortalApiGateway.csproj AgentPortalApiGateway/AgentPortalApiGateway/
RUN dotnet restore AgentPortalApiGateway/AgentPortalApiGateway/AgentPortalApiGateway.csproj
COPY AgentPortalApiGateway/AgentPortalApiGateway/ AgentPortalApiGateway/AgentPortalApiGateway/
RUN dotnet publish AgentPortalApiGateway/AgentPortalApiGateway/AgentPortalApiGateway.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8099
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "AgentPortalApiGateway.dll"]
