insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'sign_recalculate','rely','重算误差','sign_recalculate.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'sign_recalculate');
delimiter;

set @bigintabid = (select tabid from ld_tab where `name`='CustomForm181');
set @endtabid = (select tabid from ld_tab where `name`='CustomForm200');
update ld_tabdetailfield set allowhide = 'yes' where tabid BETWEEN @bigintabid and @endtabid and columnname in ( 'amount','total');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`='CollectionSlip');
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

SET @labelbol = 'TIMESPERYEAR';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'次/年',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' times/year',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

ALTER TABLE `ld_linkmodulecustom` MODIFY COLUMN `url` text;
delimiter;


UPDATE  ld_tabdetailfield SET defaultcolumn=1 WHERE tabid=67 AND defaultcolumn IN (3,7);

select tabid into @tabid from ld_tab where name = 'VisualAnalysis';
update ld_profileallpermission set sequence = 1 where tabid=@tabid and operation = 4;
update ld_profileallpermission set sequence = 2 where tabid=@tabid and operation = 11;
update ld_profileallpermission set sequence = 3 where tabid=@tabid and operation = 1;
update ld_profileallpermission set sequence = 4 where tabid=@tabid and operation = 2;
update ld_profileallpermission set sequence = 5 where tabid=@tabid and operation = 13;
update ld_profileallpermission set sequence = 6 where tabid=@tabid and operation = 3;
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SIGNINSTATISTICS';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_singin:record:record:OftenUseReport_拜访对象类型:V';
SELECT (CASE WHEN presence = 0 THEN 1 WHEN presence != 0 THEN 0 END) INTO @columnshow FROM ld_tab WHERE name = "Singin";
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence and Usereportid=@usereportid;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_singin:signout_time:signout_time:OftenUseReport_signout_time:D', @sequence, @columnshow, 'ld_singin:signout_time:signout_time:OftenUseReport_签退时间:D','ld_singin:signout_time:signout_time:OftenUseReport_Sign out Time:D' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_singin:signout_time:signout_time:OftenUseReport_signout_time%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SIGNINSTATISTICS';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_singin:record:record:OftenUseReport_拜访对象类型:V';
SELECT (CASE WHEN presence = 0 THEN 1 WHEN presence != 0 THEN 0 END) INTO @columnshow FROM ld_tab WHERE name = "Singin";
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence and Usereportid=@usereportid;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_singin:signout_address:signout_address:OftenUseReport_signout_address:V', @sequence, @columnshow, 'ld_singin:signout_address:signout_address:OftenUseReport_签退地址:V','ld_singin:signout_address:signout_address:OftenUseReport_Sign out Address:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_singin:signout_address:signout_address:OftenUseReport_signout_address%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SIGNINSTATISTICS';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_singin:record:record:OftenUseReport_拜访对象类型:V';
SELECT (CASE WHEN presence = 0 THEN 1 WHEN presence != 0 THEN 0 END) INTO @columnshow FROM ld_tab WHERE name = "Singin";
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence and Usereportid=@usereportid;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_singin:signout_distance:signout_distance:OftenUseReport_signout_distance:V', @sequence, @columnshow, 'ld_singin:signout_distance:signout_distance:OftenUseReport_签退误差(米):V','ld_singin:signout_distance:signout_distance:OftenUseReport_Sign out Distance(m):V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_singin:signout_distance:signout_distance:OftenUseReport_signout_distance%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SIGNINSTATISTICS';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_singin:record:record:OftenUseReport_拜访对象类型:V';
SELECT (CASE WHEN presence = 0 THEN 1 WHEN presence != 0 THEN 0 END) INTO @columnshow FROM ld_tab WHERE name = "Singin";
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence and Usereportid=@usereportid;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_singin:timeused:timeused:OftenUseReport_timeused:V', @sequence, @columnshow, 'ld_singin:timeused:timeused:OftenUseReport_用时:V','ld_singin:timeused:timeused:OftenUseReport_Time:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_singin:timeused:timeused:OftenUseReport_timeused%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SIGNINSTATISTICS';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_singin:record:record:OftenUseReport_拜访对象类型:V';
SELECT (CASE WHEN presence = 0 THEN 1 WHEN presence != 0 THEN 0 END) INTO @columnshow FROM ld_tab WHERE name = "Singin";
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence and Usereportid=@usereportid;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_singin:signout_type:signout_type:OftenUseReport_signout_type:V', @sequence, @columnshow, 'ld_singin:signout_type:signout_type:OftenUseReport_签退方式:V','ld_singin:signout_type:signout_type:OftenUseReport_Sign out way:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_singin:signout_type:signout_type:OftenUseReport_signout_type%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SIGNINSTATISTICS';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_attachmentsforsign:picture:picture:OftenUseReport_图片:V';
SELECT (CASE WHEN presence = 0 THEN 1 WHEN presence != 0 THEN 0 END) INTO @columnshow FROM ld_tab WHERE name = "Singin";
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence+1 and Usereportid=@usereportid;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_singin:signout_imagename:signout_imagename:OftenUseReport_signout_imagename:V', @sequence+1, @columnshow, 'ld_singin:signout_imagename:signout_imagename:OftenUseReport_签退图片:V','ld_singin:signout_imagename:signout_imagename:OftenUseReport_Sign out photo:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_singin:signout_imagename:signout_imagename:OftenUseReport_signout_imagename%' and Usereportid=@usereportid);
delimiter;
-- 2024-04-03

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
select blockid into @blockid from ld_BLOCKS where tabid=@tabid and blocklabel='LBL_FILE_INFORMATION';
UPDATE ld_field SET block = @blockid,sequence=1 WHERE tabid = @tabid and columnname = 'signout_imagename';
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
UPDATE ld_field SET displaytype = 2 WHERE tabid = @tabid and columnname = 'signout_type';
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = @sequence WHERE tabid = @tabid and columnname = 'source_list';
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence;

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = @sequence WHERE tabid = @tabid and columnname = 'entityaddress';
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence;

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = @sequence WHERE tabid = @tabid and columnname = 'signin_id';
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence;
delimiter;

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

UPDATE ld_version SET old_version='V8.6.2.9',current_version='V8.6.2.9',remark='V8.6.2.9-20240403',wx_version='V8.6.2.9';
delimiter;