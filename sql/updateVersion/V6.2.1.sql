call AddColumn('ld_account','potentialid','int','11',0);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set columnname = 'potentialid',fieldname='potential_id',uitype='76' 
where tabid = @tabid and columnname ='lastpotential' and fieldname = 'lastpotential';
delimiter;
-- 2016-02-17


update (
	select t.potentialid,t.accountid from (
		select potentialid,accountid from ld_potential where accountid>0 order by accountid,createdtime desc) as t group by t.accountid) 
as f LEFT JOIN ld_account on f.accountid=ld_account.accountid set ld_account.potentialid=f.potentialid;
-- 2016-02-18

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
delimiter;

update ld_version set old_version='V6.2.1' ,current_version='V6.2.1' ,remark='V6.2.1-20160218(V6.2.0SP1)';
delimiter;