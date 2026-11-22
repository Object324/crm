UPDATE ld_desk SET fieldlabel='（但是，可以在 WPS 中编辑后另存为*.xls格式再导入）' WHERE labelbol='HOWEVERINPORTWPS' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='.xls/.xlsx，不支持 WPS 格式' WHERE labelbol='wpsformatisnotsupported' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='.xls/.xlsx, WPS format is not supported' WHERE labelbol='wpsformatisnotsupported' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Column order can be adjusted and unnecessary items can be deleted' WHERE labelbol='MAYADJUSTORDERIMPORT' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='请按照数据模板的格式准备要导入的数据' WHERE labelbol='ACCORDINGTEMPLATEIMPORTDATA' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Prepare the data to be imported according to the data template' WHERE labelbol='ACCORDINGTEMPLATEIMPORTDATA' AND languagetype='en';

UPDATE ld_desk SET fieldlabel="查重字段" WHERE labelbol='CHECKIMPORTFIELD' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel="" WHERE labelbol='CHECKIMPORTFIELD' AND languagetype='en';

UPDATE ld_desk SET fieldlabel="请设置{$Contacts.Contacts}查重字段，如果不需要导入{$Contacts.Contacts}请将查重字段设置为“不导入{$Contacts.Contacts}”" WHERE labelbol='NOTNEEDTOIMPORTCONTACTS' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel=CONCAT("Please set the duplicate fields for {$Contacts.Contacts}. If you don't want to import {$Contacts.Contacts}, please choose ",'"DO not import {$Contacts.Contacts}"') WHERE labelbol='NOTNEEDTOIMPORTCONTACTS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel="重复时导入方式" WHERE labelbol='REPEAT_IMPORT_MODE' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel=" repeats" WHERE labelbol='REPEAT_IMPORT_MODE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Download data template' WHERE labelbol='DOWNTEMPLATEDATA' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='View the Notes' WHERE labelbol='VIEWCAREITEM' AND languagetype='en';
UPDATE ld_desk SET fieldlabel="The header name in the template can't be changed and the header rows can't be deleted" WHERE labelbol='STOPDELETEIMPORTTEMPLATEHEAD' AND languagetype='en';
UPDATE ld_desk SET fieldlabel="Red * is a must entry,must be retained and cannot be empty" WHERE labelbol='REDREPRESENTNOTEMPTY' AND languagetype='en';

UPDATE ld_desk SET fieldlabel="请选择需要导入的文件（请使用系统导出的模板表格）" WHERE labelbol='USESYSIMPORTFILE' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel="Please select the file you want to import, and use the exported template" WHERE labelbol='USESYSIMPORTFILE' AND languagetype='en';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDFILE','添加文件','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ADDFILE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDFILE','Add Files','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ADDFILE' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel="支持文件类型：" WHERE labelbol='SUPPORTFILETYPE' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel="Supported file: " WHERE labelbol='SUPPORTFILETYPE' AND languagetype='en';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOIMPORT','  不导入{$Contacts.Contacts}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOIMPORT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOIMPORT','  Do not import {$Contacts.Contacts}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOIMPORT' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel="  不导入{$Contacts.Contacts}" WHERE labelbol='NOIMPORT' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='  Do not import {$Contacts.Contacts}' WHERE labelbol='NOIMPORT' AND languagetype='en';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IMPORT_PLEASESETIMPORTMODE','请设置','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORT_PLEASESETIMPORTMODE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','IMPORT_PLEASESETIMPORTMODE','Please set the import mode when the ','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='IMPORT_PLEASESETIMPORTMODE' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IMPORT_PLEASESETDUMPLICATEFIELDS','请设置','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORT_PLEASESETDUMPLICATEFIELDS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','IMPORT_PLEASESETDUMPLICATEFIELDS','Please set the duplicate fields for ','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='IMPORT_PLEASESETDUMPLICATEFIELDS' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='上传文件' where labelbol='FILEUPLOAD' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='模板中的表头名称不可更改，表头行不能删除；' where labelbol='STOPDELETEIMPORTTEMPLATEHEAD' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel="The header name in the template can't be changed and the header rows can't be deleted;" where labelbol='STOPDELETEIMPORTTEMPLATEHEAD' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='栏目顺序可以调整，不需要的栏目可以删减；' where labelbol='MAYADJUSTORDERIMPORT' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Column order can be adjusted and unnecessary items can be deleted;' where labelbol='MAYADJUSTORDERIMPORT' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='红色*表示为必录项，必须保留并且不能为空；' where labelbol='REDREPRESENTNOTEMPTY' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Red * is a must entry,must be retained and cannot be empty;' where labelbol='REDREPRESENTNOTEMPTY' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='请选择需要导入的文件（请使用系统导出的Excel模板）' where labelbol='USESYSIMPORTFILE' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Please select the file you want to import, and use the exported excel template' where labelbol='USESYSIMPORTFILE' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='请设置{$Contacts.Contacts}查重字段，如果不需要导入{$Contacts.Contacts}，请将查重字段设置为“不导入{$Contacts.Contacts}”' where labelbol='NOTNEEDTOIMPORTCONTACTS' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

