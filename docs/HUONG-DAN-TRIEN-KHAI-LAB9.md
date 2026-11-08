# Lab 9 — cách chạy trên Windows

Kho: https://github.com/YenNhu1801/InsuranceAgent  
Nhánh: `cursor/lab9-policy-services-599a`

Hạn trong PDF là **19:00 ngày 08/11/2026**. Dòng 18:00 trên Moodle chỉ là lệch mô tả, không đổi hạn PDF.

Hướng dẫn này là cách tự chạy trên máy Windows. Phần `dotnet run` đã được thực thi trên một máy Linux cùng cổng. Phần Docker Compose ở dưới sửa lỗi build; máy kiểm tra không có Docker CLI nên **chưa build và chưa `up` được image**.

## Docker Compose trên Windows

Lỗi `COPY --from=publish` ở Pricing là do stage trong Dockerfile tên `build`, không phải `publish`. Docker hiểu `publish` là image `docker.io/library/publish` và bị từ chối pull. Policy và Policy Search cùng kiểu đó đã được sửa thành `--from=build`. Các Dockerfile khác có stage `AS publish` nên `--from=publish` là đúng.

Cổng host **5040 không được publish** (CDPSvc đang giữ cổng đó). Container Pricing vẫn nghe `5040` trong mạng Compose. Từ Windows mở Pricing qua http://localhost:15040 . Policy trong mạng gọi `http://pricing:5040`. Postgres của Compose map `5432`, không đụng PostgreSQL 18 đang ở **5433**, và không xóa volume stack cũ.

Trong `D:\InsuranceAgent-Lab9`:

```powershell
git fetch origin
git checkout cursor/lab9-policy-services-599a
git pull origin cursor/lab9-policy-services-599a
docker compose -p insuranceagent-lab9 up -d --build
```

Không chạy `docker system prune` và không xóa volume. Project name `insuranceagent-lab9` tách khỏi stack bth4 đang dừng. Đừng bật đồng thời hai stack nếu cùng chiếm 5432, 5672, 8080, 8099, 8761 hoặc 9200.

Sau khi lên, mở http://localhost:8080 . Vue trong image gọi Auth http://localhost:6060/api/ và gateway http://localhost:8099/api/ trên máy Windows. Đăng nhập bằng tài khoản trong `InsuranceAgentsInMemoryDb.cs`.

| Dịch vụ | Cổng trên Windows | Cổng trong mạng Compose |
| --- | --- | --- |
| Vue | 8080 | 80 |
| Auth | 6060 | 6060 |
| Gateway | 8099 | 8099 |
| Product | 5030 | 5030 |
| Pricing | **15040** | 5040 |
| Policy | 5050 | 5050 |
| Policy Search | 5065 | 5065 |
| Eureka | 8761 | 8761 |
| Postgres | 5432 | 5432 |
| RabbitMQ | 5672 và 15672 | 5672 |
| Elasticsearch | 9200 | 9200 |

Hai chức năng giống mục giao diện bên dưới: báo giá TRI rồi tạo hợp đồng, sau đó tìm hợp đồng. Lần tìm đầu có thể cần bấm lại sau 1–2 giây.

Giao diện dùng để thao tác là Vue có sẵn trong `Web/Web`. Blazor trong `BlazorWasmClient` được giữ từ bài trước, không phải đường chạy của phụ lục VueJS.

## Phần mềm cần cài

Đã dùng các bản sau khi kiểm tra. Trên Windows hãy cài cùng dòng phiên bản.

| Phần | Bản đã dùng | Ghi chú |
| --- | --- | --- |
| .NET SDK | 8.0.427 | `dotnet --version` phải là 8.x |
| Node.js | 22.23.4 | Kèm npm 10.9.9 |
| JDK | OpenJDK 21.0.12 | Chỉ để chạy Eureka |
| Maven | 3.8.7 | `mvn -version` |
| PostgreSQL | 16 | Tạo user và database ở dưới |
| RabbitMQ | 3.12.1 | Cổng 5672. Tài khoản mặc định của broker chỉ dùng từ localhost |
| Elasticsearch | **8.9.2** | Đúng dòng với thư viện `Elastic.Clients.Elasticsearch` 8.9.3. Không dùng 7.x |

Vue trong repo là Vue CLI 3 / Vue 2 / webpack 4. Trên Node 22 phải đặt:

```powershell
$env:NODE_OPTIONS="--openssl-legacy-provider"
```

