-- 1. Create a BEFORE UPDATE trigger on address table to set last_update =
--     NOW() whenever a row is changed. 

create or replace function fn_set_last_update() 
returns trigger as $$
begin
    new.last_update = now();
    return new;
end;
$$ language plpgsql;

create trigger trg_address_last_update
before update on address
for each row
execute function fn_set_last_update();

select * 
from address 
where address_id = 1;

update address 
set district = 'test trigger' 
where address_id = 1;








--2. Create a BEFORE DELETE trigger on payment table that prevents deleting
--   any payment record older than 1 year 

create or replace function fn_prevent_old_payment_deletion() 
returns trigger as $$
begin
    if old.payment_date < now() - interval '1 year' then
        raise exception 'can not delete payment that older than 1 year';
    end if;
    return old;
end;
$$ language plpgsql;

create or replace trigger trg_prevent_old_payment_deletion
before delete on payment
for each row
execute function fn_prevent_old_payment_deletion();

select * from payment limit 1;

delete from payment where payment_id = 16051;

create table payment_p2026_01 partition of payment
for values from ('2026-01-01') to ('2026-02-01');

insert into payment (customer_id, staff_id, rental_id, amount, payment_date) 
values (1, 1, 1, 0.00, now());

select * from payment where amount = 0.00 order by payment_id desc limit 1;

delete from payment where payment_id = 32102;




-- 3. Create a trigger to prevent an UPDATE to the staff table if the username is changed to 'admin'

create or replace function fn_prevent_admin_username() 
returns trigger as $$
begin
    if new.username = 'admin' then
        raise exception 'can not change your username to "admin"';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_prevent_admin_username
before update on staff
for each row
execute function fn_prevent_admin_username();


select * from staff;

update staff 
set username = 'admin' 
where staff_id = 1;


-- 4. Create a trigger that INITCAPs the city name before it is inserted into the city table. 

create or replace function fn_initcap_city() 
returns trigger as $$
begin
    new.city = initcap(new.city);
    return new;
end;
$$ language plpgsql;

create trigger trg_city_initcap
before insert on city
for each row
execute function fn_initcap_city();

select * from city;

insert into city (city, country_id) values ('sohag city', 29);

select * from city order by city_id desc limit 1;



-- 5. Create a table inventory_log. Write a trigger that records the inventory_id
--    and action ('INSERT' or 'DELETE') whenever the inventory changes.


create table inventory_log (
    log_id serial primary key,
    inventory_id int,
    action varchar(10),
    changed_at timestamp default now()
);


create or replace function fn_log_inventory_changes()
returns trigger as $$
begin
    if (tg_op = 'INSERT') then
        insert into inventory_log (inventory_id, action)
        values (new.inventory_id, 'insert');
        return new;
    elsif (tg_op = 'DELETE') then
        insert into inventory_log (inventory_id, action)
        values (old.inventory_id, 'delete');
        return old;
    end if;
    return null;
end;
$$ language plpgsql;


create trigger trg_inventory_log
after insert or delete on inventory
for each row
execute function fn_log_inventory_changes();

insert into inventory (film_id, store_id) values (1, 1);

delete from inventory where inventory_id = (select max(inventory_id) from inventory);

select * from inventory_log;


-- 6. Create an INSTEAD OF UPDATE trigger on a view that joins film and
--    language to allow updating the language name through the view

create or replace view film_language_view as
select f.film_id, f.title, l.name as language_name
from film f
join language l on f.language_id = l.language_id;

create or replace function fn_update_language_through_view()
returns trigger as $$
begin
    update language
    set name = new.language_name
    where language_id = (select language_id from film where film_id = old.film_id);
    
    return new;
end;
$$ language plpgsql;

create trigger trg_instead_of_update_lang
instead of update on film_language_view
for each row
execute function fn_update_language_through_view();

update film_language_view 
set language_name = 'arabic' 
where film_id = 1;


select * from film_language_view where film_id = 1;

select * from language;