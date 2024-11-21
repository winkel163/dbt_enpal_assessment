with fields as (select * from {{ ref('stg_fields') }}),

 parsed_data as (
    select
        json_array_elements(field_value_options::json)  as option
    from fields
    where id = 23  -- lost_reason
)
select
    (option->>'id')::int  as id,
    option->>'label'  as lost_reason
FROM parsed_data