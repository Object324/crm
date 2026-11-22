update ld_desk set fieldlabel='正在导出数据，请不要关闭或刷新浏览器' where labelbol='EXPORTINGDATA' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Exporting data, please do not close or refresh the browser' where labelbol='EXPORTINGDATA' and Labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_relatedlists set actions='add' where tabid in(select tabid from ld_tab where name='ServiceContracts') and name='get_paymentplan';

UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'V~0','V~O');
UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'~o','~O');
-- 2019-07-01

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

UPDATE ld_version SET old_version='V7.8.1.1',current_version='V7.8.1.1',remark='V7.8.1.1-20190706',wx_version='V7.8.2';
delimiter;