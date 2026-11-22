DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=NULL;
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
		ELSEIF columntype='decimal' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,',2)',' default 0.00');
		ELSEIF columntype='int' THEN
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default 0');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
	profileid int(19),
	tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
	tabname varchar(50),
	permissions int(19)
)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `fieldprofile`;
delimiter ||
CREATE  PROCEDURE `fieldprofile`(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;

	declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;

	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO

		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_selectlead_wsfieldtype`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_selectlead_wsfieldtype`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_ws_fieldtype a LEFT JOIN ld_ws_referencetype b ON b.fieldtypeid=a.fieldtypeid WHERE b.type='Leads' AND a.uitype+0>=2000) THEN
		SET @max_uitype=(SELECT MAX(uitype+0) FROM ld_ws_fieldtype);
		SET @fieldtypeid=(SELECT MAX(fieldtypeid) FROM ld_ws_fieldtype);

		INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
		SELECT @fieldtypeid+1,IF(@max_uitype+1<2000,2000,@max_uitype+1),'reference';

		INSERT INTO ld_ws_referencetype(fieldtypeid,type) SELECT @fieldtypeid+1,'Leads';
	END IF;
end ||
delimiter;

CALL ldcrm_add_selectlead_wsfieldtype();
DROP PROCEDURE IF EXISTS `ldcrm_add_selectlead_wsfieldtype`;


SET @modulename='ContactRecords';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='leads_id'; 
SET @fieldname='leads_id'; 
SET @zh='销售线索'; 
SET @en='Leads'; 
SET @uitype=(SELECT uitype FROM ld_ws_fieldtype a LEFT JOIN ld_ws_referencetype b ON b.fieldtypeid=a.fieldtypeid WHERE b.type='Leads' AND a.uitype+0>=2000 LIMIT 1); 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='reference';
SET @datarang='all';
SET @maxrowsshow=5;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','19',0);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

SET @related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
SET @maxid=(SELECT MAX(relation_id) FROM ld_relatedlists);

INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,type,related_coltable,wx_presence)
SELECT @maxid+1,@tabid,@related_tabid,'get_contactRecords',1000,'ContactRecords',0,'add',1,'datacategory_sql','contactrecords.leads_id',0 FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid and related_tabid=@related_tabid);

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;


SET @leads_uitype=(SELECT uitype FROM ld_ws_fieldtype a LEFT JOIN ld_ws_referencetype b ON b.fieldtypeid=a.fieldtypeid WHERE b.type='Leads' AND a.uitype+0>=2000 LIMIT 1); 
UPDATE ld_field SET uitype=@leads_uitype WHERE tablename='ld_contactrecords' AND columnname='leads_id';
-- 2019-09-23

CREATE TABLE if not EXISTS `ld_reverseformula` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `reversetable` varchar(50) DEFAULT NULL,
  `relateid` int(19) DEFAULT NULL,
  `parentid` int(19) DEFAULT NULL,
  `formulastring` varchar(500) DEFAULT NULL,
  `columnstring` text,
  `reversetabid` int(19) DEFAULT NULL,
	`activatestatus` varchar(50) DEFAULT 'yes',
	`reversefieldtype` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

