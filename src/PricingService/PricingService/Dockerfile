FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/PricingService/PricingService.Api/PricingService.Api.csproj src/PricingService/PricingService.Api/
COPY src/PricingService/PricingService/PricingService.csproj src/PricingService/PricingService/
RUN dotnet restore src/PricingService/PricingService/PricingService.csproj
COPY src/PricingService/PricingService.Api/ src/PricingService/PricingService.Api/
COPY src/PricingService/PricingService/ src/PricingService/PricingService/
RUN dotnet publish src/PricingService/PricingService/PricingService.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:5040
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "PricingService.dll"]
