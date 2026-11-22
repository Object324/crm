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

SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=21 AND columnname='source_list' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=21 AND columnname='contactid' LIMIT 1);
DELETE FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfieldformula`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_relatedlistsinfo`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_relid INT(19) DEFAULT 0;
	DECLARE tmp_fangfa VARCHAR(100) DEFAULT '';

	DECLARE tmp_minid INT(19) DEFAULT 0;
	DECLARE tmp_isshow INT(1) DEFAULT 0;

	
	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				IFNULL(a.tabid,0) AS tabid,
				a.related_tabid,
				IFNULL(a.related_coltable,'') AS related_coltable,
				(SELECT MIN(relation_id) FROM ld_relatedlists WHERE IFNULL(tabid,0)=IFNULL(a.tabid,0) AND related_tabid=a.related_tabid AND IFNULL(related_coltable,'')=IFNULL(a.related_coltable,'')) AS minid,
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_relatedlists WHERE IFNULL(tabid,0)=IFNULL(a.tabid,0) AND related_tabid=a.related_tabid AND IFNULL(related_coltable,'')=IFNULL(a.related_coltable,'') AND presence=0) THEN 0
					ELSE 1
				END AS is_show
			FROM ld_relatedlists a
			WHERE a.related_tabid NOT IN (-1,0)
			GROUP BY a.tabid,a.related_tabid,a.label,related_coltable
			HAVING COUNT(a.relation_id)>1;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_relid,tmp_fangfa,tmp_minid,tmp_isshow;
	WHILE(tmp_tabid IS NOT NULL) DO
		DELETE  FROM ld_relatedlists WHERE IFNULL(tabid,0)=tmp_tabid AND related_tabid=tmp_relid AND IFNULL(related_coltable,'')=tmp_fangfa AND relation_id>tmp_minid;
		IF tmp_isshow=0 THEN
			UPDATE ld_relatedlists SET presence=0 WHERE IFNULL(tabid,0)=tmp_tabid AND related_tabid=tmp_relid AND relation_id=tmp_minid;
		ELSE
			UPDATE ld_relatedlists SET presence=1 WHERE IFNULL(tabid,0)=tmp_tabid AND related_tabid=tmp_relid AND relation_id=tmp_minid;
		END IF;
		FETCH MYCUSOR INTO tmp_tabid,tmp_relid,tmp_fangfa,tmp_minid,tmp_isshow;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_relatedlistsinfo();
DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedlistsinfo`;
-- 2021-06-07

SET @labelbol=UPPER('VALIDATASAVEREMARK');
SET @labeltype='fixedstr';
SET @zh='(不满足条件的时候弹出提示信息)';
SET @en='(Remind when the condition is not met)';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@labelbol AND labeltype=@labeltype);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@labelbol AND labeltype=@labeltype);
delimiter;

UPDATE ld_entityname SET fieldname='last_name' WHERE tabid=29 AND fieldname='user_name';
-- 2021-06-08

CALL AddColumn('ld_tab','main_tablename','varchar','100','');
CALL AddColumn('ld_tab','custom_tablename','varchar','100','');
CALL AddColumn('ld_tab','primary_key','varchar','100','');

UPDATE ld_tab a
SET a.main_tablename=(SELECT tablename FROM ld_field WHERE tabid=a.tabid AND columnname='createdtime' LIMIT 1)
WHERE a.tabid>0
	AND IFNULL((SELECT tablename FROM ld_field WHERE tabid=a.tabid AND columnname='createdtime' LIMIT 1),'')<>''
    AND IFNULL(a.main_tablename,'')='';
delimiter;
   
UPDATE ld_tab a
SET a.custom_tablename=(
	CASE
		WHEN EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT(IFNULL(main_tablename,''),'cf')) THEN CONCAT(IFNULL(main_tablename,''),'cf')
		WHEN EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT(IFNULL(main_tablename,''),'scf')) THEN CONCAT(IFNULL(main_tablename,''),'scf')
	END)
WHERE IFNULL(a.main_tablename,'')<>''
    AND IFNULL(a.custom_tablename,'')='';
    
UPDATE ld_tab SET custom_tablename='ld_productcf' WHERE tabid=14;
UPDATE ld_tab SET custom_tablename='ld_contactscf' WHERE tabid=13;
UPDATE ld_tab SET custom_tablename='ld_ticketcf' WHERE tabid=4;
delimiter;

UPDATE ld_tab a
SET a.primary_key=(SELECT entityidfield FROM ld_entityname WHERE modulename=a.`name` LIMIT 1)
WHERE IFNULL(a.main_tablename,'')<>''
	AND IFNULL(a.custom_tablename,'')<>''
	AND IFNULL(a.primary_key,'')=''
	AND IFNULL((SELECT entityidcolumn FROM ld_entityname WHERE modulename=a.`name` LIMIT 1),'')<>'';
UPDATE ld_tab SET primary_key='activityid' WHERE tabid=16;
delimiter;


CALL AddColumn('ld_option_module','withbalanceqtycondition','decimal','10,4',0.0000);
delimiter;

ALTER TABLE ld_option_module MODIFY COLUMN withbalanceqtycondition decimal(10,4) default 0.0000;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WithBalanceQtyCondition','剩余{quantity}为0时自动带出','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'WithBalanceQtyCondition' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WithBalanceQtyCondition',"When the remaining {quantity} is 0, it will be brought out automatically",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'WithBalanceQtyCondition' and labeltype = 'fixedstr');
delimiter;

set @sequence=1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewServiceChargeNums','fixedstr','ld_account.accountid','count','index.php?pageto_module=ServiceCharge&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewServiceChargeNums');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewServiceChargeNums';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:createdtime:createdtime:ServiceCharge_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:createdtime:createdtime:ServiceCharge%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:approvestatus:approvestatus:ServiceCharge_审批状态:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:approvestatus:approvestatus:ServiceCharge%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewServiceChargeNums','新增{$ServiceCharge.ServiceCharge}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewServiceChargeNums' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewServiceChargeNums','new {$ServiceCharge.ServiceCharge}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewServiceChargeNums' and Labeltype='fixedstr');
delimiter;

update ld_homestuffdetail set cssname="item-ico-purchaseorder",icon="crm_ServiceCharge.png" where stufflabel="NewServiceChargeNums";
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_expensebudget`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addnewmoudule_expensebudget`(
	tmp_modulename VARCHAR(100),
	tmp_zhmoudulename VARCHAR(100),
	tmp_enmoudulename VARCHAR(100),
	tmp_parenttabid INT(19),
	tmp_deploy_type INT(19)
)
BEGIN
		SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @tabsequence=(select tabsequence from ld_tab where name="Expense");
    update ld_tab set tabsequence=tabsequence+1  where tabsequence>@tabsequence;
		INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
		SELECT @maxtabid+1,tmp_modulename,0,@tabsequence+1,tmp_modulename,1,'DOCUMENTENTRY' FROM DUAL
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
		SELECT @maxnum_id+1,tmp_modulename,'BUD',1,1,1,'none',0,0,0 FROM DUAL
		WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
		UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

		INSERT INTO ld_modtracker_tabs(tabid,visible)
		SELECT @tabid,1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

		SET @i=0;
		INSERT INTO ld_profileallpermission(tabid,operation,sequence)
		SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
		WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
			('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView','Advance','DownLoad','Preview','DownloadSelected','FileReadHistory');

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

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'expensebudget_type','no',CONCAT('ld_',LOWER(tmp_modulename)),1,15,'expensebudget_type','预算类型',1,0,(@i:=@i+1),@blockid ,1,'V~O',1,0,0,1,'text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='expensebudget_type');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='expensebudget_type');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'预算类型' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'budget type' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
	  SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,CONCAT(LOWER(tmp_modulename),'_no'),'no',CONCAT('ld_',LOWER(tmp_modulename)),1,4,CONCAT(LOWER(tmp_modulename),'_no'),'单据编号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,2,NULL,NULL,0 FROM DUAL
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
		SELECT @tabid,@maxfieldid+1,'budget_start_date','no',CONCAT('ld_',LOWER(tmp_modulename)),1,5,'budget_start_date','预算起始日期',0,0,(@i:=@i+1),@blockid ,1,'D~M',1,0,1,1,'date',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='budget_start_date');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='budget_start_date');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'预算起始日期' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Budget start date' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

     SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'budget_end_date','no',CONCAT('ld_',LOWER(tmp_modulename)),1,5,'budget_end_date','预算结束日期',0,0,(@i:=@i+1),@blockid ,1,'D~M',1,0,1,1,'date',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='budget_end_date');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='budget_end_date');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'预算结束日期' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Budget end date' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


    SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'budget_person','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,154,'budget_person','预算人员',0,2,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,1,'text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='budget_person');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='budget_person');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'预算人员' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Scope of budget personnel' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

    SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'budget_indicators','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,15,'budget_indicators','预算指标',0,2,(@i:=@i+1),@blockid ,1,'V~M',1,0,1,1,'picklist',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='budget_indicators');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='budget_indicators');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'预算指标' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Budget Indicators' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


    SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'budget_rate','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,7,'budget_rate','预算比例(%)',0,2,(@i:=@i+1),@blockid ,1,'NN~M~10,2',1,0,1,1,'number',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='budget_rate');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='budget_rate');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'预算比例(%)' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Budget Rate(%)' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


    SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'indicators_start_date','no',CONCAT('ld_',LOWER(tmp_modulename)),1,5,'indicators_start_date','指标起始日期',0,0,(@i:=@i+1),@blockid ,1,'D~M',1,0,1,1,'date',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='indicators_start_date');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='indicators_start_date');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'指标起始日期' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Indicators start date' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

    SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'indicators_end_date','no',CONCAT('ld_',LOWER(tmp_modulename)),1,5,'indicators_end_date','指标结束日期',0,0,(@i:=@i+1),@blockid ,1,'D~M',1,0,1,1,'date',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='indicators_end_date');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='indicators_end_date');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'指标结束日期' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Indicators end date' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'modifiedby','最新更新人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'modifiedtime','更新时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,609,'approvestatus','审批状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,NULL,NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'approvetime','最新审批时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,131,'approveby','上一步审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,132,'currentapprover','当前审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
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
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',1,0,1,2,'text',NULL,0 FROM DUAL
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
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'total','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnGrandTotal','合计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2,'currency',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='total');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'合计' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Total' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @j=IFNULL((SELECT MAX(sequence) FROM ld_tabdetailfield WHERE tabid=@tabid),0);
		SET @td_columnname='lin_users_id';
		SET @td_zhlable='姓名';
		SET @td_enlable='Last Name';

		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase)
		SELECT @tabid,@td_columnname,'no',CONCAT('ld_',LOWER(tmp_modulename),'detail'),@td_zhlable,NULL,0,'Reference','V~O',(@j:=@j+1),20,1,0,0,0,0,0,'Users','all','none',20,'reference','yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname);


		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tabdetailfield',@tabid,@relateid,@td_zhlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tabdetailfield',@tabid,@relateid,@td_enlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

		SET @td_columnname='reference_amount';
		SET @td_zhlable='指标金额';
		SET @td_enlable='Reference_amount';

		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase)
		SELECT @tabid,@td_columnname,'no',CONCAT('ld_',LOWER(tmp_modulename),'detail'),@td_zhlable,NULL,0,'Amount','N~O~25,6',(@j:=@j+1),24,1,0,0,0,0,0,NULL,NULL,NULL,0,NULL,'yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname);


		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tabdetailfield',@tabid,@relateid,@td_zhlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tabdetailfield',@tabid,@relateid,@td_enlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);


		SET @td_columnname='budget_rate';
		SET @td_zhlable='预算比例(%)';
		SET @td_enlable='Budget Rate(%)';

		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase)
		SELECT @tabid,@td_columnname,'no',CONCAT('ld_',LOWER(tmp_modulename),'detail'),@td_zhlable,NULL,0,'Num','N~O~25,2',(@j:=@j+1),22,0,0,0,0,0,0,NULL,NULL,NULL,0,NULL,'yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname);


		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tabdetailfield',@tabid,@relateid,@td_zhlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tabdetailfield',@tabid,@relateid,@td_enlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);



		SET @td_columnname='amount';
		SET @td_zhlable='金额';
		SET @td_enlable='Amount';

		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase)
		SELECT @tabid,@td_columnname,'no',CONCAT('ld_',LOWER(tmp_modulename),'detail'),@td_zhlable,NULL,0,'Amount','N~O~25,6',(@j:=@j+1),24,1,0,0,0,0,0,NULL,NULL,NULL,0,NULL,'yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname);


		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tabdetailfield',@tabid,@relateid,@td_zhlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tabdetailfield',@tabid,@relateid,@td_enlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);


		SET @td_columnname='adjustment_amount';
		SET @td_zhlable='调整';
		SET @td_enlable='Adjustment Amount';

		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase)
		SELECT @tabid,@td_columnname,'no',CONCAT('ld_',LOWER(tmp_modulename),'detail'),@td_zhlable,NULL,0,'Amount','N~O~25,6',(@j:=@j+1),24,1,0,0,0,0,0,NULL,NULL,NULL,0,NULL,'yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname);


		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tabdetailfield',@tabid,@relateid,@td_zhlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tabdetailfield',@tabid,@relateid,@td_enlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);



		SET @td_columnname='budget_amount';
		SET @td_zhlable='预算金额';
		SET @td_enlable='Budget Amount';

		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase)
		SELECT @tabid,@td_columnname,'no',CONCAT('ld_',LOWER(tmp_modulename),'detail'),@td_zhlable,NULL,0,'Amount','N~O~25,6',(@j:=@j+1),24,1,0,0,0,0,0,NULL,NULL,NULL,0,NULL,'yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname);


		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tabdetailfield',@tabid,@relateid,@td_zhlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tabdetailfield',@tabid,@relateid,@td_enlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);


		SET @td_columnname='description';
		SET @td_zhlable='备注';
		SET @td_enlable='Description';

		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase)
		SELECT @tabid,@td_columnname,'no',CONCAT('ld_',LOWER(tmp_modulename),'detail'),@td_zhlable,NULL,0,'TextArea','V~O',(@j:=@j+1),40,1,0,0,0,0,0,NULL,NULL,NULL,0,NULL,'yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname);


		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tabdetailfield',@tabid,@relateid,@td_zhlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tabdetailfield',@tabid,@relateid,@td_enlable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);


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

		SET @i=-1;
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:expensebudget_no:expensebudget_no:ExpenseBudget_fieldlabel:V';
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:expensebudget_type:expensebudget_type:ExpenseBudget_fieldlabel:V';
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:budget_start_date:budget_start_date:ExpenseBudget_fieldlabel:D';
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:budget_end_date:budget_end_date:ExpenseBudget_fieldlabel:D';
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:budget_person:budget_person:ExpenseBudget_fieldlabel:V';

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:total:hdnGrandTotal:ExpenseBudget_fieldlabel:N';
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:approvestatus:approvestatus:ExpenseBudget_fieldlabel:V';
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:smownerid:assigned_user_id:ExpenseBudget_fieldlabel:V';
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,@i:=@i+1,'ld_expensebudget:modifiedtime:modifiedtime:ExpenseBudget_fieldlabel:DT';

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
  `expensebudget_type` VARCHAR(50) DEFAULT '',
  `budget_start_date` DATE DEFAULT NULL,
  `budget_end_date` DATE DEFAULT NULL,
  `budget_person` TEXT DEFAULT NULL,
  `budget_indicators` VARCHAR(50) DEFAULT '',
  `budget_rate` DECIMAL(10,2) DEFAULT '3.00',
  `indicators_start_date` DATE DEFAULT NULL,
  `indicators_end_date` DATE DEFAULT NULL,
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
  `lin_users_id` INT(19) DEFAULT 0,
  `reference_amount` DECIMAL(25,6) DEFAULT '0',
	`budget_rate` DECIMAL(25,2) DEFAULT '0',
  `amount` DECIMAL(25,6) DEFAULT '0',
  `adjustment_amount` DECIMAL(25,6) DEFAULT '0',
  `budget_amount` DECIMAL(25,6) DEFAULT '0',
  `description` TEXT DEFAULT NULL,
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


		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ExpenseBudget');
		IF NOT EXISTS (SELECT 1 FROM ld_fieldrule WHERE tabid=@tabid) THEN
			INSERT INTO ld_fieldrule(tabid,rulename,columnname,createdtime,smcreator,enablestatus)
			SELECT @tabid,'根据预算类型控制单据头显示','expensebudget_type',NOW(),1,'yes';

			SET @myruleid=(SELECT id FROM ld_fieldrule WHERE tabid=@tabid AND columnname='expensebudget_type' LIMIT 1);
			INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`)
			SELECT @myruleid,'n','直接录入预算';

			SET @mysearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@myruleid AND comparator='n' AND `value`='直接录入预算' LIMIT 1);
			INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
			SELECT 'budget_indicators','display',@mysearchid;
			INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
			SELECT 'budget_rate','display',@mysearchid;
			INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
			SELECT 'indicators_start_date','display',@mysearchid;
			INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
			SELECT 'indicators_end_date','display',@mysearchid;
		END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_detailfieldrule WHERE tabid=@tabid) THEN
			INSERT INTO ld_detailfieldrule(tabid,rulename,columnname,createdtime,smcreator,enablestatus)
			SELECT @tabid,'根据预算类型控制单据分录显示','expensebudget_type',NOW(),1,'yes';

			SET @myruleid=(SELECT id FROM ld_detailfieldrule WHERE tabid=@tabid AND columnname='expensebudget_type' LIMIT 1);
			INSERT INTO ld_detailfieldrulebasicsearch(ruleid,comparator,`value`)
			SELECT @myruleid,'n','直接录入预算';

			SET @mysearchid=(SELECT id FROM ld_detailfieldrulebasicsearch WHERE ruleid=@myruleid AND comparator='n' AND `value`='直接录入预算' LIMIT 1);
			INSERT INTO ld_detailfieldrule_operate(columnname,type,basicsearchid)
			SELECT 'reference_amount','display',@mysearchid;
			INSERT INTO ld_detailfieldrule_operate(columnname,type,basicsearchid)
			SELECT 'budget_rate','display',@mysearchid;
			INSERT INTO ld_detailfieldrule_operate(columnname,type,basicsearchid)
			SELECT 'amount','display',@mysearchid;
			INSERT INTO ld_detailfieldrule_operate(columnname,type,basicsearchid)
			SELECT 'adjustment_amount','display',@mysearchid;
		END IF;


