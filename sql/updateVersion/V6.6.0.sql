DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	defaultvalue INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=NULL;
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');	
		ELSEIF columntype='decimal' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,',2)',' default 0.00');
		ELSEIF columntype='int' THEN
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default ',defaultvalue);
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;



select fieldid into @fieldid from ld_field where tabid=29 and columnname='edit_other_mobile';
update ld_tranlabel set fieldlabel="Allow to edit other users' mobile number" where tabid=29 and trantable='ld_field' and languagetype='en' and Relateid=@fieldid;
delimiter;

update ld_desk set fieldlabel='Sales Stage' where labelbol='sales_stage' AND Labeltype='fixedstr' AND languagetype='en';
update ld_desk set fieldlabel='LastSales Stage' where labelbol='lastsales_stage' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
update ld_field set displaytype=2 where tabid=@tabid AND columnname='size';
update ld_field set uitype=1108 where  columnname='filename' AND tabid=@tabid;
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
update ld_field set uitype=15 where  columnname='isenabled' AND tabid=@tabid;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_isenabled` (
  `isenabledid` int(19) NOT NULL AUTO_INCREMENT,
  `isenabled` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL DEFAULT '1',
  `picklist_valueid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`isenabledid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_isenabled_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select id into @id from ld_picklistvalues_seq;
set @isenabled='公开';
insert into ld_isenabled(isenabled,presence,picklist_valueid)
select @isenabled,1,@id+1 from dual 
where not exists (select 1 from ld_isenabled where isenabled=@isenabled);

set @isenabled='私有';
insert into ld_isenabled(isenabled,presence,picklist_valueid)
select @isenabled,1,@id+2 from dual 
where not exists (select 1 from ld_isenabled where isenabled=@isenabled);

select ifnull(max(picklist_valueid),0) into @picklist_valueid from ld_isenabled;
update ld_picklistvalues_seq set id=@picklist_valueid where id<@picklist_valueid;
delimiter;

delete from ld_isenabled_seq;
insert into ld_isenabled_seq(id)
select max(isenabledid) from ld_isenabled;
delimiter;

call AddColumn('ld_attachmentsforbills','filecreatetype','int',10,0);
delimiter;

call AddColumn('ld_users','edit_me_mobile','int',10,1);
delimiter;

set @tabid=29;
set @blockid=192;
select max(fieldid) into @maxfieldid from ld_field ;
select sequence into @sequence from ld_field where tabid=@tabid and columnname='edit_other_mobile';
update ld_field set sequence=sequence+1 where sequence>@sequence and block=@blockid;

update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from  ld_field where tabid=@tabid and columnname='edit_me_mobile');
insert into ld_field(fieldid,tabid,columnname,tablename,
generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @maxfieldid+1,@tabid,'edit_me_mobile','ld_users',1,56,'edit_me_mobile','允许编辑自己单据的手机号字段',0,0,'',27,@blockid,1,'C~O' from dual 
where not exists(select 1 from  ld_field where tabid=@tabid and columnname='edit_me_mobile');
delimiter;

set @tabid=29;
select fieldid into @relateid from ld_field where tabid=@tabid and columnname='edit_me_mobile';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'允许编辑自己单据的手机号字段' from dual 
where not EXISTS(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and LANGUAGEtype='zh');
select fieldid into @relateid from ld_field where tabid=@tabid and columnname='edit_me_mobile';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Allow to edit my bills’ mobile number' from dual 
where not EXISTS(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and LANGUAGEtype='en');
delimiter;

DROP TRIGGER IF EXISTS `update_account_lastservicedate`;
delimiter ||
CREATE TRIGGER `update_account_lastservicedate` AFTER INSERT ON `ld_maxservicedate` FOR EACH ROW BEGIN 

IF NEW.accountid>0 THEN
	update ld_account set lastservicedate=(SELECT max(service_enddate) from ld_maxservicedate where accountid=NEW.accountid) where accountid=NEW.accountid;
END IF;

END ||
delimiter;
-- 2016-11-24

update ld_desk set Fieldlabel='Records' where labelbol='RECORDNUMS' and languagetype='en';
update ld_desk set Fieldlabel='Page' where labelbol='PAGE' and languagetype='en';
update ld_desk set fieldlabel='接通' where labelbol='JIUWEIPHONEANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='无人接听' where labelbol='JIUWEIPHONENOANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='无人接听' where labelbol='JIUWEIPHONECANCEL' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='占线' where labelbol='JIUWEIPHONEBUSY' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='其他' where labelbol='JIUWEIPHONEOTHER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='主叫号码' where labelbol='JIUWEICALLER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='被叫号码' where labelbol='JIUWEICALLEE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='账户已停用！' where labelbol='LBL_SMS_DELACCOUNT' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='用户名或密码有误，请重新输入！' where labelbol='LBL_SMS_USERINFO' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='保存失败！原因：{$Products.Products}[%s]{$Products.regmaturitydate}已经过期。' where labelbol='REGMATURITYDATEEXPIRED' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='保存失败！原因：该%s的%s已经过期。' where labelbol='QUALIFYMATURITYDATEEXPIRED' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='最多上传20张图片，支持类型：jpg、jpeg、gif、png、bmp、ico' where labelbol='UPLOADUPTP20PICTURES' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='当{$Accounts.Accounts}访问权为私有时: {$Potentials.Potentials}、{$HelpDesk.HelpDesk}、{$Quotes.Quotes}、{$SalesOrder.SalesOrder}、{$Invoice.Invoice} 访问权限必须设为私有' where labelbol='ACCOUNT_ACCESS_INFO' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='至少设置3个显示列字段' where labelbol='SETUPCOLUMNHEADERREMIND' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='请选择文件' where labelbol='PLEASESELECTAFILE' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='来电' where labelbol='ANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Notification list' where labelbol='NOTIFICATIONSCHEDULERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='通知列表' where labelbol='NOTIFICATIONSCHEDULERS' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

update ld_crmentity set setype='Accounts' where setype='servicecharge';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Youdonothavemoduleoperationrights','您没有模块操作权限，请联系管理员！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Youdonothavemoduleoperationrights' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Youdonothavemoduleoperationrights','You do not have module operation rights, please contact the administrator!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Youdonothavemoduleoperationrights' and labeltype = 'fixedstr');
delimiter;

alter table ld_workreport_remind alter column push_to_weixin set default 2;
alter table ld_reminds alter column push_to_weixin set default 2;
delimiter;

update ld_desk set fieldlabel='Open' where labelbol='OPENMODULE' AND Labeltype='jspop' AND languagetype='en';
delimiter;

select tabid into @tabid from ld_tab where name = 'OutboundOrder';
select tabid into @related_tabid from ld_tab where name = 'Invoice';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,@related_tabid,'get_invoices',1,'Invoice',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_invoices');
delimiter;
update ld_relatedlists_seq set id = (select MAX(relation_id) from ld_relatedlists);
delimiter;
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name = 'Stock';
select tabid into @related_tabid from ld_tab where name = 'PurchaseInvoice';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,@related_tabid,'get_purchaseinvoice',1,'PurchaseInvoice',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_purchaseinvoice');
delimiter;

update ld_relatedlists_seq set id = (select MAX(relation_id) from ld_relatedlists);
delimiter;
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select tabid into @related_tabid from ld_tab where `name` = 'Invoice';
update ld_quickactions set sequence = sequence + 1 where tabid = @tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,0,0,'创建销售发票' from dual
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select tabid into @related_tabid from ld_tab where `name` = 'PurchaseInvoice';
update ld_quickactions set sequence = sequence + 1 where tabid = @tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,0,0,'创建采购发票' from dual
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;

update ld_quickactions set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;
update ld_field set presence = 1 where tabid = 29 and columnname = 'menuapproval';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','xinfan','鼎捷报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='xinfan' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','xinfan','Report of dingjie','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='xinfan' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','lideng','励登报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='lideng' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','lideng','Report of lideng','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='lideng' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','fudi','复地资产报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='fudi' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','fudi','Report of fudi','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='fudi' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','yijia','怡家报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='yijia' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','yijia','Report of yijia','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='yijia' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','yixun','翼勋报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='yixun' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','yixun','Report of yixun','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='yixun' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ruiai','睿埃报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ruiai' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ruiai','Report of ruiai','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ruiai' and Labeltype='fixedstr'); 
delimiter
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOREPORTEAVAIL','没有可用的报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NOREPORTEAVAIL' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NOREPORTEAVAIL','There is no available report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NOREPORTEAVAIL' and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_usereport', 'presence', 'int', '1', 'NULL');
delimiter;

CALL AddColumn('ld_usereport', 'setype', 'varchar', '100', 'NULL');
delimiter;

CREATE TABLE if not exists`ld_comprehensivereport` (
	`id` int(19) NOT NULL auto_increment,
	`name` varchar(100) DEFAULT NULL,
	reportlabel varchar(100) DEFAULT NULL,
	typename varchar(100) DEFAULT NULL,
	`setype` varchar(100) default NULL,
	`presence` int(1) DEFAULT NULL,
	PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists`ld_comprehensivereport_group` (
  `id` int(19) NOT NULL auto_increment,
  `typename` varchar(100) DEFAULT NULL,
   reportlabel varchar(100) DEFAULT NULL,
	version varchar(100) DEFAULT NULL,
  `presence` int(1) DEFAULT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

ALTER TABLE ld_usereport MODIFY COLUMN setype VARCHAR(100);
delimiter;

ALTER TABLE ld_comprehensivereport MODIFY COLUMN setype VARCHAR(100);
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'SALESLIST','销售明细表',0,'' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='SALESLIST'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'GROSSMARGINSTATISTICS','毛利统计表',0,'' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='GROSSMARGINSTATISTICS'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'SALESSUMMARYLIST','销售汇总表',0,'龙威机械' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='SALESSUMMARYLIST'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'DOMESTICREPORTLIST','内销报表',0,'龙威机械' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='DOMESTICREPORTLIST'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'LEASINGREPORTLIST','租赁报表',0,'rent' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='LEASINGREPORTLIST'); 
delimiter;
 
insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'DETECTIONTASKSTATISTICS','检测任务完成情况统计表',0,'envtesting' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='DETECTIONTASKSTATISTICS'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'ADREPORT','爱安德报表',0,'aiande' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='ADREPORT'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'HBRREPORT','红不让报表',0,'hongburang' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='HBRREPORT'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'GUOTONGREPORT','国通报表',0,'guotong' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='GUOTONGREPORT'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'SNOWBEARREPORTS','小白熊报表',0,'小白熊' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='SNOWBEARREPORTS'); 
delimiter;
 
insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'cheer100','集家网报表',0,'cheer100' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='cheer100'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'unitrumpreport','优创报表',0,'youchuang' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='unitrumpreport'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'xinfan','鼎捷报表',0,'xinfan' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='xinfan'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'lotrecreport','乐瑞固报表',0,'leruigu' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='lotrecreport'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'lideng','励登报表',0,'lideng' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='lideng'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'fudi','复地资产报表',0,'fudi' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='fudi'); 
delimiter; 
insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'yijia','怡家报表',0,'yijia' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='yijia'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'yixun','翼勋报表',0,'yixun' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='yixun'); 
delimiter;

insert into ld_comprehensivereport_group(typename,reportlabel,presence,version)
select 'ruiai','睿埃报表',0,'ruiai' from dual 
where not EXISTS(select 1 from ld_comprehensivereport_group where typename='ruiai'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'PERSONNELSIGNINGLIST','人员签单明细表','SalesOrder/ServiceContracts',0,'SALESLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='PERSONNELSIGNINGLIST'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'PERSONNELCOLLECTIONLIST','人员回款明细表','CashBill',0,'SALESLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='PERSONNELCOLLECTIONLIST'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'CUSTOMERCOLLECTIONLIST','客户回款明细表','CashBill',0,'SALESLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='CUSTOMERCOLLECTIONLIST'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'GROSSMARGINLIST','毛利明细表','SalesOrder/ServiceContracts',0,'GROSSMARGINSTATISTICS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='GROSSMARGINLIST'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'GROSSMARGINSUMMARY','毛利汇总明细表','SalesOrder/ServiceContracts',0,'GROSSMARGINSTATISTICS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='GROSSMARGINSUMMARY'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'PRODUCTGROSSMARGINSTATISTICS','产品毛利统计表','SalesOrder/ServiceContracts',0,'GROSSMARGINSTATISTICS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='PRODUCTGROSSMARGINSTATISTICS'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'CUSTOMERGROSSMARGINSTATISTICS','客户毛利统计表','SalesOrder/ServiceContracts',0,'GROSSMARGINSTATISTICS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='CUSTOMERGROSSMARGINSTATISTICS'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'SALESSTATISTICSLIST','销售汇总表','',0,'SALESSUMMARYLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='SALESSTATISTICSLIST'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'BYPROVINCE','销售报表--按省份','',0,'DOMESTICREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='BYPROVINCE'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'BYPRODUCT','销售报表--按产品','',0,'DOMESTICREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='BYPRODUCT'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'BYEXAMINATION','销售报表--按考核','',0,'DOMESTICREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='BYEXAMINATION'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'BYNETWORK','销售报表--按网点','',0,'DOMESTICREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='BYNETWORK'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'BYMODELS','销售报表--按机型','',0,'DOMESTICREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='BYMODELS'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'LEASINGSTATISTICSLIST','租赁统计表','',0,'LEASINGREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='LEASINGSTATISTICSLIST'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'RENTPAIDBACKSITUATION','租金已回款情况','',0,'LEASINGREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='RENTPAIDBACKSITUATION'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'ANNUALRENTSCHEDULE','年度租金计划表','',0,'LEASINGREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='ANNUALRENTSCHEDULE'); 
delimiter;
 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'RENTARREARSLIST','租金欠款明细表','',0,'LEASINGREPORTLIST' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='RENTARREARSLIST'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'DETECTIONTASKSTATISTICS','检测任务完成情况统计表-按月份','',0,'DETECTIONTASKSTATISTICS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='DETECTIONTASKSTATISTICS'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Drilldownreports','爱安德明细表','',0,'ADREPORT' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Drilldownreports'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Summaryreports','爱安德汇总表','',0,'ADREPORT' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Summaryreports'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'HBRREPORT','红不让报表','',0,'HBRREPORT' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='HBRREPORT'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'GUOTONGREPORT','国通报表','',0,'GUOTONGREPORT' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='GUOTONGREPORT'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'CostStatistics','成本统计表','',0,'GUOTONGREPORT' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='CostStatistics'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Salesrecordslist','销售记录明细表','',0,'GUOTONGREPORT' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Salesrecordslist'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'SNOWBEARRPISP','维修点配件发放汇总表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='SNOWBEARRPISP'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'SNOWBEARRPSL','维修点配件申请明细表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='SNOWBEARRPSL'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'SNOWBEARHNSRSR','热线单数量区域汇总表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='SNOWBEARHNSRSR'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'ComplainSummaryreports','客诉汇总表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='ComplainSummaryreports'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Customercomplaintanalysisreport','客诉分析表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Customercomplaintanalysisreport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Returnamountregionaldatasummaryreport','退换货金额各区域数据汇总表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Returnamountregionaldatasummaryreport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Returnnumberregionaldatasummaryreport','退换货数量区域汇总分析表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Returnnumberregionaldatasummaryreport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Productcustomerservicefaultsummarytable','产品售后故障汇总表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Productcustomerservicefaultsummarytable'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Productcustomerservicenumberfailurestatistics','产品售后故障分析表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Productcustomerservicenumberfailurestatistics'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Productcustomerservicefailurein','产品售后故障占比图','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Productcustomerservicefailurein'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Customerservicenumberofsummarytableoffaultarea','售后故障数量区域汇总表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Customerservicenumberofsummarytableoffaultarea'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'SinglewiretransfertableHotline','热线单来电汇总表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='SinglewiretransfertableHotline'); 
delimiter;
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Analysisofthetablecustomerservicefailure','热线单来电类型分析表','',0,'SNOWBEARREPORTS' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Analysisofthetablecustomerservicefailure' and 
typename='SNOWBEARREPORTS'); 
delimiter;

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'cheer100','集家网报表','',0,'cheer100' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='cheer100'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'Salessummaryreport','销售汇总表','',0,'unitrumpreport' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='Salessummaryreport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'youchuangProductSales','产品线销售业绩报表','',0,'unitrumpreport' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='youchuangProductSales'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'xinfanSalesDetail','鼎捷销售统计表报表','',0,'xinfan' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='xinfanSalesDetail'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'lotrectotalreceivablesalesreport','乐瑞固总帐款销售表','',0,'lotrecreport' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='lotrectotalreceivablesalesreport'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'lidengSunsalestotal','励登销售统计表报表','',0,'lideng' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='lidengSunsalestotal'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'SumStockSssetsReport','复地存量资产汇总表','',0,'fudi' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='SumStockSssetsReport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'fudiSalesReport','复地销售报表','',0,'fudi' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='fudiSalesReport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'fudiRentCollectionreport','复地租金收缴报表','',0,'fudi'  from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='fudiRentCollectionreport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'fudiLeaseReport','复地租赁报表','',0,'fudi' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='fudiLeaseReport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'fudiHomePageReport','复地首页显示报表','',0,'fudi' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='fudiHomePageReport'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'YijiaProjectProfitStatistics','怡家项目利润统计表','',0,'yijia' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='YijiaProjectProfitStatistics'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'yixunOperateReport','翼勋运营报表','',0,'yixun' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='yixunOperateReport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'yixunFinacialReport','翼勋财务报表','',0,'yixun' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='yixunFinacialReport'); 
delimiter; 
insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'yixunContractOostReport','翼勋合同岗报表','',0,'yixun' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='yixunContractOostReport'); 
delimiter; 

insert into ld_Comprehensivereport(name,reportlabel,setype,presence,typename)
select 'ruiaiTheAmountOfPaymentSummaryReport','睿埃回款金额汇总表','',0,'ruiai' from dual 
where not EXISTS(select 1 from ld_Comprehensivereport where name='ruiaiTheAmountOfPaymentSummaryReport'); 
delimiter; 
-- 2016-12-01

update ld_usereport set setype='SalesOrder,ServiceContracts' where `name`='SalesOrderTrack';
update ld_usereport set setype='Potentials' where `name`='Salesforecastandanalysistable';
update ld_usereport set setype='CashBill' where `name`='CashBillSum_Paymentplan';
update ld_usereport set setype='CashBill' where `name`='CashBillSum_SalesOrder';
update ld_usereport set setype='CashBill' where `name`='Performancestatisticscollection';
update ld_usereport set setype='PurchaseOrder' where `name`='PurchaseOrderTrack';
update ld_usereport set setype='SendCashBill' where `name`='SendCashBillSum_PurchaseOrder';
update ld_usereport set setype='SendCashBill' where `name`='SendCashBillSum_SendPayment';
update ld_usereport set setype='SalesOrder,ServiceContracts' where `name`='Contractnumber';
update ld_usereport set setype='SalesOrder,ServiceContracts' where `name`='Contractamount';
update ld_usereport set setype='CashBill' where `name`='THESINGNINGAMOUNTOFBILLBOARD';
update ld_usereport set setype='Project' where `name`='Thestatisticalreportofprojectperformance';
update ld_usereport set setype='HelpDesk,ProjectTask' where `name`='Serviceperformanceappraisal';
delimiter;

DROP TABLE IF EXISTS ld_baobiaoType;
delimiter;

update ld_comprehensivereport set setype='SalesOrder,ServiceContracts' where setype='SalesOrder/ServiceContracts';
update ld_usereport set setype='SalesOrder,ServiceContracts' where setype='SalesOrder/ServiceContracts';
delimiter;

alter table ld_workreport_remind alter column push_to_weixin set default 2;
delimiter;

alter table ld_reminds alter column push_to_weixin set default 2;
delimiter;

update ld_desk set Fieldlabel='Records' where labelbol='RECORDNUMS' and languagetype='en';
update ld_desk set Fieldlabel='Page' where labelbol='PAGE' and languagetype='en';
update ld_desk set fieldlabel='接通' where labelbol='JIUWEIPHONEANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='无人接听' where labelbol='JIUWEIPHONENOANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='无人接听' where labelbol='JIUWEIPHONECANCEL' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='占线' where labelbol='JIUWEIPHONEBUSY' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='其他' where labelbol='JIUWEIPHONEOTHER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='主叫号码' where labelbol='JIUWEICALLER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='被叫号码' where labelbol='JIUWEICALLEE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='账户已停用！' where labelbol='LBL_SMS_DELACCOUNT' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='用户名或密码有误，请重新输入！' where labelbol='LBL_SMS_USERINFO' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='保存失败！原因：{$Products.Products}[%s]{$Products.regmaturitydate}已经过期。' where labelbol='REGMATURITYDATEEXPIRED' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='保存失败！原因：该%s的%s已经过期。' where labelbol='QUALIFYMATURITYDATEEXPIRED' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='最多上传20张图片，支持类型：jpg、jpeg、gif、png、bmp、ico' where labelbol='UPLOADUPTP20PICTURES' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='当{$Accounts.Accounts}访问权为私有时: {$Potentials.Potentials}、{$HelpDesk.HelpDesk}、{$Quotes.Quotes}、{$SalesOrder.SalesOrder}、{$Invoice.Invoice} 访问权限必须设为私有' where labelbol='ACCOUNT_ACCESS_INFO' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='至少设置3个显示列字段' where labelbol='SETUPCOLUMNHEADERREMIND' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='请选择文件' where labelbol='PLEASESELECTAFILE' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='来电' where labelbol='ANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Notification list' where labelbol='NOTIFICATIONSCHEDULERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='通知列表' where labelbol='NOTIFICATIONSCHEDULERS' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

UPDATE ld_desk set fieldlabel='单据[%s]转为普通客户失败，原因：当前单据已经是普通客户了！' where labelbol='TOANORDINARYCUSTOMERERROR' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DISTRIBUTECHANGESERVICECASHER','分配（更改服务收费人）','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DISTRIBUTECHANGESERVICECASHER' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DISTRIBUTECHANGESERVICECASHER','Assign(Change Service Casher)','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DISTRIBUTECHANGESERVICECASHER' and Labeltype='jspop'); 
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='ServiceCharge';
SELECT actionid into @actionid from ld_actionmapping where actionname='Import' AND actionlabel='IMPORT';
insert into ld_profileallpermission(tabid,operation) select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid and operation=@actionid);
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LOGOUTS','注销','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LOGOUTS' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LOGOUTS','Logout','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='LOGOUTS' and Labeltype='fixedstr'); 
delimiter;
update ld_desk set fieldlabel='来电和去电号码匹配字段' where labelbol='PHONECALLINFIELDS' AND Labeltype='fixedstr' AND languagetype='zh';
update ld_desk set fieldlabel='The incoming and outgoing call number match fields' where labelbol='PHONECALLINFIELDS' AND Labeltype='fixedstr' AND languagetype='en';   
delimiter;

CALL AddColumn('ld_inventoryproductrelscf','expiry_date','date',8,'');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PASSEXPIRYDATE','保存失败！原因：{$Products.Products}[%s]已经失效。','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'PASSEXPIRYDATE' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PASSEXPIRYDATE','Save failed! Reason: the {$Products.Products} [%s] has expired.','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'PASSEXPIRYDATE' and labeltype='jspop' and languagetype='en');
delimiter;

drop procedure if exists add_expiry_date;  
delimiter ||
CREATE PROCEDURE add_expiry_date()  
BEGIN  
	   DECLARE a int;
	   DECLARE s int default 0;  
	   DECLARE cursor_name CURSOR FOR select tabid from ld_tab where name in('Quotes','PurchaseOrder','SalesOrder','Invoice','ServiceContracts',
				'OutboundOrder','Stock','Checks','SalesBack','CashBack','PurchaseBack','PurchaseCashBack','PurchaseInvoice','WareHouseTransfer','Productbom');

	   DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET s=1;  

			OPEN cursor_name;  
				  
				fetch  cursor_name into a;  
				
				while s <> 1 do  
						insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline)
						select (select max(producttoolfieldid)+1 from ld_producttoolfield),a,'ld_inventoryproductrelscf','expiry_date','失效日期',1,51,'D~M',1,NULL,20,0,0,0,0 
						from dual where not exists(select 1 from ld_producttoolfield where tabid = a and columnname = 'expiry_date' and tablename = 'ld_inventoryproductrelscf');
						
						set @producttoolfieldid=0;
						select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = a and columnname = 'expiry_date' and tablename = 'ld_inventoryproductrelscf';
						insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						select 'zh','ld_producttoolfield',a,@producttoolfieldid,'失效日期' 
						from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
						and trantable ='ld_producttoolfield' and tabid = a and relateid=@producttoolfieldid);
						insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						select 'en','ld_producttoolfield',a,@producttoolfieldid,'Expiry Date' 
						from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
						and trantable ='ld_producttoolfield' and tabid = a and relateid=@producttoolfieldid);
				fetch  cursor_name into a;   
				end while;
			 CLOSE cursor_name;
END ||
delimiter;

CALL add_expiry_date();
delimiter;

select tabid into @potabid from ld_tab where name = 'Potentials';
select tabid into @ptabid from ld_tab where name = 'Project';
select sequence into @sequence from ld_relatedlists where tabid = @potabid and name = 'get_servicecontracts';
update ld_relatedlists set sequence = sequence+1 where tabid = @potabid and sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@potabid,@ptabid,'get_project',@sequence+1,'Project',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@potabid AND NAME='get_project');
delimiter;

set @i=0; 
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @potabid order by sequence; 
delimiter;

update ld_desk set fieldlabel = 'Enter the user you want to find' 
where languagetype='en' and labelbol='PLEASEINPUTYOUWANTTOFINDTHEUSER' and Labeltype='fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SYSTEMSELECTOPERATIONPERFORMED','System for you to find a number of conditions in the record, please select the operation to be performed!',
		'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SYSTEMSELECTOPERATIONPERFORMED','系统为您找到多个符合条件的记录，请选择要执行的操作！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='' and labeltype='fixedstr');
delimiter;
-- 2016-12-02

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Addthenumberofattachmentsisnotallowedtoexceed','添加的附件数量不允许超出','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Addthenumberofattachmentsisnotallowedtoexceed' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Addthenumberofattachmentsisnotallowedtoexceed','Add the number of attachments is not allowed to exceed','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Addthenumberofattachmentsisnotallowedtoexceed' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THECURRENTATTACHMENT','当前附件已在队列中，不能重复上传！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THECURRENTATTACHMENT' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THECURRENTATTACHMENT','The current attachment is already in the queue and cannot be uploaded repeatedly!','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THECURRENTATTACHMENT' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILESIZECANNOTEXCEED','附件大小不能超过','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'FILESIZECANNOTEXCEED' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILESIZECANNOTEXCEED','File size can not exceed','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'FILESIZECANNOTEXCEED' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILEALLSIZECANNOTEXCEED','附件总大小不能超过','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'FILEALLSIZECANNOTEXCEED' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILEALLSIZECANNOTEXCEED','File all size can not exceed','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'FILEALLSIZECANNOTEXCEED' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STARTUPLOADING','开始上传','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'STARTUPLOADING' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STARTUPLOADING','Start uploading','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'STARTUPLOADING' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BEINGUPLOADED','正在上传','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'BEINGUPLOADED' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BEINGUPLOADED','Being uploaded','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'BEINGUPLOADED' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WAITINGFORUPLOADING','等待上传','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'WAITINGFORUPLOADING' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WAITINGFORUPLOADING','Waiting for uploading','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'WAITINGFORUPLOADING' and labeltype = 'jspop');
delimiter;
-- 2016-12-06

update ld_usereport set pagewidthpercent=100 where `name`='Serviceperformanceappraisal';
delimiter;

drop procedure if exists add_currentapprover_field;
delimiter ||
CREATE PROCEDURE add_currentapprover_field()
BEGIN  
	 DECLARE a varchar(100);
	 DECLARE b int;
	 DECLARE fieldblockid int;
	 declare fieldsequence int;
	 DECLARE fieldsettype varchar(200);
	 DECLARE s int default 0;

	 DECLARE cursor_name CURSOR FOR select ld_field.tablename,ld_tab.tabid ,ld_field.block,ld_field.sequence,ld_tab.name from ld_systems_deploy 
		inner join ld_tab on ld_tab.name=ld_systems_deploy.setype
		inner join ld_field on ld_tab.tabid=ld_field.tabid
		where setype is not null and setype!= '' and ld_field.fieldname='approveby' order by tabid;

	 DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET s=1;

			OPEN cursor_name;
					fetch  cursor_name into a,b,fieldblockid,fieldsequence,fieldsettype;
					
					while s <> 1 do
    					CALL AddColumn(a,'currentapprover','varchar','1000',NULL);
    
    					insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,sequence,displaytype,presence,typeofdata)
    					select b,(select max(fieldid) from ld_field)+1,'currentapprover',a,132,'currentapprover','当前审批人',
    					fieldblockid,fieldsequence+1,2,2,'V~O' from dual 
    					where not EXISTS(select 1 from ld_field where tabid=b and columnname='currentapprover');
    
    					select fieldid into @fieldid from ld_field where tabid = b and fieldname = 'currentapprover' order by fieldid desc limit 1;
    					insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
    					select 'zh','ld_field',b,@fieldid,'当前审批人' from dual 
    					where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = b and relateid=@fieldid);
    
    					insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
    					select 'en','ld_field',b,@fieldid,'Current Approver' from dual 
    					where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = b and relateid=@fieldid);
                        
                        call fieldprofile(fieldsettype);
                        call getallprofile(fieldsettype);
					fetch  cursor_name into a,b,fieldblockid,fieldsequence,fieldsettype;    
					end while;
			CLOSE cursor_name;
END||
delimiter;

CALL add_currentapprover_field();
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceCharge';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,sequence,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'currentapprover','ld_account',132,'currentapprover','当前审批人',
(select blockid from ld_blocks where tabid=@tabid and blocklabel = 'LBL_ACCOUNT_INFORMATION'),
(select sequence from ld_field where tabid=@tabid and fieldname='approveby'),2,2,'V~O' from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当前审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

drop procedure if exists update_currentapprover_data;
delimiter ||
CREATE PROCEDURE update_currentapprover_data()
BEGIN
		   DECLARE a int;
			 DECLARE b varchar(100);
			 DECLARE c int;
			 DECLARE d varchar(100);
			 DECLARE s int default 0;

			 DECLARE cursor_name CURSOR FOR select ld_approvelog.crmid,ld_approvelog.nextstepapproveby,approve_temp.tabid,table_temp.tablename from ld_approvelog
				inner join (select max(id) as max_id from ld_approvelog GROUP BY crmid) id_temp 
				on id_temp.max_id = ld_approvelog.id
				inner join (select id,tabid from ld_approve) approve_temp 
				on approve_temp.id=ld_approvelog.approveid
				inner join (select ld_field.tablename,ld_tab.tabid from ld_systems_deploy 
				inner join ld_tab on ld_tab.name=ld_systems_deploy.setype
				inner join ld_field on ld_tab.tabid=ld_field.tabid
				where setype is not null and setype!= '' and ld_field.fieldname='approveby') table_temp on table_temp.tabid=approve_temp.tabid
				where nextstepapproveby is not null and  nextstepapproveby<>'';
			
			 DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET s=1;
				
						OPEN cursor_name;
								fetch  cursor_name into a,b,c,d;
								while s <> 1 do
									set @columnname = (select DISTINCT COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where table_name = d AND COLUMN_KEY="PRI");

									set @sql = CONCAT('update ',d,' set currentapprover = "',b,'" where ',@columnname,' = ',a);
									prepare stmt from @sql;
									execute stmt;
									
								fetch  cursor_name into a,b,c,d;
								end while;
						CLOSE cursor_name;
END||
delimiter;

CALL update_currentapprover_data();
delimiter;

update ld_tranlabel INNER JOIN(
select fieldid,ld_tranlabel.* from ld_field 
left join ld_tranlabel on ld_field.fieldid=ld_tranlabel.Relateid and ld_field.tabid=ld_tranlabel.tabid
where fieldname = 'approveby' and tablename != 'ld_users') tran_temp on ld_tranlabel.tranlabelid=tran_temp.tranlabelid
set ld_tranlabel.fieldlabel='上一步审批人' where ld_tranlabel.languagetype='zh' and ld_tranlabel.fieldlabel='审批人' ;
update ld_tranlabel INNER JOIN(
select fieldid,ld_tranlabel.* from ld_field 
left join ld_tranlabel on ld_field.fieldid=ld_tranlabel.Relateid and ld_field.tabid=ld_tranlabel.tabid
where fieldname = 'approveby' and tablename != 'ld_users') tran_temp on ld_tranlabel.tranlabelid=tran_temp.tranlabelid
set ld_tranlabel.fieldlabel='The Last Approver' where ld_tranlabel.languagetype='en' and  ld_tranlabel.fieldlabel='Approver' or ld_tranlabel.fieldlabel='Approve By';
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='PurchaseOrder';
insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select (select max(producttoolfieldid)+1 from ld_producttoolfield),@tabid,'ld_inventoryproductrel','entitytype','源单类型',0,204,'V~O~100',1,NULL,22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype' and tablename = 'ld_inventoryproductrel');
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='PurchaseOrder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype' and tablename = 'ld_inventoryproductrel';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'源单类型' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@producttoolfieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'entitytype' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@producttoolfieldid);
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='Stock';
SELECT actionid into @actionid from ld_actionmapping where actionname='Import' AND actionlabel='IMPORT';
insert into ld_profileallpermission(tabid,operation) select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid and operation=@actionid);
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='PurchaseOrder';
SELECT actionid into @actionid from ld_actionmapping where actionname='Import' AND actionlabel='IMPORT';
insert into ld_profileallpermission(tabid,operation) select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid and operation=@actionid);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHTHROGHPROBLEM','通过问题查找','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'SEARCHTHROGHPROBLEM' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHTHROGHPROBLEM','Search through problem','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'SEARCHTHROGHPROBLEM' and labeltype='fixedstr' and languagetype='en');
delimiter;

select tabid into @expense_tabid from ld_tab where `name` = 'Expense';
select tabid into @commission_tabid from ld_tab where `name` = 'Commission';
select tabid into @timesheet_tabid from ld_tab where `name` = 'TimeSheet';
delete from ld_producttoolfield where tabid in (@expense_tabid,@commission_tabid,@timesheet_tabid);
delimiter;

select max(relation_id) into @relation_id from ld_relatedlists;
select tabid into @tabid from ld_tab where `name` = 'Rate';
select tabid into @Attachment_tabid from ld_tab where `name` = 'Attachment';
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,@Attachment_tabid,'get_attachment',2,'Attachment',0,'add',1,3 from dual
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @Attachment_tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,0,0,'负责人变更记录' from DUAL
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = -10);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Attachment';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status)
select @fieldid,'Attachment','Rate',0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module= 'Attachment' and relmodule = 'Rate');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBack';
select tabid into @related_tabid from ld_tab where `name` = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,3,0,'' from DUAL
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
select tabid into @related_tabid from ld_tab where `name` = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,3,0,'' from DUAL
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main":[{"table_column_value":"smownerid","fieldname":"assigned_user_id"}],"main_more":[{"module":"VendorContact","fieldname":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main":[{"table_column_value":"smownerid","fieldname":"assigned_user_id"}],"main_more":[{"module":"VendorContact","fieldname":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main":[{"table_column_value":"smownerid","fieldname":"assigned_user_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main_more":[{"module":"VendorContact","fieldname":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid);
delimiter;

update ld_desk set fieldlabel = '对不起，目前只支持单文件上传！' where labelbol = 'ONLYSINGLEFILEUPLOAD' and languagetype ='zh' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'Sorry, currently only single file uploading are supported！' where labelbol = 'ONLYSINGLEFILEUPLOAD' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OUTCALLCENTERPOP','外拨弹屏','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OUTCALLCENTERPOP' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OUTCALLCENTERPOP','Dialing Out','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OUTCALLCENTERPOP' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INCOMECALLCENTERPOP','来电弹屏','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INCOMECALLCENTERPOP' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INCOMECALLCENTERPOP','Incoming Telegram','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INCOMECALLCENTERPOP' and Labeltype='fixedstr');
delimiter;

update ld_field set approve_demand=2 where columnname='currentapprover';
delimiter;


CREATE TABLE IF NOT EXISTS `ld_backup_file`(
	`backupid` int(19) NOT NULL AUTO_INCREMENT,
	`filename` varchar(255) DEFAULT NULL,
	`backuptime` datetime DEFAULT NULL,
	`backuptype` int(2) DEFAULT 0,
	`operator` int(11) DEFAULT NULL,
	PRIMARY KEY (`backupid`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOWNLOADBACKUPFILE','下载备份文件','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'DOWNLOADBACKUPFILE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOWNLOADBACKUPFILE','Download backup file','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'DOWNLOADBACKUPFILE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BACKUPFILENAME','备份文件名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BACKUPFILENAME' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BACKUPFILENAME','Backup file name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BACKUPFILENAME' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BACKUPTIME','备份时间','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BACKUPTIME' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BACKUPTIME','Backup time','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BACKUPTIME' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BACKUPTYPE','备份方式','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BACKUPTYPE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BACKUPTYPE','Backup time','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BACKUPTYPE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MANUAL','手动','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'MANUAL' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MANUAL','Manual','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'MANUAL' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOMATIC','自动','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'AUTOMATIC' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOMATIC','Automatic','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'AUTOMATIC' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWMANUALBACKUPMESSAGE','备份文件存放在服务器的固定路径下，备份后可以通过<b>下载备份文件</b>按钮将备份文件更换路径或下载到本地。备份结果为数据库脚本文件（不包含附件文件和图片）。','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'NEWMANUALBACKUPMESSAGE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWMANUALBACKUPMESSAGE','The backup file is stored in a fixed path of the server. After the backup, the backup file can be replaced or downloaded to the local by <b>downloading the backup file</b> button. Backup results for database script files (not included in attachment files and pictures).','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'NEWMANUALBACKUPMESSAGE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SURETODELETEBACKUPFILE','确定永久删除这个备份文件吗？','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'SURETODELETEBACKUPFILE' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SURETODELETEBACKUPFILE','Are you sure you permanently delete this backup file?','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'SURETODELETEBACKUPFILE' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CLICKDOWNLOADBACKUPFILE','点击下载备份文件','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CLICKDOWNLOADBACKUPFILE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CLICKDOWNLOADBACKUPFILE','Download backup file','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CLICKDOWNLOADBACKUPFILE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THEFILEHASDELETED','该文件已经被删除','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'THEFILEHASDELETED' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','THEFILEHASDELETED','The file has been deleted','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'THEFILEHASDELETED' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAXUPLOADSIZE','最大上传大小','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MAXUPLOADSIZE' and labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAXUPLOADSIZE','Maximum upload size is','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MAXUPLOADSIZE' and labeltype = 'jspop');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='PurchaseOrder';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='PurchaseOrder');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'subject','purchaseorder_no') AND tabid=@tabid;
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Stock';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='Stock');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'subject','ware_stock_no') AND tabid=@tabid;
delimiter;

CREATE TABLE if not exists `ld_fund_accured_history` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `operatorid` int(19) DEFAULT NULL,
  `productid` int(11) DEFAULT NULL,
  `reason` text,
  `accured_condition` text,
  `accured_result` text,
  `accured_operationdate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_type_productid_fund_accured_history` (`type`,`productid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_fund_accured_history_detail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `fund_accured_historyid` int(19) DEFAULT NULL,
  `accured_result` text,
  `accountid` int(19) DEFAULT NULL,
  `vendorid` int(19) DEFAULT NULL,
  `accured_date` date DEFAULT NULL,
  `success_result` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_fund_accured_historyid_accountid` (`fund_accured_historyid`,`accountid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_fund_reward_low_water` (
  `operationtime` datetime DEFAULT NULL,
  `fund_reward_low_waterid` int(19) NOT NULL AUTO_INCREMENT,
  `accured_date` date DEFAULT NULL,
  `accured_result` varchar(500) DEFAULT NULL,
  `success_result` varchar(10) DEFAULT NULL,
  `salesorderid` int(19) DEFAULT NULL,
  `productid` int(19) DEFAULT NULL,
  `module` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`fund_reward_low_waterid`),
  KEY `idx_fund_reward_low_water_module_productid` (`module`,`productid`,`success_result`) USING BTREE,
  KEY `idx_fund_reward_low_water_salesorderid` (`salesorderid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
