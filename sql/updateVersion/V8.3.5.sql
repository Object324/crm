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

UPDATE ld_tabwithproductview SET `columns`=REPLACE(`columns`,'absamount','cf_1317') WHERE `columns` LIKE '%absamount:cf_1317%' AND tabid=2;

SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms' LIMIT 1);
SET @min_zhid=(SELECT MIN(tranlabelid) FROM ld_tranlabel WHERE Relateid=@myparenttabid AND trantable='ld_parenttab' AND languagetype='zh');
SET @min_enid=(SELECT MIN(tranlabelid) FROM ld_tranlabel WHERE Relateid=@myparenttabid AND trantable='ld_parenttab' AND languagetype='en');
DELETE FROM ld_tranlabel WHERE Relateid=@myparenttabid AND trantable='ld_parenttab' AND languagetype='zh' AND tranlabelid>@min_zhid;
DELETE FROM ld_tranlabel WHERE Relateid=@myparenttabid AND trantable='ld_parenttab' AND languagetype='en' AND tranlabelid>@min_enid;
delimiter;
-- 2020-12-09

update ld_dashboard_app set home_presence='no' WHERE  NAME='InventoryQuery';
delimiter;

update ld_desk set fieldlabel = '启用公海' where languagetype = 'zh' and labelbol = 'ACTIVATEPUBLICCUST' and labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Highseasparametersetting','公海参数设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Highseasparametersetting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Highseasparametersetting','Public account parameter setting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Highseasparametersetting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Showtheallincludeunassignedtab','显示 “全部（含所有公海）”页签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Showtheallincludeunassignedtab' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Showtheallincludeunassignedtab','Show the all include unassigned tab','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Showtheallincludeunassignedtab' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','theallincludeunassignedpool','全部（含所有公海）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='theallincludeunassignedpool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','theallincludeunassignedpool','the all include unassigned pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='theallincludeunassignedpool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Setthedefaulttabasallincludeunassigned','默认 “全部（含所有公海）”页签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Setthedefaulttabasallincludeunassigned' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Setthedefaulttabasallincludeunassigned','Set the default tab as all include unassigned','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Setthedefaulttabasallincludeunassigned' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thedefaultallincludeunassigned','全部（含指定公海）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='thedefaultallincludeunassigned' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thedefaultallincludeunassigned','the default all include unassigned','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='thedefaultallincludeunassigned' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Highseassuperadministratorsettings','公海超级管理员设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Highseassuperadministratorsettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Highseassuperadministratorsettings','High seas super administrator settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Highseassuperadministratorsettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleasesettheadministrators','选择公海超级管理员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesettheadministrators' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleasesettheadministrators','Please set the administrators','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesettheadministrators' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Createandmaintainmultiplehighseaspool','说明：建立多个公海，对多个公海进行维护：设置每个公海允许保有客户的上限、回收条件、指定公海管理员和公海成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Createandmaintainmultiplehighseaspool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Createandmaintainmultiplehighseaspool','Description: Create and maintain multiple high seas pool. Set the upper limit for each high seas, recovery conditions, designate the mangers and members.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Createandmaintainmultiplehighseaspool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleasesettheadministratorsjspop','请选择公海超级管理员','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesettheadministratorsjspop' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleasesettheadministratorsjspop','Please set the administrators','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesettheadministratorsjspop' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','createpublicaccountpool','新建公海','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='createpublicaccountpool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','createpublicaccountpool','create public account pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='createpublicaccountpool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Name(ZH)','公海名称（中）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Name(ZH)' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Name(ZH)','Name(ZH)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Name(ZH)' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Name(EN)','公海名称（英）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Name(EN)' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Name(EN)','Name(EN)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Name(EN)' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Mangers','公海管理员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Mangers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Mangers','Mangers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Mangers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Members','公海成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Members' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Members','Members','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Members' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Businessrules','业务规则','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Businessrules' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Businessrules','Business rules','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Businessrules' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel = '不允许领取公海未分配客户，只能由公海管理员分配' where labelbol = 'UNALLOCATECUSTOMERADMIN' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '不控制公海未分配客户的数据权限，允许查询所有公海未分配客户' where labelbol = 'CUSTOMERCONTROLPUBLIC' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allowtheunallocatedcustomerstobedisplayedinalllist','允许公海未分配客户显示在“全部（含指定公海）”列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allowtheunallocatedcustomerstobedisplayedinalllist' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allowtheunallocatedcustomerstobedisplayedinalllist','Allow the unallocated customers to be displayed in "all" list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allowtheunallocatedcustomerstobedisplayedinalllist' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allowtheallocatedcustomerstobedisplayedinalllist','允许公海已分配客户显示在“全部（含指定公海）”列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allowtheallocatedcustomerstobedisplayedinalllist' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allowtheallocatedcustomerstobedisplayedinalllist','Allow the allocated customers to be displayed in "all" list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allowtheallocatedcustomerstobedisplayedinalllist' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allowuserstotransfertheallocatedcustomerstootherseas','允许公海成员将已分配或领取的公海客户转移到其他公海','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allowuserstotransfertheallocatedcustomerstootherseas' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allowuserstotransfertheallocatedcustomerstootherseas','Allow users to transfer the allocated customers to other seas','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allowuserstotransfertheallocatedcustomerstootherseas' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel = '客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）' where labelbol = 'AFTERCONVERTINGMODIFYTHEOWNER' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = ' 公海成员客户序时簿“新建”功能下拉选项' where labelbol = 'NEWBUTTONDROPDOWNOPTIONS' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleasesetuphighseasmemberfirst','请先设置公海成员！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesetuphighseasmemberfirst' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleasesetuphighseasmemberfirst','Please set up high seas member first!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesetuphighseasmemberfirst' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ObjtainAccountControlDays1','{$Accounts.Accounts}被自动回收后','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ObjtainAccountControlDays1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ObjtainAccountControlDays1','{$Accounts.Accounts} after being automatically recycled','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ObjtainAccountControlDays1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ObjtainAccountControlDays2','天内不允许被当前{$Accounts.assigned_user_id}再次领取（为0或空表示不控制）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ObjtainAccountControlDays2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ObjtainAccountControlDays2','cannot be current for days{$Accounts.assigned_user_id} claim again (0 or empty means no control)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ObjtainAccountControlDays2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_account_set_rule','pool_id','int','11',0);
delimiter;

