with
deal_stages   as (select * from {{ ref('int_deal_stages') }}),
stages        as (select * from {{ ref('dim_stage') }}),

base as (
    select
        date_trunc('month', ds.deal_created)::date  as deal_created_month,
        ds.stage_id,
        s.stage_name,
        count(distinct ds.deal_id)  as deals_count,
        avg(days_in_stage)::int  as avg_days_in_stage,
        avg(days_to_reach_stage)::int  as avg_days_to_reach_stage
    from deal_stages ds
        left join stages s
            on ds.stage_id = s.stage_id
    group by
        date_trunc('month', ds.deal_created)::date,
        ds.stage_id,
        s.stage_name
),

totals as (
    select
        deal_created_month,
        stage_id,
        stage_name,
        deals_count,
        avg_days_in_stage,
        avg_days_to_reach_stage,
        sum(case when stage_id = 1 then deals_count end) over (partition by deal_created_month)  as init_deals_count
    from base
)

select
    deal_created_month,
    stage_id,
    stage_name,
    deals_count,
    round((deals_count / init_deals_count * 100), 1)  as deal_passed_perc,
    avg_days_to_reach_stage,
    avg_days_in_stage
from totals