-- 2016-12-12

select tabid into @tabid from ld_tab where `name`= 'Rate';
update ld_field set quickcreate = 0 where tabid = @tabid and columnname = 'ratename';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_AVGDISTRIBUT_HIGHSEAS_JSOP','公海平均分配（更改负责人）','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_AVGDISTRIBUT_HIGHSEAS_JSOP' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_AVGDISTRIBUT_HIGHSEAS_JSOP','Average distribution highseas（Change Assigned）','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='LBL_AVGDISTRIBUT_HIGHSEAS_JSOP' and Labeltype='jspop'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASESELECTLESTTWOUSER','请至少选择两个用户！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESELECTLESTTWOUSER' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASESELECTLESTTWOUSER','Please select at least two user!','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESELECTLESTTWOUSER' and Labeltype='jspop'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AVERAGEDISTRIBUTION','平均分配','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AVERAGEDISTRIBUTION' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AVERAGEDISTRIBUTION','Average Distribution','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AVERAGEDISTRIBUTION' and Labeltype='fixedstr'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_AVGDISTRIBUT_HIGHSEAS','公海平均分配','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_AVGDISTRIBUT_HIGHSEAS' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_AVGDISTRIBUT_HIGHSEAS','Average distribution highseas','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='LBL_AVGDISTRIBUT_HIGHSEAS' and Labeltype='fixedstr'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AVERAGEDISTRIBUTIONSERVICECASHER','平均分配（更改服务收费人）','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AVERAGEDISTRIBUTIONSERVICECASHER' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AVERAGEDISTRIBUTIONSERVICECASHER','Average Distribution（Change Service Casher）','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AVERAGEDISTRIBUTIONSERVICECASHER' and Labeltype='jspop'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AVERAGEDISTRIBUTIONASSIGNED','平均分配（更改负责人）','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AVERAGEDISTRIBUTIONASSIGNED' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AVERAGEDISTRIBUTIONASSIGNED','Average Distribution（Change Assigned）','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AVERAGEDISTRIBUTIONASSIGNED' and Labeltype='jspop'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','APPROVE_BATCHSUBMITLOG_INFO','共选择 %d 条记录，成功提交 %d 条，失败 %d 条。','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='APPROVE_BATCHSUBMITLOG_INFO' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','APPROVE_BATCHSUBMITLOG_INFO','Submit %d records,%d successful, %d failed.','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='APPROVE_BATCHSUBMITLOG_INFO' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AVERAGE_PROMPT','[%s]分配了 %d 条记录!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AVERAGE_PROMPT' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AVERAGE_PROMPT','[%s]Allocate %d records.','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AVERAGE_PROMPT' and Labeltype='fixedstr'); 
delimiter; 