call AddColumn('ld_account_set_advfilter','pool_id','int','11',0);
delimiter;

call AddColumn('ld_account_set_advfilter_grouping','pool_id','int','11',0);
delimiter;

call DelPrikey('ld_account_set_advfilter_grouping');
delimiter;

SET @modulename='Accounts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'publicaccount' and tabid = @tabid);
SET @maxseq=(select sequence from ld_field where columnname = 'publicaccount' and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_account';
SET @columnname='pool_id';
SET @fieldname='pool_id';
SET @zh='所属公海';
SET @en='High seas';
SET @uitype=302;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @relateid and sequence >= @maxseq;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid and block = @relateid order by sequence;
delimiter;

call AddColumn('ld_account','pool_id','int','11',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Thishighseaswasfounded','本公海创建于 %s 共有公海客户 %s 个；已认领%s个/未认领%s个；认领上限%s个 / 已领%s个； 公海管理员：%s','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Thishighseaswasfounded' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Thishighseaswasfounded','This high seas was founded in %s The total customers is %s, assigned %s/ unassigned %s, toplimit %s/used %s.  Manager: %s','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Thishighseaswasfounded' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ModifyParameters','修改公海配置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ModifyParameters' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ModifyParameters','Modify Parameters','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ModifyParameters' and Labeltype='fixedstr' and languagetype='en');
delimiter;

select fieldid into @fieldid from ld_field where fieldname = 'publicaccount' and tabid = 6;
update ld_tranlabel set fieldlabel = '公海状态' where languagetype = 'zh' and tabid = 6 and Relateid = @fieldid and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = 'Unassigned Status' where languagetype = 'en' and tabid = 6 and Relateid = @fieldid and trantable = 'ld_field';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Transfer','转换公海','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Transfer' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Transfer','Transfer','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Transfer' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Transfertothehighseas','转移到公海','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Transfertothehighseas' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Transfertothehighseas','Transfer to the high seas','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Transfertothehighseas' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Transferoutofthehighseas','转移出公海（转为普通客户）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Transferoutofthehighseas' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Transferoutofthehighseas','Transfer out of the high seas','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Transferoutofthehighseas' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleaseselectatleastonehighseas','请至少选择一个公海！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleaseselectatleastonehighseas' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleaseselectatleastonehighseas','Please select at least one high seas!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleaseselectatleastonehighseas' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOTHEHIGNSEASCUSTOMERERROR1','单据[%s]转为公海客户失败，原因：已超出转换公海负责人的保有数量！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TOTHEHIGNSEASCUSTOMERERROR1' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOTHEHIGNSEASCUSTOMERERROR1','Please select at least one high seas!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TOTHEHIGNSEASCUSTOMERERROR1' and Labeltype='jspop' and languagetype='en');
delimiter;

