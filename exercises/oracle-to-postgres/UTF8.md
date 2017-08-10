# Invalid UTF8 issue while migrating from Oracle to PostgreSQL

One of the most common issue while migrating from Oracle to PostgreSQL using AWS Database Migration Service is the where the customers face the following error in the DMS task logs:

    [TARGET_LOAD ]D: Load command output: ERROR: invalid byte sequence for encoding "UTF8": 0xed 0xa0 0xbd, CONTEXT: COPY cs_actions, line 1 (csv_target.c:891)
    
The cause of this error is bascially due to the high surrogates of UTF8 values which are categorized as 4 bytes characters(**UTF8MB4**) which were previously not supported by the available DMS version. Following are the two possible workarounds for getting rid of these errors and performing your migration smoothly:

## Using DMS Extra Connection Attributes

* Always run the task in [detailed debug mode][t].
* As soon as this task fails, please search in the logs for messages like:

    [TARGET_LOAD ]D: Load command output: ERROR: invalid byte sequence for encoding "UTF8": 0xed 0xa0 0xbd, CONTEXT: COPY cs_actions, line 1 (csv_target.c:891)

* From the above mentioned excerpt, you can will get the sequence **`0xed 0xa0 0xbd`**.
* Removing the **`0x`** and the **spaces** in between them and writing it in CAPS will give you **`EDA0BD`**
* Introduce the below mentioned extra connection attribute in your target endpoint:

```
ReplaceChars=EDA0BD,3F
```

The thing that we are doing in the above step is let the DMS determine the invalid byte sequence not supported by DMS and the replacing the same with a question mark**(3F)**.

* After modifying the target endpoint to include the above mentioned extra connection attribute, please go ahead and do the **Test Connections** for the target endpoint to make sure changes are applied correctly. 

* You will also find multiple messages related to invalid byte sequence. So every time you need to get the sequence from the logs and append it to the existing extra connection attribute in the target endpoint. For Eg:

```
ReplaceChars=EDA0BD,3F,EDB18D,3F,EDB89C,3F,EDB080,3F
```

Additionally, you will need to do **Test Connections** every time you modify your endpoint.

* Once done, go ahead and **RESTART** your task and check if it fails again. If it does, then please repeat all the steps as listed above.

## Oracle CSSCAN Utility

I would like to suggest based on some of the use-cases that I have worked on, using Oracle’s CSSCAN utility to identify such characters on your Oracle source is the most relaible method. 

**Note**: This utility might not work with RDS Oracle as it needs sysdba privileges. You need to seek AWS Support for assistance.

Example command to invoke this utility:

```
csscan TABLE='(TABLE_NAME)' FROMCHAR=AL32UTF8  TOCHAR=UTF8 LOG=CANDIDATE_NOTES CAPTURE=N PROCESS=1 ARRAY=1024000
```

Addtitonally, consulting your DBA before performing the same on your production database. Also there are many other ways to stripe the data that I am not aware about. Contacting oracle with regards to that might also help you in this situation.

[t]: https://forums.aws.amazon.com/ann.jspa?annID=4263

## Custom Queries

There are ceratin queries, which can be used as last restort if CSSCAN doesn't help or it is not helping you find out the exact table rows having the faulty UTF8 data. The below mentioned queries will surely help you to point out the exact rows and work on it. The queries have been differentiated based on values of **NLS_CHARACTERSET** and **NLS_NCHAR_CHARACTERSET**.

* If **NLS_CHARACTERSET=AL32UTF8** and **NLS_NCHAR_CHARACTERSET=AL16UTF16**

Use the below mentioned query to find the invalid UTF8 bytes, with regards to particular column.

```
SELECT <Primary_Key_Column>||' '||<Problematic_Column> FROM Tablename WHERE REGEXP_LIKE(<Problematic_Column>, UNISTR('[\D800-\DFFF]'));
```

Basically <Problematic_Column> should be the column of the type **Varchar2**. Preferrably I would recommend to run the above query against each and every **varchar** and **varchar2** type columns. But if your tables have columns like **varchar(200)** or **varchar2(200)**, then likely these columns are the problematic ones. 

Once you have found the columns, you can execute the below mentioned **UPDATE** query to replace the invalid bytes with question mark `?(003F)`:

```
UPDATE Tablename SET <Problematic_Column> = REGEXP_REPLACE(<Problematic_Column>, UNISTR('[\D800-\DFFF]'), UNISTR('\003F'))
```
The above update query will automatically scan the whole column that you have mentioned and replace the invalid bytes with question mark.

* If **NLS_CHARACTERSET=UTF8** and **NLS_NCHAR_CHARACTERSET=AL16UTF16**

Use the below mentioned query to find the invalid UTF8 bytes, with regards to particular column.

```
SELECT REGEXP_SUBSTR(str, UNISTR('[\FFFF-\DBFF\DFFF]')) AS substr FROM (SELECT <Problematic_Column> str FROM Table_name)
```

Use the below mentioned query to update the faulty data in these columns.

```
UPDATE Table_name SET <Problematic_Column> = REGEXP_REPLACE(<Problematic_Column>, UNISTR('[\FFFF-\DBFF\DFFF]'), UNISTR('\00BF'));
```
