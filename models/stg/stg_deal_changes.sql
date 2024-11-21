with deal_changes as (select * from {{ source('postgres_public','deal_changes') }})

, duplicates as (
    select
        deal_id,
        change_time,
        changed_field_key,
        new_value,
        row_number() over (partition by deal_id, change_time, changed_field_key, new_value order by change_time)  as rnum
    from deal_changes
    where 1=1
)

select
    deal_id,
    change_time,
    changed_field_key,
    new_value
from duplicates
where rnum = 1