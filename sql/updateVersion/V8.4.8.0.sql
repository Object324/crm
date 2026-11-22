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

ALTER TABLE ld_loginhistory MODIFY COLUMN user_name VARCHAR(255);
UPDATE ld_loginhistory a SET user_name=(SELECT user_name FROM ld_users WHERE LOCATE(a.user_name,user_name)) WHERE LOCATE(a.user_name,user_name)>0 AND DATABASE() LIKE 'wx%';
delimiter;

UPDATE ld_producttoolfield SET defaultcolumn=0 WHERE columnname IN ('taxprice','listprice');
delimiter;

CALl AddColumn('ld_customform19','triggercount','INT','19',0);
CALl AddColumn('ld_customform26','triggercount','INT','19',0);
delimiter;

UPDATE ld_systems_deploy SET inputvalue='[{"value":"1","text":"1"},{"value":"5","text":"5"},{"value":"20","text":"20"},{"value":"50","text":"50"} ,{"value":"100","text":"100"},{"sql":""}]' WHERE deploy_type=151;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile2standardpermissions`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile2standardpermissions`(
	tmp_tabid INT(19)
)
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;

	DECLARE MYCUSOR1 CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0 ORDER BY profileid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	OPEN MYCUSOR1;
	FETCH MYCUSOR1 INTO tmp_profileid;
	WHILE(tmp_profileid IS NOT NULL) DO
		SET @seq_index=(SELECT MAX(sequence) FROM ld_profileallpermission WHERE tabid=tmp_tabid AND operation=3);

		INSERT ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
		SELECT
			profileid,
			tabid,
			11,
			0,
			@seq_index+1
		FROM ld_profile2standardpermissions
		WHERE tabid=tmp_tabid
			AND profileid=tmp_profileid
			AND operation=1
			AND NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE operation=11 AND tabid=tmp_tabid AND profileid=tmp_profileid);


		SET @i=0;
		UPDATE ld_profile2standardpermissions SET sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND profileid=tmp_profileid ORDER BY sequence;

		FETCH MYCUSOR1 INTO tmp_profileid;
	END WHILE;
	CLOSE MYCUSOR1;

END ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profileallpermission_20220928`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profileallpermission_20220928`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR
			SELECT
				a.tabid
			FROM ld_tab a
			WHERE a.`name` IN ('ServiceReturn','SalesBack','PurchaseBack','CashBack','PurchaseCashBack');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_tabid;
	WHILE(tmp_tabid IS NOT NULL) DO
		IF NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=tmp_tabid AND operation=11) THEN
			SET @seq_index=(SELECT MAX(sequence) FROM ld_profileallpermission WHERE tabid=tmp_tabid AND operation=3);

			INSERT INTO ld_profileallpermission(tabid,operation,sequence)
			SELECT tmp_tabid,11,@seq_index+1 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=tmp_tabid AND operation=11);

			SET @i=0;
			UPDATE ld_profileallpermission SET sequence=(@i:=@i+1) WHERE tabid=tmp_tabid ORDER BY sequence;

			CALL ldcrm_add_profile2standardpermissions(tmp_tabid);
		END IF;
		FETCH MYCUSOR INTO tmp_tabid;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_add_profileallpermission_20220928();
DROP PROCEDURE IF EXISTS `ldcrm_add_profileallpermission_20220928`;
DROP PROCEDURE IF EXISTS `ldcrm_add_profile2standardpermissions`;
delimiter;


