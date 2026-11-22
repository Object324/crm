update ld_tranlabel set fieldlabel = '计量单位' 
where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'CashBack') 
and Relateid in (select fieldid from ld_field where columnname= 'usageunit' and tabid in (select tabid from ld_tab where name = 'CashBack') );
delimiter;

update ld_field set defaultvalue='thistoday' where tabid=6 and columnname='lastcontactdate';
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE name='SalesSumSequence';
SELECT tabid INTO @tid FROM ld_tab WHERE name='SalesOrder';

UPDATE  ld_usereport SET tabids=@tid WHERE Usereportid=@id;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Salesrecordslist','销售记录明细表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Salesrecordslist' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Salesrecordslist','Sales records list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Salesrecordslist' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Hospital','医院','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Hospital' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Hospital','Hospital','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Hospital' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','OrderDate','下单日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OrderDate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','OrderDate','Order Date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OrderDate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SerialNumber','序列号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SerialNumber' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SerialNumber','Serial Number','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SerialNumber' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Model1','型号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Model1' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Model1','Model','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Model1' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Degree','度数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Degree' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Degree','Degree','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Degree' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Patient','患者','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Patient' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Patient','Patient','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Patient' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Leftandrighteye','左右眼','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Leftandrighteye' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Leftandrighteye','Left and right eye','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Leftandrighteye' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ICMfilm','ICM(片)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ICMfilm','ICM (film)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TICMfilm','TICM(片)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TICMfilm','TICM (film)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Donatedpieces','赠片','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Donatedpieces' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Donatedpieces','Donated pieces','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Donatedpieces' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Ejectmonth','退片月份','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Ejectmonth' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Ejectmonth','Eject month','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Ejectmonth' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Billingdate','开票日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Billingdate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Billingdate','Billing date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Billingdate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SpecialNote','特别说明','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SpecialNote' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SpecialNote','Special Note','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SpecialNote' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CrystalOrderingInformation','晶体订购信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CrystalOrderingInformation' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CrystalOrderingInformation','Crystal Ordering Information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CrystalOrderingInformation' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EjectcrystalRecord','退片晶体记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EjectcrystalRecord' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EjectcrystalRecord','Eject crystal Record','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EjectcrystalRecord' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Alibrarycrystalinformation','出库晶体信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Alibrarycrystalinformation' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Alibrarycrystalinformation','A library crystal information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Alibrarycrystalinformation' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
update ld_field set typeofdata = 'V~O' where tabid = @tabid and fieldname = 'total_units';
delimiter;
select tabid into @tabid from ld_tab where name = 'Products';
update ld_field set presence = 0 where tabid = @tabid and columnname = 'productsheet';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Products';
UPDATE ld_field SET typeofdata = 'NN~O~8,2' WHERE fieldname = 'qtyearly' AND tabid = @tabid AND typeofdata != 'NN~O~8,2';

call Addcolumn('LD_modentity_num','isallow','int','2',0);
delimiter;
call Addcolumn('LD_modentity_num','prefixtype','int','2',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CURRENTCODE','当前流水号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CURRENTCODE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CURRENTCODE','Current Code','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CURRENTCODE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ALLOWTOMODIFY','允许手动编码','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ALLOWTOMODIFY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ALLOWTOMODIFY','Allows to modify','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ALLOWTOMODIFY' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FIXEDCHARATERSTR','固定字符','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FIXEDCHARATERSTR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FIXEDCHARATERSTR','Fixed Characters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FIXEDCHARATERSTR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEFIRSTLETTEROFSTATE','拼音首字母','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEFIRSTLETTEROFSTATE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEFIRSTLETTEROFSTATE','The first letter of ','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEFIRSTLETTEROFSTATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REMINDTIMES','提醒时间','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REMINDTIMES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REMINDTIMES','Remind Time','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REMINDTIMES' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REPEATTIME','重复次数','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REPEATTIME' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REPEATTIME','Repeat Times','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REPEATTIME' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REPEATMODES','重复方式','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REPEATMODES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REPEATMODES','Repeat Mode','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REPEATMODES' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel = '确认密码' where labelbol = 'Password_confirmation' and languagetype = 'zh';
update ld_desk set Fieldlabel = 'Confirmation Password' where labelbol = 'Password_confirmation' and languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','YOUCANCLICKONTHE','你可以点击','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUCANCLICKONTHE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','YOUCANCLICKONTHE','You can click on the','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUCANCLICKONTHE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ADDARECORD','增加一条记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ADDARECORD' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ADDARECORD','Add a record','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADDARECORD' and Labeltype='fixedstr');
delimiter;
-- end 2014-08-07

