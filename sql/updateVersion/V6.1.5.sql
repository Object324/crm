select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
delete from ld_profileallpermission where tabid = @tabid and operation = 12;
delimiter;

select tabid into @tabid from ld_tab where `name` ='SendPayment';
delete from ld_profileallpermission where tabid = @tabid and operation = 12;
delimiter;
-- 2015-11-04

update ld_attachmentsforbills inner join ld_crmentity on ld_attachmentsforbills.related_to=ld_crmentity.crmid 
set reltab=ld_crmentity.setype;
delimiter;
-- 2015-11-05

update ld_desk set fieldlabel='Field' where fieldlabel='Lookup field';
delimiter;

update ld_desk set fieldlabel='Keyword' where fieldlabel='keyword';
delimiter;

update ld_tranlabel set fieldlabel='编码或条码' where tabid=14 and Relateid=176 and trantable='ld_field' and languagetype='zh';
-- 2015-11-06

update ld_field set typeofdata='V~O' where uitype=202 and tabid in(select  tabid from ld_tab where name='expense');
delimiter;
-- 2015-11-09

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
delimiter;

update ld_version set old_version='V6.1.5' ,current_version='V6.1.5' ,remark='V6.1.5-20151109';
delimiter;