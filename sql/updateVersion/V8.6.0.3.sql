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
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
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

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
BEGIN
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;

UPDATE ld_desk SET fieldlabel='无法生成二维码，可能还未配置相关功能。请联系管理员点击“微信小程序”按钮进行' WHERE labelbol IN ('THEREISNOQRCODEPLEASECONTACTANDSET','THEREISNOQRCODEPLEASECONTACTANDSET2') AND languagetype='zh';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','ANDOTHER','等','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ANDOTHER' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','ANDOTHER',' and ','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ANDOTHER' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_default`(in `tmp_tabname` varchar(50) , in `tmp_actionname` varchar(200))
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;

DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	SET @tabid=(select tabid from ld_tab  where name=`tmp_tabname`);

	set @operation = (SELECT actionid from ld_actionmapping where actionname = `tmp_actionname`);

	IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid and operation = @operation) THEN
		OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO
			SET @profileid=tmp_profileid;
INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT
    @profileid AS profileid,
    @tabid AS tabid,
    @operation,
    0,
    0
FROM ld_profile2standardpermissions a
         LEFT JOIN ld_tab b ON b.tabid=a.tabid
WHERE a.profileid=@profileid
  AND a.operation=@operation
    LIMIT 1;

SET @i=0;
UPDATE ld_profile2standardpermissions SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND profileid=@profileid ORDER BY sequence;

IF NOT EXISTS (SELECT 1 FROM ld_profile2tab WHERE tabid=@tabid AND profileid=@profileid) THEN
				INSERT INTO ld_profile2tab(profileid,tabid,permissions)
SELECT profileid,@tabid,IF(MIN(permissions)=0,1,0) FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid;
END IF;

			IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid AND permissions=0) THEN
UPDATE ld_profile2standardpermissions SET permissions=1 WHERE tabid=@tabid AND profileid=@profileid AND operation=0;
END IF;

FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;
END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_default('Events','Print');
CALL ldcrm_add_profile_for_default('Documents','Print');
CALL ldcrm_add_profile_for_default('PublicAnnouncement','Print');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','howtomaintrandepartanduserinfo4','4.点击继续将前往企业微信管理后台','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='howtomaintrandepartanduserinfo4' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','howtomaintrandepartanduserinfo4','4.Click to continue to go to the enterprise WeChat management backend','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='howtomaintrandepartanduserinfo4' and labeltype='fixedstr');
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_relatedlists_get_contactsmap`;
delimiter ||
CREATE PROCEDURE `ldcrm_relatedlists_get_contactsmap`(
)
BEGIN
	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_presence INT(1) DEFAULT 0;
	DECLARE tmp_actions VARCHAR(100) DEFAULT '';
	DECLARE tmp_mobile_presence INT(1) DEFAULT 0;
	DECLARE tmp_wx_presence INT(1) DEFAULT 0;
	DECLARE tmp_buttonstatus VARCHAR(20) DEFAULT '';
	DECLARE tmp_type VARCHAR(100) DEFAULT '';
	DECLARE tmp_related_coltable VARCHAR(100) DEFAULT '';


	DECLARE MYCUSOR CURSOR FOR
SELECT tabid,presence,actions,mobile_presence,type,related_coltable,wx_presence,buttonstatus FROM ld_relatedlists WHERE related_tabid=4 and label='Contacts';
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_tabid,tmp_presence,tmp_actions,tmp_mobile_presence,tmp_type,tmp_related_coltable,tmp_wx_presence,tmp_buttonstatus;
WHILE(tmp_tabid IS NOT NULL) DO
			SET @sequence=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=tmp_tabid);
			SET @mobile_sequence=(SELECT MAX(mobile_sequence) FROM ld_relatedlists WHERE tabid=tmp_tabid);
			SET @wx_sequence=(SELECT MAX(wx_sequence) FROM ld_relatedlists WHERE tabid=tmp_tabid);
			SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);

            INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,buttonstatus)
            SELECT @maxrelation_id+1,tmp_tabid,'-18','get_contactsmap',@sequence+1,'ContactsMap',tmp_presence,tmp_actions,tmp_mobile_presence,@mobile_sequence+1,tmp_type,tmp_related_coltable,tmp_wx_presence,@wx_sequence+1,tmp_buttonstatus FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=tmp_tabid AND label='ContactsMap' AND `name`='get_contactsmap' );
            FETCH MYCUSOR INTO tmp_tabid,tmp_presence,tmp_actions,tmp_mobile_presence,tmp_type,tmp_related_coltable,tmp_wx_presence,tmp_buttonstatus;

