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

UPDATE ld_field SET allowhide='yes' WHERE columnname='team_memberid' AND uitype=154;
delimiter;

ALTER TABLE ld_sendpayment ALTER COLUMN approvestatus SET DEFAULT '未提交';
ALTER TABLE ld_paymentplan ALTER COLUMN approvestatus SET DEFAULT '未提交';
delimiter;

SET @disable_triggers=1;
UPDATE ld_sendpayment SET approvestatus='未提交' WHERE approvestatus='' OR approvestatus IS NULL;
UPDATE ld_paymentplan SET approvestatus='未提交' WHERE approvestatus='' OR approvestatus IS NULL;
SET @disable_triggers=NULL;
delimiter;
-- 2021-04-16

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mobileDetailCode','移动端单据详情码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='mobileDetailCode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mobileDetailCode','Mobile terminal document detail code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='mobileDetailCode' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','useCrmScan','使用CRM扫一扫功能','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='useCrmScan' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','useCrmScan','Using CRM scan function','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='useCrmScan' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALL AddColumn('ld_users','pwd_checkcondition','varchar',20,'yes');
delimiter;
update ld_users set pwd_checkcondition='yes' where pwd_checkcondition is null or  pwd_checkcondition='';
delimiter;

CALL AddColumn('ld_tabshare','viewuserduty','varchar','100',0);
delimiter;
CALL AddColumn('ld_tabshare','viewuserremark','text','',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Duty','职责','fixedstr' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='duty' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Duty','Duty','fixedstr' from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='duty' and labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='PublicAnnouncement';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
select max(sequence) into @maxsequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-13,'get_readrecord',@maxsequence+1,'ReadRecord',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-13' and name='get_readrecord');

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;


CALL AddColumn('ld_reminds','readedtime','datetime','','');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReadingRecord','阅读记录','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ReadingRecord' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReadingRecord','Reading record','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ReadingRecord' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Reader','阅读人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Reader' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Reader','Reader','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Reader' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LatestReadingTime','最新阅读时间','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LatestReadingTime' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LatestReadingTime','Latest Reading Time','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LatestReadingTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReadingState','阅读状态','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ReadingState' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReadingState','Reading state','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ReadingState' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_wechatsession','fileext','varchar','25','');
delimiter;
CALL AddColumn('ld_wechatsession','upload_way','varchar','25','');
delimiter;
CALL AddColumn('ld_wechatsession','play_length','varchar','100','');
delimiter;
CALL AddColumn('ld_wechatsession','corpname','varchar','255','');
delimiter;

CALL AddColumn('ld_wechatsession','userid','varchar','255','');
delimiter;
CALL AddColumn('ld_wechatsession','longitude','varchar','255','');
delimiter;
CALL AddColumn('ld_wechatsession','latitude','varchar','255','');
delimiter;
CALL AddColumn('ld_wechatsession','address','varchar','255','');
delimiter;
CALL AddColumn('ld_wechatsession','title','varchar','255','');
delimiter;
CALL AddColumn('ld_wechatsession','zoom','varchar','255','');
delimiter;

CALL AddColumn('ld_wechatsession','description','text',NULL,NULL);
delimiter;
CALL AddColumn('ld_wechatsession','link_url','text',NULL,NULL);
delimiter;
CALL AddColumn('ld_wechatsession','image_url','text',NULL,NULL);
delimiter;
CALL AddColumn('ld_wechatsession','username','varchar','255','');
delimiter;
CALL AddColumn('ld_wechatsession','displayname','varchar','255','');
delimiter;
CALL AddColumn('ld_wechatsession','item','text',NULL,NULL);
delimiter;
-- 2021-04-26

call AddColumn("ld_validatasave",'rulename','varchar','100','');
delimiter;
call AddColumn("ld_validatasave",'status','varchar','20','yes');
delimiter;
call AddColumn("ld_validatasave",'validatacheckbutton','varchar','50','create,edit');
delimiter;
call AddColumn("ld_validatasave",'allowsave','varchar','20','no');

delimiter;
alter table ld_validatasave alter column allowsave set default 'no';
delimiter;
call AddColumn("ld_validatasave",'tipzh','varchar','255','');
delimiter;
call AddColumn("ld_validatasave",'tipen','varchar','255','');
delimiter;
call AddColumn("ld_validatasave",'funtype','varchar','50','');  -- sum count avg  --sql
delimiter;
call AddColumn("ld_validatasave",'fungroupdbcolumns','varchar','255','');  
delimiter;
call AddColumn("ld_validatasave",'fungrouphiddencolumns','varchar','100','');
delimiter;

