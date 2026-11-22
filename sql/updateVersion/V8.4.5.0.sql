update  ld_business_backfillfield set tianyanchalabel = 'trade'
where  tianyanchalabel='industry'
and not EXISTS(select * from ld_desk  where  labelbol='trade') ;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','trade','行业','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='trade' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','trade','Industry','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='trade' and labeltype='fixedstr');
delimiter;

delete from ld_business_backfillfield  where tianyanchalabel='industry';
delimiter; 
-- 2021-09-17

update  ld_business_backfillfield set tianyanchalabel = 'trade'
where  tianyanchalabel='industry'
and not EXISTS(select * from ld_desk  where  labelbol='trade') ;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','trade','行业','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='trade' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','trade','Industry','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='trade' and labeltype='fixedstr');
delimiter;

delete from ld_business_backfillfield  where tianyanchalabel='industry';
delimiter; 

create table if not exists `ld_customtable_module` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`report_id` int(11) DEFAULT NULL COMMENT "报表ID ",
	`tabid` int(11) DEFAULT NULL COMMENT "模块ID ",
	`modulename` varchar(255) DEFAULT NULL COMMENT "模块名称 ",
	`parent_id` int(11) DEFAULT NULL COMMENT "上级模块ID =0是主模块 ",
	PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
delimiter;