set @tabid = (SELECT tabid from ld_tab where name ='Accounts');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists) +1;
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid;
set @statu = (select IFNULL(`status`,1) from ld_account_set);

INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`)
SELECT @relation_id, @tabid, -302, 'get_publicaccount', 0, 'publicaccount_log', @statu, '', @statu, 0, NULL, NULL, 0, 0, NULL, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=-302);
UPDATE ld_relatedlists_seq set id =(SELECT MAX(relation_id) FROM ld_relatedlists);
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_account_public` (
  `status` varchar(20) NOT NULL DEFAULT 'no',
  `show_publicaccount_tab` varchar(20) DEFAULT 'yes',
  `default_publicaccount_tab` varchar(20) DEFAULT 'no',
  `administrators` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_account_public_pool` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zh_name` varchar(200) DEFAULT NULL COMMENT '公海名称中文',
  `en_name` varchar(200) DEFAULT NULL COMMENT '公海名称英文',
  `limit_count` int(11) DEFAULT NULL COMMENT '公海已分配客户上线',
  `limit_type` varchar(20) DEFAULT NULL COMMENT '公海已分配上线 1按成员 2按角色',
  `administrators` text COMMENT '公海管理员',
  `userids` text COMMENT '公海成员',
  `usertype` varchar(100) DEFAULT NULL COMMENT '公海成员类型 all所有 group 部门 user 用户',
  `dataprofile` varchar(20) DEFAULT NULL COMMENT '公海未分配客户不控制数据权限（可查询所有公海未分配客户）',
  `allowget` varchar(20) DEFAULT NULL COMMENT '不允许领取公海未分配客户，只能由公海管理员分配',
  `allow_unallocated_showinall` varchar(20) DEFAULT 'no' COMMENT ' 允许公海未分配客户显示在“全部（含指定公海）”列表 ',
  `allow_allocated_showinall` varchar(20) DEFAULT 'no' COMMENT ' 允许公海已分配客户显示在“全部（含指定公海）”列表 ',
  `allow_trasnfer_others` varchar(20) DEFAULT 'no' COMMENT ' 允许公海成员将已分配或领取的公海客户转移到其他公海 ',
  `userid_after_transfer` int(11) DEFAULT NULL COMMENT ' 客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）',
  `userid_after_release` int(11) DEFAULT NULL COMMENT ' 公海已分配客户释放后，更改客户负责人为（为空表示不更改）',
  `create_buttons` varchar(200) DEFAULT NULL COMMENT ' 公海成员客户序时簿“新建”功能下拉选项',
  `recycleselect` text COMMENT '回收条件sql',
  `beforereminddays` varchar(10) DEFAULT NULL COMMENT ' 客户回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒） ',
  `objtainaccountcontroldays` varchar(10) DEFAULT NULL COMMENT '客户被自动回收后天内不允许被当前销售负责人再次领取（为0或空表示不控制） ',
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `smcreatorid` int(11) DEFAULT NULL,
  `modifiedby` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_account_public_pool__id` (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_account_role_limitcount` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pool_id` int(11) NOT NULL,
  `roleid` int(11) DEFAULT NULL,
  `limit_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_account_role_limitcount_poolid` (`pool_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_customview','pool_id','int','11',0);
delimiter;

call AddColumn('ld_logpublicaccount','pool_id','int','11',0);
delimiter;

update ld_account_set_rule set pool_id = 1 where pool_id = 0;
delimiter;

select count(1) into @cnt from ld_account_public;
insert into ld_account_public(`status`,show_publicaccount_tab,default_publicaccount_tab,administrators)
select if(`status` = 0,'yes','no'),'yes','no',1 from ld_account_set where `status` = 0 and @cnt = 0;
delimiter;

select count(1) into @cnt from ld_account_public_pool;
insert into ld_account_public_pool(zh_name,en_name,limit_count,limit_type,administrators,userids,usertype,dataprofile,allowget,allow_unallocated_showinall,allow_allocated_showinall,allow_trasnfer_others,userid_after_transfer,userid_after_release,create_buttons,recycleselect,beforereminddays,objtainaccountcontroldays,createdtime,smcreatorid) 
select '旧公海','High seas',count,if(astricttype=1,'user','role'),adminaccount,usersaccount,usersaccount_type,if(dataprofile=0,'yes','no'),if(getprofile=0,'yes','no'),'yes','yes','yes',userid,allotaccount,case when buttontype = '1' then 'COMMONACCOUNT' when buttontype = '2' then 'NOALLOCATE' when buttontype = '3' then 'PUBLICALLOCATE' when buttontype = '1,2' then 'COMMONACCOUNT,NOALLOCATE' when buttontype = '2,3' then 'NOALLOCATE,PUBLICALLOCATE' when buttontype = '1,3' then 'COMMONACCOUNT,PUBLICALLOCATE' when buttontype = '1,2,3' then 'COMMONACCOUNT,NOALLOCATE,PUBLICALLOCATE' else '' END,recycleselect,beforereminddays,objtainaccountcontroldays,now(),1 from ld_account_set where `status` = 0 and @cnt = 0;
delimiter;

set @_status = (select IFNULL(`status`,1) from ld_account_set);
select count(1) into @cnt from ld_account_role_limitcount;
insert into ld_account_role_limitcount(pool_id,roleid,limit_count)
select 1,roleid,astrictcount from ld_role_astrictcount where @_status = 0 and @cnt = 0;
delimiter;

set @_status = (select IFNULL(`status`,1) from ld_account_set);
update ld_account_set_advfilter set pool_id = 1 where pool_id = 0 and @_status = 0;
update ld_account_set_advfilter_grouping set pool_id = 1 where pool_id = 0 and @_status = 0;
delimiter;

set @_status = (select IFNULL(`status`,1) from ld_account_set);
update ld_account set pool_id = 1 where publicaccount >=1 and pool_id = 0 and @_status = 0;
delimiter;

set @_status = (select IFNULL(`status`,1) from ld_account_set);
update ld_customview set pool_id = 1 where entitytype = 'Accounts' and customcategory in ('PUBLICALLOCATE','NOALLOCATE') and pool_id = 0 and @_status = 0;
delimiter;

update ld_account_set set `status` = 1;
delimiter;

DROP PROCEDURE IF EXISTS `execute_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `execute_account_publicoperation`()
BEGIN

	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_account_public_pool;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
		Fetch cur1 into tmp_pool_id;
			loop1: while  done<>1 DO
				UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicaccount';	
				call account_singlerecycle_normal_rule(tmp_pool_id);
				call account_singlerecycle_highsea_rule(tmp_pool_id);
				call account_singlerecycle_normal_rule_beforeremind(tmp_pool_id);
				call account_singlerecycle_highsea_rule_beforeremind(tmp_pool_id);
		Fetch cur1 into tmp_pool_id;
	end while loop1;
	close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule`(IN tmp_pool_id INT(11))
BEGIN
	
	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
  DECLARE var_smownercolumn varchar(50);
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
   
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

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		 
		  if var_iscycle ='yes' then 
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
			else
				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			 end if;
      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				
				if var_iscycle='yes' then 
					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
				else
						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
			   end if;

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then
				 
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
				end if;
		else
			 if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
			
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;

	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
		end if;

     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();


		if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
			
		      if @recycleselect<>'' and @recycleselect is not null THEN	
						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
					end if;	
				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
  
					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) and ld_account.pool_id = ',tmp_pool_id);
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				  end if;
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) and ld_account.pool_id = ',tmp_pool_id);
					
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;


