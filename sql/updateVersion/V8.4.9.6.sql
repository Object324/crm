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

update ld_customtable set `sqlstr`='select \nsmownerid,\npotential_no,\npotentialid,\npotentialname,\naccountname,\nlast_name,\ntotal,\nsales_stage,\ncreatedtime,\nchangedon,\ngaptime,\nordernum\nfrom (\nselect \np.smownerid,\np.potential_no,\np.potentialid,\np.potentialname,\na.accountname,\nu.last_name,\np.total,\np.sales_stage,\np.createdtime,\nmodtracker.changedon,\ntimestampdiff(HOUR,p.createdtime,modtracker.changedon)as gaptime,\n1 as ordernum\nfrom \nld_potential p \nleft join ld_account a on p.accountid=a.accountid\nleft join ld_users u on u.id=p.smownerid\nleft join(\nselect \nld_modtracker_basic.crmid,\nmax(ld_modtracker_basic.changedon) as changedon,\nld_modtracker_detail.fieldname,\nld_modtracker_detail.postvalue\nfrom ld_modtracker_basic \nleft join ld_modtracker_detail on ld_modtracker_basic.id=ld_modtracker_detail.id\nwhere ld_modtracker_basic.module=\'Potentials\'\nand ld_modtracker_detail.postvalue=\'成功结案\' \nand ld_modtracker_detail.fieldname=\'sales_stage\'\ngroup by ld_modtracker_basic.crmid\n)modtracker on modtracker.crmid=p.potentialid\nwhere p.sales_stage=\'成功结案\'  and p.deleted=0 \nand p.createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 00:00:00\') and p.createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\')\nand find_in_set(p.smownerid,\'{userid}\')\nunion all \nselect \nsmownerid,\n\'\' as potential_no,\n\'\' as potentialid,\n\'\' as potentialname,\n\'\' as accountname,\nconcat(last_name,\'-小计\') as last_name,\n\'\' as total,\n\'\' as sales_stage,\n\'\' as createdtime,\n\'\' as changedon,\nsum(timestampdiff(HOUR,createdtime,changedon))/count(1) as gaptime,\n2 as ordernum\nfrom (\nselect \np.smownerid,\np.potential_no,\np.potentialid,\np.potentialname,\nu.last_name,\np.total,\np.sales_stage,\np.createdtime,\nmodtracker.changedon,\ntimestampdiff(HOUR,p.createdtime,modtracker.changedon)as gaptime,\n2 as ordernum\nfrom \nld_potential p \nleft join ld_account a on p.accountid=a.accountid\nleft join ld_users u on u.id=p.smownerid\nleft join(\nselect \nld_modtracker_basic.crmid,\nmax(ld_modtracker_basic.changedon) as changedon,\nld_modtracker_detail.fieldname,\nld_modtracker_detail.postvalue\nfrom ld_modtracker_basic \nleft join ld_modtracker_detail on ld_modtracker_basic.id=ld_modtracker_detail.id\nwhere ld_modtracker_basic.module=\'Potentials\'\nand ld_modtracker_detail.postvalue=\'成功结案\' \nand ld_modtracker_detail.fieldname=\'sales_stage\'\ngroup by ld_modtracker_basic.crmid\n)modtracker on modtracker.crmid=p.potentialid\nwhere p.sales_stage=\'成功结案\'\n and p.deleted=0 and p.createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 00:00:00\') and p.createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\')\nand find_in_set(p.smownerid,\'{userid}\')\n)a group by smownerid\n)a order by smownerid asc,ordernum asc;'
where `primaryname`='potiential_report_avg_period' and deleted=0;
select report_id into @report_id from ld_customtable where  `primaryname`='potiential_report_avg_period' and deleted=0 limit 1;

