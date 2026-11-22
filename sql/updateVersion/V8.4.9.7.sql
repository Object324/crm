DROP PROCEDURE IF EXISTS `reset_producttoolfield_20230412`;
delimiter ||
CREATE  PROCEDURE `reset_producttoolfield_20230412`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_servicecontracts WHERE deleted=0) THEN
		SET @tabid=37;
		IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='salesorderid') AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list') THEN
			UPDATE ld_field SET uitype=202,columnname='source_list',fieldname='selectlistval',bigtype='selectsource',fieldlabel='选择源单' WHERE tabid=@tabid AND columnname='salesorderid';
			SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list' LIMIT 1);
			UPDATE ld_tranlabel SET fieldlabel='选择源单' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='合同订单';

			SET @disable_triggers='abcdefg';
			CALl AddColumn('ld_servicecontracts','entitytype','VARCHAR','100','');
			CALl AddColumn('ld_servicecontracts','source_list','TEXT','100','');
			SET @disable_triggers=NULL;


			SET @option_tabid=22;
			SET @presence=0;
			SET @isdefault=1;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',20,'yes',0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);

			SET @option_tabid=20;
			SET @presence=0;
			SET @isdefault=0;
			SET @approve_demand=0;
			INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
			SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',20,'yes',0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);


			SET @tabid=37;
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



			SET @tabid=37;
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


			SET @tabid=37;
			UPDATE ld_producttoolfield SET edit_permission=1 WHERE tabid=@tabid AND columnname IN ('entitytypeid','entitytype');
			ALTER TABLE ld_servicecontractsdetail MODIFY COLUMN entitytypeid INT(19) AFTER entitytype;

			SET @i=0;
			SET @seq=(SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid AND presence<>1 AND tablename='ld_products');
			UPDATE ld_producttoolfield SET sequence=sequence+4 WHERE tabid=@tabid AND presence<>1 AND sequence>@seq;
			UPDATE ld_producttoolfield SET sequence=@seq+1 WHERE tabid=@tabid AND columnname='entitytype';
			UPDATE ld_producttoolfield SET sequence=@seq+2 WHERE tabid=@tabid AND columnname='entitytypeid';
			UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;

			UPDATE ld_relatedlists SET type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' WHERE tabid IN (20,22) AND related_tabid=37;

			SET @tabid=37;
			SET @trigger_columnname='source_list';
			SET @effect_columnname='potentialid';
			SET @mysql="SELECT
				potentialid
			FROM (
				SELECT potentialid FROM ld_quotes WHERE deleted=0 AND FIND_IN_SET(quoteid,?)
				UNION
				SELECT potentialid FROM ld_salesorder WHERE deleted=0 AND FIND_IN_SET(salesorderid,?)
			) a
			WHERE potentialid>0 LIMIT 1";
			SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
			SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
			INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
			SELECT 'main',@trigger_fieldid,@effect_fieldid,'sql',@mysql FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
				AND @trigger_fieldid>0 AND @effect_fieldid>0;
		END IF;

	END IF;


end ||
delimiter;

CALL reset_producttoolfield_20230412();
DROP PROCEDURE IF EXISTS `reset_producttoolfield_20230412`;
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

	IF tmp_moduletype='productrel' THEN
		-- 有产品分录
		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','CUSTOMFORMPRODUCTREL','自定义表单，有产品分录','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMPRODUCTREL' AND languagetype='zh' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','CUSTOMFORMPRODUCTREL','Custom form with products entry','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMPRODUCTREL' AND languagetype='en' AND Labeltype='fixedstr');

SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,tmp_modulename,5,@maxtseq+1,tmp_modulename,1,'CUSTOMFORMPRODUCTREL' FROM DUAL
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

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,editpage)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment','listview' from dual
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


SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);


SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
	  -- 插入字段
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'accountid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,73,'account_id','客户名称',1,0,(@i:=@i+1),@blockid ,1,'V~O',1,0,0,'reference',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='accountid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'客户名称' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Account Name' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'received_amount','ld_invoice',1,71,'received_amount','已收总额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='received_amount');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='received_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'已收总额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Received Amount' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'receivable_balance','ld_outboundorder',1,71,'receivable_balance','应收余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='receivable_balance');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='receivable_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应收余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Receivable Balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_amount','ld_purchaseorder',1,71,'pay_amount','已付总额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_amount');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'已付总额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Total amount paid' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);