create table if not exists `ld_customtable` (
  `report_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT "报表ID ",
  `report_name` varchar(255) DEFAULT NULL COMMENT "报表名称 ",
  `parent_id` int(11) DEFAULT NULL COMMENT "所属文件夹ID ",
  `description` text COMMENT "报表描述 ",
  `sequence` int(4) DEFAULT NULL COMMENT "排序 ",
  `linkmodulecheck` varchar(20) DEFAULT NULL COMMENT "是否设置为链接模块 yes no",
  `total_position` varchar(20) DEFAULT NULL COMMENT "总计显示位置：top  bottom",
  `show_subtotal` varchar(20) DEFAULT NULL COMMENT "显示小计文案 yes  no",
  `show_detail` varchar(20) DEFAULT NULL COMMENT "显示明细：yes  no",
  `createdtime` datetime DEFAULT NULL COMMENT "创建时间 ",
  `modify_time` datetime DEFAULT NULL COMMENT "更新时间",
  `deleted` tinyint(4) DEFAULT NULL COMMENT "删除",
  `modify_id` int(11) DEFAULT NULL COMMENT "更新人",
  `smcreatorid` int(11) DEFAULT '1' COMMENT "创建人",
  PRIMARY KEY (`report_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
delimiter;


create table if not exists `ld_customtable_columns` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT ,
  `report_id` int(11) DEFAULT NULL COMMENT "报表ID ",
	`tdheader_label` varchar(255) DEFAULT NULL COMMENT "表头名称，示例：客户名称",
	`columns` varchar(255) DEFAULT NULL COMMENT "ld_account:accountname:accountname:Accounts_客户名称:V",
	`columnmodule` varchar(255) DEFAULT NULL COMMENT "来自那个模块 示例：Accounts",
	`is_group` varchar(20) DEFAULT NULL COMMENT "是否分组 yes  no",
	`order_by` varchar(20) DEFAULT NULL COMMENT "升序降序  desc  asc  no",
	`is_merge` varchar(20) DEFAULT NULL COMMENT "是否合并  yes  no",
	`total_type` varchar(255) DEFAULT NULL COMMENT "统计方式 count计数 distinct_count唯一计数 sum 求和avg求均值  max求最大值 min求最小值,可多选，逗号分割",
	`align` varchar(20) DEFAULT NULL COMMENT "对齐方式 left  right  center",
	`sequence` int(11) DEFAULT NULL COMMENT "显示顺序",
	PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
delimiter;


create table if not exists `ld_customtable_condition` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT ,
	`report_id` int(11) DEFAULT NULL COMMENT "报表ID ",
	`columns` varchar(255) DEFAULT NULL COMMENT "字段  ld_account:accountname:accountname:Accounts_客户名称:V",
	`comparator` varchar(255) DEFAULT NULL COMMENT "关系  示例：e",
	`value` varchar(255) DEFAULT NULL COMMENT "值   示例：华为",
	PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
delimiter;



create table if not exists `ld_customtable2user` (
	`report_id` int(11) DEFAULT NULL,
	`userid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;


SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
SET @maxtseq=(SELECT tabsequence FROM ld_tab where name="CustomEcharts");
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,'CustomTables',5,@maxtseq+1,'CustomTables',1,'CustomTables' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='CustomTables');



select max(sequence) into @sequence from ld_parenttabrel where parenttabid=5;
insert into ld_parenttabrel (parenttabid,tabid,sequence,tab_tablename) select 5,@maxtabid+1,@sequence+1,'ld_tab' from dual where not exists(select 1 from ld_parenttabrel where tabid=@maxtabid+1 and tab_tablename='ld_tab');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomTables');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tab',@tabid,@tabid,'自定义统计表' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tab',@tabid,@tabid,'CustomTables' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

INSERT INTO ld_modtracker_tabs(tabid,visible) 
		SELECT @tabid,1 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

SET @i=0;
		INSERT INTO ld_profileallpermission(tabid,operation,sequence) 
		SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping 
		WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN 
			('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView');


update ld_tab set presence=0 where name="CustomTables";
select tabsequence into @tabsequence from ld_tab  where name="CustomEcharts";
update ld_tab set tabsequence=tabsequence+1 where tabsequence>@tabsequence;
update ld_tab set tabsequence=@tabsequence+1 where name="CustomTables";
SET @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CustomTables','自定义统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomTables' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CustomTables','Custom Tables','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomTables' and Labeltype='fixedstr' and languagetype='en');

delimiter;

call AddColumn('ld_customtable','approveallocatetype','int','11','0');
delimiter;

update ld_tabdetailfield  set typeofdata='N~O' where (columnname='amount' or columnname='pay_amount' or columnname='source_total')
and tablename='ld_sendcashbill2payment' and typeofdata='V~O';
delimiter;

update ld_tabdetailfield  set typeofdata='N~O' where (columnname='amount' or columnname='pay_amount' or columnname='source_total')
and tablename='ld_cashbill2paymentplan' and typeofdata='V~O';
delimiter;
-- 2021-09-29

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTPRODUCTAFTERSELECTQUOTETYPE','选择报价单类型之后，才能选择产品','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTPRODUCTAFTERSELECTQUOTETYPE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTPRODUCTAFTERSELECTQUOTETYPE',"Products can only be selected after quotation type is selected",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELECTPRODUCTAFTERSELECTQUOTETYPE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHANGEQUOTECLEARPRODUCTINFOCONTINUE','改变报价单类型会清空产品信息，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHANGEQUOTECLEARPRODUCTINFOCONTINUE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHANGEQUOTECLEARPRODUCTINFOCONTINUE',"Changing the quotation type will clear the product information. Do you want to continue?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHANGEQUOTECLEARPRODUCTINFOCONTINUE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHANGEQUOTECLEARPRODUCTINFOCONTINUE','单据[%s]提交失败！原因：该单据已经审批！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHANGEQUOTECLEARPRODUCTINFOCONTINUE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHANGEQUOTECLEARPRODUCTINFOCONTINUE',"Changing the quotation type will clear the product information. Do you want to continue?",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHANGEQUOTECLEARPRODUCTINFOCONTINUE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Currentmodel','当前型号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Currentmodel' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Currentmodel',"Current model",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Currentmodel' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Alternativemodels','可替代型号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Alternativemodels' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Alternativemodels',"Alternative models",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Alternativemodels' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SPECIALMATERIALWARNINGINFO','特殊物料警告信息','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SPECIALMATERIALWARNINGINFO' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SPECIALMATERIALWARNINGINFO',"Special material warning information",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SPECIALMATERIALWARNINGINFO' and labeltype='fixedstr');
delimiter;

update ld_producttoolfield set columnname = 'discount_percent' where tabid =20 and columnname = 'discount_percent ';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CANNOTDELETEWITHORDER','不能删除已创建{$SalesOrder.SalesOrder}的产品！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='CANNOTDELETEWITHORDER' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CANNOTDELETEWITHORDER','Products with {$SalesOrder.SalesOrder} records cannot be deleted!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='CANNOTDELETEWITHORDER' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SEARCHHISTORY','搜索历史','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SEARCHHISTORY' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SEARCHHISTORY','Search History','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SEARCHHISTORY' and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_searchhistory` ( 
    `id` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `modulename` Varchar(50) NOT NULL,
    `smownerid` Int(11),
    `searchtype` Varchar(50),
    `searchvalue` BLOB,
    `searchtime` Datetime
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2021-10-09

DROP EVENT IF EXISTS `task_questionnaire_resetstatus_everysecond`;
delimiter ||
CREATE  EVENT `task_questionnaire_resetstatus_everysecond` ON SCHEDULE EVERY 5 SECOND STARTS '2021-05-11 15:00:00' ON COMPLETION NOT PRESERVE ENABLE 
DO 
UPDATE ld_questionnaire SET `status`='暂停' WHERE recovery_endtime<NOW() AND `status`<>'暂停';
||
delimiter;

UPDATE ld_field SET allowhide='yes' WHERE tabid=2 AND columnname='potentialname';

SET @i=0;
UPDATE ld_desk SET fieldlabel='项目动态' WHERE languagetype='zh' AND labelbol='ProjectAbstract';
UPDATE ld_relatedlists SET presence=0,sequence=-100 WHERE tabid=48 AND `name`='get_projectabstract';
UPDATE ld_relatedlists SET sequence=(@i:=@i+1) WHERE tabid=48 AND presence=0 ORDER BY sequence;
delimiter;


insert into ld_wx_config (name,description) select 'electronic_signature','电子签章' from dual where not exists(select 1 from ld_wx_config where name='electronic_signature');
delimiter;

CALL AddColumn('ld_users', 'proxyoperatoropenid', 'varchar', '255', NULL);
delimiter;
CALL AddColumn('ld_salesorder', 'sponsorid', 'int', '11', NULL);
delimiter;

UPDATE ld_field_seq SET id = (select MAX(fieldid) from ld_field);
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder');
SET @sequence=(SELECT sequence FROM ld_field WHERE `tabid`=@tabid AND columnname='duedate');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'sponsorid','yes',CONCAT('ld_',LOWER('SalesOrder')),1,52,'sponsorid','合同发起人',1,0,@sequence,61 ,2,'V~O',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='sponsorid');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='sponsorid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'合同发起人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Contract sponsor' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

CALL AddColumn('ld_salesorder', 'flowstatus', 'varchar', '25', NULL);
delimiter;

UPDATE ld_field_seq SET id = (select MAX(fieldid) from ld_field);
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder');
SET @sequence=(SELECT sequence FROM ld_field WHERE `tabid`=@tabid AND columnname='sponsorid');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'flowstatus','yes',CONCAT('ld_',LOWER('SalesOrder')),1,1,'flowstatus','合同状态',1,0,@sequence,61 ,2,'V~O',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='flowstatus');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='flowstatus');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'合同状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'flowstatus' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