end ||
delimiter;


DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule`(IN tmp_pool_id INT(11))
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
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
			end if;	
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

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
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		 end if;

		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

		

end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`(IN tmp_pool_id INT(11))
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
 
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
   
	select beforereminddays into @var_beforereminddays from ld_account_public_pool where id = tmp_pool_id;
  if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
   set @maxdays=@maxdays-@var_beforereminddays;
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
			 set var_days=var_days-@var_beforereminddays;
			if var_days<=0 THEN
				leave loop1;
		   end if;
		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		 
		  if var_iscycle ='yes' then 
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
			else
				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			 end if;
             
           set @tmpsqltwo=concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime , '",var_tabname,"' as remindtabname from ld_account LEFT JOIN (select ld_account.accountid from ld_account inner join ",var_tablename,' on ld_account.accountid=',
                var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ," select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account inner join "  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				
				if var_iscycle='yes' then 
					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
				else
						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
			   end if;

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
			set @len=CHAR_LENGTH(' union all ');
			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
			
			if var_condition='or'  then
				 set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.status='active' and ld_account_set_rule.status='active' ORDER BY ld_account_set_rule.sequence asc ) ";

				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				if @recycleselect<>'' and @recycleselect is not null THEN	
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
				end if;	
				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) and ld_account.pool_id = ',tmp_pool_id  );
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
					end if;
				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
				
		  else
				if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
				end if;
			
				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) and ld_account.pool_id = ',tmp_pool_id,'group by ld_account.smownerid'  );
			end if;

	 	delete from ld_publicaccount_remindtableview ;
		 set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
			prepare stmt from @tmpthree;
			execute stmt;
			deallocate prepare stmt;

			call crm_publicaccount_beforereminds();
	 end if;


