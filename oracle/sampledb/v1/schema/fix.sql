drop index dms_sample.set_ev_id_tkholder_id_idx;
create index dms_sample.set_ev_id_tkholder_id_idx on dms_sample.sporting_event_ticket(sporting_event_id,ticketholder_id);
drop index dms_sample.se_start_date_fcn;
create index dms_sample.se_start_date_fcn on dms_sample.sporting_event(start_date_time);
alter table dms_sample.sport_location modify (id number);
exit;
