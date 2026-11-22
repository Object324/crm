insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEENTERTHECORRECT','请输入正确的','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASEENTERTHECORRECT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEENTERTHECORRECT',"Please enter the correct ",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASEENTERTHECORRECT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PERSONCHARGEREALNAME','负责人真实姓名','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PERSONCHARGEREALNAME' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PERSONCHARGEREALNAME',"Real name",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PERSONCHARGEREALNAME' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PERSONCHARGEREALNAME','负责人真实姓名','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PERSONCHARGEREALNAME' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PERSONCHARGEREALNAME',"Real name",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PERSONCHARGEREALNAME' and labeltype='fixedstr');
delimiter;



INSERT INTO ld_currencies(currency_name,currency_code,currency_symbol,description)
SELECT 'Macau Dollar','MOP','MOP$','澳门元' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_currencies WHERE currency_name='Macau Dollar');

UPDATE ld_currencies_seq SET id=(SELECT MAX(currencyid) FROM ld_currencies);
delimiter;


DROP FUNCTION IF EXISTS `func_changeToHalfAngle`;
delimiter ||
CREATE FUNCTION `func_changeToHalfAngle`(in_str TEXT) RETURNS TEXT
BEGIN  

	DECLARE out_str TEXT;

	-- 标点符号
	SET in_str=REPLACE(in_str,'，',',');
	SET in_str=REPLACE(in_str,'＜','<');

	SET in_str=REPLACE(in_str,'．','.');
	SET in_str=REPLACE(in_str,'＞','>');

	SET in_str=REPLACE(in_str,'／','/');
	SET in_str=REPLACE(in_str,'？','?');

	SET in_str=REPLACE(in_str,'：',':');
	SET in_str=REPLACE(in_str,'；',';');

	SET in_str=REPLACE(in_str,'＇',"'");
	SET in_str=REPLACE(in_str,'＂','"');

	SET in_str=REPLACE(in_str,'［','[');
	SET in_str=REPLACE(in_str,'｛','{');

	SET in_str=REPLACE(in_str,'］',']');
	SET in_str=REPLACE(in_str,'｝','}');

	SET in_str=REPLACE(in_str,'＼','\\');
	SET in_str=REPLACE(in_str,'｜','|');

	SET in_str=REPLACE(in_str,'·','`');
	SET in_str=REPLACE(in_str,'～','~');

	SET in_str=REPLACE(in_str,'！','!');
	SET in_str=REPLACE(in_str,'＠','@');
	SET in_str=REPLACE(in_str,'＃','#');
	SET in_str=REPLACE(in_str,'＄','$');
	SET in_str=REPLACE(in_str,'％','%');
	SET in_str=REPLACE(in_str,'＾','^');
	SET in_str=REPLACE(in_str,'＆','&');
	SET in_str=REPLACE(in_str,'＊','*');
	SET in_str=REPLACE(in_str,'（','(');
	SET in_str=REPLACE(in_str,'）',')');

	SET in_str=REPLACE(in_str,'－','-');
	SET in_str=REPLACE(in_str,'＿','_');

	SET in_str=REPLACE(in_str,'＝','=');
	SET in_str=REPLACE(in_str,'＋','+');
	SET in_str=REPLACE(in_str,'／','/');

	SET in_str=REPLACE(in_str,'……','^');
	SET in_str=REPLACE(in_str,'￥','$');


	-- 数字
	SET in_str=REPLACE(in_str,'１','1');
	SET in_str=REPLACE(in_str,'２','2');
	SET in_str=REPLACE(in_str,'３','3');
	SET in_str=REPLACE(in_str,'４','4');
	SET in_str=REPLACE(in_str,'５','5');
	SET in_str=REPLACE(in_str,'６','6');
	SET in_str=REPLACE(in_str,'７','7');
	SET in_str=REPLACE(in_str,'８','8');
	SET in_str=REPLACE(in_str,'９','9');
	SET in_str=REPLACE(in_str,'０','0');

	SET in_str=REPLACE(in_str,'Ａ','A');
	SET in_str=REPLACE(in_str,'Ｂ','B');
	SET in_str=REPLACE(in_str,'Ｃ','C');
	SET in_str=REPLACE(in_str,'Ｄ','D');
	SET in_str=REPLACE(in_str,'Ｅ','E');
	SET in_str=REPLACE(in_str,'Ｆ','F');
	SET in_str=REPLACE(in_str,'Ｇ','G');

	SET in_str=REPLACE(in_str,'Ｈ','H');
	SET in_str=REPLACE(in_str,'Ｉ','I');
	SET in_str=REPLACE(in_str,'Ｊ','J');
	SET in_str=REPLACE(in_str,'Ｋ','K');
	SET in_str=REPLACE(in_str,'Ｌ','L');
	SET in_str=REPLACE(in_str,'Ｍ','M');
	SET in_str=REPLACE(in_str,'Ｎ','N');

	SET in_str=REPLACE(in_str,'Ｏ','O');
	SET in_str=REPLACE(in_str,'Ｐ','P');
	SET in_str=REPLACE(in_str,'Ｑ','Q');
	SET in_str=REPLACE(in_str,'Ｒ','R');
	SET in_str=REPLACE(in_str,'Ｓ','S');
	SET in_str=REPLACE(in_str,'Ｔ','T');

	SET in_str=REPLACE(in_str,'Ｕ','U');
	SET in_str=REPLACE(in_str,'Ｖ','V');
	SET in_str=REPLACE(in_str,'Ｗ','W');
	SET in_str=REPLACE(in_str,'Ｘ','X');
	SET in_str=REPLACE(in_str,'Ｙ','Y');
	SET in_str=REPLACE(in_str,'Ｚ','Z');

	SET in_str=REPLACE(in_str,'ａ','a');
	SET in_str=REPLACE(in_str,'ｂ','b');
	SET in_str=REPLACE(in_str,'ｃ','c');
	SET in_str=REPLACE(in_str,'ｄ','d');
	SET in_str=REPLACE(in_str,'ｅ','e');
	SET in_str=REPLACE(in_str,'ｆ','f');
	SET in_str=REPLACE(in_str,'ｇ','g');

	SET in_str=REPLACE(in_str,'ｈ','h');
	SET in_str=REPLACE(in_str,'ｉ','i');
	SET in_str=REPLACE(in_str,'ｊ','j');
	SET in_str=REPLACE(in_str,'ｋ','k');
	SET in_str=REPLACE(in_str,'ｌ','l');
	SET in_str=REPLACE(in_str,'ｍ','m');
	SET in_str=REPLACE(in_str,'ｎ','n');

	SET in_str=REPLACE(in_str,'ｏ','o');
	SET in_str=REPLACE(in_str,'ｐ','p');
	SET in_str=REPLACE(in_str,'ｑ','q');
	SET in_str=REPLACE(in_str,'ｒ','r');
	SET in_str=REPLACE(in_str,'ｓ','s');
	SET in_str=REPLACE(in_str,'ｔ','t');

	SET in_str=REPLACE(in_str,'ｕ','u');
	SET in_str=REPLACE(in_str,'ｖ','v');
	SET in_str=REPLACE(in_str,'ｗ','w');
	SET in_str=REPLACE(in_str,'ｘ','x');
	SET in_str=REPLACE(in_str,'ｙ','y');
	SET in_str=REPLACE(in_str,'ｚ','z');
	
	SET in_str=REPLACE(in_str,'　','');
	SET in_str=REPLACE(in_str,' ','');
	
	SET out_str=in_str;
	RETURN(out_str);

