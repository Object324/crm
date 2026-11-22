SET @tabid=6;
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'lastname',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'mobile',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'bill_street',3,'normal';

SET @tabid=13;
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'ticketstatus',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hopetime',3,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',4,'normal';


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact');
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'lastname',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'mobile',3,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'email',4,'normal';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords');
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'contactdate',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',3,'normal';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
DELETE FROM ld_fieldwxmaininfo WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',1,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'contactdate',2,'normal';

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'nextcontactdate',3,'normal';

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='QuotesChange';
CALL rest_cvcolumnlist_wx('QuotesChange','quoteschange_no','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('QuotesChange','accountid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('QuotesChange','change_type','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('QuotesChange','smownerid','3','2','yes','yes');

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='VendorContact';
CALL rest_cvcolumnlist_wx('VendorContact','lastname','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('VendorContact','vendorid','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('VendorContact','mobile','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('VendorContact','title','3','2','yes','yes');

DROP PROCEDURE IF EXISTS `ldcrm_reset_potentials_fields`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_potentials_fields`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_potential) THEN
		SET @tabid=2;
		SET @blockid=(SELECT max(blockid) FROM ld_blocks);
		SET @blocklabel='LBI_SALES_FORECAST';
		SET @en='Sales Forecast';
		SET @zh='销售预测';
		SET @seq=(SELECT sequence FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_OPPORTUNITY_INFORMATION');

		UPDATE ld_blocks SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@seq;

		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @blockid+1,@tabid,@blocklabel,@seq+1,0,0,0,0,0,1,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

		UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

		SET @i=0;
		UPDATE ld_blocks SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel=@blocklabel);
		DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid=@blockid;
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,@en;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,@zh;

		SET @i=0;
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='sales_stage';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='lastsales_stage';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='closingdate';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='amount';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='possibility';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='cf_1308';

	END IF;

end ||
delimiter;

CALL ldcrm_reset_potentials_fields();
DROP PROCEDURE IF EXISTS `ldcrm_reset_potentials_fields`;
delimiter;

call AddColumn('ld_bangwo8','is_customer','int','11','0');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','iscustomer','是否同步客户到帮我吧','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'iscustomer' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','iscustomer','Do you synchronize customers to bangwo ba！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'iscustomer' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='账号已存在' where labelbol='auserwiththesepecifiednamealreadyexists' and languagetype='zh' and labeltype='fixedstr';
delimiter;
-- 2017-12-18

DROP PROCEDURE IF EXISTS `ldcrm_reset_contacts_fields`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_contacts_fields`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_contactdetails) THEN
		SET @tabid=4;
		DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (
			SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel IN ('LBL_CUSTOM_INFORMATION','LBL_CUSTOMER_PORTAL_INFORMATION')
			);
		
		DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel IN ('LBL_CUSTOM_INFORMATION','LBL_CUSTOMER_PORTAL_INFORMATION');

		DELETE FROM ld_field WHERE tabid=@tabid AND columnname IN ('homephone','otherphone','assistant','assistantphone',
				'secondaryemail','emailoptout','portal','support_start_date','support_end_date','othercountry','mailingpobox','otherpobox',
				'otherstate','donotcall','notify_owner','othercity','otherstreet','otherzip');
		CALL DelColumn('ld_customerdetails','otherzip');
		CALL DelColumn('ld_customerdetails','otherstreet');
		CALL DelColumn('ld_customerdetails','othercity');
		CALL DelColumn('ld_customerdetails','otherstate');
		CALL DelColumn('ld_customerdetails','otherpobox');
		CALL DelColumn('ld_customerdetails','othercountry');
		CALL DelColumn('ld_customerdetails','mailingpobox');
	
		CALL DelColumn('ld_customerdetails','portal');
		CALL DelColumn('ld_customerdetails','support_start_date');
		CALL DelColumn('ld_customerdetails','support_end_date');
	
		CALL DelColumn('ld_customerdetails','assistant');
		CALL DelColumn('ld_customerdetails','assistantphone');
		CALL DelColumn('ld_customerdetails','secondaryemail');

		SET @blockid=(SELECT max(blockid) FROM ld_blocks);
		SET @blocklabel='LBI_CONTACT_INFO';
		SET @en='Contact Information';
		SET @zh='联系方式';
		SET @seq=(SELECT sequence FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_CONTACT_INFORMATION');

		UPDATE ld_blocks SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@seq;

		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @blockid+1,@tabid,@blocklabel,@seq+1,0,0,0,0,0,1,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

		UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

		SET @i=0;
		UPDATE ld_blocks SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid and blocklabel=@blocklabel);
		DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid=@blockid;
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,@en;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,@zh;

		SET @i=0;
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='mobile';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='pphone';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='email';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='qq';
		UPDATE ld_field SET sequence=(@i:=@i+1),block=@blockid WHERE tabid=@tabid AND columnname='fax';
		
		SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_CONTACT_INFORMATION');
		UPDATE ld_field SET presence=1,sequence=1000 WHERE tabid=@tabid AND columnname IN ('leadsource','modifiedby');
		UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tabid=@tabid AND columnname='title';

		UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@blockid;
		SET @i=0;
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='accountid';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='contact_no';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='lastname';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='salutation';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='department';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='title';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='birthday';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='reference';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='smownerid';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='smcreatorid';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='createdtime';
		
		SET @i=0;
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@blockid ORDER BY sequence;

		UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname IN ('mailingcountry','mailingstate','mailingcity','mailingzip','mailingstreet');
	END IF;

end ||
delimiter;

CALL ldcrm_reset_contacts_fields();
DROP PROCEDURE IF EXISTS `ldcrm_reset_contacts_fields`;
delimiter;
-- 2017-12-19

SET @cnt=(SELECT count(1) FROM ld_field WHERE tabid=4 AND columnname='mobile' AND presence<>1 AND typeofdata LIKE '%~M%');
UPDATE ld_field SET typeofdata='V~M' WHERE tabid=4 AND columnname='lastname' AND presence<>1 AND @cnt=1;
delimiter;

SET @tabid=6;
SET @cnt=(SELECT count(1) FROM ld_field WHERE tabid=@tabid AND columnname='mobile' AND tablename='ld_contactdetails' AND presence<>1 AND typeofdata='V~M');
UPDATE ld_field SET typeofdata='V~M' WHERE tabid=@tabid AND columnname='lastname' AND tablename='ld_contactdetails' AND presence<>1 AND @cnt=1;
delimiter;

SET @tabid=102;
SET @cnt=(SELECT count(1) FROM ld_field WHERE tabid=@tabid AND columnname='mobile' AND tablename='ld_contactdetails' AND presence<>1 AND typeofdata='V~M');
UPDATE ld_field SET typeofdata='V~M' WHERE tabid=@tabid AND columnname='lastname' AND tablename='ld_contactdetails' AND presence<>1 AND @cnt=1;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_commission_fields`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_commission_fields`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_commission) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
		UPDATE ld_tabdetailfield SET defaultcolumn=8 WHERE tabid=@tabid AND columnname IN ('cashbilldate','received_amount','due_date','source_total');
		UPDATE ld_tabdetailfield SET defaultcolumn=1 WHERE tabid=@tabid AND columnname IN ('noamount');
		UPDATE ld_tabdetailfield SET presence=1 WHERE tabid=@tabid AND columnname IN ('cashbilldate','received_amount','due_date','noamount');
		
		UPDATE ld_tabdetailfield SET sequence=sequence+10 WHERE tabid=@tabid;
		SET @i=0;
		UPDATE ld_tabdetailfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='entitytypeid';
		UPDATE ld_tabdetailfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='source_total';
		UPDATE ld_tabdetailfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='source_total';
		UPDATE ld_tabdetailfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='rate';
		UPDATE ld_tabdetailfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='amount';

		SET @i=0;
		SET @j=0;
		UPDATE ld_tabdetailfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;
		UPDATE ld_tabdetailfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
	END IF;

end ||
delimiter;

CALL ldcrm_reset_commission_fields();
DROP PROCEDURE IF EXISTS `ldcrm_reset_commission_fields`;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname='potentialid' AND NOT EXISTS (SELECT 1 FROM ld_commission);
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname='potentialid' AND NOT EXISTS (SELECT 1 FROM ld_potential);
delimiter;

UPDATE ld_field SET quickcreate=0 WHERE typeofdata like '%~M%' AND uitype NOT IN (4,53);
UPDATE ld_desk SET fieldlabel='确定要删除选定的下拉框选项吗？' WHERE labelbol='ALLROLESREMOVESELECTOPTION' AND languagetype='zh';

SET @tabid=6;
SET @cnt=(SELECT COUNT(1) FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=843 AND languagetype='zh' AND fieldlabel LIKE '%联系人%');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='salutation' AND tablename='ld_contactdetails'); 
UPDATE ld_tranlabel SET fieldlabel='联系人称谓' WHERE fieldlabel='称谓' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='firstname' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人英文名' WHERE fieldlabel='英文名' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='title' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人职务' WHERE fieldlabel='职务' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pphone' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人电话' WHERE fieldlabel='电话' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mobile' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人手机' WHERE fieldlabel='手机' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='faxx' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人传真' WHERE fieldlabel='传真' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='email' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人 Email' WHERE fieldlabel='Email' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='qq' AND tablename='ld_contactscf');
UPDATE ld_tranlabel SET fieldlabel='联系人 QQ' WHERE fieldlabel='QQ' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mailingzip' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人邮编' WHERE fieldlabel='邮编' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mailingstreet' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人住址' WHERE fieldlabel='住址' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='lastname' AND tablename='ld_contactdetails'); 
UPDATE ld_tranlabel SET fieldlabel='联系人姓名' WHERE fieldlabel='姓名' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='salutation' AND tablename='ld_contactdetails'); 
UPDATE ld_tranlabel SET fieldlabel='联系人称谓' WHERE fieldlabel='称谓' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='firstname' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人英文名' WHERE fieldlabel='英文名' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='title' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人职务' WHERE fieldlabel='职务' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pphone' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人电话' WHERE fieldlabel='电话' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mobile' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人手机' WHERE fieldlabel='手机' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='faxx' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人传真' WHERE fieldlabel='传真' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='email' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人 Email' WHERE fieldlabel='Email' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='qq' AND tablename='ld_contactscf');
UPDATE ld_tranlabel SET fieldlabel='联系人 QQ' WHERE fieldlabel='QQ' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mailingzip' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人邮编' WHERE fieldlabel='邮编' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mailingstreet' AND tablename='ld_contactdetails');
UPDATE ld_tranlabel SET fieldlabel='联系人住址' WHERE fieldlabel='住址' AND trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh' AND @cnt=1; 
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge');
SET @columnname=(SELECT GROUP_CONCAT(columnname) FROM ld_field WHERE tabid=6 AND quickcreate=0);
UPDATE ld_field SET quickcreate=0 WHERE tabid=@tabid AND FIND_IN_SET(columnname,@columnname);
delimiter;

