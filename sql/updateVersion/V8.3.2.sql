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
			IF tmp_defaultvalue='' THEN
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

UPDATE ld_field SET bigtype='picklist' WHERE uitype=15;
UPDATE ld_field SET bigtype=NULL WHERE bigtype='NULL';

alter table ld_articles change content content longtext;
delimiter;

CALL addtableIndex('ld_wx_users','idx_wx_user_id','id');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Articles';
update ld_tranlabel set fieldlabel = '裂变文章' where tabid = @tabid and Relateid = @tabid and languagetype = 'zh' and trantable = 'ld_tab';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Enterpriseselfbuiltapplicationname','企业自建应用名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Enterpriseselfbuiltapplicationname' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Enterpriseselfbuiltapplicationname','Enterprise self built application name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Enterpriseselfbuiltapplicationname' and Labeltype='fixedstr' and languagetype='en');
delimiter;

INSERT INTO ld_systems_deploy ( `deploy_value`, `deploy_type`, `description`, `setype`, `sequence`, `roottype`, `inputtype`, `presence`, `inputvalue`) 
SELECT '', 264, '(新)天润呼叫中心企业ID', '', 1000, NULL, NULL, 0, NULL  FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE description='(新)天润呼叫中心企业ID');

INSERT INTO ld_systems_deploy ( `deploy_value`, `deploy_type`, `description`, `setype`, `sequence`, `roottype`, `inputtype`, `presence`, `inputvalue`) 
SELECT '', 265, '(新)天润呼叫中心访问秘钥ID', '', 1000, NULL, NULL, 0, NULL  FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE description='(新)天润呼叫中心访问秘钥ID');

INSERT INTO ld_systems_deploy ( `deploy_value`, `deploy_type`, `description`, `setype`, `sequence`, `roottype`, `inputtype`, `presence`, `inputvalue`) 
SELECT '', 266, '(新)天润呼叫中心私有访问秘钥', '', 1000, NULL, NULL, 0, NULL  FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE description='(新)天润呼叫中心私有访问秘钥');
delimiter;

set @deploy_type = (select deploy_type from ld_systems_deploy where  description='(新)天润呼叫中心企业ID');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'企业ID' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'Enterprise ID' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

set @deploy_type = (select deploy_type from ld_systems_deploy where  description='(新)天润呼叫中心访问秘钥ID');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'秘钥ID' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'AccessKeyId' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

