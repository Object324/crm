insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'no',462,'设置销售发票，采购发票审批通过后计算已开票金额','',19,1,'select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 462);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',462,462,'设置{$Invoice.Invoice}，{$PurchaseInvoice.PurchaseInvoice}审批通过后计算已开票金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_systems_deploy' and tabid = 462 and relateid=462);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',462,462,'Set calculating have_invoicetotal after the approval of {$Invoice.Invoice},{$PurchaseInvoice.PurchaseInvoice}'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = 462 and relateid=462);
delimiter;

update ld_desk set fieldlabel='Settings' where labelbol='OldKanban' and languagetype='en' and Labeltype='fixedstr';
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Worksheet');
UPDATE ld_tab SET isduplicate='yes' WHERE tabid=@tabid AND `name`='Worksheet';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ModuleHasNoEmailField','模块中没有Email类型字段','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ModuleHasNoEmailField' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ModuleHasNoEmailField','module has no Email type field','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ModuleHasNoEmailField' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ClicktoViewGantt','点击查看甘特图','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ClicktoViewGantt' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ClicktoViewGantt','Click to view Gantt chart','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ClicktoViewGantt' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Contrast','对比','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Contrast' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Contrast','Contrast','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Contrast' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnableToObtain','未获取到','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UnableToObtain' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnableToObtain','Unable to obtain','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UnableToObtain' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CorrespondingTo','对应的','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CorrespondingTo' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CorrespondingTo','corresponding to','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CorrespondingTo' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ONTIME','按期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ONTIME' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ONTIME','On Time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ONTIME' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OVERDUE','超期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OVERDUE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OVERDUE','Overdue','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OVERDUE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SCHEDULED','待开始','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SCHEDULED' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SCHEDULED','Scheduled','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SCHEDULED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INPROGRESS','进行中','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INPROGRESS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INPROGRESS','In Progress','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INPROGRESS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PlanColumnColorFill','计划条需填充色','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PlanColumnColorFill' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PlanColumnColorFill','Plan Column Requires Color Fill','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PlanColumnColorFill' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TodayColumnColorFill','今日列需填充色','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TodayColumnColorFill' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TodayColumnColorFill','Today Column Requires Color Fill','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TodayColumnColorFill' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CompletionProgress','完成进度','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CompletionProgress' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CompletionProgress','Completion Progress','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CompletionProgress' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk SET fieldlabel = "无法生成二维码，可能还未配置相关功能。请联系管理员点击“微信小程序”" where labelbol = "THEREISNOQRCODEPLEASECONTACTANDSET"
and languagetype = 'zh' and Labeltype = 'fixedstr';
UPDATE ld_desk SET fieldlabel = "无法生成二维码，可能还未配置相关功能。请联系管理员点击“微信小程序”" where labelbol = "THEREISNOQRCODEPLEASECONTACTANDSET2"
and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

call AddColumn('ld_wechatconvertuserid','convertuserid','varchar',255,'');
delimiter; 
update ld_wechatconvertuserid inner join 
ld_users on ld_users.id=ld_wechatconvertuserid.userid
set convertuserid=wx_userid where  wx_userid is not null and wx_userid<>'';
delimiter;
delete from ld_wechatconvertuserid where convertuserid is null or convertuserid='';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NOCONTENTTOCOPY','无内容可复制','jspop'
from dual WHERE NOT EXISTS(SELECT 1 from ld_desk where languagetype = 'zh' and labelbol = 'NOCONTENTTOCOPY' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NOCONTENTTOCOPY','No Content To Copy!','jspop'
from dual WHERE not EXISTS(SELECT 1 from ld_desk where languagetype = 'en' and labelbol = 'NOCONTENTTOCOPY' and Labeltype = 'jspop');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','COPY','复制','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COPY' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','COPY','Copy','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COPY' and labeltype='jspop');
delimiter;


