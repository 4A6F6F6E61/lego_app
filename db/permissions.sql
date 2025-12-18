alter table public.sets enable row level security;
alter table public.set_parts enable row level security;

-- Sets policies
create policy "Users can view their own sets"
  on public.sets for select
  using ( auth.uid() = user_id );

create policy "Users can insert their own sets"
  on public.sets for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own sets"
  on public.sets for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own sets"
  on public.sets for delete
  using ( auth.uid() = user_id );

-- Set parts policies
create policy "Users can view their own set parts"
  on public.set_parts for select
  using ( auth.uid() = user_id );

create policy "Users can insert their own set parts"
  on public.set_parts for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own set parts"
  on public.set_parts for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own set parts"
  on public.set_parts for delete
  using ( auth.uid() = user_id );