CREATE TABLE IF NOT EXISTS `ld_salesorder_electronicsignet` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `salesorderid` int(19) DEFAULT NULL,
  `flowid` varchar(255) DEFAULT NULL,
  `flowname` varchar(255) DEFAULT NULL COMMENT '合同名称',
  `flowtype` varchar(25) DEFAULT NULL COMMENT '合同类型',
  `flowstatus` varchar(255) DEFAULT NULL COMMENT '合同状态',
  `flowmessage` varchar(255) DEFAULT NULL,
  `createon` datetime DEFAULT NULL COMMENT '发起时间',
  `deadline` datetime DEFAULT NULL COMMENT '截止时间',
  `occurtime` datetime DEFAULT NULL COMMENT '回调发起时间(合同状态变化节点)',
  `flowapproverinfo` text COMMENT '合同参与者的信息',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnterpriseAuthentication','企业实名认证','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EnterpriseAuthentication' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnterpriseAuthentication','Enterprise real name authentication','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EnterpriseAuthentication' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ElectronicSignatureAdmin','电子签管理后台','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ElectronicSignatureAdmin' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ElectronicSignatureAdmin','Electronic signature management background','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ElectronicSignatureAdmin' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InitiateSigning','发起签署','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InitiateSigning' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InitiateSigning','Initiate signing','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InitiateSigning' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotApprovedNotSigned','您的合同还未审批通过，合同不允许发起签署！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotApprovedNotSigned' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotApprovedNotSigned','Your contract has not been approved yet. The contract cannot be signed!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotApprovedNotSigned' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PreviewContract','预览合同','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PreviewContract' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PreviewContract','Preview Contract','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PreviewContract' and labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2021-11-12

