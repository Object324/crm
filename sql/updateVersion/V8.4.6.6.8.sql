DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
	END IF;

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


CALl AddColumn('ld_attachmentstype','module_name','varchar','255','');
delimiter;

UPDATE ld_tranlabel SET fieldlabel='意向产品' WHERE tabid=2 AND Relateid=(SELECT fieldid FROM ld_field WHERE tabid=2 AND columnname='product_id' AND presence=1) AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel='Intended Products' WHERE tabid=2 AND Relateid=(SELECT fieldid FROM ld_field WHERE tabid=2 AND columnname='product_id' AND presence=1) AND languagetype='en';
delimiter;
-- 2022-07-14

SET @modulename='Potentials';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='quote_id' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='adjustment'; 
SET @fieldname='txtAdjustment'; 
SET @zh='调整'; 
SET @en='Adjustment'; 
SET @uitype=72; 
SET @typeofdata='NN~O';
SET @quickcreate=1;
SET @displaytype=3;
SET @bigtype='currency';
SET @datarang=NULL;
SET @maxrowsshow=0;

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

CALl AddColumn(@tablename,@columnname,'VARCHAR','200',NULL);
ALTER TABLE ld_potential MODIFY COLUMN adjustment DECIMAL(25,2);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);


SET @modulename='Potentials';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='quote_id' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='discount_amount'; 
SET @fieldname='hdnDiscountAmount'; 
SET @zh='折扣直接降价'; 
SET @en='Discount Amount'; 
SET @uitype=72; 
SET @typeofdata='NN~O';
SET @quickcreate=1;
SET @displaytype=3;
SET @bigtype='currency';
SET @datarang=NULL;
SET @maxrowsshow=0;

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

CALl AddColumn(@tablename,@columnname,'VARCHAR','200',NULL);
ALTER TABLE ld_potential MODIFY COLUMN discount_amount DECIMAL(25,2);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);


SET @modulename='Potentials';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='quote_id' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='discount_percent'; 
SET @fieldname='hdnDiscountPercent'; 
SET @zh='折扣百分比'; 
SET @en='Discount Percent'; 
SET @uitype=9; 
SET @typeofdata='N~O';
SET @quickcreate=1;
SET @displaytype=3;
SET @bigtype='currency';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','200',NULL);
ALTER TABLE ld_potential MODIFY COLUMN discount_percent DECIMAL(25,2);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

UPDATE ld_blocks SET display_status=2 WHERE blocklabel='LBL_LABEL' AND (DATABASE() LIKE 'yanshi_%' OR DATABASE() LIKE 'demo_%');

CALl AddColumn('ld_customform20','triggercount','INT','19',0);
ALTER TABLE ld_customform20 MODIFY COLUMN triggercount INT(19) DEFAULT 0 AFTER customform20id;
UPDATE ld_customform20 SET triggercount=0 WHERE triggercount IS NULL;


ALTER TABLE ld_worksheet modify column description Text;
delimiter;
set @reportid = (SELECT Usereportid FROM ld_usereport where name ='SalesOrderTrack');
select sequence into @sequence from ld_usereportcolumns where `columns`='ld_salesorder:total:hdnGrandTotal:SalesOrder_Total:N'  and Usereportid=@reportid;
UPDATE ld_usereportcolumns set sequence =sequence+1 where sequence>=@sequence and Usereportid=@reportid;
INSERT INTO  ld_usereportcolumns ( `Usereportid`, `columns`, `Sequence`, `columnshow`, `realcolumns`, `realencolumns`, `tabname`, `is_advanced`)
SELECT  @reportid,
        'ld_salesorder:totalquantity:totalquantity:SalesOrder_quantity:N',@sequence , 1,
        'ld_salesorder:totalquantity:totalquantity:SalesOrder_合同订单数量合计:N', 'ld_salesorder:totalquantity:totalquantity:SalesOrder_quantity:N', NULL, 0