END WHILE;
CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_relatedlists_get_contactsmap();
DROP PROCEDURE IF EXISTS `ldcrm_relatedlists_get_contactsmap`;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ContactsMap','联系人图谱','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ContactsMap' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ContactsMap','ContactsMap','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ContactsMap' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_wx_config(name,description)
SELECT 'shopmp_bindtype','商城小程序' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_wx_config WHERE name = 'shopmp_bindtype' AND description='商城小程序');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELFSHOPQRCODE','商城小程序','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELFSHOPQRCODE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELFSHOPQRCODE',"Mall applet",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELFSHOPQRCODE' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','LBL_SHOP_MINI_SETTINGS1','商城设置', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_SHOP_MINI_SETTINGS1' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','LBL_SHOP_MINI_SETTINGS1','Shop Settings', 'jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'LBL_SHOP_MINI_SETTINGS1' AND labeltype = 'jspop' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh','APPIDNOEXIST','未获取到appld与appSecret，请联系管理员点击','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'APPIDNOEXIST' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','APPIDNOEXIST','Unable to obtain appld and appSecret.Please contact administrator to click ','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'APPIDNOEXIST' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','APPIDNOTCORRECT','Appld与appSecret数据错误，请联系管理员点击','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'APPIDNOTCORRECT' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','APPIDNOTCORRECT','Appld and AppSecret data errors, please contact administrator to click ','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'APPIDNOTCORRECT' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','ANDOTHER','等','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ANDOTHER' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','ANDOTHER',' and ','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ANDOTHER' and labeltype='fixedstr');
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','SERACHACCOUNT','搜索客户名称','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SERACHACCOUNT' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','SERACHACCOUNT','Search customer name','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SERACHACCOUNT' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','APPROVALTYPE','审批类型','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APPROVALTYPE' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','APPROVALTYPE',' approve type','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='APPROVALTYPE' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','ADDNEWCONTACTNUM','新增联系记录数','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ADDNEWCONTACTNUM' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','ADDNEWCONTACTNUM',' New contact record number','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ADDNEWCONTACTNUM' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','PRODUCTNUM','产品编号','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRODUCTNUM' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','PRODUCTNUM','Product number','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRODUCTNUM' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','JANUARY1','1月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='JANUARY1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','JANUARY1','January','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='JANUARY1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','FEBRUARY1','2月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FEBRUARY1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','FEBRUARY1','February','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FEBRUARY1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','MARCH1','3月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MARCH1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','MARCH1','March','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MARCH1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','APRIL1','4月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APRIL1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','APRIL1','April','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='APRIL1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','MAY1','5月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MAY1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','MAY1','May','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MAY1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','JUNE1','6月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='JUNE1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','JUNE1','June','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='JUNE1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','JULY1','7月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='JULY1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','JULY1','July','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='JULY1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','AUGUST1','8月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUGUST1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','AUGUST1','August','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUGUST1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','SEPTEMBER1','9月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SEPTEMBER1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','SEPTEMBER1','September','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SEPTEMBER1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','OCTOBER1','10月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OCTOBER1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','OCTOBER1','October','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OCTOBER1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','NOVEMBER1','11月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOVEMBER1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','NOVEMBER1','November','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOVEMBER1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','DECEMBER1','12月','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DECEMBER1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','DECEMBER1','December','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DECEMBER1' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','REIMBURSED','我报销的','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='REIMBURSED' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','REIMBURSED','I reimbursed','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='REIMBURSED' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','LEADSOURCE','线索来源','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LEADSOURCE' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','LEADSOURCE','Lead source','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LEADSOURCE' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','LEADDISTRYBUTION','线索分布','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LEADDISTRYBUTION' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','LEADDISTRYBUTION','Lead distribution','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LEADDISTRYBUTION' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','FAILUREANALYSIS','失败分析','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FAILUREANALYSIS' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','FAILUREANALYSIS','Failure analysis','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FAILUREANALYSIS' and labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','FAILUREANALYSIS1','线索失败原因分析','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FAILUREANALYSIS1' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','FAILUREANALYSIS1','Cause analysis of clue failure','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FAILUREANALYSIS1' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','REGCUST','注册客户数','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='REGCUST' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','REGCUST','Registered customers','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='REGCUST' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','CRECUSTNUM','授信客户数','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CRECUSTNUM' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','CRECUSTNUM','credit customers number','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CRECUSTNUM' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','FINANCECUSTNUM','融资客户数','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FINANCECUSTNUM' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','FINANCECUSTNUM','financing customers number','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FINANCECUSTNUM' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','lastyear','上年','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='lastyear' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','lastyear','lastyear','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='lastyear' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','nextyear','下年','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='nextyear' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','nextyear','nextyear','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='nextyear' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','NOSALESFUNNEL','没有销售漏斗数据','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOSALESFUNNEL' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','NOSALESFUNNEL','Sales funnel data are not available','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOSALESFUNNEL' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','TARGETAMOUNT','目标金额','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TARGETAMOUNT' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','TARGETAMOUNT','Target amount','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TARGETAMOUNT' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','AMOUNTCOMPLETED','完成金额','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AMOUNTCOMPLETED' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','AMOUNTCOMPLETED','Amount completed','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AMOUNTCOMPLETED' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','SNOWBEARMonth','月度','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SNOWBEARMonth' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','SNOWBEARMonth','MONTH','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SNOWBEARMonth' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','SNOWBEARQuarter','季度','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SNOWBEARQuarter' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','SNOWBEARQuarter','QUARTER','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SNOWBEARQuarter' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','AMOUNTRETURN','回款额','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AMOUNTRETURN' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','AMOUNTRETURN','Amount of return','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AMOUNTRETURN' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','TOP10','前10名','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TOP10' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','TOP10','Top 10','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TOP10' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','BOTTOM10','后10名','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BOTTOM10' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','BOTTOM10','Bottom 10','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BOTTOM10' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','REBACKAMOUNT','回款金额','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='REBACKAMOUNT' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','REBACKAMOUNT','Amount of money returned','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='REBACKAMOUNT' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','CLICKLOADMORE','点击加载更多','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CLICKLOADMORE' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','CLICKLOADMORE','Click to load more','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CLICKLOADMORE' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','TOTALNEWCUSTNUM','新建客户总数','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TOTALNEWCUSTNUM' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','TOTALNEWCUSTNUM','Total number of new customers','fixedstr' FROM DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TOTALNEWCUSTNUM' and labeltype='fixedstr');
delimiter;