CREATE TABLE IF NOT EXISTS `ld_quotes_mailhistory` ( 
    `id` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `quoteid` Int(19),
    `accountid` Int(19),
		`fromemail` Varchar(50),
		`toemail` Varchar(50),
		`conditions` Varchar(200),
		`sendtime` Datetime NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid  from ld_tab where name='Potentials';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_OPPORTUNITY_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='total');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata,bigtype)
select @tabid,@maxfieldid+1,'total','no','ld_potentials',1,72,'hdnGrandTotal','合计',2,'',@maxsequence+1,@blockid,@maxsequence,'N~O','currency' from dual
where not exists(select 1 from ld_field where tabid=@tabid and columnname='total');
delimiter;

select tabid into @tabid  from ld_tab where name='Potentials';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnGrandTotal';
update ld_producttoolfield set fieldid=0 where tabid = @tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'合计' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'total' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='subtotal');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata,bigtype)
select @tabid,@maxfieldid+1,'subtotal','no','ld_potentials',1,72,'hdnSubTotal','小计',2,'',@maxsequence+1,@blockid,@maxsequence,'N~O','currency' from dual
where not exists(select 1 from ld_field where tabid=@tabid and columnname='subtotal');

delimiter;
select tabid into @tabid  from ld_tab where name='Potentials';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnSubTotal';
update ld_producttoolfield set fieldid=0 where tabid = @tabid and columnname='subtotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'小计' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'subtotal' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

update ld_field set typeofdata='N~O~20,2' where columnname='hastime' and (tablename='ld_project' or tablename='ld_projecttask')
and typeofdata='V~o';
delimiter;

update ld_field set typeofdata='N~O~20,2' where columnname='hastime' and (tablename='ld_project' or tablename='ld_projecttask')
and typeofdata='N~o';
delimiter;
-- 2021-10-13

