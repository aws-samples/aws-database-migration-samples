CREATE OR REPLACE FUNCTION esubstr(
    str character varying,
    pos integer,
    cnt integer)
  RETURNS character varying AS
$BODY$
declare
	len int;
begin
	if str is null or pos is null or cnt is null then
		return null;
	elsif cnt <= 0 or pos = 0 then
		return '';
	elsif pos > 0 then
		return substr(str, pos, cnt);
	elsif pos < 0 then
		len := length(str);
		return substr(str, len+pos+1, cnt);
	end if;
end;
$BODY$
  LANGUAGE plpgsql;
