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

SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,'WeChatUser',5,@maxtseq+1,'WeChatUser',1,NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='WeChatUser');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab',@tabid,@tabid,'微信用户' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab',@tabid,@tabid,'WeChat User' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');
delimiter;

SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
SELECT @maxnum_id+1,'WeChatUser','WXYH',1,1,1,'none',0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule='WeChatUser');
UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
INSERT INTO ld_modtracker_tabs(tabid,visible)
SELECT @tabid,1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);
delimiter;

SET @i=0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Export','ChangeCreator','CustomView');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
SELECT @tabid,'WeChatUser',CONCAT('ld_',LOWER('WeChatUser')),CONCAT(LOWER('WeChatUser'),'_no'),CONCAT(LOWER('WeChatUser'),'id'),CONCAT(LOWER('WeChatUser'),'id') FROM DUAl
WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename='WeChatUser');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER('WeChatUser'),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('WeChatUser'),'_BASICINFORMATION') AND tabid=@tabid);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('WeChatUser'),'_BASICINFORMATION') AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'accountid','no',CONCAT('ld_',LOWER('WeChatUser')),1,73,'account_id','客户名称',1,0,2,@blockid ,1,'V~O',1,0,0,'reference',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='accountid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'客户名称' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Account Name' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,CONCAT(LOWER('WeChatUser'),'_no'),'no',CONCAT('ld_',LOWER('WeChatUser')),1,4,CONCAT(LOWER('WeChatUser'),'_no'),'单据编号',1,0,1,@blockid ,1,'V~M',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER('WeChatUser'),'_no'));

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER('WeChatUser'),'_no'));
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'单据编号' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Bill NO.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'contactid','no',CONCAT('ld_',LOWER('WeChatUser')),1,57,'contact_id','联系人',1,0,3,@blockid ,1,'V~O',1,0,0,'reference',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='contactid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='contactid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'联系人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Contact Name' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'mobile','no',CONCAT('ld_',LOWER('WeChatUser')),1,1101,'mobile','手机号码',1,0,4,@blockid ,1,'V~O',1,0,0,'',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='mobile');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='mobile');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'手机号码' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Mobile' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'lastname','no',CONCAT('ld_',LOWER('WeChatUser')),1,1,'lastname','姓名',1,0,5,@blockid ,1,'V~O',1,0,0,'text',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='lastname');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='lastname');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'姓名' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'LastName' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'sex','no',CONCAT('ld_',LOWER('WeChatUser')),1,15,'sex','性别',1,0,6,@blockid ,1,'V~O',1,0,0,'text',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='sex');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='sex');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'性别' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Sex' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'imagename','no',CONCAT('ld_',LOWER('WeChatUser')),1,105,'imagename','个人头像',1,0,7,@blockid ,1,'V~O',1,0,0,'',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='imagename');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='imagename');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'个人头像' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Image' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER('WeChatUser')),1,53,'assigned_user_id','负责人',1,0,8,@blockid ,1,'V~M',1,1,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER('WeChatUser')),1,52,'smcreatorid','创建人',1,0,9,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER('WeChatUser')),1,70,'createdtime','创建时间',1,0,10,@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER('WeChatUser')),1,52,'modifiedby','最新更新人',1,0,11,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER('WeChatUser')),1,70,'modifiedtime','更新时间',1,0,12,@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER('WeChatUser')),1,609,'approvestatus','审批状态',1,0,13,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER('WeChatUser')),1,70,'approvetime','最新审批时间',1,0,14,@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER('WeChatUser')),1,131,'approveby','上一步审批人',1,0,15,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER('WeChatUser')),1,132,'currentapprover','当前审批人',1,0,16,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'当前审批人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Current Approver' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER('WeChatUser')),1,1,'print_times','打印次数',1,1,17,@blockid ,2,'N~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Print Times' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
delimiter;

CALL getallprofile('WeChatUser');
CALL fieldprofile('WeChatUser');

SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+1,'All',1,0,'WeChatUser',3,1,1 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype='WeChatUser' and viewname='All');
UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
delimiter;

SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='WeChatUser' AND viewname='All');
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,0,CONCAT('ld_',LOWER('WeChatUser'),':',LOWER('WeChatUser'),'_no',':',LOWER('WeChatUser'),'_no',':','WeChatUser','_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,1,CONCAT('ld_',LOWER('WeChatUser'),':','lastname',':','lastname',':','WeChatUser','_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,2,CONCAT('ld_',LOWER('WeChatUser'),':','contactid',':','contact_id',':','WeChatUser','_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,3,CONCAT('ld_',LOWER('WeChatUser'),':','mobile',':','mobile',':','WeChatUser','_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,4,CONCAT('ld_',LOWER('WeChatUser'),':','smownerid',':','assigned_user_id',':','WeChatUser','_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,5,CONCAT('ld_',LOWER('WeChatUser'),':','createdtime',':','createdtime',':','WeChatUser','_fieldlabel:DT');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
INSERT INTO ld_def_org_share(tabid,permission,editstatus)
SELECT @tabid,3,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);
delimiter;

CALL addtabintoprofile('WeChatUser',1);
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_attachments_filename_bymodule`(
	tmp_modulename VARCHAR(100)
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);

	IF @tabid>0 THEN
		SELECT MAX(blockid) into @maxid FROM ld_blocks;
		SELECT MAX(sequence) into @maxseq FROM ld_blocks WHERE tabid=@tabid;
		SET @trantable='ld_blocks';
		SET @blocklabel='LBI_ATTACHMENT_FILE';
		SET @zh='附件信息';
		SET @en='Attachments Information';

		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title)
		SELECT @maxid+1,@tabid,@blocklabel,@maxseq+1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

		UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

		SELECT blockid INTO @relateid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel LIMIT 1;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		SET @maxseq=0;
		SELECT MAX(fieldid) INTO @maxid FROM ld_field;
		SELECT MAX(sequence) INTO @maxseq FROM ld_field WHERE tabid=@tabid AND block=@relateid;
		SET @trantable='ld_field';
		SET @tablename='ld_attachments';
		SET @columnname='filename';
		SET @fieldname='filename';
		SET @zh='附件';
		SET @en='Attachment';
		SET @uitype=1109;

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment' from dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);

	END IF;

end ||
delimiter;

CALl ldcrm_add_attachments_filename_bymodule('WeChatUser');
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

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='WeChatUser';
CALL ldcrm_add_cvcolumnlist_wx('WeChatUser',CONCAT(LOWER('WeChatUser'),'_no'),'1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('WeChatUser','lastname','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('WeChatUser','mobile','3','1','yes','yes');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,CONCAT(LOWER('WeChatUser'),'_no'),1,'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname=CONCAT(LOWER('WeChatUser'),'_no'));
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'lastname',2,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='lastname');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'mobile',3,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='mobile');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
	tmp_moudlename VARCHAR(100),
	tmp_deploytype INT(19)
)
BEGIN

	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;

	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);

		CALl AddColumn(@tablename,'approvesubmitter','INT','19',0);
		CALl AddColumn(@tablename,'approvesubmittedtime','DATETIME','',0);
		CALl AddColumn(@tablename,'currentapprovestepid','INT','19',0);

		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvestatus';
		SET @fieldname='approvestatus';
		SET @zh='审批状态';
		SET @en='Approve status';
		SET @uitype=609;
		SET @typeofdata='V~O';
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

		CALl AddColumn(@tablename,'approvestatus','VARCHAR','50','未提交');


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approveby';
		SET @fieldname='approveby';
		SET @zh='上一步审批人';
		SET @en='Approve By';
		SET @uitype=131;
		SET @typeofdata='V~O';
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

		CALl AddColumn(@tablename,'approveby','INT','19',NULL);


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='currentapprover';
		SET @fieldname='currentapprover';
		SET @zh='当前审批人';
		SET @en='Current Approver';
		SET @uitype=132;
		SET @typeofdata='V~O';
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

		CALl AddColumn(@tablename,'currentapprover','TEXT','100',NULL);


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvetime';
		SET @fieldname='approvetime';
		SET @zh='最新审批时间';
		SET @en='Last Approve Time';
		SET @uitype=70;
		SET @typeofdata='DT~O';
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

		CALl AddColumn(@tablename,'approvetime','DATETIME','','0');

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);


		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 1,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);



		SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);


		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

	END IF;

end ||
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wechatuser` (
  `wechatuserid` int(11) NOT NULL AUTO_INCREMENT,
  `accountid` int(11) DEFAULT NULL,
  `contactid` int(11) DEFAULT NULL,
  `wechatuser_no` varchar(100) DEFAULT NULL,
  `lastname` varchar(100) DEFAULT NULL,
  `mobile` varchar(50) DEFAULT NULL,
  `smownerid` int(11) DEFAULT NULL,
  `smcreatorid` int(11) DEFAULT NULL,
  `modifiedby` int(11) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  `imagename` text,
  `sex` varchar(50) DEFAULT NULL,
  `approvesubmitter` int(19) DEFAULT '0',
  `approvesubmittedtime` datetime DEFAULT NULL,
  `currentapprovestepid` int(19) DEFAULT '0',
  `approvestatus` varchar(50) DEFAULT '未提交',
  `approveby` int(19) DEFAULT '0',
  `currentapprover` text,
  `approvetime` datetime DEFAULT NULL,
  `advance_stage` varchar(100) DEFAULT NULL,
  `kis_id` int(11) DEFAULT '0',
  `kis_no` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`wechatuserid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wechatuserscf` (
  `wechatuserid` int(11) NOT NULL,
  PRIMARY KEY (`wechatuserid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CALL ldcrm_add_approveforbill('WeChatUser',329);
CALL AddColumn('ld_wechatuser','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_wechatuser','kis_id','int','11',0);
CALL AddColumn('ld_wechatuser','kis_no','varchar','50',NULL);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WeChatUser');
set @fieldid = (SELECT fieldid FROM ld_field WHERE tabid=@tabid and columnname = 'Sex');
insert into ld_picklist_set(listname,relatetable,parent_listname,parent_relatetable)
select 'sex','ld_field','','' from dual
where not exists(select 1 from ld_picklist_set where listname = 'sex' and relatetable = 'ld_field');
select listid into @listid from ld_picklist_set where listname = 'sex' and relatetable = 'ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'男',1 from dual
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '男');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'女',1 from dual
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '女');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wechatuser_sign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wechatuserid` int(11) DEFAULT NULL,
  `channelcode_id` int(11) DEFAULT NULL,
  `sign_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','accountname2','客户档案','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='accountname2' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','accountname2',"Account name",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='accountname2' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','signlog','签到日志','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signlog' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','signlog',"Sign Log",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signlog' and labeltype='fixedstr');
delimiter;

set @presence = 0;
set @related_tabid = -17;
select tabid into @tabid from ld_tab where `name`='WeChatUser';
select max(relation_id) into @relation_id from ld_relatedlists;
select max(sequence) into @maxsequence from ld_relatedlists where tabid=@tabid;
update ld_relatedlists_seq set id=@relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid);
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,label,presence,wx_presence,wx_sequence,sequence)
select @relation_id+1,@tabid,@related_tabid,'get_wechatuser_sign','signlog',@presence,@presence,@maxsequence+1,@maxsequence+1 from dual
where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid);
delimiter;


call AddColumn('ld_wechatuser','open_id','text','','');
delimiter;

call AddColumn('ld_wechatuser_sign','address','text','','');
delimiter;
call AddColumn('ld_wechatuser_sign','longtitude','varchar','50','');
delimiter;
call AddColumn('ld_wechatuser_sign','latitude','varchar','50','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','signlongtitude','签到经度','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signlongtitude' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','signlongtitude',"Sign Longtitude",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signlongtitude' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','signlatitude','签到纬度','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signlatitude' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','signlatitude',"Sign Latitude",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signlatitude' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_wechatuser','unionid','text','','');
delimiter;

call AddColumn('ld_contactdetails','unionid','text','','');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WeChatUser';
update ld_field set presence = 1 where tabid = @tabid and columnname in ('approvestatus','approvetime','approveby','currentapprover');
delimiter;

call AddColumn('ld_wechatuser','channelcode_id','int','11',0);
delimiter;

select tabid into @tabid from ld_tab where `name`='WeChatUser';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'lastname';
update ld_tranlabel set fieldlabel = '昵称' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
update ld_field set fieldlabel = '昵称' where tabid = @tabid and columnname = 'lastname';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_shopcartdetails` ( 
    `cartid` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `productid` int(19) NOT NULL,
    `quantity` Decimal(20,8) DEFAULT 1 ,
		`smownerid` int(11) NOT NULL,
		`createdtime` Datetime
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','ADDTOCART','加入购物车','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='ADDTOCART' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','ADDTOCART','Add to cart','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='ADDTOCART' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SHOPCART','购物车','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SHOPCART' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SHOPCART','Shopping cart','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SHOPCART' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SUCCESSADDCART','加入购物车成功！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SUCCESSADDCART' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SUCCESSADDCART','Successfully added to shopping cart','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SUCCESSADDCART' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SHOPCARTEMPTY','购物车空空如也~','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SHOPCARTEMPTY' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SHOPCARTEMPTY','The shopcart is empty!','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SHOPCARTEMPTY' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SUCCESSMASSADDCART','成功批量加入购物车{Var}条！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SUCCESSMASSADDCART' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SUCCESSMASSADDCART','Successfully added {Var} shopping carts in batch !','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SUCCESSMASSADDCART' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SHOPCARTFULL','您的购物车商品总数已满，请先清理后继续加入购物车！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SHOPCARTFULL' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SHOPCARTFULL','The total number of goods in your shopping cart is full. Please clean it up before adding it to the shopping cart!','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SHOPCARTFULL' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SELECTEDPRODUCT','已选商品','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SELECTEDPRODUCT' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SELECTEDPRODUCT','Selected products','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SELECTEDPRODUCT' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','ENTERCORRECTNUMBER','请输入正确的数字！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='ENTERCORRECTNUMBER' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','ENTERCORRECTNUMBER','Please enter the correct number','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='ENTERCORRECTNUMBER' and Labeltype='jspop');
delimiter;

select max(report_id) into @folder_id from ld_customreport;
INSERT INTO ld_customreport
SELECT @folder_id+1, '默认图表', '默认图表', 'folder', 0, 0, NULL, '2021-9-2 17:03:01', NULL, 0, NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL, NULL, NULL
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0);
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户类型分布统计-饼图', '客户类型分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-2 17:04:26', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户类型分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");


select report_id into @report_id from  ld_customreport where report_name="客户类型分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户类型分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);


select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');


select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_account:account_type:accounttype:Accounts_客户类型:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_account:account_type:accounttype:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户状态分布统计-饼图', '客户状态分布统计', 'chart',  @folder_id, NULL, 'Accounts', '2021-9-2 17:06:06', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户状态分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from ld_customreport  where report_name="客户状态分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户状态分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_account:rating:rating:Accounts_客户状态:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_account:rating:rating:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户来源分布统计-饼图', '客户来源分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-2 17:07:46', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户来源分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户来源分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户来源分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');


select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_accountscf:leadsource:leadsource:Accounts_客户来源:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_accountscf:leadsource:leadsource:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户重要级别分布统计-饼图', '?客户重要级别分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-2 17:09:35', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户重要级别分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户重要级别分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户重要级别分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');


select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_accountscf:important_level:important_level:Accounts_重要级别:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_accountscf:important_level:important_level:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1,  '客户所属行业分布统计-饼图', '?客户所属行业分布统计', 'chart',  @folder_id, NULL, 'Accounts', '2021-9-2 17:13:59', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户所属行业分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户所属行业分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户所属行业分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_account:industry:industry:Accounts_所属行业1:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_account:industry:industry:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户关系分布统计-饼图', '客户关系分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-2 17:18:22', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户关系分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户关系分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户关系分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_accountscf:accountrelationship:accountrelationship:Accounts_客户关系:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_accountscf:accountrelationship:accountrelationship:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户人员规模分布统计-饼图', '?客户人员规模分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-2 17:19:34', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户人员规模分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户人员规模分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户人员规模分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_accountscf:accountsize:accountsize:Accounts_人员规模:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_accountscf:accountsize:accountsize:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1,'客户年营业额分布统计-饼图', '?客户年营业额分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-2 17:20:55', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户年营业额分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户年营业额分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户年营业额分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,  'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_accountscf:annualincome:annualincome:Accounts_年营业额:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_accountscf:annualincome:annualincome:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户注册资金分布统计-饼图', '?客户注册资金分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-2 17:21:48', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户注册资金分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户注册资金分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户注册资金分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');


select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_accountscf:registeredcapital:registeredcapital:Accounts_注册资金:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_accountscf:registeredcapital:registeredcapital:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '联系记录联系方式分布统计-饼图', '描述', 'chart', @folder_id, NULL, 'ContactRecords', '2021-9-3 11:34:59', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='联系记录联系方式分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="ContactRecords");

select report_id into @report_id from  ld_customreport where report_name="联系记录联系方式分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="ContactRecords";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"联系记录联系方式分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'count', 'ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_跟进记录编号:V', 0, 'pie', '', '跟进记录数量', 0, 'ContactRecords'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_contactrecords:contactrecordtype:contactrecordtype:ContactRecords_联系方式:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_contactrecords:contactrecordtype:contactrecordtype:ContactRecords_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户联系次数Top10-柱状', '客户联系次数Top10', 'chart', @folder_id, NULL, 'ContactRecords', '2021-9-3 11:36:35', NULL, 0, NULL, 10, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户联系次数Top10-柱状' and report_type='chart' and `deleted`=0 and mainmodule="ContactRecords");

select report_id into @report_id from  ld_customreport where report_name="客户联系次数Top10-柱状" and report_type="chart" and `deleted`=0 and mainmodule="ContactRecords";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"客户联系次数Top10-柱状\"}', 'bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"客户名称\",\"axisLabel\":{\"rotate\":0}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_跟进记录编号:V', 0, 'bar', '', '跟进记录次数', 0, 'ContactRecords'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_%');


select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_contactrecords:accountid:account_id:ContactRecords_客户名称:V', 0, 'reference'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_contactrecords:accountid:account_id:ContactRecords_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户联系次数Top50-柱状', '客户联系次数Top50', 'chart', @folder_id, NULL, 'ContactRecords', '2021-9-3 11:37:53', NULL, 0, NULL, 50, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户联系次数Top50-柱状' and report_type='chart' and `deleted`=0 and mainmodule="ContactRecords");

select report_id into @report_id from  ld_customreport where report_name="客户联系次数Top50-柱状" and report_type="chart" and `deleted`=0 and mainmodule="ContactRecords";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"客户联系次数Top50-柱状\"}', 'bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"客户名称\",\"axisLabel\":{\"rotate\":45}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_跟进记录编号:V', 0, 'bar', '', '跟进次数', 0, 'ContactRecords'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_%');


select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_contactrecords:accountid:account_id:ContactRecords_客户名称:V', 0, 'reference'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_contactrecords:accountid:account_id:ContactRecords_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户服务次数统计表-柱状', '', 'chart', @folder_id, NULL, 'HelpDesk', '2021-9-3 11:38:52', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户服务次数统计表-柱状' and report_type='chart' and `deleted`=0 and mainmodule="HelpDesk");

select report_id into @report_id from  ld_customreport where report_name="客户服务次数统计表-柱状" and report_type="chart" and `deleted`=0 and mainmodule="HelpDesk";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"客户服务次数统计表-柱状\"}', 'bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"客户名称\",\"axisLabel\":{\"rotate\":45}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_troubletickets:ticket_no:ticket_no:HelpDesk_服务单编号:V', 0, 'bar', '', '服务次数', 0, 'HelpDesk'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_troubletickets:ticket_no:ticket_no:HelpDesk_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_troubletickets:accountid:account_id:HelpDesk_客户名称:V', 0, 'reference'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_troubletickets:accountid:account_id:HelpDesk_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '服务人员服务次数统计表-柱状', '?服务人员服务次数统计表', 'chart', @folder_id, NULL, 'HelpDesk', '2021-9-3 11:40:18', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='服务人员服务次数统计表-柱状' and report_type='chart' and `deleted`=0 and mainmodule="HelpDesk");

select report_id into @report_id from  ld_customreport where report_name="服务人员服务次数统计表-柱状" and report_type="chart" and `deleted`=0 and mainmodule="HelpDesk";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"服务人员服务次数统计表-柱状\"}', 'bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"服务人员\",\"axisLabel\":{\"rotate\":45}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);


select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_troubletickets:ticket_no:ticket_no:HelpDesk_服务单编号:V', 0, 'bar', '', '服务次数', 0, 'HelpDesk'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_troubletickets:ticket_no:ticket_no:HelpDesk_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_服务人员:V', 0, 'users'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_troubletickets:smownerid:assigned_user_id:HelpDesk_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户服务单故障类别统计表-柱状', '客户服务单故障类别统计表', 'chart', @folder_id, NULL, 'HelpDesk', '2021-9-3 11:41:08', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户服务单故障类别统计表-柱状' and report_type='chart' and `deleted`=0 and mainmodule="HelpDesk");

select report_id into @report_id from  ld_customreport where report_name="客户服务单故障类别统计表-柱状" and report_type="chart" and `deleted`=0 and mainmodule="HelpDesk";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"客户服务单故障类别统计表-柱状\"}', 'bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"服务单数量\",\"axisLabel\":{\"rotate\":45}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'count', 'ld_troubletickets:ticket_no:ticket_no:HelpDesk_服务单编号:V', 0, 'bar', '', '服务单数量', 0, 'HelpDesk'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_troubletickets:ticket_no:ticket_no:HelpDesk_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_troubletickets:category:ticketcategories:HelpDesk_故障类别:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_troubletickets:category:ticketcategories:HelpDesk_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户公司性质分布统计-饼图', '?客户公司性质分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-3 11:42:09', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户公司性质分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户公司性质分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"客户公司性质分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);