drop PROCEDURE if exists reverseproducttooldiscount;
delimiter ||
create PROCEDURE reverseproducttooldiscount(ttabid int(19) )
BEGIN
		set @sql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0) into @parentid from ld_producttoolfield where tabid=',ttabid,' and columnname="tax_amount" and tablename like "%detail"');
		
	  PREPARE stalter from @sql;
	  EXECUTE stalter;
		DEALLOCATE PREPARE stalter;
		set @discountamountfieldid=0;
    set @sql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0)  into @discountamountfieldid from ld_producttoolfield where tabid=',ttabid,' and columnname="discount_amount" and tablename like "%detail"');
    PREPARE stalter FROM @sql;
    EXECUTE stalter;
	  deallocate  prepare  stalter;
	 if @discountamountfieldid>0 then 
		 set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,formulastring,columnstring,reversetabid,reversefieldtype)');
		 set @sql=concat(@sql,' select "ld_producttoolfield",@discountamountfieldid,@parentid,"a*b-c",'); 
		 set @sql=concat(@sql,'"',"{formulavar:[{'lettervar':'a','column':'quantity'},{'lettervar':'b','column':'taxprice'},{'lettervar':'c','column':'tax_amount'}]}",'",',ttabid ,',"discount" from dual ');
		 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@discountamountfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
		 PREPARE stalter from @sql;
		 execute stalter;
		 DEALLOCATE PREPARE stalter;
	end if;
	set @discountpercentfieldid=0;
    set @sql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0)  into @discountpercentfieldid from ld_producttoolfield where tabid=',ttabid,' and columnname="discount_percent" and tablename like "%detail"');
    PREPARE stalter FROM @sql;
    EXECUTE stalter;
	  deallocate  prepare  stalter;
	 if @discountpercentfieldid>0 then 
	           set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,formulastring,columnstring,reversetabid,reversefieldtype)');
		      set @sql=concat(@sql,' select "ld_producttoolfield",@discountpercentfieldid,@parentid,"100-(a/(b*c/100))",'); 
			 set @sql=concat(@sql,'"',"{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'},{'lettervar':'c','column':'taxprice'}]}",'",',ttabid ,',"discount" from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@discountpercentfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and exists(select 1 from ld_producttoolfield_formula where producttoolfieldid=@parentid and formulastring like "%1-%")');
				
			PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;

			 set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,formulastring,columnstring,reversetabid,reversefieldtype)');
			 set @sql=concat(@sql,' select "ld_producttoolfield",@discountpercentfieldid,@parentid,"(a/(b*c/100))",'); 
			 set @sql=concat(@sql,'"',"{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'},{'lettervar':'c','column':'taxprice'}]}",'",',ttabid ,',"discount" from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@discountpercentfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and not exists(select 1 from ld_producttoolfield_formula where producttoolfieldid=@parentid and formulastring like "%1-%")');

			PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
	end if;
end ||
delimiter;

