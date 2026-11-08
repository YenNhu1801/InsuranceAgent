FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/ProductService/ProductService.Api/ProductService.Api.csproj src/ProductService/ProductService.Api/
COPY src/ProductService/ProductService/ProductService.csproj src/ProductService/ProductService/
RUN dotnet restore src/ProductService/ProductService/ProductService.csproj
COPY src/ProductService/ProductService.Api/ src/ProductService/ProductService.Api/
COPY src/ProductService/ProductService/ src/ProductService/ProductService/
RUN dotnet publish src/ProductService/ProductService/ProductService.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:5030
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "ProductService.dll"]
