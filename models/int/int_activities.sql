with activity as (select * from {{ ref('stg_activity') }})

select
    due_to::date  as date,
    type,
    case type
        when 'meeting' then 3
        when 'sc_2' then 5
        else 0
    end  as stage_id,
    deal_id
from activity
where 1=1
and type in ('meeting','sc_2')
and done