drop PROCEDURE if exists deleteApproveLogByDelete;
delimiter ||
create PROCEDURE deleteApproveLogByDelete()
begin
	declare table_name varchar(200);
	declare table_index varchar(200);
	declare done  int  default 0;
		declare cur1 CURSOR FOR select tablename,entityidfield  from ld_systems_deploy 
		inner join  ld_entityname  on ld_systems_deploy.setype=ld_entityname.modulename
		where setype is not null and setype<>'';
		declare continue handler  for not   found  SET done =1;
	 OPEN cur1;
	 Fetch cur1 into table_name,table_index;
		loop1: while  done<>1 DO
			
				set @sql=CONCAT('delete from ld_approvelog where crmid in(select ' ,table_index,' from ', table_name,' where deleted=1 ) ');

				prepare stmtt from @sql;
			  execute stmtt;
			  deallocate  prepare stmtt;
				
			  Fetch cur1 into table_name,table_index;
		end while loop1;
		close cur1;
end ||
delimiter;

call deleteApproveLogByDelete();
delimiter;
-- 2017-03-06

update ld_producttoolfield set uitype = 69 where columnname = 'imagename' and input_type = 1;
-- 2017-03-09 

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

update ld_version set old_version='V6.6.5',current_version='V6.6.5',remark='V6.6.5-20170309';
delimiter;