call AddColumn("ld_validatasave",'sequence','int','6','');
delimiter;

call AddColumn("ld_validatasave",'validatasavetype','varchar','50','php');
delimiter;
update ld_validatasave set validatasavetype='js' where validatasavetype is null or validatasavetype='';
delimiter;

alter table ld_validatasave alter column validatasavetype set default 'php';
delimiter;

call AddColumn("ld_validatasave",'isshowlist','varchar','20','yes');
delimiter;
update ld_validatasave set isshowlist='no' where isshowlist is null or isshowlist='';
delimiter;
alter table ld_validatasave alter column isshowlist set default 'yes';
delimiter;

call AddColumn("ld_validatasavedetail",'relatedtable','varchar','50','');  
delimiter;
call AddColumn("ld_validatasavedetail",'funtype','varchar','50','');
delimiter;
call AddColumn("ld_validatasavedetail",'fungroupdbcolumns','varchar','255','');
delimiter;
call AddColumn("ld_validatasavedetail",'fungrouphiddencolumns','varchar','100','');
delimiter;

alter table ld_validatasave modify column fieldname text;
delimiter;

alter table ld_validatasavedetail modify column relatefieldname text;
delimiter;



insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CheckValidataRules','验证规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CheckValidataRules' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CheckValidataRules','Validation Rules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CheckValidataRules' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApplicationScenarios','应用场景','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ApplicationScenarios' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApplicationScenarios','Application Scenarios','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ApplicationScenarios' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IsAllowSave','是否允许保存','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='IsAllowSave' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','IsAllowSave','Allow Saving','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='IsAllowSave' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ValidationArea','验证区域','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ValidationArea' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ValidationArea','Validation Area','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ValidationArea' and labeltype='fixedstr');
delimiter;



insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TipMsgType','提示信息(ZH)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TipMsgType' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TipMsgType','Remind Info(EN)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TipMsgType' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TipMsgType','提示信息(ZH)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TipMsgType' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TipMsgType','Remind Info(EN)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TipMsgType' and labeltype='fixedstr');
delimiter;



insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotAllowSave','不允许保存','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NotAllowSave' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotAllowSave','Not allow','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NotAllowSave' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllowSave','允许保存','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AllowSave' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllowSave','Allow','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AllowSave' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BillHeader','单据头','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BillHeader' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BillHeader','Header','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BillHeader' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BillDetail','单据分录','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BillDetail' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BillDetail','Details','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BillDetail' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ComparatorRelationShip','比较关系','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ComparatorRelationShip' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ComparatorRelationShip','Comparative relationship','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ComparatorRelationShip' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CompareFields','比较字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CompareFields' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CompareFields','Compare fields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CompareFields' and labeltype='fixedstr');
delimiter;



insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TipMsg','提示信息','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TipMsg' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TipMsg','Tips','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TipMsg' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Function','自定义函数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Function' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Function','Function','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Function' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectFieldFunction','选择字段函数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectFieldFunction' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectFieldFunction','选择字段函数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectFieldFunction' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CompareFieldFunction','比较字段函数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CompareFieldFunction' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CompareFieldFunction','比较字段函数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CompareFieldFunction' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GroupBy','分组列','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GroupBy' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','GroupBy','Group By','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GroupBy' and labeltype='fixedstr');
delimiter;



-- chj  BEGIN
SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
SET @maxtseq=(SELECT tabsequence FROM ld_tab where `name` = 'MassEmails');
update ld_tab set tabsequence = tabsequence + 100 where tabsequence > @tabsequence;
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,'Questionnaire',0,@tabsequence+1,'Questionnaire',1,'' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='Questionnaire');
SET @i=0;
UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab',@tabid,@tabid,'调查问卷' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab',@tabid,@tabid,'Questionnaire' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');
delimiter;

select tabid into @massEmails_tabid from ld_tab where `name` = 'MassEmails';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Marketing';
select tabid into @massEmails_tabid from ld_tab where `name` = 'MassEmails';
select sequence into @sequence from ld_parenttabrel where tabid = @massEmails_tabid and parenttabid = @parenttabid;
update ld_parenttabrel set sequence = sequence + 100 where parenttabid = @parenttabid and sequence > @sequence;
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @parenttabid,@tabid,@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);
SET @i=0;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) where parenttabid = @parenttabid ORDER BY sequence;
delimiter;

SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
SELECT @maxnum_id+1,'Questionnaire','DCWJ',1,1,1,'none',0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule='Questionnaire');
UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
INSERT INTO ld_modtracker_tabs(tabid,visible)
SELECT @tabid,1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
('index','Detailview','Create','EditView','Delete','Allocate','Share','ChangeCreator','CustomView');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
SELECT @tabid,'Questionnaire',CONCAT('ld_',LOWER('Questionnaire')),CONCAT(LOWER('Questionnaire'),'_no'),CONCAT(LOWER('Questionnaire'),'id'),CONCAT(LOWER('Questionnaire'),'id') FROM DUAl
WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename='Questionnaire');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
delimiter;



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,CONCAT(LOWER('Questionnaire'),'_no'),'no',CONCAT('ld_',LOWER('Questionnaire')),1,4,CONCAT(LOWER('Questionnaire'),'_no'),'单据编号',1,0,1,@blockid ,1,'V~M',1,0,0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER('Questionnaire'),'_no'));
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER('Questionnaire'),'_no'));
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'单据编号' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Bill NO' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER('Questionnaire')),1,53,'assigned_user_id','负责人',1,0,2,@blockid ,1,'V~M',1,1,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER('Questionnaire')),1,52,'smcreatorid','创建人',1,0,3,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER('Questionnaire')),1,70,'createdtime','创建时间',1,0,4,@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER('Questionnaire')),1,52,'modifiedby','最新更新人',1,0,5,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER('Questionnaire')),1,70,'modifiedtime','更新时间',1,0,6,@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'name','yes',CONCAT('ld_',LOWER('Questionnaire')),1,1,'name','问卷名称',0,0,7,@blockid ,1,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='name');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='name');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'问卷名称' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Questionnaire Name' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'description','yes',CONCAT('ld_',LOWER('Questionnaire')),1,1,'description','问卷描述',0,0,8,@blockid ,1,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='description');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='description');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'问卷描述' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Questionnaire Describing' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

CALL getallprofile('Questionnaire');
delimiter;

CALL fieldprofile('Questionnaire');
delimiter;

SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+1,'All',1,0,'Questionnaire',3,1,1 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype='Questionnaire' and viewname='All');
UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
delimiter;

SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Questionnaire' AND viewname='All');
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,0,CONCAT('ld_',LOWER('Questionnaire'),':',LOWER('Questionnaire'),'_no',':',LOWER('Questionnaire'),'_no',':','Questionnaire','_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,1,CONCAT('ld_',LOWER('Questionnaire'),':','smownerid',':','assigned_user_id',':','Questionnaire','_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,2,CONCAT('ld_',LOWER('Questionnaire'),':','smcreatorid',':','smcreatorid',':','Questionnaire','_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,3,CONCAT('ld_',LOWER('Questionnaire'),':','createdtime',':','createdtime',':','Questionnaire','_fieldlabel:DT');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
INSERT INTO ld_def_org_share(tabid,permission,editstatus)
SELECT @tabid,3,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);
delimiter;

CALL addtabintoprofile('Questionnaire',1);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Customizedquestionnaire','定制问卷','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Customizedquestionnaire' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Customizedquestionnaire','Customized questionnaire','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Customizedquestionnaire' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Conclusionsetting','结束语设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Conclusionsetting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Conclusionsetting','Conclusion setting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Conclusionsetting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Topictype','题目类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Topictype' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Topictype','Topic type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Topictype' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Topicname','题目名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Topicname' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Topicname','Topic name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Topicname' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Multiplechoicequestions','单选题','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Multiplechoicequestions' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Multiplechoicequestions','Multiple choice questions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Multiplechoicequestions' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Multipleschoicequestions','多选题','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Multipleschoicequestions' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Multipleschoicequestions','Multiples choice questions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Multipleschoicequestions' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Textdescription','文本描述','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Textdescription' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Textdescription','Text description','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Textdescription' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Newoptions','新建选项','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Newoptions' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Newoptions','New options','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Newoptions' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Noquestions','没有任何题目！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Noquestions' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Noquestions','Noquestions!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Noquestions' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Optioncannotbeempty','选项不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Optioncannotbeempty' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Optioncannotbeempty','Option cannot be empty!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Optioncannotbeempty' and Labeltype='jspop' and languagetype='en');
delimiter;
-- chj end



