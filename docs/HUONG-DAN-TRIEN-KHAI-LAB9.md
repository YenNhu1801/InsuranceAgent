# Hướng dẫn triển khai Lab 9 — Đại lý bảo hiểm

Sinh viên: Nguyễn Thị Yến Như, 2424802010403, D24CNTT04.
Kho: https://github.com/YenNhu1801/InsuranceAgent

Hạn nộp: mô tả trên Moodle và trang tổng quan môn ghi 18:00 ngày 08/11/2026 (Asia/Bangkok). File PDF và trường hạn Moodle ghi 19:00 cùng ngày. Bản này chuẩn bị theo mốc sớm hơn (18:00). Không nộp Drive và không nộp e-learning trong lần chạy này.

## Đã tích hợp

Năm archive mẫu được đưa vào cây thư mục sẵn có:

- `src/PolicyService/PolicyService`
- `src/PolicyService/PolicyService.Api` (contract đã trùng mẫu)
- `src/PolicyService/PolicyService.Test`
- `src/PolicySearchService/PolicySearchService`
- `src/PolicySearchService/PolicySearchService.Api`

Tên project giữ nguyên. Tham chiếu được sửa cho đúng vị trí trong repo:

- PolicyService → `src/PricingService/PricingService.Api`
- PolicySearchService → `src/PolicyService/PolicyService.Api`

Frontend Blazor và Vue hiện có không bị đổi. BTH2 (học liệu TDMU) không được trộn vào mã bảo hiểm.

## Chức năng đã chạy thật

1. Tạo báo giá: Policy gọi Pricing REST, lưu offer PostgreSQL.
2. Mua hợp đồng: lưu policy, phát `PolicyCreated` qua outbox RabbitMQ, đọc lại chi tiết hợp đồng.
3. Tìm kiếm: PolicySearch nhận sự kiện, lập chỉ mục Elasticsearch, tìm theo số hợp đồng hoặc tên.
4. Thanh toán: Payment tạo tài khoản hợp đồng sau `PolicyCreated` và trả số dư.

Dữ liệu demo là dữ liệu giả (An Nguyen, Ha Le, Linh Pham, mã số thuế giả).

## Cách A — Docker Compose

Cần Docker. Từ thư mục gốc repo:

```bash
docker compose up --build
```

Cổng:

| Thành phần | Cổng |
| --- | --- |
| Postgres | 5432 |
| RabbitMQ | 5672, giao diện 15672 |
| Elasticsearch | 9200 |
| Eureka | 8761 |
| Pricing | 5040 |
| Policy | 5050 |
| Policy Search | 5065 |

Trong container, Policy gọi `http://pricing:5040/api/pricing`. Host logic `PricingService` vẫn đi qua Eureka nếu URI cấu hình đúng tên đó.

Mật khẩu Postgres của lab nằm trong `postgres/postgres/createdatabases.sql` và `appsettings` sẵn có. Không thêm bí mật mới.

## Cách B — Máy không có Docker

Đã dùng cách này trên môi trường kiểm thử vì không có Docker daemon.

1. Cài .NET SDK 8, PostgreSQL, RabbitMQ. Elasticsearch 8.9.2 (khớp `Elastic.Clients.Elasticsearch` 8.9.3). Elasticsearch 7 trong compose cũ không khớp client.
2. Tạo user và database bằng `postgres/postgres/createdatabases.sql`. Trên PostgreSQL 15+ cần `GRANT ALL ON SCHEMA public TO lab_user` cho từng database.
3. Bật RabbitMQ, user `guest`/`guest` trên localhost.
4. Elasticsearch: `discovery.type: single-node`, `xpack.security.enabled: false`, `vm.max_map_count=262144`.
5. Chạy:

```bash
export ASPNETCORE_ENVIRONMENT=Development
export Eureka__Client__ShouldRegisterWithEureka=false
export Eureka__Client__ShouldFetchRegistry=false
dotnet run --project src/PricingService/PricingService --no-launch-profile --urls http://localhost:5040
dotnet run --project src/PolicyService/PolicyService --no-launch-profile --urls http://localhost:5050
dotnet run --project src/PolicySearchService/PolicySearchService --no-launch-profile --urls http://localhost:5065
dotnet run --project src/PaymentService/PaymentService --no-launch-profile --urls http://localhost:5070
bash scripts/lab9-e2e.sh
```

`appsettings.Development.json` của Policy trỏ Pricing tới `http://localhost:5040/api/pricing`.

Trang bấm thử:

```bash
python3 scripts/lab9-demo/server.py
```

Mở http://127.0.0.1:8090. Bốn nút gọi API đang chạy.

## Kiểm thử

```bash
dotnet test src/PolicyService/PolicyService.Test/PolicyService.Test.csproj
dotnet test src/PaymentService/PaymentService.Test/PaymentService.Test.csproj
dotnet test src/PolicySearchService/PolicySearchService.Test/PolicySearchService.Test.csproj
```

PolicyService.Test: 8 test domain của mẫu. Các test dùng chung `SysTime` nên assembly tắt chạy song song, nếu không test hết hạn offer lúc được lúc không.

## Điểm đã chỉnh so với archive

- Polly 8.4.0 không còn `Policy.Handle`. Giữ lời gọi mẫu, hạ gói xuống Polly 7.2.4.
- MediatR Policy Search nâng 12.4.1 để không bị hạ cấp so với API.
- `Npgsql.EnableLegacyTimestampBehavior` cho NHibernate và Npgsql 8.
- Listener RabbitMQ của Policy Search, Payment, Chat, Dashboard `await` publish bên trong `using` scope. Trước đó scope bị hủy khi Task chưa chạy xong, Payment báo session Marten đã dispose và không tạo tài khoản.
- Dockerfile build từ gốc repo, không dùng layout phẳng của archive.

## Chưa làm

- Không upload video lên Drive, không nộp link e-learning.
- Không dựng được image Docker trong môi trường này vì không có Docker daemon. File compose vẫn là cách triển khai lặp lại được khi có Docker.
- Eureka không bắt buộc cho lần chạy trực tiếp vì URI Pricing là localhost. Compose vẫn dựng Eureka.
- Gateway Ocelot/JWT và Blazor chưa nằm trong lần demo API này.