set @deploy_type = (select deploy_type from ld_systems_deploy where  description='(新)天润呼叫中心私有访问秘钥');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'秘钥' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'AccessKeySecret' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addnewmoudule`(
	tmp_moduletype VARCHAR(100),
	tmp_modulename VARCHAR(100),
	tmp_zhmoudulename VARCHAR(100),
	tmp_enmoudulename VARCHAR(100),
	tmp_parenttabid INT(19),
	tmp_deploy_type INT(19)
)
BEGIN

	IF tmp_moduletype='basic' THEN
		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'zh','CUSTOMFORMBASIC','自定义表单，没有单据分录','fixedstr' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMBASIC' AND languagetype='zh' AND Labeltype='fixedstr');

		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'en','CUSTOMFORMBASIC','Custom form without entry','fixedstr' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMBASIC' AND languagetype='en' AND Labeltype='fixedstr');

		-- 将tabsequence>3的值全部+1
		update ld_tab set tabsequence=tabsequence+1 where tabsequence>=4;

		SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
		INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
		SELECT @maxtabid+1,tmp_modulename,5,4,tmp_modulename,1,'CUSTOMFORMBASIC' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename);


		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tab',@tabid,@tabid,tmp_zhmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tab',@tabid,@tabid,tmp_enmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

		SET @labseq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid),0);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT tmp_parenttabid,@tabid,@labseq+1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid AND tabid=@tabid);

		SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
		INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
		SELECT @maxnum_id+1,tmp_modulename,getPY(tmp_zhmoudulename),1,1,1,'none',0,1,0 FROM DUAL
		WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
		UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

		INSERT INTO ld_modtracker_tabs(tabid,visible)
		SELECT @tabid,1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

		SET @i=0;
		INSERT INTO ld_profileallpermission(tabid,operation,sequence)
		SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
		WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
			('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView');

		INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
		SELECT @tabid,tmp_modulename,CONCAT('ld_',LOWER(tmp_modulename)),CONCAT(LOWER(tmp_modulename),'_no'),CONCAT(LOWER(tmp_modulename),'id'),CONCAT(LOWER(tmp_modulename),'id') FROM DUAl
		WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=tmp_modulename);


		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);


		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,CONCAT(LOWER(tmp_modulename),'_no'),'no',CONCAT('ld_',LOWER(tmp_modulename)),1,4,CONCAT(LOWER(tmp_modulename),'_no'),'单据编号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'单据编号' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Bill NO.' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		-- 新增两个字段 申请人姓名 申请人手机号
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'apply_name','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,4,'apply_name','申请人姓名',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='apply_name');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='apply_name');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'申请人姓名' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Applicant’s Name' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		-- 新增两个字段 申请人姓名 申请人手机号
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'apply_phone','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,4,'apply_phone','申请人手机号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='apply_phone');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='apply_phone');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'申请人手机号' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Applicant’s Phone Number' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );



		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'modifiedby','最新更新人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'modifiedtime','更新时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,609,'approvestatus','审批状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'approvetime','最新审批时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,131,'approveby','上一步审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,132,'currentapprover','当前审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'当前审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Current Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Print Times' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);


		SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+2,'已批准',0,0,tmp_modulename,3,1,2 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已批准');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+3,'审批中',0,0,tmp_modulename,3,1,3 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='审批中');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+4,'未提交',0,0,tmp_modulename,3,1,4 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='未提交');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+5,'已驳回',0,0,tmp_modulename,3,1,5 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已驳回');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+6,'已拒绝',0,0,tmp_modulename,3,1,6 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已拒绝');

		UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid',':','assigned_user_id',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','smcreatorid',':','smcreatorid',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','createdtime',':','createdtime',':',tmp_modulename,'_fieldlabel:DT');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,5,CONCAT('ld_',LOWER(tmp_modulename),':','apply_name',':','apply_name',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,6,CONCAT('ld_',LOWER(tmp_modulename),':','apply_phone',':','apply_phone',':',tmp_modulename,'_fieldlabel:V');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已批准');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已批准',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='审批中');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','审批中',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='未提交');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','未提交',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已驳回');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已驳回',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已拒绝');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已拒绝',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

		DELETE FROM ld_relatedlists WHERE tabid=@tabid;
		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-1','get_SharedUsers',(@i:=@i+1),'SharedUsers',0,'share','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-1' AND `name`='get_SharedUsers');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-7','get_viewhistory',(@i:=@i+1),'ViewHistory',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-7' AND `name`='get_viewhistory');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-10','get_changeview',(@i:=@i+1),'ChangeView',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-10' AND `name`='get_changeview');

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);


		INSERT INTO ld_def_org_share(tabid,permission,editstatus)
		SELECT @tabid,3,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);

		CALL addtabintoprofile(tmp_modulename,1);

		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 0,tmp_deploy_type,CONCAT(tmp_zhmoudulename,'是否启用审批流程'),tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=tmp_deploy_type);


		SET @approvename=CONCAT(tmp_zhmoudulename,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(tmp_zhmoudulename,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
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

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);



		SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
	`",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
	`",LOWER(tmp_modulename),"_no` VARCHAR(255) DEFAULT NULL,
	`smownerid` INT(19) DEFAULT NULL,
	`smcreatorid` INT(19) DEFAULT NULL,
	`apply_name` VARCHAR(100) DEFAULT NULL,
	`apply_phone` VARCHAR(20) DEFAULT NULL,
	`createdtime` DATETIME DEFAULT NULL,
	`modifiedby` INT(19) DEFAULT NULL,
	`modifiedtime` DATETIME DEFAULT NULL,
	`approvestatus` VARCHAR(50) DEFAULT '未提交',
	`approvetime` DATETIME DEFAULT NULL,
	`approveby` INT(19) DEFAULT NULL,
	`currentapprover` TEXT DEFAULT NULL,
	`print_times` INT(11) DEFAULT '0',
	`deleted` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

	SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");


		PREPARE stmt FROM @querysql;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql1;
		EXECUTE stmt;
		DROP PREPARE stmt;
		END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addambassador`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addambassador`(
)
BEGIN

	declare i int default 1;

	SET @maxid=(SELECT MAX(parenttabid) FROM ld_parenttab);
	SET @seq=(SELECT MAX(sequence) FROM ld_parenttab);
	INSERT INTO ld_parenttab(parenttabid,parenttab_label,sequence,visible,allocatetype)
	SELECT @maxid+1,'CustomForms',@seq+1,0,'all' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_parenttab WHERE parenttab_label='CustomForms');

	SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms');
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh','ld_parenttab',@myparenttabid, @myparenttabid,'自定义表单' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@myparenttabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_parenttab');
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en','ld_parenttab',@myparenttabid, @myparenttabid,'Custom Forms' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@myparenttabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_parenttab');


	CALL ldcrm_addnewmoudule('basic','Ambassador','推广大使','Promotion Ambassador',@myparenttabid,170+i);