END || 
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_account_validatasaverule`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_account_validatasaverule`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_validatasavemain WHERE rulename='客户名称去重(忽略全角和半角)' AND module='Accounts') THEN
		INSERT INTO `ld_validatasavemain` (
			`rulename`, 
			`module`, 
			`status`, 
			`actionprevent`, 
			`tipzhtype`, 
			`tipzh`, 
			`tipentype`, 
			`tipen`, 
			`validatasavetype`, 
			`isshowlist`, 
			`conditiongroup`, 
			`validataapplication`, 
			`relatedtable`, 
			`sequence`
		) 
		SELECT
			'客户名称去重(忽略全角和半角)', 
			'Accounts', 
			'inactive',
			'yes', 
			'sql', 
			'SELECT\nGROUP_CONCAT(tips SEPARATOR \'\\r\\n\') AS tips\nFROM (\nSELECT\nCONCAT(\n(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname=\'accountname\') AND languagetype=\'zh\' AND trantable=\'ld_field\' LIMIT 1),\n\'『\',\na.accountname,\n\'』已存在，当前\',\n(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname=\'smownerid\') AND languagetype=\'zh\' AND trantable=\'ld_field\' LIMIT 1),\n\'『\',\nb.last_name,\n\'』\'\n) AS tips\nFROM ld_account a\nLEFT JOIN ld_users b ON b.id=a.smownerid  \nWHERE a.deleted=0 \nAND func_changeToHalfAngle(a.accountname)=func_changeToHalfAngle(\'{ld_account.accountname}\')\nGROUP BY a.accountname,a.smownerid\n) a', 
			'sql', 
			'SELECT\nGROUP_CONCAT(tips SEPARATOR \'\\r\\n\') AS tips\nFROM (\nSELECT\nCONCAT(\n(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname=\'accountname\') AND languagetype=\'zh\' AND trantable=\'ld_field\' LIMIT 1),\n\'『\',\na.accountname,\n\'』已存在，当前\',\n(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname=\'smownerid\') AND languagetype=\'zh\' AND trantable=\'ld_field\' LIMIT 1),\n\'『\',\nb.last_name,\n\'』\'\n) AS tips\nFROM ld_account a\nLEFT JOIN ld_users b ON b.id=a.smownerid  \nWHERE a.deleted=0 \nAND func_changeToHalfAngle(a.accountname)=func_changeToHalfAngle(\'{ld_account.accountname}\')\nGROUP BY a.accountname,a.smownerid\n) a', 
			'php', 
			'yes', 
			'[null,{\"groupcondition\":\"\"}]', 
			'create,edit', 
			'ld_field', 
			IFNULL((SELECT MAX(sequence)+1 FROM ld_validatasavemain WHERE module='Accounts'),1);

		SET @this_mainid=(SELECT id FROM ld_validatasavemain WHERE rulename='客户名称去重(忽略全角和半角)' AND module='Accounts' ORDER BY id DESC);

		INSERT INTO `ld_validatasave` (
		`module`, 
		`relatedtable`, 
		`fieldname`, 
		`comparator`, 
		`formulavalue`, 
		`comparatordescription`, 
		`rulename`, 
		`status`, 
		`validatacheckbutton`, 
		`allowsave`, 
		`tipzh`, 
		`tipen`, 
		`funtype`, 
		`fungroupdbcolumns`, 
		`fungrouphiddencolumns`, 

		`sequence`, 
		`validatasavetype`, 
		`isshowlist`, 
		`validatasavemainid`, 
		`conditiongroupid`, 
		`valid_condition`
	) 
	SELECT 
		'Accounts', 
		'ld_field', 
		'SELECT\n	CASE\n		WHEN EXISTS (SELECT 1 FROM ld_account WHERE deleted=0 AND func_changeToHalfAngle(accountname)=func_changeToHalfAngle(\'{ld_account.accountname}\') \n						AND (CASE WHEN \'{Record.ID}\'>0 THEN accountid<>\'{Record.ID}\' ELSE 1=1 END)) THEN \'yes\'\n		ELSE \'no\'\n	END AS tmp_value', 
		'e', 
		NULL, 
		NULL, 
		NULL, 
		'active', 
		NULL, 
		'no', 
		NULL, 
		NULL, 
		'sql', 
		NULL, 
		NULL, 

		IFNULL((SELECT MAX(sequence)+1 FROM ld_validatasave WHERE validatasavemainid=@this_mainid),1), 
		'php', 
		'yes', 
		@this_mainid, 
		'1', 
		'';

		SET @this_validatasaveid=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@this_mainid ORDER BY id DESC LIMIT 1);
	
		INSERT INTO `ld_validatasavedetail` (
			`relateid`, 
			`relateformulavalue`, 
			`relatefieldname`, 
			`sequence`, 
			`relatedtable`, 
			`funtype`, 
			`fungroupdbcolumns`, 
			`fungrouphiddencolumns`
		) 
		SELECT
			@this_validatasaveid, 
			NULL, 
			'no', 
			NULL, 
			'ld_field', 
			'text', 
			NULL, 
			NULL;

	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_validatasavemain WHERE rulename='客户名称去重(忽略全角和半角)' AND module='ServiceCharge') THEN
		INSERT INTO `ld_validatasavemain` (
			`rulename`, 
			`module`, 
			`status`, 
			`actionprevent`, 
			`tipzhtype`, 
			`tipzh`, 
			`tipentype`, 
			`tipen`, 
			`validatasavetype`, 
			`isshowlist`, 
			`conditiongroup`, 
			`validataapplication`, 
			`relatedtable`, 
			`sequence`
		) 
		SELECT
			'客户名称去重(忽略全角和半角)', 
			'ServiceCharge', 
			'inactive',
			'yes', 
			'sql', 
			'SELECT\nGROUP_CONCAT(tips SEPARATOR \'\\r\\n\') AS tips\nFROM (\nSELECT\nCONCAT(\n(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname=\'accountname\') AND languagetype=\'zh\' AND trantable=\'ld_field\' LIMIT 1),\n\'『\',\na.accountname,\n\'』已存在，当前\',\n(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname=\'smownerid\') AND languagetype=\'zh\' AND trantable=\'ld_field\' LIMIT 1),\n\'『\',\nb.last_name,\n\'』\'\n) AS tips\nFROM ld_account a\nLEFT JOIN ld_users b ON b.id=a.smownerid  \nWHERE a.deleted=0 \nAND func_changeToHalfAngle(a.accountname)=func_changeToHalfAngle(\'{ld_account.accountname}\')\nGROUP BY a.accountname,a.smownerid\n) a', 
			'sql', 
			'SELECT\nGROUP_CONCAT(tips SEPARATOR \'\\r\\n\') AS tips\nFROM (\nSELECT\nCONCAT(\n(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname=\'accountname\') AND languagetype=\'zh\' AND trantable=\'ld_field\' LIMIT 1),\n\'『\',\na.accountname,\n\'』已存在，当前\',\n(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname=\'smownerid\') AND languagetype=\'zh\' AND trantable=\'ld_field\' LIMIT 1),\n\'『\',\nb.last_name,\n\'』\'\n) AS tips\nFROM ld_account a\nLEFT JOIN ld_users b ON b.id=a.smownerid  \nWHERE a.deleted=0 \nAND func_changeToHalfAngle(a.accountname)=func_changeToHalfAngle(\'{ld_account.accountname}\')\nGROUP BY a.accountname,a.smownerid\n) a', 
			'php', 
			'yes', 
			'[null,{\"groupcondition\":\"\"}]', 
			'create,edit', 
			'ld_field', 
			IFNULL((SELECT MAX(sequence)+1 FROM ld_validatasavemain WHERE module='ServiceCharge'),1);

		SET @this_mainid=(SELECT id FROM ld_validatasavemain WHERE rulename='客户名称去重(忽略全角和半角)' AND module='ServiceCharge' ORDER BY id DESC);

		INSERT INTO `ld_validatasave` (
		`module`, 
		`relatedtable`, 
		`fieldname`, 
		`comparator`, 
		`formulavalue`, 
		`comparatordescription`, 
		`rulename`, 
		`status`, 
		`validatacheckbutton`, 
		`allowsave`, 
		`tipzh`, 
		`tipen`, 
		`funtype`, 
		`fungroupdbcolumns`, 
		`fungrouphiddencolumns`, 

		`sequence`, 
		`validatasavetype`, 
		`isshowlist`, 
		`validatasavemainid`, 
		`conditiongroupid`, 
		`valid_condition`
	) 
	SELECT 
		'ServiceCharge', 
		'ld_field', 
		'SELECT\n	CASE\n		WHEN EXISTS (SELECT 1 FROM ld_account WHERE deleted=0 AND func_changeToHalfAngle(accountname)=func_changeToHalfAngle(\'{ld_account.accountname}\') \n						AND (CASE WHEN \'{Record.ID}\'>0 THEN accountid<>\'{Record.ID}\' ELSE 1=1 END)) THEN \'yes\'\n		ELSE \'no\'\n	END AS tmp_value', 
		'e', 
		NULL, 
		NULL, 
		NULL, 
		'active', 
		NULL, 
		'no', 
		NULL, 
		NULL, 
		'sql', 
		NULL, 
		NULL, 

		IFNULL((SELECT MAX(sequence)+1 FROM ld_validatasave WHERE validatasavemainid=@this_mainid),1), 
		'php', 
		'yes', 
		@this_mainid, 
		'1', 
		'';

		SET @this_validatasaveid=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@this_mainid ORDER BY id DESC LIMIT 1);
	
		INSERT INTO `ld_validatasavedetail` (
			`relateid`, 
			`relateformulavalue`, 
			`relatefieldname`, 
			`sequence`, 
			`relatedtable`, 
			`funtype`, 
			`fungroupdbcolumns`, 
			`fungrouphiddencolumns`
		) 
		SELECT
			@this_validatasaveid, 
			NULL, 
			'no', 
			NULL, 
			'ld_field', 
			'text', 
			NULL, 
			NULL;

	END IF;

