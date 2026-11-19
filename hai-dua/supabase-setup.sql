-- =====================================================================
-- "Hai Đứa Mình" — dựng cơ sở dữ liệu trên Supabase
-- Chạy toàn bộ file này một lần trong Supabase → SQL Editor → New query → Run.
-- =====================================================================

-- 1. Danh sách thành viên: chỉ những tài khoản có ở đây mới đọc/ghi được dữ liệu.
create table if not exists public.members (
  user_id      uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at   timestamptz not null default now()
);

create or replace function public.is_member()
returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.members where user_id = auth.uid()) $$;

-- 2. Danh sách những điều muốn làm cùng nhau
create table if not exists public.items (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  note        text,
  theme       text not null default 'heart',
  position    int  not null default 0,
  done_at     date,
  done_by     uuid references auth.users(id),
  created_by  uuid references auth.users(id) default auth.uid(),
  created_at  timestamptz not null default now()
);

-- 3. Ảnh kỷ niệm (ảnh lưu trong Storage, bảng này giữ thông tin đi kèm)
create table if not exists public.memories (
  id              uuid primary key default gen_random_uuid(),
  item_id         uuid references public.items(id) on delete set null,
  photo_path      text not null,
  thumb_path      text not null,
  caption         text,
  taken_on        date not null default current_date,
  width           int,
  height          int,
  created_by      uuid references auth.users(id) default auth.uid(),
  created_by_name text,
  created_at      timestamptz not null default now()
);

alter table public.members  enable row level security;
alter table public.items    enable row level security;
alter table public.memories enable row level security;

drop policy if exists "thanh vien xem danh sach thanh vien" on public.members;
create policy "thanh vien xem danh sach thanh vien" on public.members
  for select using (public.is_member());

drop policy if exists "thanh vien quan ly items" on public.items;
create policy "thanh vien quan ly items" on public.items
  for all using (public.is_member()) with check (public.is_member());

drop policy if exists "thanh vien quan ly memories" on public.memories;
create policy "thanh vien quan ly memories" on public.memories
  for all using (public.is_member()) with check (public.is_member());

-- 4. Kho ảnh riêng tư: không có link công khai, chỉ thành viên mới xem được
insert into storage.buckets (id, name, public)
values ('memories', 'memories', false)
on conflict (id) do nothing;

drop policy if exists "thanh vien xem anh" on storage.objects;
create policy "thanh vien xem anh" on storage.objects
  for select using (bucket_id = 'memories' and public.is_member());

drop policy if exists "thanh vien tai anh len" on storage.objects;
create policy "thanh vien tai anh len" on storage.objects
  for insert with check (bucket_id = 'memories' and public.is_member());

drop policy if exists "thanh vien xoa anh" on storage.objects;
create policy "thanh vien xoa anh" on storage.objects
  for delete using (bucket_id = 'memories' and public.is_member());

-- 5. Mười điều đầu tiên
insert into public.items (title, note, theme, position, created_by)
select * from (values
  ('Cùng nhau vào bếp',                  'Một bữa cơm hai đứa tự nấu. Ai nấu chính, ai rửa chén thì oẳn tù tì.', 'cook',    1, null::uuid),
  ('Hóng gió biển Vũng Tàu',             'Ăn bánh khọt, ngồi Bãi Sau chờ hoàng hôn.',                           'beach',   2, null),
  ('Ngắm đồi cát Phan Thiết',            'Dậy thật sớm, ngắm bình minh trên đồi cát Mũi Né.',                    'dunes',   3, null),
  ('Một ngày ở Golden Lotus',            'Một ngày thả lỏng, không nhắc tới công việc.',                         'lotus',   4, null),
  ('Trốn lên Đà Lạt',                    'Áo khoác dày, ly sữa đậu nóng, đi bộ giữa rừng thông.',                'pine',    5, null),
  ('Về Đà Nẵng ra mắt ba mẹ',            'Chuyến về nhà quan trọng nhất. Anh sẽ tập trước câu chào.',            'dragon',  6, null),
  ('Đi ăn cùng Đạt và Kim Ngân',         'Buổi hẹn bốn người đầu tiên.',                                         'friends', 7, null),
  ('Ra mắt hội nhóc văn phòng của anh',  'Mấy đứa nhỏ hóng gặp chị lâu lắm rồi.',                                'office',  8, null),
  ('Chụp một dải photobooth',            'Bốn kiểu, tạo dáng gì cũng được, miễn là có hai đứa.',                 'booth',   9, null),
  ('Hẹn hò ở rạp phim',                  'Một suất phim, một bịch bắp, hai cái ghế sát nhau.',                   'movie',  10, null)
) as v(title, note, theme, position, created_by)
where not exists (select 1 from public.items);

-- =====================================================================
-- 6. CHẠY SAU KHI CẢ HAI ĐÃ ĐĂNG NHẬP BẰNG FACEBOOK MỘT LẦN
--    (lúc đó Authentication → Users chỉ có đúng 2 tài khoản của hai người).
--    Bỏ dấu "--" ở 3 dòng dưới rồi chạy riêng đoạn này:
-- =====================================================================
-- insert into public.members (user_id, display_name)
-- select id, coalesce(raw_user_meta_data->>'full_name', raw_user_meta_data->>'name') from auth.users
-- on conflict (user_id) do nothing;
