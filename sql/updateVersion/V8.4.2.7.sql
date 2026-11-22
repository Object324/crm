DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF tmp_columnlen<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
	END IF;

end ||
delimiter;

CREATE TABLE IF NOT EXISTS `ld_external_contact` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`contactid` int(11) DEFAULT NULL  COMMENT '联系人表主键id',
	`external_name` VARCHAR(80) DEFAULT NULL  COMMENT '外部联系人姓名',
	`weixin_external_userid` VARCHAR(255) DEFAULT NULL COMMENT '外部联系人ID',
	`session_external_userid` VARCHAR(255) DEFAULT NULL COMMENT '会话存档联系人的ID',
	`created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Interfaceparameter','接口参数信息不完整，请先配置！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Interfaceparameter' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Interfaceparameter','Interface parameter information is incomplete, please configure first!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Interfaceparameter' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_users','yxc_uid','varchar','50',null);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncName','同步联系人姓名/群名','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SyncName' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncName','Synchronize contact name/group name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SyncName' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncExternalContactName','同步外部联系人姓名','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SyncExternalContactName' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncExternalContactName','Synchronize external contact names','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SyncExternalContactName' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncGroupName','同步群名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SyncGroupName' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncGroupName','Synchronize group names','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SyncGroupName' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportExternalContacts','导入外部联系人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ImportExternalContacts' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportExternalContacts','Import external contacts','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ImportExternalContacts' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_external_contact (contactid, external_name,weixin_external_userid,session_external_userid) 
SELECT 
	contactid,
	lastname,
	weixin_external_userid,
	weixin_external_userid 
FROM ld_contactdetails 
WHERE deleted = 0 
	AND ifnull(weixin_external_userid,"") <> '' 
	AND ifnull(lastname,"") <> '' 
	AND NOT EXISTS (SELECT 1 FROM ld_external_contact WHERE contactid > 0 LIMIT 1) 
GROUP BY weixin_external_userid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Andthesizecannotexceed2MB','且大小不能超过2MB！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Andthesizecannotexceed2MB' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Andthesizecannotexceed2MB',' And the size cannot exceed 2MB!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Andthesizecannotexceed2MB' and Labeltype='jspop' and languagetype='en');
delimiter;


call AddColumn('ld_external_contact','corp_name','varchar','255',null);
delimiter;

update ld_producttoolfield set savedatabase = 'yes' where columnname in ('entitytype','entitytypeid','subtotal','total','contractid');
delimiter;

CALL AddColumn('ld_customreport','can_penetrate','varchar','50','no');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOVE','移动','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MOVE' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOVE','move to','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MOVE' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CREATENEWECHARTS','新建统计图','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CREATENEWECHARTS' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CREATENEWECHARTS','new statistical chart','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CREATENEWECHARTS' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Conversation','的会话','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Conversation' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Conversation',"'s conversation",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Conversation' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APIcustomfieldquery','Api自定义字段查询','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='APIcustomfieldquery' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APIcustomfieldquery','API custom field query','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='APIcustomfieldquery' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Headerfield','头部字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Headerfield' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Headerfield','Header field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Headerfield' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Entryfield','分录字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Entryfield' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Entryfield','Entry field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Entryfield' and Labeltype='fixedstr' and languagetype='en');
delimiter;


CREATE TABLE if not exists `ld_wechatexternalid` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `externalid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid  from ld_tab where name='potentials';
select actionid into @dupactionid from ld_actionmapping where actionname='accountdatadup';
select actionid into @delactionid from ld_actionmapping where actionname='delete';

select sequence into @delsequence from ld_profileallpermission where tabid=@tabid and operation=@delactionid;
update ld_profileallpermission set sequence=sequence+2 where tabid=@tabid and sequence>@delsequence;
insert into ld_profileallpermission(tabid ,operation,sequence)
select @tabid,@dupactionid,@delsequence+1  from dual 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@dupactionid);

SET @i=0;
UPDATE ld_profileallpermission SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;
-- 2021-05-18

INSERT INTO ld_attachmentstype(file_type)
SELECT 'mp4' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_attachmentstype WHERE file_type='mp4') AND NOT EXISTS (SELECT 1 FROM ld_attachments);

call AddColumn('ld_loanapply','bankaccountsetid','int','19',NULL);
call AddColumn('ld_loanapply','currency_id','int',1,1);
call AddColumn('ld_loanapply','conversion_rate','int',1,1);
call AddColumn('ld_loanapply','currency_symbol','varchar','30',NULL);
delimiter;

