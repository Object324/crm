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

select tabid into @tabid from ld_tab where name='Singin';
update ld_field set uitype=70 where tabid=@tabid and columnname='createdtime';
delimiter;

select tabid into @related_tabid from ld_tab where name='commission';
select tabid into @tabid from ld_tab where name='potentials';
select max(relation_id) into @maxid from ld_relatedlists;
update ld_relatedlists_seq set id=@maxid+1 where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid);
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,type,related_coltable,wx_presence)
select @maxid+1,@tabid,@related_tabid,'get_commission',20,'Commission',1,'add',1,'datacategory_sql','commission.potentialid',1 from dual 
where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid);
delimiter;

call AddColumn('ld_dashboard_app','home_presence','varchar',255,null );
call AddColumn('ld_dashboard_app','home_sequence','int',11,null );

update ld_dashboard_app set home_presence='yes'
where name in ('Contractkit','Saleskit','Salesfunnel','Contractamount','Returnamount');
update ld_dashboard_app set home_sequence=1 where name='Contractkit';
update ld_dashboard_app set home_sequence=2 where name='Saleskit';
update ld_dashboard_app set home_sequence=3 where name='Salesfunnel';
update ld_dashboard_app set home_sequence=4 where name='Contractamount';
update ld_dashboard_app set home_sequence=5 where name='Returnamount';

select max(fieldid) into @fieldid from ld_settings_field ;
select blockid into @blockid from ld_settings_blocks where label='LBI_UI_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid=@blockid and name='LBL_TABLIST';
update ld_settings_field set sequence=sequence+1 where sequence > @sequence;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
  select @fieldid+1,@blockid,'mobile_home_setting','picklistdependency.png','mobile_home_describ',
    'index.php?module=Settings&action=mobile_home_setting&parenttab=Settings',@sequence+1,0 from DUAL
  where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'mobile_home_setting');
set @i =0 ;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence asc;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','mobile_home_setting','移动端首页定制','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'mobile_home_setting' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','mobile_home_setting','Mobile home customization','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'mobile_home_setting' and languagetype='en' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','mobile_home_describ','定制移动端首页显示的报表','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'mobile_home_describ' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','mobile_home_describ','Customize the report displayed on the mobile home page','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'mobile_home_describ' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','mobile_home_remind_one','至少需要启用一个报表','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'mobile_home_remind_one' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','mobile_home_remind_one','At least one report needs to be enabled','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'mobile_home_remind_one' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_producttoolfield a
LEFT JOIN ld_producttoolfield_formula b ON a.producttoolfieldid=b.producttoolfieldid
SET b.formulastring='base_tax_amount*a',columnstring="{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount]}"
WHERE 1=1
	AND columnname='tax_amount'
	AND b.formulastring='base_tax_amount*a*c/100'
	AND b.columnstring="{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount,{'lettervar':'c','column':'discount_percent'}]}"
	AND EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=a.tabid AND presence=1 AND columnname='discount_percent');
delimiter;
		
UPDATE ld_producttoolfield a
LEFT JOIN ld_producttoolfield_formula b ON a.producttoolfieldid=b.producttoolfieldid
SET b.formulastring='base_tax_amount*a*c/100',b.columnstring="{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount,{'lettervar':'c','column':'discount_percent'}]}"
WHERE 1=1
	AND columnname='tax_amount'
	AND b.formulastring='base_tax_amount*a'
	AND b.columnstring="{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount]}"
	AND EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=a.tabid AND presence<>1 AND columnname='discount_percent');
delimiter;

update ld_salesorderdetail set balanceinvoicecount=quantity-ifnull(haveinvoicecount,0)
where haveinvoicecount is null or haveinvoicecount=0;
delimiter;

update ld_desk set fieldlabel="The consignation of examining and approving has been applied,the consigner can't be empty"
where labelbol='APPROVINGCLIENTCANOTEMPTY' and languagetype='en';
delimiter;


select max(actionid) into @maxactionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @maxactionid+1,'DownLoad',0,'DOWNLOAD' from dual 
where not exists(select 1 from ld_actionmapping where actionname='download');
delimiter;

