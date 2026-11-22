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

DROP EVENT IF EXISTS `update_contact_nolinkdays`;
delimiter ||
CREATE EVENT `update_contact_nolinkdays` ON SCHEDULE EVERY 1 DAY STARTS '2020-08-14 00:30:00' ON COMPLETION NOT PRESERVE ENABLE DO 
UPDATE ld_contactdetails SET nolinkdays=DATEDIFF(CURDATE(),IFNULL(lastcontactdate,DATE_FORMAT(createdtime,'%Y-%m-%d')));
|| 
delimiter;

SET @labelbol = 'MYAPPROVALCENTER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批中心','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Approve','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @tabid = (SELECT tabid FROM ld_tab where `name` = 'Accounts');
SET @related_tabid = (SELECT tabid FROM ld_tab where `name` = 'ServiceReturn');
UPDATE ld_relatedlists SET actions = 'add' where related_tabid = @related_tabid and tabid = @tabid;
delimiter;

set @tabid = (select tabid from ld_tab where `name`='CashBill');
update ld_tabdetailfield set relatedmodulefield='yes'  where tabid = @tabid and sourcemodule not in ('OutboundOrder','Invoice','PaymentPlan','SalesOrder','ServiceContracts')  and relatedmodulefield = 'no' 
and columnname in (select columnname from (select columnname from ld_tabdetailfield where tabid = @tabid and sourcemodule='OutboundOrder' and relatedmodulefield='yes') as a );
update ld_producttoolfield set relatedmodulefield='yes'  where tabid = @tabid and relatedmodulefield != 'yes' and sourcemodule not in ('OutboundOrder','Invoice','PaymentPlan','SalesOrder','ServiceContracts') 
and columnname in (select columnname from (select columnname from ld_producttoolfield where tabid = @tabid and sourcemodule='OutboundOrder' and relatedmodulefield='yes')as a);
delimiter;

set @tabid = (select tabid from ld_tab where `name`='SendCashBill');
update ld_tabdetailfield set relatedmodulefield='yes'  where tabid = @tabid and sourcemodule not in ('PurchaseInvoice','PurchaseOrder','SendPayment','Stock')  and relatedmodulefield = 'no' 
and columnname in (select columnname from (select columnname from ld_tabdetailfield where tabid = @tabid and sourcemodule='OutboundOrder' and relatedmodulefield='yes') as a );
update ld_producttoolfield set relatedmodulefield='yes'  where tabid = @tabid and relatedmodulefield != 'yes' and sourcemodule not in ('PurchaseInvoice','PurchaseOrder','SendPayment','Stock') 
and columnname in (select columnname from (select columnname from ld_producttoolfield where tabid = @tabid and sourcemodule='OutboundOrder' and relatedmodulefield='yes')as a);
delimiter;

update ld_homestuffdetail set pageurl='index.php?pageto_module=Singin&pageto_action=index' where stuffid=35 and stufflabel='NewSignCount';
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewSignCount' limit 1 ;
update ld_homestuffdetailcondition set `columns`='ld_singin:createdtime:createdtime:Singin_签到时间:DT' where homestuffdetailid=@homestuffdetailid;
delimiter;


update ld_field set bigtype='users' where columnname = 'smownerid' and ifnull(bigtype,'') = '';
update ld_field set masseditable=0 where REPLACE(`tablename`,'ld_customform','')+0>100 and REPLACE(`tablename`,'ld_customform','')+0<=200 AND columnname = 'smownerid' and ifnull(masseditable,1) = 1;
delimiter;


DROP FUNCTION IF EXISTS `func_insting_isnumeral`;
delimiter ||
CREATE FUNCTION `func_insting_isnumeral`(in_string TEXT) RETURNS VARCHAR(10) CHARSET utf8
BEGIN  

	DECLARE is_numeral VARCHAR(10) DEFAULT 'no';

	IF TRIM(IFNULL(in_string,''))='' THEN
		SET is_numeral='yes';
	ELSE
		-- 空格也不允许
		SET in_string=REPLACE(in_string,' ','@');

		SET in_string=REPLACE(in_string,0,'');
		SET in_string=REPLACE(in_string,1,'');
		SET in_string=REPLACE(in_string,2,'');
		SET in_string=REPLACE(in_string,3,'');
		SET in_string=REPLACE(in_string,4,'');
		SET in_string=REPLACE(in_string,5,'');
		SET in_string=REPLACE(in_string,6,'');
		SET in_string=REPLACE(in_string,7,'');
		SET in_string=REPLACE(in_string,8,'');
		SET in_string=REPLACE(in_string,9,'');

		IF TRIM(in_string)='' THEN
			SET is_numeral='yes';
		ELSE
			SET is_numeral='no';
		END IF;
	END IF;

	RETURN(is_numeral);

