
create view sporting_event_info as 
select e.id as event_id
     , e.sport_type_name sport
     , e.start_date_time event_date_time
     , h.name home_team
     , a.name away_team
     , l.name location
     , l.city city
from sporting_event e, sport_team h, sport_team a, sport_location l
where e.home_team_id = h.id
and e.away_team_id = a.id
and e.location_id = l.id;

go