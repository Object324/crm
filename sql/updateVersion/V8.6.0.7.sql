SET @labelbol = 'NODATAFOUND';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有找到任何记录','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No data found','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

DELETE om
FROM ld_option_module om
LEFT JOIN ld_tab t ON om.option_tabid = t.tabid
WHERE om.tabid = (select tabid from ld_tab where `name` = 'ModComments')
AND t.`name` IN ('WorkReportList', 'Shopping', 'ShopSettings', 'ChannelCode', 'Questionnaire', 'ReportAnalysis');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MoveLeftFieldshere','请将左侧字段移至此处','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MoveLeftFieldshere' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MoveLeftFieldshere','Please move the left field here ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MoveLeftFieldshere' and Labeltype='fixedstr' and languagetype='en');
delimiter;
SET @stufftitle = 'Contractnumber';
set @stuffid=102;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule)
select @stuffid,@stufftitle,'chart','SalesOrder,ServiceContracts','SalesOrder,ServiceContracts' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='chart');
delimiter;


SET @stufftitle = 'Contractamount';
set @stuffid=103;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule)
select @stuffid,@stufftitle,'chart','SalesOrder,ServiceContracts','SalesOrder,ServiceContracts' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='chart');
delimiter;

SET @stufftitle = 'STATISTICALRECEIVABLES';
set @stuffid=104;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule)
select @stuffid,@stufftitle,'chart','CashBill','CashBill' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='chart');
delimiter;


SET @stufftitle = 'STATISTICALEXPENSECOMMISSION';
set @stuffid=105;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule)
select @stuffid,@stufftitle,'chart','Expense,Commission','Expense,Commission' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='chart');
delimiter;


SET @stufftitle = 'CUSTOMERSOURCEDISSTATIST';
set @stuffid=106;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule)
select @stuffid,@stufftitle,'chart','Accounts','Accounts' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='chart');
delimiter;

SET @stufftitle = 'CUSTOMERTYPEDISSTATIS';
set @stuffid=107;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule)
select @stuffid,@stufftitle,'chart','Accounts','Accounts' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='chart');
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewSignContractCount','fixedstr',
       'ld_salesorder.salesorder_no','count','新增签约数量',
       'New SignContract Count','ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSignContractCount' and compute_module='SalesOrder' and stuffid=100);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewSignContractCount','fixedstr',
       'ld_servicecontracts.contract_no','count','新增签约数量',
       'New SignContract Count','ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_fieldlabel:DT',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSignContractCount' and compute_module='ServiceContracts' and stuffid=100);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 102,'dragontiger_NewSignContractCount','fixedstr',
       'ld_salesorder.salesorder_no','count','新增签约数量',
       'New SignContract Count','ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSignContractCount' and compute_module='SalesOrder' and stuffid=102);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 102,'dragontiger_NewSignContractCount','fixedstr',
       'ld_servicecontracts.contract_no','count','新增签约数量',
       'New SignContract Count','ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_fieldlabel:DT',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSignContractCount' and compute_module='ServiceContracts' and stuffid=102);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 100,'dragontiger_NewCashBillAmount','fixedstr',
       'ld_cashbill.total','sum','新增收款额',
       'New CashBill Amount','ld_cashbill:createdtime:createdtime:CashBill_fieldlabel:DT',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewCashBillAmount' and compute_module='CashBill' and stuffid=100);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 104,'dragontiger_NewCashBillAmount','fixedstr',
       'ld_cashbill.total','sum','新增收款额',
       'New CashBill Amount','ld_cashbill:createdtime:createdtime:CashBill_fieldlabel:DT',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewCashBillAmount' and compute_module='CashBill' and stuffid=104);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 103,'dragontiger_NewSignContractAmount','fixedstr',
       'ld_salesorder.total','sum','新增签约额',
       'New SignContract Amount','ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSignContractAmount' and compute_module='SalesOrder' and stuffid=103);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 103,'dragontiger_NewSignContractAmount','fixedstr',
       'ld_servicecontracts.total','sum','新增签约额',
       'New SignContract Amount','ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_fieldlabel:DT',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',5
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='dragontiger_NewSignContractAmount' and compute_module='ServiceContracts' and stuffid=103);
delimiter;

UPDATE ld_producttoolfield
    INNER JOIN (
        SELECT showhyperlinks, tabid FROM ld_producttoolfield WHERE columnname = 'productname' GROUP BY tabid
    ) AS tmp ON tmp.tabid = ld_producttoolfield.tabid
