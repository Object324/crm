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

set @tabid =(SELECT tabid  from ld_tab where name ='Users');
set @actionid =(SELECT max(actionid) from ld_actionmapping) +1 ;
set @maxSequence = (SELECT max(sequence) from ld_profileallpermission where tabid =@tabid)+1;
insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid,'Department',0,'DEPARTMENT'  from  dual
where not EXISTS(select 1 from ld_actionmapping where actionname='Department');
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@actionid,@maxSequence from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid);

set @actionid =(SELECT max(actionid) from ld_actionmapping) +1 ;
set @maxSequence = (SELECT max(sequence) from ld_profileallpermission where tabid =@tabid)+1;

insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid,'Job level',0,'JOBLEVEL'  from  dual
where not EXISTS(select 1 from ld_actionmapping where actionname='Job level');
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@actionid,@maxSequence from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid);
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DEPARTMENT',"部门",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DEPARTMENT' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DEPARTMENT',"Department",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DEPARTMENT' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','JOBLEVEL',"职位级别",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='JOBLEVEL' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','JOBLEVEL',"Joblevel",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='JOBLEVEL' and Labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTACCOUNT','请先选择客户','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol='PLEASESELECTACCOUNT' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTACCOUNT','Please select account first','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol='PLEASESELECTACCOUNT' and Labeltype='jspop' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COLNOTDUPLICATE','列不能重复','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol='COLNOTDUPLICATE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COLNOTDUPLICATE','Please select account first','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol='COLNOTDUPLICATE' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
set @maxBlockid = (SELECT id from ld_blocks_seq );
set @tabid = (SELECT tabid from ld_tab where name ='Products' );
set @sequence = (SELECT max(sequence) from ld_blocks where tabid =@tabid );
INSERT INTO ld_blocks(`blockid`, `tabid`, `blocklabel`, `sequence`, `show_title`, `visible`, `create_view`, `edit_view`, `detail_view`, `display_status`, `iscustom`, `linkid`) select @maxBlockid+1, @tabid, 'LBL_PRODUCT_DETAILS', @sequence+1, 0, 0, 0, 0, 0, 1, 0, NULL FROM DUAL  WHERE NOT EXISTS(SELECT 1 FROM ld_blocks WHERE blocklabel='LBL_PRODUCT_DETAILS' and tabid =@tabid);
set @blockid = (SELECT blockid FROM ld_blocks where blocklabel='LBL_PRODUCT_DETAILS' and tabid =@tabid);

