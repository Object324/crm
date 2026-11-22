DROP PROCEDURE IF EXISTS `Del_ForeignKey`;
delimiter ||
CREATE  PROCEDURE `Del_ForeignKey`(
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

END ||
delimiter;

UPDATE ld_field SET allowhide='yes' WHERE columnname='bankaccountsetid' 
	AND tablename IN ('ld_expense','ld_cashbill','ld_sendcashbill','ld_cashback','ld_commission','ld_purchasecashback');

UPDATE ld_field SET presence=1 WHERE columnname='bankaccountsetid' 
	AND tablename IN ('ld_expense','ld_cashbill','ld_sendcashbill','ld_cashback','ld_commission','ld_purchasecashback')
	AND EXISTS (SELECT 1 FROM ld_tab WHERE `name`='BankAccountSet' AND presence IN (1,5));

DELETE FROM ld_tranlabel WHERE trantable='ld_field' 
	AND Relateid IN (SELECT fieldid FROM ld_field WHERE columnname='terms_conditions')
	AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);

DELETE FROM ld_field WHERE columnname='terms_conditions' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);

DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' 
	AND Relateid IN (SELECT blockid FROM ld_blocks WHERE blocklabel='LBL_TERMS_INFORMATION')
	AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);

DELETE FROM ld_blocks WHERE blocklabel='LBL_TERMS_INFORMATION' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);


update ld_cvcolumnlist_wx set columnname=replace(columnname,'ServiceCharge','Accounts') where modulename='ServiceCharge';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CardApply';
update ld_field set typeofdata = 'E~O' where tabid = @tabid and columnname in ('zh_email','en_email');
delimiter;

update ld_desk set fieldlabel = '显示顺序请填写正整数！' where languagetype = 'zh' and labelbol = 'ORDERISPOSITIVEINTEGERS' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'Please fill in the positive integer in the display order!' where languagetype = 'en' and labelbol = 'ORDERISPOSITIVEINTEGERS' and Labeltype = 'jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','profileauthority','角色权限','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'profileauthority' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','profileauthority','Role authority','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'profileauthority' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','groupsetup','部门设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'groupsetup' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','groupsetup','Group setup','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'groupsetup' and labeltype = 'fixedstr');
delimiter;
-- 2017-12-05

SET @i=0;
SET @tabid=21;
SET @seq1=(SELECT sequence FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='entitytypeid');
UPDATE ld_producttoolfield SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>=@seq1;
UPDATE ld_producttoolfield SET sequence=@seq1 WHERE tabid=@tabid AND columnname='entitytype';
UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

UPDATE ld_field SET presence=1 WHERE columnname='subject' AND tablename IN ('ld_quotes','ld_purchaseorder','ld_servicecontracts','ld_checks');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWSUBGROUP','新增子部门','fixedstr' from dual  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NEWSUBGROUP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWSUBGROUP','New sub department','fixedstr' from dual  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NEWSUBGROUP' and labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Contacts';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'lastname' and fieldname = 'lastname';
update ld_tranlabel set fieldlabel = '联系人姓名' where tabid = @tabid and languagetype = 'zh' and trantable = 'ld_field' and Relateid = @fieldid;
update ld_tranlabel set fieldlabel = 'Contacts Name' where tabid = @tabid and languagetype = 'en' and trantable = 'ld_field' and Relateid = @fieldid;
delimiter;

select versiontype into @versiontype from ld_version;
select tabid into @tabid from ld_tab where name='Products';
select blockid into @blockid from ld_appparenttab where parenttab_label='Sales';
update ld_appparenttabrel set sequence=sequence+1 where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid)
and @versiontype in(55,56,57,58);
set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;
-- 2017-12-05

