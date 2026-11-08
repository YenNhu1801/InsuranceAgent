FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/PolicyService/PolicyService.Api/PolicyService.Api.csproj src/PolicyService/PolicyService.Api/
COPY src/ChatService/ChatService.Api/ChatService.Api.csproj src/ChatService/ChatService.Api/
COPY src/ChatService/ChatService/ChatService.csproj src/ChatService/ChatService/
RUN dotnet restore src/ChatService/ChatService/ChatService.csproj
COPY src/PolicyService/PolicyService.Api/ src/PolicyService/PolicyService.Api/
COPY src/ChatService/ChatService.Api/ src/ChatService/ChatService.Api/
COPY src/ChatService/ChatService/ src/ChatService/ChatService/
RUN dotnet publish src/ChatService/ChatService/ChatService.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:4099
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "ChatService.dll"]
