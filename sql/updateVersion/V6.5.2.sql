update ld_desk set fieldlabel='Orders Amount Year-on-year' where labelbol='AMOUNTMONTHCONTRACTYEAR' and languagetype='en';
update ld_desk set fieldlabel='签约金额同比' where labelbol='AMOUNTMONTHCONTRACTYEAR' and languagetype='zh';
update ld_desk set fieldlabel='Received Amount Year-on-year' where labelbol='BACKAMOUNTMONTHYEAR' and languagetype='en';
update ld_desk set fieldlabel='回款金额同比' where labelbol='BACKAMOUNTMONTHYEAR' and languagetype='zh';
-- 2016-11-07

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
delimiter;

update ld_version set old_version='V6.5.2' ,current_version='V6.5.2' ,remark='V6.5.2-20161107';
delimiter;