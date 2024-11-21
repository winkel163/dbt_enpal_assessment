with 
deal_changes   as (select * from {{ ref('stg_deal_changes') }}),

hist as (
    select
        deal_id,
        case when changed_field_key = 'add_time' then new_value end  as add_time,
        case when changed_field_key = 'user_id' then new_value end  as user_id,
        case when changed_field_key = 'lost_reason' then new_value end  as lost_reason,
        change_time  as valid_from,
        lead(change_time) over (partition by deal_id order by change_time)  as valid_to
    from deal_changes
    where 1=1
    and changed_field_key != 'stage_id'
)

select
    deal_id,
    min(add_time)  as add_time,
    (array_remove(array_agg(user_id order by valid_from), null))[1]  as first_user_id,
    (array_remove(array_agg(user_id order by valid_from desc), null))[1]  as last_user_id,
    (array_remove(array_agg(lost_reason order by valid_from desc), null))[1]  as lost_reason
from hist
group by
    deal_id