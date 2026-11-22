update ld_desk set fieldlabel='组合数量' where labelbol='NUMBEROFCOPIES' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Combinations Number' where labelbol='NUMBEROFCOPIES' and labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='组合数量' where labelbol='NUMBEROFCOPIES' and labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='Combinations Number' where labelbol='NUMBEROFCOPIES' and labeltype='jspop' and languagetype='en';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTMORETHANTEN','More than 10 documents are selected, which takes a long time to export','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELECTMORETHANTEN' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTMORETHANTEN','选择超过10个单据，导出时间可能比较长','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTMORETHANTEN' and labeltype='jspop');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportCustomsOrder','Export cloud declaration template','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ExportCustomsOrder' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportCustomsOrder','导出云报关模板','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ExportCustomsOrder' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportCheckTemplate','Export check template','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ExportCheckTemplate' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportCheckTemplate','导出核对模板','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ExportCheckTemplate' and labeltype='fixedstr');
delimiter;



UPDATE ld_systems_deploy SET inputvalue='[{"value":"0","text":"HIDE"},{"value":"1","text":"MANDATORYFIELDS"},{"value":"2","text":"NONMANDATORY"},{"sql":""}]' WHERE deploy_type=143;


SET @roottype=8;
SET @deploy_type=211;
SET @deploy_value=0;
SET @description='设置移动端单据分录中录入产品管理时是否启用扫一扫添加产品功能。1:否，0:是';
SET @zh='设置移动端单据分录中录入{$Products.Products}时是否启用扫一扫添加产品功能';
SET @en='Set whether to enable the function of scanning to add products when entering product management into the mobile document entry';
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT @deploy_value,@deploy_type,@description,'',@seq+1,@roottype,'select',0 ,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);

INSERT INTO ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_systems_deploy',@deploy_type,@deploy_type,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@deploy_type AND relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');

INSERT INTO ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_systems_deploy',@deploy_type,@deploy_type,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@deploy_type AND relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');
delimiter;


SET @roottype=8;
SET @deploy_type=212;
SET @deploy_value=0;
SET @description='设置移动端单据分录中录入产品管理时是否启用PDA条码扫码功能。1:否，0:是';
SET @zh='设置移动端单据分录中录入{$Products.Products}时是否启用PDA条码扫码功能';
SET @en='Set whether to enable the function of PDA bar code scanning when entering product management into the mobile document entry';
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT @deploy_value,@deploy_type,@description,'',@seq+1,@roottype,'select',0 ,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);

INSERT INTO ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_systems_deploy',@deploy_type,@deploy_type,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@deploy_type AND relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');

INSERT INTO ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_systems_deploy',@deploy_type,@deploy_type,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@deploy_type AND relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

UPDATE ld_systems_deploy SET presence=1 WHERE deploy_type IN (211,212) AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);

delete  from ld_desk where labelbol = 'SELECTMORETHANTEN' and labeltype = 'jspop';
delimiter;
-- 2020-06-19

update ld_desk set fieldlabel='查看其他成员的单据详情' where labelbol='allowviewothers' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='查看自己创建的单据详情' where labelbol='ViewCreateMe' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='查看自己创建的单据详情（优先于角色权限）' where labelbol='ViewCreateMeTip' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='查询自己创建的单据列表' where labelbol='allowviewselfcreatedbill' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='允许查询自己创建的单据列表（负责人不是自己的单据）' where labelbol='viewselfbills' and labeltype='fixedstr' and languagetype='zh';
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

UPDATE ld_version SET old_version='V8.0.8',current_version='V8.0.8',remark='V8.0.8-20200619',wx_version='V8.0.8';
delimiter;