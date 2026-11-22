CALL DEL_FK('ld_reminds','ld_reminds_ibfk_1');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','themodulehasenotemailfield','该模块没有Eamli字段！','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='themodulehasenotemailfield' and Labeltype='jspop');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','themodulehasenotemailfield','The module has no Eamli field!','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='themodulehasenotemailfield' and Labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '写邮件' where labelbol = 'LBL_Compose' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Write mail' where labelbol = 'LBL_Compose' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '收邮件' where labelbol = 'LBL_GETBOX' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Charge mail' where labelbol = 'LBL_GETBOX' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '需购买并设置短信账户' where labelbol = 'NEEDBUYACCOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '发送短信失败，请联系管理员设置短信账户' where labelbol = 'COMMUNICATIONACCOUNTISNOTSETEMPTYFAILED' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;
-- 218-08-15

ALTER TABLE ld_smssend MODIFY COLUMN ReceiveContacts VARCHAR(255);

DROP PROCEDURE IF EXISTS `ldcrm_add_sms`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_sms`(
	tmp_mobile VARCHAR(50),
	tmp_jieshouren VARCHAR(255),
	tmp_content TEXT,
	tmp_sendtime DATETIME,
	tmp_sender VARCHAR(100),
	tmp_relatedid INT(19)
)
BEGIN

	SET @cnt=(SELECT COUNT(SubmitTime) FROM ld_smssend WHERE DATE_FORMAT(SubmitTime,'%Y-%m-%d')=CURDATE());

	INSERT INTO ld_smssend(
		TaskID,
		BatchNo,
		CalledNumber,
		SmsContent,
		SubmitTime,
		CreateTime,
		SmsResult,
		SmsBillingFee,
		operator,
		ReceiveContacts,
		FDataStatu,
		relatieid
	)
	SELECT
		IFNULL((SELECT MAX(TaskID) FROM ld_smssend),0)+1,
		CONCAT('sms',DATE_FORMAT(NOW(),'%Y%m%d'),LPAD(@cnt+1,8,0)),
		tmp_mobile,
		tmp_content,
		tmp_sendtime,
		NOW(),
		0,
		0.00,
		tmp_sender,
		tmp_jieshouren,
		0,
		tmp_relatedid;

end ||
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select sequence into @sequence from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_INFORMATION';
update ld_blocks set sequence = sequence + 100 where tabid = @tabid and sequence >@sequence;
select max(blockid) into @blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom,linkid)
select @blockid+1,@tabid,'LBL_LOCATION_ADDRESS',@sequence+1,0,0,0,0,0,1,0,NULL from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_LOCATION_ADDRESS');
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_LOCATION_ADDRESS';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'定位地址' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Location address' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
SET @i=0;
UPDATE ld_blocks SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_LOCATION_ADDRESS' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'locationaddress','yes','ld_account',1,65,'locationaddress','定位地址',1,2,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'定位地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Location address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_account','locationaddress','varchar','255',null);
delimiter;

CALL AddColumn('ld_salesorder','totalquantity','decimal','25,8',0);
delimiter;

alter table ld_salesorder modify column totalquantity decimal(25,8);

select tabid into @tabid from ld_tab where name='salesorder';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid  from ld_field ;
update ld_field_seq set id=@fieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='totalquantity');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@fieldid+1,'totalquantity','no','ld_salesorder',560,'totalquantity','数量合计',0,0,@sequence+1,@blockid,4,'N~O',1,2,0 from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='totalquantity');
delimiter;
select tabid into @tabid from ld_tab where name='salesorder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='totalquantity';

insert into ld_tranlabel(trantable,relateid,tabid,fieldlabel,languagetype)
select 'ld_field',@fieldid,@tabid,'数量合计','zh' from dual 
where not exists(select 1 from ld_tranlabel where relateid=@fieldid and tabid=@tabid  and languagetype='zh');

insert into ld_tranlabel(trantable,relateid,tabid,fieldlabel,languagetype)
select 'ld_field',@fieldid,@tabid,'total quantity','en' from dual 
where not exists(select 1 from ld_tranlabel where relateid=@fieldid and tabid=@tabid  and languagetype='en');
delimiter;

call getallprofile('salesorder');
delimiter;

update ld_salesorder  INNER JOIN (select sum(ifnull(quantity,0)) as totalquantity,id from ld_inventoryproductrel group by  id)
as tmp 
on ld_salesorder.salesorderid=tmp.id  
set ld_salesorder.totalquantity=tmp.totalquantity;
delimiter;

CALL AddColumn('ld_users','wx_userid_old','varchar','255',null);
delimiter;

update ld_desk set fieldlabel = '{$Commission.Commission}明细' where labelbol = 'COMMISSIONINFO' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TIME1','次','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TIME1' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TIME1','time','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TIME1' and Labeltype='fixedstr');
delimiter;

CREATE TABLE if not EXISTS `ld_approvereminds_backup` (
  `approvereminds_backupid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stepid` int(11) DEFAULT NULL,
  `type` tinyint(4) DEFAULT NULL,
  `remindmethod` varchar(100) DEFAULT NULL,
  `reminduser` varchar(100) DEFAULT NULL,
  `remindcontent` text,
  `reminduserid` varchar(200) DEFAULT NULL,
	`inserted` varchar(200) ,
  PRIMARY KEY (`approvereminds_backupid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_approvereminds_backup  select id,stepid,type,remindmethod,reminduser,remindcontent,reminduserid,'no' from ld_approvereminds