ALTER TABLE ld_loanapply MODIFY COLUMN conversion_rate decimal(25,6);
ALTER TABLE ld_loanapply ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_loanapply ALTER COLUMN conversion_rate SET DEFAULT '1.000000';
ALTER TABLE ld_loanapply ALTER COLUMN currency_symbol SET DEFAULT '¥';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='LoanApply');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('LoanApply'),'_LOANINFO') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'bankaccountsetid','yes',CONCAT('ld_',LOWER('LoanApply')),1,251,'bankaccountsetid','账户',1,2,2,@blockid,1,'V~O',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='bankaccountsetid');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bankaccountsetid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'账户' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Account' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='LoanApply');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('LoanApply'),'_LOANINFO') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'currency_id','yes',CONCAT('ld_',LOWER('LoanApply')),1,117,'currency_id','币种',1,1,15,@blockid,1,'V~M',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'币种' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Currency' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

CALL AddColumn('ld_customreport','relatedmodule','varchar','300','');
delimiter;
-- 2021-05-24

UPDATE ld_field SET allowhide='yes' WHERE tabid=20 AND columnname='quotestage';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='nolinkdays'; 
SET @fieldname='nolinkdays'; 
SET @zh='未联系天数'; 
SET @en='nolinkdays'; 
SET @uitype=7; 
SET @typeofdata='NN~O~19,0';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='number';
SET @datarang='';
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

call AddColumn('ld_leads','nolinkdays','int','19','0');
delimiter;

DROP EVENT IF EXISTS `update_lead_nolinkdays`;
CREATE EVENT `update_lead_nolinkdays`
ON SCHEDULE EVERY 1 DAY STARTS '2021-05-24 00:30:00' ON COMPLETION NOT PRESERVE ENABLE
DO
UPDATE ld_leads SET nolinkdays=DATEDIFF(CURDATE(),DATE_FORMAT(IFNULL(lastcontactdate,createdtime),'%Y-%m-%d'));
delimiter;
-- 2021-05-24

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms');
UPDATE ld_tranlabel SET fieldlabel='自定义表单' WHERE Relateid=@parenttabid AND trantable='ld_parenttab' AND languagetype='zh' AND fieldlabel='Custom Forms';
delimiter;

update ld_producttoolfield set savedatabase = 'yes' where columnname in ('discount_percent','quantity','paperquantity','pro_id','actualtaxprice');
delimiter;

CALL AddColumn('ld_customreport','relatedmodule','varchar','300','');
delimiter;

update ld_tabdetailfield set savedatabase = 'yes' where columnname in ('rmb_total');
delimiter;


CALL AddColumn('ld_callbutler','talkid','varchar','50',NULL);
CALL addtableIndex('ld_callbutler','index_talkid','talkid');
delimiter;

update ld_desk set fieldlabel = '说明：在所有{$Accounts.Accounts}中进行查重，最多只显示符合条件的前{Var}条数据。'
				where labelbol = 'NOTECHECKCUSTOMERS' and languagetype = 'zh';
delimiter;