set @disable_trigger = 'aa';
update ld_quotesdetail LEFT JOIN (
select sum(quantity) as haveoutordercount,ld_salesorderdetail.entitytype,entitytypeid,parent_lineitem_id from ld_salesorderdetail
inner join ld_salesorder on ld_salesorder.salesorderid=ld_salesorderdetail.id
where ld_salesorderdetail.entitytype='Quotes' and ld_salesorder.deleted=0
GROUP BY ld_salesorderdetail.entitytype,entitytypeid,parent_lineitem_id ) as 
tmp on tmp.entitytypeid=ld_quotesdetail.id and ld_quotesdetail.lineitem_id=tmp.parent_lineitem_id
set ld_quotesdetail.haveordercount=ifnull(tmp.haveoutordercount,0),
ld_quotesdetail.balanceordercount=ld_quotesdetail.quantity-ifnull(tmp.haveoutordercount,0);
SET @disable_triggers=NULL;
delimiter;

select tabid into @tabid from ld_tab  where name='VisualAnalysis';
update ld_tranlabel set fieldlabel = '管理驾驶舱' where languagetype = 'zh' and trantable = 'ld_tab' and tabid = @tabid and relateid=@tabid and fieldlabel = '可视化分析';
update ld_tranlabel set fieldlabel = 'The Cockpit' where languagetype = 'en' and trantable = 'ld_tab' and tabid = @tabid and relateid=@tabid and fieldlabel = 'Visualization Analysis';
delimiter;

drop PROCEDURE  if EXISTS update_campaigns_print;
delimiter ||
create PROCEDURE update_campaigns_print
(
var_tabid int(10),
new_actionid int(10),
locate_actionid int(10),
related_actionid int(10)
)
BEGIN
	declare var_profileid int(19);
	declare tmp_sequence int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT profileid from ld_profile;
	declare continue handler  for not   found  SET done =1;
	
	if not EXISTS (SELECT * from ld_profileallpermission where tabid = var_tabid and operation = new_actionid) then
			set tmp_sequence = (SELECT sequence from ld_profileallpermission where tabid = var_tabid and operation = locate_actionid);
			UPDATE ld_profileallpermission set sequence = sequence+1 where tabid = var_tabid  and sequence >= tmp_sequence;
			INSERT into ld_profileallpermission(tabid,operation,sequence) value(var_tabid,new_actionid,tmp_sequence);
	end if;

	open cur1;
	loop1: while  done<>1 DO
				Fetch cur1 into var_profileid;

        IF NOT EXISTS(SELECT 1 from ld_profile2standardpermissions where tabid = var_tabid and profileid = var_profileid and operation = new_actionid) 
						and EXISTS(SELECT 1 from ld_profile2standardpermissions where tabid = var_tabid and profileid = var_profileid and operation = related_actionid and permissions = 0) THEN
						INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) value(var_profileid,var_tabid,new_actionid,0,30);
				end if;
	end while loop1;
	close cur1;
