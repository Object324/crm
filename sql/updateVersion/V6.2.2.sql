select max(tabid) into @tabid from ld_tab;
select tabsequence,parent into @tabsequence,@parent from ld_tab where `name` = 'Comprehensivereport';
insert into ld_tab(tabid,`name`,presence,tabsequence,tablabel,parent)
select @tabid+1,'Customreport',0,@tabsequence+1,'Customreport',@parent from DUAL
where not exists(select 1 from ld_tab where `name` = 'Customreport');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Customreport';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Customreport' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_tab' and tabid = @tabid and relateid = @tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'定制报表' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_tab' and tabid = @tabid and relateid = @tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Customreport';
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from DUAL
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Customreport';
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Parent Reports';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 from DUAL
where not exists(select 1 from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','reportsort','报表排序','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'reportsort' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','reportsort','Report Sort','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'reportsort' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','reportdescription','报表说明','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'reportdescription' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','reportdescription','Report Description','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'reportdescription' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','reporttype','报表类型','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'reporttype' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','reporttype','Report Type','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'reporttype' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STIMULSORTREPORTSPHP','Stimulsoft Reports.PHP模板','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'STIMULSORTREPORTSPHP' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STIMULSORTREPORTSPHP','Template of Stimulsoft Reports.PHP','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'STIMULSORTREPORTSPHP' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LINKADDRESS','链接地址','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LINKADDRESS' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LINKADDRESS','Link address','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LINKADDRESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TEMPLATEREPORT','报表模板','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TEMPLATEREPORT' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TEMPLATEREPORT','Template','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TEMPLATEREPORT' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CUSTOMTEMPLATEUSEREPORTDESIGNTOOLSTIMULSOFTREPORT','请先使用报表设计工具Stimulsoft Reports.PHP定制模板','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CUSTOMTEMPLATEUSEREPORTDESIGNTOOLSTIMULSOFTREPORT' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CUSTOMTEMPLATEUSEREPORTDESIGNTOOLSTIMULSOFTREPORT','Custom template use report design tool stimulsoft reports.php','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CUSTOMTEMPLATEUSEREPORTDESIGNTOOLSTIMULSOFTREPORT' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETBYDEPARTMENT','按部门','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETBYDEPARTMENT' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETBYDEPARTMENT','Set By Department','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETBYDEPARTMENT' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETBYUSERS','按用户','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETBYUSERS' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETBYUSERS','Set By Users','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETBYUSERS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CANNOTEXCEED','不能超出','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CANNOTEXCEED' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CANNOTEXCEED',' can not exceed ','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CANNOTEXCEED' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AWORD','个字','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'AWORD' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AWORD',' a word ','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'AWORD' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT','文件是零字节或者已损坏，请重新选择','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT','The file is zero byte or damaged, please re select','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT' and Labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel = '适用范围' where labelbol = 'APPLICABLESCOPE' and languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','THEFOLDERLISTEXISTSNOTALLOWEDTODELETE','该文件夹下有报表，不允许删除','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THEFOLDERLISTEXISTSNOTALLOWEDTODELETE' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','THEFOLDERLISTEXISTSNOTALLOWEDTODELETE','The folder list exists，not allowed to delete','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THEFOLDERLISTEXISTSNOTALLOWEDTODELETE' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','THEREISAREPORTTEMPLATETHEREPORT','该报表下存在报表模板，是否确认要删除？','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THEREISAREPORTTEMPLATETHEREPORT' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','THEREISAREPORTTEMPLATETHEREPORT','There is a report template the report, are you sure you want to delete?','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THEREISAREPORTTEMPLATETHEREPORT' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ERRORDELETEINGSTATEMENTS','删除报表时出错，请刷新后重试','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ERRORDELETEINGSTATEMENTS' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ERRORDELETEINGSTATEMENTS','Error deleting statements, please refresh and try again','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ERRORDELETEINGSTATEMENTS' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','EDITREPORT','编辑报表','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'EDITREPORT' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','EDITREPORT','Edit Report','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'EDITREPORT' and Labeltype = 'fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customreport_folder` (
  `id` int(11) NOT NULL auto_increment,
  `folder_name` varchar(25) default NULL,
  `sequence` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customreport_info` (
  `report_id` int(11) NOT NULL auto_increment,
  `folder_id` int(11) default NULL,
  `report_name` varchar(25) default NULL,
  `report_describe` text,
  `report_type` varchar(25) default NULL,
  `report_template` varchar(25) default NULL,
  `report_url` varchar(200) default NULL,
  `sequence` int(11) default NULL,
  `allocatetype` int(2) default NULL,
  PRIMARY KEY  (`report_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customreport_info_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customreport2user` (
  `report_id` int(11) default NULL,
  `userid` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
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

update ld_version set old_version='V6.2.2' ,current_version='V6.2.2' ,remark='V6.2.2-20160308(V6.2.0SP2)';
delimiter;