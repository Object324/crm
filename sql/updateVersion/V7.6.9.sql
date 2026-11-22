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

UPDATE ld_products p
LEFT JOIN (
	SELECT
		a.wareid,
		a.productid,
		a.batchtext,
		SUM(a.inventory_qty) AS inventory_qty
	FROM (
		SELECT
			a.warehouseid AS wareid,
			a.productid,
			a.batchtext,
			a.lastqty AS inventory_qty
		FROM ld_warehousecondtions a
		LEFT JOIN ld_products c ON c.productid=a.productid
		WHERE a.modulename='库存初始化'
			AND a.type='确认初始库存'
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_stock a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.stock_id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_salesback a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.salesbackid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.salesbackstatus<>'中止'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			c.wareid,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_outboundorder a
		LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.out_id
		LEFT JOIN ld_inventoryproductrelscf d ON d.lineitem_id=c.lineitem_id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_purchaseback a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.purchasebackid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.purchasebackstatus<>'中止'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.purchasebackstatus='结束'
				END)
		UNION ALL
		SELECT
			a.inwarehouse,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_warehousetransfer a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.warehousetransferid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.transferstatus='已审核'
				END)
		UNION ALL
		SELECT
			a.outwarehouse,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_warehousetransfer a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.warehousetransferid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.transferstatus='已审核'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.profitloss
		FROM ld_checks a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.presence='盘点结束'
				END)
	) a
	WHERE a.productid>0
	GROUP BY a.productid
) a ON a.productid=p.productid
SET p.qtyinstock=IFNULL(a.inventory_qty,0)
WHERE p.deleted=0
	AND IFNULL(p.qtyinstock,0)<>IFNULL(a.inventory_qty,0);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'whethertochangethewarehouse','是否更改下面所有行的仓库为{warename}','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='whethertochangethewarehouse' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'whethertochangethewarehouse','Whether to change the warehouse for all the bellow rows','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='whethertochangethewarehouse' and labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'mailingarea';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','bill_area' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'Tencent','腾讯','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Tencent' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'Tencent','Tencent','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Tencent' and labeltype='fixedstr');
delimiter;

update ld_field set approve_demand = 2 where tabid = 6 and columnname in ('lastservicedate');
delimiter;

DROP PROCEDURE IF EXISTS `altercolumnfor_primarykey`;
delimiter ||
CREATE  PROCEDURE `altercolumnfor_primarykey`(
 tablename varchar(50),
 columnname varchar(50)
)
BEGIN
    SELECT DATABASE() INTO @tableschema;
    SET tablename=LOWER(tablename);
    SET @primaryNum=0;
		select database() into @db_name;

		select count(*) into @primaryNum
		from INFORMATION_SCHEMA.KEY_COLUMN_USAGE t
		where t.table_schema = @db_name and t.TABLE_NAME = tablename and COLUMN_NAME = columnname;
		IF @primaryNum = 0 THEN

      SET @altersql=CONCAT(' alter table ',tablename, ' change ',columnname,' ',columnname,' int primary key auto_increment');
      PREPARE stalter FROM @altersql;
      EXECUTE stalter;

			set @altersql1 = CONCAT(' alter table ',tablename, ' change ',columnname,' ',columnname,' int NOT NULL auto_increment');
			PREPARE stalter FROM @altersql1;
      EXECUTE stalter;

    END IF;
 end ||
delimiter;

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