UPDATE ld_field SET presence=1 WHERE tabid=14 AND columnname='batchmanagement' AND NOT EXISTS (SELECT 1 FROM ld_products);

SET @i=0;
UPDATE ld_parenttab SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;
-- 2017-12-20

call AddColumn('ld_producttoolprofile','presence','int','11',0);
call AddColumn('ld_tabdetailprofile','presence','int','11',0);
delimiter;

update ld_field set searchfieldtype = 0 where tabid = 14 and fieldname = 'productsheet';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','operatoroer','操作人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'operatoroer' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','operatoroer','Operator','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'operatoroer' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','operatoroertime','操作时间','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'operatoroertime' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','operatoroertime','Operating time','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'operatoroertime' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Alreadychosen','已选择','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Alreadychosen' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Alreadychosen','Already chosen ','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Alreadychosen' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_PERSONAL','个人','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_PERSONAL' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_PERSONAL',' personal','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_PERSONAL' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALL','全部','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ALL' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALL',' All','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ALL' and labeltype = 'jspop');
delimiter;

CALL AddColumn('ld_singin','signway','varchar','100','');
delimiter;

update ld_tab set printtab = 0 where `name` in ('CooperativeWork','ChinaMap');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment');
UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid;
UPDATE ld_field SET quickcreate=0 WHERE tabid=@tabid AND presence<>1
	AND columnname IN ('isenabled','related_to','filename');
