DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
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
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default 0');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
profileid int(19),
tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
tabname varchar(50),
permissions int(19)

)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `fieldprofile`;
delimiter ||
CREATE  PROCEDURE `fieldprofile`(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;


declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;

declare continue handler  for not   found  SET done =1;


	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO

		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_actualtaxprice`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_actualtaxprice`(
)
BEGIN
	

	DECLARE tmp_tabid INT(19) DEFAULT 0;

	DECLARE cur1 CURSOR FOR SELECT tabid FROM ld_tab 
													WHERE `name` IN ('Quotes','PurchaseOrder','SalesOrder','Invoice',
														'ServiceContracts','OutboundOrder','Stock','SalesBack','CashBack',
														'PurchaseBack','PurchaseCashBack','PurchaseInvoice','WareHouseTransfer') ORDER BY tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	IF NOT EXISTS (SELECT 1 FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_inventoryproductrel' AND COLUMN_NAME='actualtaxprice') THEN
		 ALTER TABLE ld_inventoryproductrel ADD COLUMN actualtaxprice DECIMAL(25,8);
	END IF;

	OPEN cur1;
	Fetch cur1 into tmp_tabid;
	WHILE(tmp_tabid is not null) DO
		SELECT MAX(producttoolfieldid) into @maxid FROM ld_producttoolfield;
		SELECT sequence INTO @seq FROM ld_producttoolfield WHERE tabid=tmp_tabid AND columnname='tax_amount';
		UPDATE ld_producttoolfield SET sequence=sequence+1 WHERE tabid=tmp_tabid AND sequence>=@seq;

		INSERT INTO ld_producttoolfield (producttoolfieldid,columnname,allowhide,fieldlabel,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,defaultcolumn)
		SELECT @maxid+1,'actualtaxprice','yes','实际含税单价',0,163,'N~O~25,6',@seq,tmp_tabid,'ld_inventoryproductrel',30,1,2,3 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=tmp_tabid AND columnname='actualtaxprice');

		UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);

		SET @i=0;
		UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND presence<>1 ORDER BY sequence;

		SELECT producttoolfieldid into @producttoolfieldid FROM ld_producttoolfield WHERE tabid=tmp_tabid AND columnname='actualtaxprice';
		SELECT max(sequence) INTO @seq FROM ld_producttoolfield_formula where producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=tmp_tabid);
		INSERT INTO ld_producttoolfield_formula(producttoolfieldid,formulastring,columnstring,sequence)
		SELECT @producttoolfieldid,'a/b',"{formulavar:[{'lettervar':'a','column':'tax_amount'},{'lettervar':'b','column':'quantity'}]}",@seq+1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield_formula WHERE producttoolfieldid=@producttoolfieldid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_producttoolfield',tmp_tabid,@producttoolfieldid,'实际含税单价' FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_producttoolfield' and tabid = tmp_tabid and relateid=@producttoolfieldid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_producttoolfield',tmp_tabid,@producttoolfieldid,'Actual tax-inclusive price' FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_producttoolfield' and tabid = tmp_tabid and relateid=@producttoolfieldid);

		Fetch cur1 into tmp_tabid;
	END while;
	CLOSE cur1;

end ||
delimiter;

