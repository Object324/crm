SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Users');
SET @columnname='gender';
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @sequence=(SELECT sequence FROM ld_field where tabid=@tabid AND columnname='real_name');
SET @fieldname='gender';
SET @fieldlabel='性别';
SET @zh='性别';
SET @en='Gender';
SET @uitype=15;
SET @typeofdata='V~M';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='picklist';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @profileeditfield='no';
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @allowhide='no';
SET @allowdelete='no';
SET @readonly=1;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_field SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@sequence;
delimiter;

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,'未知',15,@sequence+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',2,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND fieldlabel=@fieldlabel);
delimiter;

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
delimiter;

call getallprofile('Users');
call fieldprofile('Users');
delimiter;

CALL AddColumn('ld_users','gender','varchar','15','未知');
delimiter;

insert into ld_picklist_set(listname,relatetable,parent_listname,parent_relatetable,picklist_allowedit,picklist_allowdelete)
select 'gender','ld_field','','','no','no' from dual
where not exists(select 1 from ld_picklist_set where listname='gender' and relatetable='ld_field');
delimiter;

select listid into @listid from ld_picklist_set where listname='gender' and relatetable='ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'男' ,1 from dual where not exists(select 1 from ld_picklist_values where listid=@listid and sequence=1);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'女' ,2 from dual where not exists(select 1 from ld_picklist_values where listid=@listid and sequence=2);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'未知' ,3 from dual where not exists(select 1 from ld_picklist_values where listid=@listid and sequence=3);
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SALESKITSETTING','简报设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SALESKITSETTING' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SALESKITSETTING','Saleskit Setting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SALESKITSETTING' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','smsmustbeapprovedbytencent','3、短信模板必须在腾讯云后台审批通过后才可成功发送','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='smsmustbeapprovedbytencent' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','smsmustbeapprovedbytencent','3. The SMS template must be approved in the Tencent Cloud backend before it can be successfully sent','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='smsmustbeapprovedbytencent' and labeltype='fixedstr');
delimiter;

CREATE TABLE if not exists `ld_sortfieldmapping` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tabid` int(11) DEFAULT NULL,
  `origin_columnname` varchar(50) DEFAULT NULL,
  `mapping_columnname` varchar(50) DEFAULT NULL,
  `mapping_tablename` varchar(50) DEFAULT NULL,
  `mapping_sorttype` varchar(20) DEFAULT NULL,
  `isonlydata` varchar(20) DEFAULT NULL,
  `maxvalue` int(19) DEFAULT NULL,
  `origin_tablename` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
delimiter;
-- 2023-12-05


update ld_stuff set relatedmodule='Potentials' where stufftitle='StatisticsPotentialsBySalesPersonAndSalesStage';
delimiter;

ALTER TABLE `ld_homeboard` MODIFY COLUMN `createdtime`  timestamp NULL DEFAULT NULL AFTER `smcreatorid`;
delimiter;

set @disable_triggers = 'aaa';
UPDATE ld_account INNER JOIN 
(SELECT accountid,min(new_date) as min_end_date from 
	(SELECT ld_servicecontracts.accountid,ld_servicecontractsdetail.productid,MAX(ld_servicecontractsdetail.servicecontracts_end_date) as new_date 
	from ld_servicecontracts 
	INNER JOIN ld_servicecontractsdetail  on ld_servicecontractsdetail.id = ld_servicecontracts.servicecontractsid 
	where ld_servicecontracts.accountid >0 and IFNULL(ld_servicecontractsdetail.servicecontracts_end_date,'0000-00-00')>'1600-01-01'
	GROUP BY accountid,productid) as tmpdata1 
GROUP BY accountid) as tmpdata2 on tmpdata2.accountid = ld_account.accountid
set earlyservicedate=min_end_date;
set @disable_triggers = NULL; 
delimiter;
-- 2023-12-06

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

UPDATE ld_version SET old_version='V8.6.1.6',current_version='V8.6.1.6',remark='V8.6.1.6-20231206',wx_version='V8.6.1.5';
delimiter;