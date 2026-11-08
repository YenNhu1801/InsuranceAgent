# Demo 2 chuc nang tren UI Blazor da chay (http://localhost:5081).
# Tai khoan: jimmy.solid / secret. Khong co giao dich tien that.
Write-Host @"
1) Mo http://localhost:5081/login
   User name: jimmy.solid
   Password:  secret
   Submit. Thanh menu hien 'Logged as: jimmy.solid'.

2) Chuc nang san pham:
   Mo Products. Phai thay Safe Traveller, Happy House, Happy farm, Happy Driver.

3) Chuc nang hop dong (Policy + PolicySearch):
   - Co the Search policies, o Policy holder nhap Nguyen (neu da tao hop dong mau).
   - Hoac tao moi: Products -> Buy Safe Traveller, dien form, tao offer/policy,
     roi quay lai Policies va tim theo ten nguoi mua.
   Ket qua la bang so hop dong, ma TRI, phi bao hiem.

4) (Tuy chon) Chat:
   Mo Chat, go mot cau, Send. Dong tin hien 'jimmy.solid says: ...'.
   Day la SignalR noi bo, khong gui tin ra ngoai.

Dung he thong: docker compose down
"@