where not exists(select 1 from ld_approvereminds_backup);
delimiter;
delete from ld_approvereminds where  remindmethod  like '%,%';
delimiter;
call AddColumn('ld_approvereminds','remindcolumnname','text',1000,0);
delimiter;

CREATE TABLE if not exists `ld_reminds_weixin` (
  `remindsweixinid` int(19) NOT NULL,
  `Content` text,
  `receiverid` varchar(255) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `Related_to` int(19) DEFAULT NULL,
  `reltab` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`remindsweixinid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

create table if not exists tmp_remindmethodtable(
str varchar(100)
);
delimiter;

create table if not exists tmp_remindusertable(
str varchar(100)
);


drop PROCEDURE if exists insertintoapproveremindsinfo;
delimiter ||
create PROCEDURE insertintoapproveremindsinfo()
BEGIN
	declare done int default 0;
	declare  sstepid int(19);
	declare ttype int(11);
	declare rremindmethod varchar(100);
	declare rreminduser varchar(100);
	declare rremindcontent varchar(500);
	declare rreminduserid varchar(1000);
	DECLARE cur1 CURSOR FOR
		SELECT  stepid,type,remindmethod,reminduser,remindcontent,reminduserid from  ld_approvereminds_backup 
     where  not  exists(select 1 from ld_approvereminds) and inserted='no';

	  declare continue handler for not found SET done =1;
		open cur1;
		fetch cur1 into sstepid,ttype,rremindmethod,rreminduser,rremindcontent,rreminduserid;
		loop1: while done<>1 do
		call splitstr(rremindmethod,',');
		delete from  tmp_remindmethodtable;
		 insert into tmp_remindmethodtable select *   from splitstrlist;
     call splitstr(rreminduser,',');
		delete from tmp_remindusertable;

		 insert into tmp_remindusertable select * from splitstrlist;
		call loopapproveremindmethod(sstepid,ttype,rreminduserid,rremindcontent);
		fetch cur1 into sstepid,ttype,rremindmethod,rreminduser,rremindcontent,rreminduserid;
		end while loop1; 
		close cur1;
end ||
delimiter;

drop PROCEDURE if exists loopapproveremindmethod;
delimiter ||
create PROCEDURE loopapproveremindmethod
(
	sstepid int(19),
	ttype int(11),
	reminduserid varchar(1000),
	rremindcontent varchar(500)
)
begin 
	declare ddone int default 0;
	declare splitremindmethod varchar(100);
	DECLARE cur2 CURSOR FOR
		SELECT  *  from  tmp_remindmethodtable  where str is not null and str<>'';

	  declare continue handler for not found SET ddone =1;
	open cur2;
		fetch cur2 into splitremindmethod;
		loop2: while ddone<>1 do
		call loopapprovereminduser(sstepid,ttype,splitremindmethod,reminduserid,rremindcontent);
		fetch cur2 into splitremindmethod;
		end while loop2; 
		close cur2;

end ||
delimiter;

drop PROCEDURE if exists loopapprovereminduser;
delimiter ||
create PROCEDURE loopapprovereminduser
(
	sstepid int(19),
	ttype int(11),
	remindmethod varchar(100),
	reminduserid varchar(1000),
	rremindcontent varchar(500)
)
begin 
	declare dddone int default 0;
	declare splitreminduser varchar(100);
	DECLARE cur3 CURSOR FOR
		SELECT  *  from  tmp_remindusertable  where str is not null and str<>'' ;

	  declare continue handler for not found SET dddone =1;
		open cur3;
		fetch cur3 into splitreminduser;
		loop3: while dddone<>1 do
			
					
					set @sql=CONCAT (' insert into ld_approvereminds (stepid,type,remindmethod,reminduser,remindcontent,reminduserid ) value( ',sstepid);
					set @sql=CONCAT(@sql,",",ttype,",'",remindmethod,"','",splitreminduser,"','",ifnull(rremindcontent,''),"','",ifnull(reminduserid,''),"')");
					
					 prepare stmt from @sql; 
						execute stmt; 
						deallocate prepare stmt;
		
			  fetch cur3 into splitreminduser;
		end while loop3; 
		close cur3;

end ||
delimiter;

call insertintoapproveremindsinfo();
delimiter;
update ld_approvereminds_backup set inserted='yes';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ASSIGNACCOUNTEMAIL','指定{$Accounts.Accounts}邮箱','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='ASSIGNACCOUNTEMAIL' and Labeltype='fixedstr');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ASSIGNACCOUNTEMAIL','assign {$Accounts.Accounts} email','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='ASSIGNACCOUNTEMAIL' and Labeltype='fixedstr');
 delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ASSIGNCONTACTEMAIL','指定{$Contacts.Contacts}邮箱','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='ASSIGNCONTACTEMAIL' and Labeltype='fixedstr');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ASSIGNCONTACTEMAIL','assign {$Contacts.Contacts} email','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='ASSIGNCONTACTEMAIL' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ASSIGNACCOUNTSSMS','指定{$Accounts.Accounts}手机','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='ASSIGNACCOUNTSSMS' and Labeltype='fixedstr');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ASSIGNACCOUNTSSMS','assign {$Accounts.Accounts} mobile','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='ASSIGNACCOUNTSSMS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ASSIGNCONTACTSMS','指定{$Contacts.Contacts}手机','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='ASSIGNCONTACTSMS' and Labeltype='fixedstr');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ASSIGNCONTACTSMS','assign {$Contacts.Contacts} mobile','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='ASSIGNCONTACTSMS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WEIXIN','微信','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='WEIXIN' and Labeltype='fixedstr');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','WEIXIN','WeChat','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='WEIXIN' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESETREMINDER','请设置提醒人！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='PLEASESETREMINDER' and Labeltype='fixedstr');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESETREMINDER','Please set reminder','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='PLEASESETREMINDER' and Labeltype='fixedstr');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 14 and columnname = 'unit_price';
update ld_tranlabel set fieldlabel = CONCAT(fieldlabel,'(RMB)') where tabid = 14 and Relateid = @fieldid and (languagetype = 'zh' or languagetype = 'en')
and trantable = 'ld_field' and fieldlabel not LIKE '%(RMB)%';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','waitforsending','待发送','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='waitforsending' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','waitforsending','Wait for sending','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='waitforsending' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,fieldlabel,labelbol,labeltype)
select 'zh','自动提醒时间参考字段之日起提前N天提醒：正数表示提前，负数表示延后','ANNUALREMINDEXPLAIN','fixedstr' from dual 
 where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='ANNUALREMINDEXPLAIN' and ifnull(fieldlabel,'')<>'');
delimiter;

insert into ld_desk (languagetype,fieldlabel,labelbol,labeltype)
select 'zh','提前','AHEAD','fixedstr' from dual 
 where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='AHEAD' and ifnull(fieldlabel,'')<>'');

delimiter
update ld_field set uitype=71 where columnname='loanmoney' and tabid in(select tabid from ld_tab where name='LoanApply');
delimiter;

update ld_desk set fieldlabel = '提醒模式' where labelbol = 'REMINDMODEL' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'thelocationaddress' where labelbol = 'REMINDMODEL' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;


DROP TABLE IF EXISTS tmp_remindmethodtable;
DROP TABLE IF EXISTS tmp_remindusertable;

UPDATE ld_desk SET fieldlabel='自分配或创建之日起' WHERE labelbol='ALLOCATEORCREATETIMESTART' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='from the date of distribution or creation' WHERE labelbol='ALLOCATEORCREATETIMESTART' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;
-- 2018-08-20

DROP PROCEDURE IF EXISTS `del_idx`;
DROP PROCEDURE IF EXISTS `Del_TableIndex`;
delimiter ||
CREATE PROCEDURE `Del_TableIndex`(
	tmp_tablename varchar(100),
	tmp_indexname varchar(100)
)
BEGIN  

	IF EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND index_name=tmp_indexname) THEN  
		SET @execsql=CONCAT(' DROP INDEX ',tmp_indexname,' ON ',tmp_tablename);
		PREPARE stmt_execsql FROM @execsql; 
		EXECUTE stmt_execsql;
		DEALLOCATE PREPARE stmt_execsql;
	END IF;

end ||
delimiter;



DROP PROCEDURE IF EXISTS `DelForeignkey`;
DROP PROCEDURE IF EXISTS `Del_ForeignKey`;
delimiter ||
CREATE PROCEDURE `Del_ForeignKey`(
	tmp_tablename varchar(100),
	tmp_fkeyname varchar(100)
)
BEGIN

	IF EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE WHERE CONSTRAINT_NAME=tmp_fkeyname AND TABLE_NAME=tmp_tablename AND TABLE_SCHEMA=DATABASE()) THEN
		SET @execsql=CONCAT(' ALTER TABLE ',tmp_tablename, ' DROP FOREIGN KEY ',tmp_fkeyname);
		PREPARE stmt_execsql FROM @execsql; 
		EXECUTE stmt_execsql;
		DEALLOCATE PREPARE stmt_execsql;
	END IF;

end ||
delimiter;

CALL Del_ForeignKey('ld_invoice','ld_invoice_ibfk_1');
CALL Del_TableIndex('fk_2_vtiger_invoice','ld_invoice');
CALL Del_TableIndex('invoice_contactid_idx','ld_invoice');
CALL Del_TableIndex('invoice_accountid_idx','ld_invoice');
-- 2018-08-21

DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_users`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_attachments_filename_users`(
)
BEGIN
	
	SET @blockid=IFNULL((SELECT blockid FROM ld_blocks WHERE tabid=29 AND visible=0 AND blocklabel='LBL_ATTACHMENTS_INFOMATION'),0);
	IF @blockid>0 THEN
		SET @tabid=29;
		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
		SET @trantable='ld_field';
		SET @tablename='ld_attachments';
		SET @columnname='filename'; 
		SET @fieldname='filename'; 
		SET @zh='附件'; 
		SET @en='Attachment'; 
		SET @uitype=1109; 

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0 from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		CALL getallprofile('Users');
		CALL fieldprofile('Users');

	END IF;
	

end ||
delimiter;


CALL ldcrm_add_attachments_filename_users();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_users`;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Productbom');
UPDATE ld_producttoolfield SET columnname='product_no',fieldid=175 WHERE tabid=@tabid AND fieldlabel='产品编号' AND tablename='ld_products' AND fieldid=174;
-- 2018-08-22

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
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.4.8',current_version='V7.4.8',remark='V7.4.8-20180820',wx_version='V7.4.5';
delimiter;