END ||
delimiter;

CALL ldcrm_add_account_validatasaverule();
DROP PROCEDURE IF EXISTS `ldcrm_add_account_validatasaverule`;
delimiter;
-- 2023-03-09


CALL AddColumn('ld_account','accountname_halfangle','VARCHAR','255',NULL);
ALTER TABLE ld_account MODIFY COLUMN accountname_halfangle VARCHAR(255) AFTER accountname;
CALL addtableIndex('ld_account','accountname_halfangle','accountname_halfangle');
delimiter;

DROP PROCEDURE IF EXISTS `reset_accountname_halfangle`;
delimiter ||
CREATE  PROCEDURE `reset_accountname_halfangle`(
)
BEGIN
	
	WHILE( EXISTS (SELECT 1 FROM ld_account WHERE deleted=0 AND TRIM(IFNULL(accountname,''))<>'' AND accountname_halfangle IS NULL) ) DO
		SET @disable_triggers=1;
		UPDATE ld_account SET accountname_halfangle=func_changeToHalfAngle(accountname) WHERE deleted=0 AND TRIM(IFNULL(accountname,''))<>'' AND accountname_halfangle IS NULL LIMIT 1000;
		SET @disable_triggers=NULL;
	END WHILE;


end ||
delimiter;

CALL reset_accountname_halfangle();
DROP PROCEDURE IF EXISTS `reset_accountname_halfangle`;
delimiter;