INSERT INTO `ld_customtable_columns` (`report_id`, `tdheader_label`, `columns`, `columnmodule`, `is_group`, `order_by`, `is_merge`, `total_type`, `align`, `sequence`, `tdheader_label_en`, `alias`, `suffix`, `decimal_places`, `columnstring`, `prefix`, `visibile`, `fieldtype`, `linkurl`, `issticky`, `styleset_header`, `styleset_body`)
select @report_id, '客户名称', 'accountname', NULL, NULL, NULL, 'no', NULL, 'left', '4', NULL, NULL, NULL, '0', NULL, NULL, 'yes', 'string', 'no', 'no', 'null', 'null'
from dual
where not exists(select 1 from ld_customtable_columns where report_id=@report_id and `columns`='accountname' and tdheader_label='客户名称');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEXT','下一步','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEXT' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEXT','Next','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEXT' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ASTEP','上一步','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ASTEP' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ASTEP','Last step','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ASTEP' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILLBASICINFORMATION','填写基础信息','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='FILLBASICINFORMATION' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILLBASICINFORMATION','Fill in basic information','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='FILLBASICINFORMATION' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETLAYOUTRULES','设置布局规则','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SETLAYOUTRULES' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETLAYOUTRULES','Set layout rules','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SETLAYOUTRULES' and Labeltype='jspop' and languagetype='en');
delimiter;

update ld_customtable set `sqlstr`='select \np.smownerid,\np.potential_no,\np.potentialid,\np.potentialname,\na.accountname,\nu.last_name,\np.total,\nmodtracker.prevalue as postvalue,\nmodtracker.createdtime,\nmodtracker.endtime,\ntimestampdiff(HOUR,modtracker.createdtime,modtracker.endtime)as gaptime\nfrom \nld_potential p \nleft join ld_account a on p.accountid=a.accountid\nleft join ld_users u on u.id=p.smownerid\nleft join(\nselect   t.crmid,t1.crmid as crmid1 ,timestampdiff(HOUR,t1.changedon,t.changedon)as gaptime,t1.j,t.prevalue,\ncase when t.crmid<>ifnull(t1.crmid,0)  then t.createdtime else t1.changedon  end as createdtime ,t.changedon as endtime \nfrom \n(select (@i:=@i+1) as i,a.*,p.createdtime,detail.postvalue,detail.prevalue from ld_modtracker_basic  as a left join ld_modtracker_detail detail on  detail.id=a.id INNER JOIN ld_potential  as p on p.potentialid=a.crmid and p.deleted=0 and detail.fieldname=\'sales_stage\' and a.module=\'Potentials\',(select @i:=0) as it    order by id asc) t\nleft join \n(select (@j:=@j+1) as j,a.* from ld_modtracker_basic as a left join ld_modtracker_detail detail on  detail.id=a.id INNER JOIN ld_potential \nas p on p.potentialid=a.crmid and p.deleted=0 and  detail.fieldname=\'sales_stage\' and a.module=\'Potentials\',(select @j:=1) as it     order by id asc ) t1\non t.i=t1.j\n\nunion all \n\nselect\n a.crmid,a.crmid as crmid1,\'-\' as gaptime,0 as j,detail.postvalue,a.changedon as createdtime,\'-\'as endtime\nfrom ld_modtracker_basic  as a left join ld_modtracker_detail detail on  detail.id=a.id\nINNER JOIN (select max(id)as id  from ld_modtracker_basic  GROUP BY crmid )b on a.id=b.id \nwhere detail.fieldname=\'sales_stage\' and a.module=\'Potentials\'\n\n)modtracker on modtracker.crmid=p.potentialid\nwhere p.deleted=0\nand p.createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 00:00:00\') and p.createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\')\nand find_in_set(p.smownerid,\'{userid}\')\norder by p.smownerid asc,p.potentialid desc,modtracker.createdtime desc'
where `primaryname`='potiential_report_stay_period' and deleted=0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETEDATAKANBAN','是否删除该数据看板','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEDATAKANBAN' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETEDATAKANBAN','Whether to delete the data kanban','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEDATAKANBAN' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INPUTSEARCHSTUFFNAME','请输入要查找的报表组件名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INPUTSEARCHSTUFFNAME' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INPUTSEARCHSTUFFNAME','Please enter the name of the report component to find','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INPUTSEARCHSTUFFNAME' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @labelbol = 'MISSCASCADEFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'缺少级联字段设置！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Missing Cascade Field settings!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