select max(actionid) into @maxactionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @maxactionid+1,'Preview',0,'PREVIEW' from dual 
where not exists(select 1 from ld_actionmapping where actionname='Preview');
delimiter;

select tabid into @tabid from ld_tab where name='Attachment';
select actionid into @operation from ld_actionmapping where actionname='download';
select max(sequence) into @maxsequence from ld_profileallpermission where tabid=@tabid ;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@operation,@maxsequence+1 from dual 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@operation);
delimiter;

select tabid into @tabid from ld_tab where name='Attachment';
select actionid into @operation from ld_actionmapping where actionname='preview';
select max(sequence) into @maxsequence from ld_profileallpermission where tabid=@tabid ;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@operation,@maxsequence+1 from dual 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@operation);
delimiter;

drop PROCEDURE if EXISTS downloadorpreviewprofile;
delimiter ||
create PROCEDURE downloadorpreviewprofile()
begin
	
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name="Attachment"');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;

	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
				 select actionid into @downloadoperation from ld_actionmapping where actionname='download';
		   		select actionid into @previewoperation from ld_actionmapping where actionname='preview';
				 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',@downloadoperation,',',0,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@downloadoperation,')' );
				  prepare stmt from @sql;
			  	execute stmt;

			   deallocate prepare stmt;
				 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',@previewoperation,',',0,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@previewoperation,')' );
				  prepare stmt from @sql;
			  	execute stmt;
			   deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

CALL downloadorpreviewprofile();
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetDetailRelatedModules','设置单据详情界面左边相关信息显示的栏目','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetDetailRelatedModules' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetDetailRelatedModules','Setting the module for the related information to display on the left side of the bill details interface','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetDetailRelatedModules' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllRelatedModules','可选栏目','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AllRelatedModules' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllRelatedModules','All Modules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AllRelatedModules' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllRelatedModules','可选栏目','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AllRelatedModules' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllRelatedModules','All Modules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AllRelatedModules' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectedRelateModules','已选栏目','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectedRelateModules' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectedRelateModules','Display modules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectedRelateModules' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QuickCreateSetting','新建界面设置','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='QuickCreateSetting' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QuickCreateSetting','Settings the create interface','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='QuickCreateSetting' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DefaultDisplayQuickField','默认显示快速创建字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DefaultDisplayQuickField' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DefaultDisplayQuickField','Default display quick creation fields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DefaultDisplayQuickField' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DefaultDisplayAllfield','默认显示全部字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DefaultDisplayAllfield' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DefaultDisplayAllfield','Default display all fields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DefaultDisplayAllfield' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MandatoryFieldnotallowedcancelled','必填字段不允许取消快速创建','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MandatoryFieldnotallowedcancelled' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MandatoryFieldnotallowedcancelled','Mandatory fields do not allow quick creation to be cancelled','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MandatoryFieldnotallowedcancelled' and Labeltype='fixedstr');
delimiter;

UPDATE ld_salesorderdetail a 
LEFT JOIN (
	SELECT parent_lineitem_id,sum(quantity) as invoice_qty  from ld_invoice a
	LEFT JOIN ld_invoicedetail b on a.invoiceid=b.id
	where a.deleted=0 and b.entitytypeid>0 and b.entitytype='SalesOrder'
	GROUP BY parent_lineitem_id
) b on b.parent_lineitem_id=a.lineitem_id
SET a.haveinvoicecount=ifnull(b.invoice_qty,0),a.balanceinvoicecount=a.quantity-ifnull(b.invoice_qty,0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','afteroperationthisrecord','升级后将转入"{$Accounts.Accounts}"模块，是否继续？','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'afteroperationthisrecord' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','afteroperationthisrecord','After operation this record will be transferred to "{$Accounts.Accounts}",continue or not?','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'afteroperationthisrecord' and labeltype = 'fixedstr');
delimiter;
-- 2019-09-11

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

UPDATE ld_version SET old_version='V7.8.8',current_version='V7.8.8',remark='V7.8.8-20190911',wx_version='V7.8.8';
delimiter;