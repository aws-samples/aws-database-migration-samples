create or replace view sporting_event_ticket_info as
select t.id as ticket_id
      ,e.event_id
      ,e.sport
      ,e.event_date_time
      ,e.home_team
      ,e.away_team
      ,e.location
      ,e.city
      ,t.seat_level
      ,t.seat_section
      ,t.seat_row
      ,t.seat
      ,t.ticket_price
      ,p.full_name as ticketholder
from sporting_event_info e
   , sporting_event_ticket t
   , person p
where t.sporting_event_id = e.event_id
and   t.ticketholder_id = p.id (+)
/