UPDATE ld_field SET bigtype='mobile' WHERE uitype=1101;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ModifyTrackingFieldToModifyAutomaticAask','（如需修改自动任务，请修改跟踪字段的下拉框选项）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ModifyTrackingFieldToModifyAutomaticAask' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ModifyTrackingFieldToModifyAutomaticAask',"(To modify the automatic task, modify the drop-down box options of the tracking field)",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ModifyTrackingFieldToModifyAutomaticAask' and labeltype='fixedstr');
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name='Accounts');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'socialStaffNum','socialStaffNum','','null','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'socialStaffNum' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'websiteList','websiteList','','website','url' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'websiteList' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyphoneNumber','phoneNumber','','phone','phone' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyphoneNumber' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'staffNumRange','staffNumRange','','accountsize','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'staffNumRange' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyEmail','email','','email1','email' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyEmail' and tabid = @tabid);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name='ServiceCharge');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'socialStaffNum','socialStaffNum','','null','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'socialStaffNum' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'websiteList','websiteList','','website','url' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'websiteList' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyphoneNumber','phoneNumber','','phone','phone' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyphoneNumber' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'staffNumRange','staffNumRange','','accountsize','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'staffNumRange' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyEmail','email','','email1','email' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyEmail' and tabid = @tabid);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name='Vendors');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'socialStaffNum','socialStaffNum','','null','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'socialStaffNum' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'websiteList','websiteList','','website','url' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'websiteList' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyphoneNumber','phoneNumber','','null','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyphoneNumber' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'staffNumRange','staffNumRange','','null','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'staffNumRange' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyEmail','email','','null','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyEmail' and tabid = @tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','socialStaffNum','参保人数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='socialStaffNum' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','socialStaffNum',"Number of insured persons",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='socialStaffNum' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','socialStaffNum','参保人数','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='socialStaffNum' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','socialStaffNum',"Number of insured persons",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='socialStaffNum' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','websiteList','网址','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='websiteList' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','websiteList',"Website",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='websiteList' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','websiteList','网址','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='websiteList' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','websiteList',"Website",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='websiteList' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','companyphoneNumber','电话','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='companyphoneNumber' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','companyphoneNumber',"Phone",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='companyphoneNumber' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','companyphoneNumber','电话','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='companyphoneNumber' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','companyphoneNumber',"Phone",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='companyphoneNumber' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','staffNumRange','人员规模','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='staffNumRange' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','staffNumRange',"Staff size",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='staffNumRange' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','staffNumRange','人员规模','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='staffNumRange' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','staffNumRange',"Staff size",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='staffNumRange' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','companyEmail','企业邮箱','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='companyEmail' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','companyEmail',"Enterprise mailbox",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='companyEmail' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','companyEmail','企业邮箱','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='companyEmail' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','companyEmail',"Enterprise mailbox",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='companyEmail' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PreservationConditions','保存条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PreservationConditions' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PreservationConditions',"Preservation conditions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PreservationConditions' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PreservationConditions','保存条件','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PreservationConditions' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PreservationConditions',"Preservation conditions",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PreservationConditions' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QueryField','查询字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='QueryField' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QueryField',"Query field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='QueryField' and labeltype='fixedstr');
delimiter;
-- 2021-10-18

update ld_desk set labelbol = 'AllowNewCommonLead' where labelbol='AllowNewCommonLead"' and Labeltype='fixedstr' and languagetype = 'zh';
delimiter;


UPDATE ld_field INNER JOIN ld_tab ON ld_tab.tabid = ld_field.tabid INNER JOIN (SELECT tabid FROM ld_producttoolfield WHERE tabid > 0 GROUP BY tabid) AS pro_tabid ON pro_tabid.tabid = ld_tab.tabid SET ld_field.quickcreate = 0,ld_tab.isduplicate = 'yes';
delimiter;
UPDATE ld_field INNER JOIN ld_tab ON ld_tab.tabid = ld_field.tabid INNER JOIN (SELECT tabid FROM ld_tabdetailfield WHERE tabid > 0 GROUP BY tabid) AS tab_tabid ON tab_tabid.tabid = ld_tab.tabid SET ld_field.quickcreate = 0,ld_tab.isduplicate = 'yes';
delimiter;
UPDATE ld_field INNER JOIN ld_tab ON ld_tab.tabid = ld_field.tabid SET ld_field.quickcreate = 0,ld_tab.isduplicate = 'yes' where ld_tab.name = 'Users';
delimiter;


