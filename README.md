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
docker compose up -d   # PostgreSQL, RabbitMQ, Elasticsearch
```

## Đẩy lên GitHub & thêm cộng tác viên
```
git init && git add . && git commit -m "Initial solution"
git branch -M main
git remote add origin https://github.com/<tai-khoan>/InsuranceAgent.git
git push -u origin main
```
Trên GitHub: Settings → Collaborators → Add people → nhập `caotxuan@gmail.com`.
