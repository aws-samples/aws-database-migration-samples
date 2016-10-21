LOAD DATA
INFILE 'master.csv'
BADFILE 'master.bad'
DISCARDFILE 'master.dsc'
INTO TABLE mlb_data
WHEN (57) = '.'
TRAILING NULLCOLS