select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id, 'byField', 'ld_accountscf:accountproperty:accountproperty:Accounts_公司性质:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_accountscf:accountproperty:accountproperty:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1,  '客户省份分布统计-饼图', '', 'chart', @folder_id, NULL, 'Accounts', '2021-9-3 11:42:49', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户省份分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户省份分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"客户省份分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');


select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_account:bill_state:bill_state:Accounts_省份:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_account:bill_state:bill_state:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户销售负责人分布统计-饼图', '?客户销售负责人分布统计', 'chart', @folder_id, NULL, 'Accounts', '2021-9-3 11:43:26', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户销售负责人分布统计-饼图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户销售负责人分布统计-饼图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"客户销售负责人分布统计-饼图\"}', 'solid_pie', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'yes', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'count', 'ld_account:account_no:account_no:Accounts_客户编号:V', 0, 'pie', '', '客户数量', 0, 'Accounts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_account:account_no:account_no:Accounts_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,   'byField', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 0, 'users'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_account:smownerid:assigned_user_id:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '销售漏斗-漏斗图', '销售漏斗', 'chart', @folder_id, NULL, 'Potentials', '2021-9-3 11:45:03', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'yes', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='销售漏斗-漏斗图' and report_type='chart' and `deleted`=0 and mainmodule="Potentials");