-- 2017-12-21

update ld_bangwo8 set is_customer = 0;
delimiter;

select sequence into @sequence from ld_systems_deploy  where roottype=1  and deploy_type=14 ;
update ld_systems_deploy set sequence=sequence+1 where roottype=1 and sequence>@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '5',151,'客户查重和选择客户列表每页显示记录的条数','',@sequence+1,1,'select',0,'[{"value":"5","text":"5"},{"value":"10","text":"10"},{"value":"15","text":"15"} ,{"value":"20","text":"20"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=1 and deploy_type=151);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',6,151,'设置客户查重和选择客户列表每页显示记录的条数' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=151);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',6,151,'Setting up the number of entries per page for the customer to check and select the customer list' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=151);
delimiter;

update ld_desk set fieldlabel='说明：支持多字段模糊查询，仅显示符合条件的前{Var}条数据。' where languagetype='zh' and Labeltype='fixedstr' and labelbol='DSFMFFQOTSTT5OTQR';
update ld_desk set fieldlabel='Description: Support for multi field fuzzy query, only to show the top {Var} of the query result.' 
where languagetype='en' and Labeltype='fixedstr' and labelbol='DSFMFFQOTSTT5OTQR';
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy  where deploy_type=16 ;
update ld_systems_deploy set sequence=sequence+1000 where roottype=@roottype and sequence>=@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '0',152,'设置客户和服务收费管理是否显示工商查询功能','',@sequence,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type=152);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',152,152,'设置{$Accounts.Accounts}和{$ServiceCharge.ServiceCharge}是否显示工商查询功能' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=152 and tabid = 152);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',152,152,'Whether charging management of {$Accounts.Accounts} and {$ServiceCharge.ServiceCharge} shows business inquiry function' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=152 and tabid = 152);
delimiter;

update ld_customview set sequence=0 where entitytype='Users' and viewname='All';
delimiter;

update ld_desk set fieldlabel='说明：在所有客户中进行查重，最多只显示符合条件的前{Var}条数据。' where languagetype='zh' and Labeltype='fixedstr' and labelbol='NOTECHECKCUSTOMERS';
update ld_desk set fieldlabel='Note: check in all of the customers, only the first {Var} qualifying data.' where languagetype='en' and Labeltype='fixedstr' and labelbol='NOTECHECKCUSTOMERS';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Paymentplan';
update ld_field set approve_demand = 2 where tabid = @tabid and columnname = 'entitytypeid' and uitype = 202;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
update ld_field set approve_demand = 2 where tabid = @tabid and columnname = 'purchaseorder_id' and uitype = 202;
delimiter;
-- 2017-12-22


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

update ld_version set old_version='V7.1.5',current_version='V7.1.5',remark='V7.1.5-20171222',wx_version='V7.1.5';
delimiter;