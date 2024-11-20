/*select * 
from public.encounters
where encounterclass in ('outpatient','ambulatory')

	
select description,
	count(*) as count_of_condition
from public.conditions
where description != 'Body Mass Index 30.0-30.9, adult'
group by description
having count(*) > 10000
order by count(*) desc 


select * 
from public.patients
where city = 'Boston'


select * 
from public.conditions
where code in ('585.1', '585.2', '585.3', '585.4')


select city, count(*) as no_of_patients
from public.patients
where city != 'Boston'
group by city
having count(*) >= 100
order by count(*) desc


select t1.*,
	t2.first,
	t2.last,
	t2.birthdate
from public.immunizations as t1
left join public.patients as t2
  on t1.patient = t2.id
*/

with active_patients as 
(
	select distinct patient
	from encounters as e
	join patients as pat
	on e.patient = pat.id
	where start between '2020-01-01 00:00' and '2022-12-31 23:59'
	and pat.deathdate is null
	and extract(month from age('2022-12-31', pat.birthdate)) >= 6
),


flu_shot_2022 as 
(
select patient, min(date) as earliest_flu_shot_2022 
from immunizations
where code = '5302'
and date between '2022-01-01 00:00' and '2022-12-31 23:59'
group by patient 
)
	
select pat.birthdate,
	pat.race,
	pat.county,
	pat.id,
	pat.first,
	pat.last,
	flu.earliest_flu_shot_2022,
	flu.patient,
	case when flu.patient is not null then 1
	else 0
	end as flu_shot_2022
from patients as pat
left join flu_shot_2022 as flu
on pat.id = flu.patient
where 1=1
and pat.id in (select patient from active_patients)