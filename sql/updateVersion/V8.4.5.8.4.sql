UPDATE ld_field SET typeofdata = 'V~O' WHERE  columnname = 'potentialid' AND uitype=76 AND bigtype='reference' AND typeofdata ='I~O' ;
delimiter;
UPDATE ld_field SET typeofdata = 'V~M' WHERE  columnname = 'potentialid' AND uitype=76 AND bigtype='reference' AND typeofdata ='I~M' ;
delimiter;
-- 2022-04-10


SET @labelbol = 'SETADDRESSASVISIT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否将签到地址设置为拜访对象地址？','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Set the check-in address as the address of the visiting object?','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SETADDRESSASVISIT';
UPDATE ld_desk SET fieldlabel = '您的拜访对象还没有地址，是否需要将签到地址设置为拜访对象地址？' where labelbol = @labelbol and languagetype = 'zh' and Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel = "Your visitor does n't have an address yet. Do you need to set the sign in address as the visitor's address?" where labelbol = @labelbol and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
-- 2022-04-15

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

UPDATE ld_version SET old_version='V8.4.5.8.4',current_version='V8.4.5.8.4',remark='V8.4.5.8.4-20220415',wx_version='V8.4.5.8.4';
delimiter;