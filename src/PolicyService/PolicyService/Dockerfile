FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY src/PricingService/PricingService.Api/PricingService.Api.csproj src/PricingService/PricingService.Api/
COPY src/PolicyService/PolicyService.Api/PolicyService.Api.csproj src/PolicyService/PolicyService.Api/
COPY src/PolicyService/PolicyService/PolicyService.csproj src/PolicyService/PolicyService/
COPY src/PolicyService/PolicyService.Test/PolicyService.Test.csproj src/PolicyService/PolicyService.Test/
RUN dotnet restore src/PolicyService/PolicyService/PolicyService.csproj \
    && dotnet restore src/PolicyService/PolicyService.Test/PolicyService.Test.csproj

COPY src/PricingService/PricingService.Api/ src/PricingService/PricingService.Api/
COPY src/PolicyService/PolicyService.Api/ src/PolicyService/PolicyService.Api/
COPY src/PolicyService/PolicyService/ src/PolicyService/PolicyService/
COPY src/PolicyService/PolicyService.Test/ src/PolicyService/PolicyService.Test/
RUN dotnet test src/PolicyService/PolicyService.Test/PolicyService.Test.csproj --verbosity normal \
    && dotnet publish src/PolicyService/PolicyService/PolicyService.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:5050
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "PolicyService.dll"]