UPDATE ld_validatasave SET fieldname=REPLACE(fieldname,'func_changeToHalfAngle(accountname)','accountname_halfangle') WHERE module IN ('ServiceCharge','Accounts') AND fieldname LIKE '%func_changeToHalfAngle(accountname)%';
UPDATE ld_validatasavemain SET tipzh="SELECT func_account_repeatinfo('{ld_account.accountname}','zh')" WHERE module IN ('ServiceCharge','Accounts') AND rulename='客户名称去重(忽略全角和半角)';
UPDATE ld_validatasavemain SET tipen="SELECT func_account_repeatinfo('{ld_account.accountname}','en')" WHERE module IN ('ServiceCharge','Accounts') AND rulename='客户名称去重(忽略全角和半角)';
UPDATE ld_validatasavemain SET status='inactive' WHERE module IN ('ServiceCharge','Accounts') AND rulename='客户名称去重(忽略全角和半角)' AND (SELECT COUNT(1) FROM ld_account WHERE deleted=0)>100000;
delimiter;



DROP FUNCTION IF EXISTS `func_account_repeatinfo`;
delimiter ||
CREATE FUNCTION `func_account_repeatinfo`(in_account TEXT,in_tiptype VARCHAR(10)) RETURNS TEXT
BEGIN  

	SET @thishalf_accountname=func_changeToHalfAngle(in_account);

	IF in_tiptype='en' THEN
		SET @this_tips=(
			SELECT
				GROUP_CONCAT(tips SEPARATOR '<br>') AS tips
			FROM (
				SELECT
					CONCAT(
						(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='accountname') AND languagetype='en' AND trantable='ld_field' LIMIT 1),
						'『',
						a.accountname,
						'』 already exists, The ',
						(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='smownerid') AND languagetype='en' AND trantable='ld_field' LIMIT 1),
						'『',
						b.last_name,
						'』'
					) AS tips
				FROM ld_account a
				LEFT JOIN ld_users b ON b.id=a.smownerid  
				WHERE a.deleted=0 
					AND a.accountname=@thishalf_accountname
					GROUP BY a.accountname,a.smownerid
			) a
		);
	ELSE
		SET @this_tips=(
			SELECT
				GROUP_CONCAT(tips SEPARATOR '<br>') AS tips
			FROM (
				SELECT
					CONCAT(
						(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='accountname') AND languagetype='zh' AND trantable='ld_field' LIMIT 1),
						'『',
						a.accountname,
						'』已存在，当前',
						(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='smownerid') AND languagetype='zh' AND trantable='ld_field' LIMIT 1),
						'『',
						b.last_name,
						'』'
					) AS tips
				FROM ld_account a
				LEFT JOIN ld_users b ON b.id=a.smownerid  
				WHERE a.deleted=0 
					AND a.accountname=@thishalf_accountname
					GROUP BY a.accountname,a.smownerid
			) a
		);
	END IF;

	RETURN(@this_tips);

