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

call AddColumn('ld_communicationaccount','marketing','varchar','20',NULL);
update ld_communicationaccount set marketing = '411623' where marketing is NULL;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','selectothercontacts',"选择其他联系人",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='selectothercontacts' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','selectothercontacts',"select other contacts",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='selectothercontacts' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','setmailformat',"设定邮件格式",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='setmailformat' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','setmailformat',"Set mail format",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='setmailformat' and Labeltype='fixedstr');
delimiter;

insert into ld_sendinformcontent(content,type,description)
select '您的【[var.troubletickets_account_id_HelpDesk]】已分配给【[var.troubletickets_assigned_user_id_HelpDesk]】为您服务！
联系电话：[var.users_phone_mobile_Users]',13,'您的【[var.troubletickets_account_id_HelpDesk]】已分配给【[var.troubletickets_assigned_user_id_HelpDesk]】为您服务！' from DUAL
where not exists(select 1 from ld_sendinformcontent where type = 13);
delimiter;

update ld_tranlabel set fieldlabel = '{$HelpDesk.HelpDesk}分配时是否发送短信或邮件通知{$HelpDesk.HelpDesk}联系人' 
where tabid = 167 and Relateid = 167 and languagetype = 'zh' and trantable = 'ld_systems_deploy';
update ld_tranlabel set fieldlabel = 'Do you send SMS or email to the {$HelpDesk.HelpDesk} contacts when {$HelpDesk.HelpDesk} list is allocated?' 
where tabid = 167 and Relateid = 167 and languagetype = 'en' and trantable = 'ld_systems_deploy';
delimiter;

update ld_desk set fieldlabel='Contract' where languagetype='en' and Labeltype='fixedstr' and labelbol='transaction';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','cannotbelessthan1',"不能小于",'jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='cannotbelessthan1' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','cannotbelessthan1',"Cannot be less than",'jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='cannotbelessthan1' and Labeltype='jspop');
delimiter;