CALl AddColumn('ld_cashback','triggercount','INT','19',0);
delimiter;

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms');
UPDATE ld_tranlabel SET fieldlabel='自定义表单' WHERE Relateid=@parenttabid AND trantable='ld_parenttab' AND languagetype='zh' AND fieldlabel='Custom Forms';
delimiter;
-- 2023-04-06

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANCELHOMEBOARDCHECK','该数据看板没有保存，退出将丢失未保存的信息，确定要退出吗？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CANCELHOMEBOARDCHECK' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELHOMEBOARDCHECK','The data kanban has not been saved. Exiting will lose any unsaved information. Are you sure you want to exit?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CANCELHOMEBOARDCHECK' and Labeltype='jspop' and languagetype='en');
delimiter;

set @count = (select count(1) from ld_account);
UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type =280 and @count=0;
UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type =326 and @count=0;
UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type =327 and @count=0;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_salestarget_basic` (
  `targetid` int(19) NOT NULL ,
  `targetname` varchar(30) NOT NULL,
	`zhlabel` varchar(100) DEFAULT NULL,
	`enlabel` varchar(100) DEFAULT NULL,
  `status` varchar(10) DEFAULT NULL,
	`modulename` varchar(50) DEFAULT NULL,
	`groupsetting` varchar(20) DEFAULT NULL,
	`scope` varchar(50) DEFAULT NULL,
	`sequence` int(5) DEFAULT NULL,
  `smownerid` int(19) DEFAULT NULL,
	`smcreatorid` int(19) DEFAULT NULL,
	`modifiedby` int(19) DEFAULT NULL,
	`createdtime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`modifiedtime` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`targetid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_salestarget_detail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
	`targetid` int(19) NOT NULL,
	`entitytype` varchar(50) DEFAULT NULL,
	`referencefield` varchar(255) DEFAULT NULL,
	`funname` varchar(20) DEFAULT NULL,
	`countfield` varchar(255) DEFAULT NULL,
	`datefield` varchar(255) DEFAULT NULL,
	`approvedemand` varchar(10) DEFAULT NULL,
  `othercondition` Text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_salestarget_info` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
	`targetid` int(19) NOT NULL,
	`record` int(19) NOT NULL,
	`type` varchar(50) DEFAULT NULL,
	`targetyear` int(19) NOT NULL,
	`targetmonth` int(19) NOT NULL,
	`targetvalue` decimal(25,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

drop PROCEDURE if EXISTS add_default_salestarget;
delimiter ||
create PROCEDURE add_default_salestarget
(
)
BEGIN
		declare tmp_fieldid int(19);
		
		IF NOT EXISTS(SELECT 1 from ld_salestarget_basic) THEN
			SET @salesgoal_module = 'SalesGoal';
			SET @var_accountversion = (SELECT account from ld_version);

			SET @targetname = 'paymentamount';
			SET @zhlabel = '收款额';
			SET @enlabel = 'Amount Back';
			SET @sequence = 0;
			SET @new_target_id = (SELECT id from ld_crmentity_seq)+1;
			UPDATE ld_crmentity_seq SET id = id+1;
			INSERT into ld_crmentity(crmid,setype) value(@new_target_id,@salesgoal_module);
			
			INSERT ld_salestarget_basic(targetid,targetname,zhlabel,enlabel,`status`,modulename,groupsetting,smownerid,smcreatorid,scope,sequence)
			SELECT @new_target_id,@targetname,@zhlabel,@enlabel,'yes','Users','noedit',1,1,'all',@sequence+1 from DUAL
			where NOT EXISTS(SELECT 1 from ld_salestarget_basic where targetname = @targetname);
			
			SET @new_target_id = (SELECT targetid from ld_salestarget_basic where targetname = @targetname);
			call create_viewvalue(@targetname,@new_target_id);
			DELETE from ld_salestarget_detail where targetid = @new_target_id;
			SET @var_entitytype = 'CashBill';
			SET @var_funname = 'sum';
			SET @var_referencefield = 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V';
			SET @var_countfield = 'ld_cashbill:total:hdnGrandTotal:CashBill_fieldlabel:N';
			SET @var_datefield = 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D';
			set @sys_count = (SELECT count(1) as sys_count from ld_systems_deploy where (deploy_type = '83' and deploy_value = 1) or ((deploy_type = '133' and deploy_value = 0)));
			IF @sys_count = 2 THEN
				SET @approvedemand = '1';
			ELSE
				SET @approvedemand = '0';
			END if;
			INSERT into ld_salestarget_detail(targetid,entitytype,referencefield,funname,countfield,datefield,approvedemand)
			VALUE(@new_target_id,@var_entitytype,@var_referencefield,@var_funname,@var_countfield,@var_datefield,@approvedemand);
			
			
			SET @targetname = 'contractamount';
			SET @zhlabel = '签约额';
			SET @enlabel = 'Contract Amount';
			SET @new_target_id = (SELECT id from ld_crmentity_seq)+1;
			UPDATE ld_crmentity_seq SET id = id+1;
			INSERT into ld_crmentity(crmid,setype) value(@new_target_id,@salesgoal_module);
			
			INSERT ld_salestarget_basic(targetid,targetname,zhlabel,enlabel,`status`,modulename,groupsetting,smownerid,smcreatorid,scope,sequence)
			SELECT @new_target_id,@targetname,@zhlabel,@enlabel,'yes','Users','noedit',1,1,'all',@sequence+2 from DUAL
			where NOT EXISTS(SELECT 1 from ld_salestarget_basic where targetname = @targetname);
			
			SET @new_target_id = (SELECT targetid from ld_salestarget_basic where targetname = @targetname);
			call create_viewvalue(@targetname,@new_target_id);
			DELETE from ld_salestarget_detail where targetid = @new_target_id;
			SET @var_entitytype = 'SalesOrder';
			SET @var_funname = 'sum';
			SET @var_referencefield = 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V';
			SET @var_countfield = 'ld_salesorder:total:hdnGrandTotal:SalesOrder_fieldlabel:N';
			SET @var_datefield = 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D';
			SET @approvedemand = '0';
			IF @var_accountversion = 'sczhongxing' THEN
				SET @othercondition = '{"advft_criteria":[{"groupid":"1","columnname":"ld_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V","comparator":"n","value":"已作废（Voided）","columncondition":""}],"advft_criteria_groups":[null,{"groupcondition":""}]}';
			ELSE
				SET @othercondition = '{"advft_criteria":[{"groupid":"1","columnname":"ld_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V","comparator":"n","value":"已作废","columncondition":""}],"advft_criteria_groups":[null,{"groupcondition":""}]}';
			END IF;
			INSERT into ld_salestarget_detail(targetid,entitytype,referencefield,funname,countfield,datefield,approvedemand,othercondition)
			VALUE(@new_target_id,@var_entitytype,@var_referencefield,@var_funname,@var_countfield,@var_datefield,@approvedemand,@othercondition);
			
			SET @var_entitytype = 'ServiceContracts';
			SET @var_funname = 'sum';
			SET @var_referencefield = 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V';
			SET @var_countfield = 'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_fieldlabel:N';
			SET @var_datefield = 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:V';
			SET @approvedemand = '0';
			INSERT into ld_salestarget_detail(targetid,entitytype,referencefield,funname,countfield,datefield,approvedemand)
			VALUE(@new_target_id,@var_entitytype,@var_referencefield,@var_funname,@var_countfield,@var_datefield,@approvedemand);
			
			
			SET @targetname = 'accountsnumber';
			SET @zhlabel = '客户数';
			SET @enlabel = 'Customer Number';
			SET @new_target_id = (SELECT id from ld_crmentity_seq)+1;
			UPDATE ld_crmentity_seq SET id = id+1;
			INSERT into ld_crmentity(crmid,setype) value(@new_target_id,@salesgoal_module);
			
			INSERT ld_salestarget_basic(targetid,targetname,zhlabel,enlabel,`status`,modulename,groupsetting,smownerid,smcreatorid,scope,sequence)
			SELECT @new_target_id,@targetname,@zhlabel,@enlabel,'yes','Users','noedit',1,1,'all',@sequence+3 from DUAL
			where NOT EXISTS(SELECT 1 from ld_salestarget_basic where targetname = @targetname);
			
			SET @new_target_id = (SELECT targetid from ld_salestarget_basic where targetname = @targetname);
			call create_viewvalue(@targetname,@new_target_id);
			DELETE from ld_salestarget_detail where targetid = @new_target_id;
			SET @var_entitytype = 'Accounts';
			SET @var_funname = 'count';
			SET @var_referencefield = 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V';
			SET @var_countfield = 'ld_account:accountname:accountname:Accounts_fieldlabel:V';
			SET @var_datefield = 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT';
			SET @approvedemand = '0';
			INSERT into ld_salestarget_detail(targetid,entitytype,referencefield,funname,countfield,datefield,approvedemand)
			VALUE(@new_target_id,@var_entitytype,@var_referencefield,@var_funname,@var_countfield,@var_datefield,@approvedemand);
			
			
			SET @targetname = 'invoiceamount';
			SET @zhlabel = '开票额';
			SET @enlabel = 'Invoice amount';
			SET @new_target_id = (SELECT id from ld_crmentity_seq)+1;
			UPDATE ld_crmentity_seq SET id = id+1;
			INSERT into ld_crmentity(crmid,setype) value(@new_target_id,@salesgoal_module);
			
			INSERT ld_salestarget_basic(targetid,targetname,zhlabel,enlabel,`status`,modulename,groupsetting,smownerid,smcreatorid,scope,sequence)
			SELECT @new_target_id,@targetname,@zhlabel,@enlabel,'yes','Users','noedit',1,1,'all',@sequence+4 from DUAL
			where NOT EXISTS(SELECT 1 from ld_salestarget_basic where targetname = @targetname);
			
			SET @new_target_id = (SELECT targetid from ld_salestarget_basic where targetname = @targetname);
			call create_viewvalue(@targetname,@new_target_id);
			DELETE from ld_salestarget_detail where targetid = @new_target_id;
			SET @var_entitytype = 'Invoice';
			SET @var_funname = 'sum';
			SET @var_referencefield = 'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V';
			SET @var_countfield = 'ld_invoice:total:hdnGrandTotal:Invoice_fieldlabel:N';
			SET @var_datefield = 'ld_invoice:invoicedate:invoicedate:Invoice_fieldlabel:D';
			SET @approvedemand = '0';
			INSERT into ld_salestarget_detail(targetid,entitytype,referencefield,funname,countfield,datefield,approvedemand)
			VALUE(@new_target_id,@var_entitytype,@var_referencefield,@var_funname,@var_countfield,@var_datefield,@approvedemand);
			
			
			SET @targetname = 'outboundorderamount';
			SET @zhlabel = '出库额';
			SET @enlabel = 'OutboundOrder amount';
			SET @new_target_id = (SELECT id from ld_crmentity_seq)+1;
			UPDATE ld_crmentity_seq SET id = id+1;
			INSERT into ld_crmentity(crmid,setype) value(@new_target_id,@salesgoal_module);
			
			INSERT ld_salestarget_basic(targetid,targetname,zhlabel,enlabel,`status`,modulename,groupsetting,smownerid,smcreatorid,scope,sequence)
			SELECT @new_target_id,@targetname,@zhlabel,@enlabel,'yes','Users','noedit',1,1,'all',@sequence+5 from DUAL
			where NOT EXISTS(SELECT 1 from ld_salestarget_basic where targetname = @targetname);
			
			SET @new_target_id = (SELECT targetid from ld_salestarget_basic where targetname = @targetname);
			call create_viewvalue(@targetname,@new_target_id);
			DELETE from ld_salestarget_detail where targetid = @new_target_id;
			SET @var_entitytype = 'OutboundOrder';
			SET @var_funname = 'sum';
			SET @var_referencefield = 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V';
			SET @var_countfield = 'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_fieldlabel:N';
			SET @var_datefield = 'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D';
			SET @approvedemand = '0';
			INSERT into ld_salestarget_detail(targetid,entitytype,referencefield,funname,countfield,datefield,approvedemand)
			VALUE(@new_target_id,@var_entitytype,@var_referencefield,@var_funname,@var_countfield,@var_datefield,@approvedemand);

			
			IF @var_accountversion = 'sh_qingke' THEN
				SET @targetname = 'receivableamount';
				SET @zhlabel = '应收额';
				SET @enlabel = 'Receivables';
				SET @new_target_id = (SELECT id from ld_crmentity_seq)+1;
				UPDATE ld_crmentity_seq SET id = id+1;
				INSERT into ld_crmentity(crmid,setype) value(@new_target_id,@salesgoal_module);
				
				INSERT ld_salestarget_basic(targetid,targetname,zhlabel,enlabel,`status`,modulename,groupsetting,smownerid,smcreatorid,scope,sequence)
				SELECT @new_target_id,@targetname,@zhlabel,@enlabel,'yes','Users','noedit',1,1,'all',@sequence+6 from DUAL
				where NOT EXISTS(SELECT 1 from ld_salestarget_basic where targetname = @targetname);
				
				SET @new_target_id = (SELECT targetid from ld_salestarget_basic where targetname = @targetname);
				call create_viewvalue(@targetname,@new_target_id);
				DELETE from ld_salestarget_detail where targetid = @new_target_id;
				SET @var_entitytype = 'CustomForm12';
				SET @var_funname = 'sum';
				SET @var_referencefield = 'ld_customform12:smownerid:assigned_user_id:CustomForm12_fieldlabel:V';
				SET @var_countfield = 'ld_customform12:total:hdnGrandTotal:CustomForm12_fieldlabel:N';
				SET @var_datefield = 'ld_customform12scf:cf_4425:cf_4425:CustomForm12_fieldlabel:D';
				SET @approvedemand = '0';
				INSERT into ld_salestarget_detail(targetid,entitytype,referencefield,funname,countfield,datefield,approvedemand)
				VALUE(@new_target_id,@var_entitytype,@var_referencefield,@var_funname,@var_countfield,@var_datefield,@approvedemand);
				
			END IF;

			UPDATE ld_salestarget_basic LEFT JOIN 
			(SELECT DISTINCT ld_salestarget_detail.targetid,'yes' from ld_salestarget_detail 
			INNER JOIN ld_tab on ld_tab.`name` = ld_salestarget_detail.entitytype
			where ld_tab.presence in (0,2)) as tmp on ld_salestarget_basic.targetid = tmp.targetid
			SET `status` = 'no' where IFNULL(tmp.targetid,0) = 0;
		END IF;
end ||
delimiter;

drop PROCEDURE if EXISTS create_viewvalue;
delimiter ||
create PROCEDURE create_viewvalue
(
var_targetname varchar(50),
var_targetid int(19)
)
BEGIN
		SET @querysql1 = CONCAT('SELECT userid,targetyear,targetmouth,',var_targetname,' as tmp_value from ld_salestarget');
		set @tmp_sql =CONCAT(' create view  v_test  as  ', @querysql1);
		DROP VIEW IF EXISTS v_test;
		PREPARE stmt FROM @tmp_sql;
		EXECUTE stmt;
		call transfer_targetvalue(var_targetid);
		SET @tabid = (SELECT tabid from ld_tab where `name` = 'SalesGoal');
		call add_SalesGoal_shareusers(@new_target_id,@tabid);
end ||
delimiter;

drop PROCEDURE if EXISTS transfer_targetvalue;
delimiter ||
create PROCEDURE transfer_targetvalue
(
var_targetid int(19)
)
BEGIN
		declare var_userid int(19);
		declare var_year int(19);
		declare var_month int(19);
		declare var_number decimal(25,2);
		declare done  int  default 0;
	
		declare cur1 CURSOR FOR SELECT userid,targetyear,targetmouth,tmp_value FROM v_test;
		declare continue handler  for not   found  SET done =1;

		open cur1;
		Fetch cur1 into var_userid,var_year,var_month,var_number;
		loop1: while  done<>1 DO
			IF var_number>0 THEN
				insert into ld_salestarget_info(targetid,record,type,targetyear,targetmonth,targetvalue)
				VALUE(var_targetid,var_userid,'Users',var_year,var_month,var_number);
			END IF;
		Fetch cur1 into var_userid,var_year,var_month,var_number;
		end while loop1;
		close cur1;
end ||
delimiter;

drop PROCEDURE if EXISTS add_SalesGoal_shareusers;
delimiter ||
create PROCEDURE add_SalesGoal_shareusers
(
var_targetid int(19),
var_tabid int(19)
)
BEGIN
		INSERT into ld_tabshare(crmid,viewuserid,Shareuserid)
		SELECT var_targetid,1,id from ld_users where profileid in 
		(SELECT profileid from ld_profile2standardpermissions where tabid = var_tabid and operation = 3);
end ||
delimiter;

CALL add_default_salestarget();
DROP VIEW IF EXISTS v_test;
DROP PROCEDURE if EXISTS add_default_salestarget;
DROP PROCEDURE if EXISTS transfer_targetvalue;
DROP PROCEDURE if EXISTS create_viewvalue;
DROP PROCEDURE if EXISTS add_SalesGoal_shareusers;
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'SalesGoal');
UPDATE ld_profileallpermission set sequence = 2 where tabid = @tabid AND operation = 4;
INSERT into ld_profileallpermission(tabid,operation,sequence) 
SELECT @tabid,11,3 from DUAL where NOT EXISTS 
(SELECT 1 from ld_profileallpermission where tabid = @tabid AND operation = 11);
UPDATE ld_profileallpermission set sequence = 4 where tabid = @tabid AND operation = 1;
INSERT into ld_profileallpermission(tabid,operation,sequence) 
SELECT @tabid,2,5 from DUAL where NOT EXISTS 
(SELECT 1 from ld_profileallpermission where tabid = @tabid AND operation = 2);
INSERT into ld_profileallpermission(tabid,operation,sequence) 
SELECT @tabid,13,6 from DUAL where NOT EXISTS 
(SELECT 1 from ld_profileallpermission where tabid = @tabid AND operation = 13);
INSERT into ld_profileallpermission(tabid,operation,sequence) 
SELECT @tabid,14,7 from DUAL where NOT EXISTS 
(SELECT 1 from ld_profileallpermission where tabid = @tabid AND operation = 14);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'SalesGoal');
SET @operation = 11;
INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
SELECT profileid,@tabid,@operation,0 from ld_profile2standardpermissions
where tabid = @tabid and operation = 1 AND permissions = 0
AND NOT EXISTS(SELECT 1 from ld_profile2standardpermissions where tabid = @tabid and operation = @operation);
SET @operation = 13;
INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
SELECT profileid,@tabid,@operation,0 from ld_profile2standardpermissions
where tabid = @tabid and operation = 1 AND permissions = 0
AND NOT EXISTS(SELECT 1 from ld_profile2standardpermissions where tabid = @tabid and operation = @operation);
SET @operation = 14;
INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
SELECT profileid,@tabid,@operation,0 from ld_profile2standardpermissions
where tabid = @tabid and operation = 1 AND permissions = 0
AND NOT EXISTS(SELECT 1 from ld_profile2standardpermissions where tabid = @tabid and operation = @operation);
delimiter;

