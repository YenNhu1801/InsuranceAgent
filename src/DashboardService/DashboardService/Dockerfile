FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/PolicyService/PolicyService.Api/PolicyService.Api.csproj src/PolicyService/PolicyService.Api/
COPY src/DashboardService/DashboardService.Api/DashboardService.Api.csproj src/DashboardService/DashboardService.Api/
COPY src/DashboardService/DashboardService/DashboardService.csproj src/DashboardService/DashboardService/
RUN dotnet restore src/DashboardService/DashboardService/DashboardService.csproj
COPY src/PolicyService/PolicyService.Api/ src/PolicyService/PolicyService.Api/
COPY src/DashboardService/DashboardService.Api/ src/DashboardService/DashboardService.Api/
COPY src/DashboardService/DashboardService/ src/DashboardService/DashboardService/
RUN dotnet publish src/DashboardService/DashboardService/DashboardService.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:5035
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "DashboardService.dll"]
