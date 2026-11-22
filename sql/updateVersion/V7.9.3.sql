select tabid into @tabid from ld_tab where name='Commission';
update ld_field set uitype=72 where tabid=@tabid and uitype=222 and fieldname in ('hdnSubTotal','noamount') and tablename='ld_commission';

select tabsequence into @tabsequence from ld_tab  where name='contactrecords';
update ld_tab set tabsequence=@tabsequence where name='CooperativeWork';
delimiter;

update ld_tab INNER JOIN (
SELECT @sequnece:=@sequnece+1 AS seq,name FROM (SELECT @sequnece:=0) r, ld_tab 
 ORDER BY tabsequence asc ,tabid desc
) as tmpone on tmpone.name=ld_tab.name 
set ld_tab.tabsequence=tmpone.seq;
delimiter;

select ruleid into @ruleid from ld_def_org_share where tabid=6;
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid, 4,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=4);
delimiter;

update ld_def_org_share set editstatus=0 where tabid=4;
delimiter;

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_workreport_daily.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_workreport_weekly.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_workreport_monthly.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_panorama.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='oa_attendance_statistics.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_performance_byorder.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_performance_bycashbill.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_warehouse_products.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_account_servicereport.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_salesorder_avg_amount.mrt';

select usereportid into @reportid from ld_usereport where name='InventoryAccount';
select Sequence into @sequence from ld_usereportcolumns where columns like 'ld_products:productname:productname%' and Usereportid=@reportid limit 1;
update ld_usereportcolumns set Sequence=Sequence+1 where Usereportid=@reportid and Sequence > @sequence;
insert into ld_usereportcolumns (Usereportid,columns, Sequence,columnshow, realcolumns, realencolumns, is_advanced)
  select @reportid,'ld_products:product_no:product_no:Products_产品编号#:V',@sequence+1,1,
    'ld_products:product_no:product_no:Products_产品编号:V','ld_products:product_no:product_no:Products_Product No:V',0 from dual where not exists(
      select 1 from ld_usereportcolumns where columns like 'ld_products:product_no:product_no%' and Usereportid=@reportid);
set @i = 0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid=@reportid order by  Sequence asc ;
delimiter;

update ld_desk set fieldlabel='该单据审批步骤已变化，请重新加载改单据！' 
where labelbol='Approvestephavechangetip' and languagetype='zh';
delimiter;
-- 2019-10-23

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

UPDATE ld_version SET old_version='V7.9.3',current_version='V7.9.3',remark='V7.9.3-20191023',wx_version='V7.9.3';
delimiter;