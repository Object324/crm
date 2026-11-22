UPDATE ld_field SET presence=1 WHERE columnname='nolinkdays' AND NOT EXISTS (SELECT 1 FROM ld_account);

delete from  ld_relatedlists  where related_tabid=-11;
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','PRINTTOOL','打印工具','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRINTTOOL' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','PRINTTOOL','Printing tool','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRINTTOOL' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','CHOOSEOPERATE','选择操作','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHOOSEOPERATE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','CHOOSEOPERATE','Choose  Operate','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHOOSEOPERATE' and labeltype='fixedstr');
delimiter;

update ld_field set typeofdata='V~O' where tabid=13 and fieldname='potential_id' or fieldname='servicecontractsid' or fieldname='salesorder_id';
update ld_field set typeofdata='V~O' where tabid=(select tabid  from ld_tab where name='contactrecords') and fieldname='product_id';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULEDETAIL','详细资料','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MODULEDETAIL' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULEDETAIL',' details ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MODULEDETAIL' and labeltype = 'fixedstr');
delimiter;

CALL AddColumn('ld_fieldwxmaininfo','presence','int','4','0');
CALL AddColumn('ld_fieldwxmaininfo','showtag','varchar','10','yes');
update ld_fieldwxmaininfo set showtag='no' where displaytype='title';
update ld_fieldwxmaininfo set showtag='yes' where displaytype in('tagtitle','normal');
delimiter;

select tabid into @tabid from ld_tab where name='Commission';
update ld_fieldwxmaininfo set sequence=0 where fieldname='assigned_user_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='Expense';
update ld_fieldwxmaininfo set sequence=0 where fieldname='assigned_user_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
update ld_fieldwxmaininfo set sequence=0 where fieldname='assigned_user_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
update ld_fieldwxmaininfo set sequence=0 where fieldname='assigned_user_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='ContactRecords';
update ld_fieldwxmaininfo set sequence=0 where fieldname='account_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
update ld_fieldwxmaininfo set sequence=0 where fieldname='account_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
update ld_fieldwxmaininfo set sequence=0 where fieldname='account_id' and tabid=@tabid;

set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
update ld_fieldwxmaininfo set sequence=0 where fieldname='account_id' and tabid=@tabid;

set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
update ld_fieldwxmaininfo set sequence=0 where fieldname='account_id' and tabid=@tabid;
set @i=0;

update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='Contacts';
update ld_fieldwxmaininfo set sequence=0 where fieldname='account_id' and tabid=@tabid;
set @i=0;