update ld_field set issmownerid=0 where columnname='express_no' ;
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=142;
update ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and roottype=5;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 1,'201','设置合同订单分录明细中数量超过安全库存数量时是否需要提示',@sequence+1,5,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type='201');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTSMORETHANQTYEARLY','产品数量超过安全库存数量','fixedstr' from dual 
where  not EXISTS(
select 1 from ld_desk where labelbol='PRODUCTSMORETHANQTYEARLY' and languagetype='zh' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTSMORETHANQTYEARLY','Product quantity excess total safety stock','fixedstr' from dual 
where  not EXISTS(
select 1 from ld_desk where labelbol='PRODUCTSMORETHANQTYEARLY' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',201,201,'设置{$SalesOrder.SalesOrder}分录明细中数量超过安全库存数量时是否需要提示' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=201);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',201,201,'Control the {$SalesOrder.SalesOrder} whether exceeds the safe stock should be prompted' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=201);
delimiter;
update ld_desk set fieldlabel='上传文件' where labelbol='FILEUPLOAD' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='模板中的表头名称不可更改，表头行不能删除；' where labelbol='STOPDELETEIMPORTTEMPLATEHEAD' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel="The header name in the template can't be changed and the header rows can't be deleted;" where labelbol='STOPDELETEIMPORTTEMPLATEHEAD' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='栏目顺序可以调整，不需要的栏目可以删减；' where labelbol='MAYADJUSTORDERIMPORT' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Column order can be adjusted and unnecessary items can be deleted;' where labelbol='MAYADJUSTORDERIMPORT' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='红色*表示为必录项，必须保留并且不能为空；' where labelbol='REDREPRESENTNOTEMPTY' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Red * is a must entry,must be retained and cannot be empty;' where labelbol='REDREPRESENTNOTEMPTY' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='请选择需要导入的文件（请使用系统导出的Excel模板）' where labelbol='USESYSIMPORTFILE' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Please select the file you want to import, and use the exported excel template' where labelbol='USESYSIMPORTFILE' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='请设置{$Contacts.Contacts}查重字段，如果不需要导入{$Contacts.Contacts}，请将查重字段设置为“不导入{$Contacts.Contacts}”' where labelbol='NOTNEEDTOIMPORTCONTACTS' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

update ld_field set issmownerid=0 where columnname='express_no' ;
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=142;
update ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and roottype=5;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 1,'201','设置合同订单分录明细中数量超过安全库存数量时是否需要提示',@sequence+1,5,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type='201');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTSMORETHANQTYEARLY','产品数量超过安全库存数量','fixedstr' from dual 
where  not EXISTS(
select 1 from ld_desk where labelbol='PRODUCTSMORETHANQTYEARLY' and languagetype='zh' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTSMORETHANQTYEARLY','Product quantity excess total safety stock','fixedstr' from dual 
where  not EXISTS(
select 1 from ld_desk where labelbol='PRODUCTSMORETHANQTYEARLY' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',201,201,'设置{$SalesOrder.SalesOrder}分录明细中数量超过安全库存数量时是否需要提示' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=201);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',201,201,'Control the {$SalesOrder.SalesOrder} whether exceeds the safe stock should be prompted' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=201);
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANCELHIDDEN','取消隐藏','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='CANCELHIDDEN');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELHIDDEN','Cancel hidden','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='CANCELHIDDEN');
delimiter;