SELECT tabid into @tabid from ld_tab where `name`='users';
update ld_field set defaultvalue=1 where tabid=@tabid AND columnname='edit_me_mobile';
delimiter; 

update ld_field set masseditable = 0 where columnname = 'currentapprover';
delimiter;

select fieldid into @fieldid from ld_field,ld_tab where ld_field.tabid = ld_tab.tabid and fieldname = 'related_to' and `name` = 'Attachment';
INSERT into ld_fieldmodulerel(fieldid,module,relmodule,status)
select @fieldid,'Attachment','TimeSheet',0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'TimeSheet');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTMODULE','请选择模块','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'PLEASESELECTMODULE' and labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTMODULE','Please select module','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'PLEASESELECTMODULE' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel='Quick Create' where labelbol='Quickly_create' and languagetype='en';
update ld_desk set fieldlabel='Look for' where labelbol='QUICKFIND' and languagetype='en';
update ld_desk set fieldlabel='Approval Center' where labelbol='MYAPPROVALCENTER' and languagetype='en';
update ld_desk set fieldlabel='Reminder' where labelbol='REMINDS' and languagetype='en';
update ld_desk set fieldlabel='Control Panel' where labelbol='CONTROLPANEL' and languagetype='en';
update ld_desk set fieldlabel='Log off' where labelbol in ('LOGOUT','LOGOUTS') and languagetype='en';
update ld_desk set fieldlabel='New' where labelbol='CREATE' and languagetype='en';
update ld_desk set fieldlabel='Find' where labelbol='SEARCH' and languagetype='en';
update ld_desk set fieldlabel='Assign' where labelbol in ('ALLOCATE','DISTRIBUT') and languagetype='en';
update ld_desk set fieldlabel='Page Setup' where labelbol='LBL_PAGE_SET' and languagetype='en';
update ld_desk set fieldlabel='View Range' where labelbol='VIEWRANGE' and languagetype='en';
update ld_desk set fieldlabel='Create Categories' where labelbol='CREATECATEGORY' and languagetype='en';
update ld_desk set fieldlabel='Approved by' where labelbol='APPROVER' and languagetype='en';
update ld_desk set fieldlabel='Batch Submit' where labelbol='APPROVE_BATCHSUBMIT' and languagetype='en';
update ld_desk set fieldlabel='Use Range' where labelbol='APPLICABLESCOPE' and languagetype='en';
update ld_desk set fieldlabel='Return list' where labelbol='BACKTOLIST' and languagetype='en';
update ld_desk set fieldlabel='Operate' where labelbol='OPERATING' and languagetype='en';
update ld_desk set fieldlabel='Next Processor' where labelbol='NEXTOPERATOR' and languagetype='en';
update ld_desk set fieldlabel='Batch Approve' where labelbol='APPROVE_BATCHAPPROVED' and languagetype='en';
update ld_desk set fieldlabel='Role-Permission' where labelbol in ('PROFILES','ROLES','SETTHEPERMISSIONS') and languagetype='en';
update ld_desk set fieldlabel='Only allow to search all the data in related information list.' where labelbol='UsersALLOWQUERY' and languagetype='en';
update ld_desk set fieldlabel='Only jpg、jpeg、gif、png、bmp & ico photo allowed(size：≤3M recommended)' where labelbol='ONLYJPGGIFIMG' and languagetype='en';
-- 2016-12-14