END ||
delimiter;

update ld_field set uitype = 5,bigtype='date',typeofdata='D~O' where bigtype='datetime' and columnname='lastcontactdate';
alter table ld_account modify lastcontactdate date;
alter table ld_contactdetails modify lastcontactdate date;
delimiter;

update ld_field set quickcreate=0 where quickcreate=1 and typeofdata like "%m%";
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOMATICCHECKIN','自动签到','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AUTOMATICCHECKIN' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOMATICCHECKIN','Automatic check-in','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AUTOMATICCHECKIN' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0517`;
delimiter ||
CREATE PROCEDURE `ldcrm_complete_customform0517`(
)
BEGIN
DECLARE i int DEFAULT 161;
WHILE i<=200 DO

SET @tmpcount=(SELECT 1 from ld_cvcolumnlist_wx where modulename=CONCAT('CustomForm',i) limit 1);
UPDATE ld_tab SET mobilepresence='weixin' WHERE NAME=CONCAT('CustomForm',i);

IF @tmpcount<=0 THEN

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,presence,systemdefault,showtag)
value(CONCAT('CustomForm',i),1,1,CONCAT('ld_customform',i,':customform',i,'_no:customform',i,'_no:CustomForm',i,'_单据编号:V'),0,0,'yes','yes');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,presence,systemdefault,showtag)
value(CONCAT('CustomForm',i),2,1,CONCAT('ld_customform',i,':createdtime:createdtime:CustomForm',i,'_创建时间:D'),0,0,'yes','yes');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,presence,systemdefault,showtag)
value(CONCAT('CustomForm',i),3,1,CONCAT('ld_customform',i,':smownerid:assigned_user_id:CustomForm',i,'_负责人:V'),0,0,'yes','yes');

END IF;

SET i=i+1;
END WHILE;

end ||
delimiter;
CALL ldcrm_complete_customform0517();
DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0517`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0517_2`;
delimiter ||
CREATE PROCEDURE `ldcrm_complete_customform0517_2`(
)
BEGIN
DECLARE i int DEFAULT 161;
WHILE 161<=i AND i<=200 DO

SET @tmptabid=(SELECT tabid FROM ld_tab WHERE name=CONCAT('CustomForm',i) LIMIT 1);
SET @count=(SELECT count(*) from ld_fieldwxmaininfo WHERE tabid=@tmptabid);
IF @count<=0  THEN

insert into ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
value(@tmptabid,CONCAT('customform',i,'_no'),1,'title',0,'yes');
insert into ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
value(@tmptabid,'total',2,'normal',0,'yes');
insert into ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
value(@tmptabid,'smownerid',3,'normal',0,'yes');

END IF;

SET i=i+1;
END WHILE;

end ||
delimiter;
CALL ldcrm_complete_customform0517_2();
DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0517_2`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0517_3`;
delimiter ||
CREATE PROCEDURE `ldcrm_complete_customform0517_3`(
)
BEGIN
DECLARE i int DEFAULT 181;
WHILE 181<=i AND i<=200 DO

SET @tmptabid=(SELECT tabid FROM ld_tab WHERE name=CONCAT('CustomForm',i) LIMIT 1);

update ld_option_module set maxrowsshow=5 where tabid=@tmptabid and maxrowsshow=0;

SET i=i+1;
END WHILE;

end ||
delimiter;
CALL ldcrm_complete_customform0517_3();
DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0517_3`;
delimiter;

SET @labelbol = 'CURROPERATOR';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前操作员','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Operator','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ApprovalStatusComponent';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批状态组件','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Approval Status Component','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0519`;
delimiter ||
CREATE PROCEDURE `ldcrm_complete_customform0519`(
)
BEGIN
DECLARE i int DEFAULT 101;
WHILE 101<=i AND i<=200 DO

SET @tabid=(SELECT tabid FROM ld_tab WHERE name=CONCAT('CustomForm',i) LIMIT 1);
SET @pretabid = (SELECT tabid from ld_tab where `name` = 'CustomForm01');
SET @count=(select count(*) from ld_profileallpermission where tabid=@tabid);

IF @count<=12  THEN
delete from ld_profileallpermission where tabid=@tabid;
insert into ld_profileallpermission (tabid,operation,sequence) select @tabid,operation,sequence from ld_profileallpermission where tabid=@pretabid;
END IF;

SET i=i+1;
END WHILE;

