create function dbo.rand_int(@min INT, @max INT) RETURNS INT as
BEGIN
  DECLARE @myid uniqueidentifier;
  select @myid = new_id from getNewID

  DECLARE @randint INT;
  SELECT @randint = ABS(Checksum(@myid) % (@max - @min +1)) + @min;
  RETURN(@randint)
END;

go