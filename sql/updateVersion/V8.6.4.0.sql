insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseSelectOneRelatedModule','请至少选择一个相关信息模块','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSelectOneRelatedModule' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseSelectOneRelatedModule','Please select at least one module from the relevant information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSelectOneRelatedModule' and labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE if not exists `ld_passwordchangecheckuser` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `userid` int(11),
    `mobiletype` varchar(50),
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB;
delimiter;

call AddColumn('ld_settings_advance','use_dependency','varchar','20',NULL);
UPDATE ld_settings_advance set use_dependency = 'yes' where IFNULL(use_dependency,'') = '';
delimiter;

SET @labelbol = 'NoRepetitionAllowed';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不允许重复',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No repetition allowed',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
UPDATE ld_signout 
INNER JOIN ld_singin ON ld_signout.signoutid = ld_singin.signout_id
INNER JOIN ld_option_module ON ld_singin.tabid = ld_option_module.option_tabid 
SET ld_signout.signout_type = 'supsign',ld_singin.signout_type = 'supsign'
WHERE ld_option_module.tabid = @tabid and ld_signout.signout_type is NULL
and ld_signout.signout_distance > ld_option_module.allowable_distance and ld_option_module.allowsupsignout = 'yes'
and ld_option_module.no_signin = 'yes';
delimiter;

UPDATE ld_signout SET signout_type = 'signout' WHERE signout_type IS NULL;
UPDATE ld_singin SET signout_type = 'signout' WHERE (signout_type IS NULL or signout_type = '') and signout_id > 0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PUBLISHFAILED','发布失败','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PUBLISHFAILED' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PUBLISHFAILED','Publish failed','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PUBLISHFAILED' and labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE if not exists `ld_workreport_modtracker` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `workreportid` int(16),
    `fieldname` varchar(100),
    `changedon` datetime,
    `prevalue` text,
     `postvalue` text,
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB;
delimiter;

CALL AddColumn('ld_workreport','editcount','int','4',0);
delimiter;


select  usereportid into @usereportid from ld_usereport where name='ServiceKanBan';

update ld_usereportcolumns set `columns`='ld_troubletickets:createdtime:createdTime:HelpDesk_createdtime:DT'
where usereportid=@usereportid and `columns`='ld_troubletickets:createdtime:创建时间:HelpDesk_createdtime:DT';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'createdtime:创建时间','createdtime:createdTime')
where usereportid=@usereportid and `columns`='ld_troubletickets:createdtime:createdTime:HelpDesk_createdtime:DT';

update ld_usereportcolumns set `columns`='ld_account:accountname:accountname:Accounts_accountname:V'
where usereportid=@usereportid and `columns`='ld_account:accountname:客户名称:Accounts_accountname:V';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'accountname:客户名称','accountname:accountname')
where usereportid=@usereportid and `columns`='ld_account:accountname:accountname:Accounts_accountname:V';

update ld_usereportcolumns set `columns`='ld_account:lastservicedate:lastservicedate:Accounts_lastservicedate:D'
where usereportid=@usereportid and `columns`='ld_account:lastservicedate:最晚服务到期日:Accounts_lastservicedate:D';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'lastservicedate:最晚服务到期日','lastservicedate:lastservicedate')
where usereportid=@usereportid and `columns`='ld_account:lastservicedate:lastservicedate:Accounts_lastservicedate:D';

update ld_usereportcolumns set `columns`='ld_troubletickets:waitingtime:waitingtime:HelpDesk_waitingtime:N'
where usereportid=@usereportid and `columns`='ld_troubletickets:waitingtime:等待时间（分钟）:HelpDesk_waitingtime:N';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'waitingtime:等待时间（分钟）','waitingtime:waitingtime')
where usereportid=@usereportid and `columns`='ld_troubletickets:waitingtime:waitingtime:HelpDesk_waitingtime:N';

update ld_usereportcolumns set `columns`='ld_troubletickets:ticketstatus:ticketstatus:HelpDesk_ticketstatus:V'
where usereportid=@usereportid and `columns`='ld_troubletickets:ticketstatus:处理状态:HelpDesk_ticketstatus:V';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'ticketstatus:处理状态','ticketstatus:ticketstatus')
where usereportid=@usereportid and `columns`='ld_troubletickets:ticketstatus:ticketstatus:HelpDesk_ticketstatus:V';

update ld_usereportcolumns set `columns`='ld_troubletickets:smownerid:last_name:HelpDesk_smownerid:V'
where usereportid=@usereportid and `columns`='ld_troubletickets:smownerid:处理人:HelpDesk_smownerid:V';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'smownerid:处理人','smownerid:last_name')
where usereportid=@usereportid and `columns`='ld_troubletickets:smownerid:last_name:HelpDesk_smownerid:V';


update ld_usereportcolumns set `columns`='ld_troubletickets:distributetime:distributetime:HelpDesk_distributetime:DT'
where usereportid=@usereportid and `columns`='ld_troubletickets:distributetime:服务开始时间:HelpDesk_distributetime:DT';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'distributetime:服务开始时间','distributetime:distributetime')
where usereportid=@usereportid and `columns`='ld_troubletickets:distributetime:distributetime:HelpDesk_distributetime:DT';


update ld_usereportcolumns set `columns`='ld_troubletickets:approvesubmittedtime:approvesubmittedtime:HelpDesk_approvesubmittedtime:DT'
where usereportid=@usereportid and `columns`='ld_troubletickets:approvesubmittedtime:服务结束时间:HelpDesk_approvesubmittedtime:DT';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'approvesubmittedtime:服务结束时间','approvesubmittedtime:approvesubmittedtime')
where usereportid=@usereportid and `columns`='ld_troubletickets:approvesubmittedtime:approvesubmittedtime:HelpDesk_approvesubmittedtime:DT';


update ld_usereportcolumns set `columns`='ld_troubletickets:servicetime:servicetime:HelpDesk_servicetime:N'
where usereportid=@usereportid and `columns`='ld_troubletickets:servicetime:服务用时（分钟）:HelpDesk_servicetime:N';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'servicetime:服务用时（分钟）','servicetime:servicetime')
where usereportid=@usereportid and `columns`='ld_troubletickets:servicetime:servicetime:HelpDesk_servicetime:N';


update ld_usereportcolumns set `columns`='ld_troubletickets:ticket_no:ticket_no:HelpDesk_ticket_no:V'
where usereportid=@usereportid and `columns`='ld_troubletickets:ticket_no:服务单编号:HelpDesk_ticket_no:V';
update ld_usereportcolumns set realcolumns=REPLACE(realcolumns,'ticket_no:服务单编号','ticket_no:ticket_no')
where usereportid=@usereportid and `columns`='ld_troubletickets:ticket_no:ticket_no:HelpDesk_ticket_no:V';
delimiter;

SET @labelbol = 'Pleaseselecttime';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择时间',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select time',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;
-- 2024-07-21

update ld_stuff set mobile_show='yes' where stuffid=100;
delimiter;
-- 2024-07-29

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

UPDATE ld_version SET old_version='V8.6.4.0',current_version='V8.6.4.0',remark='V8.6.4.0-20240729',wx_version='V8.6.4.0';
delimiter;