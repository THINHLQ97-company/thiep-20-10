# Hai Đứa Mình: hướng dẫn bật đăng nhập Facebook

Trang chạy ở `https://www.2010gift.cloud/hai-dua/`. Khi `SUPABASE_URL` và `SUPABASE_ANON_KEY` trong `index.html` còn trống, trang ở **chế độ xem thử**: dữ liệu chỉ lưu trên máy đang mở. Làm 4 bước dưới đây để chuyển sang bản thật.

Trang được khoá bằng 3 lớp:

1. Ứng dụng Facebook để ở **chế độ phát triển**: chỉ người có vai trò trong ứng dụng (anh là quản trị viên, Duyên là người thử nghiệm) mới đăng nhập được.
2. Bảng `members` trong Supabase: chỉ hai tài khoản có trong bảng mới đọc hoặc ghi được danh sách và ảnh.
3. Tắt đăng ký mới trong Supabase sau khi hai người đã đăng nhập lần đầu.

---

## Bước 1. Tạo dự án Supabase (miễn phí)

1. Vào https://supabase.com, đăng nhập bằng GitHub, bấm **New project**. Chọn region **Singapore**, đặt mật khẩu database rồi lưu lại.
2. Vào **SQL Editor → New query**, dán toàn bộ file `supabase-setup.sql`, bấm **Run**. Lệnh này tạo bảng, kho ảnh riêng tư và 10 điều đầu tiên.
3. Vào **Project Settings → API**, chép 2 giá trị:
   - **Project URL**, dạng `https://abcd.supabase.co`
   - **anon public key**, chuỗi dài bắt đầu bằng `eyJ…`
4. Vào **Authentication → URL Configuration**:
   - **Site URL:** `https://www.2010gift.cloud/hai-dua/`
   - **Redirect URLs:** thêm `https://www.2010gift.cloud/hai-dua/`

## Bước 2. Tạo ứng dụng Facebook

1. Vào https://developers.facebook.com, chọn **My Apps → Create App**.
2. Ở bước chọn trường hợp sử dụng, chọn **Authenticate and request data from users with Facebook Login**. Đặt tên ứng dụng, ví dụ `Hai Dua Minh`.
3. Trong trường hợp sử dụng **Facebook Login**, bấm **Customize**, thêm quyền **email** (quyền `public_profile` có sẵn).
4. Mở **Facebook Login → Settings**. Ở ô **Valid OAuth Redirect URIs**, dán đường dẫn callback lấy từ Supabase (xem Bước 3, mục 2), dạng `https://abcd.supabase.co/auth/v1/callback`. Bấm **Save**.
5. Vào **App settings → Basic**, chép **App ID** và **App Secret**. Ở ô **App Domains**, thêm `2010gift.cloud`.
6. Vào **App roles → Roles → Add People**, thêm Facebook của Duyên với vai trò **Tester**. Duyên cần mở https://developers.facebook.com/requests để chấp nhận lời mời. Nếu Facebook hỏi đăng ký tài khoản developer thì cứ đăng ký, mất khoảng một phút.
7. **Giữ ứng dụng ở chế độ Development**, đừng bấm chuyển sang Live. Ở chế độ này, chỉ anh và Duyên đăng nhập được.

## Bước 3. Nối Facebook với Supabase

1. Trong Supabase, vào **Authentication → Sign In / Providers → Facebook**, bật lên.
2. Chép **Callback URL** hiện ở đó, dán vào Facebook như Bước 2, mục 4.
3. Dán **App ID** vào ô *Facebook client ID*, **App Secret** vào ô *Facebook secret*, rồi bấm **Save**.

## Bước 4. Điền khoá vào trang và mời hai người vào

1. Mở `hai-dua/index.html`, tìm khối `CONFIG` ở đầu phần `<script>` rồi điền:
   ```js
   SUPABASE_URL: 'https://abcd.supabase.co',
   SUPABASE_ANON_KEY: 'eyJ…',
   TOGETHER_SINCE: '2026-11-xx',   // ngày hai đứa thành người yêu (không bắt buộc)
   ```
   Khoá *anon* được phép công khai. Dữ liệu được bảo vệ bằng bảng `members` và các quy tắc bảo mật trong file SQL. **Không bao giờ** dán khoá `service_role` vào trang.
2. Đẩy lên GitHub. Vercel sẽ tự cập nhật trang.
3. Anh và Duyên **mỗi người đăng nhập một lần**. Lúc này trang sẽ báo "Trang này là của riêng hai người", vì hai người chưa có trong danh sách. Đó là bình thường.
4. Vào Supabase **Authentication → Users** để kiểm tra chỉ có đúng 2 tài khoản. Sau đó chạy đoạn SQL ở mục 6 cuối file `supabase-setup.sql`, nhớ bỏ dấu `--` ở đầu các dòng.
5. Vào **Authentication → Sign In / Providers**, tắt **Allow new users to sign up**.
6. Tải lại trang. Xong!

## Giữ Supabase luôn thức (không bắt buộc)

Gói miễn phí của Supabase tạm dừng dự án nếu 7 ngày liền không ai truy cập. Repo đã có sẵn `.github/workflows/supabase-keepalive.yml`, cứ 3 ngày gọi nhẹ vào Supabase một lần. Để bật, vào GitHub repo → **Settings → Secrets and variables → Actions**, thêm 2 secret `SUPABASE_URL` và `SUPABASE_ANON_KEY`.

## Dung lượng

Ảnh được thu nhỏ ngay trên điện thoại trước khi tải lên: bản lớn khoảng 1600px (thường 200–400 KB) và bản nhỏ 520px để hiện danh sách. Gói miễn phí có 1 GB lưu ảnh, đủ cho khoảng 2.500–3.000 tấm.