DROP PROCEDURE IF EXISTS `ldcrm_reset_picklist`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_picklist`(
)
BEGIN

	DELETE FROM ld_leadsource WHERE leadsource='推广平台';

	IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2) THEN
		DELETE FROM ld_rating WHERE rating='高意向潜在客户';
		DELETE FROM ld_industry WHERE industry='娱乐';
		UPDATE ld_industry SET industry='环境检测' WHERE industry IN ('环境','环境监测');

		DELETE FROM ld_contactrecordtype WHERE contactrecordtype IN ('发资料','发报价','发订单');
		DELETE FROM ld_ticketcategories WHERE ticketcategories='故障排除';
		DELETE FROM ld_paymentmethod WHERE paymentmethod='邮政汇款';
		DELETE FROM ld_crpaymentmethod WHERE crpaymentmethod='邮政汇款';

		DELETE FROM ld_campaigntype WHERE campaigntype IN ('公共关系','合作伙伴','介绍活动','广告');
		UPDATE ld_campaigntype SET campaigntype='线上推广' WHERE campaigntype='网络广告';
		UPDATE ld_campaigntype SET campaigntype='网络直播' WHERE campaigntype='网上交流会';
		UPDATE ld_campaigntype SET campaigntype='线下活动' WHERE campaigntype='贸易展览';
		UPDATE ld_campaignstatus SET campaignstatus='开始' WHERE campaignstatus='停止';

		UPDATE ld_commissiontype SET commissiontype='商机费' WHERE commissiontype='佣金';
		INSERT INTO ld_commissiontype(commissiontype,presence,picklist_valueid)
		SELECT '销售提成',1,20000 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_commissiontype WHERE commissiontype='销售提成');
		
		SET @i=0;
		UPDATE ld_commissiontype SET picklist_valueid=(@i:=@i+1) ORDER BY picklist_valueid;
		

	END IF;

END ||
delimiter;

CALL ldcrm_reset_picklist();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_picklist`;
delimiter;


select tabid into @tabid from ld_tab where `name`= 'Contacts';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'lastname' and fieldname = 'lastname';
update ld_tranlabel set fieldlabel = '联系人姓名' where tabid = @tabid and languagetype = 'zh' and trantable = 'ld_field' and Relateid = @fieldid;
update ld_tranlabel set fieldlabel = 'Contacts Name' where tabid = @tabid and languagetype = 'en' and trantable = 'ld_field' and Relateid = @fieldid;
delimiter;

select versiontype into @versiontype from ld_version;
select tabid into @tabid from ld_tab where name='Products';
select blockid into @blockid from ld_appparenttab where parenttab_label='Sales';
update ld_appparenttabrel set sequence=sequence+1 where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid)
and @versiontype in(55,56,57,58);
set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
update ld_field set fieldonly = 1 where tabid = @tabid and columnname = 'email1';
update ld_field set fieldonly = 1 where tabid = @tabid and columnname = 'phone_mobile';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Stock');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
delete from ld_fieldwxmaininfo where tabid=@tabid and fieldname='nothave_invoicetotal';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder');
delete from ld_fieldwxmaininfo where tabid=@tabid and fieldname='nothave_invoicetotal';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
delete from ld_fieldwxmaininfo where fieldname='commissiontype' and tabid=@tabid;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder');
delete from ld_fieldwxmaininfo where fieldname='nothave_invoicetotal' and tabid=@tabid;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk');
update ld_fieldwxmaininfo set fieldname='hopetime' where fieldname='realtime' and tabid=@tabid;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan');
delete from ld_fieldwxmaininfo where fieldname='paymentstatus' and tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',1,'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');
delimiter;

DROP PROCEDURE IF EXISTS `update_ld_fieldwxmaininfo_link2normal`;
delimiter ||
CREATE  PROCEDURE `update_ld_fieldwxmaininfo_link2normal`(
)
begin

	declare tmp_tabid int(4) default 0;
	declare tmp_fieldname varchar(100) default '';
	declare cur1 cursor for SELECT DISTINCT tabid,fieldname from ld_fieldwxmaininfo where displaytype='link';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_tabid,tmp_fieldname;
	while(tmp_tabid is not null) DO
		update ld_fieldwxmaininfo set sequence=sequence+1 where tabid=tmp_tabid;
		update ld_fieldwxmaininfo set sequence=1,displaytype='normal' where fieldname=tmp_fieldname and tabid=tmp_tabid;
		set @i=0;
		update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=tmp_tabid order by sequence;
		Fetch cur1 into tmp_tabid,tmp_fieldname;
	end while;

	close cur1;

