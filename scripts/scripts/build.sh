#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
dotnet build InsuranceAgent.sln
dotnet test src/PolicyService/PolicyService.Test/PolicyService.Test.csproj --nologo
dotnet test src/PricingService/PricingService.Test/PricingService.Test.csproj --nologo
dotnet test src/PaymentService/PaymentService.Test/PaymentService.Test.csproj --nologo
dotnet test src/ProductService/ProductService.Test/ProductService.Test.csproj --nologo
dotnet test src/AuthService/AuthService.Test/AuthService.Test.csproj --nologo