`node-sass` 4 không biên dịch trên Node 22. Repo đã chuyển `sass-loader` sang 10 và `sass`. Cài npm bằng `--legacy-peer-deps`.

## Cơ sở dữ liệu và dịch vụ nền

PostgreSQL: mở `postgres/postgres/createdatabases.sql`. Script tạo user `lab_user` và 4 database: `lab_netmicro_policy`, `lab_netmicro_pricing`, `lab_netmicro_payments`, `lab_netmicro_jobs`. Mật khẩu nằm trong file SQL đó, không ghi lại ở đây.

Trên PostgreSQL 15/16, sau khi tạo database, với từng database chạy:

```sql
GRANT ALL ON SCHEMA public TO lab_user;
ALTER SCHEMA public OWNER TO lab_user;
```

Policy dùng database `lab_netmicro_policy` (NHibernate tự cập nhật bảng). Pricing dùng `lab_netmicro_pricing`. Product dùng EF InMemory, không cần database.

RabbitMQ: cài service Windows, bật, để cổng 5672. Code nối `localhost`, user mặc định của image/cài đặt RabbitMQ.

Elasticsearch 8.9.2: giải nén, sửa `config/elasticsearch.yml`:

```yaml
cluster.name: lab9
node.name: lab9-1
network.host: 127.0.0.1
http.port: 9200
discovery.type: single-node
xpack.security.enabled: false
xpack.security.http.ssl.enabled: false
xpack.security.transport.ssl.enabled: false
ingest.geoip.downloader.enabled: false
```

Chạy `bin\elasticsearch.bat`. Kiểm tra http://127.0.0.1:9200 . `vm.max_map_count` chỉ có trên Linux, bỏ qua trên Windows.

## Cấu hình local

Trong `Web/Web`:

```powershell
copy .env-example .env
```

Hai dòng cần đúng:

```
VUE_APP_BACKEND_URL=http://localhost:8099/api/
VUE_APP_AUTH_URL=http://localhost:6060/api/
```

File `.env` không commit. Dòng chatbot có placeholder, không cần điền vì Chat không nằm trong hai chức năng bên dưới.

Không đặt biến `Eureka__Client__ShouldRegisterWithEureka=false`. Policy gọi Pricing qua tên Eureka `PricingService`. Nếu Eureka chưa chạy, tạo báo giá sẽ lỗi.

Tài khoản đăng nhập demo khai báo trong `src/AuthService/AuthService/DataAccess/InsuranceAgentsInMemoryDb.cs`. Mở file đó và dùng đúng login/password của một đại lý. Không chép mật khẩu vào README hay báo cáo.

## Thứ tự bật — mỗi khối một terminal

Mở PowerShell tại thư mục gốc repo. Giữ mỗi cửa sổ chạy, không tắt.

**1. Elasticsearch** — `bin\elasticsearch.bat`  
**2. Bảo đảm Postgres và RabbitMQ đã là Windows service và đang chạy.**

**3. Eureka**

```powershell
cd eureka-server\eureka-server
mvn -DskipTests package
java -jar target\eureka-server.jar --server.port=8761
```

Đợi http://localhost:8761 mở được.

**4. Auth** — cổng 6060

```powershell
cd src\AuthService\AuthService
$env:ASPNETCORE_ENVIRONMENT="Development"
dotnet run --urls http://localhost:6060
```

**5. Product** — cổng 5030

```powershell
cd src\ProductService\ProductService
$env:ASPNETCORE_ENVIRONMENT="Development"
dotnet run --urls http://localhost:5030
```

**6. Pricing** — cổng 5040

```powershell
cd src\PricingService\PricingService
$env:ASPNETCORE_ENVIRONMENT="Development"
dotnet run --urls http://localhost:5040
```

**7. Policy** — cổng 5050

```powershell
cd src\PolicyService\PolicyService
$env:ASPNETCORE_ENVIRONMENT="Development"
dotnet run --urls http://localhost:5050
```

**8. Policy Search** — cổng 5065

```powershell
cd src\PolicySearchService\PolicySearchService
$env:ASPNETCORE_ENVIRONMENT="Development"
dotnet run --urls http://localhost:5065
```

**9. Cổng API** — chỉ bật sau khi Eureka đã thấy Product, Pricing, Policy, Policy Search. Địa chỉ http://localhost:8761

```powershell
cd AgentPortalApiGateway\AgentPortalApiGateway
$env:ASPNETCORE_ENVIRONMENT="Development"
dotnet run --urls http://localhost:8099
```

**10. Vue** — cổng 8080