END || 
delimiter;


UPDATE ld_desk set fieldlabel = '请输入正确的手机号码！' where labelbol='PLEASEENTERTHECORRECTMOBILEPHONENUMBER' and fieldlabel = '请输入正确的手机号码';
UPDATE ld_desk set fieldlabel = 'Please enter the correct mobile phone number!' where labelbol='PLEASEENTERTHECORRECTMOBILEPHONENUMBER' and fieldlabel = 'Please enter the correct mobile phone number';
delimiter;


call AddColumn('ld_workflow_api', 'groupname', 'VARCHAR', 50, null);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOHIDEAFTERFINDING','查找后自动隐藏','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOHIDEAFTERFINDING' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOHIDEAFTERFINDING',"Auto hide after finding",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOHIDEAFTERFINDING' and labeltype='jspop');
delimiter;

CALL AddColumn('ld_reminds','push_to_nativeapp','int','2',2);
CALL AddColumn('ld_reminds','push_time_nativeapp','datetime',null ,null );
CALL AddColumn('ld_reminds_accepted','push_to_nativeapp','int','2',2);
CALL AddColumn('ld_reminds_accepted','push_time_nativeapp','datetime',null ,null );
delimiter;


UPDATE ld_desk set fieldlabel = '审批意见' where labelbol='FILLINAPPROVALCOMMENTS' and languagetype = 'zh';
UPDATE ld_desk set fieldlabel = 'Approval comments' where labelbol='FILLINAPPROVALCOMMENTS' and languagetype = 'en';
delimiter;