update ld_desk set fieldlabel='产品授权信息' where labelbol='LBL_AUTHENINFO' and Labeltype='fixedstr' and languagetype='zh';
select blockid into @blockid from ld_settings_blocks where label='LBL_OTHER_SETTINGS';
select sequence into @sequence from ld_settings_field where `name` = 'LBL_ACCOUNTS_CONTACTS_FIELDS' and blockid=@blockid;
update ld_settings_field set sequence=@sequence where `name`='LBL_AUTHENINFO' and blockid=@blockid;
update ld_settings_field set sequence=@sequence+1 where `name`='LBL_ACCOUNTS_CONTACTS_FIELDS' and blockid=@blockid;
update ld_settings_field set sequence=sequence+2 where blockid=@blockid;
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','INVENTORY','库存','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='INVENTORY' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','INVENTORY','Inventory','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='INVENTORY' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','PRODUCTQTYINSTOCKTITLE','产品库存数量分布明细','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='PRODUCTQTYINSTOCKTITLE' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','PRODUCTQTYINSTOCKTITLE','Product inventory quantity distribution details','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='PRODUCTQTYINSTOCKTITLE' and languagetype='en' and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_mailmanager_mailrecord','seen','int',10,1 );
delimiter;
call AddColumn('ld_mailmanager_mailrecord','mmsgno','int',19,0 );
delimiter;
call AddColumn('ld_mailmanager_mailrecord','mailrecordid','int',19,0 );
delimiter;
call altercolumnfor_primarykey('ld_mailmanager_mailrecord','mailrecordid');
delimiter;
call AddColumn('ld_mailmanager_mailrecord','mailaccountname','varchar',100,'' );
delimiter;
call AddColumn('ld_mailmanager_mailrecord','deleted','int',19,'0' );
delimiter;
call AddColumn('ld_mailmanager_mailrecord','createdtime','datetime',10,'0' );
delimiter;

call AddColumn('ld_mailmanager_mailattachments','mailrecordid','int',19,'0' );
delimiter;

call AddColumn('ld_mailmanager_mailrecord','starmail','varchar',20,'no' );
delimiter;

call AddColumn('ld_mail_accounts','mail_serverport','int',19,0 );
delimiter;
call AddColumn('ld_mail_accounts','createdtime','datetime',10,0 );
delimiter;
call AddColumn('ld_mail_accounts','mailcount','int',19,0 );
delimiter;

alter table `ld_mail_accounts` modify account_id int auto_increment;
delimiter;
call altercolumnfor_primarykey('ld_mailmanager_mailattachments','attachid');
delimiter;
alter table `ld_mailmanager_mailattachments` modify attachid int auto_increment;
delimiter;