end ||
delimiter;
CALL ldcrm_complete_customform0519();
DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0519`;
delimiter;

CALl AddColumn('ld_salesback','triggercount','INT','11',0);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_leads_fileld`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_leads_fileld`()
BEGIN

	IF EXISTS (SELECT 1 FROM ld_tab WHERE name='Leads') THEN
		SET @modulename='Leads';
		SET @tabid=(SELECT tabid FROM ld_tab WHERE name=@modulename);
		SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='upgradeaccountid';
		SET @fieldname='upgradeaccountid';
		SET @zh='升级后客户';
		SET @en='Accounts after upgrade';
		SET @uitype=73;
		SET @typeofdata='V~O';
		SET @quickcreate=0;
		SET @displaytype=2;
		SET @bigtype='reference';
		SET @datarang=NULL;
		SET @maxrowsshow=0;
		SET @savedatabase = 'yes';
		SET @allowedit = 'no';
		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALL AddColumn(@tablename,@columnname,'int','19','');

	END IF;
end ||
delimiter;

CALL ldcrm_add_leads_fileld();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_leads_cvcolumnview_upgradeaccount_20230518`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_leads_cvcolumnview_upgradeaccount_20230518`()
BEGIN
	SELECT 'Leads' into @tmp_module;
	IF EXISTS (SELECT 1 FROM ld_tab WHERE name='Leads') THEN
		select tabid into @tabid from ld_tab where `name`=@tmp_module;
		if NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=@tmp_module and viewname='已升级' and customcategory='ALLACCOUNT') THEN
			SELECT max(sequence) into @maxsequence FROM ld_customview WHERE entitytype=@tmp_module;
			SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
			INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
			SELECT @maxcvid+1,'已升级',0,0,@tmp_module,3,1,@maxsequence+1,'ALLACCOUNT' FROM dual
			WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=@tmp_module and viewname='已升级' and customcategory='ALLACCOUNT');
			UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
		END IF;
	END IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_leads_cvcolumnlist_upgradeaccount_20230518`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_leads_cvcolumnlist_upgradeaccount_20230518`(
	tmp_allcvid int(11),
	tmp_cvid int(11)
)
BEGIN
		
	declare tcolumnindex int (11);
	declare tcolumnname varchar (250);
	declare done  int  default 0;
	declare cur2 CURSOR FOR 
		select  
			columnindex,
			columnname  
		from ld_cvcolumnlist 
		where  cvid=tmp_allcvid
		union 
		select 
			max(columnindex)+1 as columnindex,
			CONCAT('ld_leads',':','upgradeaccountid',':','upgradeaccountid',':','Leads','_fieldlabel:V') as columnname 
		from ld_cvcolumnlist where  cvid=tmp_allcvid;

	declare continue handler  for not   found  SET done =1;

	IF tmp_allcvid>0 AND tmp_cvid>0 THEN
		open cur2;
		fetch cur2 into tcolumnindex,tcolumnname;
		loop2: while  done<>1 DO
			IF NOT EXISTS (SELECT 1 from ld_cvcolumnlist where cvid = tmp_cvid and columnindex=tcolumnindex) THEN
				INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
				SELECT tmp_cvid,tcolumnindex,tcolumnname;
			END IF;
		fetch cur2 into tcolumnindex,tcolumnname;
		end while loop2;
		close cur2;
		
		IF NOT EXISTS (SELECT 1 from ld_cvadvfilter where cvid = tmp_cvid) THEN
			INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
			SELECT tmp_cvid,0,CONCAT('ld_leads',':','upgradeaccountid',':','upgradeaccountid',':','Leads','_fieldlabel:V'),'c','升级到',1,'';
			
			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
			SELECT 1,tmp_cvid,0;
		END IF;
	END IF;
end ||
delimiter;

CALL ldcrm_add_leads_cvcolumnview_upgradeaccount_20230518();
SELECT cvid into @allcvid FROM ld_customview WHERE entitytype='Leads' AND viewname='All' and customcategory='ALLACCOUNT';	
SELECT cvid into @cvid FROM ld_customview WHERE entitytype='Leads' and viewname='已升级' and customcategory='ALLACCOUNT';
CALL ldcrm_add_leads_cvcolumnlist_upgradeaccount_20230518(@allcvid,@cvid);
DROP PROCEDURE IF EXISTS ldcrm_add_leads_cvcolumnview_upgradeaccount_20230518;
DROP PROCEDURE IF EXISTS ldcrm_add_leads_cvcolumnlist_upgradeaccount_20230518;
delimiter;
-- 2023-05-22


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

UPDATE ld_version SET old_version='V8.5.0.2',current_version='V8.5.0.2',remark='V8.5.0.2-20230522',wx_version='V8.5.0.2';
delimiter;