drop PROCEDURE if exists reverseproducttoolprice;
delimiter ||
create PROCEDURE reverseproducttoolprice(ttabid int(19) )
BEGIN
		  set @discount_percent_presence='no' ;

     set @sql=concat('select if(count(tabid)>0, "yes","no") into @discount_percent_presence from ld_producttoolfield where tabid=',ttabid,' and columnname="discount_percent" and presence in(0,2)');
   
		PREPARE stalter FROM @sql;
     EXECUTE stalter;
	   deallocate  prepare  stalter;
		
	  set @parentsql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0)  into @parentid from ld_producttoolfield where tabid=',ttabid,' and columnname="tax_amount" and tablename like "%detail"');
		
	  PREPARE stalter from @parentsql;
	  EXECUTE stalter;
		DEALLOCATE PREPARE stalter;
		
		set  @discountamountfieldid=0;
		set @relatesql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0)  into @discountamountfieldid from ld_producttoolfield where tabid=',ttabid,' and columnname="discount_amount" and tablename like "%detail"');
    PREPARE stalter FROM @relatesql;
    EXECUTE stalter;
	  deallocate  prepare  stalter;
	 if @discountamountfieldid>0 then 
				set @formulastring ="a*(1-(b/100))";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'discount_percent'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="a*0";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'}]}";
				end if;
				set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@discountamountfieldid,@parentid,"',@formulacolumn,'",'); 
				set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
				set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@discountamountfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
				set @sql=concat(@sql,' and  exists(select 1 from ld_producttoolfield_formula ');
				set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
			
				set @formulastring="a*(b/100)";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'discount_percent'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="a*0";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'}]}";
				end if;
			 set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
			 set @sql=concat(@sql,' select "ld_producttoolfield",@discountamountfieldid,@parentid,"',@formulacolumn,'",'); 
			 set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@discountamountfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and not exists(select 1 from ld_producttoolfield_formula ');
				set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
	end if;

  set @taxpricefieldid=0;
	 set @relatesql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0)  into @taxpricefieldid from ld_producttoolfield where tabid=',ttabid,' and columnname="taxprice" and tablename like "%detail"');
    PREPARE stalter FROM @relatesql;
    EXECUTE stalter;
	  deallocate  prepare  stalter;
	if @taxpricefieldid>0 then 
				set @formulastring="a/(b*(1-c/100))";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'},{'lettervar':'c','column':'discount_percent'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="a/b";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'}]}";
				end if;

				set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@taxpricefieldid,@parentid,"',@formulacolumn,'",'); 
			 set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@taxpricefieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and  exists(select 1 from ld_producttoolfield_formula ');
			 set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
				
				set @formulastring="a/(b*(c/100))";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'},{'lettervar':'c','column':'discount_percent'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="a/b";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'}]}";
				end if;
				 set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@taxpricefieldid,@parentid,"',@formulacolumn,'",'); 
			 set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@taxpricefieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and not exists(select 1 from ld_producttoolfield_formula ');
				set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
	end if;

	set  @listpricefieldid=0;
	 set @relatesql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0)  into @listpricefieldid from ld_producttoolfield where tabid=',ttabid,' and columnname="listprice" and tablename like "%detail"');
    PREPARE stalter FROM @relatesql;
    EXECUTE stalter;
	  deallocate  prepare  stalter;
	if @listpricefieldid>0 then 
				set @formulastring="(a/(b*(1-c/100)))/(1+d/100+e/100+f/100)";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'},{'lettervar':'c','column':'discount_percent'},{'lettervar':'d','column':'tax1'},{'lettervar':'e','column':'tax2'},{'lettervar':'f','column':'tax3'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="(a/b)/(1+d/100+e/100+f/100)";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'},{'lettervar':'d','column':'tax1'},{'lettervar':'e','column':'tax2'},{'lettervar':'f','column':'tax3'}]}";
				end if;

				set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@listpricefieldid,@parentid,"',@formulacolumn,'",'); 
			 set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@listpricefieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and  exists(select 1 from ld_producttoolfield_formula ');
			 set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
				
				set @formulastring="(a/(b*c/100))/(1+d/100+e/100+f/100)";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'},{'lettervar':'c','column':'discount_percent'},{'lettervar':'d','column':'tax1'},{'lettervar':'e','column':'tax2'},{'lettervar':'f','column':'tax3'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="(a/b)/(1+d/100+e/100+f/100)";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'},{'lettervar':'d','column':'tax1'},{'lettervar':'e','column':'tax2'},{'lettervar':'f','column':'tax3'}]}";
				end if;
				 set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@listpricefieldid,@parentid,"',@formulacolumn,'",'); 
			 set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@listpricefieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and not  exists(select 1 from ld_producttoolfield_formula ');
				set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;

	end if ;
	set @listamountfieldid=0;
		set @relatesql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0)  into @listamountfieldid from ld_producttoolfield where tabid=',ttabid,' and columnname="list_amount" and tablename like "%detail"');
    PREPARE stalter FROM @relatesql;
    EXECUTE stalter;
	  deallocate  prepare  stalter;
		if @listamountfieldid>0 then 
				set @formulastring="(a*(1-b/100))/(1+c/100+d/100+e/100)";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'discount_percent'},{'lettervar':'c','column':'tax1'},{'lettervar':'d','column':'tax2'},{'lettervar':'e','column':'tax3'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="a/(1+b/100+c/100+d/100)";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'tax1'},{'lettervar':'c','column':'tax2'},{'lettervar':'d','column':'tax3'}]}";
				end if;

				set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@listamountfieldid,@parentid,"',@formulacolumn,'",'); 
			 set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@listamountfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and  exists(select 1 from ld_producttoolfield_formula ');
				set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
			
				set @formulastring="(a*b/100)/(1+c/100+d/100+e/100)";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'discount_percent'},{'lettervar':'c','column':'tax1'},{'lettervar':'d','column':'tax2'},{'lettervar':'e','column':'tax3'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="a/(1+b/100+c/100+d/100)";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'tax1'},{'lettervar':'c','column':'tax2'},{'lettervar':'d','column':'tax3'}]}";
				end if;
				 set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@listamountfieldid,@parentid,"',@formulacolumn,'",'); 
			 set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@listamountfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
			 set @sql=concat(@sql,' and not exists(select 1 from ld_producttoolfield_formula ');
				set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
	 end if;
	
   set @taxtotalfieldid=0;
	  set @relatesql=concat('select if(count(producttoolfieldid)>0 ,producttoolfieldid,0)  into @taxtotalfieldid from ld_producttoolfield where tabid=',ttabid,' and columnname="tax_total" and tablename like "%detail"');
    PREPARE stalter FROM @relatesql;
    EXECUTE stalter;
	  deallocate  prepare  stalter;
	if @taxtotalfieldid>0 then 
				set @formulastring="(a*(1-b/100))*(c/100+d/100+e/100)";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'discount_percent'},{'lettervar':'c','column':'tax1'},{'lettervar':'d','column':'tax2'},{'lettervar':'e','column':'tax3'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="a*(b/100+c/100+d/100)";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'tax1'},{'lettervar':'c','column':'tax2'},{'lettervar':'d','column':'tax3'}]}";
				end if;

				set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@taxtotalfieldid,@parentid,"',@formulacolumn,'",'); 
			 set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
			 set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@taxtotalfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
				set @sql=concat(@sql,' and  exists(select 1 from ld_producttoolfield_formula ');
				set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');

			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
				
				set @formulastring="(a*b/100)(c/100+d/100+e/100)";
				set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'discount_percent'},{'lettervar':'c','column':'tax1'},{'lettervar':'d','column':'tax2'},{'lettervar':'e','column':'tax3'}]}";

				if @discount_percent_presence='no' THEN	
					set @formulastring="a*(b/100+c/100+d/100)";
					set @formulacolumn="{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'tax1'},{'lettervar':'c','column':'tax2'},{'lettervar':'d','column':'tax3'}]}";
				end if;
				set @sql=concat(' insert into ld_reverseformula(reversetable,relateid,parentid,columnstring,formulastring,reversetabid)');
				set @sql=concat(@sql,' select "ld_producttoolfield",@taxtotalfieldid,@parentid,"',@formulacolumn,'",'); 
				set @sql=concat(@sql,'"',@formulastring,'",',ttabid ,' from dual ');
				set @sql=concat(@sql," where not exists(select 1 from ld_reverseformula  where reversetable='ld_producttoolfield' and relateid=@taxtotalfieldid and parentid=@parentid and reversetabid=",ttabid,')' );
				set @sql=concat(@sql,' and  not exists(select 1 from ld_producttoolfield_formula ');
				set @sql=concat(@sql,' where producttoolfieldid=@parentid and formulastring like "%1-%") ');
			 PREPARE stalter from @sql;
			 execute stalter;
			 DEALLOCATE PREPARE stalter;
	end if;