CALL ldcrm_add_actualtaxprice();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_actualtaxprice`;
delimiter;

UPDATE ld_inventoryproductrel SET actualtaxprice=tax_amount/quantity;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_attachments_filename`(
)
BEGIN
	

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_name VARCHAR(100) DEFAULT NULL;

	DECLARE cur1 CURSOR FOR SELECT tabid,`name` FROM ld_tab 
													WHERE `name` IN ('Potentials','Contacts','Accounts','HelpDesk','Faq','Events','Vendors',
														'Quotes','PurchaseOrder','SalesOrder','Invoice','Campaigns',
														'ServiceContracts','ModComments','ProjectMilestone','ProjectTask','Project','ContactRecords',
														'PaymentPlan','CashBill','Comprehensivereport','Expense','OutboundOrder','Stock','Checks','SendPayment',
														'SendCashBill','VendorContact','SalesBack','CashBack','VendorContactRecords','PutCash','CashDeposit',
														'Commission','PurchaseBack','PurchaseCashBack','PublicAnnouncement','ServiceCharge','PurchaseInvoice',
														'WareHouseTransfer','Rate','BankBranch','DividendOrder','TimeSheet','ServiceReturn','FundNet','FundReward',
														'FundRewardCommission','Management','Mcommission','Rate','BankAccountSet') ORDER BY tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_tabid,tmp_name;
	WHILE(tmp_tabid is not null) DO
		SELECT MAX(blockid) into @maxid FROM ld_blocks;
		SELECT MAX(sequence) into @maxseq FROM ld_blocks WHERE tabid=tmp_tabid;
		SET @trantable='ld_blocks';
		SET @blocklabel='LBI_ATTACHMENT_FILE';
		SET @zh='附件信息';
		SET @en='Attachments Information';

		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title)
		SELECT @maxid+1,tmp_tabid,@blocklabel,@maxseq+1,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=tmp_tabid AND blocklabel=@blocklabel);

		UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

		SELECT blockid INTO @relateid FROM ld_blocks WHERE tabid=tmp_tabid AND blocklabel=@blocklabel LIMIT 1;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,tmp_tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = tmp_tabid and relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,tmp_tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = tmp_tabid and relateid=@relateid);

		SET @maxseq=0;
		SELECT MAX(fieldid) INTO @maxid FROM ld_field;
		SELECT MAX(sequence) INTO @maxseq FROM ld_field WHERE tabid=tmp_tabid AND block=@relateid;
		SET @trantable='ld_field';
		SET @tablename='ld_attachments';
		SET @columnname='filename'; 
		SET @fieldname='filename'; 
		SET @zh='附件'; 
		SET @en='Attachment'; 
		SET @uitype=1109; 

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT tmp_tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0 from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=tmp_tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=tmp_tabid AND columnname=@columnname LIMIT 1;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,tmp_tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = tmp_tabid and relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,tmp_tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = tmp_tabid and relateid=@relateid);

		CALL getallprofile(tmp_name);
		CALL fieldprofile(tmp_name);

		Fetch cur1 into tmp_tabid,tmp_name;
	END while;
	CLOSE cur1;

end ||
delimiter;


