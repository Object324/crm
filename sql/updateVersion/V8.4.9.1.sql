UPDATE ld_actionmapping set actionlabel = 'Batchonshelves' where actionname = 'BatchOnShelves';
UPDATE ld_actionmapping set actionlabel = 'Batchoffshelves' where actionname = 'BatchOffShelves';
delimiter;

SET @labelbol = 'OPENNEWPAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'打开新页签','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Open new page','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk set fieldlabel = '双击查看' where labelbol='DOUBLECLICKTOSEEDETAILS' and fieldlabel = '双击查看详情';
UPDATE ld_desk set fieldlabel = 'Double-click to see' where labelbol='DOUBLECLICKTOSEEDETAILS' and fieldlabel = 'Double-click to see details';
delimiter;


UPDATE ld_field SET presence=1 WHERE tabid=22 AND columnname='parentid' AND NOT EXISTS (SELECT 1 FROM ld_salesorder);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEENTERTHECORRECT','请输入正确的','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASEENTERTHECORRECT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEENTERTHECORRECT',"Please enter the correct ",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASEENTERTHECORRECT' and labeltype='fixedstr');
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='singin' LIMIT 1);
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='entityaddress' LIMIT 1);
UPDATE ld_related_field 
SET fromvalue_info=REPLACE(fromvalue_info,'ld_account.bill_state','IFNULL(ld_account.bill_state,"")') 
WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid
	AND fromvalue_info NOT LIKE '%IFNULL(ld_account.bill_state%';
UPDATE ld_related_field 
SET fromvalue_info=REPLACE(fromvalue_info,'ld_account.bill_city','IFNULL(ld_account.bill_city,"")') 
WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid
	AND fromvalue_info NOT LIKE '%IFNULL(ld_account.bill_city%';
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='singin' LIMIT 1);
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='address' LIMIT 1);
UPDATE ld_related_field 
SET fromvalue_info=REPLACE(fromvalue_info,'ld_account.bill_state','IFNULL(ld_account.bill_state,"")') 
WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid
	AND fromvalue_info NOT LIKE '%IFNULL(ld_account.bill_state%';
UPDATE ld_related_field 
SET fromvalue_info=REPLACE(fromvalue_info,'ld_account.bill_city','IFNULL(ld_account.bill_city,"")') 
WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid
	AND fromvalue_info NOT LIKE '%IFNULL(ld_account.bill_city%';
delimiter;
-- 2023-03-03

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

UPDATE ld_version SET old_version='V8.4.9.1',current_version='V8.4.9.1',remark='V8.4.9.1-20230303',wx_version='V8.4.9.1';
delimiter;