end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_addExpenseBudget`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addExpenseBudget`(
)
BEGIN
   SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='OAForms');
   DELETE FROM ld_systems_deploy WHERE deploy_type>323 AND description LIKE '费用预算单%' AND description LIKE '%是否启用审批流程';
   CALL ldcrm_addnewmoudule_expensebudget('ExpenseBudget','费用预算单','Expense Budget',@myparenttabid,324);
end ||
delimiter;

CALL ldcrm_addExpenseBudget();
DROP PROCEDURE IF EXISTS `ldcrm_addExpenseBudget`;
DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_expensebudget`;
delimiter;


UPDATE ld_field SET allowhide='no' WHERE tablename='ld_expensebudget' AND columnname IN ('budget_person','budget_indicators','indicators_start_date','indicators_end_date','budget_rate');
UPDATE ld_field SET allowedit='no',allowhide='no',uitype=1,bigtype='text' WHERE columnname='expensebudget_type' AND tablename='ld_expensebudget';
UPDATE ld_tabdetailfield SET edit_permission=0 WHERE tablename='ld_expensebudgetdetail' AND columnname IN ('adjustment_amount','budget_amount','description');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','basicBudget','直接录入预算','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='basicBudget' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','basicBudget','Input budget directly','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='basicBudget' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','salesGoalBudget','按销售目标预算','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='salesGoalBudget' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','salesGoalBudget','Budget according to sales target','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='salesGoalBudget' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','salesAchievementBudget','按销售业绩预算','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='salesAchievementBudget' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','salesAchievementBudget','Completion of performance budget','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='salesAchievementBudget' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','salesAchievementBudget','按销售业绩预算','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='salesAchievementBudget' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','salesAchievementBudget','Completion of performance budget','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='salesAchievementBudget' and labeltype='fixedstr');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'expensebudget_type','ExpenseBudget','basicBudget','basicBudget' from dual
where not exists(select 1 from ld_translatefield where module='ExpenseBudget' and columnname='expensebudget_type' and column_Dbvalue='basicBudget');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'expensebudget_type','ExpenseBudget','salesGoalBudget','salesGoalBudget' from dual
where not exists(select 1 from ld_translatefield where module='ExpenseBudget' and columnname='expensebudget_type' and column_Dbvalue='salesGoalBudget');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'expensebudget_type','ExpenseBudget','salesAchievementBudget','salesAchievementBudget' from dual
where not exists(select 1 from ld_translatefield where module='ExpenseBudget' and columnname='expensebudget_type' and column_Dbvalue='salesAchievementBudget');
delimiter;

update ld_field set bigtype="translatefield" ,uitype="1" where tablename="ld_expensebudget" and columnname="expensebudget_type";
delimiter;

create table if not exists `ld_expensebudget_totalcolumns` (
	`totalcolumnsid` int(11) not null auto_increment primary key,
	`name` varchar(100) DEFAULT NULL COMMENT '指标名称',
	`columns` varchar(255) DEFAULT NULL COMMENT '指标需要计算的字段',
	`time_condition_field` varchar(255) DEFAULT NULL COMMENT '时间取哪个字段',
	`time_condition_default` varchar(255) DEFAULT NULL COMMENT '如果上个字段隐藏 则使用该字时间',
	`approved` varchar(50) DEFAULT NULL COMMENT '开启审批的时候  是否只统计审批通过的 yes 是 approvestatus=审批通过
no否approvestatus！=已作废（合同）',
	`type` varchar(100) DEFAULT NULL COMMENT 'salesGoalBudget按目标/salesAchievementBudget
按业绩',
	`sequence` int(11) DEFAULT NULL COMMENT '排序'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Paymentamount','ld_salestarget.paymentamount','','','','salesGoalBudget','0');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Contractamount','ld_salestarget.contractamount','','','','salesGoalBudget','1');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Invoiceamount','ld_salestarget.invoiceamount','','','','salesGoalBudget','2');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Outboundorderamount','ld_salestarget.outboundorderamount','','','','salesGoalBudget','3');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Contractamount','ld_salesorder.total','ld_salesorder.duedate','ld_salesorder.createdtime','yes','salesAchievementBudget','0');
insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Contractamount','ld_servicecontracts.total','ld_servicecontracts.due_date','ld_servicecontracts.createdtime','yes','salesAchievementBudget','0');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Cashbillamount','ld_cashbill.Total','ld_cashbill.cashbilldate','ld_cashbill.createdtime','yes','salesAchievementBudget','1');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('SendCashBillamount','ld_sendcashbill.Total','ld_sendcashbill.cashbilldate','ld_sendcashbill.createdtime','yes','salesAchievementBudget','2');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('SalesOrderamount','ld_salesorder.total','ld_salesorder.duedate','ld_salesorder.createdtime','yes','salesAchievementBudget','3');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('ServiceContractamount','ld_servicecontracts.total','ld_servicecontracts.due_date','ld_servicecontracts.createdtime','yes','salesAchievementBudget','4');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Invoiceamount','ld_invoice.total','ld_invoice.invoicedate','ld_invoice.createdtime','yes','salesAchievementBudget','5');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('PurchaseInvoiceamount','ld_purchaseinvoice.total','ld_purchaseinvoice.purchaseinvoicedate','ld_purchaseinvoice.createdtime','yes','salesAchievementBudget','6');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('OutboundOrderamount','ld_outboundorder.total','ld_outboundorder.outdate','ld_outboundorder.createdtime','yes','salesAchievementBudget','7');

insert into ld_expensebudget_totalcolumns  (`name`,`columns`,`time_condition_field`,`time_condition_default`,`approved`,`type`,`sequence`)
values ('Stockamount','ld_stock.total','ld_stock.createdate','ld_stock.createdtime','yes','salesAchievementBudget','8');

update ld_expensebudget_totalcolumns set name="ContractVolumeamount" where name='Contractamount';

update ld_expensebudget_totalcolumns set name="Invoicedamount" where name="Invoiceamount";
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Paymentamount','收款额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Paymentamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Paymentamount','Amount received','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Paymentamount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ContractVolumeamount','签约额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ContractVolumeamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ContractVolumeamount','contract volume','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ContractVolumeamount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Invoicedamount','开票额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Invoicedamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Invoicedamount','Invoice amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Invoicedamount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Outboundorderamount','出库额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Outboundorderamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Outboundorderamount','Delivery amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Outboundorderamount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Cashbillamount','收款单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Cashbillamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Cashbillamount','Amount received','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Cashbillamount' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SendCashBillamount','付款单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SendCashBillamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SendCashBillamount','Payment slip','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SendCashBillamount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SalesOrderamount','合同订单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SalesOrderamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SalesOrderamount','Contract order','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SalesOrderamount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ServiceContractamount','服务合同','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ServiceContractamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ServiceContractamount','service contract','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ServiceContractamount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PurchaseInvoiceamount','采购发票','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PurchaseInvoiceamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PurchaseInvoiceamount','Purchase invoice','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PurchaseInvoiceamount' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Stockamount','入库单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Stockamount' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Stockamount','Stock in order','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Stockamount' and labeltype='fixedstr');
delimiter;

update ld_expensebudget_totalcolumns set name="salesInvoice" where name="Invoicedamount" and type="salesAchievementBudget";
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','salesInvoice','销售发票','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='salesInvoice' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','salesInvoice','Sales Invoice','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='salesInvoice' and labeltype='fixedstr');
delimiter;

update ld_expensebudget_totalcolumns set name="SalesOrderBill" where name="SalesOrderamount" and type="salesAchievementBudget";
update ld_expensebudget_totalcolumns set name="OutboundOrderBill" where name="OutboundOrderamount" and type="salesAchievementBudget";

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SalesOrderBill','合同订单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SalesOrderBill' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SalesOrderBill','Contract order','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SalesOrderBill' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','OutboundOrderBill','出库单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OutboundOrderBill' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','OutboundOrderBill','Outbound order','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OutboundOrderBill' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_expensebudget_totalcolumns', 'modulename', 'varchar', '100', '0');
CALL AddColumn('ld_expensebudget_totalcolumns', 'isopen', 'varchar', '100', 'yes');

update ld_expensebudget_totalcolumns set modulename="SalesGoal" where type="salesGoalBudget" and name="Paymentamount";
update ld_expensebudget_totalcolumns set modulename="SalesGoal" where type="salesGoalBudget" and name="ContractVolumeamount";
update ld_expensebudget_totalcolumns set modulename="SalesGoal" where type="salesGoalBudget" and name="Invoicedamount";
update ld_expensebudget_totalcolumns set modulename="SalesGoal" where type="salesGoalBudget" and name="Outboundorderamount";

update ld_expensebudget_totalcolumns set modulename="SalesOrder" where type="salesAchievementBudget" and name="ContractVolumeamount" and columns="ld_salesorder.total";
update ld_expensebudget_totalcolumns set modulename="ServiceContracts" where type="salesAchievementBudget" and name="ContractVolumeamount" and columns="ld_servicecontracts.total";
update ld_expensebudget_totalcolumns set modulename="CashBill" where type="salesAchievementBudget" and name="Cashbillamount" and columns="ld_cashbill.Total";

update ld_expensebudget_totalcolumns set modulename="SendCashBill" where type="salesAchievementBudget" and name="SendCashBillamount" and columns="ld_sendcashbill.Total";
update ld_expensebudget_totalcolumns set modulename="SalesOrder" where type="salesAchievementBudget" and name="SalesOrderBill" and columns="ld_salesorder.total";
update ld_expensebudget_totalcolumns set modulename="ServiceContract" where type="salesAchievementBudget" and name="ServiceContractamount" and columns="ld_servicecontracts.total";
update ld_expensebudget_totalcolumns set modulename="Invoice" where type="salesAchievementBudget" and name="salesInvoice" and columns="ld_invoice.total";
update ld_expensebudget_totalcolumns set modulename="PurchaseInvoice" where type="salesAchievementBudget" and name="PurchaseInvoiceamount" and columns="ld_purchaseinvoice.total";
update ld_expensebudget_totalcolumns set modulename="OutboundOrder" where type="salesAchievementBudget" and name="OutboundOrderBill" and columns="ld_outboundorder.total";
update ld_expensebudget_totalcolumns set modulename="Stock" where type="salesAchievementBudget" and name="Stockamount" and columns="ld_stock.total";

update ld_desk set fieldlabel="{$CashBill.CashBill}" where labelbol="Cashbillamount" and labeltype='fixedstr';
update ld_desk set fieldlabel="{$SendCashBill.SendCashBill}" where labelbol="SendCashBillamount" and labeltype='fixedstr';
update ld_desk set fieldlabel="{$ServiceContract.ServiceContract}" where labelbol="ServiceContractamount" and labeltype='fixedstr';
update ld_desk set fieldlabel="{$PurchaseInvoice.PurchaseInvoice}" where labelbol="PurchaseInvoiceamount" and labeltype='fixedstr';
update ld_desk set fieldlabel="{$Stock.Stock}" where labelbol="Stockamount" and labeltype='fixedstr';
update ld_desk set fieldlabel="{$Invoice.Invoice}" where labelbol="salesInvoice" and labeltype='fixedstr';
update ld_desk set fieldlabel="{$SalesOrder.SalesOrder}" where labelbol="SalesOrderBill" and labeltype='fixedstr';
update ld_desk set fieldlabel="{$OutboundOrder.OutboundOrder}" where labelbol="OutboundOrderBill" and labeltype='fixedstr';

SET @modulename='ExpenseBudget';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @td_columnname='total';
SET @td_zhlable='合计';
SET @td_enlable='Total';

SET @j=(SELECT MAX(sequence) FROM ld_tabdetailfield WHERE tabid=@tabid AND presence<>1);
INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase)
SELECT @tabid,@td_columnname,'no',CONCAT('ld_',LOWER(@modulename)),@td_zhlable,NULL,0,'Amount','N~O~25,6',(@j:=@j+1),24,1,0,0,0,0,0,NULL,NULL,NULL,0,NULL,'yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname);

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@td_columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tabdetailfield',@tabid,@relateid,@td_zhlable FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tabdetailfield',@tabid,@relateid,@td_enlable FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable='ld_tabdetailfield' AND tabid = @tabid AND relateid=@relateid);

UPDATE ld_tabdetailfield SET allowhide='no',defaultvalue=0,edit_permission=0,newline=1,defaultcolumn=2 WHERE tablename='ld_expensebudget' AND columnname='total';
delimiter;

call addcolumn('ld_expensebudget','approvesubmitter ','int','9',0);
call addcolumn('ld_expensebudget','approvesubmittedtime ','datetime','',null);
call addcolumn('ld_expensebudget','currentapprovestepid ','int','19',0);

select tabid into @tabid from ld_tab where name='ExpenseBudget';
select tabid into @related_tabid from ld_tab where name='Expense';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
select max(sequence) into @maxsequence from ld_relatedlists where tabid = @tabid;

insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,trade)
select @maxrelation_id+1,@tabid,@related_tabid,'get_expense',1,'Expense',0,'add',1,0,'budget_datacategory_sql','expense.smownerid',0,0,NULL from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);

set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CalculateBudgetData','计算预算数据','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CalculateBudgetData' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CalculateBudgetData','Calculate budget data','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CalculateBudgetData' and labeltype='fixedstr');
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 206;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 'ServiceContracts','325', '设置服务收费管理序时簿列表界面显示服务合同或联系人',@sequence+1,@roottype,'select',0,'[{"value":"ServiceContracts","text":"ServiceContracts"},{"value":"Contacts","text":"Contacts"},{"sql":""}]' from dual
where not exists(select * from ld_systems_deploy where deploy_type=325);
SET @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = 1 order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',325,325,'设置{$ServiceCharge.ServiceCharge}序时簿列表界面显示{$ServiceContracts.ServiceContracts}或{$Contacts.Contacts}' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=325 and relateid=325 and trantable='ld_systems_deploy' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',325,325,'设置{$ServiceCharge.ServiceCharge}序时簿列表界面显示{$ServiceContracts.ServiceContracts}或{$Contacts.Contacts}' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=325 and relateid=325 and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_field_specialedit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(50) DEFAULT NULL,
  `columnname` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

UPDATE ld_field SET fieldlabel='预约上门时间' WHERE tabid=13 AND columnname='hopetime_end' AND fieldlabel='预约上门时间止';
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=13 AND columnname='hopetime_end' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='预约上门时间' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='预约上门时间止';
UPDATE ld_tranlabel SET fieldlabel='Scheduled Time' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='en' AND fieldlabel='Hopetime End';
delimiter;

CALL getallprofile('ExpenseBudget');
CALL fieldprofile('ExpenseBudget');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SaveSubmitApprove','保存并提交审批','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SaveSubmitApprove' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SaveSubmitApprove','Save&Submit','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SaveSubmitApprove' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','reCalculationBudget','重算预算金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='reCalculationBudget' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','reCalculationBudget','Recalculate budget amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='reCalculationBudget' and labeltype='fixedstr');
delimiter;

UPDATE ld_expensebudget_totalcolumns SET modulename='ServiceContracts' WHERE `name`='ServiceContractamount';

DROP PROCEDURE IF EXISTS `ldcrm_reset_expensebudget_byid`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_expensebudget_byid`(
	tmp_mybillid TEXT
)
BEGIN

	DECLARE tmp_budgettype VARCHAR(100) DEFAULT '';
	DECLARE tmp_budgetindicators VARCHAR(100) DEFAULT '';
	
	DECLARE MY_RESETCUSOR CURSOR FOR 
					SELECT
						a.expensebudget_type,
						a.budget_indicators
					FROM ld_expensebudget a
					WHERE FIND_IN_SET(a.expensebudgetid,tmp_mybillid)
						AND a.expensebudget_type IN ('salesGoalBudget','salesAchievementBudget')
					GROUP BY a.expensebudget_type,a.budget_indicators;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_budgettype = NULL;

	OPEN MY_RESETCUSOR; 
	FETCH MY_RESETCUSOR INTO tmp_budgettype,tmp_budgetindicators;
	WHILE(tmp_budgettype IS NOT NULL) DO
		SET @exec_resetbudgetinfo='';
		IF tmp_budgettype ='salesGoalBudget' THEN
			SET @exec_resetbudgetinfo=(
				SELECT
					CONCAT("UPDATE ld_expensebudget a ","\r\n",
						"LEFT JOIN ld_expensebudgetdetail b ON b.id=a.expensebudgetid ","\r\n",
						"SET ","\r\n",
						"	b.reference_amount=","IFNULL((SELECT SUM(",IFNULL(a.budget_column,''),") FROM ld_salestarget WHERE userid=b.lin_users_id AND CONCAT(targetyear,'-',targetmouth,'-01') BETWEEN a.indicators_start_date AND a.indicators_end_date),0),","\r\n",
						"	b.amount=IFNULL(b.budget_rate,0)*0.01*","IFNULL((SELECT SUM(",IFNULL(a.budget_column,''),") FROM ld_salestarget WHERE userid=b.lin_users_id AND CONCAT(targetyear,'-',targetmouth,'-01') BETWEEN a.indicators_start_date AND a.indicators_end_date),0),","\r\n",
						"	b.budget_amount=IFNULL(b.adjustment_amount,0)+IFNULL(b.budget_rate,0)*0.01*","IFNULL((SELECT SUM(",IFNULL(a.budget_column,''),") FROM ld_salestarget WHERE userid=b.lin_users_id AND CONCAT(targetyear,'-',targetmouth,'-01') BETWEEN a.indicators_start_date AND a.indicators_end_date),0)","\r\n",
						"WHERE FIND_IN_SET(a.expensebudgetid,'",tmp_mybillid,"') ","\r\n",
							"	AND a.expensebudget_type='salesGoalBudget' ","\r\n",
							"	AND a.budget_indicators='",tmp_budgetindicators,"'"
						) AS exex_sql
				FROM (
					SELECT 
						`name` AS indicators_type,
						`columns` AS budget_column 
					FROM ld_expensebudget_totalcolumns 
					WHERE type='salesGoalBudget' 
					GROUP BY `name`
				) a
				WHERE a.indicators_type=tmp_budgetindicators
			);
		ELSE
			SET @exec_resetbudgetinfo=(
				SELECT
					CONCAT("UPDATE ld_expensebudget a ","\r\n",
						"LEFT JOIN ld_expensebudgetdetail b ON b.id=a.expensebudgetid ","\r\n",
						"SET ","\r\n",
						"	b.reference_amount=(",total_sql,"),","\r\n",
						"	b.amount=IFNULL(b.budget_rate,0)*0.01*(",total_sql,"),","\r\n",
						"	b.budget_amount=IFNULL(b.adjustment_amount,0)+IFNULL(b.budget_rate,0)*0.01*(",total_sql,")","\r\n",
						"WHERE FIND_IN_SET(a.expensebudgetid,'",tmp_mybillid,"') ","\r\n",
							"	AND a.expensebudget_type='salesAchievementBudget' ","\r\n",
							"	AND a.budget_indicators='",tmp_budgetindicators,"'"
						) AS exex_sql
				FROM (
					SELECT
						indicators_type,
						budget_column,
						modulename,
						GROUP_CONCAT(CONCAT("IFNULL((SELECT SUM(",IFNULL(a.budget_column,''),") FROM ",(SELECT CONCAT(main_tablename,' LEFT JOIN ',custom_tablename,' ON ',main_tablename,'.',primary_key,'=',custom_tablename,'.',primary_key ) FROM ld_tab WHERE `name`=a.modulename)," WHERE deleted=0 AND (CASE WHEN '",a.approved,"'='yes' THEN approvestatus='已批准' ELSE 1=1 END) AND approvestatus<>'已拒绝' AND smownerid=b.lin_users_id AND ",a.time_condition," BETWEEN a.indicators_start_date AND a.indicators_end_date),0)") SEPARATOR '+') AS total_sql
					FROM (
						SELECT 
							`name` AS indicators_type,
							`columns` AS budget_column,
							modulename,
							CASE
								WHEN EXISTS (SELECT 1 FROM ld_field WHERE tablename=LEFT(time_condition_field,LOCATE('.',time_condition_field)-1) AND columnname=RIGHT(time_condition_field,LENGTH(time_condition_field)-LOCATE('.',time_condition_field)) AND presence<>1) THEN time_condition_field
								ELSE time_condition_default
							END AS time_condition,
							approved
						FROM ld_expensebudget_totalcolumns 
						WHERE type='salesAchievementBudget' 
						GROUP BY `name`,`columns`
					) a
					GROUP BY indicators_type
				) a
				WHERE a.indicators_type=tmp_budgetindicators
			);
		END IF;
		
		IF IFNULL(@exec_resetbudgetinfo,'')<>'' THEN
			SET @disable_triggers=1;
			PREPARE resetbudgetinfostmt FROM @exec_resetbudgetinfo;
			EXECUTE resetbudgetinfostmt;
			DEALLOCATE PREPARE resetbudgetinfostmt;
			SET @disable_triggers=NULL;
		END IF;
		FETCH MY_RESETCUSOR INTO tmp_budgettype,tmp_budgetindicators;
	END WHILE;
	CLOSE MY_RESETCUSOR;
	
	UPDATE ld_expensebudget SET total=(SELECT SUM(budget_amount) FROM ld_expensebudgetdetail WHERE id=ld_expensebudget.expensebudgetid) WHERE FIND_IN_SET(expensebudgetid,tmp_mybillid);