end ||
delimiter;
call update_ld_fieldwxmaininfo_link2normal();
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
update ld_fieldwxmaininfo set sequence=2 where fieldname='assigned_user_id' and tabid=@tabid;
update ld_fieldwxmaininfo set sequence=3 where fieldname='cashbilldate' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
update ld_fieldwxmaininfo set sequence=sequence+1 where tabid=@tabid;
update ld_fieldwxmaininfo set sequence=1 where fieldname='account_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='PaymentPlan';
update ld_fieldwxmaininfo set sequence=sequence+1 where tabid=@tabid;
update ld_fieldwxmaininfo set sequence=1 where fieldname='account_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dismissalapprovalrejecton','已驳回、已批准、已拒绝等状态不可以批量审批！','fixedstr' from dual  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dismissalapprovalrejecton' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dismissalapprovalrejecton','Dismissal, approval and rejection The same state can not be approved in batch!','fixedstr' from dual  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dismissalapprovalrejecton' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thenextstepofapproveisempty','下一步审批步骤为空！','fixedstr' from dual  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='thenextstepofapproveisempty' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thenextstepofapproveisempty','The next step of approval is empty!','fixedstr' from dual  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='thenextstepofapproveisempty' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thecurrentuserisnotinthenextapprover','当前用户不在下一步审批人中！','fixedstr' from dual  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='thecurrentuserisnotinthenextapprover' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thecurrentuserisnotinthenextapprover','The current user is not in the next approver!','fixedstr' from dual  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='thecurrentuserisnotinthenextapprover' and labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
update ld_field set searchfieldtype = 1 where tabid = @tabid;
update ld_field set searchfieldtype = 0 where tabid = @tabid and columnname in ('productname','product_no');
delimiter;

SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='Sales' AND systemdefault='yes' LIMIT 1;
INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
SELECT @blockid,14,100 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=14);

SET @i=0;
UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;

CREATE TABLE IF NOT EXISTS `ld_attachmentsforbillscf` (
  `attachmentsid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`attachmentsid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
update ld_field set typeofdata = 'D~M~OTH~GE~startdate~startdate' where tabid = @tabid and columnname = 'enddate';
delimiter;
-- 2017-12-06

CALL Del_ForeignKey('ld_parenttabrel','ld_parenttabrel_ibfk_1');

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='OAForms');
SET @seq=(SELECT max(sequence) FROM ld_parenttabrel WHERE parenttabid=@parenttabid);
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @parenttabid,-1,@seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=-1);
delimiter;

SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Accounts');
SET @seq=(SELECT max(sequence) FROM ld_appparenttabrel WHERE blockid=@blockid);
INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
SELECT @blockid,-2,@seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=-2);
delimiter;

UPDATE ld_producttoolfield SET presence=1 WHERE columnname IN ('product_no','usageunit') AND NOT EXISTS (SELECT 1 FROM ld_inventoryproductrel);

SET @i=0;
SET @tabid1=(SELECT tabid FROM ld_tab WHERE name='Expense');
SET @tabid2=(SELECT tabid FROM ld_tab WHERE name='Commission');
SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE systemdefault='yes' AND parenttab_label='OAForms');
SET @seq=(SELECT sequence FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=@tabid2);
UPDATE ld_appparenttabrel SET sequence=sequence+1 WHERE blockid=@blockid AND sequence>@seq;
UPDATE ld_appparenttabrel SET sequence=@seq+1 WHERE blockid=@blockid AND tabid=@tabid1 AND NOT EXISTS (SELECT 1 FROM ld_expense);
UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

SET @tabid=6;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='lastname' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人姓名' WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='姓名';
delimiter;

SET @tabid=4;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='lastname' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人姓名' WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='姓名';
delimiter;

UPDATE ld_field SET quickcreate=0 WHERE typeofdata like '%~M%' AND quickcreate=1 AND uitype<>4
	AND tabid IN (SELECT tabid FROM ld_tab WHERE name IN ('Potentials','Contacts','Accounts','VendorContactRecords'));