DROP PROCEDURE IF EXISTS `reset_producttoolfield_salesback`;
delimiter ||
CREATE  PROCEDURE `reset_producttoolfield_salesback`(
)
BEGIN

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
		IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='salesorderid') AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list') THEN
			UPDATE ld_field SET uitype=202,columnname='source_list',fieldname='selectlistval',bigtype='selectsource',fieldlabel='选择源单' WHERE tabid=@tabid AND columnname='salesorderid';
			SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
			UPDATE ld_tranlabel SET fieldlabel='选择源单' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='合同订单';

			SET @disable_triggers='abcdefg';
			CALl AddColumn('ld_salesback','entitytype','VARCHAR','100',NULL);
			CALl AddColumn('ld_salesback','source_list','TEXT','100',NULL);
			SET @disable_triggers=NULL;


			SET @option_tabid=22;
			SET @presence=0;
			SET @isdefault=1;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition,strictsourcebillcolums,autobalancevalue)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',5,'yes',0,'quantity','quantity' FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);


			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytype';
			SET @zh='源单类型';
			SET @en='Entity Type';
			SET @uitype=204;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'VARCHAR','100','');



			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytypeid';
			SET @zh='源单';
			SET @en='Related Orders';
			SET @uitype=202;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'INT','19','');


			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
			UPDATE ld_producttoolfield SET edit_permission=1 WHERE tabid=@tabid AND columnname IN ('entitytypeid','entitytype');
			ALTER TABLE ld_salesbackdetail MODIFY COLUMN entitytypeid INT(19) AFTER entitytype;

			SET @i=0;
			SET @seq=(SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid AND presence<>1 AND tablename='ld_products');
			UPDATE ld_producttoolfield SET sequence=sequence+4 WHERE tabid=@tabid AND presence<>1 AND sequence>@seq;
			UPDATE ld_producttoolfield SET sequence=@seq+1 WHERE tabid=@tabid AND columnname='entitytype';
			UPDATE ld_producttoolfield SET sequence=@seq+2 WHERE tabid=@tabid AND columnname='entitytypeid';
			UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;

			UPDATE ld_relatedlists SET type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' WHERE tabid IN (22) AND related_tabid=@tabid;

			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
			SET @trigger_columnname='source_list';
			SET @effect_columnname='accountid';
			SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
			SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
			INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
			SELECT 'main',@trigger_fieldid,@effect_fieldid,'column',@effect_columnname FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
				AND @trigger_fieldid>0 AND @effect_fieldid>0;
		END IF;
end ||
delimiter;

CALL reset_producttoolfield_salesback();
DROP PROCEDURE IF EXISTS `reset_producttoolfield_salesback`;
delimiter;

CALl AddColumn('ld_salesback','source_list','TEXT',NULL,NULL);
CALl AddColumn('ld_salesback','entitytype','VARCHAR',100,NULL);
delimiter;

update ld_salesback set source_list=salesorderid,entitytype='SalesOrder' where ifnull(salesorderid,'') <> '' and ifnull(source_list,'')='';
delimiter;

DROP PROCEDURE IF EXISTS `reset_producttoolfield_cashback`;
delimiter ||
CREATE  PROCEDURE `reset_producttoolfield_cashback`(
)
BEGIN

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
		IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='salesbackid') AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list') THEN
			UPDATE ld_field SET uitype=202,columnname='source_list',fieldname='selectlistval',bigtype='selectsource',fieldlabel='选择源单' WHERE tabid=@tabid AND columnname='salesbackid';
			SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
			SET @tmp_fieldlabel = (select fieldlabel from ld_tranlabel  WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh');
			UPDATE ld_tranlabel SET fieldlabel='选择源单' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel=@tmp_fieldlabel;

			SET @disable_triggers='abcdefg';
			CALl AddColumn('ld_cashback','entitytype','VARCHAR','100',NULL);
			CALl AddColumn('ld_cashback','source_list','TEXT','100',NULL);
			SET @disable_triggers=NULL;


			SET @option_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
			SET @presence=0;
			SET @isdefault=1;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition,strictsourcebillcolums,autobalancevalue)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',5,'yes',0,'quantity','quantity' FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);


			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytype';
			SET @zh='源单类型';
			SET @en='Entity Type';
			SET @uitype=204;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'VARCHAR','100','');



			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytypeid';
			SET @zh='源单';
			SET @en='Related Orders';
			SET @uitype=202;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'INT','19','');


			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
			UPDATE ld_producttoolfield SET edit_permission=1 WHERE tabid=@tabid AND columnname IN ('entitytypeid','entitytype');
			ALTER TABLE ld_cashbackdetail MODIFY COLUMN entitytypeid INT(19) AFTER entitytype;

			SET @i=0;
			SET @seq=(SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid AND presence<>1 AND tablename='ld_products');
			UPDATE ld_producttoolfield SET sequence=sequence+4 WHERE tabid=@tabid AND presence<>1 AND sequence>@seq;
			UPDATE ld_producttoolfield SET sequence=@seq+1 WHERE tabid=@tabid AND columnname='entitytype';
			UPDATE ld_producttoolfield SET sequence=@seq+2 WHERE tabid=@tabid AND columnname='entitytypeid';
			UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;

			UPDATE ld_relatedlists SET type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' WHERE tabid IN ((SELECT tabid FROM ld_tab WHERE `name`='SalesBack')) AND related_tabid=@tabid;

			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
			SET @trigger_columnname='source_list';
			SET @effect_columnname='accountid';
			SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
			SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
			INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
			SELECT 'main',@trigger_fieldid,@effect_fieldid,'column',@effect_columnname FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
				AND @trigger_fieldid>0 AND @effect_fieldid>0;
		END IF;
