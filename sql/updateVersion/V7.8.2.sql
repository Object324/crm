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

update ld_desk set fieldlabel='正在导出数据，请不要关闭或刷新浏览器' where labelbol='EXPORTINGDATA' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Exporting data, please do not close or refresh the browser' where labelbol='EXPORTINGDATA' and Labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_relatedlists set actions='add' where tabid in(select tabid from ld_tab where name='ServiceContracts') and name='get_paymentplan';

UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'V~0','V~O');
UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'~o','~O');
-- 2019-07-01

update ld_relatedlists set actions='add' where tabid in(select tabid from ld_tab where name='ServiceContracts') and name='get_paymentplan';
delimiter;

call addcolumn('ld_communicationaccount','service_tel','varchar',255,null);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','EVALUATESETTING04','客服电话','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='EVALUATESETTING04' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','EVALUATESETTING04','Service Tel','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='EVALUATESETTING04' and labeltype='fixedstr');
delimiter;

drop table if exists `ld_tmpcashsourcetable`;
delimiter;

create table ld_tmpcashsourcetable
(
id int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

drop PROCEDURE if EXISTS addsourcecolumnname ;
delimiter ||
create PROCEDURE addsourcecolumnname()
begin
	declare done  int  default 0;
	declare ttablename,ttabid  varchar(100) ;
	declare cur1 CURSOR FOR select tablename,tabid from ld_field where tabid in(
						select tabid from ld_field where uitype=202 and (columnname is null or columnname='' or tablename=''
						or tablename is null)
						) and uitype=4;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ttablename,ttabid;
	loop1: while  done<>1 DO
		CALl AddColumn(ttablename,'source_list','varchar','500','');
    CALl AddColumn(ttablename,'entitytype','varchar','50','');
		update ld_field set columnname='source_list' ,fieldname='source_list' where tabid=ttabid and uitype=202 and (columnname is null or columnname='');
		set @sql=CONCAT('update ld_field set columnname="source_list" ,fieldname="source_list",tablename="', ttablename,'" where tabid=',ttabid," and uitype=202 and (columnname is null or columnname='' or tablename='' or tablename is null)");
		
		prepare stmt from @sql;
		execute stmt;
		deallocate prepare stmt;
		if ttablename='ld_cashbill' or ttablename='ld_sendcashbill' THEN
			insert into ld_tmpcashsourcetable(id)value(2);
		
		else
			select  lower(`name`) into @modulename from ld_tab where tabid=ttabid;
			select  entityidfield into @entityidfield from ld_entityname where modulename=@modulename;
		
			set @sql=concat(' update ',ttablename,' inner join (select ',ttablename,'detail.entitytype,group_concat(ifnull(entitytypeid,"")) as entitytypeids');
			set	@sql=concat(@sql,",",ttablename,'.',@entityidfield,' from ',ttablename,' inner join ',ttablename,'detail on ',ttablename,'detail.id=',ttablename,'.',@entityidfield);
			set	@sql=concat(@sql," group by ",ttablename,'detail.id) as tmp on tmp.', @entityidfield,'=',ttablename,'.',@entityidfield);
			set @sql=concat(@sql," set ",ttablename,'.entitytype=tmp.entitytype,',ttablename,'.source_list=tmp.entitytypeids');
			
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
		end if;
		
		Fetch cur1 into ttablename,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

call addsourcecolumnname();
delimiter;

update ld_cashbill INNER JOIN
(
select ld_cashbill2paymentplan.entitytype,GROUP_CONCAT(ifnull(entitytypeid,'')) as entitytypeids,ld_cashbill.cashbillid  from ld_cashbill INNER JOIN ld_cashbill2paymentplan
on ld_cashbill2paymentplan.cashbillid =ld_cashbill.cashbillid
group by ld_cashbill.cashbillid ) as tmp  on tmp.cashbillid=ld_cashbill.cashbillid
set ld_cashbill.entitytype=tmp.entitytype,ld_cashbill.source_list=tmp.entitytypeids
where EXISTS(select id from ld_tmpcashsourcetable);
delimiter;
update ld_sendcashbill INNER JOIN
(
select ld_sendcashbill2payment.entitytype,GROUP_CONCAT(ifnull(entitytypeid,'')) as entitytypeids,ld_sendcashbill.sendcashbillid  
		from ld_sendcashbill INNER JOIN ld_sendcashbill2payment
on ld_sendcashbill2payment.sendcashbillid =ld_sendcashbill.sendcashbillid
group by ld_sendcashbill.sendcashbillid ) as tmp  on tmp.sendcashbillid=ld_sendcashbill.sendcashbillid
set ld_sendcashbill.entitytype=tmp.entitytype,ld_sendcashbill.source_list=tmp.entitytypeids
where EXISTS(select id from ld_tmpcashsourcetable);
delimiter;


update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where name='get_outorder' and related_coltable like '%detail.entitytypeid';
update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where name='get_invoices' and related_coltable like '%detail.entitytypeid';
update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where name='get_purchaseorder' and related_coltable like '%detail.entitytypeid';
update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where name='get_purchaseinquiryorder' and related_coltable like '%detail.entitytypeid';
update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where name='get_stock' and related_coltable like '%detail.entitytypeid';
update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where name='get_purchaseinvoice' and related_coltable like '%detail.entitytypeid';
update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where name='get_invoice' and related_coltable like '%detail.entitytypeid';

update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where name='get_quotes' and related_coltable like '%detail.entitytypeid';
delimiter;


insert into  ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'REFERENCEFIELD','Reference Field','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='REFERENCEFIELD' and Labeltype='fixedstr');
delimiter;
insert into  ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'REFERENCEFIELD','引用字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='REFERENCEFIELD' and Labeltype='fixedstr');
delimiter;


insert into  ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'RelatedModule','Related Module','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='RelatedModule' and Labeltype='fixedstr');
delimiter;

insert into  ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'RelatedModule','引用对象','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='RelatedModule' and Labeltype='fixedstr');
delimiter;


insert into  ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'SELECTREFREENCEMODULE','Please select the reference module first','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='SELECTREFREENCEMODULE' and Labeltype='fixedstr');
delimiter;

insert into  ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'SELECTREFREENCEMODULE','请先选择引用对象','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='SELECTREFREENCEMODULE' and Labeltype='fixedstr');
delimiter;


insert into  ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'Savetodatabase','Save to database','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='Savetodatabase' and Labeltype='fixedstr');
delimiter;

insert into  ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'Savetodatabase','保存到数据库','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='Savetodatabase' and Labeltype='fixedstr');
delimiter;

CALl AddColumn('ld_field','savedatabase','varchar','50','yes');
delimiter;

CALl AddColumn('ld_field','bigtype','varchar','50','');
delimiter;

alter table ld_field alter savedatabase set default 'yes';
update ld_field set savedatabase='yes'  where bigtype<>'RelatedModuleField';
delimiter;

update ld_field set savedatabase='yes'  where ifnull(bigtype,'')<>'RelatedModuleField';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHANGEENTITYTYPETIP','更改源单类型将清空已录入的源单和关联源单的分录明细信息，是否继续？','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHANGEENTITYTYPETIP' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHANGEENTITYTYPETIP','Changing the source type will empty the source list and related entry details. Do you want to continue?','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHANGEENTITYTYPETIP' and labeltype='jspop');
delimiter;
-- 2019-07-04