select max(fieldid) into @maxfieldid from ld_field ;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_balance','ld_purchaseorder',1,71,'pay_balance','应付余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应收余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Payable balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);




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
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'source_list','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,202,'selectlistval','选择源单',0,1,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,1,'selectsource',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'选择源单' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Select Sourcemodule' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,advance_demand,advance_demand_groups)
SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2,'null####[null,{"groupid":"1","columnname":"ld_users:status:status:Users_状态:V","comparator":"e","value":"Active","columncondition":""}]','All####[null,{"groupcondition":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'team_memberid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,154,'team_memberid','团队成员',1,1,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,'text',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'团队成员' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Team Members' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'tag','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,301,'tag','标签',0,2,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,'tag',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='tag');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='tag');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'标签' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Tag' FROM DUAL
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


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'exchtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,86,'exchtime','最新同步时间',1,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='exchtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='exchtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新同步时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'最新同步时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'exchmsg','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,19,'exchmsg','最新同步结果',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,'longtextarea',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='exchmsg');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='exchmsg');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新同步结果' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'最新同步结果' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'latestpushtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),2,86,'latestpushtime','最新推进时间',0,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新推进时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Latest push time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'total','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnGrandTotal','合计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='total');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'合计' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Total' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'subtotal','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnSubTotal','小计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='subtotal');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='subtotal');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'小计' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Subtotal' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'discount_amount','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnDiscountAmount','折扣直接降价',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='discount_amount');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='discount_amount');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'折扣直接降价' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Discount Amount' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'currency_id','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,117,'currency_id','币种',1,0,(@i:=@i+1),@blockid ,3,'V~M',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'币种' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Currency' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'conversion_rate','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'conversion_rate','汇率',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='conversion_rate');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='conversion_rate');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'汇率' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Conversion Rate' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

SET @i=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
		SET @j=0;
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,bigtype)
SELECT (@i:=@i+1),columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,(@j:=@j+1),@tabid,
       CASE
           WHEN tablename='ld_products' THEN 'ld_products'
           WHEN tablename='ld_customform20detail' THEN CONCAT('ld_',LOWER(tmp_modulename),'detail')
           WHEN tablename='ld_customform20detailscf' THEN CONCAT('ld_',LOWER(tmp_modulename),'detailscf')
           WHEN tablename='ld_customform20' THEN CONCAT('ld_',LOWER(tmp_modulename))
           END AS tablename,width,edit_permission,input_type,
       CASE
           WHEN tablename='ld_products' OR columnname IN ('listprice','taxprice','productcost') THEN fieldid
           WHEN columnname IN ('tax1','tax2','tax3') THEN (SELECT taxid FROM ld_inventorytaxinfo WHERE taxname=ld_producttoolfield.columnname)
           WHEN columnname IN ('discount_amount','adjustment','subtotal','total') THEN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=ld_producttoolfield.columnname)
           ELSE 0
           END AS fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,bigtype
FROM ld_producttoolfield
WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm20')
  AND NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid)
ORDER BY IFNULL(sequence,1000);

DELETE FROM ld_producttoolfield_formula WHERE producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid);
INSERT INTO ld_producttoolfield_formula(producttoolfieldid,formulastring,columnstring,sequence)
SELECT
    c.producttoolfieldid,
    a.formulastring,
    a.columnstring,
    a.sequence
FROM ld_producttoolfield_formula a
         LEFT JOIN ld_producttoolfield b ON a.producttoolfieldid=b.producttoolfieldid
         LEFT JOIN ld_producttoolfield c ON c.columnname=b.columnname AND c.tabid=@tabid
WHERE b.tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm20')
ORDER BY a.sequence;

DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_producttoolfield';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT
    b.languagetype,
    b.trantable,
    @tabid,
    c.producttoolfieldid,
    b.fieldlabel
FROM ld_producttoolfield a
         LEFT JOIN ld_tranlabel b ON b.Relateid=a.producttoolfieldid AND b.trantable='ld_producttoolfield'
         LEFT JOIN ld_producttoolfield c ON c.columnname=a.columnname AND c.tabid=@tabid
WHERE a.tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm20')
ORDER BY a.producttoolfieldid;


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
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','total',':','hdnGrandTotal',':',tmp_modulename,'_fieldlabel:N');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid',':','assigned_user_id',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','smcreatorid',':','smcreatorid',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,5,CONCAT('ld_',LOWER(tmp_modulename),':','createdtime',':','createdtime',':',tmp_modulename,'_fieldlabel:DT');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已批准');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已批准',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='审批中');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','审批中',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='未提交');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','未提交',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已驳回');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已驳回',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已拒绝');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已拒绝',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

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



SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  `",LOWER(tmp_modulename),"_no` VARCHAR(255) DEFAULT NULL,
	`accountid` INT(19) DEFAULT 0,
  `smownerid` INT(19) DEFAULT NULL,
  `smcreatorid` INT(19) DEFAULT NULL,
  `createdtime` DATETIME DEFAULT NULL,
  `modifiedby` INT(19) DEFAULT NULL,
  `modifiedtime` DATETIME DEFAULT NULL,
  `approvestatus` VARCHAR(50) DEFAULT '未提交',
  `approvetime` DATETIME DEFAULT NULL,
  `approveby` INT(19) DEFAULT NULL,
  `currentapprover` TEXT DEFAULT NULL,
  `print_times` INT(11) DEFAULT '0',
  `total` DECIMAL(25,6) DEFAULT NULL,
  `subtotal` DECIMAL(25,6) DEFAULT NULL,
  `adjustment` DECIMAL(25,6) DEFAULT NULL,
  `discount_type` INT(1) DEFAULT 0,
  `discount_percent` DECIMAL(25,3) NOT NULL DEFAULT '0.000',
  `discount_amount` DECIMAL(25,6) DEFAULT NULL,
  `s_h_amount` DECIMAL(25,3) DEFAULT NULL,
  `currency_id` INT(19) DEFAULT '1',
  `conversion_rate` DECIMAL(25,6) DEFAULT NULL,
  `currency_symbol` VARCHAR(30) DEFAULT NULL,
  `deleted` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql2=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detail` LIKE ld_salesorderdetail");
		SET @querysql3=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detailscf` LIKE ld_salesorderdetailscf");

PREPARE stmt FROM @querysql;
EXECUTE stmt;

PREPARE stmt FROM @querysql1;
EXECUTE stmt;

PREPARE stmt FROM @querysql2;
EXECUTE stmt;

PREPARE stmt FROM @querysql3;
EXECUTE stmt;
DROP PREPARE stmt;


	ELSEIF tmp_moduletype='basicrel' THEN
		-- 普通带单据分录的单据
		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','CUSTOMFORMBASICREL','自定义表单，有分录','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMBASICREL' AND languagetype='zh' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','CUSTOMFORMBASICREL','Custom form with entry','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMBASICREL' AND languagetype='en' AND Labeltype='fixedstr');

SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,tmp_modulename,5,@maxtseq+1,tmp_modulename,1,'CUSTOMFORMBASICREL' FROM DUAL
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

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,editpage)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment','listview' from dual
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



SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);

-- 插入字段
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'accountid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,73,'account_id','客户名称',1,0,(@i:=@i+1),@blockid ,1,'V~O',1,0,0,'reference',10,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='accountid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'客户名称' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Account Name' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'team_memberid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,154,'team_memberid','团队成员',1,1,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,'text',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'团队成员' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Team Members' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'tag','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,301,'tag','标签',0,2,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,'tag',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='tag');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='tag');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'标签' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Tag' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

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


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,advance_demand,advance_demand_groups)
SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2,'null####[null,{"groupid":"1","columnname":"ld_users:status:status:Users_状态:V","comparator":"e","value":"Active","columncondition":""}]','All####[null,{"groupcondition":""}]' FROM DUAL
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

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'exchtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,86,'exchtime','最新同步时间',1,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='exchtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='exchtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新同步时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'最新同步时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'exchmsg','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,19,'exchmsg','最新同步结果',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,'longtextarea',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='exchmsg');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='exchmsg');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新同步结果' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'最新同步结果' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'latestpushtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),2,86,'latestpushtime','最新推进时间',0,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新推进时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Latest push time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'source_list','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,202,'selectlistval','选择源单',0,1,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,1,'selectsource',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'选择源单' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Select Sourcemodule' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'total','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnGrandTotal','合计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='total');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'合计' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Total' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);



SET @j=0;
INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,bigtype)
SELECT @tabid,columnname,allowhide,
       CASE
           WHEN columnname IN ('entitytypeid','source_total','amount','remark','due_date','received_amount','cashbilldate') THEN CONCAT('ld_',LOWER(tmp_modulename),'detail')
           WHEN columnname IN ('total') THEN CONCAT('ld_',LOWER(tmp_modulename))
           END AS tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,(@j:=@j+1),width,edit_permission,input_type,
       fieldid,newline,is_checkimportfield,nullfield,bigtype