update ld_desk set fieldlabel='Assign(Change Assigned)' where languagetype='en' AND Labeltype='jspop' AND labelbol='DISTRIBUTECHANGEASSIGNED';
delimiter;
UPDATE ld_desk set fieldlabel='[%s] assigned %d records.' where labelbol='AVERAGE_PROMPT' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel='Average Assign' where labelbol='AVERAGEDISTRIBUTION' AND languagetype='en' AND Labeltype='fixedstr';
update ld_desk set fieldlabel='Average Assign Highseas' where labelbol='LBL_AVGDISTRIBUT_HIGHSEAS' AND languagetype='en' AND Labeltype='fixedstr';
update ld_desk set fieldlabel='Average Assign Highseas' where labelbol='LBL_AVGDISTRIBUT_HIGHSEAS_JSOP' AND languagetype='en' AND Labeltype='jspop';
update ld_desk set fieldlabel='Average Assign(Change Service Casher)' where labelbol='AVERAGEDISTRIBUTIONSERVICECASHER' AND languagetype='en' AND Labeltype='jspop';
update ld_desk set fieldlabel='Average Assign(Change Assigned)' where labelbol='AVERAGEDISTRIBUTIONASSIGNED' AND languagetype='en' AND Labeltype='jspop';
delimiter;
-- 2016-12-15

