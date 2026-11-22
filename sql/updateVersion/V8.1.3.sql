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

UPDATE ld_organizationdetails SET logoname='logo_big_white.png' WHERE logoname='logo.png' 
	AND DATABASE() NOT LIKE 'wx1%' AND DATABASE() NOT LIKE 'wx2%' AND DATABASE() NOT LIKE 'wx3%' AND DATABASE() NOT LIKE 'wx4%'
	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
-- 2020-07-14


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SocialPromotionForm','表单映射模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SocialPromotionForm' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SocialPromotionForm','Form mapping module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SocialPromotionForm' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SocialPromotionForm','表单映射模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SocialPromotionForm' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SocialPromotionForm','Form mapping module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SocialPromotionForm' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SocialPromotionForm','表单映射模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SocialPromotionForm' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SocialPromotionForm','Form mapping module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SocialPromotionForm' and labeltype='fixedstr');
delimiter;

set @tabid = (select  tabid from ld_tab where name ='SocialPromotion');
UPDATE ld_tranlabel SET fieldlabel='表单推广' where  tabid=@tabid and fieldlabel = '社交推广';
UPDATE ld_tranlabel SET fieldlabel='Form Promotion' where  tabid=@tabid and fieldlabel = 'Social Promotion';
delimiter;

UPDATE ld_desk set fieldlabel ='{$SocialPromotion.SocialPromotion}使用说明' where labelbol='SOCIALPROMOTIONTIP' and languagetype='zh';
UPDATE ld_desk set fieldlabel ='{$SocialPromotion.SocialPromotion} instructions' where labelbol='SOCIALPROMOTIONTIP' and languagetype='en';
UPDATE ld_desk set fieldlabel ='{$SocialPromotion.SocialPromotion}可自定义活动页面，通过分享到微信、微博、QQ等社交平台，进行营销推广与信息收集。' where labelbol='SOCIALPROMOTIONDESC' and languagetype='zh';
UPDATE ld_desk set fieldlabel ='CRM{$SocialPromotion.SocialPromotion}' where labelbol='CRMSOCIALPROMOTION' and languagetype='zh';
UPDATE ld_desk set fieldlabel ='CRM {$SocialPromotion.SocialPromotion}' where labelbol='CRMSOCIALPROMOTION' and languagetype='en';
delimiter;

SET @disable_triggers=1;
ALTER TABLE `ld_socialpromotionformfixed` MODIFY COLUMN `id` int(19) NOT NULL AUTO_INCREMENT;

SET @disable_triggers=1;
call AddColumn('ld_approvelog','approve_autograph','varchar','50','no');

SET @disable_triggers=1;
call AddColumn('ld_approvelog','approve_autograph_path','text','',null);

SET @disable_triggers=1;
update ld_approvelog set approve_autograph = 'no' where approve_autograph is NULL;
delimiter;

call AddColumn('ld_approvestep','countersigner','varchar',20,'no');
update ld_approvestep set countersigner='no' where countersigner is null or countersigner='';

SET @disable_triggers=1;
call AddColumn('ld_approvelog','countersigner','varchar',20,'no');

SET @disable_triggers=1;
call AddColumn('ld_approvelog','nextstep_countersigner','varchar',20,'no');

SET @disable_triggers=1;
update ld_approvelog set countersigner='no' where countersigner is null or countersigner='';

SET @disable_triggers=1;
update ld_approvelog set nextstep_countersigner='no' where nextstep_countersigner is null or nextstep_countersigner='';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MultipleapproversOne','多人审批（一个审批人通过即可通过审批步骤）','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='MultipleapproversOne' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MultipleapproversOne','Multiple approvers (Any one of the approvers can pass it)','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='MultipleapproversOne' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MultipleCountersignature','会签审批（所有审批人通过才能通过审批步骤）','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='MultipleCountersignature' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MultipleCountersignature','Countersignature (All of the approvers need pass it)','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='MultipleCountersignature' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Agree','通过','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Agree' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Agree','Agress','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Agree' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Countersignature','会签审批','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Countersignature' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Countersignature','Countersignature','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Countersignature' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CountersignatureNextStep','会签审批通过并继续下一步','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='CountersignatureNextStep' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CountersignatureNextStep','Countersignature had been done, go to next step','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='CountersignatureNextStep' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CountersignatureApproveSuccess','会签审批通过，结束流程','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='CountersignatureApproveSuccess' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CountersignatureApproveSuccess','Countersignature had been done, the approval process end','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='CountersignatureApproveSuccess' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Countersigner','会签审批人','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Countersigner' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Countersigner','Countersigner','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Countersigner' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2020-07-15