-- Questionnaire
CREATE TABLE IF NOT EXISTS `ld_questionnaire` (
    `questionnaireid` int(11) NOT NULL AUTO_INCREMENT,
    `questionnaire_no` VARCHAR(100) NOT NULL COMMENT '编号',
    `name` VARCHAR(255) DEFAULT NULL  COMMENT '问卷名称',
    `description` TEXT  DEFAULT NULL COMMENT '问卷描述',
    `status` VARCHAR(50) DEFAULT '正在回收' COMMENT '暂停、正在回收',
    `recoverys` int(11) DEFAULT NULL COMMENT '回收量',
    `views` int(11) DEFAULT NULL COMMENT '浏览量',
    `createdtime` datetime COMMENT '创建时间',
    `modifiedtime` datetime COMMENT '更新时间',
    `smownerid` int(11) DEFAULT NULL COMMENT '负责人',
    `smcreatorid` int(11) DEFAULT NULL COMMENT '创建人',
    `modifiedby` int(11) DEFAULT NULL COMMENT '最新更新人',
    `deleted` int(11) DEFAULT 0,
    `recovery_endtime` datetime COMMENT '回收截止时间',
    `recovery_endremarks` TEXT  DEFAULT NULL COMMENT '问卷结束语(html)',
		`created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`questionnaireid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_questionnairescf` (
  `questionnaireid` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`questionnaireid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_questionnaire_topic` (
    `topicid` int(11) NOT NULL AUTO_INCREMENT,
    `questionnaireid` int(11) NOT NULL COMMENT '调查问卷id',
    `topic_type` VARCHAR(50) DEFAULT NULL COMMENT '题目类型 单选:one 多选:more 文本描述:text',
    `topic_name` TEXT  DEFAULT NULL COMMENT '题目名称',
    `required` VARCHAR(20) DEFAULT 'no' COMMENT '是否必填：no、yes',
    `sequence` int(11) DEFAULT NULL COMMENT '显示顺序',
    `deleted` int(11) DEFAULT 0,
    `description` TEXT  DEFAULT NULL COMMENT '描述',
    `topic_json` TEXT  DEFAULT NULL,
		`created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`topicid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_questionnaire_topic_option` (
    `optionid` int(11) NOT NULL AUTO_INCREMENT,
    `topicid` int(11) NOT NULL COMMENT '题目id',
    `topicoption` TEXT DEFAULT NULL COMMENT '题目选项内容',
    `sequence` int(11) DEFAULT NULL COMMENT '显示顺序',
    `deleted` int(11) DEFAULT 0,
		`created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`optionid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_questionnaire_chart` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `topicid` int(11) NOT NULL COMMENT '题目id',
    `optionid` int(11) DEFAULT NULL COMMENT '选项id',
    `option_value` TEXT COMMENT '选项填写内容',
		`createdtime` datetime COMMENT '创建时间',
		`created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

UPDATE ld_field_seq SET id = (select MAX(fieldid) from ld_field);

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'status','yes',CONCAT('ld_',LOWER('Questionnaire')),1,1,'status','状态',0,0,9,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='status');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='status');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Status' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'recoverys','yes',CONCAT('ld_',LOWER('Questionnaire')),1,1,'recoverys','回收量',1,0,10,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='recoverys');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='recoverys');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'回收量' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Recovery number' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'views','yes',CONCAT('ld_',LOWER('Questionnaire')),1,1,'views','浏览量',1,0,11,@blockid ,2,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='views');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='views');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'浏览量' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Read number' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'recovery_endtime','yes',CONCAT('ld_',LOWER('Questionnaire')),1,70,'recovery_endtime','回收截止时间',0,0,12,@blockid ,1,'DT~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='recovery_endtime');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='recovery_endtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'回收截止时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Recall Deadline' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'recovery_endremarks','yes',CONCAT('ld_',LOWER('Questionnaire')),1,1,'recovery_endremarks','问卷结束语',0,0,13,@blockid ,1,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='recovery_endremarks');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='recovery_endremarks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'问卷结束语' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Questionnaire conclusion' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FINISHED','完成','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FINISHED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FINISHED','Finished','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FINISHED' and Labeltype='jspop');
delimiter;
-- 2021-04-28

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

UPDATE ld_version SET old_version='V8.4.2.4',current_version='V8.4.2.4',remark='V8.4.2.4-20210428',wx_version='V8.4.2.4';
delimiter;