update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileAppMainInfoCustomization','移动端详情界面头部定制','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MobileAppMainInfoCustomization' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileAppMainInfoCustomization','Mobile App Detail Header Customization','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MobileAppMainInfoCustomization' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Customisedetailheaderlayoutofmobileapplication','定制移动端模块详情界面头部显示的字段和布局样式','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'Customisedetailheaderlayoutofmobileapplication' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Customisedetailheaderlayoutofmobileapplication','Customise detail header layout of mobile application','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'Customisedetailheaderlayoutofmobileapplication' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBI_UI_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid=@blockid and name='MobileAppDataListCustomization';
select max(fieldid) into @fieldid from ld_settings_field;
update ld_settings_field set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'MobileAppMainInfoCustomization','picklistdependency.png','Customisedetailheaderlayoutofmobileapplication','index.php?module=Settings&action=MobileMainInfo&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'MobileAppMainInfoCustomization');
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addpermission_bytabaction`;
delimiter ||
CREATE PROCEDURE `ldcrm_addpermission_bytabaction`(
	tmp_profileid INT(19),
	tmp_modulename VARCHAR(100),
	tmp_actionname VARCHAR(100)
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
	SET @actionid=(SELECT actionid FROM ld_actionmapping WHERE actionname=tmp_actionname);

	INSERT INTO ld_profile2tab(profileid,tabid,permissions) 
	SELECT tmp_profileid,@tabid,0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_profile2tab WHERE profileid=tmp_profileid AND tabid=@tabid);
	
	UPDATE ld_profile2tab SET permissions=0 WHERE profileid=tmp_profileid AND tabid=@tabid AND permissions=1;

	IF EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@actionid) THEN
		INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
		SELECT tmp_profileid,tabid,operation,0,sequence FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@actionid 
			AND NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE profileid=tmp_profileid AND tabid=@tabid AND operation=@actionid);

		UPDATE ld_profile2standardpermissions SET permissions=0 WHERE profileid=tmp_profileid AND tabid=@tabid AND operation=@actionid;
	END IF;
	
end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_allprofile_bytabaction_201800109`;
delimiter ||
CREATE PROCEDURE `ldcrm_allprofile_bytabaction_201800109`(
	tmp_modulename VARCHAR(100),
	tmp_actionname VARCHAR(100)
)
BEGIN
	
	DECLARE tmp_profileid INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profilename IN ('销售总监','销售人员');
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_profileid;
	WHILE(tmp_profileid IS NOT NULL) DO
		CALL ldcrm_addpermission_bytabaction(tmp_profileid,tmp_modulename,tmp_actionname);
		FETCH MYCUSOR INTO tmp_profileid;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_rest_defaultprofile20180109`;
delimiter ||
CREATE PROCEDURE `ldcrm_rest_defaultprofile20180109`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype<>'Reminds' HAVING COUNT(1)>6) THEN
		CALL ldcrm_allprofile_bytabaction_201800109('OftenUseReport','index');
	END IF;
end ||
delimiter;

CALL ldcrm_rest_defaultprofile20180109();
DROP PROCEDURE IF EXISTS `ldcrm_allprofile_bytabaction_201800109`;
DROP PROCEDURE IF EXISTS `ldcrm_rest_defaultprofile20180109`;
delimiter;


DROP PROCEDURE IF EXISTS `del_idx`;
delimiter ||
CREATE DEFINER=`root`@`localhost` PROCEDURE `del_idx`(
 p_idxname varchar(100),
 p_tablename varchar(50)
)
begin  
DECLARE str VARCHAR(250);  
  set @str=concat(' drop index ',p_idxname,' on ',p_tablename);   
    select database() into @tableschema;

 set @strcount=concat('select count(*) into @cnt from information_schema.statistics where table_name=''',p_tablename,''' and index_name=''',p_idxname,'''  and table_schema=''',@tableschema,'''');  

  PREPARE stmtt FROM @strcount;  
    EXECUTE stmtt ;    
if @cnt >0 then   
    PREPARE stmt FROM @str;  
    EXECUTE stmt ;  
  end if;  
end ||
delimiter;

CALL del_idx('crm_ownerid_del_setype_idx','ld_crmentity');
CALL del_idx('crmentity_multi_index','ld_crmentity');
DROP PROCEDURE IF EXISTS `del_idx`;
delimiter;

UPDATE ld_workreport_showset SET presence='no' WHERE type IN ('weibo','cocmd')
	AND NOT EXISTS (SELECT 1 FROM ld_workreport)
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN(55,56,57,58));
    
UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=16 AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type IN (26,61) AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);

update ld_desk set fieldlabel='可选模块' where labelbol='ALLMODULES' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='已选模块' where labelbol='DISPLAYMODULE' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

ALTER TABLE ld_workreport_field MODIFY COLUMN defaultvalue TEXT;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOSTOFFIVELINE','最多显示5行数据','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MOSTOFFIVELINE' and labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOSTOFFIVELINE','A maximum of 5 lines of data','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MOSTOFFIVELINE' and labeltype='jspop');
delimiter;

update ld_field set typeofdata='V~O' where tabid=(select tabid  from ld_tab where name='ServiceReturn') and columnname='troubleticketid';
update ld_field set typeofdata='V~O' where tabid=(select tabid  from ld_tab where name='PurchaseCashBack') and columnname='purchaseback_id';
update ld_field set typeofdata='V~O' where tabid=(select tabid  from ld_tab where name='CashBack') and columnname='salesbackid';
update ld_field set typeofdata='V~O' where tabid=(select tabid  from ld_tab where name='HelpDesk') and columnname='product_id';
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'ModComments' and viewname = '本周创建';
update ld_cvadvfilter set columnname = 'ld_modcomments:createdtime:createdtime:ModComments_fieldlabel:DT' where cvid =@cvid;
select cvid into @cvid from ld_customview where entitytype = 'ModComments' and viewname = '本月创建';
update ld_cvadvfilter set columnname = 'ld_modcomments:createdtime:createdtime:ModComments_fieldlabel:DT' where cvid =@cvid;
-- 2018-01-10


update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.2.0',current_version='V7.2.0',remark='V7.2.0-20180109',wx_version='V7.2.0';
delimiter;