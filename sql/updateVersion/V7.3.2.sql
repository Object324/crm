insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','thedocumenthasbeendeleted','单据[%s]%s不成功！原因：该单据已经被删除！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thedocumenthasbeendeleted' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','thedocumenthasbeendeleted','单据[%s]%s不成功！原因：该单据已经被删除！The document [%s]%s is not successful! Reason: the document has been deleted!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thedocumenthasbeendeleted' and Labeltype = 'fixedstr');
delimiter;

UPDATE ld_actionmapping SET actionlabel='Merge' WHERE actionname='Merge';
SELECT actionid INTO @merge_actionid FROM ld_actionmapping WHERE actionname='Merge';
DELETE FROM ld_profileallpermission WHERE operation=@merge_actionid AND tabid NOT IN (
  select tabid from ld_tab where `name` IN ('Accounts','ServiceCharge','Contacts'));

SELECT actionid INTO @duplicates_actionid FROM ld_actionmapping WHERE actionname='DuplicatesHandling';
DELETE FROM ld_profileallpermission WHERE operation=@duplicates_actionid;
DELETE FROM ld_actionmapping WHERE actionname='DuplicatesHandling';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MASSELECTTEN','最多只能合并10条记录','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MASSELECTTEN' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MASSELECTTEN','You are allowed to select a maximum of ten records','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MASSELECTTEN' and Labeltype='jspop');
delimiter;
-- 2018-03-28

UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=27 AND NOT EXISTS (SELECT 1 FROM ld_contactrecords);
drop PROCEDURE  if EXISTS crm_addtab_intoprofile;
delimiter ||
create PROCEDURE crm_addtab_intoprofile
(
tabname varchar(100),
operation int(10)
)
BEGIN
		declare var_profileid int(19);
	  declare done  int  default 0;
	 declare cur1 CURSOR FOR SELECT profileid   FROM  ld_profile;
	 declare continue handler  for not   found  SET done =1;
  set @sql='select tabid into @tabid from ld_tab  where ';
	 set @sql=CONCAT(@sql, " name='",tabname,"'");
	prepare stmt from @sql;
	execute stmt;
	deallocate prepare stmt;
  open cur1;
	Fetch cur1 into var_profileid;
	loop1: while  done<>1 DO	
		
			set @sql=" insert into ld_profile2tab(profileid,tabid,permissions) select ";
			set @sql=concat(@sql,var_profileid,",",@tabid,",",0 ," from dual where not exists(select 1 from ld_profile2tab where tabid=",@tabid," and profileid=",var_profileid,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
		  set @sql=" insert into ld_profileallpermission(tabid,operation,sequence) select ";
			set @sql=concat(@sql,@tabid,",",operation ,",",0, " from dual where not exists(select 1 from ld_profileallpermission where tabid=",@tabid ,' and operation=',operation,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
			
			set @sql=" insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select ";
			set @sql=concat(@sql,var_profileid,',',@tabid,",",operation ,",",0,",",0, " from dual where not exists(select 1 from ld_profile2standardpermissions where profileid=" ,var_profileid," and tabid=",@tabid ,' and operation=',operation,")");
			prepare stmt from @sql;
			execute stmt;
			deallocate prepare stmt;
			Fetch cur1 into var_profileid;
	end while loop1;
	close cur1;
end ||
delimiter;

call crm_addtab_intoprofile('ChinaMap',3);
delimiter;
call crm_addtab_intoprofile('CooperativeWork',3);
delimiter;

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
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.3.2',current_version='V7.3.2',remark='V7.3.2-20180328',wx_version='V7.3.1';
delimiter;