CREATE TABLE IF NOT EXISTS `ld_camcard_comparison_detail` (
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `comparid`     Int(11) NOT NULL,
  `card_field`     Varchar(255),
  `crm_field` Varchar(255)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_camcard_comparison` (
  `comparid`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `modulename`     VARCHAR(255),
  `comparisoname`     VARCHAR(255),
  `status`     INT(4) DEFAULT 0
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_camcard_comparison(modulename,comparisoname,status)
  select 'Accounts','T1',1 from dual
  where not exists(select 1 from ld_camcard_comparison where modulename = 'Accounts' and comparisoname = 'T1');

insert into ld_camcard_comparison(modulename,comparisoname,status)
  select 'Contacts','T1',1 from dual
  where not exists(select 1 from ld_camcard_comparison where modulename = 'Contacts' and comparisoname = 'T1');

insert into ld_camcard_comparison(modulename,comparisoname,status)
  select 'Vendors','T1',1 from dual
  where not exists(select 1 from ld_camcard_comparison where modulename = 'Vendors' and comparisoname = 'T1');

insert into ld_camcard_comparison(modulename,comparisoname,status)
  select 'VendorContact','T1',1 from dual
  where not exists(select 1 from ld_camcard_comparison where modulename = 'VendorContact' and comparisoname = 'T1');

SELECT comparid INTO @comparid from ld_camcard_comparison WHERE modulename='Accounts' AND comparisoname='T1' LIMIT 1;
SELECT comparid INTO @comparid_Contacts from ld_camcard_comparison WHERE modulename='Contacts' AND comparisoname='T1' LIMIT 1;
SELECT comparid INTO @comparid_Vendors from ld_camcard_comparison WHERE modulename='Vendors' AND comparisoname='T1' LIMIT 1;
SELECT comparid INTO @comparid_VendorsContacts from ld_camcard_comparison WHERE modulename='VendorContact' AND comparisoname='T1' LIMIT 1;

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'formatted_name','ld_contactdetails:lastname:lastname:Products_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'formatted_name');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'label','ld_account:bill_street:bill_street:Accounts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'label');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'organization','ld_account:accountname:accountname:Accounts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'organization');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'title','ld_contactdetails:title:title:Products_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'title');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'role','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'role');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'callular','ld_contactdetails:mobile:mobile:Products_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'callular');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'telephone','ld_contactdetails:pphone:phone:Products_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'telephone');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'facsimile','ld_account:fax:fax:Accounts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'facsimile');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'email','ld_account:email1:email1:Accounts_fieldlabel:E' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'email');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'url','ld_account:website:website:Accounts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'url');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'sns','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'sns');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid,'im','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid and card_field = 'im');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'formatted_name','ld_contactdetails:lastname:lastname:Contacts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'formatted_name');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'label','ld_contactdetails:mailingstreet:mailingstreet:Contacts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'label');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'organization','ld_contactdetails:accountid:account_id:Contacts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'organization');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'title','ld_contactdetails:title:title:Contacts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'title');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'role','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'role');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'callular','ld_contactdetails:mobile:mobile:Products_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'callular');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'telephone','ld_contactdetails:pphone:phone:Contacts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'telephone');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'facsimile','ld_contactdetails:faxx:fax:Contacts_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'facsimile');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'email','ld_contactdetails:email:email:Contacts_fieldlabel:E' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'email');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'url','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'url');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'sns','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'sns');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Contacts,'im','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Contacts and card_field = 'im');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'formatted_name','ld_vendorcontacts:lastname:lastname:Products_姓名:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'formatted_name');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'label','ld_vendor:street:street:Vendors_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'label');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'organization','ld_vendor:vendorname:vendorname:Vendors_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'organization');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'title','ld_vendorcontacts:department:department:Products_部门:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'title');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'role','ld_vendorcontacts:title:title:Products_职务:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'role');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'callular','ld_vendorcontacts:mobile:mobile:Products_手机:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'callular');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'telephone','ld_vendor:phone:phone:Vendors_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'telephone');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'facsimile','ld_vendor:fax:fax:Vendors_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'facsimile');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'email','ld_vendor:email:email:Vendors_fieldlabel:E' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'email');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'url','ld_vendor:website:website:Vendors_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'url');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'sns','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'sns');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_Vendors,'im','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_Vendors and card_field = 'im');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'formatted_name','ld_vendorcontacts:lastname:lastname:VendorContact_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'formatted_name');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'label','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'label');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'organization','ld_vendorcontacts:vendorid:vendor_id:VendorContact_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'organization');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'title','ld_vendorcontacts:department:department:VendorContact_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'title');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'role','ld_vendorcontacts:title:title:VendorContact_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'role');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'callular','ld_vendorcontacts:mobile:mobile:VendorContact_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'callular');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'telephone','ld_vendorcontacts:officephone:officephone:VendorContact_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'telephone');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'facsimile','ld_vendorcontacts:fax:fax:VendorContact_fieldlabel:V' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'facsimile');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'email','ld_vendorcontacts:email:email:VendorContact_fieldlabel:E' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'email');

insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'url','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'url');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'sns','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'sns');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
  select @comparid_VendorsContacts,'im','' from dual where not exists(
      select 1 from ld_camcard_comparison_detail where comparid = @comparid_VendorsContacts and card_field = 'im');


SELECT max(fieldid)
INTO @maxfieldid
FROM ld_settings_field;
UPDATE ld_settings_field_seq
SET id = @maxfieldid + 1
WHERE NOT exists(SELECT 1
                 FROM ld_settings_field
                 WHERE name = 'LBL_EXPANSION_CAMCARD');
SELECT blockid
INTO @blockid
FROM ld_settings_blocks
WHERE label = 'LBL_OTHER_SETTINGS';
SELECT sequence
INTO @sequence
FROM ld_settings_field
WHERE name = 'BANGWO8INTERFACE' AND blockid = @blockid;
INSERT INTO ld_settings_field (fieldid, blockid, NAME, iconpath, description, linkto, sequence, active)
  SELECT
    @maxfieldid + 1,
    @blockid,
    'LBL_EXPANSION_CAMCARD',
    'Cron.png',
    'DEFINEEXPANSIONCAMCARDDESCRIPTION',
    'index.php?module=Settings&action=camcard&parenttab=Settings&purpose=DetailView',
    @sequence + 1,
    0
  FROM dual
  WHERE NOT EXISTS(SELECT 1
                   FROM ld_settings_field
                   WHERE blockid = @blockid AND `name` = 'LBL_EXPANSION_CAMCARD');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','LBL_EXPANSION_CAMCARD','名片全能王','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'LBL_EXPANSION_CAMCARD' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','LBL_EXPANSION_CAMCARD','Camcard','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'LBL_EXPANSION_CAMCARD' and languagetype = 'en' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DEFINEEXPANSIONCAMCARDDESCRIPTION','设置名片全能王与系统字段对应关系','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'DEFINEEXPANSIONCAMCARDDESCRIPTION' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DEFINEEXPANSIONCAMCARDDESCRIPTION','Set camcard corresponding relations between system field','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'DEFINEEXPANSIONCAMCARDDESCRIPTION' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
-- 2016-12-16

update ld_field set fieldlabel='资质到期日' where columnname='qualifymaturitydate' and tabid in (6,18) and fieldlabel='';
update ld_tranlabel set fieldlabel='资质到期日' where trantable='ld_field' and languagetype='zh'
	and Relateid in (select fieldid from ld_field where columnname='qualifymaturitydate' and tabid in (6,18)) and fieldlabel='';
    
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHOWDETAILRECORDS','显示','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SHOWDETAILRECORDS' and Labeltype='fixedstr'); 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SHOWDETAILRECORDS','Records','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SHOWDETAILRECORDS' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DETAILRECORDNUMS','Records total','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DETAILRECORDNUMS' and Labeltype='fixedstr'); 
delimiter; 

update ld_desk set fieldlabel='Back' where labelbol='BACKTOLIST' and languagetype='en';
update ld_desk set fieldlabel='Search' where labelbol='SEARCH' and languagetype='en';
update ld_desk set fieldlabel='Search' where labelbol='QUICKFIND' and languagetype='en';
update ld_desk set fieldlabel='New Categories' where labelbol='CREATECATEGORY' and languagetype='en';
update ld_desk set fieldlabel='My' where labelbol='Mine' and languagetype='en';
update ld_desk set fieldlabel='My' where labelbol='My' and languagetype='en';
update ld_desk set fieldlabel='I Create' where labelbol='Icreated' and languagetype='en';
update ld_desk set fieldlabel='Share with  me' where labelbol='Sharedwithme' and languagetype='en';
update ld_desk set fieldlabel='Share with others' where labelbol='Ishared' and languagetype='en';
update ld_desk set fieldlabel='Page Setting' where labelbol='LBL_PAGE_SET' and languagetype='en';
update ld_desk set fieldlabel='Approve' where labelbol='MYAPPROVALCENTER' and languagetype='en';
update ld_desk set fieldlabel='Engineers' where labelbol='ShareUsers' and languagetype='en';
update ld_desk set fieldlabel='Link To' where labelbol='SOURCETYPE' and languagetype='en';
update ld_desk set fieldlabel='Type' where labelbol='BillType' and languagetype='en';
update ld_desk set fieldlabel='Type' where labelbol='Bill_type' and languagetype='en';
update ld_desk set fieldlabel='Type' where labelbol='BillType' and languagetype='en';
update ld_desk set fieldlabel='Type' where labelbol='Bill_type' and languagetype='en';
update ld_desk set fieldlabel='No.' where labelbol='BILLNUM' and languagetype='en';
update ld_desk set fieldlabel='Approving' where labelbol='Pending' and languagetype='en';
update ld_desk set fieldlabel='Approved' where labelbol='Processed' and languagetype='en';
update ld_desk set fieldlabel='Kind Reminder' where labelbol='REMINDER' and languagetype='en';
update ld_desk set fieldlabel='Read' where labelbol='LBL_READEN' and languagetype='en';
update ld_desk set fieldlabel='Records' where labelbol='SHOWINGRECORDS' and languagetype='en';
update ld_desk set fieldlabel='Approving' where labelbol='Approvalof' and languagetype='en';
update ld_desk set fieldlabel='Approved' where labelbol='Approved' and languagetype='en';
-- 2016-12-19 

update ld_desk set fieldlabel='Assign' where labelbol in ('ALLOCATE','DISTRIBUT') and languagetype='en'; 
update ld_desk set fieldlabel='Assign Highseas' where labelbol in ('LBL_DISTRIBUT_HIGHSEAS') and languagetype='en';
update ld_desk set fieldlabel='Assign(Change Service Casher)' where labelbol in ('DISTRIBUTECHANGESERVICECASHER') and languagetype='en';
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
update ld_field set approve_demand=2 where tabid=@tabid and columnname='approveby';
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContact';
update ld_field set approve_demand=2 where tabid=@tabid and columnname='approveby';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CAMCARDFIELDS','名片全能王字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CAMCARDFIELDS' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CAMCARDFIELDS','CamCard Fields','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CAMCARDFIELDS' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CAMCARDCAPTION','描述','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CAMCARDCAPTION' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CAMCARDCAPTION','Caption','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CAMCARDCAPTION' and Labeltype='fixedstr'); 
delimiter;
 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CAMCARDCRMFIELDS','CRM字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CAMCARDCRMFIELDS' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CAMCARDCRMFIELDS','CRM Fields','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CAMCARDCRMFIELDS' and Labeltype='fixedstr'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CAMCARDMATCHFIELD','匹配字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CAMCARDMATCHFIELD' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CAMCARDMATCHFIELD','Matching Fields','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CAMCARDMATCHFIELD' and Labeltype='fixedstr'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CAMCARDNONE','--无--','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CAMCARDNONE' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CAMCARDNONE','--none--','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CAMCARDNONE' and Labeltype='fixedstr'); 
delimiter;

update ld_desk SET fieldlabel='CamCard' where labelbol='LBL_EXPANSION_CAMCARD' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Set the CRM field to match the name of the CamCard' where labelbol='DEFINEEXPANSIONCAMCARDDESCRIPTION' AND languagetype='en' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='设置名片全能王匹配的CRM字段' where labelbol='DEFINEEXPANSIONCAMCARDDESCRIPTION' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TAXRATE','税率','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'TAXRATE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TAXRATE','Tax Rate','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'TAXRATE' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel = 'Tax' where labelbol = 'TAX' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_inventorytaxinfo set percentage = 17 where taxname = 'tax2';
delimiter;

update ld_inventorytaxinfo set percentage = 1 where taxname = 'tax1';
delimiter;

update ld_inventorytaxinfo set percentage = 6 where taxname = 'tax3';
delimiter;

update ld_inventorytaxinfo set percentage = 10 where taxname = 'tax_customs';
delimiter;

update ld_inventorytaxinfo set percentage = 17 where taxname = 'tax_added';
delimiter;

update ld_inventorytaxinfo set percentage = 30 where taxname = 'tax_profit';
delimiter;
-- 2016-12-21

SELECT tabid into @tabid FROM ld_tab where `name`='Expense';
UPDATE ld_tabdetailfield  set defaultcolumn=1 where tabid=@tabid AND tablename='ld_expensedetail' AND columnname='description';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DELETEBLOCK','删除区块','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELETEBLOCK' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DELETEBLOCK','Delete block','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DELETEBLOCK' and Labeltype='fixedstr'); 
delimiter;

UPDATE ld_desk set fieldlabel='指定审批人' where labelbol='APPROVERINFO' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='Specifies the approver' where labelbol='APPROVERINFO' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk set fieldlabel='单据负责人部门用户的职位级别' where labelbol='SPECIFYPROMOTERDEP' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='Position level of the document user' where labelbol='SPECIFYPROMOTERDEP' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk set fieldlabel='单据负责人直属上级部门用户的职位级别' where labelbol='LBL_POSITIONLEVEL' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='单据负责人部门用户的职位级别' where labelbol='SPECIFYPROMOTERDEP' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='Position level of the document user' where labelbol='SPECIFYPROMOTERDEP' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MANAGEMENTPOSITIONLEVEL','（用户管理信息中的职位级别）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MANAGEMENTPOSITIONLEVEL' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MANAGEMENTPOSITIONLEVEL','(The Position level in the user management information)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MANAGEMENTPOSITIONLEVEL' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIRECTCONNECTIONODBC','直接连接(ODBC)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DIRECTCONNECTIONODBC' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DIRECTCONNECTIONODBC','Direct connection(ODBC)','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DIRECTCONNECTIONODBC' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_K3','K3系统','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_K3' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_K3','K3','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_K3' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_KIS_STANDARD','KIS标准版','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_KIS_STANDARD' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_KIS_STANDARD','Kis Standara','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_KIS_STANDARD' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_KIS_MINI','KIS迷你版','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_KIS_MINI' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_KIS_MINI','Kis Mini','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_KIS_MINI' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_KIS_MAJOR','KIS专业版','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_KIS_MAJOR' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_KIS_MAJOR','Kis Major','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_KIS_MAJOR' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_KIS_ULTIMATE','KIS旗舰版','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_KIS_ULTIMATE' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_KIS_ULTIMATE','Kis Ultimate','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_KIS_ULTIMATE' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','nodata','没有数据','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'nodata' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','nodata','No data','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'nodata' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','KINGDEEDATEBASECONNECTIONFAILED','金蝶数据库连接失败！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'KINGDEEDATEBASECONNECTIONFAILED' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','KINGDEEDATEBASECONNECTIONFAILED','Kingdee database connection failed!','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'KINGDEEDATEBASECONNECTIONFAILED' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUBECTCODEDOESNOTEXISTSINKINGDEE','科目代码在金蝶中不存在！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SUBECTCODEDOESNOTEXISTSINKINGDEE' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUBECTCODEDOESNOTEXISTSINKINGDEE','Subject code does not exist in Kingdee!','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SUBECTCODEDOESNOTEXISTSINKINGDEE' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Businessdate','业务日期','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Businessdate' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Businessdate','Business date','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Businessdate' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Singleplayer','制单人','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Singleplayer' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Singleplayer','Single player','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Singleplayer' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SimultaneousgenerationofKingdeecertificate','同步生成金蝶凭证','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SimultaneousgenerationofKingdeecertificate' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SimultaneousgenerationofKingdeecertificate','Simultaneous generation of Kingdee certificate','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SimultaneousgenerationofKingdeecertificate' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TheserviceperiodhassynchronousgenerationofKingdee','该业务期间内已同步生成过金蝶凭证，是否要覆盖之前的凭证信息','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TheserviceperiodhassynchronousgenerationofKingdee' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TheserviceperiodhassynchronousgenerationofKingdee','The service period has synchronous generation of Kingdee certificate, whether to overwrite the previous document information','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TheserviceperiodhassynchronousgenerationofKingdee' and labeltype = 'fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_voucher_log` (
  `voucher_id` int(11) NOT NULL AUTO_INCREMENT,
  `voucher_date` date DEFAULT NULL,
  `voucher_type` varchar(200) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `voucher_userid` int(11) DEFAULT NULL,
  `userid` int(11) DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `operation` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`voucher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','fieldlabelthesame','已存在同名的#fieldlabel#，是否继续保存？','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'fieldlabelthesame' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','fieldlabelthesame','#fieldlabel# with the same name already exists. Do you want to save it?','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'fieldlabelthesame' and labeltype = 'fixedstr');
delimiter;

update ld_field set masseditable=0 where columnname='currentapprover';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','USERAPPROVESREMINDS','审批委托启用时，审批单据将不会流转到该用户，直接流转到审批委托人，是否继续？','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='USERAPPROVESREMINDS' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','USERAPPROVESREMINDS','When the approval delegate is enabled, the approval document will not flow to the user, go directly to the approving delegate, and continue?','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='USERAPPROVESREMINDS' and Labeltype='jspop'); 
delimiter;

delete from ld_tranlabel where tabid=22 and trantable='ld_field' 
	and Relateid=(select fieldid from ld_field where tabid=22 and columnname='customerno' and presence=1);
delete from ld_field where tabid=22 and columnname='customerno' and presence=1;
delimiter;

update ld_desk set fieldlabel='相关信息列表是否允许查询单据相关的所有数据' where labelbol='UsersALLOWQUERY' 
	and languagetype='zh' and fieldlabel='只允许在相关信息列表查询所有的数据';
select fieldid into @fieldid from ld_field where tabid=29 and columnname='accountallview';
update ld_tranlabel set fieldlabel='相关信息列表允许查询所有数据' where trantable='ld_field' and languagetype='zh'
	and Relateid=@fieldid and fieldlabel='允许查看相关信息列表数据权限';
delimiter;
   
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','USERAPPROVESREMINDS','审批委托启用时，审批单据将不会流转到该用户，直接流转到审批委托人，是否继续？','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='USERAPPROVESREMINDS' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','USERAPPROVESREMINDS','When the approval delegate is enabled, the approval document will not flow to the user, go directly to the approving delegate, and continue?','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='USERAPPROVESREMINDS' and Labeltype='jspop'); 
delimiter;

update ld_field set masseditable=0 where columnname='approveby';
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 118;
update ld_systems_deploy set sequence = sequence + 1 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 1,119,'设置关联项目时是否在所有用户的数据中进行查询（包括选择源单）','',@sequence + 1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Contacts"}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 119);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype ORDER BY sequence asc;
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_systems_deploy',119,119,'设置关联{$Project.Project}时是否在所有用户的数据中进行查询(包括选择源单)' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and tabid = 119 and Relateid = 119 and trantable = 'ld_systems_deploy');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_systems_deploy',119,119,'To set up the related {$Project.Project} whether the data in all users to query(inclue select source)' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and tabid = 119 and Relateid = 119  and trantable = 'ld_systems_deploy');
delimiter;

CREATE TABLE if not EXISTS `ld_importcheckdupfields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `columns` varchar(500) DEFAULT NULL,
  `entitytype` varchar(255) DEFAULT NULL,
  `sequence` int(10) DEFAULT NULL,
  `conditions` varchar(50) DEFAULT 'or',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

delete from ld_desk where labeltype='fixedstr' and  labelbol='SETTINGS_SET';
update ld_desk set fieldlabel='选择重复时导入方式' where labelbol='REPEAT_IMPORT_MODE' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Choose repeat import mode' where labelbol='REPEAT_IMPORT_MODE' and labeltype='fixedstr' and languagetype='en';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETDUPFIELD','设置查重字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='SETDUPFIELD' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETDUPFIELD','Set duplicate check fields','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='SETDUPFIELD' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IMPORTRECORDTIP','共%d条记录，明细%d条，覆盖%d条记录，成功导入%d条记录，失败%d条记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='IMPORTRECORDTIP' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IMPORTRECORDTIP','A total of %d records, detailed %d, covering %d records, successfully imported %d records, failed %d records','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='IMPORTRECORDTIP' and labeltype='fixedstr');
delimiter;   
-- 2016-12-23

drop trigger if exists up_account_nolinkdays; 
delimiter || 
CREATE TRIGGER up_account_nolinkdays 
BEFORE UPDATE ON ld_account 
FOR EACH ROW 
BEGIN 

	IF ifnull(new.lastcontactdate,'0000-00-00')<>ifnull(old.lastcontactdate,'0000-00-00') THEN
		SET new.nolinkdays=datediff(CURDATE(),ifnull(new.lastcontactdate,date_format(new.createdtime,'%Y-%m-%d')));
	END IF;

END || 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BLOCKSDOWNOFSETTING','区块下移','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='BLOCKSDOWNOFSETTING' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BLOCKSDOWNOFSETTING','Blocks Down','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='BLOCKSDOWNOFSETTING' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BLOCKSUPOFSETTING','区块上移','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='BLOCKSUPOFSETTING' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BLOCKSUPOFSETTING','Blocks Up','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='BLOCKSUPOFSETTING' and Labeltype='fixedstr'); 
delimiter; 

UPDATE ld_dashboard_app SET labelbol='STATISTICALEXPENSECOMMISSION' WHERE name='expense_commission' AND labelbol='STATISTICALRECEIVABLES';

update ld_tranlabel set fieldlabel='年管理费率' where languagetype='zh' and 
Relateid in(select fieldid from ld_field where tabid in(select tabid from ld_tab where name='Management') and columnname='service_rate')
and trantable='ld_field';
delimiter;

call AddColumn('ld_fund_management','beforeqty','int',19,0);
call AddColumn('ld_fund_management','curqty','int',19,0);
call AddColumn('ld_fund_management_commission','beforeqty','int',19,0);
call AddColumn('ld_fund_management_commission','curqty','int',19,0);
delimiter;

alter table ld_fund_management_commission modify navh decimal(20,8);
alter table ld_fund_management_commission modify navn decimal(20,8);
alter table ld_fund_net modify nav decimal(20,8);
alter table ld_fund_management modify navh decimal(20,8);
alter table ld_fund_management modify navn decimal(20,8);
delimiter;

update ld_field set  uitype=1,typeofdata='V~O' where  tabid in (select tabid  from ld_tab where name='Mcommission') and columnname='navh';
update ld_field set  uitype=1,typeofdata='V~O' where  tabid in (select tabid  from ld_tab where name='Mcommission') and columnname='navn';

update ld_field set fieldlabel='前一日净值' , uitype=1,typeofdata='V~O' where  tabid in (select tabid  from ld_tab where name='Management') and columnname='navh';update ld_field set fieldlabel='前一日净值' , uitype=1,typeofdata='V~O' where  tabid in (select tabid  from ld_tab where name='Management') and columnname='navh';
update ld_tranlabel set fieldlabel='前一日净值' where Relateid in
				(select fieldid from ld_field where tabid in (select tabid  from ld_tab where name='Management') and columnname='navh')
			and trantable='ld_field';

update ld_field set fieldlabel='当日净值' , uitype=1,typeofdata='V~O'  where  tabid in (select tabid  from ld_tab where name='Management') and columnname='navn';
update ld_tranlabel set fieldlabel='当日净值' where Relateid in
				(select fieldid from ld_field where tabid in (select tabid  from ld_tab where name='Management') and columnname='navn')
			and trantable='ld_field';

update ld_fund_management INNER JOIN ld_fund_net
on ld_fund_net.product_id=ld_fund_management.product_id
 and ld_fund_net.navdate=DATE_FORMAT(date_add(ld_fund_management.expensedate, interval -1 day),'%Y-%m-%d')
set ld_fund_management.navh=ld_fund_net.nav;

update ld_fund_management INNER JOIN ld_fund_net
on ld_fund_net.product_id=ld_fund_management.product_id
 and ld_fund_net.navdate=DATE_FORMAT(ld_fund_management.expensedate,'%Y-%m-%d')
set ld_fund_management.navn=ld_fund_net.nav;
delimiter;
select tabid into @tabid from ld_tab where name='Management';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'beforeqty','ld_fund_management',7,'beforeqty','前一天份额',
(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'beforeqty'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'curqty','ld_fund_management',7,'curqty','当日变动份额',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'curqty'); 
delimiter;
select tabid into @tabid from ld_tab where name='Management';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'beforeqty'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'前一天份额' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'beforeqty' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'curqty'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'当日变动份额' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'curqty' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter;


select tabid into @tabid from ld_tab where name='Mcommission';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'beforeqty','ld_fund_management_commission',7,'beforeqty','前一天份额',
(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'beforeqty'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'curqty','ld_fund_management_commission',7,'curqty','当日变动份额',
		(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'curqty'); 
delimiter;

select tabid into @tabid from ld_tab where name='Mcommission';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'beforeqty'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'前一天份额' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'beforeqty' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'curqty'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'当日变动份额' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'curqty' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter;

call fieldprofile('Mcommission');
call getallprofile('Mcommission');

call fieldprofile('Management');
call getallprofile('Management');
delimiter;
-- 2016-12-28

update ld_desk set fieldlabel="Password Specification$=$1.General users need to reset the password every 90 days, administrator users need to reset the password every 30 days;$=$2.General users\'password should contain at least 8 digits, the administrator users\'password should contain at least 15 digits;$=$3.Password cannot contain the users\' account or users\' name;"
where labelbol='PMWARMREMINDFORPASSWORD' AND languagetype='en' AND Labeltype='fixedstr';

update ld_desk set fieldlabel="4.Password meets at least the following 3 requirements:$=$  Contains capital letters$=$  Contains small letters$=$  Contains numbers$=$  Contains special characters"
where labelbol='PMWARMREMINDFORPASSWORDADD' AND languagetype='en' AND Labeltype='fixedstr';

update ld_desk set fieldlabel='日期 ' where labelbol='YOUIN' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='Date  ' where labelbol='YOUIN' and languagetype='en' and Labeltype='jspop';

update ld_desk set fieldlabel=' 的工时超过 ' where labelbol='OVERTIME' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel=' charge over than ' where labelbol='OVERTIME' and languagetype='en' and Labeltype='jspop';

update ld_desk set fieldlabel=' 小时' where labelbol='HOUR' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel=' hours' where labelbol='HOUR' and languagetype='en' and Labeltype='jspop';

update ld_desk set fieldlabel=' continue or not?' where labelbol='WHETHERTOCONTINUE' and languagetype='en' and Labeltype='jspop';

update ld_systems_deploy set inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"SalesOrder"}]' where deploy_type=116;
delimiter;
update ld_systems_deploy set inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"ServiceContracts"}]' where deploy_type=117;
delimiter;
update ld_systems_deploy set inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"PurchaseOrder"}]' where deploy_type=118;
delimiter;
update ld_systems_deploy set inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Project"}]' where deploy_type=119;
delimiter;

