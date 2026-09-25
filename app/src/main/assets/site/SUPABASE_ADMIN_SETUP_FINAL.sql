-- MANADO P TAMPA BABELI - Supabase Admin Setup
-- Jalankan seluruh file ini sekali di Supabase SQL Editor.
-- Setelah itu buka /admin/ dan login dengan akun admin yang ditetapkan di bawah.

create extension if not exists pgcrypto;

do $$ begin
  create type public.order_status as enum ('Menunggu konfirmasi','Pembayaran dikonfirmasi','Diproses','Selesai','Dibatalkan');
exception when duplicate_object then null; end $$;

create table if not exists public.products (
  id text primary key,
  name text not null,
  category text not null default 'mobile',
  brand text not null default '',
  price bigint not null default 0 check (price >= 0),
  compare_price bigint not null default 0 check (compare_price >= 0),
  stock integer not null default 0 check (stock >= 0),
  image_url text not null default '',
  description text not null default '',
  rating numeric(2,1) not null default 0 check (rating >= 0 and rating <= 5),
  badge text not null default 'NEW',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique,
  user_id uuid null references auth.users(id) on delete set null,
  customer_name text not null default '',
  customer_phone text not null default '',
  shipping_address text not null default '',
  payment_method text not null default '',
  subtotal bigint not null default 0 check (subtotal >= 0),
  discount bigint not null default 0 check (discount >= 0),
  total bigint not null default 0 check (total >= 0),
  items jsonb not null default '[]'::jsonb,
  status public.order_status not null default 'Menunggu konfirmasi',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id text null references public.products(id) on delete set null,
  product_name text not null default '',
  customer_name text not null default 'Pelanggan',
  rating integer not null default 5 check (rating between 1 and 5),
  content text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.product_backups (
  id uuid primary key default gen_random_uuid(),
  product_id text not null,
  action text not null check (action in ('UPDATE','DELETE')),
  snapshot jsonb not null,
  actor_user_id uuid null,
  actor_email text not null default '',
  created_at timestamptz not null default now()
);

-- Kolom tambahan untuk database yang sudah pernah dibuat sebelumnya.
alter table public.products add column if not exists badge text not null default 'NEW';
alter table public.products add column if not exists rating numeric(2,1) not null default 0;
alter table public.products add column if not exists is_active boolean not null default true;
alter table public.products add column if not exists updated_at timestamptz not null default now();
alter table public.products add column if not exists created_at timestamptz not null default now();
alter table public.orders add column if not exists updated_at timestamptz not null default now();

create index if not exists products_active_created_idx on public.products(is_active, created_at desc);
create index if not exists orders_created_idx on public.orders(created_at desc);
create index if not exists reviews_created_idx on public.reviews(created_at desc);
create index if not exists backups_created_idx on public.product_backups(created_at desc);
create index if not exists backups_product_idx on public.product_backups(product_id, created_at desc);

create or replace function public.set_updated_at()
returns trigger language plpgsql security invoker as $$
begin new.updated_at = now(); return new; end $$;

drop trigger if exists products_set_updated_at on public.products;
create trigger products_set_updated_at before update on public.products for each row execute function public.set_updated_at();
drop trigger if exists orders_set_updated_at on public.orders;
create trigger orders_set_updated_at before update on public.orders for each row execute function public.set_updated_at();

-- Ganti email ini jika akun administrator Anda berbeda.
create or replace function public.is_mpb_admin()
returns boolean
language sql stable security definer set search_path = public
as $$ select coalesce((auth.jwt()->>'email')::text,'') = 'jhuandi17@gmail.com' or coalesce((auth.jwt()->'app_metadata'->>'role')::text,'') = 'admin' $$;

-- Backup otomatis sebelum UPDATE/DELETE produk.
create or replace function public.backup_product_before_change()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  if public.is_mpb_admin() then
    insert into public.product_backups(product_id, action, snapshot, actor_user_id, actor_email)
    values (
      old.id,
      case when tg_op = 'DELETE' then 'DELETE' else 'UPDATE' end,
      to_jsonb(old),
      auth.uid(),
      coalesce(auth.jwt()->>'email','')
    );
  end if;
  return old;
end $$;

drop trigger if exists products_backup_before_change on public.products;
create trigger products_backup_before_change before update or delete on public.products for each row execute function public.backup_product_before_change();

alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.reviews enable row level security;
alter table public.product_backups enable row level security;

drop policy if exists products_public_read on public.products;
create policy products_public_read on public.products for select to anon, authenticated using (is_active = true or public.is_mpb_admin());
drop policy if exists products_admin_insert on public.products;
create policy products_admin_insert on public.products for insert to authenticated with check (public.is_mpb_admin());
drop policy if exists products_admin_update on public.products;
create policy products_admin_update on public.products for update to authenticated using (public.is_mpb_admin()) with check (public.is_mpb_admin());
drop policy if exists products_admin_delete on public.products;
create policy products_admin_delete on public.products for delete to authenticated using (public.is_mpb_admin());

drop policy if exists orders_customer_insert on public.orders;
create policy orders_customer_insert on public.orders for insert to anon, authenticated with check (user_id is null or user_id = auth.uid());
drop policy if exists orders_owner_read on public.orders;
create policy orders_owner_read on public.orders for select to authenticated using (user_id = auth.uid() or public.is_mpb_admin());
drop policy if exists orders_admin_update on public.orders;
create policy orders_admin_update on public.orders for update to authenticated using (public.is_mpb_admin()) with check (public.is_mpb_admin());

drop policy if exists reviews_public_read on public.reviews;
create policy reviews_public_read on public.reviews for select to anon, authenticated using (true);
drop policy if exists reviews_public_insert on public.reviews;
create policy reviews_public_insert on public.reviews for insert to anon, authenticated with check (rating between 1 and 5);
drop policy if exists reviews_admin_delete on public.reviews;
create policy reviews_admin_delete on public.reviews for delete to authenticated using (public.is_mpb_admin());

drop policy if exists backups_admin_read on public.product_backups;
create policy backups_admin_read on public.product_backups for select to authenticated using (public.is_mpb_admin());
drop policy if exists backups_admin_insert on public.product_backups;
create policy backups_admin_insert on public.product_backups for insert to authenticated with check (public.is_mpb_admin());

-- Seed produk tidak dibuat di sini agar isi katalog yang sudah ada tidak tertimpa.
-- Anda dapat menambah produk baru langsung dari /admin/.


-- Produk katalog bawaan: Kabel Data Type-C Fast Charging 5A. Tidak menimpa produk jika SKU sudah ada.
insert into public.products (id, name, category, brand, price, compare_price, stock, image_url, description, rating, badge, is_active)
values (
  'type-c-fast-charging-5a',
  'Kabel Data Type-C Fast Charging 5A',
  'mobile',
  'Fast Charging',
  25000,
  0,
  20,
  'assets/type-c-fast-charging-5a.webp',
  'Kabel data Type-C dengan konektor USB-C, material silikon fleksibel, dan dukungan output hingga 5A sesuai informasi pada kemasan. Cocok untuk pengisian daya harian berbagai perangkat Type-C; kemampuan charging aktual mengikuti charger, perangkat, dan protokol yang digunakan.',
  5,
  'HARGA SPESIAL',
  true
)
on conflict (id) do nothing;

-- Produk katalog bawaan: Universal Earphone HD Mic K2. Tidak menimpa produk jika SKU sudah ada.
insert into public.products (id, name, category, brand, price, compare_price, stock, image_url, description, rating, badge, is_active)
values (
  'universal-earphone-hd-mic',
  'Universal Earphone HD Mic K2',
  'audio',
  'Universal / JBL by HARMAN (sesuai kemasan)',
  35000,
  45000,
  20,
  'assets/universal-earphone-hd-mic.webp',
  'Universal earphone kabel dengan HD Mic dan jack 3,5 mm. Desain in-ear ergonomis untuk penggunaan harian, dengan mikrofon untuk panggilan suara serta kabel yang dirancang agar praktis digunakan. Kompatibel dengan perangkat yang memiliki port audio 3,5 mm seperti HP, tablet, laptop, PC, dan perangkat audio yang sesuai.',
  5,
  'HARGA SPESIAL',
  true
)
on conflict (id) do nothing;

select 'SUPABASE ADMIN SETUP SELESAI' as status;

-- Produk katalog bawaan: Fleco CH-205 2in1. Tidak menimpa produk jika SKU sudah ada.
insert into public.products (id, name, category, brand, price, compare_price, stock, image_url, description, rating, badge, is_active)
values (
  'fleco-ch205-2in1-charger',
  'Fleco CH-205 Charger Adapter 2in1',
  'mobile',
  'Fleco',
  45000,
  0,
  10,
  'assets/fleco-ch205-charger.webp',
  'Fleco CH-205 Charger Adapter 2in1 dengan output hingga 4.4A dan 2 port USB untuk mengisi dua perangkat sekaligus. Dilengkapi proteksi IC untuk membantu melindungi dari overcharge, overheat, dan short circuit. Desain praktis dan kokoh untuk kebutuhan charging harian; spesifikasi mengikuti informasi pada kemasan produk.',
  5,
  'NEW',
  true
)
on conflict (id) do nothing;