UPDATE ld_desk set Fieldlabel='增加一条记录。' where labelbol='ADDARECORD' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='Add a record.' where labelbol='ADDARECORD' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MENUNAMECANOTEMPTYEN','主菜单英文名称不能为空！','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='jspop' and labelbol = 'MENUNAMECANOTEMPTYEN');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MENUNAMECANOTEMPTYEN','Main Menu English name can not be empty!','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='jspop' and labelbol = 'MENUNAMECANOTEMPTYEN');

UPDATE ld_systems_deploy set deploy_value='0' where setype in ('Expense','CashDeposit','PutCash');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','POSITIONLEVEL','职位级别','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='POSITIONLEVEL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','POSITIONLEVEL','Position level','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='POSITIONLEVEL' and Labeltype='fixedstr');
delimiter;

CREATE TABLE if not EXISTS  `ld_workreport` (
  `workreportid` int(19) NOT NULL AUTO_INCREMENT COMMENT '报告类型(1:日志，2：周，3：月',
  `createdtime` datetime DEFAULT NULL,
  `worksummary` text,
  `workplan` text,
  `workexperience` text,
  `smcreatorid` int(19) DEFAULT NULL,
  `type` int(4) DEFAULT NULL,
  `replycount` int(19) DEFAULT '0',
  `praisecount` int(19) DEFAULT '0',
  `filename` varchar(100) DEFAULT NULL,
  `filepath` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`workreportid`),
  KEY `idx_workreport_type` (`type`) USING BTREE,
  KEY `idx_workreport_smcreatorid` (`smcreatorid`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  if not EXISTS `ld_workreport2user` (
  `workreportid` int(19) DEFAULT NULL,
  `userid` int(19) DEFAULT NULL,
  `User_type` int(4) DEFAULT NULL COMMENT '1:抄送，2：@',
  `id` int(19) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `idx_workreport2user_usertype` (`User_type`,`userid`) USING BTREE,
  KEY `idx_workreport2user_userid` (`userid`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_workreply` (
  `workreplyid` int(19) NOT NULL AUTO_INCREMENT,
  `workreportid` int(19) DEFAULT NULL,
  `text` text,
  `replyuserid` int(19) DEFAULT NULL,
  `parentid` int(19) DEFAULT '0',
  `filepath` varchar(200) DEFAULT NULL,
  `filename` varchar(100) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  PRIMARY KEY (`workreplyid`),
  KEY `idx_workreply_workreportid` (`workreportid`) USING BTREE,
  KEY `idx_workreply_parentid` (`parentid`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS  `ld_workreply2user` (
  `workreplyid` int(19) DEFAULT NULL,
  `userid` int(19) DEFAULT NULL,
  `user_type` int(4) DEFAULT NULL COMMENT '1：我回复的，2：@',
  `id` int(19) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `idx_workreply2user_workreplyid` (`workreplyid`) USING BTREE,
  KEY `idx_workreply2user_userid` (`userid`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_praise` (
  `workreportid` int(19) DEFAULT NULL,
  `userid` int(19) DEFAULT NULL,
  `praiseid` int(19) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`praiseid`),
  KEY `idx_praise_workreportid` (`workreportid`,`userid`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
-- end 2014-08-08

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DOCUEMNTNUMBERREPEAT','单据编号重复','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DOCUEMNTNUMBERREPEAT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DOCUEMNTNUMBERREPEAT',"Document number repeat",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DOCUEMNTNUMBERREPEAT' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE','起始流水号应该为正整数!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE',"The initial sequence number should be a positive integer!",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PERSONALINFORMATION','个人信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PERSONALINFORMATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PERSONALINFORMATION','Personal information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PERSONALINFORMATION' and Labeltype='fixedstr');
delimiter;

update ld_desk set Fieldlabel='小计' where labelbol='SUBTOTAL' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

SELECT deploy_value into  @deploy_value from ld_systems_deploy where deploy_type=40;
SELECT id into @wayid from ld_automaticreminds where defaultnum=40;
UPDATE ld_remindway set remindsday=-@deploy_value where wayid=@wayid; 
delimiter;

SELECT deploy_value into  @deploy_value from ld_systems_deploy where deploy_type=41;
SELECT id into @wayid from ld_automaticreminds where defaultnum=41;
UPDATE ld_remindway set remindsday=-@deploy_value where wayid=@wayid; 
delimiter;

update ld_tranlabel set fieldlabel = '出库审核人' where fieldlabel = '确认出库人';
update ld_tranlabel set fieldlabel = '入库审核人' where fieldlabel = '确认入库人';
-- end 2014-08-11

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHARACTER','字符','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CHARACTER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHARACTER','Character','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHARACTER' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='角色是用来定义可以对系统中哪些模块具备操作权限，角色的层次关系可以视作公司的组织架构' where labelbol='ROLEUSEDDEFINEMODULE' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;
update ld_tranlabel set fieldlabel = '概率' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Potentials') and 
Relateid in (select fieldid from LD_field where columnname= 'probability' and tabid in (select tabid from ld_tab where name = 'Potentials') );
delimiter;
update ld_tranlabel set fieldlabel = '个人头像' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'imagename' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE NAME = 'ServiceContracts';
INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @tabid,@tabid2,6,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@tabid AND related_tabid=@tabid2);
DELIMITER;

select tabid into @tabid from ld_tab where `name` = 'Project';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'targetenddate';
update ld_field set typeofdata = 'D~O~OTH~GE~startdate~startdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Project';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'actualenddate';
update ld_field set typeofdata = 'D~O~OTH~GE~startdate~startdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'nextcontactdate';
update ld_field set typeofdata = 'D~O~OTH~GE~contactdate~contactdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;

update ld_tranlabel set fieldlabel = '允许查看客户全景' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'accountallview' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ACCOUNTALLVIEWREMIND','(在客户相关的更多信息中允许查询所有数据)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ACCOUNTALLVIEWREMIND' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ACCOUNTALLVIEWREMIND','(Allow query all data for more information on customer related)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ACCOUNTALLVIEWREMIND' and Labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel = '是否显示服务信息' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'select_servicedetail' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
update ld_tranlabel set fieldlabel = 'Whether to display the information service' where languagetype = 'en' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'select_servicedetail' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SERVICEINFOREMIND','({$Accounts.Accounts}和{$HelpDesk.HelpDesk}明细界面)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SERVICEINFOREMIND' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SERVICEINFOREMIND','({$Accounts.Accounts} and {$HelpDesk.HelpDesk}detail interface)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SERVICEINFOREMIND' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='只允许使用 jpg、gif、bmp 与 png 格式图片，建议图片大小不超过3M）' where labelbol='ONLYJPGGIFIMG' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='(Only jpg, gif, bmp and png images ,Recommended size of not more than 3M)' where labelbol='ONLYJPGGIFIMG' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;


select tabid into @tabid from ld_tab where name='FieldFormulas';
select tabid into @relateid from ld_tab where name='FieldFormulas';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_tab',@tabid,@relateid,'字段公式' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_tab');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_tab',@tabid,@relateid,'Field Formulas' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_tab');
delimiter;
select tabid into @tabid from ld_tab where name='MailManager';
select tabid into @relateid from ld_tab where name='MailManager';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_tab',@tabid,@relateid,'邮件管理' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_tab');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_tab',@tabid,@relateid,'Mail Manager' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_tab');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ZHENCHARACTERS','一个中文占2个字符，一个英文占1个字符','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ZHENCHARACTERS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ZHENCHARACTERS','A Chinese account for 2 characters, an English accounted for 1 characters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ZHENCHARACTERS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','allowtospecifytheapprover','是否允许指定下一步处理人','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='allowtospecifytheapprover' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','allowtospecifytheapprover','allow to specify the approver','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='allowtospecifytheapprover' and Labeltype='fixedstr');
delimiter;