CALL AddColumn('ld_customreport','sqlstr','text','','');
ALTER TABLE ld_customreport MODIFY COLUMN sqlstr LONGTEXT;
delimiter;
CALL AddColumn('ld_customreport','themename','varchar','255','');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customreportsql_column` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `report_id` int(19) NOT NULL ,
    `column_label` varchar(255) DEFAULT NULL COMMENT '字段显示名称',
    `columns` varchar(255) DEFAULT NULL COMMENT '字段名称',
    `is_group` varchar(100) DEFAULT NULL COMMENT '是否是分组字段',
    `sequence` int(4) COMMENT '排序' ,
    `fieldtype` varchar(255) DEFAULT NULL COMMENT '字段类型',
    PRIMARY KEY  (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customreportsql_filter` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `report_id` int(19) NOT NULL ,
    `var_name` varchar(100) DEFAULT NULL COMMENT '变量名称',
    `display_name` varchar(100) DEFAULT NULL COMMENT '别名',
    `var_type` varchar(100) DEFAULT NULL COMMENT 'date日期  datetime日期时间  number数字区间  select单选  multiselect多选   string模糊查找  checkbox复选框 单选用户selectuser,多选用户multiuser',
    `default_value` varchar(255) COMMENT '默认值 比如日期2022-01-01' ,
    `select_source` varchar(100) DEFAULT NULL COMMENT '选项自定义selfdefine 下拉框字段 picklist',
    `modulename` varchar(100)	 DEFAULT NULL COMMENT '下拉框值来源模块',
    `fieldname` varchar(100) DEFAULT NULL COMMENT '下拉框值来源字段',
    `selectvalues` text DEFAULT '' COMMENT '下拉框值列表 以逗号隔开',
    `sequence` int(4) COMMENT '排序' ,
    PRIMARY KEY  (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ONEYEAR','一年','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ONEYEAR' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ONEYEAR',"One Year",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ONEYEAR' and labeltype='fixedstr');
delimiter;


update ld_desk set fieldlabel='可用变量' where labelbol='DefineVariable' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='Available variables' where labelbol='DefineVariable' and languagetype='en' and Labeltype='jspop';
update ld_desk set fieldlabel='基本信息' where labelbol='DisplaySetting' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='Essential information' where labelbol='DisplaySetting' and languagetype='en' and Labeltype='jspop';
delimiter;

UPDATE ld_desk set fieldlabel = '重置成功！' where labelbol='ResetSuccess' and languagetype = 'zh';
UPDATE ld_desk set fieldlabel = 'Reset Success!' where labelbol='ResetSuccess' and languagetype = 'en';
delimiter;
UPDATE ld_desk set fieldlabel = '重复，已自动生成新的编号！' where labelbol='AUTOCREATEBILLNO'and languagetype = 'zh';
UPDATE ld_desk set fieldlabel = 'is repetitive, a new one has been created automatically!' where labelbol='AUTOCREATEBILLNO'and languagetype = 'en';
delimiter;
-- 2023-03-15

DROP FUNCTION IF EXISTS `func_is_accountexists`;
delimiter ||
CREATE FUNCTION `func_is_accountexists`(in_accountname TEXT,in_accountid INT(19)) RETURNS VARCHAR(10)
BEGIN  

	SET @thishalf_accountname=func_changeToHalfAngle(in_accountname);

	SET @this_existsinfo=(
		SELECT
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_account WHERE deleted=0 AND accountname_halfangle=@thishalf_accountname
								AND (CASE WHEN in_accountid+0>0 THEN accountid<>in_accountid+0 ELSE 1=1 END)) THEN 'yes'
				ELSE 'no'
			END
	);

	RETURN(@this_existsinfo);

END || 
delimiter;

SET @id=(SELECT id FROm ld_validatasavemain WHERE rulename='客户名称去重(忽略全角和半角)' AND module='Accounts');
UPDATE ld_validatasave SET fieldname="SELECT func_is_accountexists('{ld_account.accountname}','{Record.ID}') AS tmp_value" WHERE validatasavemainid=@id;
delimiter;

SET @id=(SELECT id FROm ld_validatasavemain WHERE rulename='客户名称去重(忽略全角和半角)' AND module='ServiceCharge');
UPDATE ld_validatasave SET fieldname="SELECT func_is_accountexists('{ld_account.accountname}','{Record.ID}') AS tmp_value" WHERE validatasavemainid=@id;
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

UPDATE ld_version SET old_version='V8.4.9.2',current_version='V8.4.9.2',remark='V8.4.9.2-20230315',wx_version='V8.4.9.2';
delimiter;