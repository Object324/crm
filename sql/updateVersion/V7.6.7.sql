insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CHOOSEPUBLICACCOUNTADMIN','选择公海管理员','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHOOSEPUBLICACCOUNTADMIN' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CHOOSEPUBLICACCOUNTADMIN','选择公海管理员','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHOOSEPUBLICACCOUNTADMIN' and labeltype='jspop');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_bangwobacvadvfilter` (
  `id` int(11) DEFAULT NULL,
  `columnindex` int(11) DEFAULT NULL,
  `columnname` varchar(255) DEFAULT NULL,
  `comparator` varchar(100) DEFAULT NULL,
  `value` varchar(100) DEFAULT NULL,
  `groupid` int(11) DEFAULT NULL,
  `column_condition` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_bangwobacvadvfilter_grouping` (
  `groupid` int(11) NOT NULL DEFAULT '0',
  `id` int(11) NOT NULL DEFAULT '0',
  `group_condition` varchar(255) DEFAULT NULL,
  `condition_expression` text,
  PRIMARY KEY (`groupid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO ld_automaticreminds(
	tabid,
	`name`,
	columnname,
	remindnum,
	remindway,
	remindday,
	reminder,
	remindcontent,
	`status`,
	smcreatorid,
	createdtime,
	remindmethod,
	annualremind
)
SELECT 
	4,
	'联系人生日提醒',
	'ld_contactdetails:birthday:birthday:Contacts_fieldlabel',
	0,
	3,
	0,
	'Contacts',
	'尊敬的客户，今天是您的生日，在这特殊的日子里，祝您生日快乐，幸福安康！更多服务请来电，我们随时为您服务！',
	2,
	1,
	NOW(),
	2,
	'no'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_automaticreminds WHERE tabid=4 AND `name`='联系人生日提醒');

select tabid into @tabid from ld_tab where `name` = 'Users';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_USERLOGIN_ROLE';
SELECT sequence into @sequence from ld_field WHERE block=77 and tabid = @tabid and columnname='approvestatus';
set @i=@sequence+1;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid AND block=77 and sequence > @sequence order by sequence asc;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'wx_openid','ld_users',2,'wx_openid','小程序通讯录账号',@blockid,1,0,'V~O',2,@sequence+1,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'wx_openid');
set @j=@sequence;
update ld_field set sequence=(@j:=@j+1) where tabid = @tabid AND block=77 and sequence > @sequence order by sequence asc;
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'wx_openid';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'小程序通讯录账号' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'WeiXinOpenID' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
-- 2019-01-14

DELETE FROM ld_tranlabel WHERE trantable='ld_parenttab' AND Relateid NOT IN (SELECT parenttabid FROM ld_parenttab);
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms');
SET @min_tranlabelid=(
	SELECT 
		MIN(tranlabelid)
	FROM (
		SELECT 
			tranlabelid 
		FROM ld_tranlabel 
		WHERE trantable='ld_parenttab' 
			AND Relateid=@parenttabid 
		ORDER BY tranlabelid  DESC LIMIT 2
	) a
);

DELETE FROM ld_tranlabel WHERE trantable='ld_parenttab' AND Relateid=@parenttabid AND tranlabelid<@min_tranlabelid;
UPDATE ld_tranlabel SET fieldlabel='自定义表单' WHERE trantable='ld_parenttab' AND Relateid=@parenttabid AND fieldlabel='Custom Forms' AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel='Custom Forms' WHERE trantable='ld_parenttab' AND Relateid=@parenttabid AND fieldlabel='Setup' AND languagetype='en';
delimiter;
-- 2019-01-15

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','DOWNLOADNOW','立即下载','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DOWNLOADNOW' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','DOWNLOADNOW','Download now','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DOWNLOADNOW' and languagetype='en' and Labeltype='fixedstr');
delimiter;

call addcolumn('ld_hantian_phonerecord','bridging','varchar',255,null);
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','HANTIANPHONEMISSED','未接','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HANTIANPHONEMISSED' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','HANTIANPHONEMISSED','Missed','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HANTIANPHONEMISSED' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','HANTIANPHONERECEIVED','已接','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HANTIANPHONERECEIVED' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','HANTIANPHONERECEIVED','Received','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HANTIANPHONERECEIVED' and languagetype='en' and Labeltype='fixedstr');
delimiter;  
-- 2019-01-16

UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq set id=(SELECT MAX(relation_id) FROM ld_relatedlists);
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
delimiter;

UPDATE ld_version SET old_version='V7.6.7',current_version='V7.6.7',remark='V7.6.7-20190116',wx_version='V7.6.7';
delimiter;