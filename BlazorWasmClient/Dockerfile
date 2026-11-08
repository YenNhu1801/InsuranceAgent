FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/DashboardService/DashboardService.Api/DashboardService.Api.csproj src/DashboardService/DashboardService.Api/
COPY src/PolicySearchService/PolicySearchService.Api/PolicySearchService.Api.csproj src/PolicySearchService/PolicySearchService.Api/
COPY src/PolicyService/PolicyService.Api/PolicyService.Api.csproj src/PolicyService/PolicyService.Api/
COPY src/PricingService/PricingService.Api/PricingService.Api.csproj src/PricingService/PricingService.Api/
COPY src/ProductService/ProductService.Api/ProductService.Api.csproj src/ProductService/ProductService.Api/
COPY BlazorWasmClient/BlazorWasmClient/BlazorWasmClient.csproj BlazorWasmClient/BlazorWasmClient/
RUN dotnet restore BlazorWasmClient/BlazorWasmClient/BlazorWasmClient.csproj
COPY src/DashboardService/DashboardService.Api/ src/DashboardService/DashboardService.Api/
COPY src/PolicySearchService/PolicySearchService.Api/ src/PolicySearchService/PolicySearchService.Api/
COPY src/PolicyService/PolicyService.Api/ src/PolicyService/PolicyService.Api/
COPY src/PricingService/PricingService.Api/ src/PricingService/PricingService.Api/
COPY src/ProductService/ProductService.Api/ src/ProductService/ProductService.Api/
COPY BlazorWasmClient/BlazorWasmClient/ BlazorWasmClient/BlazorWasmClient/
RUN dotnet publish BlazorWasmClient/BlazorWasmClient/BlazorWasmClient.csproj -c Release -o /out --no-restore

FROM nginx:1.27-alpine
COPY BlazorWasmClient/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /out/wwwroot /usr/share/nginx/html
EXPOSE 80