end ||
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'Campaigns');
SET @print_actionid = (SELECT actionid from ld_actionmapping where actionname = 'Print');
SET @detail_actionid = (SELECT actionid from ld_actionmapping where actionname = 'DetailView');
SET @customview_actionid = (SELECT actionid from ld_actionmapping where actionname = 'CustomView');
call update_campaigns_print(@tabid,@print_actionid,@customview_actionid,@detail_actionid);
drop PROCEDURE  if EXISTS update_campaigns_print;
delimiter;
update ld_desk set Labeltype = 'jspop' where languagetype = 'zh' and labelbol = 'suggestedsize145x40px' ;
update ld_desk set Labeltype = 'jspop' where languagetype = 'en' and labelbol = 'suggestedsize145x40px';
delimiter;
update ld_desk set Labeltype = 'jspop' where languagetype = 'zh' and labelbol = 'suggestedsize' ;
update ld_desk set Labeltype = 'jspop' where languagetype = 'en' and labelbol = 'suggestedsize';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Uploadpictures','上传图片','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Uploadpictures' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Uploadpictures',"Upload pictures",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Uploadpictures' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Choosepictures','选择图片','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Choosepictures' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Choosepictures',"Choose pictures",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Choosepictures' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Resetpictures','复位','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Resetpictures' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Resetpictures',"Reset",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Resetpictures' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Rotatepictures','旋转','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Rotatepictures' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Rotatepictures',"Rotate",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Rotatepictures' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Previewpictures','预览图片：','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Previewpictures' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Previewpictures',"Preview:",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Previewpictures' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILEUPLOADPROBLEMS','上传失败，请重试！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FILEUPLOADPROBLEMS' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILEUPLOADPROBLEMS',"Problems in file upload. Please try again!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FILEUPLOADPROBLEMS' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ClickToViewDetail','点击查看详情','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ClickToViewDetail' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ClickToViewDetail','ClickToViewDetail','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ClickToViewDetail' and Labeltype='fixedstr');
delimiter;


CALL AddColumn('ld_workflow_actions','api_receive_msg','varchar',20,'no');
ALTER TABLE ld_workflow_actions ALTER COLUMN api_receive_msg SET DEFAULT 'no';
UPDATE ld_workflow_actions SET api_receive_msg='no' WHERE api_receive_msg IS NULL OR api_receive_msg = '';
delimiter;
CALL AddColumn('ld_workflow_api_parameter','createdtime','datetime','',NULL);
ALTER TABLE ld_workflow_api_parameter MODIFY COLUMN createdtime datetime DEFAULT CURRENT_TIMESTAMP;
delimiter;

CALL AddColumn('ld_workflow_api_parameter','parameter_description','varchar',255,NULL);
CALL AddColumn('ld_workflow_api_parameter','workflow_action_id','int',11,'');
ALTER TABLE ld_workflow_api_parameter MODIFY COLUMN workflow_action_id INT(11) DEFAULT 0 AFTER workflow_id;
delimiter;