SET @labelbol = 'GROUPTOTALNOTALLOWEDIT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按部门小计不可修改','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Subtotal by department cannot be modified','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'GROUPTOTALALLOWEDIT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按部门小计可修改','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Subtotal by department can be modified','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INDICATORSNAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'指标名称','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Indicators name','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INDICATORSOBJECT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'指标对象','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Indicators object','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SECTORINDICATORS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'部门指标','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sector indicators','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TARGETDETAILS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'目标详情','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Target details','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INDICATORSMODULENAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'指标模块','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Indicators modulename','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OBJECTQUERYFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'对象查询字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Object Query Field','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TIMEQUERYFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'时间查询字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Time Query Field','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMPUTINGMETHOD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'计算方法','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'computing method','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'STATISTICALFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'统计字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Statistical field','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DOCUMENTHEADERFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据头字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Document header field','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TARGETRANGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'目标范围','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Target range','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CREATEINDICATORS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新建指标','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Create indicators','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MANAGEINDICATORS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'管理指标','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Manage indicators','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NUMUNIT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'数量单位：个','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Quantity unit: piece','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UNABLETOVIEWTARGETDETAILS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'无法查看目标详情，可能缺少模块或字段权限，请联系管理员！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Unable to view target details, may lack module or field permissions. Please contact the administrato!','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'INDICATORDELETEREMIND';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'指标删除后,设定的目标信息也会删除。是否继续?','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After the indicator is deleted, the set target information will also be deleted. Do you want to continue?','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'OTHERCONDITIONSJS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'其他条件','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Other conditions','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'OBJECTVIEW_LOOK';
UPDATE ld_desk SET fieldlabel = '完成情况统计表' where labelbol = @labelbol AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Completion Statistics Table' where labelbol = @labelbol AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HOMEBOARDDUPLICATE','该数据看板名称重复，请重新设置！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='HOMEBOARDDUPLICATE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HOMEBOARDDUPLICATE','The data kanban name is duplicate, please reset it!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='HOMEBOARDDUPLICATE' and Labeltype='jspop' and languagetype='en');
delimiter;