FROM DUAL
WHERE not  EXISTS
    (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid=@reportid and columns ='ld_salesorder:totalquantity:totalquantity:SalesOrder_quantity:N');
delimiter;

set @reportid = (SELECT Usereportid FROM ld_usereport where name ='SalesOrderTrack');
select sequence into @sequence from ld_usereportcolumns where `columns`='ld_salesorder:TotalCost:成本合计:OftenUseReport_TotalCost:N'  and Usereportid=@reportid;
UPDATE ld_usereportcolumns set sequence =sequence+1 where sequence>=@sequence and Usereportid=@reportid;
INSERT INTO  ld_usereportcolumns ( `Usereportid`, `columns`, `Sequence`, `columnshow`, `realcolumns`, `realencolumns`, `tabname`, `is_advanced`)
SELECT  @reportid,
        'ld_salesorder:approvestatus:approvestatus:SalesOrder_approvestatus:V',@sequence , 1,
        'ld_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_approvestatus:V', NULL, 0
FROM DUAL
WHERE not  EXISTS
    (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid=@reportid and columns ='ld_salesorder:approvestatus:approvestatus:SalesOrder_approvestatus:V');
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
delimiter ||
CREATE  PROCEDURE `ldcrm_approvereminds_remindtitle_add`(
)
BEGIN
	declare var_id int(100);
	DECLARE var_type varchar(100);
	DECLARE var_reminduser varchar(100);
	DECLARE var_remindmethod varchar(100);
	DECLARE var_title varchar(100);
	DECLARE var_tabid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select ld_approvereminds.id as tmp_id,ld_approvereminds.type,ld_approvereminds.reminduser,ld_approvereminds.remindmethod,ld_approvereminds.remindtitle as tmp_title,tmp_table.tabid as tmp_tabid from ld_approvereminds LEFT JOIN (SELECT ld_approvestep.id AS stepid,ld_approve.tabid AS tabid from ld_approvestep LEFT JOIN ld_approve ON ld_approve.id=ld_approvestep.approveid ) AS tmp_table ON tmp_table.stepid = ld_approvereminds.stepid;
		declare continue handler  for not   found  SET done =1;
	OPEN cur1;

	 Fetch cur1 into var_id,var_type,var_reminduser,var_remindmethod, var_title,var_tabid;
	 loop1: while  done<>1 DO
		if  var_remindmethod in ('dialog','weiin') then
			set @modulename = (select fieldlabel from ld_tranlabel where tabid = var_tabid and languagetype = 'zh' and trantable = 'ld_tab');
			set @remindtitle='';
			if var_type=0 and var_reminduser='approver' THEN
				select  concat('【',@modulename,'】审批提醒') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
			 update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批提醒') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			elseif var_type=0 and var_reminduser='selectuser'  THEN
				select  remindtitle = concat('【',@modulename,'】审批抄送提醒') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
				update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批抄送提醒') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			elseif var_type=1 and var_reminduser='smowner'  THEN
				select  remindtitle = concat('【',@modulename,'】审批结果通知') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
				update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批结果通知') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			elseif var_type=1 and var_reminduser in ('smcreator','selectuser')  THEN
				select  remindtitle = concat('【',@modulename,'】审批结果提醒') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
				update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批结果提醒') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			elseif var_type=2 THEN
				select  remindtitle = concat('【',@modulename,'】审批结果提醒') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
				update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批结果提醒') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			end if;
	end if;
   Fetch cur1 into var_id,var_type,var_reminduser,var_remindmethod, var_title,var_tabid;
	end while loop1;
	close cur1;
end ||
delimiter;

CALL ldcrm_approvereminds_remindtitle_add();
DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
delimiter;

delete from ld_field where tabid=23 and tablename='ld_invoicebillads';
delimiter;

