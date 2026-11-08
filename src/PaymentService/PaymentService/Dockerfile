FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/PolicyService/PolicyService.Api/PolicyService.Api.csproj src/PolicyService/PolicyService.Api/
COPY src/PaymentService/PaymentService.Api/PaymentService.Api.csproj src/PaymentService/PaymentService.Api/
COPY src/PaymentService/PaymentService/PaymentService.csproj src/PaymentService/PaymentService/
RUN dotnet restore src/PaymentService/PaymentService/PaymentService.csproj
COPY src/PolicyService/PolicyService.Api/ src/PolicyService/PolicyService.Api/
COPY src/PaymentService/PaymentService.Api/ src/PaymentService/PaymentService.Api/
COPY src/PaymentService/PaymentService/ src/PaymentService/PaymentService/
RUN dotnet publish src/PaymentService/PaymentService/PaymentService.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:5070
ENV ASPNETCORE_ENVIRONMENT=docker
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "PaymentService.dll"]