UPDATE ld_workflow_api_parameter AS api INNER JOIN ld_workflow_actions AS action ON api.workflow_id = action.workflow_id
    SET api.workflow_action_id=action.id WHERE IFNULL(api.workflow_action_id,0) = 0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InputParameter','输入参数','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InputParameter' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InputParameter','Input Parameter','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InputParameter' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ParametricDescription','参数描述','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ParametricDescription' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ParametricDescription','Parametric Description','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ParametricDescription' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ParametricDescription','参数描述','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ParametricDescription' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ParametricDescription','Parametric Description','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ParametricDescription' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReturnState','返回状态','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReturnState' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReturnState','Return State','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReturnState' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StatusCode','状态码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='StatusCode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','StatusCode','Status Code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='StatusCode' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','StatusCode','状态码','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='StatusCode' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','StatusCode','Status Code','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='StatusCode' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StatusDescription','状态描述','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='StatusDescription' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','StatusDescription','Status Description','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='StatusDescription' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','StatusDescription','状态描述','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='StatusDescription' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','StatusDescription','Status Description','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='StatusDescription' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReceiveReturnStatusAndPrompt','是否接收返回状态和提示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReceiveReturnStatusAndPrompt' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReceiveReturnStatusAndPrompt','Return State','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReceiveReturnStatusAndPrompt' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CallingAPIWorkflow','正在调用工作流API...','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CallingAPIWorkflow' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CallingAPIWorkflow','Calling API workflow...','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CallingAPIWorkflow' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Accounts','{$Accounts.Accounts}','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Accounts' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Accounts','{$Accounts.Accounts}','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Accounts' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Contacts','{$Contacts.Contacts} ','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Contacts' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Contacts','{$Contacts.Contacts} ','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Contacts' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RegistrationNotAllowed','{$Accounts.Accounts}已存在，不允许注册！','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RegistrationNotAllowed' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RegistrationNotAllowed','{$Accounts.Accounts} already exists, registration not allowed!','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RegistrationNotAllowed' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RegisterNewContact','是否注册为新{$Contacts.Contacts}？','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RegisterNewContact' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RegisterNewContact','Would you like to register as a new {$Contacts.Contacts}?','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RegisterNewContact' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RegisterNewAccount','是否注册为新{$Accounts.Accounts}？','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RegisterNewAccount' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RegisterNewAccount','Would you like to register as a new {$Accounts.Accounts}?','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RegisterNewAccount' and labeltype='fuwu');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VerificationCodeNotCompleted','请先完成滑动验证','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VerificationCodeNotCompleted' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VerificationCodeNotCompleted','Please complete the sliding verification first','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VerificationCodeNotCompleted' and labeltype='fuwu');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VerificationPass','验证成功','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VerificationPass' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VerificationPass','Verification passed','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VerificationPass' and labeltype='fuwu');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SlidingVerification','请按住滑块，拖动到最右边','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SlidingVerification' and labeltype='fuwu');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SlidingVerification','Please slide to verify','fuwu' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SlidingVerification' and labeltype='fuwu');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AppAccountBindObj','小程序账号绑定对象','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AppAccountBindObj' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AppAccountBindObj','Binding object for Applet accounts','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AppAccountBindObj' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WhetherAllowToCreateNew','登录验证是否允许创建新','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherAllowToCreateNew' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WhetherAllowToCreateNew','Whether login verification is allowed to create new','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherAllowToCreateNew' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WhetherToUseCode','验证是否使用短信验证码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherToUseCode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WhetherToUseCode','Whether to enable SMS in verification of','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherToUseCode' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RegWhetherToUseCode','注册验证是否使用短信验证码','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='RegWhetherToUseCode' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RegWhetherToUseCode','Whether to enable SMS in verification of registration','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='RegWhetherToUseCode' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LoginWhetherToUseCode','登录验证是否使用短信验证码','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='LoginWhetherToUseCode' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LoginWhetherToUseCode','Whether to enable SMS in verification of login','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='LoginWhetherToUseCode' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WhetherAllowToCreateAccount','登录验证是否允许创建新{$Accounts.Accounts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherAllowToCreateAccount' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WhetherAllowToCreateAccount','Whether login verification is allowed to create new {$Accounts.Accounts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherAllowToCreateAccount' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WhetherAllowToCreateContact','登录验证是否允许创建新{$Contacts.Contacts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherAllowToCreateContact' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WhetherAllowToCreateContact','Whether login verification is allowed to create new {$Contacts.Contacts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherAllowToCreateContact' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INTERFACE','界面','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INTERFACE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INTERFACE','interface','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INTERFACE' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CustomerExistCantReg','{$Accounts.Accounts}已存在，不允许注册！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomerExistCantReg' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CustomerExistCantReg','The {$Accounts.Accounts} already exists, registration is not allowed','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomerExistCantReg' and Labeltype='fixedstr' and languagetype='en');
delimiter;
UPDATE ld_wx_config SET switch = 'Login' WHERE `name`="weixinmp_bindtype";
UPDATE ld_wx_config SET para_content = '{"bindtype":"Contacts","allowedtocreate":"yes","useverificationcode":"no","appid":"wxb4cc43e5a12f5687","secret":"991ee9c028da1da860a44d7a0767b82e"}' 
WHERE `name`="weixinmp_bindtype";
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_refresh_advance_stage`;
delimiter ||
CREATE PROCEDURE `ldcrm_refresh_advance_stage`()
BEGIN

	DECLARE tmp_tablename varchar(50) DEFAULT '';
	DECLARE tmp_fieldname varchar(100) DEFAULT '';
	DECLARE tmp_dir_tablename varchar(50) DEFAULT '';
	DECLARE tmp_entityidfield varchar(150) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR
        SELECT
            (SELECT tablename FROM ld_field a WHERE tabid=ld_settings_advance.tabid AND columnname='createdtime') AS `tablename`,
            ld_field.`columnname` ,
            ld_field.`tablename` as `dir_tablename`,
            ld_entityname.entityidfield
        FROM ld_settings_advance
        LEFT JOIN ld_field ON ld_field.tabid = ld_settings_advance.tabid AND ld_field.fieldname = ld_settings_advance.module_field
        LEFT JOIN ld_entityname on ld_entityname.tabid = ld_settings_advance.tabid
        WHERE (`enable` = 'yes' or `showadvancemobile` = 'yes');
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tablename = NULL,tmp_fieldname = NULL;

	set @disable_triggers = 'ldcrm_refresh_advance_stage';

    OPEN MYCUSOR;
    FETCH MYCUSOR INTO tmp_dir_tablename,tmp_fieldname,tmp_tablename,tmp_entityidfield;
    WHILE(tmp_tablename IS NOT NULL) DO
    
        SET @update_sql = (
                    CASE
                        WHEN tmp_tablename = tmp_dir_tablename THEN CONCAT("UPDATE ",tmp_dir_tablename," SET advance_stage = ",tmp_fieldname," WHERE deleted=0 AND advance_stage <> ",tmp_fieldname,";")
                        ELSE CONCAT("UPDATE ",tmp_dir_tablename," LEFT JOIN ",tmp_tablename," ON ",tmp_tablename,".",tmp_entityidfield," = ",tmp_dir_tablename,".",tmp_entityidfield," SET advance_stage = ",tmp_fieldname," WHERE deleted=0 AND advance_stage <> ",tmp_fieldname,";")
                    END
                );
        SET @update_sql=REPLACE(@update_sql,'ld_faqscf.id', 'ld_faqscf.faqid');
        
        PREPARE stmtt FROM @update_sql;
        EXECUTE stmtt;
        DEALLOCATE PREPARE stmtt;

        FETCH MYCUSOR INTO tmp_dir_tablename,tmp_fieldname,tmp_tablename,tmp_entityidfield;
    END WHILE;
    CLOSE MYCUSOR;

    set @disable_triggers = NULL;

END ||
delimiter;

CALL ldcrm_refresh_advance_stage();
delimiter;

update ld_desk SET fieldlabel = 'Please slide to verify' WHERE languagetype='en' and labelbol='SlidingVerification' and labeltype='fuwu';
delimiter;

UPDATE ld_desk SET fieldlabel='您的密码连续输错{n}次已锁定，请联系管理员在成员管理中解锁账号或{minute}分钟后重试！' WHERE languagetype='zh' AND labeltype='fixedstr' AND labelbol='AdminUnlockUser';
UPDATE ld_desk SET fieldlabel='Your password has been locked due to {n} consecutive incorrect entries. Please contact the admin to unlock the account in member management or try again in {minute} minutes! ' WHERE languagetype='en' AND labeltype='fixedstr' AND labelbol='AdminUnlockUser';
delimiter;

UPDATE ld_desk SET fieldlabel='您的工商查询接口已到期，请联系服务商续费开通！' WHERE labelbol='keyexpired' AND languagetype='zh' AND Labeltype='jspop';
delimiter;

drop PROCEDURE  if EXISTS share_salesgoal_normaluser;
delimiter ||
create PROCEDURE share_salesgoal_normaluser
(
)
BEGIN
	declare var_targeid int(19);
	declare tmp_sequence int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT targetid from ld_salestarget_basic where targetname in ('paymentamount','contractamount','accountsnumber','invoiceamount','outboundorderamount');
	declare continue handler  for not   found  SET done =1;

	open cur1;
	loop1: while  done<>1 DO
				Fetch cur1 into var_targeid;
				call share_all_user(var_targeid);
	end while loop1;
	close cur1;
end ||
delimiter;

drop PROCEDURE  if EXISTS share_all_user;
delimiter ||
create PROCEDURE share_all_user
(
var_targeid int(19)
)
BEGIN
	declare var_userid int(19);
	declare tmp_sequence int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT id from ld_users;
	declare continue handler  for not   found  SET done =1;
	open cur1;
	loop1: while  done<>1 DO
				Fetch cur1 into var_userid;
				IF NOT EXISTS (SELECT 1 from ld_tabshare where crmid = var_targeid and Shareuserid = var_userid) THEN
					INSERT into ld_tabshare(crmid,viewuserid,Shareuserid) value(var_targeid,1,var_userid);
				end if;
	end while loop1;
	close cur1;
end ||
delimiter;

call share_salesgoal_normaluser();
drop PROCEDURE  if EXISTS share_salesgoal_normaluser;
drop PROCEDURE  if EXISTS share_all_user;
delimiter;

CALL addtableIndex('ld_cashbill','smownerid','smownerid');
delimiter;
-- 2023-08-06

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WorkReportList');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid LIMIT 1);
SET @columnname='sendlog_workdate'; 
SET @fieldname='sendlog_workdate'; 
SET @zh='汇报日期'; 
SET @en='Report date'; 
SET @uitype=21; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='textarea';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'no';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,0,NULL,180,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL AddColumn(@tablename,@columnname,'text','','');
delimiter;
select tabid into @tabid from ld_tab where `name`='SalesOrder';
select fieldlabel into @fieldlabel from ld_tranlabel where languagetype='zh' and tabid=@tabid and trantable='ld_tab';
update ld_homestuffdetail set
advance_demand=concat('[{"groupid":"1","columnname":"ld_cashbill2paymentplan:entitytype:entitytype:Products_fieldlabel:V","comparator":"e","value":"',@fieldlabel,'","columncondition":""}]'),
advance_demand_groups='[null,{"groupcondition":""}]'
where stufflabel='NewSalesOrderReceipts';
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceContracts';
select fieldlabel into @fieldlabel from ld_tranlabel where languagetype='zh' and tabid=@tabid and trantable='ld_tab';
update ld_homestuffdetail set
advance_demand=concat('[{"groupid":"1","columnname":"ld_cashbill2paymentplan:entitytype:entitytype:Products_fieldlabel:V","comparator":"e","value":"',@fieldlabel,'","columncondition":""}]'),
advance_demand_groups='[null,{"groupcondition":""}]'
where stufflabel='NewServiceContractsReceipts';
delimiter;

select tabid into @tabid from ld_tab where `name`='PaymentPlan';
select fieldlabel into @fieldlabel from ld_tranlabel where languagetype='zh' and tabid=@tabid and trantable='ld_tab';
update ld_homestuffdetail set
advance_demand=concat('[{"groupid":"1","columnname":"ld_cashbill2paymentplan:entitytype:entitytype:Products_fieldlabel:V","comparator":"e","value":"',@fieldlabel,'","columncondition":""}]'),
advance_demand_groups='[null,{"groupcondition":""}]'
where stufflabel='NewPaymentPlanCashBillAmount';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','APICall','调用API','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='APICall' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','APICall','API Call','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='APICall' and Labeltype='jspop');
delimiter;

UPDATE ld_desk SET fieldlabel='正在调用工作流API，请稍候……' where labelbol='CallingAPIWorkflow' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='Calling workflow API, please wait……' where labelbol='CallingAPIWorkflow' and languagetype='en' and Labeltype='jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReturnStateTip',"调用API后接收返回的状态码，并显示相应的提示信息：
{
  'err_code': 0
}",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReturnStateTip' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReturnStateTip',"After calling the API show the error information:
{
  'err_code': 0
}",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReturnStateTip' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','penetrate','穿透','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='penetrate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','penetrate','penetrate','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='penetrate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_relatedlists_seq SET id = (SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetModuleHyperlinkFields','模块超链接字段设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetModuleHyperlinkFields' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetModuleHyperlinkFields','Module Hyperlink Fields Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetModuleHyperlinkFields' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SourseSupports','来源支持以下格式：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SourseSupports' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SourseSupports','The source supports the following formats:','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SourseSupports' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SingleIPFormat','单个IP：192.168.0.1或101.88.24.215','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SingleIPFormat' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SingleIPFormat','Single IP: 192.168.0.1 or 101.88.24.215','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SingleIPFormat' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CIDRFormat','CIDR：192.168.1.0/24','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CIDRFormat' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CIDRFormat','CIDR：192.168.1.0/24','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CIDRFormat' and Labeltype='fixedstr' and languagetype='en');
delimiter;
UPDATE ld_desk set fieldlabel='登录策略' WHERE labelbol='LOGINPOLICY' and languagetype='zh';
delimiter;

DROP PROCEDURE IF EXISTS `reset_picklist_minusjobtype`;
delimiter ||
CREATE  PROCEDURE `reset_picklist_minusjobtype`(
)
BEGIN
	
	SET @this_listid=(SELECT listid FROM ld_picklist_set WHERE listname='minusjobtype' LIMIT 1);
	IF (SELECT COUNT(1) FROM ld_minusjobbill WHERE deleted=0)<10 AND NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@this_listid AND listvalue IN ('年假','事假','病假')) THEN
		DELETE FROM ld_picklist_values WHERE listid=@this_listid;

		SET @i=0;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'调休',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'年假',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'事假',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'迟到',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'早退',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'婚假',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'病假',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'产假',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'丧假',@i:=@i+1;
		INSERT INTO ld_picklist_values(listid,listvalue,sequence) SELECT @this_listid,'特殊报钟',@i:=@i+1;
	END IF;

end ||
delimiter;

CALL reset_picklist_minusjobtype();
DROP PROCEDURE IF EXISTS `reset_picklist_minusjobtype`;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVALIDKEY','无效的KEY','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='INVALIDKEY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVALIDKEY','Invalid Key','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='INVALIDKEY' and Labeltype='jspop' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVALIDKEY','无效的KEY','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INVALIDKEY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVALIDKEY','Invalid Key','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INVALIDKEY' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2023-08-09

drop PROCEDURE  if EXISTS delete_wrong_signin_relatedinfo;
delimiter ||
create PROCEDURE delete_wrong_signin_relatedinfo
(
)
BEGIN
	declare var_sourcelist_fieldid int(19);
  declare var_signaddress_fieldid int(19);
	declare var_entityaddress_fieldid int(19);
	declare var_sign_tabid int(19);
	
	set var_sign_tabid = (SELECT tabid from ld_tab where `name` = 'Singin');
	set var_sourcelist_fieldid = (SELECT fieldid from ld_field where tabid = var_sign_tabid and columnname = 'source_list');
	set var_signaddress_fieldid = (SELECT fieldid from ld_field where tabid = var_sign_tabid and columnname = 'address');
	set var_entityaddress_fieldid = (SELECT fieldid from ld_field where tabid = var_sign_tabid and columnname = 'entityaddress');
	IF EXISTS(SELECT 1 from ld_related_field where trigger_fieldid = var_sourcelist_fieldid and effect_fieldid = var_signaddress_fieldid) 
		and EXISTS(SELECT 1 from ld_related_field where trigger_fieldid = var_sourcelist_fieldid and effect_fieldid = var_entityaddress_fieldid) THEN
			DELETE from ld_related_field where trigger_fieldid = var_sourcelist_fieldid and effect_fieldid = var_signaddress_fieldid;
	END IF;
end ||
delimiter;

call delete_wrong_signin_relatedinfo();
drop PROCEDURE  if EXISTS delete_wrong_signin_relatedinfo;
delimiter;




drop PROCEDURE  if EXISTS `reset_homestufdetail_dateviewrange`;
delimiter ||
create PROCEDURE reset_homestufdetail_dateviewrange
(
)
BEGIN
    select count(1) into @counts from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER';
    if @counts<=0 then
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewAccounts') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_contactdetails:createdtime:createdtime:Contacts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_contactdetails:smownerid:assigned_user_id:Contacts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewContacts')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewSalesOrderCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewServiceContractsCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewSalesOrderAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewServiceContractsAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractCount') and compute_columns like 'ld_salesorder.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractCount') and compute_columns like 'ld_servicecontracts.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractAmount') and compute_columns like 'ld_salesorder.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractAmount') and compute_columns like 'ld_servicecontracts.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_invoice:invoicedate:invoicedate:Invoice_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewInvoiceAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewOutboundOrderAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewCashBillAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPotentialsCount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPotentialsAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='AdvancePotentialsAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewSignCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_leads:createdtime:createdtime:Leads_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewLeadsCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewHelpDeskCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewCashBillCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewOutboundOrderCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_invoice:invoicedate:invoicedate:Invoice_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewInvoiceCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPurchaseOrderCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPurchaseOrderAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewSalesOrderReceipts')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewServiceContractsReceipts') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_quotes:createdtime:createdtime:Quotes_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_quotes:smownerid:assigned_user_id:Quotes_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewQuotesCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_quotes:createdtime:createdtime:Quotes_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_quotes:smownerid:assigned_user_id:Quotes_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewQuotesAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPaymentPlanCashBillAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='LeadUgradeToCustomerCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_expense:expensedate:expensedate:Expense_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_expense:smownerid:assigned_user_id:Expense_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='ExpensesAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_commission:expensedate:expensedate:Commission_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_commission:smcreatorid:smcreatorid:Commission_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='CommissionsAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SalesorderBalanceReceivable') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='ServiceContractBalanceReceivable')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractBalanceReceivable') and compute_columns like 'ld_salesorder.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractBalanceReceivable') and compute_columns like 'ld_servicecontracts.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='PurchaseOrderPayBalance')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='LeadUgradeToPotentials') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;

        UPDATE ld_homestuffdetail SET `viewrange`=(case when `daterange` is null then 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_fieldlabel:V' else `daterange` end),
                              `daterange`=(case when `viewrange` is null then 'ld_contactrecords:contactdate:contactdate:ContactRecords_fieldlabel:DT' else `viewrange` end)
        WHERE (`stufflabel`='NewContactRecords')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;

        UPDATE ld_homestuffdetail SET `viewrange`=(case when `daterange` is null then 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V'else `daterange` end),
                                      `daterange`=(case when `viewrange` is null then 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT' else `viewrange` end)
        WHERE (`stufflabel`='NewServiceChargeNums')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;

END IF;
end ||
delimiter;
call reset_homestufdetail_dateviewrange();
drop PROCEDURE  if EXISTS reset_homestufdetail_dateviewrange;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDCUSTOMDRAGONTIGER','新增自定义龙虎榜','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDCUSTOMDRAGONTIGER','Add a custom dragon and tiger list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER' and Labeltype='fixedstr' and languagetype='en');
delimiter;


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

UPDATE ld_version SET old_version='V8.6.0.3',current_version='V8.6.0.3',remark='V8.6.0.3-20230809',wx_version='V8.6.0.3';
delimiter;