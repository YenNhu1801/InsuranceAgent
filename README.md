# InsuranceAgent – Kiến trúc Microservices (.NET 8)

## Cấu trúc
Mỗi service nằm trong `src/<Service>/` và một solution folder riêng, gồm 3 project:
- `<Service>.Api` – định nghĩa API (commands, queries, events, DTOs)
- `<Service>` – phần cài đặt (ASP.NET Core Web API, đã cài & đăng ký MediatR), tham chiếu `.Api`
- `<Service>.Test` – unit test xUnit, tham chiếu project cài đặt

Các service: AuthService, ChatService, PricingService, PolicyService, PolicySearchService, PaymentService, ProductService, DocumentService.

## Build
```
dotnet build InsuranceAgent.sln
dotnet test src/PolicyService/PolicyService.Test/PolicyService.Test.csproj
```

## Chạy (BTH9)
Cần Docker Desktop và .NET SDK 8 (máy này cũng chạy được với SDK 10 vì target `net8.0`).

Hạ tầng dùng user `lab_user` / password `lab_pass` (chỉ mật khẩu lab, xem `postgres/postgres/createdatabases.sql`). RabbitMQ guest chỉ trong mạng lab (`scripts/rabbitmq.conf` tắt loopback). Không có khóa thanh toán thật.

```
docker compose up -d --build
```
Windows: `powershell -File scripts/windows/start-bth9.ps1`

| Thành phần | URL |
| --- | --- |
| Blazor UI | http://localhost:5081 |
| API Gateway | http://localhost:8099 |
| Auth | http://localhost:6060 |
| Product | http://localhost:5030 |
| Pricing | http://localhost:5040 |
| Policy | http://localhost:5050 |
| Policy search | http://localhost:5065 |
| Chat | http://localhost:4099 |
| Eureka | http://localhost:8761 |

Đăng nhập UI: `jimmy.solid` / `secret`.

Smoke API (sau khi gateway đã thấy service trên Eureka, khoảng 30 giây):

```
bash scripts/bth9-smoke.sh
```

Demo trên UI: `scripts/windows/demo-two-features.ps1`.

Chỉ hạ tầng, rồi `dotnet run` từng service (Development, cổng ở `launchSettings.json` / `hosting.json`):

```
docker compose up -d postgres rabbit elasticsearch eureka-server
```

## Biến môi trường
Không có secret bắt buộc ngoài cấu hình lab trong `appsettings*.json`. Tên chính: `ASPNETCORE_ENVIRONMENT` (`Development` hoặc `docker`), `ASPNETCORE_URLS`.

## Changelog
- 2026-11-08 — BTH9: tích hợp code mẫu PolicyService và PolicySearchService, Compose chạy được, sửa hạn token Blazor (`expiryTimeStamp`) để Products / Policies / Chat gọi API.

## Đẩy lên GitHub & thêm cộng tác viên
```
git init && git add . && git commit -m "Initial solution"
git branch -M main
git remote add origin https://github.com/<tai-khoan>/InsuranceAgent.git
git push -u origin main
```
Trên GitHub: Settings → Collaborators → Add people → nhập `caotxuan@gmail.com`.