end ||
delimiter;

drop PROCEDURE if exists taxamountreverseallproducttool;
delimiter ||
create PROCEDURE taxamountreverseallproducttool()
BEGIN
	
	declare done  int  default 0;
 declare ttabid  int ;
	declare cur2 CURSOR FOR SELECT tabid    FROM  ld_producttoolfield  where columnname='tax_amount' group by tabid ;
	declare continue handler  for not   found  SET done =1;
select deploy_value into @deploy_value from ld_systems_deploy where deploy_type=140;
	OPEN cur2;
	Fetch cur2 into ttabid;

 	loop1: while  done<>1 DO
		
			call reverseproducttooldiscount(ttabid);
		  call reverseproducttoolprice(ttabid);
		  Fetch cur2 into ttabid;
	end while loop1;
	close cur2;
	 update ld_reverseformula inner join ld_producttoolfield  on ld_producttoolfield.producttoolfieldid=ld_reverseformula.parentid
    set reversefieldtype='listprice'
    where reversetable='ld_producttoolfield' and reversefieldtype is null and ld_producttoolfield.columnname='tax_amount' ;
	
  update ld_reverseformula set activatestatus='no';
  set @sql=concat('update ld_reverseformula set activatestatus="yes" where  reversefieldtype="',@deploy_value,'"');

	PREPARE altersql from @sql;
	execute altersql;
  DEALLOCATE PREPARE altersql;
    
end ||
delimiter;
call taxamountreverseallproducttool();
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Triggercalculation','反算规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Triggercalculation' and labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Triggercalculation','Trigger calculation','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Triggercalculation' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Triggercalculationcontent','输入后反算内容','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Triggercalculationcontent' and labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Triggercalculationcontent','Trigger calculation content','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Triggercalculationcontent' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Calculatedfields','反算字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Calculatedfields' and labeltype='fixedstr' and languagetype='zh');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Calculatedfields','Calculated fields','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Calculatedfields' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_producttoolfield_formula_base set formulastring=replace(formulastring,'a','z');
delimiter;
update ld_producttoolfield_formula_base set formulastring=replace(formulastring,'b','y');
delimiter;
update ld_producttoolfield_formula_base set formulastring=replace(formulastring,'c','x');
delimiter;
update ld_producttoolfield_formula_base set formulastring=replace(formulastring,'d','w');
delimiter;
update ld_producttoolfield_formula_base set formulastring=replace(formulastring,'e','v');
delimiter;