call addcolumn('ld_approvestep','specifyapproverid','int','18',1);
UPDATE ld_approvestep SET specifyapproverid=1 WHERE specifyapproverid IS NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SOURCEMODULE','选择源单','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOURCEMODULE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SOURCEMODULE','Select SourceModule','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SOURCEMODULE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Billingbalance','开票余额','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Billingbalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Billingbalance','Billing balance','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Billingbalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Billingbalance','开票余额','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Billingbalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Billingbalance','Billing balance','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Billingbalance' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'enddate';
update ld_field set typeofdata = 'D~O~OTH~GE~startdate~startdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;

update ld_field set fieldname='promodifiedby' where tabid=14 and columnname='modifiedby';
update ld_field set fieldname='promodifiedtime' where tabid=14 and columnname='modifiedtime';

update ld_field set fieldname='procreatedtime' where tabid=14 and columnname='createdtime';
update ld_field set fieldname='procreator' where tabid=14 and columnname='creator';
update ld_field set fieldname='prosmownerid' where tabid=14 and columnname='smownerid';

update ld_tabwithproductview set COLUMNS='LD_products:smownerid:prosmownerid:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:smownerid:assigned_user_id:Products%';

update ld_tabwithproductview set COLUMNS='LD_products:smcreatorid:procreator:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:smcreatorid:creator:Products%';
update ld_tabwithproductview set COLUMNS='LD_products:createdtime:procreatedtime:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:createdtime:createdtime:Products%';