SET @disable_triggers=1;
CALl AddColumn('ld_leads','approvestatus','VARCHAR',50,NULL);
CALl AddColumn('ld_leads','approvetime','datetime',50,NULL);
CALl AddColumn('ld_leads','approveby','INT',19,0);
CALl AddColumn('ld_leads','currentapprover','text',50,NULL);

ALTER TABLE ld_leads ALTER COLUMN approvestatus SET DEFAULT '未提交';
SET @disable_triggers=NULL;


DROP PROCEDURE IF EXISTS `ldcrm_add_approveinfo_tobill`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_approveinfo_tobill`(
	tmp_columnname VARCHAR(100),
	tmp_columnnametype VARCHAR(100),
	tmp_columnnamelength INT(1)
)
BEGIN

	DECLARE tmp_tablename VARCHAR(100) DEFAULT NULL;

	DECLARE MYCUSOR CURSOR FOR SELECT tablename FROM ld_field WHERE columnname='approvestatus' AND tabid<>29 ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tablename = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tablename;
	WHILE(tmp_tablename IS NOT NULL) DO

		-- 对应单据表增加字段即可，无需写入数据库
		SET @disable_triggers=1;
		CALl AddColumn(tmp_tablename,tmp_columnname,tmp_columnnametype,tmp_columnnamelength,NULL);
		SET @disable_triggers=NULL;

	FETCH MYCUSOR INTO tmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;


CALL ldcrm_add_approveinfo_tobill('approvesubmitter','INT',19);
CALL ldcrm_add_approveinfo_tobill('approvesubmittedtime','datetime',100);
CALL ldcrm_add_approveinfo_tobill('currentapprovestepid','INT',19);

DROP PROCEDURE IF EXISTS `ldcrm_add_approveinfo_tobill`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_billapproveinfo_20200715`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_billapproveinfo_20200715`(
)
BEGIN

	DECLARE tmp_modulename VARCHAR(100) DEFAULT NULL;
	DECLARE tmp_tablename VARCHAR(100) DEFAULT NULL;
	DECLARE tmp_tableindex VARCHAR(100) DEFAULT NULL;

	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				a.setype AS modulename,
				c.tablename,
				e.entityidfield AS tmp_tableindex
			FROM (
				SELECT
					b.setype
				FROM (SELECT crmid FROM ld_approvelog WHERE crmid>0 GROUP BY crmid) a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				GROUP BY b.setype
			) a
			LEFT JOIN ld_tab b ON b.`name`=a.setype
			INNER JOIN (SELECT tabid,tablename FROM ld_field WHERE columnname='approvestatus') c ON c.tabid=b.tabid
			INNER JOIN ld_entityname e ON e.modulename=a.setype
			WHERE IFNULL(a.setype,'')<>'' 
				AND IFNULL(c.tablename,'')<>'' 
				AND IFNULL(e.entityidfield,'')<>'';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_modulename = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_modulename,tmp_tablename,tmp_tableindex;
	WHILE(tmp_modulename IS NOT NULL) DO
		SET @my_execsql_approveinfo=CONCAT("
			UPDATE (
				SELECT
					a.crmid,
					MAX(a.id) AS max_logid
				FROM ld_approvelog a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				WHERE b.setype='",tmp_modulename,"'
				GROUP BY a.crmid
			) a
			LEFT JOIN ld_approvelog b ON b.id=a.max_logid
			LEFT JOIN (
				SELECT
					a.crmid,
					MAX(a.id) AS max_logid
				FROM ld_approvelog a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				WHERE b.setype='",tmp_modulename,"'
					AND a.stepid=-1
				GROUP BY a.crmid
			) c ON a.crmid=c.crmid
			LEFT JOIN ld_approvelog d ON d.id=c.max_logid
			LEFT JOIN ",tmp_tablename," t ON t.",tmp_tableindex,"=d.crmid
			SET t.approvesubmittedtime=d.createdtime,
				t.approvesubmitter=d.approved_by,
				t.currentapprovestepid=b.stepid"
			);
		SET @disable_triggers=1;

		PREPARE my_execsql_stmt FROM @my_execsql_approveinfo;
		EXECUTE my_execsql_stmt;
		DEALLOCATE PREPARE my_execsql_stmt;

	FETCH MYCUSOR INTO tmp_modulename,tmp_tablename,tmp_tableindex;
	END WHILE;
	CLOSE MYCUSOR;

	SET @disable_triggers=NULL;

end ||
delimiter;

CALL ldcrm_reset_billapproveinfo_20200715();
DROP PROCEDURE IF EXISTS `ldcrm_reset_billapproveinfo_20200715`;
-- 2020-07-15

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEXTSTEPNAME','下一审批步骤','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='NEXTSTEPNAME' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEXTSTEPNAME','The next approval step','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='NEXTSTEPNAME' and Labeltype='fixedstr' and languagetype='en');
delimiter;


set @tabid = (SELECT tabid from ld_tab where name ='SocialPromotion');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, -168, 'get_SocialPromotionReport', 2, 'SocialPromotionReport', 0, 'select', 0, 36, NULL, NULL, 0, 0, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=-168);
UPDATE ld_relatedlists_seq set id =(SELECT MAX(relation_id) FROM ld_relatedlists);


select tabid into @tabid from ld_tab where `name` = 'Commission';
select sequence into @sequence from ld_profileallpermission where tabid = @tabid and operation = 6;
update ld_profileallpermission set sequence = sequence + 1000 where tabid = @tabid and sequence >= @sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual 
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 5);
set @i =0 ;
update ld_profileallpermission set sequence=(@i:=@i+1) where tabid=@tabid order by sequence asc;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
select sequence into @sequence from ld_profileallpermission where tabid = @tabid and operation = 6;
update ld_profileallpermission set sequence = sequence + 1000 where tabid = @tabid and sequence >= @sequence;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,5,@sequence from dual 
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 5);
set @i =0 ;
update ld_profileallpermission set sequence=(@i:=@i+1) where tabid=@tabid order by sequence asc;
delimiter;

drop PROCEDURE  if EXISTS crm_addtab_intoprofile;
delimiter ||
create PROCEDURE crm_addtab_intoprofile
(
tabname varchar(100),
operation int(10)
)
BEGIN
		declare var_profileid int(19);
	  declare done  int  default 0;
	 declare cur1 CURSOR FOR SELECT profileid   FROM  ld_profile;
	 declare continue handler  for not   found  SET done =1;
  set @sql='select tabid into @tabid from ld_tab  where ';
	 set @sql=CONCAT(@sql, " name='",tabname,"'");
	prepare stmt from @sql;
	execute stmt;
	deallocate prepare stmt;
  open cur1;
	Fetch cur1 into var_profileid;
	loop1: while  done<>1 DO	
		
			set @sql=" insert into ld_profile2tab(profileid,tabid,permissions) select ";
			set @sql=concat(@sql,var_profileid,",",@tabid,",",0 ," from dual where not exists(select 1 from ld_profile2tab where tabid=",@tabid," and profileid=",var_profileid,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
		  set @sql=" insert into ld_profileallpermission(tabid,operation,sequence) select ";
			set @sql=concat(@sql,@tabid,",",operation ,",",0, " from dual where not exists(select 1 from ld_profileallpermission where tabid=",@tabid ,' and operation=',operation,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
			
			set @sql=" insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select ";
			set @sql=concat(@sql,var_profileid,',',@tabid,",",operation ,",",0,",",0, " from dual where not exists(select 1 from ld_profile2standardpermissions where profileid=" ,var_profileid," and tabid=",@tabid ,' and operation=',operation,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
			Fetch cur1 into var_profileid;
	end while loop1;
	close cur1;
end ||
delimiter;

call crm_addtab_intoprofile('Commission',5);
call crm_addtab_intoprofile('Expense',5);
drop PROCEDURE  if EXISTS crm_addtab_intoprofile;
delimiter;

UPDATE ld_field SET bigtype='picklist' WHERE uitype=15;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select block,sequence into @blockid,@sequence from ld_field where tabid = @tabid and columnname = 'registeredcapital';
update ld_field set sequence = sequence + 100 where tabid = @tabid and block = @blockid and sequence > @sequence;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'registration_time','yes','ld_account',1,5,'registration_time','注册时间',1,0,NULL,NULL,@sequence+1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'registration_time');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+2,'taxpayer_number','yes','ld_account',1,1,'taxpayer_number','纳税人识别号',1,0,NULL,NULL,@sequence+2,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'taxpayer_number');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+3,'legal_representative','yes','ld_account',1,1,'legal_representative','法定代表人',1,0,NULL,NULL,@sequence+3,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'legal_representative');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,bigtype)
select @tabid,@max_fieldid+4,'scope_of_business','yes','ld_account',1,19,'scope_of_business','经营范围',1,0,NULL,NULL,@sequence+4,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0,'longtextarea'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'scope_of_business');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where block = @blockid and tabid = @tabid order by sequence;
delimiter;

call AddColumn('ld_account','registration_time','date','','');
delimiter;
call AddColumn('ld_account','taxpayer_number','varchar','200',NULL);
delimiter;
call AddColumn('ld_account','legal_representative','varchar','50',NULL);
delimiter;
call AddColumn('ld_account','scope_of_business','text','','');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'registration_time';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'注册时间' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Registration Time' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'taxpayer_number';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'纳税人识别号' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Taxpayer identification number' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'legal_representative';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'法定代表人' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Taxpayer identification number' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'scope_of_business';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'经营范围' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Scope of business' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select block,sequence into @blockid,@sequence from ld_field where tabid = @tabid and columnname = 'registeredcapital';
update ld_field set sequence = sequence + 100 where tabid = @tabid and block = @blockid and sequence > @sequence;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'registration_time','yes','ld_account',1,5,'registration_time','注册时间',1,0,NULL,NULL,@sequence+1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'registration_time');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+2,'taxpayer_number','yes','ld_account',1,1,'taxpayer_number','纳税人识别号',1,0,NULL,NULL,@sequence+2,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'taxpayer_number');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+3,'legal_representative','yes','ld_account',1,1,'legal_representative','法定代表人',1,0,NULL,NULL,@sequence+3,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'legal_representative');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,bigtype)
select @tabid,@max_fieldid+4,'scope_of_business','yes','ld_account',1,19,'scope_of_business','经营范围',1,0,NULL,NULL,@sequence+4,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0,'longtextarea'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'scope_of_business');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where block = @blockid and tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'registration_time';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'注册时间' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Registration Time' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'taxpayer_number';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'纳税人识别号' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Taxpayer identification number' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'legal_representative';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'法定代表人' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Taxpayer identification number' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'scope_of_business';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'经营范围' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Scope of business' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select block,sequence into @blockid,@sequence from ld_field where tabid = @tabid and columnname = 'qualifymaturitydate';
update ld_field set sequence = sequence + 100 where tabid = @tabid and block = @blockid and sequence >= @sequence;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'ve_registeredcapital','yes','ld_vendor',2,15,'ve_registeredcapital','注册资金',1,0,NULL,NULL,@sequence,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 've_registeredcapital');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where block = @blockid and tabid = @tabid order by sequence;
delimiter;
call AddColumn('ld_vendor','ve_registeredcapital','varchar','100',NULL);
delimiter;


insert into ld_picklist_set(listname,relatetable)
select 've_registeredcapital','ld_field' from DUAL
where not exists(select 1 from ld_picklist_set where listname = 've_registeredcapital' and relatetable = 'ld_field');
delimiter;

select listid into @listid from ld_picklist_set where listname = 've_registeredcapital' and relatetable = 'ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'50万以下',1 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 1);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'50-100万',2 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 2);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'100-500万',3 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 3);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'500-1000万',4 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 4);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'1000万以上',5 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 5);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 've_registeredcapital';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'注册资金' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Registered Capital' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select block,sequence into @blockid,@sequence from ld_field where tabid = @tabid and columnname = 'glacct';
update ld_field set sequence = sequence + 100 where tabid = @tabid and block = @blockid and sequence >= @sequence;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'vendorproperty','yes','ld_vendor',2,15,'vendorproperty','公司性质',1,0,NULL,NULL,@sequence+1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'vendorproperty');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where block = @blockid and tabid = @tabid order by sequence;
delimiter;
call AddColumn('ld_vendor','vendorproperty','varchar','100',NULL);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Vendors';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'vendorproperty';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'公司性质' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Company Nature' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

insert into ld_picklist_set(listname,relatetable)
select 'vendorproperty','ld_field' from DUAL
where not exists(select 1 from ld_picklist_set where listname = 'vendorproperty' and relatetable = 'ld_field');
delimiter;
select listid into @listid from ld_picklist_set where listname = 'vendorproperty' and relatetable = 'ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'国有企业',1 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 1);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'外资企业',2 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 2);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'民营企业',3 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 3);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'独资企业',4 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 4);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'合资企业',5 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 5);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'集体企业',6 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 6);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'股份制企业',7 from DUAL where not exists(select 1 from ld_picklist_values where listid = @listid and sequence = 7);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select block,sequence into @blockid,@sequence from ld_field where tabid = @tabid and columnname = 've_registeredcapital';
update ld_field set sequence = sequence + 100 where tabid = @tabid and block = @blockid and sequence > @sequence;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'registration_time','yes','ld_vendor',1,5,'registration_time','注册时间',1,0,NULL,NULL,@sequence+1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'registration_time');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+2,'taxpayer_number','yes','ld_vendor',1,1,'taxpayer_number','纳税人识别号',1,0,NULL,NULL,@sequence+2,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'taxpayer_number');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+3,'legal_representative','yes','ld_vendor',1,1,'legal_representative','法定代表人',1,0,NULL,NULL,@sequence+3,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'legal_representative');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,bigtype)
select @tabid,@max_fieldid+4,'scope_of_business','yes','ld_vendor',1,19,'scope_of_business','经营范围',1,0,NULL,NULL,@sequence+4,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0,'longtextarea'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'scope_of_business');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where block = @blockid and tabid = @tabid order by sequence;
delimiter;

call AddColumn('ld_vendor','registration_time','date','','');
delimiter;
call AddColumn('ld_vendor','taxpayer_number','varchar','200',NULL);
delimiter;
call AddColumn('ld_vendor','legal_representative','varchar','50',NULL);
delimiter;
call AddColumn('ld_vendor','scope_of_business','text','','');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'registration_time';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'注册时间' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Registration Time' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ld_vendor';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'taxpayer_number';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'纳税人识别号' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Taxpayer identification number' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ld_vendor';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'legal_representative';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'法定代表人' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Taxpayer identification number' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ld_vendor';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'scope_of_business';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'经营范围' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Scope of business' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'Vendors';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_VENDOR_ADDRESS_INFORMATION';
update ld_field set sequence = sequence + 100 where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'locationaddress','yes','ld_vendor',1,65,'locationaddress','定位',1,1,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+2,'locationaddress_map','yes','ld_vendor',1,64,'locationaddress_map','定位地址地图',1,1,NULL,NULL,2,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress_map');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where block = @blockid and tabid = @tabid order by sequence;
delimiter;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'定位' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Location' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress_map';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'地图' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Map' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

call AddColumn('ld_vendor','locationaddress','varchar','255',NULL);
delimiter;
call AddColumn('ld_vendor','locationaddress_map','varchar','20',NULL);
delimiter;

update ld_field set presence = 1 
where columnname in ('legal_representative','registration_time','taxpayer_number','scope_of_business','registeredcapital',
'vendorproperty','ve_registeredcapital','scope_of_business','locationaddress','locationaddress_map') and tabid = 18;
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceCharge';
update ld_field set presence = 1 
where columnname in ('registration_time','taxpayer_number','legal_representative','scope_of_business') and tabid in (6,@tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Backfill','回填','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Backfill' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Backfill','Backfill','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Backfill' and Labeltype='fixedstr');
delimiter;
-- 2020-07-16



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

UPDATE ld_version SET old_version='V8.1.3',current_version='V8.1.3',remark='V8.1.3-20200716',wx_version='V8.1.3';
delimiter;