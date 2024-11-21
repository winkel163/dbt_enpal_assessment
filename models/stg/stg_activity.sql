with activity as (select * from {{ source('postgres_public','activity') }})

, duplicates as (
    select
        activity_id,
        type,
        assigned_to_user,
        deal_id,
        done,
        due_to,
        row_number() over (partition by activity_id order by due_to)  as rnum
    from activity
    where 1=1
)

select
    activity_id,
    type,
    assigned_to_user,
    deal_id,
    done,
    due_to
from duplicates
where rnum = 1