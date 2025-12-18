create table if not exists public.sets (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  set_num text not null,
  name text not null,
  year int,
  theme_id int,
  num_parts int,
  img_url text,
  created_at timestamptz default now()
);

create table if not exists public.set_parts (
  id uuid default gen_random_uuid() primary key,
  set_id uuid references sets(id) on delete cascade not null,
  user_id uuid references auth.users not null,
  part_num text not null,
  color_id int not null,
  name text,
  img_url text,
  quantity_needed int not null,
  quantity_found int default 0 not null,
  is_spare boolean default false
);

create index if not exists sets_user_id_idx on sets(user_id);
create index if not exists set_parts_user_id_idx on set_parts(user_id);
create index if not exists set_parts_set_id_idx on set_parts(set_id);