FROM ld_tabdetailfield
WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission')
  AND columnname IN ('entitytypeid','source_total','amount','remark','total','due_date','received_amount','cashbilldate')
  AND NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid)
ORDER BY IFNULL(sequence,1000);


DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_tabdetailfield' AND Relateid IN (
    SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname IN ('entitytypeid','source_total','amount','remark','total','due_date','received_amount','cashbilldate'));
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT
    b.languagetype,
    b.trantable,
    @tabid,
    c.tabdetailfieldid,
    b.fieldlabel
FROM ld_tabdetailfield a
         LEFT JOIN ld_tranlabel b ON b.Relateid=a.tabdetailfieldid AND b.trantable='ld_tabdetailfield'
         LEFT JOIN ld_tabdetailfield c ON c.columnname=a.columnname AND c.tabid=@tabid
WHERE a.tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission')
  AND a.columnname IN ('entitytypeid','source_total','amount','remark','total','due_date','received_amount','cashbilldate')
ORDER BY a.tabdetailfieldid;

DELETE FROM ld_option_module WHERE tabid=@tabid;
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
SELECT @tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence FROM ld_option_module
WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');

DELETE FROM ld_select_related_field WHERE module=tmp_modulename;
INSERT INTO ld_select_related_field(module,selectmodule,relatedstring)
SELECT tmp_modulename,selectmodule,relatedstring FROM ld_select_related_field
WHERE module='Commission';

DELETE FROM ld_tabdetailfield_formula WHERE tabdetailfieldid IN (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid);
INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
SELECT
    c.tabdetailfieldid,
    a.formulastring,
    a.columnstring,
    a.sequence
FROM ld_tabdetailfield_formula a
         LEFT JOIN ld_tabdetailfield b ON a.tabdetailfieldid=b.tabdetailfieldid
         INNER JOIN ld_tabdetailfield c ON c.columnname=b.columnname AND c.tabid=@tabid
WHERE b.tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission')
ORDER BY a.sequence;

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
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','total',':','hdnGrandTotal',':',tmp_modulename,'_fieldlabel:N');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid',':','assigned_user_id',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','smcreatorid',':','smcreatorid',':',tmp_modulename,'_fieldlabel:V');
INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,5,CONCAT('ld_',LOWER(tmp_modulename),':','createdtime',':','createdtime',':',tmp_modulename,'_fieldlabel:DT');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已批准');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已批准',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='审批中');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','审批中',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='未提交');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','未提交',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已驳回');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已驳回',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已拒绝');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已拒绝',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview
WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

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



SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  `",LOWER(tmp_modulename),"_no` VARCHAR(255) DEFAULT NULL,
	`accountid` INT(19) DEFAULT 0,
  `smownerid` INT(19) DEFAULT NULL,
  `smcreatorid` INT(19) DEFAULT NULL,
  `createdtime` DATETIME DEFAULT NULL,
  `modifiedby` INT(19) DEFAULT NULL,
  `modifiedtime` DATETIME DEFAULT NULL,
  `approvestatus` VARCHAR(50) DEFAULT '未提交',
  `approvetime` DATETIME DEFAULT NULL,
  `approveby` INT(19) DEFAULT NULL,
  `currentapprover` TEXT DEFAULT NULL,
  `print_times` INT(11) DEFAULT '0',
  `total` DECIMAL(25,6) DEFAULT NULL,
  `subtotal` DECIMAL(25,6) DEFAULT NULL,
  `deleted` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql2=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detail` (
  `lineitem_id` INT(19) NOT NULL AUTO_INCREMENT,
  `id` INT(19) DEFAULT 0,
  `entitytype` varchar(100) DEFAULT NULL,
  `entitytypeid` INT(19) DEFAULT 0,
  `entitytype_value` varchar(100) DEFAULT NULL,
  `amount` DECIMAL(25,2) DEFAULT '0',
  `remark` TEXT DEFAULT NULL,
  `source_total` DECIMAL(25,6) DEFAULT '0',
  `due_date` DATE DEFAULT NULL,
  `cashbilldate` DATE DEFAULT NULL,
  `received_amount` DECIMAL(25,6) DEFAULT '0',
  `sequence` INT(11) DEFAULT NULL,
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql3=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detailscf` (
  `lineitem_id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

PREPARE stmt FROM @querysql;
EXECUTE stmt;

PREPARE stmt FROM @querysql1;
EXECUTE stmt;

PREPARE stmt FROM @querysql2;
EXECUTE stmt;

PREPARE stmt FROM @querysql3;
EXECUTE stmt;
DROP PREPARE stmt;
END IF;

end ||
delimiter;





DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_161to200`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addcustomform_161to200`(
)
BEGIN

	declare i int default 161;

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

DELETE FROM ld_systems_deploy WHERE deploy_type>420 AND description LIKE '自定义表单%' AND description LIKE '%是否启用审批流程';
WHILE  i>=161 and i<=200 DO
				IF i>=161 and i<=180 THEN
					CALL ldcrm_addnewmoudule('productrel',CONCAT('CustomForm',LPAD(i,3,0)),CONCAT('自定义表单',LPAD(i,3,0)),CONCAT('Custom Form ',LPAD(i,3,0)),@myparenttabid,260+i);
				ELSEIF 	i>=181 and i<=200 THEN

					CALL ldcrm_addnewmoudule('basicrel',CONCAT('CustomForm',LPAD(i,3,0)),CONCAT('自定义表单',LPAD(i,3,0)),CONCAT('Custom Form ',LPAD(i,3,0)),@myparenttabid,260+i);
END IF;
				SET i=i+1;
END WHILE;
end ||
delimiter;

call ldcrm_addcustomform_161to200();
DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_161to200`;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_reset_share_action2tab`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_share_action2tab`(
)
BEGIN

	declare i int default 101;
	WHILE i<=200 DO
		SET @tmp_tabid=(SELECT tabid FROM ld_tab WHERE `name` = CONCAT('CustomForm',i));
INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
SELECT 0,@tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tmp_tabid AND share_action_id=0);

INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
SELECT 1,@tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tmp_tabid AND share_action_id=1);

INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
SELECT 2,@tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tmp_tabid AND share_action_id=2);

INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
SELECT 3,@tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tmp_tabid AND share_action_id=3);

UPDATE ld_def_org_share SET permission=3 WHERE tabid=@tmp_tabid;

SET i=i+1;
END WHILE;

end ||
delimiter;

CALL ldcrm_reset_share_action2tab();
DROP PROCEDURE IF EXISTS `ldcrm_reset_share_action2tab`;

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms');
UPDATE ld_tranlabel SET fieldlabel='自定义表单' WHERE Relateid=@parenttabid AND trantable='ld_parenttab' AND languagetype='zh' AND fieldlabel='Custom Forms';
delimiter;

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms');
UPDATE ld_tranlabel SET fieldlabel='Custom Forms' WHERE Relateid=@parenttabid AND trantable='ld_parenttab' AND languagetype='en' ;
delimiter;



DROP PROCEDURE IF EXISTS `ldcrm_add_biaoqian_20230412`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_biaoqian_20230412`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_module VARCHAR(100) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR
SELECT
    a.tabid,
    a.`name` AS tabname
FROM ld_tab a
WHERE EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=a.tabid)
  AND NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=a.tabid AND blocklabel='LBL_LABEL')
  AND a.`name` NOT IN ('WechatSession','CooperativeWork','MailManager','Emails','SmsPhrases','EmailListtmp','CommunicationLog',
                       'Rate','BankCash','BankAccountSet','OftenUseReport','Comprehensivereport','Customreport','CustomEcharts','RecycleBin','SalesGoal',
                       'Cache','ChinaMap','MobileReport','Dashboard','Home','Calendar','Webmails','Users','ModTracker','LessionPlan','ChannelCode','Mcommission')
ORDER BY a.tabid;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_tabid,tmp_module;
WHILE(tmp_tabid IS NOT NULL) DO
		-- 添加标签模块
		SET @modulename =tmp_module;
		SET @tabid=tmp_tabid;

		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		SET @blockname = 'LBL_LABEL';

		SET @i=0;
UPDATE ld_blocks SET sequence=sequence+1 WHERE tabid = @tabid;
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,@blockname,0,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);
UPDATE ld_blocks SET sequence=(@i:=@i+1) WHERE tabid = @tabid ORDER BY sequence;

-- 模块翻译
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'标签' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Label' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);

-- 插入字段显示格式
SET @relateid=@blockid;
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='tag';
		SET @fieldname='tag';
		SET @zh='标签';
		SET @en='Tag';
		SET @uitype=301;
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;
		SET @savedatabase = 'no';
		SET @allowedit = 'no';
		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

-- 字段翻译
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

-- 向表中添加字段
IF IFNULL(@tablename,'')<>'' THEN
		  CALL AddColumn(@tablename,@columnname,'varchar','50','');
END IF;

FETCH MYCUSOR INTO tmp_tabid,tmp_module;
END WHILE;
CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_add_biaoqian_20230412();
DROP PROCEDURE IF EXISTS `ldcrm_add_biaoqian_20230412`;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_reset_biaoqian101to160`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_biaoqian101to160`(
)
BEGIN
DECLARE i int DEFAULT 101;
WHILE i<=160 DO
SET @tmp_tabid=(SELECT tabid FROM ld_field WHERE tablename=CONCAT('ld_customform',i) AND fieldname='tag');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tmp_tabid AND blocklabel='LBL_LABEL');

UPDATE ld_field SET block=@blockid WHERE tabid=@tmp_tabid AND fieldname='tag';


SET i=i+1;
END WHILE;

end ||
delimiter;
CALL ldcrm_reset_biaoqian101to160();
DROP PROCEDURE IF EXISTS `ldcrm_reset_biaoqian101to160`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURRENTAPPROVALPROCEDURE','当前审批步骤','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CURRENTAPPROVALPROCEDURE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURRENTAPPROVALPROCEDURE','Current approval procedure','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CURRENTAPPROVALPROCEDURE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURRENTAPPROVER','当前处理人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CURRENTAPPROVER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURRENTAPPROVER','Current approver','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CURRENTAPPROVER' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_blocks SET display_status=1 WHERE blocklabel='LBL_LABEL' AND display_status=3;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPANSIONFORLABEL','开启-展开','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EXPANSIONFORLABEL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPANSIONFORLABEL','Expansion','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EXPANSIONFORLABEL' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COLLAPSEFORLABEL','开启-收起','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='COLLAPSEFORLABEL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COLLAPSEFORLABEL','Collapse','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='COLLAPSEFORLABEL' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2023-04-16

CALL AddColumn('ld_tab','mobiledetailinfoshowtype','char','10','tile');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addtable_fieldwxdetailinfo`;
delimiter ||
CREATE PROCEDURE `ldcrm_addtable_fieldwxdetailinfo`(
)
BEGIN