SET @labelbol = 'SEARCHLOCATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索地点','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search location','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2023-04-11


update ld_field set typeofdata='N~O' where fieldname='procostprice' and tabid=14;
delimiter;

ALTER TABLE ld_salesorder
    MODIFY COLUMN `haveoutboundcount` decimal(25, 6) NULL DEFAULT 0.00 AFTER `lastoutbounddate`,
    MODIFY COLUMN `balanceoutboundcount` decimal(25, 6) NULL DEFAULT 0.00 AFTER `haveoutboundcount`;
delimiter;

ALTER TABLE ld_servicecontracts
    MODIFY COLUMN `haveoutboundcount` decimal(25, 6) NULL DEFAULT 0.00 AFTER `lastoutbounddate`,
    MODIFY COLUMN `balanceoutboundcount` decimal(25, 6) NULL DEFAULT 0.00 AFTER `haveoutboundcount`;
delimiter;

update ld_field set typeofdata = 'NN~O~25,4' where  columnname in ('haveoutboundcount','balanceoutboundcount') and uitype = 7;
delimiter;
-- 2023-04-12

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

UPDATE ld_version SET old_version='V8.4.9.6',current_version='V8.4.9.6',remark='V8.4.9.6-20230412',wx_version='V8.4.9.6';
delimiter;