CALL ldcrm_add_attachments_filename();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename`;
delimiter;

update ld_producttoolfield set typeofdata='N~O~25,8' WHERE columnname in ('listprice','taxprice','actualtaxprice') AND typeofdata like 'N~M~25,%';
-- 2017-07-10

update ld_desk set Labeltype = 'jspop' where labelbol = 'setthefileformat';
update ld_desk set Labeltype = 'jspop' where labelbol = 'viewthefileformat';
delimiter;

set @tabname='Attachment';
set @columnname='attachment_no';
set @en='Attachment NO';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='附件编号';
delimiter;

set @tabname='NormalApprove';
set @columnname='normalapprove_no';
set @en='Bill NO';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='单据编号';
delimiter;

set @tabname='NormalApprove';
set @columnname='smownerid';
set @en='Applicant';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='申请人';
delimiter;

set @tabname='NormalApprove';
set @columnname='description';
set @en='Approval Event';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='审批事由';
delimiter;

set @tabname='AddJobBill';
set @columnname='addjobbill_no';
set @en='Bill NO';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='单据编号';
delimiter;

set @tabname='AddJobBill';
set @columnname='smownerid';
set @en='Applicant';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='申请人';
delimiter;

set @tabname='MinusJobBill';
set @columnname='minusjobbill_no';
set @en='Bill NO';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='单据编号';
delimiter;

set @tabname='MinusJobBill';
set @columnname='smownerid';
set @en='Applicant';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='申请人';
delimiter;

set @tabname='BusinessApply';
set @columnname='businessapply_no';
set @en='Bill NO';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='单据编号';
delimiter;

set @tabname='BusinessApply';
set @columnname='smownerid';
set @en='Applicant';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='申请人';
delimiter;

set @tabname='BusinessApply';
set @columnname='businessreason';
set @en='Business Reason';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='出差事由';
delimiter;


set @tabname='BusinessApply';
set @columnname='peer_persons';
set @en='Fellow Workers';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='同行人';
delimiter;

set @tabname='BusinessApply';
set @columnname='budget';
set @en='Budget(¥)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='预算(元)';
delimiter;

set @tabname='BusinessApply';
set @columnname='preparemoney';
set @en='Advance Money(¥)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='预支(元)';
delimiter;

set @tabname='BusinessApply';
set @columnname='source';
set @en='Departure Place';
select tabid into @tabid from ld_tab where `name`=@tabname;
select tabdetailfieldid into @fieldid from ld_tabdetailfield where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_tabdetailfield' and fieldlabel='出发地';
delimiter;

set @tabname='BusinessApply';
set @columnname='destination';
set @en='Destination Place';
select tabid into @tabid from ld_tab where `name`=@tabname;
select tabdetailfieldid into @fieldid from ld_tabdetailfield where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_tabdetailfield' and fieldlabel='目的地';
delimiter;

set @tabname='BusinessApply';
set @columnname='starttime';
set @en='Start Time';
select tabid into @tabid from ld_tab where `name`=@tabname;
select tabdetailfieldid into @fieldid from ld_tabdetailfield where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_tabdetailfield' and fieldlabel='出发时间';
delimiter;

set @tabname='BusinessApply';
select tabid into @tabid from ld_tab where `name`=@tabname;
update ld_tabdetailfield set width=40 where tabid=@tabid and columnname='source' and width<40;
update ld_tabdetailfield set width=40 where tabid=@tabid and columnname='destination' and width<40;
delimiter;

set @tabname='LoanApply';
set @columnname='loanapply_no';
set @en='Bill NO';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='单据编号';
delimiter;

set @tabname='LoanApply';
set @columnname='smownerid';
set @en='Applicant';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='申请人';
delimiter;

set @tabname='LoanApply';
set @columnname='loanmoney';
set @en='Loan Money';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='借款金额';
delimiter;

set @tabname='LoanApply';
set @columnname='paymentdate';
set @en='Planned Repayment Date';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='预计还款日期';
delimiter;

set @tabname='LoanApply';
set @columnname='loanreason';
set @en='Loan Reason';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='借款事由';
delimiter;

set @tabname='CardApply';
set @columnname='LBL_CARDAPPLY_ZH_CONTENT';
set @en='Business Card Information(Chinese)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select blockid into @fieldid from ld_blocks where tabid=@tabid and blocklabel=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_blocks' and fieldlabel='名片内容(中文)';
delimiter;

set @tabname='CardApply';
set @columnname='LBL_CARDAPPLY_EN_CONTENT';
set @en='Business Card Information(English)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select blockid into @fieldid from ld_blocks where tabid=@tabid and blocklabel=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_blocks' and fieldlabel='名片内容(英文)';
delimiter;

set @tabname='CardApply';
set @columnname='applydate';
set @en='Apply Date';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='申请日期';
delimiter;

set @tabname='CardApply';
set @columnname='cardapply_no';
set @en='Bill NO';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='单据编号';
delimiter;

set @tabname='CardApply';
set @columnname='printnum';
set @en='Printing Quantity';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='印刷数量(张)';
delimiter;

set @tabname='CardApply';
set @columnname='smownerid';
set @en='Applicant';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='申请人';
delimiter;

set @tabname='CardApply';
set @columnname='zh_companyname';
set @en='Company Name(zh)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='公司名称';
delimiter;

set @tabname='CardApply';
set @columnname='zh_address';
set @en='Address(zh)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='地址';
delimiter;

set @tabname='CardApply';
set @columnname='zh_name';
set @en='Name(zh)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='姓名';
delimiter;

set @tabname='CardApply';
set @columnname='zh_title';
set @en='Position(zh)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='职务';
delimiter;

set @tabname='CardApply';
set @columnname='zh_department';
set @en='Department(zh)';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='部门';
delimiter;

set @tabname='CardApply';
set @columnname='zh_phone';
set @en='Phone';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='联系电话';
delimiter;

set @tabname='CardApply';
set @columnname='zh_fax';
set @en='Fax';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='传真';
delimiter;

set @tabname='CardApply';
set @columnname='zh_email';
set @en='Email';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='电子邮箱';
delimiter;

update ld_desk set fieldlabel='下一步审批人' where labelbol='nextstepofapproval' and Labeltype='fixedstr' and fieldlabel='下一步骤的审批人' and languagetype='zh';

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','erplist','http://51mis.com.cn/forum.php?mod=viewthread&tid=41&fromuid=1','控制面板-ERP接口信息列表' from DUAL
where not exists(select 1 from ld_links where linktype ='Settings' and linklabel = 'erplist');
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 16;
update ld_systems_deploy set sequence = sequence+1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,140,'快速创建客户默认的客户公海状态','',@sequence+1,@roottype,'select',0,'[{"value":"0","text":"普通客户"},{"value":"1","text":"公海未分配"},{"value":"2","text":"公海已分配"},{"sql":""}]' from DUAL
where not EXISTS(select 1 from ld_systems_deploy where deploy_type = 140);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',140,140,'快速创建客户默认的客户公海状态' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid = 140 and Relateid = 140);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',140,140,'Quickly create default account high seas status' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid = 140 and Relateid = 140);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','setthefileformat','设置允许上传的文件格式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'setthefileformat' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','setthefileformat','Set the file format that you can upload','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'setthefileformat' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','viewthefileformat','查看允许上传的文件格式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'viewthefileformat' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','viewthefileformat','View the file format that you can upload','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'viewthefileformat' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'viewselfbills';
update ld_tranlabel set fieldlabel = '允许查询自已创建的单据(负责人不是自已的单据)' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = 'Allows to query the data which created by myself(smownerid are not responsible for their own documents)' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','uploaduptoattachments','最多上传{Num}个附件','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='uploaduptoattachments' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','uploaduptoattachments','Upload up to {Num} attachments at most','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='uploaduptoattachments' and Labeltype='jspop');
delimiter;
-- 2017-07-11

set @tabname='MinusJobBill';
set @columnname='minusjobbill_no';
set @en='Bill NO';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_field' and fieldlabel='单据编号';
delimiter;

set @tabname='MinusJobBill';
set @columnname='minusjobtype';
set @en='Vacation Type';
select tabid into @tabid from ld_tab where `name`=@tabname;
select tabdetailfieldid into @fieldid from ld_tabdetailfield where tabid=@tabid and columnname=@columnname;
update ld_tranlabel set fieldlabel=@en where Relateid=@fieldid and languagetype='en' and trantable='ld_tabdetailfield' and fieldlabel='假别';
delimiter;

delete from ld_systems_deploy where deploy_type = 140;
delete from ld_tranlabel where tabid = 140 and relateid = 140 and trantable = 'ld_systems_deploy';
delimiter;
call AddColumn('ld_account_set','publicaccount','int','25',0);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','quicklycreatedefaultaccount','快速创建客户默认的客户公海状态','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'quicklycreatedefaultaccount' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','quicklycreatedefaultaccount','Quickly create default account high seas status','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'quicklycreatedefaultaccount' and labeltype = 'fixedstr');
delimiter;
-- 2017-07-13
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'Attachment',0,0,'ld_attachmentsforbills:attachment_no:attachment_no:Attachment_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'Attachment' and rownumber=0 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'Attachment',1,0,'ld_attachmentsforbills:related_to:related_to:Attachment_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'Attachment' and rownumber=1 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'Attachment',1,1,'ld_attachmentsforbills:createdtime:createdtime:Attachment_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'Attachment' and rownumber=1 AND listnumber=1);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP','不通过，返回到上一步','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP','If not passed, then return to the previous step','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP' and labeltype = 'fixedstr');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','EditApproveStep','http://51mis.com.cn/forum.php?mod=viewthread&tid=42&fromuid=1','新增、编辑审批步骤' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'EditApproveStep');
delimiter;

update ld_desk set labelbol = 'LBL_Optionalmodule_Customization' where labelbol like '%LBL_Optionalmodule_Customization';
update ld_desk set labelbol = 'LBL_Optionalmodule_Customization_Description' where labelbol like '%LBL_Optionalmodule_Customization_Description';
delimiter;
-- 2017-07-15

select tabid into @tabid from ld_tab where name = 'ServiceCharge';
update ld_relatedlists set mobile_presence=0 where tabid=@tabid 
and related_tabid in(select tabid from ld_tab where name in ('Contacts','ContactRecords','Potentials'));
delimiter;

update ld_appparenttab set blockname='库存管理',parenttab_label='Inventory' where blockname='仓库管理' and systemdefault='yes';

update ld_systems_deploy set deploy_value=0 where deploy_type=82 and not exists (select 1 from ld_crmentity where crmid>2);
update ld_tranlabel set fieldlabel='单据分录明细中录入{$Products.Products}时允许选择禁用的{$Products.Products}' where Relateid=82 and trantable='ld_systems_deploy' and languagetype='zh';

DROP PROCEDURE IF EXISTS `ldcrm_update_products_discontinued`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_products_discontinued`(
)
BEGIN
	
	SET @tabid=14;
	select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='discontinued';
	update ld_tranlabel set fieldlabel='禁用' where Relateid=@fieldid and tabid=@tabid and trantable='ld_field' and languagetype='zh';
	update ld_tranlabel set fieldlabel='Disabled' where Relateid=@fieldid and tabid=@tabid and trantable='ld_field' and languagetype='en';	
    update ld_field set fieldlabel='禁用' where tabid=@tabid and columnname='discontinued'; 
     
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='discontinued' AND defaultvalue=1) THEN
        update ld_field set defaultvalue=0 where tabid=@tabid and columnname='discontinued';
		update ld_products set discontinued=100 where discontinued=0;
		update ld_products set discontinued=0 where discontinued=1;
		update ld_products set discontinued=1 where discontinued=100;
	END IF;