DECLARE tableExists INT DEFAULT 0;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'ld_fieldwxdetailinfo' AND TABLE_SCHEMA=DATABASE()) THEN
	CALL AddColumn('ld_tab','mobiledetailinfoshowtype','char','10','tile');

	CREATE TABLE if not EXISTS `ld_fieldwxdetailinfo` (
		`id` int(11) NOT NULL AUTO_INCREMENT,
		`tabid` int(11) DEFAULT 0 COMMENT '模块表ld_tab表id',
		`relatedtable` varchar(100) DEFAULT '' COMMENT '关联表ld_producttoolfield/ld_tabdetailfield',
		`columnname` varchar(100) DEFAULT NULL COMMENT '字段名对应ld_producttoolfield/ld_tabdetailfield的columnname',
		`sequence` int(4) DEFAULT 1 COMMENT '排序',
		`mobiledetailinfoshowtype` char(10) DEFAULT '' COMMENT '字段显示类型 fold折叠，table表格',
		PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;

	insert into ld_fieldwxdetailinfo (tabid,relatedtable,columnname,sequence,mobiledetailinfoshowtype)select tabid,'ld_producttoolfield',columnname,sequence,'fold' from ld_producttoolfield where mobiledetailshow='yes';
	update ld_producttoolfield set mobiledetailshow='no' where mobiledetailshow='yes';
	insert into ld_fieldwxdetailinfo (tabid,relatedtable,columnname,sequence,mobiledetailinfoshowtype)select tabid,'ld_tabdetailfield',columnname,sequence,'fold' from ld_tabdetailfield where mobiledetailshow='yes';
	update ld_tabdetailfield set mobiledetailshow='no' where mobiledetailshow='yes';

    update ld_tab set ld_tab.mobiledetailinfoshowtype='tile';
END IF;

END ||
delimiter;

call ldcrm_addtable_fieldwxdetailinfo();
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
UPDATE ld_tab SET mobiledetailinfoshowtype='tile' WHERE mobiledetailinfoshowtype IS NULL;
delimiter;

UPDATE ld_version SET old_version='V8.4.9.7',current_version='V8.4.9.7',remark='V8.4.9.7-20230414',wx_version='V8.4.9.6';
delimiter;