update ld_tranlabel set fieldlabel='坐席置忙置闲根据CRM是否登录显示'
where languagetype='zh' and trantable='ld_systems_deploy' and tabid=160 and relateid=160;
update ld_tranlabel set fieldlabel='The seat is occupied or idle according to whether the CRM is logged in or not'
where languagetype='en' and trantable='ld_systems_deploy' and tabid=160 and relateid=160;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTCOLOR','选择颜色','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='SELECTCOLOR' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTCOLOR','Select Color','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='SELECTCOLOR' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MENUBACKGROUNDCOLORSETTINGS','菜单颜色定制','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='MENUBACKGROUNDCOLORSETTINGS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MENUBACKGROUNDCOLORSETTINGS','Menu background color Settings','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='MENUBACKGROUNDCOLORSETTINGS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MENUBACKGROUNDCOLORSETTINGS','菜单颜色定制','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='MENUBACKGROUNDCOLORSETTINGS' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MENUBACKGROUNDCOLORSETTINGS','Menu background color Settings','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='MENUBACKGROUNDCOLORSETTINGS' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MENUBACKGROUNDCOLOR','菜单背景色','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='MENUBACKGROUNDCOLOR' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MENUBACKGROUNDCOLOR','Menu background color','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='MENUBACKGROUNDCOLOR' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MENUSELECTBACKGROUNDCOLOR','菜单选中背景色','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='MENUSELECTBACKGROUNDCOLOR' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MENUSELECTBACKGROUNDCOLOR','Menu select background color','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='MENUSELECTBACKGROUNDCOLOR' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RESTORETHEDEFAULT','恢复默认背景色','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='RESTORETHEDEFAULT' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','RESTORETHEDEFAULT','Restore the default','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='RESTORETHEDEFAULT' and labeltype='jspop');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','wechat_miniprogram_setting','http://51mis.com.cn/forum.php?mod=viewthread&tid=407','控制面板-企业号设置' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'wechat_miniprogram_setting');
delimiter;
-- 2019-05-29


update ld_desk set fieldlabel='Assign Unassigned' where labelbol='LBL_DISTRIBUT_HIGHSEAS' and languagetype='en';
update ld_desk set fieldlabel='Average Assign Unassigned' where labelbol='LBL_AVGDISTRIBUT_HIGHSEAS' and languagetype='en';
delimiter;
update ld_desk set fieldlabel='The members {$Accounts.Accounts} book page is shown as' where labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES' and languagetype='en';
update ld_desk set fieldlabel='Set unassigned' where labelbol='PUBLICCUSTOMERSET' and languagetype='en';
update ld_desk set fieldlabel='On the unassigned customer is a pressure-based sales customer management tools' where labelbol='PRESSCUSTOMER' and languagetype='en';
delimiter;
update ld_desk set fieldlabel='Activate unassigned {$Accounts.Accounts}' where labelbol='ACTIVATEPUBLICCUST' and languagetype='en';
delimiter;

UPDATE ld_tabdetailfield SET defaultcolumn=1,presence=0 WHERE tablename='ld_expensedetail' AND columnname IN ('expenseuse','expensetype');
UPDATE ld_tabdetailfield SET presence=0 WHERE tablename='ld_expensedetail' AND columnname IN ('expenseuse','expensetype') AND presence=2;
UPDATE ld_tabdetailfield SET defaultcolumn=1 WHERE tablename IN ('ld_minusjobbilldetail','ld_businessapply','ld_addjobbilldetail') 
	AND columnname IN ('starttime','endtime','description') AND defaultcolumn=2;
-- 2019-05-30

update ld_field set issmownerid=0 where columnname='express_company';
update ld_field set issmownerid=0 where uitype='204' or uitype=202;