drop PROCEDURE if EXISTS ldcrm_addfield_advancetime;
delimiter ||
create PROCEDURE ldcrm_addfield_advancetime
(
)
BEGIN
		DECLARE tmp_module VARCHAR(100) DEFAULT NULL;
		DECLARE tmp_tabid INT(19) DEFAULT 0;
		DECLARE tmp_block INT(19) DEFAULT 0;
		DECLARE tmp_table VARCHAR(100) DEFAULT NULL;
		DECLARE tmp_primary_key VARCHAR(100) DEFAULT NULL;
		DECLARE MYCUSOR CURSOR FOR 
			SELECT 
				b.`name` AS module,
				a.tabid,
				a.block,
				a.tablename,
				b.primary_key
			FROM ld_field a
			LEFT JOIN ld_tab b ON b.tabid=a.tabid
			WHERE a.columnname='smownerid'
				AND a.tablename NOT IN ('ld_reminds','ld_activity','ld_notes')
			GROUP BY a.tabid
			ORDER BY a.tabid;
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

		OPEN MYCUSOR; 
		FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_block,tmp_table,tmp_primary_key;
		WHILE(tmp_tabid IS NOT NULL) DO
			SET @tabid=tmp_tabid;
			SET @relateid=tmp_block;
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
			SET @trantable='ld_field';
			SET @tablename=tmp_table;
			SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
			
			SET @presence = '1';
			set @sql="SELECT CASE WHEN `enable` = 'yes' or showadvancemobile = 'yes' THEN 2 ELSE 1 END as tmp into @presence from ld_settings_advance where tabid =";
			set @sql=CONCAT(@sql,@tabid);
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;

			SET @trantable='ld_field';
			SET @columnname='latestpushtime'; 
			SET @fieldname='latestpushtime'; 
			SET @zh='最新推进时间'; 
			SET @en='Latest push time'; 
			SET @uitype=86;
			SET @typeofdata='DT~O';
			SET @quickcreate=1;
			SET @displaytype=2;
			SET @bigtype='datetime';
			SET @datarang='NULL';
			SET @maxrowsshow=0;
			SET @savedatabase = 'yes';
			SET @allowedit = 'no';

			INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
			SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,IFNULL(@presence,1),NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
			UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
			
			SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
			
			CALL AddColumn(@tablename,@columnname,'datetime','','');
			
			IF @presence = 2 THEN
					SET @sql1 = " INNER JOIN 
											(SELECT MAX(ld_modtracker_basic.changedon) as tmp_changedon,ld_modtracker_basic.crmid from ld_modtracker_basic 
												INNER JOIN ld_modtracker_detail on ld_modtracker_basic.id = ld_modtracker_detail.id 
												INNER JOIN ld_settings_advance on ld_settings_advance.module_field = ld_modtracker_detail.fieldname 
													AND ld_settings_advance.module = ld_settings_advance.module where ld_settings_advance.tabid =";
					SET @sql2 = " GROUP BY ld_modtracker_basic.crmid) as tmp
											on ";
					SET @sql3 = " = tmp.crmid SET latestpushtime = tmp.tmp_changedon";
					SET @sql4 = CONCAT('UPDATE ',@tablename,@sql1,@tabid,@sql2,tmp_primary_key,@sql3);
					prepare stmt from @sql4;
					execute stmt;
					deallocate prepare stmt;
			END IF;


			FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_block,tmp_table,tmp_primary_key;
		END WHILE;
		CLOSE MYCUSOR;
		
end ||
delimiter;

SET @disable_triggers = 'aaaa';
call ldcrm_addfield_advancetime();
SET @disable_triggers = NULL;
drop PROCEDURE if EXISTS ldcrm_addfield_advancetime;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Dealerorderdiscountprice','经销商下单折折扣价','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Dealerorderdiscountprice' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Dealerorderdiscountprice','Dealer order discount price','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Dealerorderdiscountprice' and Labeltype='fixedstr' and languagetype='en');
delimiter;

