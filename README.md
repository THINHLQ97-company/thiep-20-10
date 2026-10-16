# Thành phố của những cây cầu

Thiệp 20/10 tương tác, kể chuyện Đà Nẵng và Sài Gòn qua 6 màn hình, tối ưu cho điện thoại.
Mở bằng mã QR trên thiệp giấy, cần mật khẩu để mở hộp quà.

## Cấu trúc
- `index.html`: toàn bộ trang (HTML, CSS, JS). Nội dung chữ nằm trong khối `CONFIG` ở đầu phần `<script>`.
- `assets/dragon.glb`: mô hình cầu Rồng 3D (Three.js tải từ jsDelivr khi tới chương cây cầu).
- `assets/her.webp`, `assets/him.webp`: ảnh đại diện.
- `assets/bg-portrait.webp`, `assets/bg-wide.webp`: ảnh nền điện thoại và máy tính.
- `assets/bg-music.mp3`: nhạc nền "Gót Hồng".

## Đổi mật khẩu
Mật khẩu được chuẩn hoá (chữ thường, bỏ dấu, bỏ khoảng trắng) rồi so bằng SHA-256:

```
node -e "console.log(require('crypto').createHash('sha256').update('dnsg2010:' + 'matkhaukhongdau').digest('hex'))"
```

Dán kết quả vào `PASS_HASHES` trong `CONFIG`.

## Chạy thử trên máy
Trang cần chạy qua HTTP(S), không mở trực tiếp file:

```
npx serve .
```

## Deploy
Tải nguyên thư mục lên Netlify, Vercel hoặc GitHub Pages. Trang cần HTTPS để kiểm tra mật khẩu.
