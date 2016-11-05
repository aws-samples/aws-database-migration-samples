
create view sporting_event_ticket_info as
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
from sporting_event_ticket t
JOIN sporting_event_info e ON t.sporting_event_id = e.event_id
LEFT OUTER JOIN person p ON t.ticketholder_id = p.id;

go