DROP PROCEDURE IF EXISTS `ldcrm_reset_weixinmp_fields_20190531`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_weixinmp_fields_20190531`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_troubletickets) THEN
		select sequence into @sequence from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='ticket_no';
		update ld_weixinmp_fields set sequence:=sequence+10000 where sequence>@sequence and modulename='HelpDesk';
		insert into ld_weixinmp_fields ( modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, defaultvalue, sequence)
		select 'HelpDesk','account_id','main','客户名称','all','o','',@sequence+1 from dual where not exists(
		select 1 from ld_weixinmp_fields where modulename='HelpDesk' and fieldname='account_id');

		SET @i=0;
		UPDATE ld_weixinmp_fields SET sequence=sequence+100 WHERE modulename='HelpDesk';
		UPDATE ld_weixinmp_fields SET sequence=1 WHERE modulename='HelpDesk' AND fieldname='ticket_no';
		UPDATE ld_weixinmp_fields SET sequence=2 WHERE modulename='HelpDesk' AND fieldname='account_id';
		UPDATE ld_weixinmp_fields SET sequence=(@i:=@i+1) WHERE modulename='HelpDesk' ORDER BY sequence;
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_salesorder) THEN
		select sequence into @sequence from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='salesorder_no';
		update ld_weixinmp_fields set sequence:=sequence+10000 where sequence>@sequence and modulename='SalesOrder';
		insert into ld_weixinmp_fields ( modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, defaultvalue, sequence)
		select 'SalesOrder','account_id','main','客户名称','all','o','',@sequence+1 from dual where not exists(
		select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='account_id');
		
		insert into ld_weixinmp_fields ( modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, defaultvalue, sequence)
		select 'SalesOrder','salescontracttype','main','合同类型','all','o','',@sequence+2 from dual where not exists(
		select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='salescontracttype');

		select sequence into @sequence from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='signed_data';
		update ld_weixinmp_fields set sequence:=sequence+10000 where sequence>@sequence and modulename='SalesOrder';
		insert into ld_weixinmp_fields ( modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, defaultvalue, sequence)
		select 'SalesOrder','terms_conditions','main','备注','all','o','',@sequence+1 from dual where not exists(
		select 1 from ld_weixinmp_fields where modulename='SalesOrder' and fieldname='terms_conditions');

		SET @i=0;
		UPDATE ld_weixinmp_fields SET sequence=sequence+100 WHERE modulename='SalesOrder';
		UPDATE ld_weixinmp_fields SET sequence=1 WHERE modulename='SalesOrder' AND fieldname='salesorder_no';
		UPDATE ld_weixinmp_fields SET sequence=2 WHERE modulename='SalesOrder' AND fieldname='account_id';
		UPDATE ld_weixinmp_fields SET sequence=3 WHERE modulename='SalesOrder' AND fieldname='salescontracttype';
		UPDATE ld_weixinmp_fields SET sequence=4 WHERE modulename='SalesOrder' AND fieldname='signed_data';
		UPDATE ld_weixinmp_fields SET sequence=5 WHERE modulename='SalesOrder' AND fieldname='description';
		UPDATE ld_weixinmp_fields SET sequence=6 WHERE modulename='SalesOrder' AND fieldname='terms_conditions';
		UPDATE ld_weixinmp_fields SET sequence=(@i:=@i+1) WHERE modulename='SalesOrder' ORDER BY sequence;
	END IF;

end ||
delimiter;

CALL ldcrm_reset_weixinmp_fields_20190531();
DROP PROCEDURE IF EXISTS `ldcrm_reset_weixinmp_fields_20190531`;

UPDATE ld_producttoolfield SET defaultvalue=NULL WHERE tablename='ld_checksdetail' AND defaultvalue=0 AND columnname='remark';
-- 2019-05-31

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATASCOPESETTINGS','数据范围设置','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='DATASCOPESETTINGS');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATASCOPESETTINGS','Data Scope Settings','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='DATASCOPESETTINGS');
delimiter;
-- 2019-06-03

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

UPDATE ld_version SET old_version='V7.7.7',current_version='V7.7.7',remark='V7.7.7-20190603',wx_version='V7.7.7.1';
delimiter;