end ||
delimiter;

CALL reset_producttoolfield_cashback();
DROP PROCEDURE IF EXISTS `reset_producttoolfield_cashback`;
delimiter;

CALl AddColumn('ld_cashback','entitytype','VARCHAR','100',NULL);
CALl AddColumn('ld_cashback','source_list','TEXT','100',NULL);
update ld_cashback set source_list=salesbackid,entitytype='SalesBack' where ifnull(salesbackid,'') <> '' and ifnull(source_list,'')='';
delimiter;

DROP PROCEDURE IF EXISTS `reset_producttoolfield_purchaseback`;
delimiter ||
CREATE  PROCEDURE `reset_producttoolfield_purchaseback`(
)
BEGIN

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
		IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='purchaseorder_id') AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list') THEN
			UPDATE ld_field SET uitype=202,columnname='source_list',fieldname='selectlistval',bigtype='selectsource',fieldlabel='选择源单' WHERE tabid=@tabid AND columnname='purchaseorder_id';
			SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
			SET @tmp_fieldlabel = (select fieldlabel from ld_tranlabel  WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh');
			UPDATE ld_tranlabel SET fieldlabel='选择源单' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel=@tmp_fieldlabel;

			SET @disable_triggers='abcdefg';
			CALl AddColumn('ld_purchaseback','entitytype','VARCHAR','100',NULL);
			CALl AddColumn('ld_purchaseback','source_list','TEXT','100',NULL);
			SET @disable_triggers=NULL;


			SET @option_tabid=21;
			SET @presence=0;
			SET @isdefault=1;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition,strictsourcebillcolums,autobalancevalue)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',5,'yes',0,'quantity','quantity' FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);


			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytype';
			SET @zh='源单类型';
			SET @en='Entity Type';
			SET @uitype=204;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'VARCHAR','100','');



			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytypeid';
			SET @zh='源单';
			SET @en='Related Orders';
			SET @uitype=202;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'INT','19','');


			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
			UPDATE ld_producttoolfield SET edit_permission=1 WHERE tabid=@tabid AND columnname IN ('entitytypeid','entitytype');
			ALTER TABLE ld_purchasebackdetail MODIFY COLUMN entitytypeid INT(19) AFTER entitytype;

			SET @i=0;
			SET @seq=(SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid AND presence<>1 AND tablename='ld_products');
			UPDATE ld_producttoolfield SET sequence=sequence+4 WHERE tabid=@tabid AND presence<>1 AND sequence>@seq;
			UPDATE ld_producttoolfield SET sequence=@seq+1 WHERE tabid=@tabid AND columnname='entitytype';
			UPDATE ld_producttoolfield SET sequence=@seq+2 WHERE tabid=@tabid AND columnname='entitytypeid';
			UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;

			UPDATE ld_relatedlists SET type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' WHERE tabid IN (21) AND related_tabid=@tabid;

			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
			SET @trigger_columnname='source_list';
			SET @effect_columnname='vendorid';
			SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
			SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
			INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
			SELECT 'main',@trigger_fieldid,@effect_fieldid,'column',@effect_columnname FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
				AND @trigger_fieldid>0 AND @effect_fieldid>0;
		END IF;