update ld_desk set fieldlabel = 'Note: check in all of the {$Accounts.Accounts}, only the first {Var} qualifying data.'
				where labelbol = 'NOTECHECKCUSTOMERS' and languagetype = 'en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NOTECHECKPOTENTIALS','说明：在所有{$Potentials.Potentials}中进行查重，最多只显示符合条件的前{Var}条数据。','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NOTECHECKPOTENTIALS' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NOTECHECKPOTENTIALS','Note: check in all of the {$Potentials.Potentials}, only the first {Var} qualifying data.','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NOTECHECKPOTENTIALS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllowNewCommonLead"','允许新建“普通{$Leads.Leads}”','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowNewCommonLead' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllowNewCommonLead','Allow new "common {$Leads.Leads}"','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowNewCommonLead' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateAndMaintainMultipleHighSeasPoolOfLeads','说明：建立多个公海，对多个公海进行维护：设置每个公海允许保有{$Leads.Leads}的上限、回收条件、指定公海管理员和公海成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateAndMaintainMultipleHighSeasPoolOfLeads' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateAndMaintainMultipleHighSeasPoolOfLeads','Description:create multiple high seas and maintain multiple high seas: set the upper limit of each high seas allowed to keep {$Leads.Leads}, recycling conditions, and specify high seas administrators and high seas members','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateAndMaintainMultipleHighSeasPoolOfLeads' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CommonSalesLeadAutomaticRecoveryRuleSettings','普通{$Leads.Leads}自动回收规则设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CommonSalesLeadAutomaticRecoveryRuleSettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CommonSalesLeadAutomaticRecoveryRuleSettings','Common {$Leads.Leads} automatic recovery rule Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CommonSalesLeadAutomaticRecoveryRuleSettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnableCommonLeadsAutomaticReclaimRules','启用普通{$Leads.Leads}自动回收规则，自动回收到公海','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EnableCommonLeadsAutomaticReclaimRules' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnableCommonLeadsAutomaticReclaimRules','Enable common {$Leads.Leads} automatic recovery rules, automatic recovery to the high seas','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EnableCommonLeadsAutomaticReclaimRules' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CommonLeadsParticipateInRecycling','普通{$Leads.Leads}参与回收，回收规则条件逻辑关系为','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CommonLeadsParticipateInRecycling' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CommonLeadsParticipateInRecycling','Common {$Leads.Leads} participate in recycling, and the logical relationship of recycling rules is as','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CommonLeadsParticipateInRecycling' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MaximumNumberOfAssignedLeadsInHighSeas','公海已分配{$Leads.Leads}数量上限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MaximumNumberOfAssignedLeadsInHighSeas' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MaximumNumberOfAssignedLeadsInHighSeas','Maximum number of assigned {$Leads.Leads} in high seas','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MaximumNumberOfAssignedLeadsInHighSeas' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnallocateLeadsAdmin','不允许领取公海未分配{$Leads.Leads}，只能由公海管理员分配','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UnallocateLeadsAdmin' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnallocateLeadsAdmin','It is not allowed to get the unallocated {$Leads.Leads} from the high seas, which can only be allocated by the high seas administrator','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UnallocateLeadsAdmin' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LeadsControlPublic','不控制公海未分配{$Leads.Leads}的数据权限，允许查询所有公海未分配{$Leads.Leads}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LeadsControlPublic' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LeadsControlPublic','Do not control the data permission of unassigned {$Leads.Leads} in high seas, and allow to query all unassigned {$Leads.Leads} in high seas','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LeadsControlPublic' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllowTheUnallocatedLeadsToBeDisplayList','允许公海未分配{$Leads.Leads}显示在“全部（含公海）”列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowTheUnallocatedLeadsToBeDisplayList' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllowTheUnallocatedLeadsToBeDisplayList','Allow high seas unassigned {$Leads.Leads} to be displayed in all (including high seas) list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowTheUnallocatedLeadsToBeDisplayList' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllowTheAllocatedLeadsToBeDisplayList','允许公海已分配{$Leads.Leads}显示在“全部（含公海）”列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowTheAllocatedLeadsToBeDisplayList' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllowTheAllocatedLeadsToBeDisplayList','Allow high seas assigned {$Leads.Leads} to be displayed in all (including high seas) list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowTheAllocatedLeadsToBeDisplayList' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllowUsersToTransferTheAllocatedLeadsToOtherSeas','允许公海成员将已分配或领取的公海{$Leads.Leads}转移到其他公海','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowUsersToTransferTheAllocatedLeadsToOtherSeas' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllowUsersToTransferTheAllocatedLeadsToOtherSeas','Allow high seas members to transfer the assigned or received high seas {$Leads.Leads} to other high seas','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllowUsersToTransferTheAllocatedLeadsToOtherSeas' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewButtonDropDownOptionsOfLeads','公海成员{$Leads.Leads}序时簿“新建”功能下拉选项','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NewButtonDropDownOptionsOfLeads' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewButtonDropDownOptionsOfLeads',"Drop down option of 'new' function in high seas member's {$Leads.Leads} list",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NewButtonDropDownOptionsOfLeads' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AfterConvertingModfyTheLeadsOwner','{$Leads.Leads}转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AfterConvertingModfyTheLeadsOwner' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AfterConvertingModfyTheLeadsOwner','After the {$Leads.Leads} is transferred to the high seas, the person in charge of the change (only the high seas member can be selected, if it is blank, it means not to change)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AfterConvertingModfyTheLeadsOwner' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AfterReleasignTheAllocatedHighSeasOfLeads','公海已分配{$Leads.Leads}释放后，更改销售线索负责人为（为空表示不更改）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AfterReleasignTheAllocatedHighSeasOfLeads' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AfterReleasignTheAllocatedHighSeasOfLeads','Change the person in charge of the {$Leads.Leads} after the sales lead has been released (blank means no change)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AfterReleasignTheAllocatedHighSeasOfLeads' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AfterTheSalesLeadIsAutomaticallyRecovered','{$Leads.Leads}自动回收后','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AfterTheSalesLeadIsAutomaticallyRecovered' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AfterTheSalesLeadIsAutomaticallyRecovered','After the {$Leads.Leads} is automatically recovered','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AfterTheSalesLeadIsAutomaticallyRecovered' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HowManyDaysBeforeLeadRecoveryToRemindOfLeads','{$Leads.Leads}回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HowManyDaysBeforeLeadRecoveryToRemindOfLeads' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HowManyDaysBeforeLeadRecoveryToRemindOfLeads','How many days before lead recovery to remind {$Leads.Leads} (0 means the day reminder, blank means no reminder)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HowManyDaysBeforeLeadRecoveryToRemindOfLeads' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HighSeasSalesLeadsParticipateInRecycling','公海{$Leads.Leads}参与回收，回收规则条件逻辑关系为','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HighSeasSalesLeadsParticipateInRecycling' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HighSeasSalesLeadsParticipateInRecycling','High seas {$Leads.Leads} participate in recycling, and the logical relationship of recycling rules is as follows','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HighSeasSalesLeadsParticipateInRecycling' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TransferoutOftheHighHeasOfLeads','转移出公海（转为普通{$Leads.Leads}）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TransferoutOftheHighHeasOfLeads' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TransferoutOftheHighHeasOfLeads','Transfer out of the high seas(Turn to regular {$Leads.Leads})','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TransferoutOftheHighHeasOfLeads' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TransferoutToHighSeasPoolOfLeads','转移公海{$Leads.Leads}到公海池','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TransferoutToHighSeasPoolOfLeads' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TransferoutToHighSeasPoolOfLeads','Transfer high seas {$Leads.Leads} to high seas pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TransferoutToHighSeasPoolOfLeads' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_field set issmownerid = 0;