end ||
delimiter;


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

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
  select beforereminddays into @var_beforereminddays from ld_account_set;



 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
  select userid_after_release into @allotaccount from ld_account_public_pool where id = tmp_pool_id;
	select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;
	set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;
			
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
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
			Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.`status`='active' ORDER BY ld_account_set_rule.sequence asc ) ";

			 set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
				end if;
				
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'  group by ld_account.smownerid    ');
		end if;
		delete from ld_publicaccount_remindtableview ;
        set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

        call crm_publicaccount_beforereminds();
	end if;
end ||
delimiter;

update ld_settings_field set active = 1 where `name` = 'LBL_ACCOUNT_SET';
delimiter;



update ld_desk set fieldlabel="只统计审批通过的{$ServiceContracts.ServiceContracts}和{$SalesOrder.SalesOrder}" where
			labelbol = 'onlyshowapprovecontactandservice'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh';

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'onlyshowapproveorder', '只统计审批通过的{$SalesOrder.SalesOrder}', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'onlyshowapproveorder' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
   );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CARDQRCODEELECTRIC','电子名片','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CARDQRCODEELECTRIC' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CARDQRCODEELECTRIC','card applet','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CARDQRCODEELECTRIC' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel = '选择公海管理员' where languagetype = 'zh' and labelbol = 'Pleasesettheadministrators' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '请选择公海管理员' where languagetype = 'zh' and labelbol = 'Pleasesettheadministratorsjspop' and Labeltype = 'jspop';
delimiter;

delete from ld_settings_field where `name` = 'LBL_ACCOUNT_SET';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleasesettheadministratorsjspop1','请选择公海超级管理员','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesettheadministratorsjspop1' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleasesettheadministratorsjspop1','Please set the administrators','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesettheadministratorsjspop1' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleasesettheadministratorsjspop1','请选择公海超级管理员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesettheadministratorsjspop1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleasesettheadministratorsjspop1','Please set the administrators','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Pleasesettheadministratorsjspop1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @modulename='Users';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='last_name' LIMIT 1);
set @maxseq = IFNULL((SELECT sequence FROM ld_field WHERE tablename="ld_users" and columnname="last_name"),0);
select @maxseq;
update ld_field set sequence=sequence+1 where sequence>@maxseq;
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='last_name' LIMIT 1);
SET @columnname='real_name';
SET @fieldname='real_name';
SET @zh='真实姓名';
SET @en='real name';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='text';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,1,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

update ld_desk set fieldlabel = '公海日志' where labelbol = 'RECORDSOFOPERATION' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_account_public_pool SET createdtime=IFNULL((SELECT MIN(createdtime) FROM ld_account),NOW()) WHERE zh_name='旧公海';
UPDATE ld_account_public_pool SET administrators=(SELECT GROUP_CONCAT(id) FROM ld_users WHERE deleted=0 AND `status`='Active' AND is_admin='on') WHERE zh_name='旧公海' AND administrators IS NULL;
-- 2020-12-11

CALL AddColumn ('ld_users', 'real_name', 'varchar', '255', '' );
delimiter;


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

UPDATE ld_version SET old_version='V8.3.5',current_version='V8.3.5',remark='V8.3.5-20201211',wx_version='V8.3.5';
delimiter;