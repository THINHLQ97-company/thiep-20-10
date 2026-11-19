# 2010gift.cloud

| Đường dẫn | Nội dung |
|---|---|
| `/` | **Hai Đứa Mình**: sổ lời hẹn và ảnh kỷ niệm của hai người, đăng nhập bằng Facebook (`index.html`, `assets/`) |
| `/thiep-20-10/` | Thiệp 20/10 "Thành phố của những cây cầu" (`thiep-20-10/`) |
| `/hai-dua/` | Đường dẫn cũ, tự chuyển về trang chủ (`vercel.json`) |

- `docs/HUONG-DAN.md`: các bước bật đăng nhập Facebook qua Supabase.
- `docs/supabase-setup.sql`: dựng bảng, kho ảnh riêng tư, 10 lời hẹn đầu tiên.
- `in-thiep/`: mã QR để in.
- `.github/workflows/supabase-keepalive.yml`: giữ Supabase không tự tạm dừng.

Cả hai trang là HTML tĩnh, không cần build. Chạy thử trên máy bằng `npx serve .` rồi mở `http://localhost:3000`.

## Thiệp 20/10: đổi mật khẩu
Mật khẩu được chuẩn hoá (chữ thường, bỏ dấu, bỏ khoảng trắng) rồi so bằng SHA-256:

```
node -e "console.log(require('crypto').createHash('sha256').update('dnsg2010:' + 'matkhaukhongdau').digest('hex'))"
```

Dán kết quả vào `PASS_HASHES` trong `CONFIG` của `thiep-20-10/index.html`.
