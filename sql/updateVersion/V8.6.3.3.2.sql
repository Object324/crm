insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOCREATEPAYMENTPLANTIP','，已自动生成{$PaymentPlan.PaymentPlan}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOCREATEPAYMENTPLANTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOCREATEPAYMENTPLANTIP',', automatically generated {$PaymentPlan.PaymentPlan}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOCREATEPAYMENTPLANTIP' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOCREATESENDPAYMENTTIP','，已自动生成{$SendPayment.SendPayment}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOCREATESENDPAYMENTTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOCREATESENDPAYMENTTIP',', automatically generated {$SendPayment.SendPayment}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOCREATESENDPAYMENTTIP' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_content_not_null','内容模板不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dingtalk_content_not_null' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_content_not_null',"Content Can't be empty!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dingtalk_content_not_null' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RECORDINGPERMISSIONMANAGEMENT','录音权限管理','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'RECORDINGPERMISSIONMANAGEMENT' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RECORDINGPERMISSIONMANAGEMENT','Recording permission management','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'RECORDINGPERMISSIONMANAGEMENT' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ABOUT','关于','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ABOUT' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ABOUT','About','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ABOUT' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='actual_amount_paid' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'pretax_salary_total'},{'lettervar':'b','column':'individual_income_tax'},{'lettervar':'c','column':'otherpayable_subtotal'}]}",
	'a-b+c',
	'',
	NOW(),
	NOW();
delimiter;
-- 2024-05-14

UPDATE ld_holiday SET wheatherholidays=1 WHERE holiday_title LIKE '%补假';
delimiter;

UPDATE ld_field SET uitype=15,typeofdata='V~O',bigtype='picklist' WHERE tablename='ld_holiday' AND columnname='wheatherholidays';
INSERT INTO ld_picklist_set(listname,relatetable,picklist_allowedit,picklist_allowdelete)
SELECT 'wheatherholidays','ld_field','no','no' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE listname='wheatherholidays');

SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='wheatherholidays' ORDER BY listid DESC LIMIT 1);
INSERT INTO ld_picklist_values(listid,listvalue,pick_color)
SELECT @listid,'班','#FF0000' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue='班');

INSERT INTO ld_picklist_values(listid,listvalue,pick_color)
SELECT @listid,'休','#0000FF' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue='休');
delimiter;

ALTER TABLE ld_holiday MODIFY COLUMN wheatherholidays VARCHAR(10);
UPDATE ld_holiday SET wheatherholidays='休' WHERE wheatherholidays=0;
UPDATE ld_holiday SET wheatherholidays='班' WHERE wheatherholidays=1;
UPDATE ld_holiday SET wheatherholidays='班' WHERE holiday_title LIKE '%补假';
delimiter;

UPDATE ld_systems_deploy SET roottype=4,sequence=-100 WHERE deploy_type=51;
SET @i=0;
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=4 ORDER BY sequence;
delimiter;

UPDATE ld_customreport_info 
SET 
	report_name=REPLACE(report_name,'——','_')
WHERE report_template IN ('default_performance_bycashbill.mrt','default_performance_byorder.mrt');

SET @report_name='项目提成表';
SET @report_type='template_js';
SET @report_template='default_performance_project.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT analysisfolder_id FROM ld_customreport_info WHERE report_template='default_performance_bycashbill.mrt' LIMIT 1);
SET @folderid=(SELECT folder_id FROM ld_customreport_info WHERE report_template='default_performance_bycashbill.mrt' LIMIT 1);
SET @seq=IFNULL((SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id),0);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,analysisfolder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype,createdtime)
SELECT @folderid,@id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink',NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);

SET @i=0;
SET @seq=(SELECT sequence FROM ld_customreport_info WHERE folder_id=@folderid AND report_template='default_performance_bycashbill.mrt');
UPDATE ld_customreport_info SET sequence=sequence+10 WHERE folder_id=@folderid AND sequence>@seq;
UPDATE ld_customreport_info SET sequence=@seq+2 WHERE report_template='default_performance_project.mrt';
UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@folderid ORDER BY sequence;
delimiter;
-- 2024-05-20

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

UPDATE ld_version SET old_version='V8.6.3.3.2',current_version='V8.6.3.3.2',remark='V8.6.3.3.2-20240520',wx_version='V8.6.3.2';
delimiter;