delimiter;
update ld_field set issmownerid = 1 where columnname in ('smownerid','servicecasher');
delimiter;


update ld_relatedlists set related_tabid=0,type='CallButler_Info',wx_presence=1 where tabid=2 and name='get_CallButler';
delimiter;

CREATE TABLE if not exists  `ld_leads_public` (
  `status` varchar(20) NOT NULL DEFAULT 'no',
  `show_publicaccount_tab` varchar(20) DEFAULT 'yes',
  `default_publicaccount_tab` varchar(20) DEFAULT 'no',
  `administrators` text,
  `show_commonaccount_tab` varchar(20) DEFAULT NULL,
  `show_account_rule` varchar(20) DEFAULT NULL,
  `account_rule_pool_id` int(11) DEFAULT '0',
  `recycleselect` text,
  `is_commonaccount_create` varchar(50) DEFAULT 'yes'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists  `ld_leads_public_pool` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zh_name` varchar(200) DEFAULT NULL COMMENT '公海名称中文',
  `en_name` varchar(200) DEFAULT NULL COMMENT '公海名称英文',
  `limit_count` int(11) DEFAULT NULL COMMENT '公海已分配线索上线',
  `limit_type` varchar(20) DEFAULT NULL COMMENT '公海已分配上线 1按成员 2按角色',
  `administrators` text COMMENT '公海管理员',
  `userids` text COMMENT '公海成员',
  `usertype` varchar(100) DEFAULT NULL COMMENT '公海成员类型 all所有 group 部门 user 用户',
  `dataprofile` varchar(20) DEFAULT NULL COMMENT ' 公海未分配线索不允许领取（只能由公海管理员分配） ',
  `allowget` varchar(20) DEFAULT NULL COMMENT ' 公海未分配线索不控制数据权限（可查询所有公海未分配线索） ',
  `allow_unallocated_showinall` varchar(20) DEFAULT 'no' COMMENT ' 允许公海未分配线索显示在“全部（含指定公海）”列表 ',
  `allow_allocated_showinall` varchar(20) DEFAULT 'no' COMMENT ' 允许公海已分配线索显示在“全部（含指定公海）”列表 ',
  `allow_trasnfer_others` varchar(20) DEFAULT 'no' COMMENT ' 允许公海成员将已分配或领取的公海线索转移到其他公海 ',
  `userid_after_transfer` int(11) DEFAULT NULL COMMENT '线索转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）',
  `userid_after_release` int(11) DEFAULT NULL COMMENT ' 公海已分配线索释放后，更改线索负责人为（为空表示不更改）',
  `create_buttons` varchar(200) DEFAULT NULL COMMENT ' 公海成员线索序时簿“新建”功能下拉选项',
  `recycleselect` text COMMENT '回收条件sql',
  `beforereminddays` varchar(10) DEFAULT NULL COMMENT ' 线索回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒） ',
  `objtainaccountcontroldays` varchar(10) DEFAULT NULL COMMENT '线索被自动回收后天内不允许被当前销售负责人再次领取（为0或空表示不控制） ',
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `smcreatorid` int(11) DEFAULT NULL,
  `modifiedby` int(11) DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  `allow_users` varchar(200) DEFAULT NULL,
  `transfer_users` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_leads_public_pool__id` (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;


CREATE TABLE if not exists `ld_leads_role_limitcount` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pool_id` int(11) NOT NULL,
  `roleid` int(11) DEFAULT NULL,
  `limit_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_leads_role_limitcount_poolid` (`pool_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists  `ld_leads_set_advfilter` (
  `columnindex` int(11) DEFAULT NULL,
  `columnname` varchar(250) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  `column_condition` varchar(50) DEFAULT NULL,
  `value` varchar(250) DEFAULT NULL,
  `groupid` int(11) DEFAULT '0',
  `pool_id` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_leads_set_advfilter_grouping` (
  `groupid` int(11) NOT NULL,
  `group_condition` varchar(255) DEFAULT NULL,
  `condition_expression` text,
  `pool_id` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE if not exists  `ld_leads_set_rule` (
  `tabname` varchar(50) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `condition` varchar(20) DEFAULT NULL,
  `labelbol` varchar(200) DEFAULT NULL,
  `sequence` int(10) DEFAULT NULL,
  `days` int(10) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `columnname` varchar(50) DEFAULT NULL,
  `otherwhere` varchar(200) DEFAULT NULL,
  `iscycle` varchar(100) DEFAULT NULL,
  `singlelabelbol` varchar(100) DEFAULT NULL,
  `pool_id` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into ld_sys_event(eventdate,type)
select '1600-01-01 00:00:00','publicleads' from dual 
where not exists(select 1 from ld_sys_event where type='publicleads');
delimiter;
insert into ld_leads_public_pool(zh_name,en_name)
select  '默认公海','默认公海' from dual 
where not exists(select 1 from ld_leads_public_pool where zh_name='默认公海');
delimiter;


insert into ld_leads_set_rule(tabname,type,`condition` ,labelbol,sequence,days ,`status`,columnname,iscycle,singlelabelbol,pool_id)
select 'ContactRecords','normal','or' ,'ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE/Days',1,10,'active','createdtime','yes','ALLOCATEORCREATETIMESTART/NOTCREATECONTACTRECORDS',1 
from dual where not exists(select  1 from ld_leads_set_rule  where tabname='ContactRecords' and pool_id=1 and type='normal');
delimiter;
insert into ld_leads_set_rule(tabname,type,`condition` ,labelbol,sequence,days ,`status`,columnname,iscycle,singlelabelbol,pool_id)
select 'Singin','normal','or' ,'ALLOCATEORGETSTARTNOCREATESINGINCREATE/Days',1,10,'inactive','createdtime','yes','ALLOCATEORCREATETIMESTART/NOTCREATESINGIN',1 
from dual where not exists(select  1 from ld_leads_set_rule  where tabname='Singin' and pool_id=1 and type='normal');
delimiter;

insert into ld_leads_set_rule(tabname,type,`condition` ,labelbol,sequence,days ,`status`,columnname,iscycle,singlelabelbol,pool_id)
select 'ContactRecords','complete','and' ,'ALLOCATEORGETSTARTNOCREATECONTACTRECORDS/Days',1,10,'active','createdtime','yes','ALLOCATEORGETSTART/NOTCREATECONTACTRECORDS',1 
from dual where not exists(select  1 from ld_leads_set_rule  where tabname='ContactRecords' and pool_id=1 and type='complete');
delimiter;
insert into ld_leads_set_rule(tabname,type,`condition` ,labelbol,sequence,days ,`status`,columnname,iscycle,singlelabelbol,pool_id)
select 'Singin','complete','and' ,'ALLOCATEORGETSTARTNOCREATESINGIN/Days',1,10,'inactive','createdtime','yes','ALLOCATEORGETSTART/NOTCREATESINGIN',1 
from dual where not exists(select  1 from ld_leads_set_rule  where tabname='Singin' and pool_id=1 and type='complete');
delimiter;


call AddColumn('ld_leads','pool_id','int','11',0);
delimiter;
call AddColumn('ld_leads','allocatedate','date','','');
delimiter;
call AddColumn('ld_leads','protectdate','date','','');
delimiter;

call AddColumn('ld_leads','publicaccount','smallint','6','');
delimiter;
call AddColumn('ld_leads','completed','varchar','20','');
delimiter;
call AddColumn('ld_leads','lastdistributedate','date','','');
delimiter;

SET @modulename='Leads';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=(select sequence from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_leads';
SET @columnname='lastdistributedate';
SET @fieldname='lastdistributedate';
SET @zh='公海分配日期';
SET @en='AllocateDate';
SET @uitype=70;
SET @typeofdata='D~O';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @relateid and sequence >= @maxseq;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

SET @modulename='Leads';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=(select sequence from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_leads';
SET @columnname='protectdate';
SET @fieldname='protectdate';
SET @zh='保护结束日期';
SET @en='protectdate';
SET @uitype=70;
SET @typeofdata='D~O';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @relateid and sequence >= @maxseq;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;



SET @modulename='Leads';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=(select sequence from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_leads';
SET @columnname='publicaccount';
SET @fieldname='publicaccount';
SET @zh='公海状态';
SET @en='Unassigned Status';
SET @uitype=56;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @relateid and sequence >= @maxseq;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


SET @modulename='Leads';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=(select sequence from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_leads';
SET @columnname='allocatedate';
SET @fieldname='allocatedate';
SET @zh='领取日期';
SET @en='Collection date';
SET @uitype=70;
SET @typeofdata='D~O';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @relateid and sequence >= @maxseq;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

SET @modulename='Leads';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=(select sequence from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_leads';
SET @columnname='pool_id';
SET @fieldname='pool_id';
SET @zh='所属公海';
SET @en='High seas';
SET @uitype=302;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @relateid and sequence >= @maxseq;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid and block = @relateid order by sequence;
delimiter;
update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;
call getallprofile("Leads");
delimiter;
CREATE TABLE if not exists  `ld_logpublicleads` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) DEFAULT NULL,
  `operation` text,
  `opdate` datetime DEFAULT NULL,
  `leadsid` int(19) DEFAULT NULL,
  `userid` int(19) DEFAULT '0',
  `pool_id` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `logpublicleads_leadsid` (`leadsid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

update ld_customview set customcategory='ALLACCOUNT' where entitytype='leads' and customcategory is null;
delimiter;



select max(cvid) into @maxcvid from ld_customview ;
insert into ld_customview(cvid ,viewname,entitytype,status,userid,sequence,customcategory)
select @maxcvid+1,'全部','Leads',3,1,1,'PUBLICALLOCATE' from dual
where not exists(select 1 from ld_customview where entitytype='leads' and customcategory='PUBLICALLOCATE');
delimiter;

select cvid into @cvid from ld_customview where entitytype='Leads' and viewname='全部' and customcategory='PUBLICALLOCATE';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_leads:leads_no:leads_no:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:leads_no:leads_no:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_leads:accountname:accountname:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:accountname:accountname:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_leads:contactname:contactname:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:contactname:contactname:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_leads:leadsource:leadsource:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:leadsource:leadsource:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_leads:status:status:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:status:status:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_leads:bill_state:bill_state:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:bill_state:bill_state:Leads%');
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_leads:bill_city:bill_city:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:bill_city:bill_city:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:smownerid:assigned_user_id:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'ld_leads:modifiedtime:modifiedtime:Leads_fieldlabel:D' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:modifiedtime:modifiedtime:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'ld_leads:failurereason:failurereason:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:failurereason:failurereason:Leads%');

delimiter;


select max(cvid) into @maxcvid from ld_customview ;
insert into ld_customview(cvid ,viewname,entitytype,status,userid,sequence,customcategory)
select @maxcvid+1,'全部','Leads',3,1,1,'NOALLOCATE' from dual
where not exists(select 1 from ld_customview where entitytype='leads' and customcategory='NOALLOCATE');
delimiter;

select cvid into @cvid from ld_customview where entitytype='Leads' and viewname='全部' and customcategory='NOALLOCATE';


insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_leads:leads_no:leads_no:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:leads_no:leads_no:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_leads:accountname:accountname:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:accountname:accountname:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_leads:contactname:contactname:Leads_fieldlabel:V' from dual where not exists
 (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:contactname:contactname:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_leads:leadsource:leadsource:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:leadsource:leadsource:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_leads:status:status:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:status:status:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_leads:bill_state:bill_state:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:bill_state:bill_state:Leads%');
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_leads:bill_city:bill_city:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:bill_city:bill_city:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:smownerid:assigned_user_id:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'ld_leads:modifiedtime:modifiedtime:Leads_fieldlabel:D' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:modifiedtime:modifiedtime:Leads%');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'ld_leads:failurereason:failurereason:Leads_fieldlabel:V' from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid
and columnname  like '%ld_leads:failurereason:failurereason:Leads%');

delimiter;

update ld_customview_seq set id=(select max(cvid) from ld_customview);
delimiter;
update ld_customview set pool_id=1 where (pool_id is null or pool_id=0) and entitytype='leads';
delimiter;
CREATE TABLE if not exists `ld_publicleads_remindtableview` (
  `type` varchar(100) DEFAULT NULL,
  `names` text,
  `totalleads` int(19) DEFAULT NULL,
  `smownerid` int(19) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule_beforeremind;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and  (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_leads_set_rule.days) into @maxdays
  from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
  select beforereminddays into @var_beforereminddays from ld_leads_set;



 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
  select userid_after_release into @allotaccount from ld_leads_public_pool where id = tmp_pool_id;
	select recycleselect into @recycleselect from ld_leads_public_pool where id = tmp_pool_id;
	set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;
			
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',var_tablename,'.leadsid and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.leadsid=ld_leads.leadsid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_leads.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_leads.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_leads.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_leads_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_leads_set_rule.`status`='active' ORDER BY ld_leads_set_rule.sequence asc ) ";

			 set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_leads.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
		else
			if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid ') ;
				ELSE
					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid') ;
				end if;
				
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_leads.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		   
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id,'  group by ld_leads.smownerid    ');
		end if;
		delete from ld_publicleads_remindtableview ;
        set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

        call crm_publicleads_beforereminds();
	end if;
end ||
delimiter;
drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and (ld_field.presence in(0,2) ) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_leads_set_rule.days) into @maxdays
  from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2) 
	where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
	
	select userid_after_release into @allotaccount from ld_leads_public_pool where id = tmp_pool_id;
	select recycleselect into @recycleselect from ld_leads_public_pool where id = tmp_pool_id;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat('select ld_leads.leadsid,ld_leads.allocatedate from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.leadsid
								and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.leadsid=ld_leads.leadsid  ');
			
				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );
	
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_leads.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_leads.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
	  if var_condition='or'  then
			 
			set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id =  ',tmp_pool_id);
		  
			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
		
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
			end if;
		else
				if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.leadsid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid  group by tmpone.leadsid ') ;
				ELSE
					set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
				end if;
	
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);

		end if;
  
	   set @TMPSQL_THREE=concat('insert into ld_logpublicleads(username,operation,opdate,leadsid,pool_id) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
    if var_condition='or'  then
			
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
			end if;	
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_leads.accountname separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3)   group by ld_leads.smownerid    ');
		end if;
     delete from ld_publicleads_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicleads_recoveryreminds();

			if var_condition='or'  then
			  
			 set @TMPSQL_ONE=concat( ' update  ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ');
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
			end if;
			set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_leads.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
				end if;	
			ELSE
		
			  set @TMPSQL_ONE=concat( ' update  ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid set ld_leads.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		 end if;

		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

		

end ||
delimiter;
drop PROCEDURE if EXISTS leads_singlerecycle_normal_rule_beforeremind;
 delimiter ||
create PROCEDURE leads_singlerecycle_normal_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,
	ld_leads_set_rule.iscycle,`condition`,ld_leads_set_rule.days
 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and pool_id = 1;
	
    declare continue handler  for not   found  SET done =1;
    
    IF EXISTS (SELECT 1 FROM ld_leads_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_leads_set_rule.days) into @maxdays
      from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
    	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    	and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and pool_id = 1;
    
    	select recycleselect,account_rule_pool_id into @recycleselect,@leads_rule_pool_id from ld_leads_public;
    
    	select beforereminddays into @var_beforereminddays from ld_leads_public_pool where id = @leads_rule_pool_id;
      if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
    	end if;
       set @maxdays=@maxdays-@var_beforereminddays;
    
    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
    	end if;
    	OPEN cur1;
    
    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
    		   end if;
    		  if(var_condition='and' ) then
    
    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ');
    
    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
    				end if;
    
    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
    			else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))>",var_days);
    
    			 end if;
    
               set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime , '",var_tabname,"' as remindtabname from ld_leads LEFT JOIN (select ld_leads.leadsid from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',
                    var_tablename,'.leadsid and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');
    
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
    				end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leadsid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);
    
    
    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );
    
    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads inner join "  ,var_tablename,' on ',var_tablename,'.leadsid=ld_leads.leadsid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
    				end if;
    
    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
    				else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))<=",var_days);
    			   end if;
    
    				set @tmpsql=concat(@tmpsql,' union all ' );
    
    			end if;
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;
    
    
    	if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
    
    			if var_condition='or'  then
    				 set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_leads_set_rule
    									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
    									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
    										where type='complete' and ld_leads_set_rule.status='active' and ld_leads_set_rule.status='active' ORDER BY ld_leads_set_rule.sequence asc ) ";
    
    				set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
    
    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_leads.leadsname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
    				end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null  and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
    					end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
    
    		  else
    				if @recycleselect is not null and @recycleselect<>'' then
    
    					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid ') ;
    				ELSE
    					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid') ;
    				end if;
    
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_leads.leadsname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as leadsnames,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1) group by ld_leads.smownerid'  );
    			end if;
    
    	 	delete from ld_publicleads_remindtableview ;
    		 set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
    			prepare stmt from @tmpthree;
    			execute stmt;
    			deallocate prepare stmt;
    
    			call crm_publicleads_beforereminds();
    	 end if;
    END IF;

