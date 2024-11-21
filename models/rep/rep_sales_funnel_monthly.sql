with
  deal_stages   as (select * from {{ ref('int_deal_stages') }})
, activities    as (select * from {{ ref('int_activities') }})
, kpis          as (select * from {{ ref('dim_funnel_kpi') }})

select
    date_trunc('month', ds.stage_start_date)::date  as month,
    k.funnel_kpi,
    k.funnel_step,
    count(distinct ds.deal_id)  as deals_count
from deal_stages ds
    left join kpis k
        on ds.stage_id = k.stage_id
group by
    date_trunc('month', ds.stage_start_date)::date,
    ds.stage_id,
    k.funnel_kpi,
    k.funnel_step

union all

select
    date_trunc('month', a.date)::date  as month,
    k.funnel_kpi,
    k.funnel_step,
    count(distinct a.deal_id)  as deals_count
from activities a
    left join kpis k
        on a.type = k.activity_type
group by
    date_trunc('month', a.date)::date,
    k.funnel_kpi,
    k.funnel_step