```powershell
cd Web\Web
$env:NODE_OPTIONS="--openssl-legacy-provider"
npm install --legacy-peer-deps
npm run serve -- --port 8080
```

Mở http://localhost:8080

Trên máy Linux đã kiểm tra, `bash scripts/lab9-up.sh` làm các bước 3–9 (cần `tmux` và JDK). Script đó không dành cho Windows.

## Hai chức năng trên giao diện Vue

Đăng nhập bằng tài khoản trong `InsuranceAgentsInMemoryDb.cs`.

1. **Báo giá rồi thành hợp đồng.** Vào Sản phẩm, chọn Safe Traveller (mã TRI), giữ hoặc nhập ngày hiệu lực, số người lớn, số trẻ em, điểm đến. Bấm tính phí. Giá đi Policy → Pricing (REST) qua gateway. Bấm chuyển thành hợp đồng, nhập chủ hợp đồng, xác nhận. Trang chi tiết hiện số hợp đồng, mã TRI và tổng phí.
2. **Tìm hợp đồng.** Vào Tìm hợp đồng, nhập số vừa tạo hoặc tên chủ hợp đồng, bấm Tìm. Policy đã phát `PolicyCreated` lên RabbitMQ. Policy Search ghi Elasticsearch rồi gateway trả danh sách. Lần tìm ngay sau khi tạo có thể cần bấm lại sau 1–2 giây.

Request không có JWT tới gateway bị từ chối (đã thấy HTTP 401 với `GET /api/products`).

## Đã kiểm tra khi viết hướng dẫn này

Chạy trực tiếp, không Docker:

- `dotnet build InsuranceAgent.sln`: 0 lỗi.
- `dotnet test src/PolicyService/PolicyService.Test/PolicyService.Test.csproj`: 8/8.
- `dotnet test src/PolicySearchService/PolicySearchService.Test/PolicySearchService.Test.csproj`: 3/3 (`PolicyCreatedIndexingTest` kiểm tra map sự kiện sang bản ghi tìm kiếm và kết quả query).
- Eureka đăng ký PRODUCTSERVICE:5030, PRICINGSERVICE:5040, POLICYSERVICE:5050, POLICYSEARCHSERVICE:5065.
- Chuỗi Auth → Gateway: đăng nhập, 4 sản phẩm, tạo báo giá TRI phí 108, tạo hợp đồng, tìm theo đúng số hợp đồng thấy phí 108 ở lần thử thứ 2, không token thì 401.
- Vue: `npm run serve` biên dịch xong và http://localhost:8080 trả 200. Trên trình duyệt đã đăng nhập, chọn Safe Traveller, tính phí 108 EUR, tạo hợp đồng `b8a6b44f-9574-4f86-a780-b796d58d0d44` cho Ha Le, rồi tìm theo tên và thấy đúng số đó trong bảng.

Chưa chạy: Docker Compose, Chat, Dashboard, Payment (không tính xem số dư là thanh toán), Document/JS Report.

## Lỗi đã gặp và cách xử lý

- Policy/Pricing không hiện trên Eureka nếu biến môi trường tắt đăng ký, hoặc bật service trước Eureka. Tắt biến đó, khởi động lại Eureka rồi các service, sau đó mới bật gateway.
- Tạo báo giá lỗi kết nối Pricing: Eureka chưa có `PRICINGSERVICE`, hoặc Policy không fetch registry.
- Vue `Cannot find module 'node-sass'`: dùng Node 22 với cấu hình hiện tại (`sass` + `sass-loader` 10), cài bằng `npm install --legacy-peer-deps`, và `NODE_OPTIONS=--openssl-legacy-provider`.
- `npm run build` in `DONE Build complete` rồi Docker đứng ở `RUN`: Vue CLI 3 bật Uglify song song qua `worker-farm` khi máy có hơn 2 CPU. Trên Node 22 các process con không đóng, nên tiến trình không thoát và image không được xuất. `Web/Web/vue.config.js` tắt chế độ song song đó để minify chạy trong cùng process. Đã kiểm tra trên Node 22: `npm run build` tự thoát, mã 0, khoảng 6 giây, có `dist/index.html`. Không ép `exit 0`.
- `npm install` báo conflict peer: thêm `--legacy-peer-deps`.
- Gateway 404 với `/swagger` là bình thường. Nghiệp vụ là `/api/...`.
- Tìm kiếm rỗng ngay sau khi tạo hợp đồng: đợi outbox (khoảng 1 giây) và bấm Tìm lại.
- Elasticsearch 7 không dùng được với client 8.9.3 trong project.