END ||
delimiter;

SET @modulename='Expense';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='available_budget'; 
SET @fieldname='available_budget'; 
SET @zh='可用预算余额'; 
SET @en='可用预算余额'; 
SET @uitype=7; 
SET @typeofdata='NN~O~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
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

CALl AddColumn(@tablename,@columnname,'decimal','25',2);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

UPDATE ld_field SET savedatabase='no',allowedit='no' WHERE columnname='available_budget' AND tablename='ld_expense';
delimiter;


SET @this_mytmpsql="SELECT 
	ROUND(IFNULL((
		SELECT 
			SUM(b.budget_amount) 
		FROM ld_expensebudget a
		LEFT JOIN ld_expensebudgetdetail b ON b.id=a.expensebudgetid
		WHERE a.deleted=0 
			AND a.approvestatus<>'已拒绝' 
			AND b.lin_users_id='{ld_expense.assigned_user_id}'
	),0),2)- 
	ROUND(IFNULL((
		SELECT 
			SUM(c.rmb_total) 
		FROM ld_expense a
		LEFT JOIN ld_expensedetail b ON b.expenseid=a.expenseid
		LEFT JOIN ld_expensedetailscf c ON c.expensedetailid=b.expensedetailid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.expenseid<>'{Record.ID}'
			AND a.smownerid='{ld_expense.assigned_user_id}'
	),0),2) 
