# InsuranceAgent – Kiến trúc Microservices (.NET 8)

## Cấu trúc
Mỗi service nằm trong `src/<Service>/` và một solution folder riêng, gồm 3 project:
- `<Service>.Api` – định nghĩa API (commands, queries, events, DTOs)
- `<Service>` – phần cài đặt (ASP.NET Core Web API, đã cài & đăng ký MediatR), tham chiếu `.Api`
- `<Service>.Test` – unit test xUnit, tham chiếu project cài đặt

Các service: AuthService, ChatService, PricingService, PolicyService, PolicySearchService, PaymentService, ProductService, DocumentService, DashboardService.

PolicyService (NHibernate/PostgreSQL, gọi Pricing qua REST, outbox RabbitMQ) và PolicySearchService (Elasticsearch 8) dùng code mẫu Lab 9. Tham chiếu project trỏ theo cây `src/`. Polly giữ API 7.2.4 vì code mẫu gọi `Policy.Handle`. MediatR của Policy Search là 12.4.1 cho khớp project API.

## Build và test
```
dotnet build InsuranceAgent.sln
dotnet test src/PolicyService/PolicyService.Test/PolicyService.Test.csproj
dotnet test src/PaymentService/PaymentService.Test/PaymentService.Test.csproj
```

## Chạy Lab 9
Hướng dẫn Windows, cổng, thứ tự terminal và hai chức năng (báo giá → hợp đồng, tìm hợp đồng): `docs/HUONG-DAN-TRIEN-KHAI-LAB9.md`.

Đăng nhập demo lấy từ `src/AuthService/AuthService/DataAccess/InsuranceAgentsInMemoryDb.cs`.

`docker compose -p insuranceagent-lab9 up -d --build` dựng Eureka, Postgres, RabbitMQ, Elasticsearch, Auth, Product, Pricing, Policy, Policy Search, Gateway và Vue. Cổng Pricing trên máy host là **15040** (trong mạng Compose vẫn 5040). Postgres của Compose dùng 5432, không dùng 5433. Image chưa được build trên máy kiểm tra vì không có Docker CLI.

## Changelog
- 2026-11-08 — Tích hợp PolicyService và PolicySearchService cho Lab 9, compose triển khai, sửa listener RabbitMQ đợi xử lý xong trước khi đóng scope, ổn định test hết hạn offer.
- 2026-11-08 — Vue gọi Auth và gateway; Eureka đăng ký Pricing/Policy/Search; hướng dẫn chạy Windows. Đã bấm trên Vue: báo giá TRI 108 EUR, tạo hợp đồng, tìm thấy hợp đồng vừa tạo.
- 2026-11-08 — Sửa Docker `COPY --from=build` cho Pricing, Policy, Policy Search. Compose thêm Auth, Product, Gateway, Vue. Cổng host của Pricing là 15040.

## Đẩy lên GitHub & thêm cộng tác viên
```
git init && git add . && git commit -m "Initial solution"
git branch -M main
git remote add origin https://github.com/<tai-khoan>/InsuranceAgent.git
git push -u origin main
```
Trên GitHub: Settings → Collaborators → Add people → nhập `caotxuan@gmail.com`.
