FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY src/PolicyService/PolicyService.Api/PolicyService.Api.csproj src/PolicyService/PolicyService.Api/
COPY src/PolicySearchService/PolicySearchService.Api/PolicySearchService.Api.csproj src/PolicySearchService/PolicySearchService.Api/
COPY src/PolicySearchService/PolicySearchService/PolicySearchService.csproj src/PolicySearchService/PolicySearchService/
RUN dotnet restore src/PolicySearchService/PolicySearchService/PolicySearchService.csproj

COPY src/PolicyService/PolicyService.Api/ src/PolicyService/PolicyService.Api/
COPY src/PolicySearchService/PolicySearchService.Api/ src/PolicySearchService/PolicySearchService.Api/
COPY src/PolicySearchService/PolicySearchService/ src/PolicySearchService/PolicySearchService/
RUN dotnet publish src/PolicySearchService/PolicySearchService/PolicySearchService.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:5065
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "PolicySearchService.dll"]