update ld_producttoolfield_formula_base set formulastring=replace(formulastring,'f','u');
delimiter;
update ld_producttoolfield_formula_base set columnstring=replace(columnstring,"'lettervar':'a'","'lettervar':'z'");
delimiter;
update ld_producttoolfield_formula_base set columnstring=replace(columnstring,"'lettervar':'b'","'lettervar':'y'");
delimiter;
update ld_producttoolfield_formula_base set columnstring=replace(columnstring,"'lettervar':'c'","'lettervar':'x'");
delimiter;
update ld_producttoolfield_formula_base set columnstring=replace(columnstring,"'lettervar':'d'","'lettervar':'w'");
delimiter;
update ld_producttoolfield_formula_base set columnstring=replace(columnstring,"'lettervar':'e'","'lettervar':'v'");
delimiter;
update ld_producttoolfield_formula_base set columnstring=replace(columnstring,"'lettervar':'f'","'lettervar':'u'");
delimiter;

drop PROCEDURE if exists deletebasecolumnformula;
delimiter ||
create PROCEDURE deletebasecolumnformula()
begin 

		select deploy_value into @basecomputecolumn from ld_systems_deploy where deploy_type=124;
		set @base_list_amount_str=concat('base_list_amount_',@basecomputecolumn);

		set @base_tax_amount_str=concat('base_tax_amount_',@basecomputecolumn);

	  set @sql=concat(' select formulastring into @base_list_amount_formula from ld_producttoolfield_formula_base where base_column="',@base_list_amount_str,'"');
	  PREPARE altersql from  @sql;
		EXECUTE altersql;
		DEALLOCATE PREPARE altersql;
		
		 set @sql=concat(' select columnstring into @base_list_amount_column from ld_producttoolfield_formula_base where base_column="',@base_list_amount_str,'"');
	 PREPARE altersql from  @sql;
		EXECUTE altersql;
		DEALLOCATE PREPARE altersql;

		set @sql=concat(' select formulastring into @base_tax_amount_formula from ld_producttoolfield_formula_base where base_column="',@base_tax_amount_str,'"');
	 PREPARE altersql from  @sql;
		EXECUTE altersql;
		DEALLOCATE PREPARE altersql;
		
		set @sql=concat(' select columnstring into @base_tax_amount_column from ld_producttoolfield_formula_base where base_column="',@base_tax_amount_str,'"');
	  PREPARE altersql from  @sql;
		EXECUTE altersql;
		DEALLOCATE PREPARE altersql;
		
		update ld_producttoolfield_formula set columnstring=replace(columnstring,'base_list_amount',@base_list_amount_column)
			where columnstring like '%base_list_amount%';
		update ld_producttoolfield_formula set formulastring=replace(formulastring,'base_list_amount',@base_list_amount_formula) 
		where formulastring like '%base_list_amount%';

		update ld_producttoolfield_formula set columnstring=replace(columnstring,'base_tax_amount',@base_tax_amount_column)
			where columnstring like '%base_tax_amount%';
		update ld_producttoolfield_formula set formulastring=replace(formulastring,'base_tax_amount',@base_tax_amount_formula) 
		where formulastring like '%base_tax_amount%';

end ||
delimiter;

call deletebasecolumnformula();
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SettingFormula','Set formula','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='SettingFormula' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SettingFormula','设置公式','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='SettingFormula' and labeltype='fixedstr' and languagetype='zh');
delimiter;

update ld_systems_deploy set presence =1 where deploy_type=140;
delimiter;

update ld_systems_deploy set presence =1 where deploy_type=124;
delimiter;

update ld_desk set fieldlabel='单据分录中的所有数字类型的字段可参与运算' where labelbol='ALLTHENUMBERORDATEOFFIELDTYPESCANCALCULATE' and languagetype='zh' and labeltype='fixedstr';
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select ld_tranlabel.languagetype,trantable,2,tmp_potentialproducttoolfield.producttoolfieldid as relateid,ld_tranlabel.fieldlabel from ld_producttoolfield
INNER JOIN ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
INNER JOIN (select producttoolfieldid,columnname from ld_producttoolfield where tabid=2)
							as tmp_potentialproducttoolfield
on tmp_potentialproducttoolfield.columnname=ld_producttoolfield.columnname
 where ld_producttoolfield.tabid=22 and ld_tranlabel.trantable='ld_producttoolfield' 