select report_id into @report_id from  ld_customreport where report_name="销售漏斗-漏斗图" and report_type="chart" and `deleted`=0 and mainmodule="Potentials";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"销售漏斗-漏斗图\"}', 'funnel', NULL, NULL, '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', 'funnel'
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'count', 'ld_potential:potential_no:potential_no:Potentials_编号:V', 0, 'funnel', '', '', 0, 'Potentials'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_potential:potential_no:potential_no:Potentials_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_potential:sales_stage:sales_stage:Potentials_销售阶段1:V', 0, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_potential:sales_stage:sales_stage:Potentials_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '客户收款金额Top10-柱状', '?客户收款金额Top10', 'chart', @folder_id, NULL, 'CashBill', '2021-9-3 11:47:12', NULL, 0, NULL, 10, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户收款金额Top10-柱状' and report_type='chart' and `deleted`=0 and mainmodule="CashBill");

select report_id into @report_id from  ld_customreport where report_name="客户收款金额Top10-柱状" and report_type="chart" and `deleted`=0 and mainmodule="CashBill";
INSERT INTO ld_customreport_chartset
SELECT @report_id, '{\"text\":\"客户收款金额Top10-柱状\"}', 'bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"客户名称\",\"axisLabel\":{\"rotate\":45}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'sum', 'ld_cashbill:total:hdnGrandTotal:CashBill_实际收款金额:N', 0, 'bar', '', '收款额', 0, 'CashBill'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='sum' and columns like '%ld_cashbill:total:hdnGrandTotal:CashBill_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_cashbill:accountid:account_id:CashBill_客户名称:V', 0, 'reference'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_cashbill:accountid:account_id:CashBill_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1,  '客户收款金额Top50-柱状', '?客户收款金额Top10', 'chart', @folder_id, NULL, 'CashBill', '2021-9-3 11:47:57', NULL, 0, NULL, 50, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户收款金额Top50-柱状' and report_type='chart' and `deleted`=0 and mainmodule="CashBill");