update ld_systems_deploy set inputvalue = '[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Project"}]'
where deploy_type = 119;
delimiter;

call AddColumn('ld_tabdetailfield','is_checkimportfield','int','1','');
delimiter;

SELECT tabid into @tabid  from ld_tab where `name` ='TimeSheet';
update ld_tabdetailfield set is_checkimportfield=1 where columnname in('timetype');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'entitytype','源单类型','',1,'Text','V~O~200',1,@tabid,'ld_timesheetdetail',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytype');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'源单类型' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'entitytype' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='SendCashBill';
update ld_field set typeofdata='V~M' where columnname='vendorid' AND tabid=@tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','searchforcolleagues','搜索同事','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='searchforcolleagues' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','searchforcolleagues','Search for colleagues','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='searchforcolleagues' and Labeltype='jspop'); 
delimiter;

UPDATE ld_desk set fieldlabel='按用户' where languagetype='zh' AND labelbol='SETBYUSERS' AND Labeltype='jspop';
UPDATE ld_desk set fieldlabel='按部门' where languagetype='zh' AND labelbol='SETBYDEPARTMENT' AND Labeltype='jspop';
delimiter;

UPDATE ld_desk set fieldlabel='最多仅允许设置6个查找字段' where languagetype='zh' AND labelbol='O5SFAA' AND Labeltype='jspop';
delimiter;

update ld_field  set uitype=158 where tabid in(select tabid from ld_tab where name='InventoryAccount') and columnname='module';
delimiter;

update ld_desk set fieldlabel = '去年' where labelbol='prevfy' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '本年' where labelbol='thisfy' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '明年' where labelbol='nextfy' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '上季度' where labelbol='prevfq' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '本季度' where labelbol='thisfq' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '下季度' where labelbol='nextfq' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '共%d条记录，明细%d条，覆盖%d条记录，成功导入%d条记录，失败%d条记录。' where labelbol='IMPORTRECORDTIP' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'A total of %d records, detailed %d, covering %d records, successfully imported %d records, failed %d records.' where labelbol='IMPORTRECORDTIP' and languagetype='en' and Labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel = 'User Management' where languagetype='en' and labelbol='LBL_USER_MANAGEMENT' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = 'User Management' where languagetype='en' and labelbol='LBL_USERS' and Labeltype = 'fixedstr';
delimiter;

