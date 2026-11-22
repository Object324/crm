update ld_bankaccountset 
inner join ld_currency_info on ld_bankaccountset.currency_id=ld_currency_info.id
set ld_bankaccountset.conversion_rate=ld_currency_info.conversion_rate,ld_bankaccountset.currency_symbol=ld_currency_info.currency_symbol
where ld_bankaccountset.conversion_rate is null or ld_bankaccountset.conversion_rate=0;
delimiter;

update ld_expense INNER JOIN ld_bankaccountset on ld_bankaccountset.Bankaccountsetid=ld_expense.bankaccountsetid
set ld_expense.currency_id=ld_bankaccountset.currency_id,ld_expense.currency_symbol=ld_bankaccountset.currency_symbol,ld_expense.conversion_rate=ld_bankaccountset.conversion_rate;
delimiter;


update ld_tranlabel set fieldlabel='Quantity shipped' where fieldlabel='Quantity of shipped shipment';
delimiter;

update ld_tranlabel set fieldlabel='Unshipped Quantity' where fieldlabel='quantity of non-shipment';
delimiter;

update ld_tranlabel set fieldlabel='Invoiced amount' where fieldlabel='Have the invoice amount';
delimiter;

update ld_tranlabel set fieldlabel='Uninvoiced amount' where fieldlabel='Not the invoice amount';
delimiter;

update ld_tranlabel set fieldlabel='Unshipped amount' where fieldlabel='amount of non-shipment';
delimiter;

update ld_tranlabel set fieldlabel='Balance receivable' where fieldlabel='Receivable Balance';
delimiter;

update ld_tranlabel set fieldlabel='Latest collection date' where fieldlabel='Cashbill Date';
delimiter;

update ld_tranlabel set fieldlabel='Latest Invoicing Date' where fieldlabel='Last Invoice Date';
delimiter;

update ld_tranlabel set fieldlabel='Latest shipment date' where fieldlabel='latest date of shipment';
delimiter;

update ld_desk set fieldlabel='用户账号只能由字母、数字、下划线组成，不能输入其他特殊符号！' 
where labelbol='ACCOUNTBYTO' and languagetype='zh';
update ld_desk set fieldlabel='User account can only be composed of letters, numbers and underscores. No other special symbols can be entered!' 
where labelbol='ACCOUNTBYTO' and languagetype='en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DINGTALKONDUTY','上班打卡','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKONDUTY' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DINGTALKONDUTY','Checkin','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKONDUTY' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DINGTALKOFFDUTY','下班打卡','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKOFFDUTY' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DINGTALKOFFDUTY','Checkout','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKOFFDUTY' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DINGTALKREISSUE','补卡','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKREISSUE' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DINGTALKREISSUE','Reissue','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKREISSUE' and languagetype='en' and labeltype = 'fixedstr');

update ld_desk set fieldlabel='同步考勤打卡数据'
where languagetype='zh' and labelbol='CHECKINSYNCBUTTON';
update ld_desk set fieldlabel='Synchronize timing-in data'
where languagetype='en' and labelbol='CHECKINSYNCBUTTON';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DINGTALK','钉钉','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALK' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DINGTALK','DingTalk','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALK' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTINGDINGTALK1','考勤类型设置','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTINGDINGTALK1' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTINGDINGTALK1','Attendance type setting','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTINGDINGTALK1' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTINGDINGTALK2','选择考勤类型','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTINGDINGTALK2' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTINGDINGTALK2','Select attendance type','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTINGDINGTALK2' and languagetype='en' and labeltype = 'fixedstr');

update ld_desk set fieldlabel='接入企业微信/钉钉考勤打卡数据并增加相关的考勤统计表'
where languagetype='zh' and labelbol='CHECKINSETTING_DESCRIB';
update ld_desk set fieldlabel='Get enterprise Wechat/DingTalk attendance data and add related report'
where languagetype='en' and labelbol='CHECKINSETTING_DESCRIB';

update ld_desk set fieldlabel='考勤接口设置'
where languagetype='zh' and labelbol='CHECKINSETTING';
update ld_desk set fieldlabel='Enterprise Attendance Data Interface'
where languagetype='en' and labelbol='CHECKINSETTING';

update ld_desk set fieldlabel='请确认考勤参数配置是否正确，详细设置方法请点击右上角“帮助”按钮！'
where languagetype='zh' and labelbol='CHECKINSETTING_TITLE4';
update ld_desk set fieldlabel='Please confirm whether the enterprise card parameter configuration is correct. For detailed setting method, please click the “Help” button in the upper right corner!'
where languagetype='en' and labelbol='CHECKINSETTING_TITLE4';