SET ld_producttoolfield.showhyperlinks = tmp.showhyperlinks
WHERE tablename = 'ld_products' OR tablename = 'ld_productcf';
delimiter;
-- 2023-09-14

update  ld_settings_field set active=1 where name='LBL_TEMPLATES';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SaveTag','保存标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SaveTag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SaveTag','Save Tag','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SaveTag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_org_share_customrules` (
	`customruleid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'custom rule index',
	`tabid` int(11) NOT NULL COMMENT 'table id',
	`permission` varchar(20) NOT NULL COMMENT 'share permission for read or write',
	`profileid` text(0) COMMENT 'share range for profile',
	`groupid` text(0) COMMENT 'share range for group',
	`userid` text(0) COMMENT 'share range for user',
	`share_demand` text(0) COMMENT 'share demand',
	`share_demand_groups` text(0) COMMENT 'groups of share demand',
	`createdtime` datetime DEFAULT NULL COMMENT 'create time',
	`modifiedtime` datetime DEFAULT NULL COMMENT 'modified time',
	PRIMARY KEY (`customruleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMRULES','自定义规则','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMRULES' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMRULES','Custom rules','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMRULES' and labeltype='fixedstr');

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','SHARINGRULES','共享规则', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SHARINGRULES' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','SHARINGRULES','Sharing rules', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SHARINGRULES' AND labeltype = 'fixedstr' );

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHARINGCONDITIONS','共享条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHARINGCONDITIONS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARINGCONDITIONS',"Sharing conditions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHARINGCONDITIONS' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHAREDPERMISSIONS','共享单据权限','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHAREDPERMISSIONS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHAREDPERMISSIONS',"Shared Document Permissions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHAREDPERMISSIONS' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOSHARETO','自动共享给','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOSHARETO' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOSHARETO',"Automatically share to",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOSHARETO' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Read and write','读写','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Read and write' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Read and write','Read and write','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Read and write' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDRULES','新增规则','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ADDRULES' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDRULES',"Add rules",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ADDRULES' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMSHARESELECTATLEASTONE','部门/成员/角色至少需要选择一个','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMSHARESELECTATLEASTONE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMSHARESELECTATLEASTONE','Select at least one department/member/role','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMSHARESELECTATLEASTONE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SPECIFYGROUP','指定部门','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SPECIFYGROUP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SPECIFYGROUP','Specify groups','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SPECIFYGROUP' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOCONDITIONSSET','不设置条件，默认共享当前模块所有单据','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOCONDITIONSSET' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOCONDITIONSSET','no conditions set, default to sharing all documents in the current module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOCONDITIONSSET' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','USER','用户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='USER' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','USER','User','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='USER' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMSHARESELECTATLEASTONETIP','至少需要选择一个部门/成员/角色','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMSHARESELECTATLEASTONETIP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMSHARESELECTATLEASTONETIP','At least one department/member/role needs to be selected','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMSHARESELECTATLEASTONETIP' and labeltype='jspop');
delimiter;

update ld_dashboard_app set  home_sequence = 0
where `name` in  ('TargetCompletionRate','daylog','weeklog','monthlog','signednumber','signedamount','cashbillamount',
                    'expense_commission','monthweekreport','Salessituation','SalesOrderTrack','CashBillSum_SalesOrder',
                    'CashBillSum_Paymentplan','AccountsMap','InventoryQuery','complationRateSixMonth','PersonalAccountBalance','search_erp_stcok'
);
delimiter;

select tabid into @tabid from ld_tab where name='CustomForm101';
update ld_field set bigtype='datetime' where fieldname='createdtime' and tabid>=@tabid;
update ld_field set bigtype='datetime' where fieldname='modifiedtime' and tabid>=@tabid;
delimiter;

update ld_desk set fieldlabel='ERP库存查询_移动端' where labelbol='search_erp_stcok' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Stock Search' where labelbol='search_erp_stcok' and languagetype='en' and Labeltype='fixedstr';
delimiter;

update ld_dashboard_app set wx_presence=0 where name='commonmodules';
delimiter;
-- 2023-09-15

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

UPDATE ld_version SET old_version='V8.6.0.7',current_version='V8.6.0.7',remark='V8.6.0.7-20230915',wx_version='V8.6.0.7';
delimiter;