INSERT INTO ld_tranlabel(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_blocks', @tabid, @blockid, 'Product Details' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid and fieldlabel='Product Details' and trantable ='ld_blocks');
INSERT INTO ld_tranlabel(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_blocks', @tabid, @blockid, '产品详情' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid and fieldlabel='产品详情' and trantable ='ld_blocks');

INSERT INTO ld_field(`tabid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select  @tabid, 'productdetails', 'yes', 'ld_productcf', 0, '230', 'productdetails', '产品详情', 0, 1, NULL, 100, 1, @blockid, 1, 'V~O', 0, NULL, 'BAS', 1, NULL, 0, 0, 0, 1, 0, 0, NULL, NULL, 2, 0, 'yes', 'yes', 'yes', 'yes', 'yes', 0, 0, 'yes', NULL, NULL, 0, NULL, 'yes', NULL from  dual where not exists (select  1 from ld_field where tabid = @tabid and columnname ='productdetails');

set @fieldid = (select fieldid from ld_field where tabid =@tabid and columnname ='productdetails');
INSERT INTO ld_tranlabel(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Product Details' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid and fieldlabel='Product Details' and trantable ='ld_field');
INSERT INTO ld_tranlabel(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '产品详情' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid and fieldlabel='产品详情' and trantable ='ld_field');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CALLDOCUMENTTEMPLATE','调用文档模板','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'CALLDOCUMENTTEMPLATE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CALLDOCUMENTTEMPLATE','Call Document Template','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'CALLDOCUMENTTEMPLATE' and labeltype='fixedstr' and languagetype='en');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_Signin_Optionalmodule_Customization','签到源单类型定制','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_Signin_Optionalmodule_Customization' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_Signin_Optionalmodule_Customization','Sign in optionalmodule customization','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_Signin_Optionalmodule_Customization' and labeltype='fixedstr');
delimiter;

update ld_settings_field set name='LBL_Signin_Optionalmodule_Customization' where name='LBL_Optionalmodule_Customization' and blockid='1';
delimiter;

UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);

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

		SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
		INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
		SELECT @maxtabid+1,tmp_modulename,5,@maxtseq+1,tmp_modulename,1,'CUSTOMFORMBASIC' FROM DUAL
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
				
	ELSEIF tmp_moduletype='productrel' THEN
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
		SELECT @tabid,@maxfieldid+1,'','no','',1,202,'','选择源单',1,0,(@i:=@i+1),@blockid ,1,'V~O',1,1,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND uitype=202);

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
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
		INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield)
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
		END AS fieldid,newline,defaultcolumn,is_checkimportfield,nullfield
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


		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
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
		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield)
		SELECT @tabid,columnname,allowhide,
			CASE
				WHEN columnname IN ('entitytypeid','source_total','amount','remark','due_date','received_amount','cashbilldate') THEN CONCAT('ld_',LOWER(tmp_modulename),'detail')
				WHEN columnname IN ('total') THEN CONCAT('ld_',LOWER(tmp_modulename))
			END AS tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,(@j:=@j+1),width,edit_permission,input_type,
			fieldid,newline,is_checkimportfield,nullfield
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

DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_26to60`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addcustomform_26to60`(
)
BEGIN

	declare i int default 26; 

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

	DELETE FROM ld_systems_deploy WHERE  deploy_type>213 AND description LIKE '自定义表单%' AND description LIKE '%是否启用审批流程';
	WHILE i<=60 DO 
		IF i>=46 AND i<=60 THEN
			CALL ldcrm_addnewmoudule('basic',CONCAT('CustomForm',LPAD(i,2,0)),CONCAT('自定义表单',LPAD(i,2,0)),CONCAT('Custom Form ',LPAD(i,2,0)),@myparenttabid,195+i);
		ELSEIF i>=36 AND i<=45 THEN
			CALL ldcrm_addnewmoudule('productrel',CONCAT('CustomForm',LPAD(i,2,0)),CONCAT('自定义表单',LPAD(i,2,0)),CONCAT('Custom Form ',LPAD(i,2,0)),@myparenttabid,195+i);
		ELSEIF i>25 AND i<=35 THEN
			CALL ldcrm_addnewmoudule('basicrel',CONCAT('CustomForm',LPAD(i,2,0)),CONCAT('自定义表单',LPAD(i,2,0)),CONCAT('Custom Form ',LPAD(i,2,0)),@myparenttabid,195+i);
		END IF;
		SET i=i+1;
	END WHILE;

end ||
delimiter;

CALL ldcrm_addcustomform_26to60();
DROP PROCEDURE IF EXISTS `ldcrm_addcustomform_26to60`;
DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule`;
delimiter;

CREATE TABLE  if not exists `ld_detailfieldrule` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `tabid` int(19) DEFAULT NULL,
  `rulename` varchar(200) DEFAULT NULL,
  `columnname` varchar(100) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smcreator` int(19) DEFAULT NULL,
  `enablestatus` varchar(20) DEFAULT 'yes',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_detailfieldrule_operate` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `columnname` varchar(200) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `basicsearchid` int(19) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_detailfieldruleadvancesearch` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `basicsearchid` int(19) DEFAULT NULL,
  `columnname` varchar(255) DEFAULT NULL,
  `comparator` varchar(20) DEFAULT NULL,
  `value` varchar(100) DEFAULT NULL,
  `columncondition` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_detailfieldrulebasicsearch` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `ruleid` int(19) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  `value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WHETHERITISAREQUIREDFILED','是否必填','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WHETHERITISAREQUIREDFILED' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WHETHERITISAREQUIREDFILED','Whether it is a required filed','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WHETHERITISAREQUIREDFILED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Automaticallysignin','模块新增时自动签到','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Automaticallysignin' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Automaticallysignin','Automatically sign in when the module is added','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Automaticallysignin' and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_option_module', 'required', 'int', '2', null);
CALL AddColumn('ld_option_module', 'automaticallysign', 'int', '2', null);

update ld_settings_field set name='LBL_Optionalmodule_Customization', active=0 where name='LBL_Signin_Optionalmodule_Customization' and blockid='1';
update ld_settings_field set name='LBL_Optionalmodule_Customization', active=0 where description='LBL_Optionalmodule_Customization_Description' and blockid='1';
delimiter;

UPDATE ld_tabdetailfield SET defaultcolumn = 5,allowhide = 'yes' WHERE columnname = 'amount' AND REPLACE(REPLACE(tablename,'ld_customform',''),'detail','') BETWEEN 21 AND 35;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_signin_fields`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_signin_fields`(
    tmp_tablename VARCHAR(100)
)
BEGIN
    call AddColumn(tmp_tablename,'sign_longtitude','varchar',200,NULL);
    call AddColumn(tmp_tablename,'sign_latitude','varchar',200,NULL);
    call AddColumn(tmp_tablename,'sign_location_address','varchar',200,NULL);
END||
delimiter;

CALL	ldcrm_add_signin_fields('ld_account');
CALL	ldcrm_add_signin_fields('ld_contactdetails');
CALL	ldcrm_add_signin_fields('ld_contactrecords');
CALL	ldcrm_add_signin_fields('ld_potential');
CALL	ldcrm_add_signin_fields('ld_troubletickets');
CALL	ldcrm_add_signin_fields('ld_project');
CALL	ldcrm_add_signin_fields('ld_campaign');
CALL	ldcrm_add_signin_fields('ld_products');

DROP PROCEDURE  ldcrm_add_signin_fields;

UPDATE  ld_contactrecords SET
	sign_longtitude=longtitude,
	sign_latitude=latitude,
	sign_location_address=location_address
WHERE IFNULL(longtitude,'')<>'' AND IFNULL(longtitude,'')<>''
  AND sign_longtitude Is NULL
  AND sign_latitude Is NULL;

UPDATE  ld_troubletickets SET
	sign_longtitude=longtitude,
	sign_latitude=latitude,
	sign_location_address=location_address
WHERE IFNULL(longtitude,'')<>'' AND IFNULL(longtitude,'')<>''
  AND sign_longtitude Is NULL
  AND sign_latitude Is NULL;
delimiter;

select fieldid into @fieldid from ld_field where tabid = 6 and fieldname = 'legal_representative';
update ld_tranlabel set fieldlabel = 'Legal representative' where tabid = 6 and Relateid = @fieldid and languagetype = 'en' and trantable='ld_field';
delimiter;

CALL AddColumn('ld_productcf','productdetails','text',0,null);
delimiter;
-- 2020-07-24

UPDATE ld_option_module SET datarang='all',maxrowsshow=5 WHERE datarang IS NULL OR maxrowsshow=0 AND tabid>160;

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

UPDATE ld_version SET old_version='V8.1.5',current_version='V8.1.5',remark='V8.1.5-20200724',wx_version='V8.1.5';
delimiter;