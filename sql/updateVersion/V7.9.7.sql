update ld_tranlabel set fieldlabel = '设置序时簿列表界面批量操作记录条数的上限' 
where trantable = 'ld_systems_deploy' and tabid = 67 and Relateid = 67 and languagetype = 'zh';
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type=137;
update ld_systems_deploy set sequence=sequence+1000 where roottype=@roottype and sequence>@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 1,206,'设置序时簿列表界面文本和文本区域字段类型的字段内容是否换行显示',@sequence+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy  where deploy_type=206);
set @i=@sequence;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=@roottype order by sequence asc;
delimiter;
insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',206,206,'设置序时簿列表界面文本区域字段类型的字段内容是否换行显示' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=206 and relateid=206 and trantable='ld_systems_deploy' and languagetype='zh');

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',206,206,'Set whether the field contents of the sequence book list interface  text area field type are displayed in a new line' from DUAL 
where not exists(select 1 from ld_tranlabel where tabid=206 and relateid=206 and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

update ld_tabdetailfield set defaultcolumn=1 
where tabid in(select tabid from ld_tab where name='expense') and columnname='rmb_total';
delimiter;

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_Stock_ReconciliationReport.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_OutboundOrder_ReconciliationReport.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_OutboundOrder_Reconcil.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_cashbill_yushou.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_salesorder_outbound.mrt';
delimiter;

insert into ld_desk (languagetype,fieldlabel,labeltype,labelbol)
select 'zh','新变量','fixedstr','NewVar' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewVar' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,fieldlabel,labeltype,labelbol)
select 'en','New variable','fixedstr','NewVar' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewVar' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='All the number or date of field types can calculate.' where labelbol='ALLTHENUMBERORDATEOFFIELDTYPESCANCALCULATE'
and languagetype='en';

update ld_desk set fieldlabel='Can have at most 10 variables.' where labelbol='CANHAVEATMOST10VARIABLES'
and languagetype='en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MAP','地图','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MAP' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MAP','map','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'MAP' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

update ld_dashboard_app set home_sequence=1 where name='Saleskit';
update ld_dashboard_app set home_sequence=2 where name='Contractkit';
delimiter;

update ld_sendcashbill2payment 
INNER JOIN ld_sendpayment on ld_sendpayment.sendpaymentid=ld_sendcashbill2payment.entitytypeid
set ld_sendcashbill2payment.pay_amount=ld_sendpayment.Actualamount;
delimiter;

update ld_sendcashbill2payment 
INNER JOIN ld_purchaseorder on ld_purchaseorder.purchaseorderid=ld_sendcashbill2payment.entitytypeid
set ld_sendcashbill2payment.pay_amount=ld_purchaseorder.pay_amount;
delimiter;
-- 2019-11-22

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

UPDATE ld_version SET old_version='V7.9.7',current_version='V7.9.7',remark='V7.9.7-20191122',wx_version='V7.9.7';
delimiter;