update ld_relatedlists set presence='1' where name in('get_Kingdeequotes','get_Digiwinorders','get_Digiwintickets','get_Kingdeeorders');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_entryprofile_history_new`;
delimiter ||
CREATE  PROCEDURE `ldcrm_update_entryprofile_history_new`(

)BEGIN

	IF EXISTS (select 1 from information_schema.`COLUMNS` where TABLE_SCHEMA=database() and TABLE_NAME='ld_producttoolprofile' and column_name='create_profile') THEN
	DELETE FROM ld_producttoolprofile
	WHERE profilefieldtype = 'all'
	  AND IFNULL(create_profile, 'hidden') = 'hidden'
	  AND IFNULL(edit_profile, 'hidden') = 'hidden'
	  AND IFNULL(details_profile, 'hidden') = 'hidden';
	  
	DELETE FROM ld_tabdetailprofile
	WHERE profilefieldtype = 'all'
	  AND IFNULL(create_profile, 'hidden') = 'hidden'
	  AND IFNULL(edit_profile, 'hidden') = 'hidden'
	  AND IFNULL(details_profile, 'hidden') = 'hidden';
	END IF;
end ||
delimiter;

CALL ldcrm_update_entryprofile_history_new();
DROP PROCEDURE IF EXISTS `ldcrm_update_entryprofile_history_new`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HAVENOPRINTTEMPLATE','您没有适用的打印模板，请联系管理员检查并设置打印模板！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='HAVENOPRINTTEMPLATE_new' and Labeltype='jspop' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HAVENOPRINTTEMPLATE','You do not have an applicable print template, please contact your administrator to check and set up the print template!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='HAVENOPRINTTEMPLATE_new' and Labeltype='jspop' and languagetype='en');
delimiter;

SELECT fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=401 and fieldtype='multireference';
UPDATE ld_ws_multireferencetype SET fieldtypeid=@fieldtypeid where type='Accounts' and fieldtypeid IN (SELECT fieldtypeid from ld_ws_fieldtype where  fieldtype <>'multireference');
SELECT fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=402 and fieldtype='multireference';
UPDATE ld_ws_multireferencetype SET fieldtypeid=@fieldtypeid where type='Contacts' and fieldtypeid IN (SELECT fieldtypeid from ld_ws_fieldtype where  fieldtype <>'multireference');
SELECT fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=403 and fieldtype='multireference';
UPDATE ld_ws_multireferencetype SET fieldtypeid=@fieldtypeid where type='Products' and fieldtypeid IN (SELECT fieldtypeid from ld_ws_fieldtype where  fieldtype <>'multireference');
-- 2023-09-28

update ld_homestuffdetail set viewrange = '' where stuffid = 100;
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','SORTORDER','排序方式', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SORTORDER' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','SORTORDER','Sort Order', 'jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SORTORDER' AND labeltype = 'jspop' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','ADDSORTORDER','新增排序', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ADDSORTORDER' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','ADDSORTORDER','Add Sort Order', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ADDSORTORDER' AND labeltype = 'fixedstr' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','ASCENDINGORDER','升序', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'ASCENDINGORDER' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','ASCENDINGORDER','Ascending Order', 'jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'ASCENDINGORDER' AND labeltype = 'jspop' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','DESCENDINGORDER','降序', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'DESCENDINGORDER' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','DESCENDINGORDER','Descending Order', 'jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'DESCENDINGORDER' AND labeltype = 'jspop' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','SELECTONESORTORDER','请至少设置一种排序方式', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SELECTONESORTORDER' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','SELECTONESORTORDER','Please set at least one sort order', 'jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SELECTONESORTORDER' AND labeltype = 'jspop' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','UPTOTENSORTORDER','最多可设置十条排序方式', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'UPTOTENSORTORDER' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','UPTOTENSORTORDER','Up to ten sort order can be set', 'jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'UPTOTENSORTORDER' AND labeltype = 'jspop' );
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_cvcolumnlistsort_key`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_cvcolumnlistsort_key`(
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'ld_cvcolumnlistsort' AND COLUMN_NAME = 'sortid') THEN
			ALTER TABLE ld_cvcolumnlistsort ADD COLUMN sortid INT AUTO_INCREMENT PRIMARY KEY FIRST;
	END IF;
end ||
delimiter;

CALL ldcrm_reset_cvcolumnlistsort_key();
DROP PROCEDURE IF EXISTS `ldcrm_reset_cvcolumnlistsort_key`;
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'no',463,'设置销售发票，采购发票审批通过后计算已开票金额','',19,1,'select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 463);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',463,463,'设置{$Invoice.Invoice}，{$PurchaseInvoice.PurchaseInvoice}审批通过后计算已开票金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_systems_deploy' and tabid = 463 and relateid=463);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',463,463,'Set calculating have_invoicetotal after the approval of {$Invoice.Invoice},{$PurchaseInvoice.PurchaseInvoice}'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = 463 and relateid=463);
delimiter;
-- 2023-10-08

DELETE FROM ld_relatedlists WHERE name in('get_Kingdeequotes','get_Digiwinorders','get_Digiwintickets','get_Kingdeeorders');
update ld_appsystem set deploy_value = is_open,is_open = 'yes' where deploy_type = 14 and is_open != 'yes';
delimiter;

update ld_field set bigtype = 'text' where uitype = 255;
delimiter;
-- 2023-10-09

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

UPDATE ld_version SET old_version='V8.6.0.9',current_version='V8.6.0.9',remark='V8.6.0.9-20231009',wx_version='V8.6.0.9';
delimiter;