delete from ld_tranlabel where relateid = ( select fieldid from ld_field where tabid  = 29 and tablename='ld_asteriskextensions' and fieldname ='asterisk_extension') and  tabid =29;
delete from ld_tranlabel where relateid = ( select fieldid from ld_field where tabid  = 29 and tablename='ld_asteriskextensions' and fieldname ='use_asterisk') and  tabid =29;
DELETE from ld_field where tabid =29 and tablename='ld_asteriskextensions';
delimiter;

call AddColumn('ld_contactdetails','unionid_external_userid','varchar','255',NULL);
delimiter;
update ld_field set typeofdata='N~M~20,2' where typeofdata='V~M' and tabid=48 and columnname='timebudget';
delimiter;

update ld_field set typeofdata='N~O~20,2' where typeofdata='V~O' and tabid=48 and columnname='timebudget';
delimiter;

UPDATE ld_profile2standardpermissions as tmp1 
LEFT JOIN (SELECT * FROM ld_profile2standardpermissions where operation = 1
) AS tmp2 ON tmp1.profileid = tmp2.profileid	AND tmp1.tabid = tmp2.tabid
set tmp1.permissions = 1 
WHERE tmp1.operation = 22 and IFNULL(tmp2.permissions,1) <> 0;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','PUSHUNDERCONTROL','推进受编辑控制','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='PUSHUNDERCONTROL' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','PUSHUNDERCONTROL','Push is under control by Edit','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='PUSHUNDERCONTROL' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NOACCESSTOADVANCE','您没有权限推进这条单据！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NOACCESSTOADVANCE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NOACCESSTOADVANCE','You do not have permission to advance documents of this members！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NOACCESSTOADVANCE' and Labeltype='fixedstr');
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','APPROVENOTADVANCE','审批中的单据不允许推进!','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='APPROVENOTADVANCE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','APPROVENOTADVANCE','Record in approve is not allow to advance！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='APPROVENOTADVANCE' and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_profile2field','editreadonly','int','19',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVISIBLE','不可见','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INVISIBLE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVISIBLE',"Invisible",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INVISIBLE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','READONLYPERMISSIONSDURINGEDIT','编辑时只读','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='READONLYPERMISSIONSDURINGEDIT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','READONLYPERMISSIONSDURINGEDIT',"Read only during editing",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='READONLYPERMISSIONSDURINGEDIT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVISIBLEEXPLAIN','不可见：新增、编辑、查看界面不显示；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INVISIBLEEXPLAIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVISIBLEEXPLAIN',"Invisible: the interface of creating, editing and viewing is not displayed;",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INVISIBLEEXPLAIN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','READONLYEXPLAIN','只读权限：查看界面显示，新增、编辑界面不显示；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='READONLYEXPLAIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','READONLYEXPLAIN',"Read-only permissions：The view interface is displayed, and the create and  edit interface is not displayed;",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='READONLYEXPLAIN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','READANDWRITEEXPLAIN','读写权限：新增、编辑、查看界面都显示，新增、编辑界面可录入；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='READANDWRITEEXPLAIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','READANDWRITEEXPLAIN',"Read and write permission: it is displayed in the create, edit and view interfaces, and can be entered in the create and edit interfaces;",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='READANDWRITEEXPLAIN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','READANDWRITEDURINGEDITEXPLAIN','编辑时只读：新增、编辑、查看界面都显示，仅新增界面可录入；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='READANDWRITEDURINGEDITEXPLAIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','READANDWRITEDURINGEDITEXPLAIN',"Read only during editing: the create, edit and view interfaces are displayed, and only the create interface can be entered;",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='READANDWRITEDURINGEDITEXPLAIN' and labeltype='fixedstr');
delimiter;
-- 2021-10-23

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

UPDATE ld_version SET old_version='V8.4.5.0',current_version='V8.4.5.0',remark='V8.4.5.0-20211023',wx_version='V8.4.5.0';
delimiter;