update ld_desk set fieldlabel='已找到的记录：' where labelbol='TOTALRECORDFOUND' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Total Records found:' where labelbol='TOTALRECORDFOUND' and Labeltype='fixedstr' and languagetype='en';
delimiter;


update ld_appparenttab set sequence=sequence+1 ;

select max(sequence) into @maxsequence from ld_appparenttab;
insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '报表',0,1,'yes' ,'Reports' from dual 
where not exists(select 1 from ld_appparenttab where parenttab_label='Reports');
delimiter;

CALl AddColumn('ld_appparenttabrel','relatename','text','','');
delimiter;
drop PROCEDURE if EXISTS addMobileReportBlock ;
delimiter ||
create PROCEDURE addMobileReportBlock()
begin
declare done  int  default 0;
	declare nname varchar(100);
declare iid int(11);
	declare cur1 CURSOR FOR select id,NAME FROM ld_dashboard_app 
	LEFT JOIN ld_appuiset on ld_dashboard_app.name=ld_appuiset.setname and ld_appuiset.apptype='weixin' 
   and ld_appuiset.userid=1 WHERE wx_presence = 1 and name in('Saleskit','Contractkit','Salesfunnel','InventoryQuery') order by wx_sequence ASC;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into iid, nname;
	select blockid into @blockid from ld_appparenttab where parenttab_label='reports';
	set @i=1;
	loop1: while  done<>1 DO
		set @sql=concat('insert into ld_appparenttabrel(blockid,tabid,sequence,relatename) ','select ',@blockid);
		set @sql=concat(@sql,',',iid,',',@i,',"',nname,'" from dual where not exists(select 1 from ld_appparenttabrel where blockid= ',@blockid,' and  relatename="',nname,'")');
			
	  prepare stmt from @sql;
		execute stmt;
		set @i=@i+1;
		deallocate prepare stmt;
		Fetch cur1 into iid,nname;
	end while loop1;
	close cur1;
end ||
delimiter;
call addMobileReportBlock();
delimiter;

select wx_sequence into @sequence from ld_dashboard_app where name='Saleskit';
update ld_dashboard_app set wx_sequence=wx_sequence+2;
insert into ld_dashboard_app(name,labelbol,modulenames,image,presence,wx_presence,wx_sequence)
select 'Contractkit','Contractkit','SalesOrder','dashboard_6',0,1,@sequence+1 from dual 
where not EXISTS(select 1 from ld_dashboard_app where name='Contractkit');
delimiter;

select blockid into @blockid from ld_appparenttab where parenttab_label='Reports';
select id into @tabid from ld_dashboard_app where name='Contractkit';
select max(sequence) into @maxsequence from ld_appparenttabrel;
insert into ld_appparenttabrel(blockid,tabid,sequence,relatename)
select @blockid,@tabid,1,'Contractkit' from dual where not EXISTS(select 1 from ld_appparenttabrel where relatename='Contractkit');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Contractkit','合同简报','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='contractkit' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Contractkit','Contract kit','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='contractkit' and Labeltype='fixedstr');
delimiter;
-- 2019-07-06


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

UPDATE ld_version SET old_version='V7.8.2',current_version='V7.8.2',remark='V7.8.2-20190706',wx_version='V7.8.2';
delimiter;