CREATE TABLE if not exists `ld_productstrategy` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `productid` int(19) DEFAULT NULL,
  `count_from` decimal(25,8) DEFAULT NULL,
  `count_to` decimal(25,8) DEFAULT NULL,
  `type` int(4) DEFAULT NULL COMMENT '1,2,3固定基数，固定增量',
  `userid` int(19) DEFAULT NULL,
		`money` decimal(25,2) ,
  PRIMARY KEY (`id`),
  KEY `idx_strategy_product_type` (`productid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_products','havepricestrategy','varchar',25,'no' );
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGY','价格策略','fixedstr' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGY' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGY','Price strategy','fixedstr'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGY' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYTYPE1','固定基数','fixedstr' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYTYPE1' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYTYPE1','Fixed basic number','fixedstr'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYTYPE1' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYTYPE2','固定增量','fixedstr' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYTYPE2' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYTYPE2','Fixed increment','fixedstr'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYTYPE2' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYTYPE3','阶梯增量','fixedstr' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYTYPE3' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYTYPE3','Step increment','fixedstr'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYTYPE3' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYFROM','从','fixedstr' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYFROM' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYFROM','From','fixedstr'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYFROM' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYTO','到','fixedstr' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYTO' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYTO','To','fixedstr'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYTO' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYADDFIX','新增基数','fixedstr' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYADDFIX' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYADDFIX','Add fixed basic number','fixedstr'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYADDFIX' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYADDINCREMENT','新增增量','fixedstr' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYADDINCREMENT' and Labeltype='fixedstr');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYADDINCREMENT','Add incremental','fixedstr'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYADDINCREMENT' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYREMIND1','当前数字应大于起始数字','jspop' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYREMIND1' and Labeltype='jspop');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYREMIND1','The current number should be greater than the initial number','jspop'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYREMIND1' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYREMIND2','当前数字应大于前一行最大数字','jspop' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYREMIND2' and Labeltype='jspop');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYREMIND2','The current number should be larger than the maximum number in the previous line','jspop'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYREMIND2' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRICESTRATEGYREMIND3','当前金额应不小于前一行金额','jspop' from dual where
    not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRICESTRATEGYREMIND3' and Labeltype='jspop');

insert into ld_desk(languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRICESTRATEGYREMIND3','The current amount should be greater than the previous line amount','jspop'
  from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRICESTRATEGYREMIND3' and Labeltype='jspop');

select max(actionid) into @max_actionid from ld_actionmapping ;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
  select  @max_actionid+1,'price_strategy',0,'PRICESTRATEGY' from dual
  where not exists(select 1 from ld_actionmapping where   actionname='price_strategy');

select actionid into @actionid from ld_actionmapping where actionname='price_strategy';
select tabid into @tabid from ld_tab where name='Products';
select max(sequence) into @max_seq from ld_profileallpermission where tabid=@tabid;

insert into ld_profileallpermission(tabid,operation,sequence)
  select @tabid,@actionid,@max_seq+1 from dual where not exists(
      select 1 from ld_profileallpermission  where tabid=@tabid and operation=@actionid);

insert into  ld_profile2standardpermissions (profileid,tabid,operation,permissions,sequence)
  select profileid ,@tabid ,@actionid,0,22  from ld_profile
  where not exists(select 1 from ld_profile2standardpermissions where operation=@actionid and tabid=@tabid);
delimiter;

update ld_desk set fieldlabel='当前数字应大于等于起始数字'
where labelbol='PRICESTRATEGYREMIND1' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='The current number should be greater than or equal to the starting number'
where labelbol='PRICESTRATEGYREMIND1' and languagetype='en' and Labeltype='jspop';
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_OTHER_SETTINGS';
select max(sequence) into @maxsequence from ld_settings_field where blockid=@blockid;
select max(fieldid)into @maxfieldid  from ld_settings_field ;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @maxfieldid+1,@blockid,'LBL_AUTHENINFO','','LBL_AUTHENINFO','index.php?action=isReg',@maxsequence+1,0 from dual 
where not EXISTS(select 1 from ld_settings_field where blockid=@blockid and  name='LBL_AUTHENINFO');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_AUTHENINFO','Authorization Information','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='lbl_autheninfo' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_AUTHENINFO','授权信息','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='lbl_autheninfo' and labeltype='fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBI_UI_SETTINGS';
select max(sequence) into @maxsequence from ld_settings_field where blockid=@blockid;
select max(fieldid)into @maxfieldid  from ld_settings_field ;
insert into ld_settings_field(fieldid, blockid,name,iconpath,description,linkto,sequence,active)
select @maxfieldid+1, @blockid,'LBL_LOGIN_SETTINGS','','登录界面设置','index.php?module=Settings&action=LoginSettings&parenttab=Settings',@maxsequence+1,0 from dual 
where not EXISTS(select 1 from ld_settings_field where blockid=@blockid and name='LBL_LOGIN_SETTINGS');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_LOGIN_SETTINGS','Login setting','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_LOGIN_SETTINGS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_LOGIN_SETTINGS','登录界面设置','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_LOGIN_SETTINGS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITCONTENT','修改内容','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EDITCONTENT' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITCONTENT','Edit content','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EDITCONTENT' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CORRESPONDINGCONTENT','对应内容','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CORRESPONDINGCONTENT' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CORRESPONDINGCONTENT','Corresponding content','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CORRESPONDINGCONTENT' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_salesorder','imagename','varchar',200,null );
delimiter;
-- 2018-10-26

select tabid into @tabid from ld_tab where name='Singin';
select fieldid into @record from ld_field where tabid=@tabid and columnname='record';
select fieldid into @address from ld_field where tabid=@tabid and columnname='address';
update ld_related_field set fromvalue_info='select CONCAT(ld_account.bill_state,ld_account.bill_city, ld_account.bill_street) as address
from ld_account
where ld_account.deleted = 0 and accountid = ?
UNION select CONCAT(ld_account.bill_state,ld_account.bill_city, ld_account.bill_street) as address
      from ld_contactdetails
        INNER JOIN ld_account on ld_account.accountid = ld_contactdetails.accountid
      where ld_account.deleted = 0 and ld_contactdetails.contactid = ?
UNION select CONCAT(ld_account.bill_state,ld_account.bill_city, ld_account.bill_street) as address
      from ld_contactrecords
        INNER JOIN ld_account on ld_account.accountid = ld_contactrecords.accountid
      where ld_account.deleted = 0 and ld_contactrecords.contactrecordID = ?
UNION select CONCAT(ld_account.bill_state,ld_account.bill_city, ld_account.bill_street) as address
      from ld_potential
        INNER JOIN ld_account on ld_account.accountid = ld_potential.accountid
      where ld_account.deleted = 0 and ld_potential.potentialid = ?
UNION select CONCAT(ld_account.bill_state,ld_account.bill_city, ld_account.bill_street) as address
      from ld_project
        INNER JOIN ld_account on ld_account.accountid = ld_project.accountid
      where ld_account.deleted = 0 and ld_project.projectid = ?' 
where trigger_fieldid=@record and effect_fieldid=@address;
delimiter;

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

update ld_version set old_version='V7.5.5',current_version='V7.5.5',remark='V7.5.5-20181028',wx_version='V7.5.5';
delimiter;