AS tmp_value";
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
	`isshowlist`
)
SELECT
		'Expense',
		'ld_tabdetailfield',
		@this_mytmpsql,
		'h',
		NULL,
		NULL,
		'报销金额不能超出可用预算余额',
		'inactive',
		'create,edit',
		'no',
		'第 {line} 行报销金额不能超出可用预算余额',
		'第 {line} 行报销金额不能超出可用预算余额',
		'sql',
		NULL,
		NULL,
		'0',
		'php',
		'yes'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_validatasave WHERE module='Expense' AND tipzh LIKE '%{line}%');

SET @myid=(SELECT id FROM ld_validatasave WHERE module='Expense' AND tipzh LIKE '%{line}%' LIMIT 1);
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
		@myid,
		NULL,
		'rmb_total',
		'1',
		'ld_tabdetailfield',
		'sum',
		'ld_expensedetail.entitytypeid',
		'ld_expense.expenseid'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_validatasavedetail WHERE relateid=@myid);
delimiter;

SET @this_mytmpsql="SELECT 
	ROUND(IFNULL((
		SELECT 
			SUM(b.budget_amount) 
		FROM ld_expensebudget a
		LEFT JOIN ld_expensebudgetdetail b ON b.id=a.expensebudgetid
		WHERE a.deleted=0 
			AND a.approvestatus<>'已拒绝' 
			AND b.lin_users_id=?
	),0),2)- 
	ROUND(IFNULL((
		SELECT 
			SUM(c.rmb_total) 
		FROM ld_expense a
		LEFT JOIN ld_expensedetail b ON b.expenseid=a.expenseid
		LEFT JOIN ld_expensedetailscf c ON c.expensedetailid=b.expensedetailid 
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.expenseid<>'{Record.ID}'
			AND a.smownerid=?
	),0),2) 
AS tmp_value";
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tablename='ld_expense' AND columnname='smownerid' LIMIT 1);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tablename='ld_expense' AND columnname='available_budget' LIMIT 1);
INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'sql',@this_mytmpsql FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid);
delimiter;
-- 2021-06-10

UPDATE ld_field SET presence=1 WHERE columnname='available_budget' AND tablename='ld_expense';
update ld_desk set fieldlabel='剩余{quantity}为0时不用自动带出' where languagetype = 'zh' and labelbol = 'WithBalanceQtyCondition' and labeltype = 'fixedstr';
update ld_desk set fieldlabel='When the remaining {quantity} is 0, it will not be brought out automatically' where languagetype = 'en' and labelbol = 'WithBalanceQtyCondition' and labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','smsSendTips','短信推送成功，等待腾讯云返回结果！','jspop' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='smsSendTips' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','smsSendTips','SMS push succeeded, waiting for Tencent cloud to return to the result!','jspop' from dual where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='smsSendTips' and labeltype='jspop');
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

UPDATE ld_version SET old_version='V8.4.2.9',current_version='V8.4.2.9',remark='V8.4.2.9-20210611',wx_version='V8.4.2.9';
delimiter;