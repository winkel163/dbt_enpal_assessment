with deal_changes as (select * from {{ ref('stg_deal_changes') }})

, deal_stages as (
    select
        deal_id,
        new_value  as stage_id,
        change_time::date  as stage_start_date,
        lead(change_time::date) over (partition by deal_id order by change_time)  as stage_end_date,
        min(change_time::date) over (partition by deal_id)  as deal_created
    from deal_changes
    where 1=1
        and changed_field_key = 'stage_id'
)

select
    deal_id,
    stage_id::int  as stage_id,
    stage_start_date,
    stage_end_date,
    coalesce(stage_end_date, current_date) - stage_start_date  as days_in_stage,
    deal_created,
    stage_start_date - deal_created  as days_to_reach_stage
from deal_stages