END ||
delimiter;

CALL ldcrm_update_products_discontinued();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_products_discontinued`;
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceCharge';
update ld_relatedlists set mobile_presence=1 where tabid=@tabid;
-- 2017-07-18

select tabid into @tabid from ld_tab where `name`='Productbom';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
select tablename into @tablename from ld_field where tabid=@tabid and columnname='smownerid';
set @columnname='bomcode';
set @fieldname='bomcode';
set @zh='编码/条码';
set @en='BOM Code';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;

call getallprofile('Productbom');
delimiter;
call fieldprofile('Productbom');
delimiter;

select tabid into @tabid from ld_tab where `name`='Productbom';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=sequence=100 where tabid=@tabid and block=@blockid;
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and columnname='subject';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and columnname='productbom_no';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and columnname='bomcode';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and columnname='smownerid';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and columnname='createdtime';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and columnname='smcreatorid';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and columnname='modifiedtime';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and columnname='modifiedby';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence,fieldid;
delimiter;

update ld_producttoolfield set width=35 where width<35 and columnname='actualtaxprice';
update ld_producttoolfield set width=26 where width<26 and columnname='list_amount';
-- 2017-07-19

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

update ld_version set old_version='V7.0.6',current_version='V7.0.6',remark='V7.0.6-201707019';
delimiter;