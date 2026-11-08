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

## Triển khai
`docker compose up --build` dựng Postgres (user `lab_user`, các database trong `postgres/postgres/createdatabases.sql`), RabbitMQ (`rabbit`), Elasticsearch 8.9.2, Eureka, Pricing (:5040), Policy (:5050), Policy Search (:5065).

Biến môi trường: xem `.env.example` (chỉ tên/giá trị mẫu).

Nếu không có Docker, hướng dẫn chạy trực tiếp trên máy nằm trong `docs/HUONG-DAN-TRIEN-KHAI-LAB9.md`. Script kiểm tra hai chức năng chính (báo giá → hợp đồng, tìm kiếm) và tài khoản thanh toán:

```
bash scripts/lab9-e2e.sh
```

Trang demo cục bộ: `python3 scripts/lab9-demo/server.py` rồi mở http://127.0.0.1:8090.

## Changelog
- 2026-11-08 — Tích hợp PolicyService và PolicySearchService cho Lab 9, compose triển khai, sửa listener RabbitMQ đợi xử lý xong trước khi đóng scope, ổn định test hết hạn offer.

## Đẩy lên GitHub & thêm cộng tác viên
```
git init && git add . && git commit -m "Initial solution"
git branch -M main
git remote add origin https://github.com/<tai-khoan>/InsuranceAgent.git
git push -u origin main
```
Trên GitHub: Settings → Collaborators → Add people → nhập `caotxuan@gmail.com`.