and (ld_producttoolfield.tablename='ld_products' or ld_producttoolfield.tablename='ld_productcf')
and  not exists(select 1 from ld_tranlabel INNER JOIN ld_producttoolfield
		on ld_tranlabel.Relateid=ld_producttoolfield.producttoolfieldid
		where ld_tranlabel.trantable='ld_producttoolfield' and ld_tranlabel.tabid=2
		and ((ld_producttoolfield.tablename='ld_products' or ld_producttoolfield.tablename='ld_productcf')) );
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select ld_tranlabel.languagetype,trantable,2,tmp_potentialproducttoolfield.producttoolfieldid as relateid,ld_tranlabel.fieldlabel from ld_producttoolfield
INNER JOIN ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
INNER JOIN (select producttoolfieldid,columnname from ld_producttoolfield where tabid=2)
							as tmp_potentialproducttoolfield
on tmp_potentialproducttoolfield.columnname=ld_producttoolfield.columnname
 where ld_producttoolfield.tabid=22 and ld_tranlabel.trantable='ld_producttoolfield' 
and (ld_producttoolfield.tablename='ld_salesorder' and (ld_producttoolfield.columnname='total' or ld_producttoolfield.columnname='subtotal'))
and  not exists(select ld_tranlabel.* from ld_tranlabel INNER JOIN ld_producttoolfield
		on ld_tranlabel.Relateid=ld_producttoolfield.producttoolfieldid
		where ld_tranlabel.trantable='ld_producttoolfield' and ld_tranlabel.tabid=2
		and ld_producttoolfield.tablename='ld_potential' and (ld_producttoolfield.columnname='total' or ld_producttoolfield.columnname='subtotal')  );
delimiter;
-- 2019-09-24


DROP PROCEDURE IF EXISTS `ldcrm_add_selectbill_bymodule`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_selectbill_bymodule`(
	tmp_curmodule VARCHAR(100),
	tmp_selmodule VARCHAR(100)
)
BEGIN
	
	SET @cur_tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_curmodule LIMIT 1);
	SET @sel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_selmodule LIMIT 1);
	SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_option_module WHERE tabid=@cur_tabid),1);
	SET @table_sequence=(SELECT tabsequence FROM ld_tab WHERE `name`=tmp_curmodule LIMIT 1);

	IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_option_module' AND COLUMN_NAME='maxrowsshow') THEN
		SET @insert_sql=CONCAT("INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence,datarang,maxrowsshow) 
		SELECT ",@cur_tabid,",",@sel_tabid,",",0,",",0,",",0,",",@maxseq+1,",",@table_sequence,",'all',5  
		FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=",@cur_tabid," AND option_tabid=",@sel_tabid,")");
	ELSE
		SET @insert_sql=CONCAT("INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence) 
		SELECT ",@cur_tabid,",",@sel_tabid,",",0,",",0,",",0,",",@maxseq+1,",",@table_sequence," 
		FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=",@cur_tabid," AND option_tabid=",@sel_tabid,")");
	END IF;

		PREPARE mystmt FROM @insert_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;

end ||
delimiter;

CALL ldcrm_add_selectbill_bymodule('Expense','PurchaseOrder');
delimiter;


SET @max_relationid=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @tabid=21;
SET @related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense');
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence)
SELECT @max_relationid+1,@tabid,@related_tabid,'get_expense',100,'Expense',0,'add',1,10,'datacategory_sql','expensedetail.entitytypeid',0,9 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid);

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;
-- 2019-09-26

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnableRegExp','Enable validation','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='EnableRegExp' and labeltype='fixedstr' );
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnableRegExp','启用正则验证','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='EnableRegExp' and labeltype='fixedstr' );
delimiter;

UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
UPDATE ld_customview_seq SET id = (SELECT MAX(cvid) FROM ld_customview);
UPDATE ld_links_seq SET id=(SELECT MAX(linkid) FROM ld_links);
UPDATE ld_picklist_dependency_seq SET id=(SELECT MAX(id) FROM ld_picklist_dependency);
UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
UPDATE ld_approve_seq SET id=(SELECT MAX(id) FROM ld_approve);
UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);
UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) FROM ld_autotask);
UPDATE ld_currency_info_seq SET id=(SELECT MAX(id) FROM ld_currency_info);
UPDATE ld_users_seq SET id=(SELECT MAX(id) FROM ld_users);
UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
UPDATE ld_customreport_info_seq SET id=(SELECT MAX(report_id) FROM ld_customreport_info);
UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);
delimiter;

UPDATE ld_version SET old_version='V7.9.0',current_version='V7.9.0',remark='V7.9.0-20190927',wx_version='V7.9.0';
delimiter;