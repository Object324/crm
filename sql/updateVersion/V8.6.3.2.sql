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

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE PROCEDURE `addtableIndex`(tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50))
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

CALL AddColumn('ld_bireportscreen','scope','varchar',20,'');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_bireportscreen`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_bireportscreen`()
BEGIN

    DECLARE tmp_profileid INT(19) DEFAULT 0;

    DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

    SET @tabid=(select tabid from ld_tab  where name='BIReportScreen');

    set @operation = (SELECT actionid from ld_actionmapping where actionname = 'index');

    IF NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) THEN
        INSERT INTO ld_profileallpermission(tabid,operation,sequence) VALUES (@tabid,@operation,0);
    END IF;

        IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid) THEN
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

CALL ldcrm_add_profile_for_bireportscreen();
delimiter;


INSERT INTO ld_bireportscreen(project_id,project_name,deleted,smcreatorid,createdtime,index_image,scope)
SELECT 'ldcrm_default_1','预设大屏1',0,1,NOW(),'ldcrm_default_1_indexImg.png','all' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_bireportscreen WHERE project_id = 'ldcrm_default_1');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Holiday');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'holidayno' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Personnelfile');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'personnelfile_no' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Laborcontract');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'laborcontract_no' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Salary');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'salary_no' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Competition');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'competition_no' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Collectionslip');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'collectionslip_no' and typeofdata<>'V~M';
delimiter;

call addtableIndex('ld_singin','idx_record_singin','record');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HIGH','高','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='HIGH' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HIGH',"High",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HIGH' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOW','低','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOW' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOW',"low",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOW' and labeltype='fixedstr');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
update ld_relatedlists set buttonstatus='no' where related_tabid = @tabid and label = 'Singin';
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
update ld_relatedlists set buttonstatus='no' where related_tabid = @tabid and label = 'Signout';
delimiter;
-- 2024-04-26

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

UPDATE ld_version SET old_version='V8.6.3.2',current_version='V8.6.3.2',remark='V8.6.3.2-20240426',wx_version='V8.6.3.2';
delimiter;