update ld_tabwithproductview set COLUMNS='LD_products:modifiedby:promodifiedby:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:modifiedby:modifiedby:Products%';

update ld_tabwithproductview set COLUMNS='LD_products:modifiedtime:procreatedtime:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:modifiedtime:modifiedtime:Products%';
delimiter;

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype)
SELECT '2',49,'单据明细中数量小数位数','' FROM DUAL WHERE NOT EXISTS
(SELECT 1 FROM ld_systems_deploy WHERE deploy_type=49);
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','LENGTHDECIMALDIGITS','单据明细中数量小数位数','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='LENGTHDECIMALDIGITS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','LENGTHDECIMALDIGITS','Length of the decimal digits',
	'fixedstr' FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='LENGTHDECIMALDIGITS' AND Labeltype='fixedstr');
DELIMITER;

ALTER TABLE ld_inventoryproductrel MODIFY quantity DECIMAL(25,8);
DELIMITER;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMBINATION','组合','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMBINATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMBINATION','Combination','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMBINATION' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FORMATERROR','格式错误','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FORMATERROR' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FORMATERROR',"Format error",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FORMATERROR' and Labeltype='jspop');
delimiter;


alter table ld_campaign modify column targetsize decimal(25,2);
update ld_field set typeofdata='N~O' where tabid=26 and columnname='targetsize';
-- end 2014-08-14

select tabid into @tabid from ld_tab where name = 'Commission';
update ld_field set defaultvalue = 'thistoday' where tabid = @tabid and fieldname = 'expensedate';
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
update ld_field set defaultvalue = 'thistoday' where tabid = @tabid and fieldname = 'contactdate';
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
update ld_field set defaultvalue = 'thistoday' where tabid = @tabid and fieldname = 'cashbilldate';
delimiter;

UPDATE ld_desk SET Fieldlabel='允许结束审批流程' WHERE labelbol='WHETHERAPPROVALPROCESS' AND languagetype='zh' AND Labeltype='fixedstr';

UPDATE ld_desk SET Fieldlabel='允许审批步骤' WHERE labelbol='WHETHERAPPROVALSTEP' AND languagetype='zh' AND Labeltype='fixedstr';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','specifytheapproval','允许指定审批人','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='specifytheapproval' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','specifytheapproval','Allow specify approval','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='specifytheapproval' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','nextstepofapproval','下一步骤的审批人','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='nextstepofapproval' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','nextstepofapproval','next step approval','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='nextstepofapproval' and Labeltype='fixedstr');
delimiter;


update ld_tranlabel set fieldlabel = '是否允许查看服务到期日' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'select_due_date' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
update ld_tranlabel set fieldlabel = 'Whether to allow the service maturity' where languagetype = 'en' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'select_due_date' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
UPDATE ld_desk set Fieldlabel='（在客户相关信息中允许查询所有数据）' where labelbol='ACCOUNTALLVIEWREMIND' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='(Allow query all data in the customer related information)' where labelbol='ACCOUNTALLVIEWREMIND' and languagetype='en';
delimiter;
UPDATE ld_desk set Fieldlabel='关联产品明细信息时是否显示"成本价"和"GP(毛利率 %)"' where labelbol='PRODUCTSETLABEL' and languagetype='zh' and Labeltype = 'fixedstr';
UPDATE ld_desk set Fieldlabel="Whether to display 'Cost Price' and 'GP(Cost Profit %)' when relate to products details" where labelbol='PRODUCTSETLABEL' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
-- end 2014-08-15

CALL addfldcrmentityinfo('LessionPlan');

-- end 2014-08-18 

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.6.0' ,current_version='V5.6.0' ,remark='V5.6.0-20140818';
delimiter;