select tabid into @tabid from ld_tab where name = 'Reminds';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,`status`,sequence)
select @fieldid,'Reminds','Rate',0,0 from dual where not exists
(select 1 from ld_fieldmodulerel where module = 'Reminds' and relmodule = 'Rate');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='ServiceReturn';
UPDATE ld_field set quickcreate=3 where tabid=@tabid; 
delimiter;

UPDATE ld_desk set fieldlabel='Public: Read/Edit' where Labeltype='fixedstr' AND labelbol='Public: Read, Create/Edit' AND languagetype='en';
UPDATE ld_desk set fieldlabel='Public: Read/Edit, Delete' where Labeltype='fixedstr' AND labelbol='Public: Read, Create/Edit, Delete' AND languagetype='en';
UPDATE ld_desk set fieldlabel='User can read/edit other users\'data' where Labeltype='fixedstr' AND labelbol='LBL_DESCRIPTION_Public: Read, Create/Edit' AND languagetype='en';
UPDATE ld_desk set fieldlabel='User can read/edit, delete other user\'data' where Labeltype='fixedstr' AND labelbol='LBL_DESCRIPTION_Public: Read, Create/Edit, Delete' AND languagetype='en';
delimiter;

call AddColumn('ld_timesheet','total','int','11',0); 
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet'; 
INSERT INTO ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,selectmodule,newline,defaultcolumn,is_checkimportfield)
select @tabid,'total','ld_timesheet','合计',0,0,'Span','N~O',2,22,0,0,0,NULL,1,2,0 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'total'); 
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'total'; 

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Total' from DUAL 
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and relateid = @tabdetailfieldid and languagetype='zh'); 

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Total' from DUAL 
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and relateid = @tabdetailfieldid and languagetype='en'); 
delimiter;

update ld_timesheet set total = sum_direct + sum_indirect where total = 0 or total is NULL; 

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
update ld_tabdetailfield set sequence=1000 where tabid=@tabid and columnname='total';

set @i=0;
update ld_tabdetailfield set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet'; 
select max(fieldid) into @fielid from ld_field; 
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'; 
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence, 
block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields, 
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield) 
select @tabid,@fielid+1,'total','ld_timesheet',1,7,'total','合计',0,0,NULL,NULL,1,@blockid,3,'N~O',1,NULL,NULL,1,NULL,0,0,NULL,NULL,0,0,NULL,NULL,2,0 from DUAL 
where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'total'); 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'total'; 
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'合计' from DUAL 
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Total' from DUAL 
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid); 
update ld_field_seq set id = (select max(fieldid) from ld_field); 
delimiter;

update ld_tabwithproductview set `columns`='ld_timesheet:total:total:TimeSheet_:N' where `columns` like 'ld_timesheet:sum_direct:sum_direct:%' 
	and cvid in (select cvid from ld_customview where entitytype='TimeSheet');
-- 2017-01-03

update ld_desk set fieldlabel='You can click' where labelbol='YOUCANCLICKONTHE' and languagetype='en';
update ld_desk set fieldlabel=' to add a record.' where labelbol='ADDARECORD' and languagetype='en';
update ld_desk set fieldlabel='You are not permitted to execute this operation' where labelbol='NOPERMITTEDEXECUTE' and languagetype='en';

update ld_tranlabel set fieldlabel='{$SalesOrder.SalesOrder}中产品单价自动根据客户最近购买记录带出' 
where trantable='ld_systems_deploy' AND tabid=79 AND Relateid=79 AND languagetype='zh'; 
update ld_tranlabel set fieldlabel='Whether the products unit price in the {$SalesOrder.SalesOrder} is automatically brought out according to the customers recent buy history' 
where trantable='ld_systems_deploy' AND tabid=79 AND Relateid=79 AND languagetype='en'; 
delimiter;
update ld_tranlabel set fieldlabel='{$SalesOrder.SalesOrder}同步接口触发点' 
where trantable='ld_systems_deploy' AND tabid=92 AND Relateid=92 AND languagetype='zh'; 
update ld_tranlabel set fieldlabel='The trigger point of the data interface about {$SalesOrder.SalesOrder}' 
where trantable='ld_systems_deploy' AND tabid=92 AND Relateid=92 AND languagetype='en'; 
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
delete from ld_blocks where tabid=@tabid and blocklabel = 'LBL_USER_MENUAPPROVAL1';
delimiter;

select id into @id from ld_option_showtableheader where module = 'PurchaseInvoice' and selectmodule = 'Stock';
select min(id) into @minid from ld_option_showheader_label where optionshowtabheader_id=@id and columnname = 'createdate';
delete from ld_option_showheader_label where optionshowtabheader_id=@id and columnname = 'createdate' and id>@minid;
delimiter;

select id into @id from ld_option_showtableheader where module = 'Invoice' and selectmodule = 'OutboundOrder';
select min(id) into @minid from ld_option_showheader_label where optionshowtabheader_id=@id and columnname = 'outdate';
delete from ld_option_showheader_label where optionshowtabheader_id=@id and columnname = 'outdate' and id>@minid;
delimiter;

select max(sequence)+1 into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,120,'常见问题是否启用审批流程。1:否，0:是','Faq',@sequence,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=120);
delimiter;

CALL AddColumn('ld_faq','approveby','int','19','0');
CALL AddColumn('ld_faq','currentapprover','varchar','1000',NULL);
CALL AddColumn('ld_faq','approvestatus','varchar','200','');

alter table ld_faq alter approvestatus set default '未提交';

select tabid into @tabid from ld_tab where name='Faq';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_faq',131,'approveby','审批人',1,(select blockid from ld_blocks where blocklabel='LBL_FAQ_INFORMATION'),2,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
delimiter;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'currentapprover','ld_faq',132,'currentapprover','当前审批人',1,(select blockid from ld_blocks where blocklabel='LBL_FAQ_INFORMATION'),2,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_faq',130,'approvestatus','审批状态',1,(select blockid from ld_blocks where blocklabel='LBL_FAQ_INFORMATION'),2,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'上一步审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当前审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

call fieldprofile('Faq');
delimiter;
call getallprofile('Faq');
delimiter;

select tabid into @tabid from ld_tab where name='Faq';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'常见问题默认流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='常见问题默认流程');
delimiter;

select id into @id from ld_approve where tabid=@tabid and name='常见问题默认流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
delimiter;

insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;

update ld_approve_seq set id=(select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
delimiter;

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

update ld_desk set fieldlabel = '注意：选择的用户没有该字段的查看和编辑权限(管理员除外)' where labelbol = 'NOTESELECTTHEUSERDOESNOTHAVETHEFIELDVIEWANDEDITPERMISSIONS' and languagetype = 'zh' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'Note: select the user does not have the field view and edit permissions(Administrator except)' where labelbol = 'NOTESELECTTHEUSERDOESNOTHAVETHEFIELDVIEWANDEDITPERMISSIONS' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

UPDATE ld_desk set fieldlabel='新增字段' where labelbol='ADDCUSTOMFIELDS' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel='显示隐藏' where labelbol='HIDDENFIELDS' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk set fieldlabel=' batch allocation' where labelbol='BATCHALLOCATION' AND Labeltype='jspop' AND languagetype='en';
delimiter;

update ld_tranlabel set fieldlabel='单据分录中调用产品时只能选择已审批的产品' where languagetype='zh' AND trantable='ld_systems_deploy' AND tabid=71;
delimiter;

select max(relation_id) into @maxrelation_id from  ld_relatedlists;
update ld_relatedlists_seq set id=@maxrelation_id+1  where not exists(select 1 from ld_relatedlists where tabid=6 and name='get_reminds');
select tabid into @related_tabid from ld_tab where name='reminds';

insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @maxrelation_id+1,6,@related_tabid,'get_reminds',10,'Reminds',0,'add' from dual
 where not exists(select 1 from ld_relatedlists where tabid=6 and name='get_reminds');
delimiter;

update ld_systems_deploy set presence=0  where deploy_type=71;
delimiter;
-- 2017-01-05

select block into @blockid from ld_field where tabid=29 and columnname='edit_other_mobile';
SELECT sequence into @seq from ld_field where tabid=29 and columnname='edit_other_mobile'; 
update ld_field set block=@blockid where tabid=29 and columnname='edit_me_mobile';
update ld_field set sequence=sequence+1 where tabid=29 and block=@blockid and sequence>@seq;
update ld_field set sequence=@seq+1 where tabid=29 and columnname='edit_me_mobile';
delimiter;

select fieldid into @fieldid from ld_field where tabid=29 and columnname='edit_me_mobile';
update ld_tranlabel set fieldlabel='允许编辑自己单据的手机号码字段' 
	where trantable='ld_field' and tabid=29 and Relateid=@fieldid and languagetype='zh';
delimiter;

update ld_desk set fieldlabel='完成情况统计图' where labelbol='TEMPLATESALESGOALIMG' AND languagetype='zh' AND Labeltype='fixedstr';
update ld_desk set fieldlabel='of the sales charts' where labelbol='TEMPLATESALESGOALIMG' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='转为普通' where labelbol='TURNORDINARY' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter;

select max(relation_id) into @maxrelation_id from  ld_relatedlists;
update ld_relatedlists_seq set id=@maxrelation_id+1  where not exists(select 1 from ld_relatedlists where tabid=6 and name='get_reminds');
select tabid into @related_tabid from ld_tab where name='reminds';

insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @maxrelation_id+1,6,@related_tabid,'get_reminds',10,'Reminds',0,'add' from dual
 where not exists(select 1 from ld_relatedlists where tabid=6 and name='get_reminds');
delimiter;
update ld_usereport set presence=0 where `name`='SalesSumSequence';
delimiter;

update ld_systems_deploy set presence=0  where deploy_type=71;
delimiter;
select tabid into @tabid from ld_tab where name = 'ContactRecords';
update ld_tranlabel set fieldlabel = '跟进记录' where languagetype = 'zh' and trantable = 'ld_tab' and tabid = @tabid and Relateid = @tabid;
delimiter;
update ld_field set readonly=1,displaytype=2 where columnname = 'approveby';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','supportformat','支持格式','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'supportformat' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','supportformat','Support format','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'supportformat' and Labeltype = 'jspop');
delimiter;