select max(sequence) + 1 into @sequence from ld_systems_deploy where roottype = 8;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,349,'设置移动端订货商城价格显示方式','',@sequence,8,'select',0,'[{"value":"0","text":"product_costprice"},{"value":"1","text":"Dealerorderdiscountprice"},{"sql":""}]' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type = 349);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',349,349,'设置移动端订货商城价格显示方式'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_systems_deploy' and tabid = 349 and relateid=349);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',349,349,'Set the price display method of mobile ordering mall'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_systems_deploy' and tabid = 349 and relateid=349);
delimiter;

select account into @account from ld_version; 
update ld_systems_deploy set deploy_value = 1 where deploy_type = 349 and @account = 'huboshi';
delimiter;
-- 2022-07-17

UPDATE ld_usereportcolumns set realcolumns ='ld_salesorder:totalquantity:totalquantity:SalesOrder_数量合计:N' where realcolumns='ld_salesorder:totalquantity:totalquantity:SalesOrder_合同订单数量合计:N';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','aftertransferringtothehighseas','说明：转公海后，会重算保护结束日期并更新分配日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='aftertransferringtothehighseas' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','aftertransferringtothehighseas','Instructions: after transferring to the high seas, the protection end date will be recalculated and the distribution date will be updated','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='aftertransferringtothehighseas' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2022-07-20

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule_beforeremind`(IN tmp_pool_id INT(11))
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and (ld_field.presence in(0,2) ) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2) 
	where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	
	select userid_after_release into @allotaccount from ld_account_public_pool where id = tmp_pool_id;
	select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			
				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
	
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
	  if var_condition='or'  then
			 
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id =  ',tmp_pool_id);
		  
			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
			
		else
			 
				if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
	
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);

		end if;
  
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
		

    if var_condition='or'  then
			
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
			end if;	
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'   group by ld_account.smownerid    ');
		end if;

     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();
    if @allotaccount>0 then 
				select  tmp.tablename into @grouptablename  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
					on ld_related_field.effect_fieldid=ld_field.fieldid
					where ld_field.uitype=1600  )  as  tmp 
					INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
					where ld_field.tabid=6 and ld_field.columnname='smownerid'
					and presence in(0,2)  GROUP BY ld_field.fieldid limit 1; 

				 select  tmp.columnname into @groupcolumnname  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
					on ld_related_field.effect_fieldid=ld_field.fieldid
					where ld_field.uitype=1600  )  as  tmp 
					INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
					where ld_field.tabid=6 and ld_field.columnname='smownerid'
					and presence in(0,2)  GROUP BY ld_field.fieldid limit 1; 
        end if;
	if var_condition='or'  then
	  
		 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		if @recycleselect<>'' and @recycleselect is not null THEN	
			set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		end if;
		set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		 if @allotaccount>0 THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
			end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;	
	ELSE

	  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
					
						if   ifnull(@groupcolumnname,'')!='' then 
					 
								select GROUP_CONCAT(groupid) into @groupid from  ld_users2group where userid =@allotaccount;
								set @TMPSQL_GroupEditSql=concat( ' update  ',@grouptablename,' inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=',@grouptablename,'.accountid ') ;
								if @grouptablename!='ld_account' then 
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' inner join ld_account on ld_account.accountid=ld_accountscf.accountid ');
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql, ' set ',@groupcolumnname,'="', @groupid,'"');
									
								end if ;
								set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
							prepare stmt1 from @TMPSQL_GroupEditSql;
							execute stmt1;
							deallocate prepare stmt1;
						end if;

end if;
  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
 end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;
end ||
delimiter;
-- 2022-07-22

SET @disable_triggers=NULL;
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

UPDATE ld_version SET old_version='V8.4.6.6.8',current_version='V8.4.6.6.8',remark='V8.4.6.6.8-20220722',wx_version='V8.4.6.6.8';
delimiter;