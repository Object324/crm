select tabid into @tabid from ld_tab where name='customform12';
select max(fieldid) into @maxfieldid from ld_field;
select block into @block from ld_field where tabid=@tabid and columnname='smownerid';
select presence into @presence from ld_producttoolfield where tabid=@tabid and columnname='adjustment';
update ld_field_seq set id=id+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='adjustment');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,uitype,fieldname,fieldlabel,presence,sequence,block,displaytype,typeofdata)

select @tabid,@maxfieldid+1,'adjustment','yes','ld_customform12',72,'txtAdjustment','调整',@presence,10,@block,3,'NN~O' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='adjustment');
delimiter;

select tabid into @tabid from ld_tab where name='customform12';
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='adjustment';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field',@tabid,@fieldid ,'调整' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and relateid=@fieldid and trantable='ld_field'); 

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field',@tabid,@fieldid ,'Adjustment' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and relateid=@fieldid and trantable='ld_field'
); 
delimiter;

update ld_relatedlists set related_tabid=-12,related_coltable='',type='' where name='get_singin';
delimiter;
-- 2020-05-28

SET @disable_triggers=1;
UPDATE ld_cashbill SET currency_id=1,currency_symbol='¥',conversion_rate='1.000000' WHERE currency_id=0; 


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

UPDATE ld_version SET old_version='V8.0.2',current_version='V8.0.2',remark='V8.0.2-20200528',wx_version='V8.0.1.5';
delimiter;