end ||

delimiter;
drop PROCEDURE if exists leads_singlerecycle_normal_rule;
delimiter ||
create PROCEDURE leads_singlerecycle_normal_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
   DECLARE var_smownercolumn varchar(50);
	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,
	ld_leads_set_rule.iscycle,`condition`,ld_leads_set_rule.days
 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and pool_id = 1;
	
    declare continue handler  for not   found  SET done =1;
    
    IF EXISTS (SELECT 1 FROM ld_leads_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_leads_set_rule.days) into @maxdays
      from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
    	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    	and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and pool_id = 1;
    
    	select recycleselect,account_rule_pool_id into @recycleselect,@leads_rule_pool_id from ld_leads_public;
    
    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
    	end if;
    	OPEN cur1;
    
    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    		  if(var_condition='and' ) then
    
    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.leads_id=ld_leads.leadsid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ');
    
    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
    				end if;
    
    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
    			else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))>",var_days);
    
    			 end if;
          set @tmpsqltwo=concat('select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from  ld_leads LEFT JOIN(select ld_leads.leadsid
    					from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.leads_id
    						and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );
    
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
    				end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);
    
    
    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );
    
    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.leadsid=ld_leads.leadsid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
    				end if;
    
    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
    				else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))<=",var_days);
    			   end if;
    
    				set @tmpsql=concat(@tmpsql,' union all ' );
    
    			end if;
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;
    
    
    	if @tmpint>0 then
    		set @len=CHAR_LENGTH(' union all ');
    		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
    
    	  if var_condition='or'  then
    
    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    			if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
    		 	end if;
    			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)'  );
    				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null  and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
    				end if;
    		else
    			 if @recycleselect is not null and @recycleselect<>'' then
    
    					set @sql=concat(' select tmpone.leadsid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid  group by tmpone.leadsid ') ;
    				ELSE
    					set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
    				end if;
    
    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)'  );
    		 end if;
    
    	   set @TMPSQL_THREE=concat('insert into ld_logpublicleads(username,operation,opdate,leadsid,pool_id) ',@TMPSQL_TWO);
    		 prepare stmt from @TMPSQL_THREE;
    		 execute stmt;
    		 deallocate prepare stmt;
    
    
    
    		if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(leadsname separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    		   if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
    		 	end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)    ');
    		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    			if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
    				end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
    		else
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_leads.leadsname separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1) group by ld_leads.smownerid    ');
    		end if;
    
         delete from ld_publicleads_remindtableview ;
    
         set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
    		prepare stmt from @tmpthree;
    		execute stmt;
    		deallocate prepare stmt;
    
       call crm_publicleads_recoveryreminds();
    
    
    		if var_condition='or'  then
    			  	set @TMPSQL_ONE=concat( ' update  ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ');
    
    		      if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
    					end if;
    				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_leads.publicaccount=1,ld_leads.pool_id=',@leads_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
    
    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
    				  end if;
    			ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid set ld_leads.publicleads=1,ld_leads.pool_id=',@leads_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
    		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    
    		 end if;
    		prepare stmt from @TMPSQL_TWO;
    		execute stmt;
    		deallocate prepare stmt;
    
    	end if;
    END IF;