UPDATE ld_desk SET fieldlabel='展开更多栏目' WHERE labelbol='DISPLAYMOREITEM' AND languagetype='zh' AND Labeltype='fixedstr';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply');
UPDATE ld_tabdetailfield SET width=50 WHERE tabid=@tabid AND columnname='description';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realcolumns = 'ld_singin:uuid:uuid:OftenUseReport_手机设备号:V' where Usereportid = @usereportid and `columns` = 'ld_singin:uuid:uuid:OftenUseReport_手机id:V';
delimiter;

delete from ld_campaignstatus where campaignstatus = '活动';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseselect','请选择','jspop' from dual  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='pleaseselect' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseselect','Please select ','jspop' from dual  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='pleaseselect' and labeltype='jspop');
delimiter;

update ld_relatedlists set related_tabid = '-15' where tabid = 6 and `name` = 'get_Kingdeeorders' and label = 'Kingdeeorders';
update ld_relatedlists set related_tabid = '-1' where tabid = 6 and `name` = 'get_WorkReport' and label = 'Home';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'servicecontracts_start_date';
update ld_tranlabel set fieldlabel = '服务开始日' where tabid = @tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @fieldid from ld_field where tabid = 6 and columnname = 'lastname' and tablename = 'ld_contactdetails';
update ld_tranlabel set fieldlabel = '联系人姓名' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
update ld_field set typeofdata = 'V~M' where tabid = @tabid and columnname = 'groupid' and uitype = 180;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workreport_showset` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(20) DEFAULT NULL,
  `presence` varchar(20) DEFAULT NULL,
  `sequence` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Set_Cooperative_WorkSet','Set Cooperative Work','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Set_Cooperative_WorkSet' and languagetype='en' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Set_Cooperative_WorkSet','工作汇报设置','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Set_Cooperative_WorkSet' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_workreport_showset(type,presence,sequence)
select 'weibo','yes',1 from dual where not exists(select 1 from ld_workreport_showset where type='weibo');
delimiter;
insert into ld_workreport_showset(type,presence,sequence)
select 'dayreport','yes',2 from dual where not exists(select 1 from ld_workreport_showset where type='dayreport');
delimiter;
insert into ld_workreport_showset(type,presence,sequence)
select 'weekreport','yes',3 from dual where not exists(select 1 from ld_workreport_showset where type='weekreport');
delimiter;
insert into ld_workreport_showset(type,presence,sequence)
select 'monthreport','yes',4 from dual where not exists(select 1 from ld_workreport_showset where type='monthreport');
delimiter;

insert into ld_workreport_showset(type,presence,sequence)
select 'cocmd','yes',5 from dual where not exists(select 1 from ld_workreport_showset where type='cocmd');
delimiter;

update ld_workreport_showset set presence='no' where  (type='weibo' or type='cocmd') 
and exists(select 1 from ld_version  where versiontype='55' or versiontype='56' or versiontype='57' or versiontype='58');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENABLEATONE','停用失败，请至少启用一个类别','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='ENABLEATONE' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENABLEATONE','Disable failure, please enable at least one category','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='ENABLEATONE' and languagetype='en' and labeltype='fixedstr');
delimiter;

update ld_tab set mobilepresence='weixin' where tabid=-1;
delimiter;

update ld_field set quickcreate = 0 where tabid = 6 and tablename = 'ld_contactdetails' and columnname in ('lastname','title','mobile');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULENAME','模块名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MODULENAME' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULENAME','Module Name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MODULENAME' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thenewpwdisnotbesameastheoldone','新密码不能和旧密码一样！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thenewpwdisnotbesameastheoldone' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thenewpwdisnotbesameastheoldone','The new password is not the same as the old password!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thenewpwdisnotbesameastheoldone' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','isubmitted','我提交的','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'isubmitted' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','isubmitted','I submitted','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'isubmitted' and labeltype = 'fixedstr');
delimiter;
-- 2017-12-07

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
delimiter;

update ld_version set old_version='V7.1.2',current_version='V7.1.2',remark='V7.1.2-20171207',wx_version='V7';
delimiter;