end ||
delimiter;

CALL reset_producttoolfield_purchaseback();
DROP PROCEDURE IF EXISTS `reset_producttoolfield_purchaseback`;
delimiter;


CALl AddColumn('ld_purchaseback','entitytype','VARCHAR','100',NULL);
CALl AddColumn('ld_purchaseback','source_list','TEXT','100',NULL);
delimiter;

update ld_purchaseback set source_list=purchaseorder_id,entitytype='PurchaseOrder' where ifnull(purchaseorder_id,'') <> ''  and ifnull(source_list,'')='';
delimiter;

DROP PROCEDURE IF EXISTS `reset_producttoolfield_purchasecashback`;
delimiter ||
CREATE  PROCEDURE `reset_producttoolfield_purchasecashback`(
)
BEGIN

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack');
		IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='purchaseback_id') AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list') THEN
			UPDATE ld_field SET uitype=202,columnname='source_list',fieldname='selectlistval',bigtype='selectsource',fieldlabel='选择源单' WHERE tabid=@tabid AND columnname='purchaseback_id';
			SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
			SET @tmp_fieldlabel = (select fieldlabel from ld_tranlabel  WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh');
			UPDATE ld_tranlabel SET fieldlabel='选择源单' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel=@tmp_fieldlabel;

			SET @disable_triggers='abcdefg';
			CALl AddColumn('ld_purchasecashback','entitytype','VARCHAR','100',NULL);
			CALl AddColumn('ld_purchasecashback','source_list','TEXT','100',NULL);
			SET @disable_triggers=NULL;


			SET @option_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
			SET @presence=0;
			SET @isdefault=1;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition,strictsourcebillcolums,autobalancevalue)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',5,'yes',0,'quantity','quantity' FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);


			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack');
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytype';
			SET @zh='源单类型';
			SET @en='Entity Type';
			SET @uitype=204;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'VARCHAR','100','');



			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack');
			SET @maxid=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @tablename=(SELECT tablename FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='quantity' LIMIT 1);
			SET @trantable='ld_producttoolfield';

			SET @columnname='entitytypeid';
			SET @zh='源单';
			SET @en='Related Orders';
			SET @uitype=202;
			SET @typeofdata='V~O~100';
			SET @width=22;
			SET @defaultvalue=NULL;

			INSERT INTO ld_producttoolfield(
				producttoolfieldid,
				columnname,
				allowhide,
				fieldlabel,
				defaultvalue,

				presence,
				uitype,
				typeofdata,
				sequence,
				tabid,

				tablename,
				width,
				edit_permission,
				input_type,
				fieldid,

				newline,
				defaultcolumn,
				is_checkimportfield,
				description,
				nullfield,


				maxrowsshow,
				bigtype,
				savedatabase
			)
			SELECT
				@maxid+1,
				@columnname,
				'no',
				@zh,
				@defaultvalue,

				0,
				@uitype,
				@typeofdata,
				@maxseq+1,
				@tabid,

				@tablename,
				@width,
				0,
				0,
				0,

				0,
				1,
				0,
				NULL,
				1,

				0,
				NULL,
				'yes'
			FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname);

			UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);


			SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'INT','19','');


			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack');
			UPDATE ld_producttoolfield SET edit_permission=1 WHERE tabid=@tabid AND columnname IN ('entitytypeid','entitytype');
			ALTER TABLE ld_purchasecashbackdetail MODIFY COLUMN entitytypeid INT(19) AFTER entitytype;

			SET @i=0;
			SET @seq=(SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid AND presence<>1 AND tablename='ld_products');
			UPDATE ld_producttoolfield SET sequence=sequence+4 WHERE tabid=@tabid AND presence<>1 AND sequence>@seq;
			UPDATE ld_producttoolfield SET sequence=@seq+1 WHERE tabid=@tabid AND columnname='entitytype';
			UPDATE ld_producttoolfield SET sequence=@seq+2 WHERE tabid=@tabid AND columnname='entitytypeid';
			UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;

			UPDATE ld_relatedlists SET type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' WHERE tabid IN ((SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack')) AND related_tabid=@tabid;

			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack');
			SET @trigger_columnname='source_list';
			SET @effect_columnname='vendorid';
			SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
			SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
			INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
			SELECT 'main',@trigger_fieldid,@effect_fieldid,'column',@effect_columnname FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
				AND @trigger_fieldid>0 AND @effect_fieldid>0;
		END IF;