CREATE TABLE if not exists `ld_mailmanager_history` (
  `uidl` varchar(100) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `userid` int(19) DEFAULT NULL,
  `mailaccountname` varchar(100) DEFAULT NULL,
	`msubject` varchar(200) DEFAULT NULL,
  `mdate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAILBOXSETUP','邮件账户设置','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MAILBOXSETUP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAILBOXSETUP','邮件账户设置','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MAILBOXSETUP' and labeltype='fixedstr');
delimiter;


CREATE TABLE if not exists `ld_mailmanager_deletemail` (
  `userid` int(11) DEFAULT NULL,
  `mfrom` varchar(255) DEFAULT NULL,
  `mto` varchar(255) DEFAULT NULL,
  `mcc` varchar(500) DEFAULT NULL,
  `mbcc` varchar(500) DEFAULT NULL,
  `mdate` varchar(20) DEFAULT NULL,
  `msubject` varchar(500) DEFAULT NULL,
  `mbody` text,
  `mcharset` varchar(10) DEFAULT NULL,
  `misbodyhtml` int(1) DEFAULT NULL,
  `mplainmessage` int(1) DEFAULT NULL,
  `mhtmlmessage` int(1) DEFAULT NULL,
  `muniqueid` varchar(500) DEFAULT NULL,
  `mbodyparsed` int(1) DEFAULT NULL,
  `muid` int(11) DEFAULT NULL,
  `seen` int(10) DEFAULT '0',
  `mmsgno` int(19) DEFAULT '0',
  `mailrecordid` int(11) NOT NULL AUTO_INCREMENT,
  `mailaccountname` varchar(100) DEFAULT NULL,
  `mailaccount` varchar(100) DEFAULT NULL,
  `deleted` int(19) DEFAULT '0',
  `createdtime` datetime DEFAULT NULL,
  PRIMARY KEY (`mailrecordid`),
  KEY `userid_muid_idx` (`userid`,`muid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select max(ruleid) into @maxruleid from ld_def_org_share;
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @maxruleid+1,10,3,0 from dual where not exists(select 1 from  ld_def_org_share where tabid=10);
update ld_def_org_share_seq set id=@maxruleid+1;
delimiter;
-- 2019-01-30

UPDATE ld_producttoolfield SET uitype=60 WHERE columnname='wareid' AND tabid=(SELECT tabid FROM ld_tab WHERE name='OutboundOrder');

CREATE TABLE IF NOT EXISTS `ld_approvecanceladvfilter` (
  `approveid` int(11) NOT NULL DEFAULT '0',
  `columnindex` int(11) NOT NULL DEFAULT '0',
  `columnname` varchar(250) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  `value` varchar(200) DEFAULT NULL,
  `groupid` int(11) DEFAULT NULL,
  `column_condition` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`approveid`,`columnindex`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_approvecanceladvfilter_grouping` (
  `groupid` int(11) NOT NULL DEFAULT '0',
  `approveid` int(11) NOT NULL DEFAULT '0',
  `group_condition` varchar(50) DEFAULT NULL,
  `condition_expression` text,
  PRIMARY KEY (`groupid`,`approveid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2019-02-11

DROP PROCEDURE IF EXISTS `insert_tmp_date`;
delimiter ||
CREATE PROCEDURE `insert_tmp_date`(
)
begin

	declare tmpdate date default NULL;

	set @cnt=0;
	set @maxdate=NULL;
	set @mindate=NULL;
	set @enddate=NULL;
	select ifnull(max(date),CURDATE()) into @maxdate from tmp_date;
	select
		date_sub(ifnull(min(date),CURDATE()),INTERVAL 1 year) into @mindate
	from (
			select min(cashbilldate) date from ld_cashbill
			UNION ALL select min(signed_data) from ld_salesorder
			UNION ALL select min(due_date) from ld_servicecontracts) a;

	select CONCAT(YEAR(CURDATE())+2,'-12-31') into @enddate;
	select count(1) into @cnt from tmp_date;

	IF @cnt=0 THEN
		set tmpdate=@mindate;
	ELSE
		set tmpdate=date_add(@maxdate,interval 1 day);
	END IF;

	while tmpdate<=@enddate DO
			insert into tmp_date(date) select tmpdate;
			set tmpdate=date_add(tmpdate,interval 1 day);
	end while;

END ||
delimiter;

CALL insert_tmp_date();

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','exporttopdf1','导出成PDF格式','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='exporttopdf1' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','exporttopdf1','Export to PDF format','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='exporttopdf1' and languagetype='en' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','Send_Email_Add_DOC','发送邮件并添加DOC格式附件','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Send_Email_Add_DOC' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','Send_Email_Add_DOC','Send email add doc','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Send_Email_Add_DOC' and languagetype='en' and Labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '发送邮件并添加PDF格式附件' where labelbol = 'Send_Email_Add_PDF' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;
-- 2019-02-13

DROP PROCEDURE IF EXISTS `ldcrm_reset_picklist_dependency_20190218`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_picklist_dependency_20190218`()
BEGIN

	SET @listid_billcity=(SELECT listid FROM ld_picklist_set WHERE listname='bill_city' LIMIT 1);

	IF EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid_billcity AND listvalue='省直辖县级行政区划') THEN
		DELETE FROM ld_picklist_values WHERE listid=@listid_billcity AND listvalue IN ('省直辖县级行政区划');

		SET @i=(SELECT MAX(sequence) FROM ld_picklist_values WHERE listid=@listid_billcity);
		INSERT INTO ld_picklist_values(listid,listvalue,sequence)
		SELECT @listid_billcity,'河北省直辖县级行政区划',@i:=(@i+1) FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid_billcity AND listvalue='河北省直辖县级行政区划');

		INSERT INTO ld_picklist_values(listid,listvalue,sequence)
		SELECT @listid_billcity,'河南省直辖县级行政区划',@i:=(@i+1) FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid_billcity AND listvalue='河南省直辖县级行政区划');


		INSERT INTO ld_picklist_values(listid,listvalue,sequence)
		SELECT @listid_billcity,'湖北省直辖县级行政区划',@i:=(@i+1) FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid_billcity AND listvalue='湖北省直辖县级行政区划');

		INSERT INTO ld_picklist_values(listid,listvalue,sequence)
		SELECT @listid_billcity,'海南省直辖县级行政区划',@i:=(@i+1) FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid_billcity AND listvalue='海南省直辖县级行政区划');

		UPDATE ld_picklist_dependency SET targetvalues=REPLACE(targetvalues,'省直辖县级行政区划','河北省直辖县级行政区划') WHERE targetfield='bill_city'
			AND sourcevalue='河北省' AND tabid=6 AND targetvalues NOT LIKE '%河北省直辖县级行政区划%';

		UPDATE ld_picklist_dependency SET targetvalues=REPLACE(targetvalues,'省直辖县级行政区划','河南省直辖县级行政区划') WHERE targetfield='bill_city'
			AND sourcevalue='河南省' AND tabid=6 AND targetvalues NOT LIKE '%河南省直辖县级行政区划%';

		UPDATE ld_picklist_dependency SET targetvalues=REPLACE(targetvalues,'省直辖县级行政区划','湖北省直辖县级行政区划') WHERE targetfield='bill_city'
			AND sourcevalue='湖北省' AND tabid=6 AND targetvalues NOT LIKE '%湖北省直辖县级行政区划%';

		UPDATE ld_picklist_dependency SET targetvalues=REPLACE(targetvalues,'省直辖县级行政区划','海南省直辖县级行政区划') WHERE targetfield='bill_city'
			AND sourcevalue='海南省' AND tabid=6 AND targetvalues NOT LIKE '%海南省直辖县级行政区划%';

		UPDATE ld_picklist_dependency SET sourcevalue='河北省直辖县级行政区划' WHERE targetfield='bill_area' AND sourcevalue='省直辖县级行政区划' AND targetvalues LIKE '%辛集%';
		UPDATE ld_picklist_dependency SET sourcevalue='河南省直辖县级行政区划' WHERE targetfield='bill_area' AND sourcevalue='省直辖县级行政区划' AND targetvalues LIKE '%济源%';
		UPDATE ld_picklist_dependency SET sourcevalue='湖北省直辖县级行政区划' WHERE targetfield='bill_area' AND sourcevalue='省直辖县级行政区划' AND targetvalues LIKE '%潜江%';
		UPDATE ld_picklist_dependency SET sourcevalue='海南省直辖县级行政区划' WHERE targetfield='bill_area' AND sourcevalue='省直辖县级行政区划' AND targetvalues LIKE '%五指山%';


		-- 插入销售机会、联系人、供应商、服务收费管理级联关系
		SET @tabid=2;
		DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield IN ('bill_country','bill_state','bill_city');
		SET @i=(SELECT MAX(id) FROM ld_picklist_dependency);

		INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
		SELECT (@i:=@i+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency
		WHERE tabid=6 AND sourcefield IN ('bill_country','bill_state','bill_city');

		SET @tabid=4;
		DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield IN ('bill_country','bill_state','bill_city');
		SET @i=(SELECT MAX(id) FROM ld_picklist_dependency);

		INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
		SELECT (@i:=@i+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency
		WHERE tabid=6 AND sourcefield IN ('bill_country','bill_state','bill_city');

		SET @tabid=18;
		DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield IN ('bill_country','bill_state','bill_city');
		SET @i=(SELECT MAX(id) FROM ld_picklist_dependency);

		INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
		SELECT (@i:=@i+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency
		WHERE tabid=6 AND sourcefield IN ('bill_country','bill_state','bill_city');

		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='ServiceCharge' LIMIT 1);
		DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield IN ('bill_country','bill_state','bill_city');
		SET @i=(SELECT MAX(id) FROM ld_picklist_dependency);

		INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
		SELECT (@i:=@i+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency
		WHERE tabid=6 AND sourcefield IN ('bill_country','bill_state','bill_city');

		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Leads' LIMIT 1);
		DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield IN ('bill_country','bill_state','bill_city');
		SET @i=(SELECT MAX(id) FROM ld_picklist_dependency);

		INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
		SELECT (@i:=@i+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency
		WHERE tabid=6 AND sourcefield IN ('bill_country','bill_state','bill_city');

		UPDATE ld_picklist_dependency_seq SET id=(SELECT max(id) FROM ld_picklist_dependency);


		UPDATE ld_account SET bill_city='河北省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='河北';
		UPDATE ld_account SET bill_city='河南省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='河南';
		UPDATE ld_account SET bill_city='湖北省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='湖北';
		UPDATE ld_account SET bill_city='海南省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='海南';

		UPDATE ld_potential SET bill_city='河北省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='河北';
		UPDATE ld_potential SET bill_city='河南省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='河南';
		UPDATE ld_potential SET bill_city='湖北省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='湖北';
		UPDATE ld_potential SET bill_city='海南省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='海南';

		UPDATE ld_contactdetails SET mailingcity='河北省直辖县级行政区划' WHERE mailingcity='省直辖县级行政区划' AND mailingstate='河北';
		UPDATE ld_contactdetails SET mailingcity='河南省直辖县级行政区划' WHERE mailingcity='省直辖县级行政区划' AND mailingstate='河南';
		UPDATE ld_contactdetails SET mailingcity='湖北省直辖县级行政区划' WHERE mailingcity='省直辖县级行政区划' AND mailingstate='湖北';
		UPDATE ld_contactdetails SET mailingcity='海南省直辖县级行政区划' WHERE mailingcity='省直辖县级行政区划' AND mailingstate='海南';


		UPDATE ld_vendor SET bill_city='河北省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='河北';
		UPDATE ld_vendor SET bill_city='河南省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='河南';
		UPDATE ld_vendor SET bill_city='湖北省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='湖北';
		UPDATE ld_vendor SET bill_city='海南省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='海南';


		UPDATE ld_leads SET bill_city='河北省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='河北';
		UPDATE ld_leads SET bill_city='河南省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='河南';
		UPDATE ld_leads SET bill_city='湖北省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='湖北';
		UPDATE ld_leads SET bill_city='海南省直辖县级行政区划' WHERE bill_city='省直辖县级行政区划' AND bill_state='海南';

	END IF;

END ||
delimiter;


CALL ldcrm_reset_picklist_dependency_20190218();
DROP PROCEDURE IF EXISTS `ldcrm_reset_picklist_dependency_20190218`;

update ld_workreport_field_seq set id = (select max(id) from ld_workreport_field);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='BusinessApply');
UPDATE ld_tabdetailfield SET presence=1 WHERE tabid=@tabid AND columnname IN ('starttime','endtime');
UPDATE ld_tabdetailfield SET defaultcolumn=1 WHERE tabid=@tabid AND columnname IN ('starttime','endtime','description');
delimiter;
-- 2019-02-19

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','handwriting','手写签名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='handwriting' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','handwriting','Handwriting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='handwriting' and languagetype='en' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','handwritingdatetime','签名时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='handwritingdatetime' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','handwritingdatetime','Handwriting datetime','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='handwritingdatetime' and languagetype='en' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','allowrewriting','允许重签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='allowrewriting' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','allowrewriting','Allow rewriting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='allowrewriting' and languagetype='en' and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_field','fldallow_rewriting','int',11,0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select max(blockid) into @blockid from ld_blocks;
select sequence into @sequence from ld_blocks where tabid = @tabid and blocklabel = 'LBI_ATTACHMENT_FILE';
update ld_blocks set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom,linkid)
select @blockid+1,@tabid,'LBL_Signature_Confirmation',@sequence+1,0,0,0,0,0,1,0,NULL from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_Signature_Confirmation');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_Signature_Confirmation';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签字确认' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and tabid = @tabid and Relateid = @blockid and trantable = 'ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Signature Confirmation' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and tabid = @tabid and Relateid = @blockid and trantable = 'ld_blocks');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
SET @i=0;
UPDATE ld_blocks SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

call AddColumn('ld_troubletickets','customer_signature','varchar','200',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_Signature_Confirmation';
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'customer_signature','yes','ld_troubletickets',1,222,'customer_signature','客户签名',1,0,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'customer_signature');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'customer_signature';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'客户签名' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Customer Signature' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_field_signature` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tabid` int(11) DEFAULT NULL,
  `recordid` int(11) DEFAULT NULL,
  `fieldname` varchar(100) DEFAULT NULL,
  `path` text,
  `name` varchar(200) DEFAULT NULL,
  `datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
update ld_tranlabel set fieldlabel='Collection Plan' where trantable = 'ld_tab' and tabid = @tabid and Relateid = @tabid and languagetype = 'en';

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_tranlabel set fieldlabel='Receipt' where trantable = 'ld_tab' and tabid = @tabid and Relateid = @tabid and languagetype = 'en';
delimiter;
-- 2019-02-20

UPDATE ld_field SET searchfieldtype=0 WHERE tabid IN (SELECT tabid FROM ld_tab WHERE `name` LIKE 'CustomForm%') AND uitype=4;
UPDATE ld_field SET searchfieldtype=0 WHERE tabid IN (SELECT tabid FROM ld_tab WHERE `name` LIKE 'CustomForm%') AND columnname='smownerid';

call AddColumn('ld_mail_accounts','smtp_servername','varchar',100,'' );
delimiter;
call AddColumn('ld_mail_accounts','smtp_ssltype','varchar',100,'' );
delimiter;
call AddColumn('ld_mail_accounts','smtp_port','varchar',100,'' );
delimiter;
call AddColumn('ld_mailmanager_mailrecord','mailtype','varchar',50,'pop' );
delimiter;
update ld_mailmanager_mailrecord set mailtype='pop' where mailtype is null;
delimiter;
call Del_TableIndex('ld_mailmanager_mailrecord','userid_lastsavedtime_idx');
delimiter;
call Del_TableIndex('ld_mailmanager_mailrecord','userid_muid_idx');
delimiter;
call addtableIndex('ld_mailmanager_mailrecord','mailrecord_mailtype_idx','mailtype,mailaccountname');
delimiter;
call AddColumn('ld_mailmanager_mailattachments','filesize','decimal',25,'0' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELEMPTYMAIL', '是否要清空此文件夹中的邮件？','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='jspop' and labelbol='DELEMPTYMAIL');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELEMPTYMAIL', 'Do you want to empty the mail in this folder?','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='jspop' and labelbol='DELEMPTYMAIL');
delimiter;
-- 2018-02-25

DROP PROCEDURE IF EXISTS `ldcrm_reset_parenttabforleads_20190301`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_parenttabforleads_20190301`(
)
BEGIN


	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
	SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Parent Accounts');
	SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Accounts');
	
	IF NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid) THEN
		UPDATE ld_parenttabrel SET sequence=sequence+1 WHERE parenttabid=@parenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,@tabid,1;
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=@tabid) THEN
		UPDATE ld_appparenttabrel SET sequence=sequence+1 WHERE blockid=@blockid;
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,@tabid,1;
	END IF;

END ||
delimiter;

CALL ldcrm_reset_parenttabforleads_20190301();
DROP PROCEDURE IF EXISTS `ldcrm_reset_parenttabforleads_20190301`;

UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=48 AND NOT EXISTS (
	SELECT 1 FROM ld_crmentity WHERE setype IN ('OutboundOrder','Stock','WareHouseTransfer','Checks','SalesBack','PurchaseBack'));
delimiter;

update ld_desk set fieldlabel='客户联系适用范围配置' where labelbol='ExternalContactUsersSetting' and languagetype='zh';
delimiter;

UPDATE ld_purchaseorder a
LEFT JOIN ld_inventoryproductrel b ON a.purchaseorderid=b.id
LEFT JOIN (
	SELECT
		b.entitytypeid,
		b.parent_lineitem_id,
		SUM(b.quantity) AS in_qty
	FROM ld_stock a
	LEFT JOIN ld_inventoryproductrel b ON a.stock_id=b.id
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 LIMIT 1)=0 THEN 
						a.approvestatus='已批准'
					ELSE 1=1
				END
			)
		AND b.entitytype='PurchaseOrder'
	GROUP BY b.entitytypeid,b.parent_lineitem_id
) c ON b.id=c.entitytypeid AND b.lineitem_id=c.parent_lineitem_id
SET b.havepurchasecount=IFNULL(c.in_qty,0);
delimiter;
UPDATE ld_purchaseorder a
LEFT JOIN ld_inventoryproductrel b ON a.purchaseorderid=b.id
SET b.balancepurchasecount=IFNULL(b.quantity,0)-IFNULL(b.havepurchasecount,0);
delimiter;

UPDATE ld_purchaseorder a
LEFT JOIN ld_inventoryproductrel b ON a.purchaseorderid=b.id
SET a.stockpresence=(	CASE 
												WHEN b.balancepurchasecount<=0 THEN '全部入库' 
												WHEN b.havepurchasecount>0 AND b.balancepurchasecount>0 THEN '部分入库' 
												ELSE '未入库'
											END);
delimiter;

update ld_stock set presence='未入库'
	where exists  (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 and deploy_value=0) 
and ifnull(approvestatus,'')<>'已批准';
delimiter;

update ld_stock set presence='已入库'
	where exists  (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 and deploy_value=1) ;
delimiter;

UPDATE ld_salesorder a
LEFT JOIN ld_inventoryproductrel b ON a.salesorderid=b.id
LEFT JOIN (
	SELECT
		b.entitytypeid,
		b.parent_lineitem_id,
		SUM(b.quantity) AS in_qty
	FROM ld_outboundorder a
	LEFT JOIN ld_inventoryproductrel b ON a.out_id=b.id
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 LIMIT 1)=0 THEN 
						a.approvestatus='已批准'
					ELSE 1=1
				END
			)
		AND b.entitytype='SalesOrder'
	GROUP BY b.entitytypeid,b.parent_lineitem_id
) c ON b.id=c.entitytypeid AND b.lineitem_id=c.parent_lineitem_id
SET b.haveoutproductcount=IFNULL(c.in_qty,0);
delimiter;

UPDATE ld_salesorder a
LEFT JOIN ld_inventoryproductrel b ON a.salesorderid=b.id
SET b.balanceoutproductcount=IFNULL(b.quantity,0)-IFNULL(b.haveoutproductcount,0);
delimiter;


UPDATE ld_salesorder a
LEFT JOIN ld_inventoryproductrel b ON a.salesorderid=b.id
SET a.stockpresence=(	CASE 
												WHEN b.balanceoutproductcount<=0 THEN '全部出库' 
												WHEN b.haveoutproductcount>0 AND b.balanceoutproductcount>0 THEN '部分出库' 
												ELSE '未出库'
											END);

delimiter;
update ld_outboundorder set presence='未出库'
	where exists  (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 and deploy_value=0) 
and ifnull(approvestatus,'')<>'已批准';
delimiter;

update ld_outboundorder set presence='已出库'
	where exists  (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=48 and deploy_value=1) ;
delimiter;


select tabid into @tabid from ld_tab where `name` = 'Invoice';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid and fieldtype = 'main');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'PASSWORDVERFICATION','密码验证','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PASSWORDVERFICATION' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'PASSWORDVERFICATION','Password verification','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PASSWORDVERFICATION' and labeltype='fixedstr');
delimiter;

SET @tabid=6;
SET @blockid1=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_ACCOUNT_INFORMATION');
SET @blockid2=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_ACCOUNT_PRIMARYCONTACT' ORDER BY blockid LIMIT 1);
SET @blockid3=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_ACCOUNT_PRIMARYCONTACT' AND blockid>@blockid2 ORDER BY blockid LIMIT 1);
DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_blocks' AND Relateid=@blockid3;
DELETE FROM ld_blocks WHERE blockid=@blockid3;
UPDATE ld_field SET block=@blockid1 WHERE tabid=@tabid AND block=@blockid3;
-- 2019-03-01

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
UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);
delimiter;

UPDATE ld_version SET old_version='V7.6.9',current_version='V7.6.9',remark='V7.6.9-20190227',wx_version='V7.6.9';
delimiter;