update ld_producttoolfield set tablename='ld_inventoryproductrel'
  where tabid  =(select tabid from ld_tab where name='WareHouseTransfer') and (columnname='listprice' or columnname='taxprice');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_cvcolumnlist_wx` (
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `modulename`     VARCHAR(100),
  `rownumber`     INT(4),
  `listnumber`     INT(4),
  `columnname` Varchar(255),
  `type`     INT(4) DEFAULT 0,
  `typedescribe`     Varchar(255),
  `presence`     INT(4) DEFAULT 0
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CALL AddColumn('ld_cvcolumnlist_wx','presence','int','4',0);
delimiter;
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
  select 'Accounts',0,0,'ld_account:accountname:accountname:Accounts_客户名称:V',2,'蓝色加粗' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Accounts' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Accounts',1,0,'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Accounts' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Accounts',1,1,'ld_account:rating:rating:Accounts_客户状态:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Accounts' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Accounts',1,2,'ld_account:createdtime:createdtime:Accounts_创建时间:D' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Accounts' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
  select 'Contacts',0,0,'ld_contactdetails:lastname:lastname:Contacts_姓名:V',2,'蓝色加粗' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Contacts' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Contacts',1,0,'ld_contactdetails:smownerid:assigned_user_id:Contacts_负责人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Contacts' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Contacts',1,1,'ld_contactdetails:accountid:account_id:Contacts_Account_Name:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Contacts' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
  select 'Contacts',1,2,'ld_contactdetails:mobile:mobile:Contacts_Mobile:V',10,'隐藏' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Contacts' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ContactRecords',0,0,'ld_contactrecords:subject:subject:ContactRecords_subject:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ContactRecords' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ContactRecords',1,0,'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_assigned_Name:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ContactRecords' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ContactRecords',2,0,'ld_contactrecords:accountid:account_id:ContactRecords_Account_Name:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ContactRecords' and rownumber=2 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ContactRecords',2,1,'ld_contactrecords:contactdate:contactdate:ContactRecords_contactdate:D' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ContactRecords' and rownumber=2 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,presence)
  select 'ContactRecords',3,0,'ld_contactrecords:contactid:contact_id:ContactRecords_Contact_Name:V',10,1 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ContactRecords' and rownumber=3 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'SalesOrder',0,0,'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_编号:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'SalesOrder' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'SalesOrder',0,1,'ld_salesorder:accountid:account_id:SalesOrder_客户:I',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'SalesOrder' and rownumber=0 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'SalesOrder',1,0,'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'SalesOrder' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'SalesOrder',1,1,'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'SalesOrder' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'SalesOrder',1,2,'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'SalesOrder' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'HelpDesk',0,0,'ld_troubletickets:ticket_no:ticket_no:HelpDesk_编号:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'HelpDesk' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'HelpDesk',0,1,'ld_troubletickets:accountid:account_id:HelpDesk_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'HelpDesk' and rownumber=0 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'HelpDesk',1,0,'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'HelpDesk' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'HelpDesk',1,1,'ld_troubletickets:status:ticketstatus:HelpDesk_状态:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'HelpDesk' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'HelpDesk',1,2,'ld_troubletickets:realtime:realtime:HelpDesk_fieldlabel:DT' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'HelpDesk' and rownumber=1 AND listnumber=2);


insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Potentials',0,0,'ld_potential:potentialname:potentialname:Potentials_机会名称:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Potentials' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Potentials',1,0,'ld_potential:smownerid:assigned_user_id:Potentials_负责人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Potentials' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Potentials',1,1,'ld_potential:accountid:account_id:Potentials_客户名称:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Potentials' and rownumber=1 AND listnumber=1);


insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Quotes',0,0,'ld_quotes:quote_no:quote_no:Quotes_编号:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Quotes' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Quotes',0,1,'ld_quotes:accountid:account_id:Quotes_客户:I',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Quotes' and rownumber=0 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Quotes',1,0,'ld_quotes:total:hdnGrandTotal:Quotes_合计:N' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Quotes' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Quotes',1,1,'ld_quotes:smownerid:assigned_user_id:Quotes_销售负责人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Quotes' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Quotes',1,2,'ld_quotes:createdtime:createdtime:Quotes_创建日期:D' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Quotes' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Products',0,0,'ld_products:productname:productname:InventoryQuery_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Products' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Products',1,0,'ld_products:usageunit:usageunit:Products_计量单位:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Products' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Products',1,1,'ld_products:productsheet:productsheet:Products_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Products' and rownumber=1 AND listnumber=1);


insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Project',0,0,'ld_project:project_no:project_no:Project_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Project' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Project',0,1,'ld_project:accountid:account_id:Project_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Project' and rownumber=0 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Project',1,0,'ld_project:targetbudget:targetbudget:Project_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Project' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Project',1,1,'ld_project:smownerid:assigned_user_id:Project_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Project' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Project',1,2,'ld_project:projectstatus:projectstatus:Project_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Project' and rownumber=1 AND listnumber=2);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ProjectTask',0,0,'ld_projecttask:projecttask_no:projecttask_no:ProjectTask_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectTask' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ProjectTask',0,1,'ld_projecttask:accountid:account_id:ProjectTask_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectTask' and rownumber=0 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ProjectTask',1,0,'ld_projecttask:costbudget:costbudget:ProjectTask_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectTask' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ProjectTask',1,1,'ld_projecttask:smownerid:assigned_user_id:ProjectTask_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectTask' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ProjectTask',1,2,'ld_projecttask:projecttaskstatus:projecttaskstatus:ProjectTask_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectTask' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ServiceContracts',0,0,'ld_servicecontracts:contract_no:contract_no:ServiceContracts_编号:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceContracts' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ServiceContracts',0,1,'ld_servicecontracts:accountid:account_id:ServiceContracts_客户:I',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceContracts' and rownumber=0 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ServiceContracts',1,0,'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceContracts' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ServiceContracts',1,1,'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_销售负责人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceContracts' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ServiceContracts',1,2,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceContracts' and rownumber=1 AND listnumber=2);

update ld_field set approve_demand = 2 where uitype = 15;
delimiter;

select blockid into @blockid from ld_settings_blocks where label = 'LBL_OTHER_SETTINGS';
select sequence into @sequence from ld_settings_field where name = 'BANGWO8INTERFACE';
update ld_settings_field set blockid=@blockid ,sequence=@sequence+1  where name = 'LBL_EXPANSION_CAMCARD';
delimiter;
update ld_desk set fieldlabel = '名片全能王接口' where languagetype = 'zh' and labelbol = 'LBL_EXPANSION_CAMCARD' and Labeltype = 'fixedstr';
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_return1_or','{$ServiceReturn.ServiceReturn}是针对{$HelpDesk.HelpDesk}或{$ProjectTask.ProjectTask}的，不允许直接新增','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='How_to_create_return1_or');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_return1_or','{$ServiceReturn.ServiceReturn} is for the {$HelpDesk.HelpDesk} or {$ProjectTask.ProjectTask}, direct creation is not allowed','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='How_to_create_return1_or');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_return2_or','可通过{$HelpDesk.HelpDesk}或{$ProjectTask.ProjectTask}查看明细界面，关联创建{$ServiceReturn.ServiceReturn}增加。','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='How_to_create_return2_or');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_return2_or','Through the {$HelpDesk.HelpDesk} , or {$ProjectTask.ProjectTask} view detail interface, associated to create a single {$ServiceReturn.ServiceReturn} visit.','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='How_to_create_return2_or');
delimiter;
-- 2016-01-06

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','supportformat','支持格式','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'supportformat' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','supportformat','Support format','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'supportformat' and Labeltype = 'jspop');
delimiter;

SELECT blockid into @blockid from ld_settings_blocks WHERE label='LBL_STUDIO';
DELETE from ld_settings_field where `name`='LBL_EXPANSION_CAMCARD' AND blockid=@blockid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EXPORT_LOG','导出日志','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EXPORT_LOG' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EXPORT_LOG','Export log','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='EXPORT_LOG' and Labeltype='fixedstr'); 
delimiter; 

update ld_option_showtableheader set from_clause = '[{"tablename":"fun:getInvoice_date_amount","othertablename":"crminvoice", "jointype":"left","joincontent":"crminvoice.entitytypeid=ld_outboundorder.out_id"}]'
where module = 'Invoice' and selectmodule = 'OutboundOrder';
delimiter;
-- 2017-01-09

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PLEASESELECTADATEATLEAST','至少选择一个日期！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'PLEASESELECTADATEATLEAST' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PLEASESELECTADATEATLEAST','Select at least one date!','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'PLEASESELECTADATEATLEAST' and Labeltype = 'jspop');
delimiter;

select tabid into @ctabid from ld_tab where name = 'Contacts';
select tabid into @itabid from ld_tab where name = 'Invoice';
delete from ld_relatedlists where tabid = @ctabid and related_tabid = @itabid;
delimiter;
-- 2017-01-10

select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='contactid';
update ld_tranlabel set fieldlabel='供应商联系人' where tabid=@tabid and trantable='ld_field' and Relateid=@fieldid and fieldlabel='联系人姓名';
delimiter;

update ld_field set quickcreate=3 where tabid=8;
update ld_field set fieldonly=1 where uitype=4;

update ld_tab set presence=1 where `name`='Dashboard';
update ld_settings_field set iconpath='migrate.png' where `name`='LBL_SERVICE_PERFORMANCE_PARAMETERS';

select tabid into @ctabid from ld_tab where name = 'Contacts';
select tabid into @itabid from ld_tab where name = 'Invoice';
delete from ld_relatedlists where tabid = @ctabid and related_tabid = @itabid;
delimiter;

update ld_systems_deploy set sequence = sequence+3 where roottype=4;
update ld_systems_deploy set roottype=4,sequence=1 where deploy_type=61;
update ld_systems_deploy set roottype=4,sequence=2 where deploy_type=26;
update ld_systems_deploy set roottype=4,sequence=3 where deploy_type=110;
set @i=0; 
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=4 order by sequence; 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MOBILENUMBER','手机号码','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MOBILENUMBER' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MOBILENUMBER','Mobile number','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MOBILENUMBER' and Labeltype='fixedstr'); 
delimiter; 

update ld_desk set fieldlabel='Change ' where labelbol='CHANGE' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type = 109;
select roottype into @roottype from ld_systems_deploy where deploy_type = 109;
set @i=@sequence+1;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype and sequence >@sequence;
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type = 109;
select roottype into @roottype from ld_systems_deploy where deploy_type = 109;
update ld_systems_deploy set sequence = @sequence + 1 where roottype = @roottype and deploy_type=116;
update ld_systems_deploy set sequence = @sequence + 1 where roottype = @roottype and deploy_type=117;
update ld_systems_deploy set sequence = @sequence + 1 where roottype = @roottype and deploy_type=118;
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype ORDER BY sequence asc;
delimiter;

update ld_desk set fieldlabel=' And ' where languagetype='en' AND Labeltype='fixedstr' AND labelbol='AND';
delimiter;

update ld_desk set fieldlabel=' Duplicate check field ' where labelbol='CHECKIMPORTFIELD' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;
-- 2017-01-11

delete from ld_cvcolumnlist_wx where modulename='ProjectTask' and columnname like 'ld_projecttask:costbudget:costbudget%';
update ld_cvcolumnlist_wx set rownumber=1,listnumber=0 where modulename='ProjectTask' and columnname like 'ld_projecttask:smownerid:assigned_user_id%';
update ld_cvcolumnlist_wx set rownumber=1,listnumber=1 where modulename='ProjectTask' and columnname like 'd_projecttask:projecttaskstatus:projecttaskstatus%';

SELECT tabid into @tabid from ld_tab where `name`='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Reminds','ProjectProgress',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Reminds' and relmodule = 'ProjectProgress');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Reminds','TimeSheet',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Reminds' and relmodule = 'TimeSheet');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','Calendar',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'Calendar');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','Faq',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'Faq');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','SalesBack',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'SalesBack');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','ServiceCharge',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'ServiceCharge');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','ServiceReturn',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'ServiceReturn');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','ProjectProgress',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'ProjectProgress');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','PurchaseInvoice',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'PurchaseInvoice');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','CashBack',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'CashBack');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','PurchaseCashBack',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'PurchaseCashBack');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','PaymentPlan',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'PaymentPlan');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','SendPayment',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'SendPayment');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','Commission',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'Commission');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','PutCash',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'PutCash');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','CashDeposit',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'CashDeposit');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','BankAccountSet',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'BankAccountSet');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','WareHouseTransfer',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'WareHouseTransfer');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','VendorContact',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'VendorContact');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','VendorContactRecords',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'VendorContactRecords');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','PurchaseBack',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'PurchaseBack');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','Products',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'Products');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='Attachment';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Attachment','Productbom',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Attachment' and relmodule = 'Productbom');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DELETETISHI','删除','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELETETISHI' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DELETETISHI',' delete ','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DELETETISHI' and Labeltype='fixedstr'); 
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','OutboundOrder',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'OutboundOrder');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','SalesOrder',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'SalesOrder');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','ContactRecords',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'ContactRecords');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Vendors',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Vendors');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Quotes',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Quotes');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Calendar',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Calendar');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','VendorContact',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'VendorContact');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Products',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Products');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Expense',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Expense');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Commission',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Commission');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Documents',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Documents');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','TimeSheet',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'TimeSheet');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','ProjectProgress',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'ProjectProgress');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','ServiceContracts',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'ServiceContracts');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Campaigns',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Campaigns');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','PurchaseOrder',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'PurchaseOrder');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','VendorContactRecords',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'VendorContactRecords');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','ServiceCharge',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'ServiceCharge');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','ProjectMilestone',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'ProjectMilestone');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','PutCash',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'PutCash');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','ServiceReturn',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'ServiceReturn');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Checks',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Checks');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','SendPayment',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'SendPayment');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Invoice',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Invoice');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Stock',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Stock');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','CashBill',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'CashBill');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','Attachment',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'Attachment');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'ModComments','CashDeposit',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'ModComments' and relmodule = 'CashDeposit');
delimiter; 

update ld_products set unit_price = 0 where unit_price is NULL or unit_price = '';
delimiter;

select versiontype into @versiontype from ld_version;
select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
update ld_field set presence = 1 where tabid = @tabid and columnname = 'salesorderid' and @versiontype = 10;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ifthestatehasebeenselectedaspartofthe','若是选择状态为部分已收或已收，保存之后则不可再编辑该单据。是否需要保存？','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ifthestatehasebeenselectedaspartofthe' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ifthestatehasebeenselectedaspartofthe','If the state has been selected as part of the collection or has been received, after the preservation of the document can not be re edited. Do you need to save?','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ifthestatehasebeenselectedaspartofthe' and Labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel='没有找到任何记录！<br>可能原因：您没有模块操作权限，请联系管理员！' where labelbol='Youdonothavemoduleoperationrights' AND languagetype='zh' AND Labeltype='fixedstr';
update ld_desk set fieldlabel='No data found！<br>Possible reason：You do not have module operation rights, please contact the administrator!' where labelbol='Youdonothavemoduleoperationrights' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

select sequence into @seq from ld_systems_deploy where deploy_type=118;
select roottype into @roottype from ld_systems_deploy where deploy_type=118;
update ld_systems_deploy set sequence=sequence+10 where sequence>@seq and roottype=@roottype;
update ld_systems_deploy set roottype=@roottype,sequence=@seq+1 where deploy_type=119;

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=@roottype order by sequence;
delimiter;

update ld_desk set fieldlabel = 'Please input the user name' where labelbol = 'PLEASEINPUTYOUWANTTOFINDTHEUSER' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
-- 2017-01-13

update ld_salesorder set stockpresence = '未出库' where stockpresence = 'SALESORDERNOTOUTSTOCK';
update ld_salesorder set stockpresence = '未采购' where stockpresence = 'NOPURCHASE';
delimiter;
-- 2017-01-16

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
delimiter;

update ld_version set old_version='V6.6.0' ,current_version='V6.6.0' ,remark='V6.6.0-20170116';
delimiter;