end ||
delimiter;
 
drop PROCEDURE if exists execute_leads_publicoperation;
delimiter ||
create PROCEDURE execute_leads_publicoperation()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_leads_public_pool where deleted = 0;
	declare continue handler  for not   found  SET done =1;
	if  EXISTS (SELECT 1 FROM ld_leads_public WHERE STATUS = 'yes')  THEN
		if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicleads')  THEN
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicleads';
			call leads_singlerecycle_normal_rule();
			call leads_singlerecycle_normal_rule_beforeremind();
			OPEN cur1;
				Fetch cur1 into tmp_pool_id;
					loop1: while  done<>1 DO
						call leads_singlerecycle_highsea_rule(tmp_pool_id);
						call leads_singlerecycle_highsea_rule_beforeremind(tmp_pool_id);
				Fetch cur1 into tmp_pool_id;
			end while loop1;
			close cur1;
		end if;
	end if;
end ||
delimiter;

DROP EVENT IF EXISTS `lingdang_public_leads_event`;
CREATE EVENT `lingdang_public_leads_event` ON SCHEDULE EVERY 5 MINUTE STARTS CONCAT('2019-06-21 ',floor(rand()*24),':',floor(rand()*60),':',floor(rand()*60)) ON COMPLETION NOT PRESERVE ENABLE DO 
call execute_leads_publicoperation();
delimiter;
call execute_leads_publicoperation;
delimiter;
-- 2021-05-28

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

UPDATE ld_version SET old_version='V8.4.2.7',current_version='V8.4.2.7',remark='V8.4.2.7-20210528',wx_version='V8.4.2.6.4';
delimiter;