select report_id into @report_id from  ld_customreport where report_name="客户收款金额Top50-柱状" and report_type="chart" and `deleted`=0 and mainmodule="CashBill";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户收款金额Top50-柱状\"}', 'bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"客户名称\",\"axisLabel\":{\"rotate\":45}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'sum', 'ld_cashbill:total:hdnGrandTotal:CashBill_实际收款金额:N', 0, 'bar', '', '收款额', 0, 'CashBill'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='sum' and columns like '%ld_cashbill:total:hdnGrandTotal:CashBill_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,   'byField', 'ld_cashbill:accountid:account_id:CashBill_客户名称:V', 0, 'reference'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_cashbill:accountid:account_id:CashBill_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1,  '客户签约金额堆叠图', '客户签约金额堆叠图', 'chart', @folder_id, NULL, 'Accounts', '2021-9-3 11:53:24', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='客户签约金额堆叠图' and report_type='chart' and `deleted`=0 and mainmodule="Accounts");

select report_id into @report_id from  ld_customreport where report_name="客户签约金额堆叠图" and report_type="chart" and `deleted`=0 and mainmodule="Accounts";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"客户签约金额堆叠图\"}', 'bar_stack', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"客户名称\",\"axisLabel\":{\"rotate\":0}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"scroll\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'sum', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 0, 'bar', '', '合同额', 0, 'SalesOrder'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='sum' and columns like '%ld_salesorder:total:hdnGrandTotal:SalesOrder_%');
select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1,'sum', 'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N', 1, 'bar', '', '服务合同额', 0, 'ServiceContracts'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='sum' and columns like '%ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_account:accountname:accountname:Accounts_客户名称1:V', 0, 'text'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_account:accountname:accountname:Accounts_%');
delimiter;