end ||
delimiter;

CALL ldcrm_addambassador();
DROP PROCEDURE IF EXISTS `ldcrm_addambassador`;
DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule`;
delimiter;


UPDATE ld_desk SET fieldlabel='Message Archiving' WHERE labelbol= 'Wechatsession' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='会话存档' WHERE labelbol= 'Wechatsession' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

update ld_tab set description='',presence=0 where name="Ambassador";

DELETE FROM ld_systems_deploy WHERE description='推广大使是否启用审批流程' AND deploy_type<>267;
SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 1,267,'推广大使是否启用审批流程',"Ambassador",@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=267);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Optionaltag','可选标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Optionaltag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Optionaltag','Optional tag','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Optionaltag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectedTags','已选标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SelectedTags' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectedTags','Selected Tags','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SelectedTags' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Taggroupname','标签组名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Taggroupname' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Taggroupname','Tag group name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Taggroupname' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Selectatleastonemessagetypewhenautogreetingison','开启自动打招呼时，消息类型至少选择一种类型！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Selectatleastonemessagetypewhenautogreetingison' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Selectatleastonemessagetypewhenautogreetingison','Select at least one message type when auto greeting is on!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Selectatleastonemessagetypewhenautogreetingison' and Labeltype='jspop' and languagetype='en');
delimiter;

select tabid into @tabid from ld_tab where name='invoice';
update ld_relatedlists set actions='add' where  tabid=@tabid and name='get_paymentplan';
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInvoice';
update ld_relatedlists set actions='add' where  tabid=@tabid and name='get_sendpayment';
delimiter;

select tabid into @tabid from ld_tab where name='purchaseorder';
update ld_relatedlists set actions='add' where  tabid=@tabid and name='get_sendpayment';
delimiter;

call AddColumn('ld_account','report_wx_userid','int','11',0);
delimiter;

call AddColumn('ld_cloud_users','share','int','11',0);
call AddColumn('ld_account','report_type','varchar','10',0);
call AddColumn('ld_account','cloud_users_id','int','11',0);
delimiter;

call AddColumn('ld_ambassador','approvesubmitter','int','19',0);
call AddColumn('ld_ambassador','approvesubmittedtime','datetime','0',0);
call AddColumn('ld_ambassador','currentapprovestepid','int','19',0);
call AddColumn('ld_ambassador','wx_user_id','int','11',0);
delimiter;

alter table ld_field alter column allowedit set default 'yes';
alter table ld_field alter column allowedit_presence set default 'yes';
alter table ld_field alter column allowcreate set default 'yes';
alter table ld_field alter column allowcreate_presence set default 'yes';
alter table ld_field alter column allowdetail_presence set default 'yes';
delimiter;

update ld_field set allowedit = 'yes' where savedatabase = 'yes' and bigtype <> 'relatedmodulefield' and (allowedit = '' or allowedit is NULL);
delimiter;

call AddColumn('ld_ambassador','crm_user_id','int','19',0);
delimiter;

DELETE FROM ld_producttoolfield WHERE columnname='sf3' AND tablename IS NULL;
-- 2020-11-17

select tabid into @tabid from ld_tab where name='cashbill' ;
update ld_field  set  allowedit='no' where tabid=@tabid and columnname='cashtype';
delimiter;

SET @modulename='Potentials';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=(select max(sequence) from ld_field where block = @relateid);
SET @trantable='ld_field';
SET @tablename='ld_potential';
SET @columnname='oldcustomer_marketing';
SET @fieldname='oldcustomer_marketing';
SET @zh='老客户营销';
SET @en='Old customer marketing';
SET @uitype=15;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='NULL';
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
delimiter;

call AddColumn('ld_potential','oldcustomer_marketing','varchar','200',null);
delimiter;

insert into ld_picklist_set(listname,relatetable)
select 'oldcustomer_marketing','ld_field' from dual
where not exists(select 1 from ld_picklist_set where listname = 'oldcustomer_marketing' and relatetable = 'ld_field');
delimiter;

select listid into @listid from ld_picklist_set where listname = 'oldcustomer_marketing' and relatetable = 'ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'活跃客户（增购）',1 from DUAL
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '活跃客户（增购）');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'忠诚客户（续费）',2 from DUAL
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '忠诚客户（续费）');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'高NPS客户（转介绍）',2 from DUAL
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '高NPS客户（转介绍）');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Customerfunnel','客户漏斗','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Customerfunnel' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Customerfunnel','Customer funnel','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Customerfunnel' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_roleinfo_20201123`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_roleinfo_20201123`(
)
BEGIN
		SET @my_profileid=(SELECT profileid FROM ld_profile WHERE profilename='推广大使' ORDER BY profileid DESC LIMIT 1);
		DELETE FROM ld_profile2standardpermissions WHERE profileid=@my_profileid;
		IF @my_profileid>0  THEN
			INSERT INTO `ld_profile2standardpermissions` (`profileid`, `tabid`, `operation`, `permissions`, `sequence`, `relatednames`) VALUES (@my_profileid, '6', '1', '0', '1', NULL);
			INSERT INTO `ld_profile2standardpermissions` (`profileid`, `tabid`, `operation`, `permissions`, `sequence`, `relatednames`) VALUES (@my_profileid, '6', '4', '0', '2', NULL);
			INSERT INTO `ld_profile2standardpermissions` (`profileid`, `tabid`, `operation`, `permissions`, `sequence`, `relatednames`) VALUES (@my_profileid, '6', '11', '0', '6', NULL);
			INSERT INTO `ld_profile2standardpermissions` (`profileid`, `tabid`, `operation`, `permissions`, `sequence`, `relatednames`) VALUES (@my_profileid, '6', '12', '0', '7', NULL);
			INSERT INTO `ld_profile2standardpermissions` (`profileid`, `tabid`, `operation`, `permissions`, `sequence`, `relatednames`) VALUES (@my_profileid, '6', '22', '0', '10', NULL);
			INSERT INTO `ld_profile2standardpermissions` (`profileid`, `tabid`, `operation`, `permissions`, `sequence`, `relatednames`) VALUES (@my_profileid, '6', '29', '0', '12', NULL);
			INSERT INTO `ld_profile2standardpermissions` (`profileid`, `tabid`, `operation`, `permissions`, `sequence`, `relatednames`) VALUES (@my_profileid, '6', '38', '0', '14', NULL);
			INSERT INTO `ld_profile2standardpermissions` (`profileid`, `tabid`, `operation`, `permissions`, `sequence`, `relatednames`) VALUES (@my_profileid, '22', '4', '0', '2', NULL);

			DELETE FROM ld_profile2field WHERE profileid=@my_profileid;
			INSERT INTO ld_profile2field(profileid,tabid,fieldid,visible,readonly)
			SELECT @my_profileid,tabid,fieldid,visible,readonly FROM ld_profile2field WHERE profileid=(SELECT profileid FROM ld_profile LIMIT 1);
		END IF;
END ||
delimiter;

CALL ldcrm_reset_roleinfo_20201123();
DROP PROCEDURE IF EXISTS `ldcrm_reset_roleinfo_20201123`;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Ambassador' ORDER BY tabid DESC LIMIT 1);
delete from ld_profileallpermission where tabid=@tabid and operation=5;
delete from ld_profileallpermission where tabid=@tabid and operation=6;
-- 2020-11-24

CALL AddColumn('ld_ambassador','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform26','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform27','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform28','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform29','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform30','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform31','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform32','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform33','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform34','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform35','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform36','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform37','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform38','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform39','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform40','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform41','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform42','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform43','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform44','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform45','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform46','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform47','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform48','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform49','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform50','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform51','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform52','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform53','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform54','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform55','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform56','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform57','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform58','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform59','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform60','advance_stage','VARCHAR','100','');



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

UPDATE ld_version SET old_version='V8.3.2',current_version='V8.3.2',remark='V8.3.2-20201124',wx_version='V8.3.1';
delimiter;