end ||
delimiter;

CALL reset_producttoolfield_purchasecashback();
DROP PROCEDURE IF EXISTS `reset_producttoolfield_purchasecashback`;
delimiter;

CALl AddColumn('ld_purchasecashback','entitytype','VARCHAR','100',NULL);
CALl AddColumn('ld_purchasecashback','source_list','TEXT','100',NULL);
delimiter;

update ld_purchasecashback set source_list=purchaseback_id,entitytype='PurchaseBack' where ifnull(purchaseback_id,'') <> '' and ifnull(source_list,'')='';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETMAPDISPLAYFIELD','设置图谱显示字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETMAPDISPLAYFIELD' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETMAPDISPLAYFIELD',"Set the map display field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETMAPDISPLAYFIELD' and labeltype='fixedstr');
delimiter;

SET @accounts_tabid = (SELECT tabid from ld_tab where `name` = 'Accounts');
SET @servicecharge_tabid = (SELECT tabid from ld_tab where `name` = 'ServiceCharge');
SET @newblockid = (SELECT blockid from ld_blocks where tabid = @servicecharge_tabid ORDER BY blockid asc limit 1);
update ld_field SET block = @newblockid,presence = 1 WHERE tabid = @servicecharge_tabid and block in (SELECT blockid from ld_blocks where tabid = @accounts_tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DISCONTINUEDPRODUCTSNOTBEBROUGHTIN','产品分录明细中存在已禁用产品，复制后不会带入这些产品！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DISCONTINUEDPRODUCTSNOTBEBROUGHTIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DISCONTINUEDPRODUCTSNOTBEBROUGHTIN',"There are disabled products in the product bills details, they will not be brought in!",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DISCONTINUEDPRODUCTSNOTBEBROUGHTIN' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_account_nolinkdays`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_account_nolinkdays`(
)
BEGIN
	SET @disable_triggers=1;
	UPDATE ld_account SET nolinkdays=DATEDIFF(CURDATE(),DATE_FORMAT(IFNULL(lastcontactdate,createdtime),'%Y-%m-%d'));
	SET @disable_triggers=NULL;
end ||
delimiter;


DROP EVENT IF EXISTS `update_account_nolinkdays`;
delimiter ||
CREATE  EVENT `update_account_nolinkdays` ON SCHEDULE EVERY 1 DAY STARTS '2016-05-24 00:30:00' ON COMPLETION NOT PRESERVE ENABLE DO 
CALL ldcrm_reset_account_nolinkdays();
||
delimiter;


SET @labelbol = 'DETAILAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'明细','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Detailed','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DETAIL1APP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'详情','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Details','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-11-08

UPDATE ld_desk SET fieldlabel = 'Current version' where labelbol = 'CURRENTVERSION' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

UPDATE ld_desk SET fieldlabel ='Visitor' where labelbol='BaiFang_DuiXiang' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;
-- 2022-11-09

DROP PROCEDURE IF EXISTS `ldcrm_add_field_20230419`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_field_20230419`(
)
BEGIN
	


	SET @modulename='ServiceContracts';
	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
	IF @tabid>0 THEN
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='totalquantity'; 
		SET @fieldname='totalquantity'; 
		SET @zh='数量合计'; 
		SET @en='Total Quantity'; 
		SET @uitype=560; 
		SET @typeofdata='N~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
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

		CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
		ALTER TABLE ld_servicecontracts MODIFY COLUMN totalquantity DECIMAL(25,8);

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);

		SET @disable_triggers=1;
		UPDATE ld_servicecontracts a
		INNER JOIN (
			SELECT 
				id,
				SUM(IFNULL(quantity,0)) AS totalquantity
			FROM ld_servicecontractsdetail
			GROUP BY id
		) b ON b.id=a.servicecontractsid
		SET a.totalquantity=IFNULL(b.totalquantity,0);
		SET @disable_triggers=NULL;
	END IF;

end ||
delimiter;

CALL ldcrm_add_field_20230419();
DROP PROCEDURE IF EXISTS `ldcrm_add_field_20230419`;
delimiter;


CALl AddColumn('ld_salesorder','totalquantity','INT','19',NULL);
ALTER TABLE ld_salesorder MODIFY COLUMN totalquantity DECIMAL(25,8);
delimiter;


DROP PROCEDURE IF EXISTS `delete_trigger_nolinkdays`;
delimiter ||
CREATE PROCEDURE `delete_trigger_nolinkdays`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM information_schema.TRIGGERS  WHERE TRIGGER_SCHEMA=DATABASE() AND TRIGGER_NAME='up_account_nolinkdays' AND ACTION_STATEMENT LIKE "%IF @disable_triggers IS NULL THEN
		IF ifnull(new.lastcontactdate,'0000-00-00')<>ifnull(old.lastcontactdate,'0000-00-00') THEN
			SET new.nolinkdays=datediff(CURDATE(),ifnull(new.lastcontactdate,date_format(new.createdtime,'%Y-%m-%d')));
		END IF;
	END IF;%") THEN
		DROP TRIGGER IF EXISTS `up_account_nolinkdays`;
	END IF;


END ||
delimiter;

CALL delete_trigger_nolinkdays();
DROP PROCEDURE IF EXISTS `delete_trigger_nolinkdays`;
-- 2022-11-11

UPDATE ld_tab SET mobilepresence = 'mobile,weixin' where name = 'BankAccountSet';
delimiter;

SET @blockid = (SELECT blockid from ld_appparenttab where parenttab_label = 'Finacial');
SET @sequence = (SELECT max(sequence) from ld_appparenttabrel where blockid = @blockid);
SET @tabid = (SELECT tabid from ld_tab where name = 'BankAccountSet');
INSERT into ld_appparenttabrel(blockid,tabid,sequence,relatename,tab_tablename)
SELECT @blockid,@tabid,@sequence+1,'','ld_tab' from dual
where not EXISTS(SELECT 1 from ld_appparenttabrel where tabid = @tabid and blockid = @blockid);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_cvcolumnlist_wx`(
  tmp_module VARCHAR(100),
  tmp_column VARCHAR(100),
  tmp_rownum INT(1),
  tmp_colnum INT(1),
  tmp_showtag VARCHAR(20),
  tmp_sysdefault VARCHAR(20)
)
BEGIN

  SET @columnname=(
    SELECT
      CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1))
    FROM ld_tab a
    LEFT JOIN ld_field b ON a.tabid=b.tabid
    WHERE a.`name`=tmp_module
      AND b.columnname=tmp_column
    LIMIT 1);

  DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
  INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
  SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='BankAccountSet';
CALL ldcrm_add_cvcolumnlist_wx('BankAccountSet','accountname','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('BankAccountSet','smownerid','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('BankAccountSet','createdtime','3','1','yes','yes');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'accountname',1,'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='accountname');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',2,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',3,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
delimiter;

CREATE TABLE if not exists `ld_wechatconvertuserid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT NULL,
  `wechatuserid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

ALTER TABLE ld_appuiset MODIFY setname text;
delimiter;

CALL addtableIndex('ld_wechatsession','session_type_idx','session_type');
delimiter;

set @tabid = (select tabid from ld_tab where `name`= 'ServiceContracts');
update ld_field set columnname='vendorid',uitype=81 where uitype=75 and columnname='vendor_id' and tabid=@tabid;
delimiter;

CALl AddColumn('ld_customform15','triggercount','INT','19',0);
delimiter;
-- 2022-11-12


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

UPDATE ld_version SET old_version='V8.4.8.0',current_version='V8.4.8.0',remark='V8.4.8.0-20221112',wx_version='V8.4.8.0';
delimiter;