select max(report_id) into @report_id from ld_customreport;
select report_id into @folder_id from ld_customreport where report_name='默认图表' and report_type='folder' and `deleted`=0 limit 1;
INSERT INTO ld_customreport
SELECT @report_id+1, '商机统计图_按销售负责人和销售阶段统计-多柱', '商机统计图_按所属行业和销售阶段统计-多柱', 'chart', @folder_id , NULL, 'Potentials', '2021-9-3 11:58:29', NULL, 0, NULL, 0, '', 'desc', 1, '', 'no', 0, 'no', 'no', ''
from DUAL
where NOT exists(select 1 from ld_customreport where report_name='商机统计图_按销售负责人和销售阶段统计-多柱' and report_type='chart' and `deleted`=0 and mainmodule="Potentials");

select report_id into @report_id from  ld_customreport where report_name="商机统计图_按销售负责人和销售阶段统计-多柱" and report_type="chart" and `deleted`=0 and mainmodule="Potentials";
INSERT INTO ld_customreport_chartset
SELECT @report_id,'{\"text\":\"商机统计图_按销售负责人和销售阶段统计-多柱\"}', 'multiple_bar', '{\"bottom\":{\"type\":\"category\",\"position\":\"bottom\",\"name\":\"\",\"axisLabel\":{\"rotate\":0}}}', '{\"left\":{\"type\":\"value\",\"position\":\"left\",\"name\":\"\"}}', '{\"type\":\"plain\",\"orient\":\"horizontal\"}', '{\"trigger\":\"axis\"}', '{\"feature\":{\"saveAsImage\":[\"\"]},\"right\":30}', 'no', NULL
from DUAL
where NOT exists(select 1 from ld_customreport_chartset where report_id=@report_id);

