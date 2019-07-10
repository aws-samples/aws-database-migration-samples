drop index dms_sample.set_ev_id_tkholder_id_idx;
create index set_ev_id_tkholder_id_idx on sporting_event_ticket(sporting_event_id,ticketholder_id);
drop index dms_sample.se_start_date_fcn;
create index se_start_date_fcn on sporting_event(start_date_time);
exit;
