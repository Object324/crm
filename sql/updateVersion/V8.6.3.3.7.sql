UPDATE ld_producttoolfield set bigtype='tax' where uitype=17 and bigtype is  null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MASSELECTTENTIP','您勾选了{Var}条记录，最多可合并前10条记录，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MASSELECTTENTIP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MASSELECTTENTIP',"You have selected {Var} records and can merge up to the first 10 records. Do you want to continue?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MASSELECTTENTIP' and labeltype='jspop');
delimiter;

drop PROCEDURE if exists `addReferenceUitypmodule`;
delimiter ||
create PROCEDURE `addReferenceUitypmodule`(
    referencemodule varchar(100)
)
begin
    IF NOT EXISTS (select 1 from ld_ws_fieldtype INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid  where type=referencemodule) THEN
        select max(uitype+0) into @maxuitype from ld_ws_fieldtype;
        if @maxuitype<2000  then
		    set @maxuitype=2000;
        else
			set @maxuitype=@maxuitype+1;
        end if;
        set @sql=concat('insert into ld_ws_fieldtype(uitype,fieldtype)value("',@maxuitype,'","reference")');
        prepare stmta from @sql;
        execute stmta;
        deallocate prepare stmta;
        set @sql=concat('select fieldtypeid  into @lastid from ld_ws_fieldtype where uitype ="',@maxuitype,'"');
        prepare stmt1 from @sql;
        execute stmt1;
        deallocate prepare stmt1;

        set @sql=concat('insert into ld_ws_referencetype(fieldtypeid,type)value("',@lastid,'","',referencemodule,'")');
        prepare stmt2 from @sql;
        execute stmt2;
        deallocate prepare stmt2;
    END IF;
end ||
delimiter;
call addReferenceUitypmodule('CustomForm14');
DROP PROCEDURE IF EXISTS `addReferenceUitypmodule`;
delimiter;

set @tabid = (select tabid from ld_tab where `name`='BudgetChange');
set @uitype = (select uitype from ld_ws_fieldtype INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid  where type='CustomForm14');
update ld_field set uitype = @uitype where tabid=@tabid and columnname='customform14id';
delimiter;

UPDATE ld_desk SET fieldlabel = '不允许直接新增，可通过{$CustomForm14.CustomForm14}关联新建' WHERE labelbol = 'How_to_create_budgetchange_infos' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Direct addition is not allowed, but can be created through association with {$CustomForm14.CustomForm14}' WHERE labelbol = 'How_to_create_budgetchange_infos' AND languagetype = 'en';
delimiter;
-- 2024-07-19

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

UPDATE ld_version SET old_version='V8.6.3.3.7',current_version='V8.6.3.3.7',remark='V8.6.3.3.7-20240719',wx_version='V8.6.3.9';
delimiter;