select max(column_id) into @column_id from ld_customreport_total_column;
INSERT INTO `ld_customreport_total_column`
select  @report_id  , @column_id+1, 'count', 'ld_potential:potential_no:potential_no:Potentials_编号:V', 0, 'bar', '', '机会数量', 0, 'Potentials'
from DUAL
where NOT exists(select 1 from ld_customreport_total_column where report_id=@report_id and total_type='count' and columns like '%ld_potential:potential_no:potential_no:Potentials_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_potential:smownerid:assigned_user_id:Potentials_销售负责人:V', 0, 'users'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_potential:smownerid:assigned_user_id:Potentials_%');

select max(group_id) into @group_id from ld_customreport_group;
INSERT INTO `ld_customreport_group`
select @group_id+1, @report_id,  'byField', 'ld_potential:sales_stage:sales_stage:Potentials_销售阶段1:V', 1, 'picklist'
from DUAL
where NOT exists(select 1 from ld_customreport_group where report_id=@report_id and groupbytype='byField' and columns like '%ld_potential:sales_stage:sales_stage:Potentials_%');
delimiter;
-- 2021-09-03

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

UPDATE ld_version SET old_version='V8.4.3.9',current_version='V8.4.3.9',remark='V8.4.3.9-20210903',wx_version='V8.4.3.9';
delimiter;