create table if not exists `ld_wx_checkin_dingtalk`(
  `id` bigint primary key comment '钉钉打卡唯一标识ID',
  `userid` varchar(255) comment '钉钉用户ID',
  `groupid` bigint  comment '考勤组ID',
  `planid` bigint  comment '排班ID',
  `recordid` bigint  comment '打卡记录ID',
  `checktype` varchar(255) comment '考勤类型,OnDuty：上班 OffDuty：下班',
  `timeresult` varchar(255) comment '时间结果 Normal：正常;Early：早退;Late：迟到;SeriousLate：严重迟到；Absenteeism：旷工迟到；NotSigned：未打卡',
  `workdate_date` datetime comment '格式化工作日',
  `basechecktime_date` datetime comment '格式化计算迟到和早退，基准时间',
  `userchecktime_date` datetime comment '格式化实际打卡时间,  用户打卡时间的毫秒数',
  `workdate` bigint comment '工作日',
  `basechecktime` bigint comment '计算迟到和早退，基准时间',
  `userchecktime` bigint comment '实际打卡时间,  用户打卡时间的毫秒数',
  `locationresult` varchar(255) comment '位置结果 Normal：范围内；Outside：范围外；NotSigned：未打卡',
  `approveid` bigint comment '关联的审批id，当该字段非空时，表示打卡记录与请假、加班等审批有关',
  `procinstid` bigint comment '关联的审批实例id，当该字段非空时，表示打卡记录与请假、加班等审批有关。可以与获取单个审批数据配合使用',
  `sourceType` varchar(255) comment '数据来源'
);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DINGTALKREMINDONE','请确认钉钉接口设置中参数配置是否正确','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKREMINDONE' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DINGTALKREMINDONE','Please confirm whether the parameter configuration in the DingTalk interface setting is correct','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKREMINDONE' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_workreport_daily.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_workreport_weekly.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_workreport_monthly.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_panorama.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='oa_attendance_statistics.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_performance_byorder.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_performance_bycashbill.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_warehouse_products.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_servicereport.mrt';


UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_salesorder_avg_amount.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_category_distribution.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_CustomersStatus.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_CustomersSource.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_ImportantLevel.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_Industry.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_Relations.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_Staffsize.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_AnnualRevenue.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_RegisteredCapital.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_ContactRecords_ContactType.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_cashbilltop10.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_cashbilltop50.mrt';

SET @seq=(SELECT sequence FROM ld_customreport_info WHERE report_template='default_account_cashbilltop50.mrt');
SET @myid=(SELECT folder_id FROM ld_customreport_info WHERE report_template='default_account_cashbilltop50.mrt');
UPDATE ld_customreport_info SET sequence=sequence+5 WHERE folder_id=@myid AND sequence>@seq;

SET @folder_id=(SELECT folder_id FROM ld_customreport_info WHERE report_template='default_account_qianyuetop10.mrt');
UPDATE ld_customreport_info SET folder_id=@myid,sequence=@seq+1 WHERE report_template='default_account_qianyuetop10.mrt' AND NOT EXISTS (SELECT 1 FROM ld_customreport_folder WHERE id=@folder_id);

SET @folder_id=(SELECT folder_id FROM ld_customreport_info WHERE report_template='default_account_qianyuetop50.mrt');
UPDATE ld_customreport_info SET folder_id=@myid,sequence=@seq+2 WHERE report_template='default_account_qianyuetop50.mrt' AND NOT EXISTS (SELECT 1 FROM ld_customreport_folder WHERE id=@folder_id);

SET @i=0;
UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@myid ORDER BY sequence;
delimiter;

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_qianyuetop10.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_qianyuetop50.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_ContactRecords_kehulianxicishuTOP10.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_ContactRecords_kehulianxicishuTOP50.mrt';


UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_tickets_times.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_serviers_times.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_tickets_category.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_tongbi_payment.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_tongbi_paymentQty.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_tongbi_salesorder.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_tongbi_salesorderQty.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_huanbi_payment.mrt';
-- 2019-10-31

update ld_desk set fieldlabel='同步企业微信考勤打卡数据'
where languagetype='zh' and labelbol='CHECKINSYNCBUTTON';
update ld_desk set fieldlabel='Synchronize WeChat checkin data'
where languagetype='en' and labelbol='CHECKINSYNCBUTTON';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSYNCBUTTONDINGTALK','同步钉钉考勤打卡数据','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSYNCBUTTONDINGTALK' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSYNCBUTTONDINGTALK','Synchronize DingTalk checkin data','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSYNCBUTTONDINGTALK' and languagetype='en' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DINGTALKSYNCBUTTONREMIND','请确认钉钉接口设置中参数配置是否正确，详细设置方法请点击右上角“帮助”按钮！','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKSYNCBUTTONREMIND' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DINGTALKSYNCBUTTONREMIND','Please confirm whether the parameter configuration in the DingTalk interface setting is correct, please click the “Help” button in the upper right corner!','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'DINGTALKSYNCBUTTONREMIND' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
-- 2019-11-04

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

UPDATE ld_version SET old_version='V7.9.4',current_version='V7.9.4',remark='V7.9.4-20191104',wx_version='V7.9.3';
delimiter;