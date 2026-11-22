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

UPDATE ld_field SET searchfieldtype=0 WHERE tabid=22 AND columnname IN ('salesorder_no','accountid','smownerid','signed_data','total','sostatus') AND presence<>1;

UPDATE ld_field SET searchfieldtype=0 WHERE tabid=22 AND 
columnname IN ('salesorder_no', 'subject', 'accountid', 'signed_data', 'total', 'sostatus', 'smownerid')
and ifnull(searchfieldtype,1)<>0;
delimiter;

UPDATE ld_field SET searchfieldtype=0 WHERE tabid=37 AND 
columnname IN ('subject', 'contract_no', 'contract_status', 'total', 'accountid', 'smownerid', 'due_date') 
and ifnull(searchfieldtype,1)<>0;
delimiter;

update ld_field INNER JOIN ld_entityname
on ld_entityname.tabid=ld_field.tabid  and ld_entityname.fieldname=ld_field.fieldname
set searchfieldtype=0;
delimiter;

update ld_field set searchfieldtype=0 where tabid=6 and columnname in('accountname','account_no','smownerid');
delimiter;

update ld_field set searchfieldtype=0 where tabid=14 and columnname in('product_no','productsheet');
delimiter;

select tabid into @tabid from ld_tab where name='vendors';

update ld_field set searchfieldtype=0 where tabid=@tabid and columnname in('vendorname','vendor_no','smownerid');
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select max(sequence) into @maxsequence from ld_producttoolfield;
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'haveinvoiceamount','yes','已开票金额','',1,50,'NN~O~25,3',@maxsequence+1,@tabid ,'ld_salesorderdetail',30,3,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='haveinvoiceamount');
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='haveinvoiceamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'已开票金额' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='haveinvoiceamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'Invoiced amount' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;

CALL AddColumn('ld_salesorderdetail','haveinvoiceamount','decimal','25,2',0);
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select max(sequence) into @maxsequence from ld_producttoolfield;
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'balanceinvoiceamount','yes','未开票金额','',1,50,'NN~O~25,3',@maxsequence+1,@tabid ,'ld_salesorderdetail',30,3,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='balanceinvoiceamount');
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='balanceinvoiceamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'未开票金额' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='balanceinvoiceamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'Uninvoiced amount' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;

CALL AddColumn('ld_salesorderdetail','balanceinvoiceamount','decimal','25,2',0);
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select max(sequence) into @maxsequence from ld_producttoolfield;
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'haveoutproductamount','yes','已发货金额','',1,50,'NN~O~25,3',@maxsequence+1,@tabid ,'ld_salesorderdetail',30,3,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='haveoutproductamount');
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='haveoutproductamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'已发货金额' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='haveoutproductamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'Amount of shipment' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;

CALL AddColumn('ld_salesorderdetail','haveoutproductamount','decimal','25,2',0);
delimiter;


select tabid into @tabid from ld_tab where name='SalesOrder';
select max(sequence) into @maxsequence from ld_producttoolfield;
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'balanceoutproductamount','yes','未发货金额','',1,50,'NN~O~25,3',@maxsequence+1,@tabid ,'ld_salesorderdetail',30,3,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='balanceoutproductamount');
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='balanceoutproductamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'未发货金额' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='balanceoutproductamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'Unshipped amount' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;

CALL AddColumn('ld_salesorderdetail','balanceoutproductamount','decimal','25,2',0);
delimiter;
-- 2019-08-20

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

UPDATE ld_version SET old_version='V7.8.4',current_version='V7.8.4',remark='V7.8.4-20190820',wx_version='V7.8.3';
delimiter;