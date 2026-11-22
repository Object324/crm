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

CALL addtableIndex('ld_minusjobbill','smownerid','smownerid');
CALL addtableIndex('ld_minusjobbilldetail','starttime','starttime');
CALL addtableIndex('ld_minusjobbilldetail','minusjobtype','minusjobtype');
delimiter;

CALL addtableIndex('ld_addjobbill','smownerid','smownerid');
CALL addtableIndex('ld_addjobbilldetail','starttime','starttime');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_sykq_byuserid`;
delimiter ||
CREATE  PROCEDURE `ldcrm_update_sykq_byuserid`(
	tmp_id int(19)
)
BEGIN

	SET @disable_triggers='abcdefg';
	UPDATE ld_minusjobbill a
	LEFT JOIN ld_minusjobbillscf b ON b.minusjobbillid=a.minusjobbillid
	LEFT JOIN (
		SELECT
			a.id,
			IFNULL(b.add_hours,0)-IFNULL(c.min_hours,0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN 40
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN 80
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN 15*8
				ELSE 120
			END AS total_nj_all,
			(SELECT
				SUM(y.costtime)
			FROM ld_minusjobbill x
			LEFT JOIN ld_minusjobbilldetail y ON y.id=x.minusjobbillid
			WHERE x.deleted=0
				AND x.approvestatus='已批准'
				AND y.minusjobtype='年假'
				AND IFNULL(y.description,'') NOT LIKE '%兑换%'
				AND x.smownerid=a.id
				AND y.starttime>a.this_njstart) AS totqal_nj_use,
			a.this_njstart
		FROM (
			SELECT
				a.id,
				a.last_name,
				a.`status`,
				a.hire_date,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
					ELSE
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
				END AS this_njstart,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					ELSE
						DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
				END AS extra_njend
			FROM ld_users a
			WHERE a.id=tmp_id
		) a
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS add_hours
			FROM ld_addjobbill a
			LEFT JOIN ld_addjobbilldetail b ON b.id=a.addjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND a.smownerid=tmp_id
			GROUP BY a.smownerid
		) b ON b.smownerid=a.id
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS min_hours
			FROM ld_minusjobbill a
			LEFT JOIN ld_minusjobbilldetail b ON b.id=a.minusjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND b.minusjobtype='调休'
				AND a.smownerid=tmp_id
			GROUP BY a.smownerid
		) c ON c.smownerid=a.id
	) c ON c.id=a.smownerid
	SET 
		b.sytx=c.total_sy_tx,
		b.synj=CONCAT(IFNULL(c.total_nj_all,0)-IFNULL(c.totqal_nj_use,0),IFNULL(CONCAT('(',c.this_njstart,')'),''))
	WHERE a.smownerid=tmp_id;


	UPDATE ld_addjobbill a
	LEFT JOIN ld_addjobbillscf b ON b.addjobbillid=a.addjobbillid
	LEFT JOIN (
		SELECT
			a.id,
			IFNULL(b.add_hours,0)-IFNULL(c.min_hours,0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN 40
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN 80
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN 15*8
				ELSE 120
			END AS total_nj_all,
			(SELECT
				SUM(y.costtime)
			FROM ld_minusjobbill x
			LEFT JOIN ld_minusjobbilldetail y ON y.id=x.minusjobbillid
			WHERE x.deleted=0
				AND x.approvestatus='已批准'
				AND y.minusjobtype='年假'
				AND IFNULL(y.description,'') NOT LIKE '%兑换%'
				AND x.smownerid=a.id
				AND y.starttime>a.this_njstart) AS totqal_nj_use,
			a.this_njstart
		FROM (
			SELECT
				a.id,
				a.last_name,
				a.`status`,
				a.hire_date,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
					ELSE
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
				END AS this_njstart,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					ELSE
						DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
				END AS extra_njend
			FROM ld_users a
			WHERE a.id=tmp_id
		) a
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS add_hours
			FROM ld_addjobbill a
			LEFT JOIN ld_addjobbilldetail b ON b.id=a.addjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND a.smownerid=tmp_id
			GROUP BY a.smownerid
		) b ON b.smownerid=a.id
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS min_hours
			FROM ld_minusjobbill a
			LEFT JOIN ld_minusjobbilldetail b ON b.id=a.minusjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND b.minusjobtype='调休'
				AND a.smownerid=tmp_id
			GROUP BY a.smownerid
		) c ON c.smownerid=a.id
	) c ON c.id=a.smownerid
	SET 
		b.sytx=c.total_sy_tx,
		b.synj=concat(IFNULL(c.total_nj_all,0)-IFNULL(c.totqal_nj_use,0),IFNULL(CONCAT('(',c.this_njstart,')'),''))
	WHERE a.smownerid=tmp_id;
	SET @disable_triggers=NULL;
end ||
delimiter;

DROP TRIGGER IF EXISTS `ldcrm_insertsykq_byaddjobbill`;
delimiter ||
CREATE TRIGGER `ldcrm_insertsykq_byaddjobbill` BEFORE INSERT ON `ld_addjobbillscf` FOR EACH ROW 
BEGIN 

	SET @total_sy_tx=0;
	SET @total_sy_nj=0;
	
	SELECT
		c.total_sy_tx,
		CONCAT(IFNULL(c.total_nj_all,0)-IFNULL(c.totqal_nj_use,0),IFNULL(CONCAT('(',c.this_njstart,')'),'')) AS total_sh_nj
	INTO
		@total_sy_tx,
		@total_sy_nj
	FROM (
		SELECT
			a.id,
			IFNULL(b.add_hours,0)-IFNULL(c.min_hours,0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN 40
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN 80
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN 15*8
				ELSE 120
			END AS total_nj_all,
			(SELECT
				SUM(y.costtime)
			FROM ld_minusjobbill x
			LEFT JOIN ld_minusjobbilldetail y ON y.id=x.minusjobbillid
			WHERE x.deleted=0
				AND x.approvestatus='已批准'
				AND y.minusjobtype='年假'
				AND IFNULL(y.description,'') NOT LIKE '%兑换%'
				AND x.smownerid=a.id
				AND y.starttime>a.this_njstart) AS totqal_nj_use,
			a.this_njstart
		FROM (
			SELECT
				a.id,
				a.last_name,
				a.`status`,
				a.hire_date,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
					ELSE
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
				END AS this_njstart,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					ELSE
						DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
				END AS extra_njend
			FROM ld_users a
			WHERE a.id=(SELECT smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.addjobbillid)
		) a
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS add_hours
			FROM ld_addjobbill a
			LEFT JOIN ld_addjobbilldetail b ON b.id=a.addjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND a.smownerid=(SELECT smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.addjobbillid)
			GROUP BY a.smownerid
		) b ON b.smownerid=a.id
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS min_hours
			FROM ld_minusjobbill a
			LEFT JOIN ld_minusjobbilldetail b ON b.id=a.minusjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND b.minusjobtype='调休'
				AND a.smownerid=(SELECT smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.addjobbillid)
			GROUP BY a.smownerid
		) c ON c.smownerid=a.id
	) c 
	WHERE c.id=(SELECT smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.addjobbillid);

	SET NEW.sytx=@total_sy_tx;
	SET NEW.synj=@total_sy_nj;	
	
END ||
delimiter;

DROP TRIGGER IF EXISTS `ldcrm_insertsykq_byminusjobbill`;
delimiter ||
CREATE TRIGGER `ldcrm_insertsykq_byminusjobbill` BEFORE INSERT ON `ld_minusjobbillscf` FOR EACH ROW 
BEGIN 

	SET @total_sy_tx=0;
	SET @total_sy_nj=0;
	
	SELECT
		c.total_sy_tx,
		CONCAT(IFNULL(c.total_nj_all,0)-IFNULL(c.totqal_nj_use,0),IFNULL(CONCAT('(',c.this_njstart,')'),'')) AS total_sh_nj
	INTO
		@total_sy_tx,
		@total_sy_nj
	FROM (
		SELECT
			a.id,
			IFNULL(b.add_hours,0)-IFNULL(c.min_hours,0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN 40
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN 80
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN 15*8
				ELSE 120
			END AS total_nj_all,
			(SELECT
				SUM(y.costtime)
			FROM ld_minusjobbill x
			LEFT JOIN ld_minusjobbilldetail y ON y.id=x.minusjobbillid
			WHERE x.deleted=0
				AND x.approvestatus='已批准'
				AND y.minusjobtype='年假'
				AND IFNULL(y.description,'') NOT LIKE '%兑换%'
				AND x.smownerid=a.id
				AND y.starttime>a.this_njstart) AS totqal_nj_use,
			a.this_njstart
		FROM (
			SELECT
				a.id,
				a.last_name,
				a.`status`,
				a.hire_date,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
					ELSE
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
				END AS this_njstart,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					ELSE
						DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
				END AS extra_njend
			FROM ld_users a
			WHERE a.id=(SELECT smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.minusjobbillid)
		) a
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS add_hours
			FROM ld_addjobbill a
			LEFT JOIN ld_addjobbilldetail b ON b.id=a.addjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND a.smownerid=(SELECT smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.minusjobbillid)
			GROUP BY a.smownerid
		) b ON b.smownerid=a.id
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS min_hours
			FROM ld_minusjobbill a
			LEFT JOIN ld_minusjobbilldetail b ON b.id=a.minusjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND b.minusjobtype='调休'
				AND a.smownerid=(SELECT smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.minusjobbillid)
			GROUP BY a.smownerid
		) c ON c.smownerid=a.id
	) c 
	WHERE c.id=(SELECT smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.minusjobbillid);

	SET NEW.sytx=@total_sy_tx;
	SET NEW.synj=@total_sy_nj;	
	
END ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_update_sykq_all`;
delimiter ||
CREATE  PROCEDURE `ldcrm_update_sykq_all`(
)
BEGIN
	
	SET @disable_triggers='abcdefg';
	UPDATE ld_minusjobbill a
	LEFT JOIN ld_minusjobbillscf b ON b.minusjobbillid=a.minusjobbillid
	LEFT JOIN (
		SELECT
			a.id,
			IFNULL(b.add_hours,0)-IFNULL(c.min_hours,0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN 40
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN 80
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN 15*8
				ELSE 120
			END AS total_nj_all,
			(SELECT
				SUM(y.costtime)
			FROM ld_minusjobbill x
			LEFT JOIN ld_minusjobbilldetail y ON y.id=x.minusjobbillid
			WHERE x.deleted=0
				AND x.approvestatus='已批准'
				AND y.minusjobtype='年假'
				AND IFNULL(y.description,'') NOT LIKE '%兑换%'
				AND x.smownerid=a.id
				AND y.starttime>a.this_njstart) AS totqal_nj_use,
			a.this_njstart
		FROM (
			SELECT
				a.id,
				a.last_name,
				a.`status`,
				a.hire_date,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
					ELSE
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
				END AS this_njstart,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					ELSE
						DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
				END AS extra_njend
			FROM ld_users a
		) a
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS add_hours
			FROM ld_addjobbill a
			LEFT JOIN ld_addjobbilldetail b ON b.id=a.addjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
			GROUP BY a.smownerid
		) b ON b.smownerid=a.id
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS min_hours
			FROM ld_minusjobbill a
			LEFT JOIN ld_minusjobbilldetail b ON b.id=a.minusjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND b.minusjobtype='调休'
			GROUP BY a.smownerid
		) c ON c.smownerid=a.id
	) c ON c.id=a.smownerid
	SET 
		b.sytx=c.total_sy_tx,
		b.synj=CONCAT(IFNULL(c.total_nj_all,0)-IFNULL(c.totqal_nj_use,0),IFNULL(CONCAT('(',c.this_njstart,')'),''));

	UPDATE ld_addjobbill a
	LEFT JOIN ld_addjobbillscf b ON b.addjobbillid=a.addjobbillid
	LEFT JOIN (
		SELECT
			a.id,
			IFNULL(b.add_hours,0)-IFNULL(c.min_hours,0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN 0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN 40
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN 80
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN 15*8
				ELSE 120
			END AS total_nj_all,
			(SELECT
				SUM(y.costtime)
			FROM ld_minusjobbill x
			LEFT JOIN ld_minusjobbilldetail y ON y.id=x.minusjobbillid
			WHERE x.deleted=0
				AND x.approvestatus='已批准'
				AND y.minusjobtype='年假'
				AND IFNULL(y.description,'') NOT LIKE '%兑换%'
				AND x.smownerid=a.id
				AND y.starttime>a.this_njstart) AS totqal_nj_use,
			a.this_njstart
		FROM (
			SELECT
				a.id,
				a.last_name,
				a.`status`,
				a.hire_date,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
					ELSE
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
				END AS this_njstart,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					ELSE
						DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
				END AS extra_njend
			FROM ld_users a
		) a
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS add_hours
			FROM ld_addjobbill a
			LEFT JOIN ld_addjobbilldetail b ON b.id=a.addjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
			GROUP BY a.smownerid
		) b ON b.smownerid=a.id
		LEFT JOIN (
			SELECT
				a.smownerid,
				SUM(b.costtime) AS min_hours
			FROM ld_minusjobbill a
			LEFT JOIN ld_minusjobbilldetail b ON b.id=a.minusjobbillid
			WHERE a.deleted=0
				AND a.approvestatus='已批准'
				AND b.minusjobtype='调休'
			GROUP BY a.smownerid
		) c ON c.smownerid=a.id
	) c ON c.id=a.smownerid
	SET 
		b.sytx=c.total_sy_tx,
		b.synj=concat(IFNULL(c.total_nj_all,0)-IFNULL(c.totqal_nj_use,0),IFNULL(CONCAT('(',c.this_njstart,')'),''));
	SET @disable_triggers=NULL;

END ||
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE (d.`name`='CooperativeWork'
			AND permissions=0
			and d.presence in(0,2)
			AND a.`status`='Active' ) or (a.is_admin='on' AND a.`status`='Active');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remindtime='no';
	SELECT IFNULL(cooperativeworkdaily,'no') INTO @remindtime FROM ld_workremindset LIMIT 1;

	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '日志提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() and reltab='CooperativeWork';

	IF @remindtime<>'no' AND WEEKDAY(NOW())<5 AND @cnt=0 AND DATE_FORMAT(DATE_ADD(NOW(),INTERVAL 1 HOUR),'%H:%i')>=@remindtime AND DATE_FORMAT(NOW(),'%H:%i')<=@remindtime THEN
	    OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO

			IF NOT EXISTS (SELECT 1 FROM ld_workreport WHERE  DATE_FORMAT(createdtime,"%Y-%m-%d")=CURDATE() AND smcreatorid=tmp_id and type=1) THEN

			SET @content=CONCAT('日志提交提醒：您该提交日志啦，还有一个小时就到提交期限哦');
			CALL ldcrm_add_reminder(@content,tmp_id,'CooperativeWork',0);
			end if;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;
	END IF;

end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PlEASEINPUTSETMEMBERRANGE','设置可选择的成员范围不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETMEMBERRANGE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PlEASEINPUTSETMEMBERRANGE','Please input set selectable member ranges','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETMEMBERRANGE' and labeltype='jspop');
delimiter;


call AddColumn('ld_workflow','advft_criteria','text','','');
call AddColumn('ld_workflow','advft_criteria_groups','text','','');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','workflowcondition','触发条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='workflowcondition' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','workflowcondition','Workflow Condition','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='workflowcondition' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','updatefields','更新字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='updatefields' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','updatefields','Update Fields','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='updatefields' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','setvalue','设定取值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='setvalue' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','setvalue','Set Value','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='setvalue' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PLEASESELECTMODULE','请选择模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESELECTMODULE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PLEASESELECTMODULE','Please select module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESELECTMODULE' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','haschanged','有改变','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='haschanged' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','haschanged','has changed','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='haschanged' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','haschangedto','有改变-变更后','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='haschangedto' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','haschangedto','has changed to','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='haschangedto' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','haschangedfrom','有改变-变更前','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='haschangedfrom' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','haschangedfrom','has changed from','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='haschangedfrom' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','suoshumodule','所属模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='suoshumodule' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','suoshumodule','Module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='suoshumodule' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ExcuteSQL','执行SQL','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ExcuteSQL' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ExcuteSQL','Excute SQL','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ExcuteSQL' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SQLstatementssupportcallingstoredprocedures','1.SQL语句支持调用存储过程,支持多个同时执行多条SQL语句;','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SQLstatementssupportcallingstoredprocedures' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SQLstatementssupportcallingstoredprocedures','1. SQL statements support calling stored procedures, and multiple SQL statements can be executed simultaneously;','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SQLstatementssupportcallingstoredprocedures' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DROPandotherkeywordsinSQLstatements','2.SQL语句中禁止使用DELETE、TRUNCATE、DROP等关键字,如果必要请使用存储过程!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DROPandotherkeywordsinSQLstatements' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DROPandotherkeywordsinSQLstatements','2. Do not use DELETE, TRUNCATE, DROP and other keywords in SQL statements. If necessary, use stored procedures!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DROPandotherkeywordsinSQLstatements' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','WildcardcurrentdocumentID','3.通配符：当前单据ID{Record.ID};单据字段{表名.字段fieldname},例如:{ld_account.assigned_user_id};','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WildcardcurrentdocumentID' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','WildcardcurrentdocumentID','Wildcard: current document ID {Record. ID}; Doc field {table name. field fieldname}, for example: {ld_account. assigned_user_id};','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WildcardcurrentdocumentID' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Pleaseselectthefieldtobeupdated','请选择需要更新的字段！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Pleaseselectthefieldtobeupdated' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Pleaseselectthefieldtobeupdated','Please select the field to be updated!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Pleaseselectthefieldtobeupdated' and labeltype='jspop');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workflow_updatefields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `workflow_action_id` int(11) DEFAULT NULL,
  `module` varchar(50) DEFAULT NULL,
  `tabid` int(11) DEFAULT NULL,
  `fieldname` varchar(50) DEFAULT NULL,
  `setmode` varchar(50) DEFAULT NULL,
  `setvalue` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workflow_excutesql` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `workflow_action_id` int(11) DEFAULT NULL,
  `query_sql` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

UPDATE ld_workreport_field SET tablename = 'ld_workreport' WHERE tablename = 'ld_wordreport';
delimiter;
CALL AddColumn('ld_field','categorytype','varchar','100',NULL);
delimiter;

CALL AddColumn('ld_workreport','workreport_no','varchar','100',NULL);
ALTER TABLE ld_workreport CHANGE COLUMN workreport_no workreport_no varchar(100) NOT NULL;
set @i=0;
UPDATE ld_workreport SET workreport_no = CONCAT("WRPT",(@i:=@i+1)) WHERE IFNULL(workreport_no,'') = '' ORDER BY createdtime;
delimiter;

CALL AddColumn('ld_workreport','deleted','tinyint','1',0);
CALL AddColumn('ld_workreport','reuser','int','19',NULL);
CALL AddColumn('ld_workreport','commentscore','varchar','100',NULL);
CALL AddColumn('ld_workreport','commenttime','datetime',NULL,NULL);
CALL AddColumn('ld_workreport','ccuser','text','','');
CALL AddColumn('ld_workreport','isresubmission','varchar','20',NULL);
delimiter;

CALL AddColumn('ld_workreport','relatedto_account','text','','');
CALL AddColumn('ld_workreport','relatedto_contact','text','','');
CALL AddColumn('ld_workreport','relatedto_product','text','','');
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_copy_ld_workreport_field_to_ld_field`;
delimiter ||
CREATE PROCEDURE `ldcrm_copy_ld_workreport_field_to_ld_field`(
  tabid VARCHAR(100)
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_name VARCHAR(200) DEFAULT '';
	DECLARE tmp_label VARCHAR(200) DEFAULT '';
	DECLARE tmp_type INT(4) DEFAULT 1;
	DECLARE tmp_is_mandatory TINYINT(1) DEFAULT 0;
	DECLARE tmp_is_activate TINYINT(1) DEFAULT 0;
	DECLARE tmp_sequence INT(11) DEFAULT 0;
	DECLARE tmp_tablename VARCHAR(100) DEFAULT '';
	DECLARE tmp_allow_edit VARCHAR(20) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR SELECT id,name,label,type,is_mandatory,is_activate,sequence,tablename,allow_edit FROM ld_workreport_field WHERE entitytype='workreport' AND deleted=0 ORDER BY type,sequence;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;


	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_id,tmp_name,tmp_label,tmp_type,tmp_is_mandatory,tmp_is_activate,tmp_sequence,tmp_tablename,tmp_allow_edit;
	WHILE(tmp_id IS NOT NULL) DO
		IF (tmp_type='2' AND (tmp_name = 'worksummary' OR tmp_name = 'workplan' OR tmp_name = 'workexperience' OR tmp_name = 'signaddress')) THEN
			SET tmp_name = CONCAT(tmp_name,'_week');
			CALL AddColumn('ld_workreport',tmp_name,'text','',NULL);
		ELSEIF (tmp_type='3' AND (tmp_name = 'worksummary' OR tmp_name = 'workplan' OR tmp_name = 'workexperience' OR tmp_name = 'signaddress')) THEN
			SET tmp_name = CONCAT(tmp_name,'_month');
			CALL AddColumn('ld_workreport',tmp_name,'text','',NULL);
		END IF;

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
				INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,bigtype,datarang,maxrowsshow,categorytype)
				SELECT @tabid,@maxfieldid+1,tmp_name,'no',tmp_tablename,1,21,tmp_name,tmp_label,0,CASE WHEN tmp_is_activate=1 THEN 1 ELSE 0 END,tmp_sequence,@blockid,1,CASE WHEN tmp_is_mandatory=1 THEN 'V~O' ELSE 'V~M' END,0,0,1,2,tmp_allow_edit,'textarea',NULL,0,tmp_type FROM DUAL
				WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=tmp_name);
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=tmp_name);
				INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
				SELECT 'zh','ld_field',@tabid,@fieldid,tmp_label FROM DUAL
				WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
				INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
				SELECT 'en','ld_field',@tabid, @fieldid,tmp_label FROM DUAL
				WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

		FETCH MYCUSOR INTO tmp_id,tmp_name,tmp_label,tmp_type,tmp_is_mandatory,tmp_is_activate,tmp_sequence,tmp_tablename,tmp_allow_edit;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_WorkReportList`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addnewmoudule_WorkReportList`(
	tmp_modulename VARCHAR(100),
	tmp_zhmoudulename VARCHAR(100),
	tmp_enmoudulename VARCHAR(100)
)
BEGIN

	SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
	SET @tabsequence=(SELECT tabsequence FROM ld_tab WHERE `name`='CooperativeWork' LIMIT 1);
	INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
	SELECT @maxtabid+1,tmp_modulename,0,@tabsequence,tmp_modulename,0,tmp_modulename FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename);
	SET @i=0;
	UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence,tabid;

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh','ld_tab',@tabid,@tabid,tmp_zhmoudulename FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en','ld_tab',@tabid,@tabid,tmp_enmoudulename FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');


	SET @coopwork_tabid=(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork');
	SELECT parenttabid,sequence INTO @parenttabid,@sequence FROM ld_parenttabrel where tabid = @coopwork_tabid LIMIT 1;

	INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
	SELECT @parenttabid,@tabid,@sequence FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);
	SET @i=0;
	UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) where parenttabid = @parenttabid ORDER BY sequence;


	SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
	SET @cur_id = (select count(1) from ld_workreport);
	INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
	SELECT @maxnum_id+1,tmp_modulename,'WRPT',1,@cur_id,1,'none',0,0,0 FROM DUAL
	WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
	UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

	INSERT INTO ld_modtracker_tabs(tabid,visible)
	SELECT @tabid,1 FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);


	SET @i=0;
	INSERT INTO ld_profileallpermission(tabid,operation,sequence)
	SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
	WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
		('index','Detailview','Export','CustomView');


	INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
	SELECT @tabid,tmp_modulename,'ld_workreport','workreport_no','workreportid','workreportid' FROM DUAl
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
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'workreport_no','no','ld_workreport',1,4,'workreport_no','单据编号',0,0,(@i:=@i+1),@blockid,1,'V~M',0,0,0,2,'moduleno',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='workreport_no');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='workreport_no');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'单据编号' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Document No' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'type','no','ld_workreport',1,1,'type','日志类型',1,0,(@i:=@i+1),@blockid,1,'V~O',0,0,0,2,'translatefield',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='type');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='type');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'日志类型' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Log type' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes','ld_workreport',1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid,2,'DT~O',0,0,1,2,'no','no','no','no','datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' AND tablename='ld_workreport');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' AND tablename='ld_workreport');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');



	CALL ldcrm_copy_ld_workreport_field_to_ld_field(@tabid);


	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes','ld_workreport',1,52,'smcreatorid','发起人',1,0,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'no','no','no','no','users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'发起人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Sponsor' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');


	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
			INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
			SELECT @tabid,@maxfieldid+1,'approved','yes','ld_workreport',1,1,'approved','点评状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'translatefield',NULL,0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approved');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approved');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'点评状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Comment status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
			INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
			SELECT @tabid,@maxfieldid+1,'reuser','yes','ld_workreport',1,52,'reuser','点评人',1,0,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'no','no','no','no','users',NULL,0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='reuser');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='reuser');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'点评人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Reviewer' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
			INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
			SELECT @tabid,@maxfieldid+1,'text','yes','ld_workreply',1,21,'text','点评内容',1,0,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'textarea',NULL,0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='text');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='text');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'点评内容' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Comment content' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'commenttime','yes','ld_workreport',1,70,'commenttime','点评时间',1,0,(@i:=@i+1),@blockid,2,'DT~O',0,0,1,2,'no','no','no','no','datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='commenttime');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='commenttime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'点评时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Comment time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'commentscore','yes','ld_workreport',1,1,'commentscore','点评评分',1,0,(@i:=@i+1),@blockid,2,'V~O',0,0,1,2,'no','no','no','no','text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='commentscore');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='commentscore');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'点评评分' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Comment score' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'isresubmission','yes','ld_workreport',1,1,'isresubmission','是否补交',1,0,(@i:=@i+1),@blockid,2,'V~O',0,0,1,2,'no','no','no','no','text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='isresubmission');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='isresubmission');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'是否补交' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Resubmission' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');


	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'ccuser','yes','ld_workreport',1,154,'ccuser','抄送范围',1,0,(@i:=@i+1),@blockid,2,'V~O',0,0,1,2,'no','no','no','no','text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='ccuser');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='ccuser');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'抄送范围' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Cc Range' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');



	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'relatedto_account','yes','ld_workreport',1,401,'relatedto_account','关联客户',0,0,(@i:=@i+1),@blockid,1,'V~O',0,0,1,2,'no','no','no','no','multireference',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='relatedto_account');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='relatedto_account');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'关联客户' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Related To Account' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'relatedto_contact','yes','ld_workreport',1,402,'relatedto_contact','关联联系人',0,0,(@i:=@i+1),@blockid,1,'V~O',0,0,1,2,'no','no','no','no','multireference',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='relatedto_contact');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='relatedto_contact');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'关联联系人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Related To Contact' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

	SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'relatedto_product','yes','ld_workreport',1,403,'relatedto_product','关联产品',0,0,(@i:=@i+1),@blockid,1,'V~O',0,0,1,2,'no','no','no','no','multireference',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='relatedto_product');
	SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='relatedto_product');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'关联产品' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Related To Product' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');




	update ld_field_seq set id = (select max(fieldid) from ld_field);


	CALL getallprofile(tmp_modulename);
	CALL fieldprofile(tmp_modulename);


	SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1,'0' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All' and customcategory = '0');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+2,'待点评',0,0,tmp_modulename,3,1,2,'0' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='待点评' and customcategory = '0');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+3,'已点评',0,0,tmp_modulename,3,1,3,'0' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已点评' and customcategory = '0');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+4,'我发起的',0,0,tmp_modulename,3,1,4,'0' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='我发起的' and customcategory = '0');

	UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,0,CONCAT('ld_workreport:workreport_no:workreport_no:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,1,CONCAT('ld_workreport:type:type:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,2,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,3,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V');
  INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,4,CONCAT('ld_workreport:reuser:reuser:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,5,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,6,CONCAT('ld_workreport:commenttime:commenttime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,7,CONCAT('ld_workreply:text:text:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,8,CONCAT('ld_workreport:commentscore:commentscore:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,9,CONCAT('ld_workreport:isresubmission:isresubmission:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,10,CONCAT('ld_workreport:ccuser:ccuser:',tmp_modulename,'_fieldlabel:V');


	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='待点评' and customcategory = '0');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V'),'e','未点评',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;


	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,0,CONCAT('ld_workreport:workreport_no:workreport_no:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,1,CONCAT('ld_workreport:type:type:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,2,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,3,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,4,CONCAT('ld_workreport:reuser:reuser:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,5,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,6,CONCAT('ld_workreport:isresubmission:isresubmission:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,7,CONCAT('ld_workreport:ccuser:ccuser:',tmp_modulename,'_fieldlabel:V');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已点评' and customcategory = '0');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V'),'e','已点评',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
	WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='我发起的' and customcategory = '0');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;


	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V'),'curuser','',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
	WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';




	SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1,'1' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All' and customcategory = '1');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+2,'待点评',0,0,tmp_modulename,3,1,2,'1' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='待点评' and customcategory = '1');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+3,'已点评',0,0,tmp_modulename,3,1,3,'1' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已点评' and customcategory = '1');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+4,'我发起的',0,0,tmp_modulename,3,1,4,'1' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='我发起的' and customcategory = '1');

	UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '1');

	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,0,CONCAT('ld_workreport:workreport_no:workreport_no:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,1,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,2,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,3,CONCAT('ld_workreport:worksummary:worksummary:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,4,CONCAT('ld_workreport:workplan:workplan:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,5,CONCAT('ld_workreport:workexperience:workexperience:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,6,CONCAT('ld_workreport:saleskit_day:saleskit_day:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,7,CONCAT('ld_workreport:reuser:reuser:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,8,CONCAT('ld_workreport:relatedto_account:relatedto_account:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,9,CONCAT('ld_workreport:relatedto_contact:relatedto_contact:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,10,CONCAT('ld_workreport:relatedto_product:relatedto_product:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,11,CONCAT('ld_workreport:ccuser:ccuser:',tmp_modulename,'_fieldlabel:V');


	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='待点评' and customcategory = '1');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V'),'e','未点评',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;

INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,0,CONCAT('ld_workreport:workreport_no:workreport_no:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,1,CONCAT('ld_workreport:type:type:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,2,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,3,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,4,CONCAT('ld_workreport:reuser:reuser:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,5,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,6,CONCAT('ld_workreport:isresubmission:isresubmission:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,7,CONCAT('ld_workreport:ccuser:ccuser:',tmp_modulename,'_fieldlabel:V');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已点评' and customcategory = '1');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V'),'e','已点评',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
	WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='我发起的' and customcategory = '1');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;


	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V'),'curuser','',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
	WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';



	SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1,'2' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All' and customcategory = '2');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+2,'待点评',0,0,tmp_modulename,3,1,2,'2' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='待点评' and customcategory = '2');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+3,'已点评',0,0,tmp_modulename,3,1,3,'2' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已点评' and customcategory = '2');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+4,'我发起的',0,0,tmp_modulename,3,1,4,'2' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='我发起的' and customcategory = '2');

	UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '2');

	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,0,CONCAT('ld_workreport:workreport_no:workreport_no:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,1,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,2,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,3,CONCAT('ld_workreport:worksummary_week:worksummary_week:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,4,CONCAT('ld_workreport:workplan_week:workplan_week:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,5,CONCAT('ld_workreport:workplan_tuesday:workplan_tuesday:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,6,CONCAT('ld_workreport:workplan_wednesday:workplan_wednesday:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,7,CONCAT('ld_workreport:workplan_thursday:workplan_thursday:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,8,CONCAT('ld_workreport:workplan_friday:workplan_friday:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,9,CONCAT('ld_workreport:saleskit_week:saleskit_week:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,10,CONCAT('ld_workreport:reuser:reuser:',tmp_modulename,'_fieldlabel:V');
  INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,11,CONCAT('ld_workreport:relatedto_account:relatedto_account:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,12,CONCAT('ld_workreport:relatedto_contact:relatedto_contact:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,13,CONCAT('ld_workreport:relatedto_product:relatedto_product:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,14,CONCAT('ld_workreport:ccuser:ccuser:',tmp_modulename,'_fieldlabel:V');


	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='待点评' and customcategory = '2');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V'),'e','未点评',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;


INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,0,CONCAT('ld_workreport:workreport_no:workreport_no:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,1,CONCAT('ld_workreport:type:type:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,2,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,3,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,4,CONCAT('ld_workreport:reuser:reuser:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,5,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,6,CONCAT('ld_workreport:isresubmission:isresubmission:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,7,CONCAT('ld_workreport:ccuser:ccuser:',tmp_modulename,'_fieldlabel:V');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已点评' and customcategory = '2');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V'),'e','已点评',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;


	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
	WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='我发起的' and customcategory = '2');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;


	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V'),'curuser','',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
	WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';




	SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1,'3' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All' and customcategory = '3');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+2,'待点评',0,0,tmp_modulename,3,1,2,'3' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='待点评' and customcategory = '3');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+3,'已点评',0,0,tmp_modulename,3,1,3,'3' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已点评' and customcategory = '3');

	INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,customcategory)
	SELECT @maxcvid+4,'我发起的',0,0,tmp_modulename,3,1,4,'3' FROM dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='我发起的' and customcategory = '3');

	UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '3');

	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,0,CONCAT('ld_workreport:workreport_no:workreport_no:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,1,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,2,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,3,CONCAT('ld_workreport:worksummary_month:worksummary_month:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,4,CONCAT('ld_workreport:workplan_month:workplan_month:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,5,CONCAT('ld_workreport:workexperience_month:workexperience_month:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,6,CONCAT('ld_workreport:saleskit_month:saleskit_month:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,7,CONCAT('ld_workreport:reuser:reuser:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,8,CONCAT('ld_workreport:relatedto_account:relatedto_account:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,9,CONCAT('ld_workreport:relatedto_contact:relatedto_contact:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,10,CONCAT('ld_workreport:relatedto_product:relatedto_product:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,11,CONCAT('ld_workreport:ccuser:ccuser:',tmp_modulename,'_fieldlabel:V');


	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='待点评' and customcategory = '3');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V'),'e','未点评',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;


INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,0,CONCAT('ld_workreport:workreport_no:workreport_no:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,1,CONCAT('ld_workreport:type:type:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,2,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_fieldlabel:DT');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,3,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,4,CONCAT('ld_workreport:reuser:reuser:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,5,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,6,CONCAT('ld_workreport:isresubmission:isresubmission:',tmp_modulename,'_fieldlabel:V');
	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,7,CONCAT('ld_workreport:ccuser:ccuser:',tmp_modulename,'_fieldlabel:V');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已点评' and customcategory = '3');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:approved:approved:',tmp_modulename,'_fieldlabel:V'),'e','已点评',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
	WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='我发起的' and customcategory = '3');
	DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
	DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;


	INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
	SELECT @cvid,0,CONCAT('ld_workreport:smcreatorid:smcreatorid:',tmp_modulename,'_fieldlabel:V'),'curuser','',1,'';
	INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
	SELECT 1,@cvid,0;

	INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
	SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
	WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All' and customcategory = '0');

	DELETE FROM ld_cvcolumnlistsort WHERE cvid=@cvid;
	INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
	SELECT @cvid,CONCAT('ld_workreport:createdtime:createdtime:',tmp_modulename,'_DT~O:fieldlabel'),'desc';



	call addtabintoprofile(tmp_modulename,0);



end ||
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
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',6,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=6)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',37,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=37)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;


CALL ldcrm_addnewmoudule_WorkReportList('WorkReportList','工作汇报(列表)','Cooperative Work(list)');

DROP PROCEDURE IF EXISTS `ldcrm_copy_ld_workreport_field_to_ld_field`;
DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_WorkReportList`;
DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','TOBEREVIEW','未点评','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='TOBEREVIEW' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','TOBEREVIEW','To review','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='TOBEREVIEW' and Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','HAVEREVIEWED','已点评','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='HAVEREVIEWED' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','HAVEREVIEWED','Reviewed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='HAVEREVIEWED' and Labeltype='fixedstr');
delimiter;


SET @columnname = 'approved';
SET @module = 'WorkReportList';
SET @Dbvalue = '0';
SET @labelbol = 'TOBEREVIEW';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);

SET @Dbvalue = '1';
SET @labelbol = 'HAVEREVIEWED';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);

SET @columnname = 'type';
SET @module = 'WorkReportList';
SET @Dbvalue = '1';
SET @labelbol = 'JOURNAL';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);

SET @Dbvalue = '2';
SET @labelbol = 'WEEKPLAN';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);

SET @Dbvalue = '3';
SET @labelbol = 'MONTHPLAN';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@module,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @module);
delimiter;


UPDATE ld_workreport LEFT JOIN ld_workreply ON ld_workreply.workreportid = ld_workreport.workreportid AND ld_workreply.type = 1 SET ld_workreport.commenttime=ld_workreply.createdtime WHERE ld_workreport.approved = 1 AND IFNULL(ld_workreport.commenttime,'')='' AND ld_workreport.deleted = 0;
delimiter;
UPDATE ld_workreport LEFT JOIN ld_workreport2user ON ld_workreport2user.workreportid = ld_workreport.workreportid SET ld_workreport.reuser=ld_workreport2user.userid WHERE ld_workreport2user.user_type = 5 AND ld_workreport.deleted = 0;
delimiter;
UPDATE ld_workreport LEFT JOIN (
SELECT ld_workreport.workreportid,GROUP_CONCAT(ld_workreport2user.userid) AS tmp_ccuser FROM ld_workreport LEFT JOIN ld_workreport2user ON ld_workreport2user.workreportid = ld_workreport.workreportid WHERE ld_workreport2user.user_type = 1 GROUP BY ld_workreport2user.workreportid
) AS tmp ON tmp.workreportid = ld_workreport.workreportid
SET ld_workreport.ccuser = tmp.tmp_ccuser WHERE ld_workreport.deleted = 0;
delimiter;
UPDATE ld_workreport SET worksummary_week=worksummary,workplan_week=workplan,workexperience_week=workexperience,signaddress_week=signaddress WHERE type = 2 AND workreportid>0 AND (IFNULL(worksummary_week,'') = '' AND IFNULL(workplan_week,'') = '' AND IFNULL(workexperience_week,'') = '');
UPDATE ld_workreport SET worksummary_month=worksummary,workplan_month=workplan,workexperience_month=workexperience,signaddress_month=signaddress WHERE type = 3 AND workreportid>0 AND (IFNULL(worksummary_month,'') = '' AND IFNULL(workplan_month,'') = '' AND IFNULL(workexperience_month,'') = '');
delimiter;
UPDATE ld_workreport SET isresubmission =
CASE WHEN type = 1 THEN
(CASE WHEN DATE_FORMAT(createdtime,'%Y-%m-%d') = IFNULL(DATE_FORMAT(sendlog_workdate,'%Y-%m-%d'),DATE_FORMAT(createdtime,'%Y-%m-%d')) THEN '否' ELSE '是' END)
ELSE
(CASE WHEN DATE_FORMAT(createdtime,'%Y-%m-%d') BETWEEN REPLACE(SUBSTRING_INDEX(IFNULL(sendlog_workdate,DATE_FORMAT(createdtime,'%Y-%m-%d')),'~','1'),' ','') AND REPLACE(SUBSTRING_INDEX(IFNULL(sendlog_workdate,DATE_FORMAT(createdtime,'%Y-%m-%d')),'~','-1'),' ','') THEN '否' ELSE '是' END)
END
WHERE entitytype = 'workreport' AND IFNULL(type,'') <> '' AND IFNULL(isresubmission,'')='' AND deleted = 0;
delimiter;
UPDATE ld_workreport a LEFT JOIN ld_workreply b ON b.workreportid=a.workreportid AND b.type=1 SET a.commentscore=b.text
WHERE a.entitytype='workreport' AND b.workreportid>0 AND b.text IN ('一分：严重批评','二分：不合格','三分：符合要求','四分：超过预期','五分：非常满意');
delimiter;

UPDATE ld_workreport INNER JOIN (
SELECT ld_workreport.workreportid,GROUP_CONCAT(ld_workreportrelatedto.relatedto) AS tmp_relatedto,ld_workreportrelatedto.relatedtab FROM ld_workreportrelatedto
	INNER JOIN ld_workreport ON ld_workreportrelatedto.workreportid = ld_workreport.workreportid
WHERE ld_workreportrelatedto.relatedtab = 'Accounts' GROUP BY ld_workreportrelatedto.workreportid
) AS tmp ON tmp.workreportid = ld_workreport.workreportid
SET  ld_workreport.relatedto_account = tmp.tmp_relatedto
WHERE ld_workreport.deleted = 0;
delimiter;

UPDATE ld_workreport INNER JOIN (
SELECT ld_workreport.workreportid,GROUP_CONCAT(ld_workreportrelatedto.relatedto) AS tmp_relatedto,ld_workreportrelatedto.relatedtab FROM ld_workreportrelatedto
	INNER JOIN ld_workreport ON ld_workreportrelatedto.workreportid = ld_workreport.workreportid
WHERE ld_workreportrelatedto.relatedtab = 'Contacts' GROUP BY ld_workreportrelatedto.workreportid
) AS tmp ON tmp.workreportid = ld_workreport.workreportid
SET ld_workreport.relatedto_contact = tmp.tmp_relatedto
WHERE ld_workreport.deleted = 0;
delimiter;

UPDATE ld_workreport INNER JOIN (
SELECT ld_workreport.workreportid,GROUP_CONCAT(ld_workreportrelatedto.relatedto) AS tmp_relatedto,ld_workreportrelatedto.relatedtab FROM ld_workreportrelatedto
	INNER JOIN ld_workreport ON ld_workreportrelatedto.workreportid = ld_workreport.workreportid
WHERE ld_workreportrelatedto.relatedtab = 'Products' GROUP BY ld_workreportrelatedto.workreportid
) AS tmp ON tmp.workreportid = ld_workreport.workreportid
SET ld_workreport.relatedto_product = tmp.tmp_relatedto
WHERE ld_workreport.deleted = 0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NowReview','现在点评','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NowReview' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NowReview','Now review','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NowReview' and labeltype='fixedstr' and languagetype='en');
delimiter;


CREATE TABLE  if not exists `ld_ws_multireferencetype` (
  `fieldtypeid` int(19) NOT NULL,
  `type` varchar(25) NOT NULL,
  PRIMARY KEY (`fieldtypeid`,`type`),
  CONSTRAINT `ld_ws_multireferencetype_ibfk_1` FOREIGN KEY (`fieldtypeid`) REFERENCES `ld_ws_fieldtype` (`fieldtypeid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(fieldtypeid) into @maxfielddtypeid from ld_ws_fieldtype;
insert into ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
select @maxfielddtypeid+1,401,'multireference' from dual where not exists(select 1 from ld_ws_fieldtype
where  uitype=401 and fieldtype='multireference');
delimiter;

select max(fieldtypeid) into @maxfielddtypeid from ld_ws_fieldtype;
insert into ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
select @maxfielddtypeid+1,402,'multireference' from dual where not exists(select 1 from ld_ws_fieldtype
where  uitype=402 and fieldtype='multireference');
delimiter;

select max(fieldtypeid) into @maxfielddtypeid from ld_ws_fieldtype;
insert into ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
select @maxfielddtypeid+1,403,'multireference' from dual where not exists(select 1 from ld_ws_fieldtype
where  uitype=403 and fieldtype='multireference');
delimiter;


select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=401 and fieldtype='multireference';
insert into ld_ws_multireferencetype(fieldtypeid,type)
select @fieldtypeid,'Accounts'  from dual where not exists(select 1 from ld_ws_multireferencetype where type='Accounts');
delimiter;

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=402 and fieldtype='multireference';
insert into ld_ws_multireferencetype(fieldtypeid,type)
select @fieldtypeid,'Contacts'  from dual where not exists(select 1 from ld_ws_multireferencetype where type='Contacts');
delimiter;

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=403 and fieldtype='multireference';
insert into ld_ws_multireferencetype(fieldtypeid,type)
select @fieldtypeid,'Products'  from dual where not exists(select 1 from ld_ws_multireferencetype where type='Products');
delimiter;

CALL AddColumn('ld_loginhistory','languagetype','varchar','10',NULL);
delimiter;

CALL AddColumn('ld_appparenttab','enblockname','varchar','255',NULL);
delimiter;

CALL AddColumn('ld_mobile_report_parent_tab','enblock_name','varchar','255',NULL);
delimiter;

UPDATE ld_appparenttab SET enblockname =
	CASE
		WHEN blockname = '客户管理' then 'Account'
		WHEN blockname = '销售管理' then 'Sales'
		WHEN blockname = '服务管理' then 'Service'
		WHEN blockname = '报表' then 'Reports'
		WHEN blockname = 'OA表单' then 'OA Form'
		WHEN blockname = '项目管理' then 'Project'
		WHEN blockname = '财务管理' then 'Finance'
		WHEN blockname = '库存管理' then 'Storage'
		WHEN blockname = '采购管理' then 'Purchase'
		WHEN blockname = '其他' then 'Other'
		ELSE blockname
	END
where IFNULL(enblockname,'') = '';
delimiter;

UPDATE ld_mobile_report_parent_tab SET enblock_name =
	CASE
		WHEN block_name = '销售报表' then 'Sales Report'
		WHEN block_name = '库存报表' then 'Inventory Report'
		WHEN block_name = '统计图表' then 'Statistics Charts'
		WHEN block_name = '统计排名' then 'Statistical Ranking'
		WHEN block_name = '数据报表' then 'Data report'
		WHEN block_name = '自定义报表' then 'Custom Reports'
		ELSE block_name
	END
where IFNULL(enblock_name,'') = '';
delimiter;

SET @labelbol = 'INSUFFICIENTUSERS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'系统中启用的用户数超出许可用户数%d，您可以在企业微信通讯录中禁用多余用户或者设置应用的可见范围为指定的%d个用户。','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The number of users enabled in the system exceeds the number of licensed users by %d. You can disable redundant users in the enterprise WeChat address book or set the visible range of the application to %d Users','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERUSERACCOUNT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入用户账号','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the user account','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERPASSWORD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入密码','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the password','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ACCOUNTCANOTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'账号不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The account number cannot be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SEARCHMODULENAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索模块名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search Module Name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FUNCTIONMODULEDISPLAYSETTINGS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'功能模块显示设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Function module display settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISPLAYSETTINGS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOMODULEPERMISSION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'暂无模块查看权限','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No module viewing permission','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUSHMESSAGEREMINDER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推送消息提醒','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Push message reminder','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUSHMESSAGETOWECHAT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推送的通知和消息到个人的企业微信中','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Push notifications and messages to personal enterprise wechat','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PERSONALDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'个人资料','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Personal data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MAILLIST';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'通讯录','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'mail list','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERPRISEWECHATCUSTOMERS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'企业微信客户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Enterprise WeChat customers','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LANGUAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'语言','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Language','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VERSIONSWITCHING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'版本切换','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Version switching','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CURRENTVERSION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前版本','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'current version','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TELEPHONECUSTOMERSERVICE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'电话客服','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Telephone customer service','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPWORKBENCH';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'工作台','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'WorkBench','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPFUNCTION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'功能','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Function','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPSETTINGS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CODEINFORMATIONINVALID';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前扫码信息无效','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The current code scanning information is invalid','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VERSIONLOWPLEASEUPGRADE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'版本过低请升级','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The version is too low,please upgrade','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WECHATVERSIONLOWPLEASEUPGRADE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前企业微信版本过低，请升级','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The Enterprise WeChat version is too low,please upgrade','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMON';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'常用','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Common','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISCUSSIONGROUP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'讨论组','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Discussion group','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FAILEDTOGETURL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'获取URL失败','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Failed to get URL','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CANNOTOPENINMOBILE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前模块移动端无法打开','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The mobile terminal of the current module cannot be opened','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MENUDISPLAYMODE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'菜单显示方式','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Menu display mode','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'BLOCKDISPLAY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'区块显示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Block display','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LISTDISPLAY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'列表显示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'List display','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REPORTFORMMODULEDISPLAYSETTINGS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'报表模块显示设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Report form module display settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CURRENCY2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'通用','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Currency','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LICENSEDUSERS2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'许可用户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Licensed Users','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'USED2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已用','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Used','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PERMANENTAUTHORIZATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'永久授权','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Permanent authorization','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CUSTOMTIME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自定义时间','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Custom Time','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AMOUNT1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'额','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Amount','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NEWCONTRACTAMOUNT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增签约额','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'New contract amount','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NEWSIGNNUMBER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增签到数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Number of new sign ins','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RANKINGHIGHTOLOW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'排名从高到低','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'high to low','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RANKINGLOWTOHIGH';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'排名从低到高','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'low to high','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'HOMEPAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'首页','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'home page','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OPPORTUNITIESNUMBER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'机会数量','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Number of opportunities','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OPPORTUNITIESINTOTAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'共%d条机会','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'%d opportunities in total','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CURRENTBLOCKCANNOTVIEW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前区块无法查看详情','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The current block cannot view the details','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'THOUSAND';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'千','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'thousand','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MILLION1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'百万','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'million','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'BILLION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'十亿','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'billion','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TILLION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'万亿','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'trillion','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTUSER1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择用户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'select user','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OUTPUTVALUE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'产值','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'output value','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TOTAL1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'总量','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'total','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUCCESSFULLYCALLED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'成功调用','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Successfully called','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SCAN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'扫一扫','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'scan','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMONTOOLS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'常用工具','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Common tools','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'HIGHSEAS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'High seas','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVALITEMS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批事项','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Approval items','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SALESASSISTANT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'销售助手','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sales Assistant','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NODATATOBEAPPROVED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有待审批数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No data to be approved','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOMOREDATATOBEAPPROVED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有更多待审批数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No more data to be approved','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOAPPROVEDDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有已批准数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No approved data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOMOREAPPROVEDDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有更多已批准数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No more approved data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NODATASUBMITTEDBYME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有我提交的数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No data submitted by me','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOMOREDATASUBMITTEDBYME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有更多我提交的数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No more data submitted by me','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOTFOLLOWEDUPACCOUNT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'超过%d天没有跟进的{$Accounts.Accounts}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'{$Accounts.Accounts} who have not followed more than %d days','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CLOSEPOTENTAILS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'预计%d天内成交的{$Potentials.Potentials}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Expected in %d days to clinch a deal {$Potentials.Potentials}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COLLECTIONPAYMENTPLAN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'%d天内需要收款的{$PaymentPlan.PaymentPlan}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'{$PaymentPlan.PaymentPlan} requiring collection within %d days','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EXPIRINGSERVICECONTRACTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'%d天内将到期的{$ServiceContracts.ServiceContracts}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'{$ServiceContracts.ServiceContracts} expiring in %d days','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'BIRTHDAYSCONTACTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'最近%d天将要过生日的{$Contacts.Contacts}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'{$Contacts.Contacts} who will have birthdays in the last %d days','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SEARCHREPORTNAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索报表名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search Report Name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOREPORTVIEWING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'暂无报表查看权限','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No report viewing permission','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Pending1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'待审批','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Pending','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'isubmitted1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'我提交的','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'submitted','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COLLEAGUE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'同事','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'colleague','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VIEWBYORGANIZATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按组织架构查看','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'View by Organization Structure','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOCOLLEAGUEDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有同事数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No colleague data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NODEPARTMENTDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有部门数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No department data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RESET';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'重置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Reset','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTONECOLLEAGUE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请至少选择一个同事','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select at least one colleague','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AREYOUSURETOASSIGN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定将','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure to assign ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ASSIGNTO1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'分配给','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'to ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ASSIGNSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'分配成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Assign succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'HIGHSEASASSIGNSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海分配成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Highseas assign succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SHARINGSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'共享成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sharing succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COLLEAGUES';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'个同事','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' colleagues','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMPANYWIDE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'全公司','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Company wide','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SEARCHFORCOLLEAGUES';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索同事','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search for colleagues','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SEARCHFORDEPARTMENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索部门','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search for department','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISPLAYQUICKOPERATIONBUTTONS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据列表是否显示快速操作按钮','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether to display quick operation buttons in the document list','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENABLESGLOBALSEARCH';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'功能菜单是否启用全局查找','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether the function menu enables global search','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SCANFUNCTIONISENABLED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'功能菜单是否启用扫一扫功能','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether the scan function is enabled in the function menu','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISPLAYSTYLEISMULTILINE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'字段显示样式为多行显示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The field display style is multi line display','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TMPDISPLAYSTYLEISMULTILINE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'%s显示样式为多行显示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The display style of %s is multi line display','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DEPARTMENTMEMBERS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'部门成员','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Department members','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMONMODULESETTINGS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'常用模块设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Common module settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMONMODULESBESET';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'常用模块最多只能设置7个','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only 7 common modules can be set','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUCCESSFULLYSAVED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'保存成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Successfully saved','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MODIFYAVATAR';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'修改头像','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Modify avatar','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MODIFYDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'修改资料','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Modify data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UPLOADFAILED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'上传失败','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Upload failed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OLDPASSWORDCANOTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'旧密码不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Old password can not be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERNEWPASSWORD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新密码不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The new password cannot be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERNEWPASSWORDAGAIN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确认密码不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Confirm the password can not be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUCCESSFULLYMODIFIED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'修改成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Successfully modified','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CLOSEASSISTANTSHOWAPPROVE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'关闭销售助手后待办界面直接显示审批单据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After closing the sales assistant, the approval document will be directly displayed in the to do interface','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'STAYDOSETTING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'待办设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Staydo Setting','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISPLAYSALESASSISTANT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否显示销售助手','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display sales assistant','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISPLAYKEYVIEW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否显示关键视图','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display key view','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CANNOTBELESSTHANONE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不能小于','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'cannot be less than one ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VISITORTYPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'拜访对象类型','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Visitor Type','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VISITINGADDRESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'拜访地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Visiting address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PHOTO';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'照片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Photo','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ERRORMETRA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'误差(米)：','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Error(metre):','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INACCURATEPOSITIONING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'定位不准？点我','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Inaccurate positioning?Click me','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'HISTORY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'历史','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'History','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOADDRESSISOBTAINED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未获取地址，请确定是否开启GPS','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No address is obtained, please confirm whether GPS is enabled','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'POSITIONING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'定位中...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Positioning...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UPTOUPLOAD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'最多可上传','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Up to upload','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ALSOUPLOAD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您还可以上传','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'You can also upload','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOTPICTUREFILETYPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不是图片文件类型','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Not a picture file type','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UPLOADING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'上传中...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Uploading...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UPLOADSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'上传成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Upload succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LOCATINGCURRENTADDRESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'正在定位当前地址，请稍后再选择拜访对象类型','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Locating the current address, please select the visitor type later','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LOCATINGCURRENTADDRESS2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'正在定位当前地址，请稍后再选择拜访对象','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Locating the current address, please select the visitor later','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTVISITORTYPEFIRST';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择拜访对象类型后，再选择拜访对象','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select a visitor type before selecting a visitor','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASEWAITLOCATING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请稍等，正在定位中...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please wait, locating...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VISITORCANNOTBEEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'拜访对象不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Visitor cannot be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASESELECTPICTURES';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择%dM以内的图片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select pictures within %dM','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PICTURECANNOTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'图片不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Picture cannot be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REMARKCANNOTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'备注不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Remark cannot be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INCALCULABLE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'无法计算','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'incalculable','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CLICKTOREPOSITION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您当前页面停留超过5分钟，点击【确定】按钮后将重新定位','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'You stay on the current page for more than 5 minutes, click the [OK] button to reposition','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SIGNINSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'签到成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sign in succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @tmp_str = 'The administrator has set that it is not allowed to sign in beyond the error range. Your sign in error has exceeded {metre} meters. Please sign in within the specified range!';
UPDATE ld_desk SET fieldlabel = @tmp_str where labelbol = 'Theadministratorhassetthatitisnotallowedtosign' AND languagetype = 'en';
delimiter;

SET @labelbol = 'VISITADDRESSISINCOMPLETE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您的拜访地址不完整，可能会影响签到距离计算，请完善地址信息！','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Your visit address is incomplete, which may affect the calculation of sign in distance. Please complete the address information','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMPLETEADDRESSINFORMATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'管理员已设置超出误差范围不允许签到，请完善您的拜访对象地址信息(%s)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The administrator has set that it is not allowed to sign in beyond the error range. Please complete your visitor address information(%s)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASEENTERTHEADDRESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FINDTHEFOLLOWINGADDRESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'查找以下地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Find the following address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UNABLETOOBTAINLONGITUDE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'无法获取经纬度，请输入更详细的地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Unable to obtain longitude and latitude, please enter a more detailed address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISTANCE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'距离','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'distance','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CALL2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'打电话','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'call','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOSIGNINHISTORY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有签到历史','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No sign in history','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOMORESIGNINHISTORY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有更多签到历史','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No more sign in history','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UNABLETOCALCULATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'无法计算，请查看【%s地址】是否准确录入','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Unable to calculate, please check whether [%s Address] is entered accurately','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SEARCHFORVISITORS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索拜访对象、地址、人员、签到时间、误差','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search for visitors, addresses, personnel, sign in time and errors','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WRITEFOLLOWUP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'写跟进','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Write follow-up','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LONGPRESSTOFORWARD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'长按转发或识别小程序码','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Long press to forward or identify the applet code','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'GENERATEBUSINESSCARD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'生成名片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Generate business card','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EDITBUSINESSCARD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑名片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Edit business card','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'GOHERE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'到这去','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Go here','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AWAYFROMYOU';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'距您%d米','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'%d meters away from you','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMEHERE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'到这里','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Come here','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOTMPDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有%s数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No %s data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LISTMODE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'列表模式','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'List Mode','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUREYOUWANTCOLLECT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定要领取？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure you want to collect?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUCCESSFULLYRECEIVED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'领取成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Successfully received','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NEARBY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'附近','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'nearby','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOTENTEREDMOBILENUMBER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该客户没有录入手机号码或电话号码！','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The customer has not entered a mobile number or phone number!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMENT1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'评论','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Comment','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DELAYED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'延时','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Delayed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOSCHEDULE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有日程安排，','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No schedule,','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TOADD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'去添加','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'add','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MYSCHEDULE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'我的日程','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'My schedule','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OTHERSCHEDULE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'他人日程','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Other schedule','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'OTHERSCHEDULE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'他人日程','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Other schedule','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ShortMonday';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'一','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Mon','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ShortTuesday';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'二','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Tues','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ShortWednesday';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'三','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Wed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ShortThursday';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'四','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Thur','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ShortFriday';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'五','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Fri','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ShortSaturday';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'六','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sat','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ShortSunday';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'日','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sun','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'zhang';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'张','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EXPANDINVENTORYDETAILS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'展开库存详情','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Expand inventory details','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOMOREDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有更多数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No more data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOMORETMPDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有更多%s数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No more %s data','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASESELECTSTARTDATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择开始日期','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select a start date','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASESELECTENDDATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择结束日期','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select a end date','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOADVANCEDSEARCHCONDITIONS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'暂无高级查找条件，请%s前往设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No advanced search conditions, please%s go to Settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = 'List' where labelbol = 'list' AND languagetype = 'en' AND Labeltype = 'fixedstr';
delimiter;
UPDATE ld_desk SET fieldlabel = 'Call' where labelbol = 'CALL2' AND languagetype = 'en' AND Labeltype = 'fixedstr';
delimiter;
UPDATE ld_desk SET fieldlabel = 'Map' where labelbol = 'MAP' AND languagetype = 'en' AND Labeltype = 'fixedstr';
delimiter;

SET @labelbol = 'CREATEBUSINESSCARD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'拍名片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Business card','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NORMAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'普通','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Normal ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ONEPICTUREBUSINESSCARD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'创建名片时只能上传1张图片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only one picture can be uploaded when creating a business card','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CONFIGURECUSTOMERCONTACTPARAMETERS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'企业微信后台没有配置客户联系参数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The enterprise WeChat background does not configure customer contact parameters','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'STOWINVENTORYDETAILS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'收起库存详情','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Stow inventory details','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SETGLOBALDISCOVERYMODULE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置全局查找模块(仅显示已选模块前20条数据)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Set Global Discovery Module (Only the first 20 data of the selected module are displayed)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TEAM';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'团队','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Team','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SESSION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'会话','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Session','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CHANGESTATUS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'更改状态','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Change status','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CHANGESTATUS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'数据错误，进度无法显示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Data error, progress cannot be displayed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOOPERATIONPERMISSIONS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有更多操作权限','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No more operation permissions','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RETRACENOTSUBMITTED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'执行后，该单据将被还原到“未提交”状态，确定要撤销吗？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After execution, the document will be restored to the "Notsubmitted" state. Are you sure you want to do this?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUCCESSFULLYSUBMITTEDAPPROVAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'提交审批成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Successfully submitted for approval','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RETREATSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'回撤成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Retreat succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SURETOASSOCIATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定要关联吗？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure to associate?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NONUMBERTODIAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有可拨打号码','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No number to dial','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CREATETMPQUICKLY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否快速创建%s？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Create %s quickly?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RECORDSINTOTAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'共%d条记录','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'%d records in total','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UNLIMITED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不限','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Unlimited','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = 'New->Edit' where labelbol = 'QuotesChange_Edit' AND languagetype = 'en' AND Labeltype = 'fixedstr';
delimiter;

SET @labelbol = 'INCOMPLETE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未完成','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'incomplete','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMPLETED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已完成','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Completed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTOGRAPH';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'签名','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Autograph','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REWRITING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'重签','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Rewriting','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FILLINCOMMENTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请填写评论内容','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please fill in the comments','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMENTLOG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'评论日志','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Comment Log','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOCOMMENTLOG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有评论日志','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No comment log','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'noapprovelog';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有审批日志','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No approve log','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NORELEVANTINFORMATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有相关信息','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No relevant information','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NODYNAMIC';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有动态','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No dynamic','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOTEAMMEMBERS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有团队成员','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No team members','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'HIGHSEASOPERATIONLOG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海操作日志','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'High seas operation log','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOHIGHSEASOPERATIONLOG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有公海操作日志','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No high seas operation log','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOVIEWHISTORY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有修改日志','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No change Log','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOSIGNLOG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有签到日志','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No sign Log','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RELATEDCREATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'相关创建','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Related Creation','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INITIATEASESSION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发起会话','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Initiate a session','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RELATEDCREATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'相关创建','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Related Creation','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DELAYEDDAYS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'延期天数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Delayed days','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERDELAYEDDAYS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入延期天数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the delayed days','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERRELEASEREASON';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入释放原因','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the release reason','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERSUBMITOPINIONS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入审批意见','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the submit opinions','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPAGREE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'同意','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Agree','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REFERRAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'转审','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Referral','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CURRENTSTAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前阶段','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Current stage','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WRITEOFF';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'核销','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Write off','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CONVERTTOHIGHSEASCLIENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定要转换为公海客户吗？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure you want to convert to a high seas client?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CONVERTTONORMALCLIENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定要转换为普通客户吗？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure you want to convert to a normal client?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ADVANCECOMPLETED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推进完成','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Advance completed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SAVEASPDF';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'另存为pdf','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Save as pdf','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPPOSTPONEDFEWDAYSCANOTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'延期天数不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Delayed days can not be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPPOSTPONEDFEWDAYPOSITIVEINT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'延期天数只能录入正整数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Delayed days can only input positive integer','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DELAYSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'延期成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Delay succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RELEASEREASONCANNOTBEEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'释放原因不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Release reason cannot be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPRELEASESUCCESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'释放成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Release successed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FOLLOWUPSUCCESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'跟进成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Follow up success','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPTRANSFERTOPOTENTIALS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'升级后将转入"{$Accounts.Accounts}"和"{$Potentials.Potentials}"模块，是否继续？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After operation this record will be transferred to "{$Accounts.Accounts}" and "{$Potentials.Potentials}",continue or not?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TRANSFERTOADVANCEORDER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'转预订单','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Transfer to advance order','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SIGNATURECANNOTBEEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'手写签名不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The handwritten signature cannot be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVALSTEPISEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批步骤为空，无法提交','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The approval step is empty and cannot be submitted','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVERISEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批人为空，无法提交','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The approver is empty and cannot be submitted','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVALSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Approval succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPDETERMINEINVENTORY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定盘点吗？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure to inventory?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPREADYCANCELINVENTORY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'执行后，该盘点单将被还原到“盘点中”状态，库存数量还原到盘点前。确定要撤销盘点吗？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After execution, the inventory list will be restored to the state of "inventorying", and restore inventory quantity before inventory. are you sure you want to cancel inventory?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COUNTINGSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'盘点成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Counting succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMENTSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'评论成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Comment succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'BUSINESSINFORMATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'工商信息','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Business Information','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EXPRESSINQUIRY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'快递查询','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Express inquiry','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REJECT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'驳回','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Reject','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOSESSION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有会话','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No session','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TRANSFERSUCCESSED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'转换成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Transfer successed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ADVANCESUCCESSED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推进成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Advance successed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REVOKE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'撤销','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Revoke','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'IMAGEUPLOADING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'图片上传中...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Image uploading...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ATTACHMENTUPLOADING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'附件上传中...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Attachment uploading...','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPURGENTAPPROVAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'加急审批','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Urgent approval','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUBMITCOMMENTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'提交意见','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Submit comments','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASEFILLINYOURCOMMENTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请填写意见','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please fill in your comments','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASEFILLINREMINDERCONTENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请填写提醒内容','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please fill in reminder content','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EXPEDITIONSUCCEEDED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'催审成功','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Expedition succeeded','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISCUSSIONGROUPOF';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'的讨论组','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' discussion group','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPREWRITING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'重写','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Rewriting','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CANVASSKETCHPAD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'Canvas画板','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Canvas Sketchpad','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASEFILLINTHECONTENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请填写内容','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please fill in the content','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOTFILLEDINTHECONTENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您还没有填写内容','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'You have not filled in the content','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERAPOSITIVEINTEGER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入正整数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter a positive integer','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TOTIME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'营业期限','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'ToTime','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPFINISH';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'完成','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Finish','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASEENTERTHESCALE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入比例','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the scale','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ADDDETAILS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'添加明细','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Add details','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SCANTOADDPRODUCTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'扫一扫添加产品','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Scan to add products','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SCANBARCODEWITHPDA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请使用PDA扫入条码','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please scan the barcode with PDA','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'BATCHSELECTISSUEWAREHOUSE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'批量选择出库仓库','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Batch select issue warehouse','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DEDUCTIBLE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'可抵扣','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Deductible','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DEDUCTED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已抵扣','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Deducted','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUBTOTALOFQUANTITY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'数量小计','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Subtotal of quantity','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPSUBTOTAL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'金额小计','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Subtotal','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CALCULATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'计算','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Calculate','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VOICEMESSAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'语音信息','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Voice message','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISCARDTHEMODIFICATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定要放弃当前页面的修改？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure you want to discard the modification of the current page?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MANUALLYSELECTANDENTERPRODUCTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'手动选择录入产品','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Manually select and enter products','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASEENTERINFORMATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入信息','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter information','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTTHESOURCEDOCUMENTTYPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择源单类型后，再选择源单','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select the source document type before selecting the source document','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTMODULEBEFORESELECTING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择模块后，再选择','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select a module before selecting','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SCANCODECONTINUOUSLY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否连续扫码','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Do you scan the code continuously','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTPRODUCTLINEITEMAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不能选择源单以外的产品','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Cannot choose  the product outside of source single','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = 'Add' where labelbol = 'ADD' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

SET @labelbol = 'APPCANNOTBEEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' can not be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INCORRECTFORMAT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'格式不正确','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Incorrect format','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CONTACTNAMECANOTEMPTYAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'首要联系人姓名不能为空','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The primary contact name can not be empty','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CANNOTBESAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'%s和%s不能相同','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'%s and %s cannot be the same','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASEENTERTHECORRECTAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入正确的','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the correct ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = ' cannot be less than one ' where labelbol = 'CANNOTBELESSTHANONE' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

SET @labelbol = 'SHOULDGREATEROREQUALAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'应大于或等于','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' should be greater than or equal to','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LINECOUNT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'第%d行','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Line %d ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AMOUNTCANNOTBEBLANK';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'报销金额不能为空或0','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The reimbursement amount cannot be blank or 0','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMISSIONCANNOTBEBLANK';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'佣金不能为空或0','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Commission cannot be empty or 0','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WAREHOUSINGQUANTITYAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'可入库数量：','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Warehousing quantity:','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'QUANTITYCANISSUEDAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'可出库数量：','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Quantity that can be issued:','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PRODUCTQUANTITYAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'产品数量：','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Product quantity:','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WAREHOUSING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'入库','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Warehousing','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'QUANTITYEXCEEDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'产品累计%s数量超过可%s数量，保存失败','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The cumulative product %s quantity exceeds the %s quantity, Saving failed!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SIGNINISREQUIRED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'签到必填，请点击签到后保存','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sign in is required, please click sign in to save','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'IFTHESTATEHASEBEENSELECTEDASPARTOFTHEAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'若是选择状态为部分已收或已收，保存之后则不可再编辑该单据。是否需要保存？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'If the state has been selected as part of the collection or has been received, after the preservation of the document can not be re edited. Do you need to save?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ApprovedEditAgainSubmitMsgapp';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑已审批的单据将重置其审批状态，稍后您需要重新提交审批！','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'When editing approved records, the approval status will be updated. You need to submit it again for approval!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASESELECTFIRST';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请先选择%s，再选择%s','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select %s first, then %s','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Select ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DOYOUUSELOCATIONADDRESSAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否用定位地址覆盖国家、省份、城市及地址？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Do you use location addresses to cover countries, provinces, cities and addresses?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DELETELOCATIONINFORMATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定要删除定位信息吗？','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure you want to delete the location information?','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CLICKTOSIGNIN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击签到','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click to sign in','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FAILEDTOINITIALIZEPAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'初始化页面失败','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Failed to initialize page','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TOTALOFAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'总','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Total of ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REQUIREDAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'要求','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'It is required ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'THANAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'比','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' than ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MONTHSAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'个月','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' months','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PROPORTIONTOTALMUSTBE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'%s比例合计必须等于100','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The proportion of the total %s must be equal to 100','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PRODUCTCANNOTBEEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'产品名称（变更后）不能为空！','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Product name (after change) cannot be empty!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CREATECUSTOMER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'创建客户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Create customer','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = 'Reduce' where labelbol = 'DEDUCT' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

SET @labelbol = 'SETSEARCHFIELDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'至少设置3个搜索字段','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Set at least 3 search fields','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LEGALPERSON';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'法人','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'legal person','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REGSTATUS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'经营状态','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'RegStatus','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASESELECTATLEASTONE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请至少选择一个','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select at least one','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASESELECTATLEASTONEITEM';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请至少选择一项','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select at least one item','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EDITDETAILS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑明细','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Edit details','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTPRODUCTFIRST';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请先选择产品','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select a product first','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SHOULDLESSTHANAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,' 应小于 ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' should be less than ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PRODUCTNAMEHASNOTCHANGED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'产品名称更换前后没有变化，请重新选择','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The product name has not changed before or after replacement, please select again','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'KILOMETRE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公里','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' kilometre','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NEARBYADDRESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'附近地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Nearby address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LOCATINGADDRESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'定位地址','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Locating address','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMENTNOW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'现在点评','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Comment now','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CCRANGEAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'抄送范围：','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Cc Range:','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ASSOCIATEDCUSTOMERS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'关联客户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Associated customers','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ASSOCIATECONTACT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'关联联系人','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Associate Contact','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ASSOCIATEDPRODUCTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'关联产品','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Associated products','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RELEASETIME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发布时间','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Release time','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUBLISHER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发布人','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Publisher','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DATATYPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'数据类型','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Data type','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ATME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'@我的','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'@me','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PRIVATEAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'私密','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Private','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOCOMMENTS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未点评','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No comments','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REVIEWEDAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已点评','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Reviewed','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UNDERIMPLEMENTATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'执行中','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Under implementation','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TIMEDOUT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已超时','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Timed out','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CANCELED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'已取消','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Canceled','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMENTSIMMEDIATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'以下为直属领导的点评','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The following are the comments of the immediate leadership','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'KEYTIMEREPLIES';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'以下为关键时间点的回复','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The following are the replies at the key time points','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DETAILINTERFACE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'明细界面','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Detail interface','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REQUESTABORTED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请求失败','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Request was aborted','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LINKCONTENTDELETED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'链接内容已删除','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Link content deleted','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMPLETIONTIMEAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'完成时间','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Completion time','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CCRANGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'抄送范围','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Cc Range','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REVIEWER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点评人','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Reviewer','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EXECUTORS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'执行人','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Executor','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REPORTBEENTEMPORARILYSAVED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您的工作汇报已暂存，下次进入可继续编辑工作汇报！','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Your work report has been temporarily saved. You can continue to edit it next time!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ATUSERSCOPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'@用户范围','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'@user scope','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CUSTOMERSAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'个客户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' customers','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CONTACTSAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'个联系人','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' contacts','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VISIBLERANGSETTINGSAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'指定日期范围内没有销售简报数据！','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No sales briefing data is available within the specified date range!','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMPLETIONTIMEEARLIER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'完成时间不能早于当前时间','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The completion time cannot be earlier than the current time','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DATEEARLIERTHAN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'日期不能早于当前日期','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Date cannot be earlier than current date','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTREVIEWER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择点评人','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select a reviewer','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTCCRANGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择抄送范围','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select the CC range','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTEXECUTOR';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择执行人','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select a executor','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SENDINGRANGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发送范围','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sending range','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ATUSER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'@用户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'@USER','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ASSOCIATEPICTURE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'关联图片','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Associate Picture','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

DELETE FROM ld_systems_deploy WHERE deploy_type=110;
delimiter;

update ld_desk set fieldlabel = 'Workflow customization' where languagetype = 'en' and labelbol = 'LBL_WORKFLOWCUSTOMIZATION_SET' and Labeltype = 'fixedstr';
delimiter;

SET @labelbol = 'MYORDER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'我的订单','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'My Order','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RECOMMENREASON';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推荐理由','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Reason for recommendation','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMMODITYDETAILS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'商品详情','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Commodity Details','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ORDERIMMEDIATELY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'立即下单','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Place an order immediately','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOORDERPERMISSION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前没有下单权限','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No permission to place an order','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLACEORDER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'下单','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'place an order','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SUREDELETERECORDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您确定要删除所选记录吗？','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure you want to delete the selected record?','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTLEASTONEDATA';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请至少选择一条数据','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select at least one data','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-10-25

call AddColumn('ld_workflow_actions', 'sequence', 'smallint', '4', null);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','newfields','新字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='newfields' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','newfields','New Fields','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='newfields' and labeltype='fixedstr');
delimiter;

SET @labelbol = 'CANNOTMOVEBEFORECOMPLETEAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'任务未完成，不能向前推进','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The task has not been completed and cannot move forward','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


CALL AddColumn('ld_reminds','push_to_fw','int','2',0);
delimiter;
CALL AddColumn('ld_reminds_accepted','push_to_fw','int','2',0);
delimiter;
CALL AddColumn('ld_reminds','push_time_fw','datetime',null,null );
delimiter;
CALL AddColumn('ld_reminds_accepted','push_time_fw','datetime',null,null );
delimiter;

alter table `ld_reminds` change `push_to_fw` `push_to_fw` int DEFAULT 2 COMMENT '泛微提醒发送标识';
alter table `ld_reminds` change `push_time_fw` `push_time_fw` datetime COMMENT '泛微提醒发送时间';
alter table `ld_reminds_accepted` change `push_to_fw` `push_to_fw` int DEFAULT 2 COMMENT '泛微提醒发送标识';
alter table `ld_reminds_accepted` change `push_time_fw` `push_time_fw` datetime COMMENT '泛微提醒发送时间';
delimiter;

update ld_reminds set push_to_fw = 3 where push_to_fw = 0;
update ld_reminds_accepted set push_to_fw = 3 where push_to_fw = 0;
delimiter;

insert into ld_wx_config (name,description) select 'fanwei_setting','泛微设置' from dual where not exists(select 1 from ld_wx_config where name='fanwei_setting');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PAIDINREGISTEREDCAPITAL','实收注册资金','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PAIDINREGISTEREDCAPITAL' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PAIDINREGISTEREDCAPITAL',"Paid in registered capital",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PAIDINREGISTEREDCAPITAL' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PAIDINREGISTEREDCAPITAL','实收注册资金','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PAIDINREGISTEREDCAPITAL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PAIDINREGISTEREDCAPITAL',"Paid in registered capital",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PAIDINREGISTEREDCAPITAL' and labeltype='fixedstr');
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name='Accounts');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'PAIDINREGISTEREDCAPITAL','actualCapital','','null','' from dual
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'PAIDINREGISTEREDCAPITAL' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'COMPANYNAME','name','','accountname','' from dual
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'COMPANYNAME' and tabid = @tabid);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name='ServiceCharge');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'PAIDINREGISTEREDCAPITAL','actualCapital','','null','' from dual
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'PAIDINREGISTEREDCAPITAL' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'COMPANYNAME','name','','accountname','' from dual
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'COMPANYNAME' and tabid = @tabid);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name='Vendors');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'PAIDINREGISTEREDCAPITAL','actualCapital','','null','' from dual
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'PAIDINREGISTEREDCAPITAL' and tabid = @tabid);

insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'COMPANYNAME','name','','accountname','' from dual
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'COMPANYNAME' and tabid = @tabid);
delimiter;



delete from ld_desk where labelbol='UpperYaxisname' and labeltype='fixedstr';

SET @labelbol = 'RightYaxisname';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'右Y轴名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Right Y axis name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

set @sequence=(SELECT sequence FROM ld_business_backfillfield WHERE `tianyanchaname`='regCapital' LIMIT 1);
update ld_business_backfillfield set sequence=@sequence where tianyanchaname='actualCapital';
delimiter;

call AddColumn('ld_sendcashbill2paymentscf','sequence','int','4','');
delimiter;

SET @labelbol = 'QUARTER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'季','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Quarter','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'STARTDATENOTBEEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'开始日期不能为空','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Start date cannot be empty','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENDDATENOTBEEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'结束日期不能为空','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'End date cannot be empty','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'STARTDATECANOTGREATERENDDATEAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'开始日期不能大于结束日期！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The start date cannot be later than the end date!','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = ' This Year' where labelbol = 'thisyear1' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

UPDATE ld_desk SET fieldlabel = ' Last Year' where labelbol = 'lastyear1' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

SET @labelbol = 'NUMBEROFNEWTMP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增%s数','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'New %s','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INVOICEAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发票','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Invoice','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DELIVERYAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发货','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Delivery','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CUSTOMERAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'客户','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Client','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RECEIVEAPPS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'收款','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Receive','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-10-27

UPDATE ld_desk SET fieldlabel='后台设置' WHERE labelbol IN ('CONTROLPANEL','SYSTEM_DESCRIPTION') AND languagetype='zh' AND fieldlabel='系统设置';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTACTMAP','联系人图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CONTACTMAP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTACTMAP',"Contact map",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CONTACTMAP' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETMAPDISPLAYFIED','设置图谱显示字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETMAPDISPLAYFIED' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETMAPDISPLAYFIED',"Set the map display field",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETMAPDISPLAYFIED' and labeltype='jspop');
delimiter;

CREATE TABLE IF NOT EXISTS`ld_moduledatashowview` (
	`id` int(19) NOT NULL AUTO_INCREMENT,
	`frommodule` varchar(50) DEFAULT NULL ,
	`modulename` varchar(50) DEFAULT NULL ,
	`columns` varchar(220) DEFAULT NULL ,
	`sequence` int(11) DEFAULT NULL ,
	`createdtime` timestamp DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1  DEFAULT CHARSET=utf8;
delimiter;

insert into ld_moduledatashowview(frommodule,modulename,`columns`,sequence)
select 'Default','Contacts','ld_contactdetails:lastname:lastname:Contacts_fieldlabel:V',1 from dual
where not exists(select 1 from ld_moduledatashowview where frommodule='Default' and modulename='Contacts' and `columns`='ld_contactdetails:lastname:lastname:Contacts_fieldlabel:V');
insert into ld_moduledatashowview(frommodule,modulename,`columns`,sequence)
select 'Default','Contacts','ld_contactdetails:title:title:Contacts_fieldlabel:V',2 from dual
where not exists(select 1 from ld_moduledatashowview where frommodule='Default' and modulename='Contacts' and `columns`='ld_contactdetails:title:title:Contacts_fieldlabel:V');
insert into ld_moduledatashowview(frommodule,modulename,`columns`,sequence)
select 'Default','Contacts','ld_contactdetails:mobile:mobile:Contacts_fieldlabel:V',3 from dual
where not exists(select 1 from ld_moduledatashowview where frommodule='Default' and modulename='Contacts' and `columns`='ld_contactdetails:mobile:mobile:Contacts_fieldlabel:V');
insert into ld_moduledatashowview(frommodule,modulename,`columns`,sequence)
select 'Default','Contacts','ld_contactdetails:tag:tag:Contacts_fieldlabel:V',4 from dual
where not exists(select 1 from ld_moduledatashowview where frommodule='Default' and modulename='Contacts' and `columns`='ld_contactdetails:tag:tag:Contacts_fieldlabel:V');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRESSENTERTYSEARCH','请输入%s按Enter键进行查询','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRESSENTERTYSEARCH' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRESSENTERTYSEARCH',"Please enter %s and press enter to query",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRESSENTERTYSEARCH' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGCONTACTTOMAP','可将此处的{$Contacts.Contacts}拖拽到右侧图谱待添加中','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DRAGCONTACTTOMAP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGCONTACTTOMAP',"You can drag {$Contacts.Contacts} here to the map on the right to be added",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DRAGCONTACTTOMAP' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS`ld_moduledatamap` (
	`id` int(19) NOT NULL AUTO_INCREMENT,
	`frommodule` varchar(50) DEFAULT NULL ,
	`modulename` varchar(50) DEFAULT NULL ,
	`fromrecordid` int(11) DEFAULT NULL ,
	`moduleindexid` int(11) DEFAULT NULL ,
	`nodeid` int(11) DEFAULT NULL ,
	`parentnodeid` int(11) DEFAULT NULL ,
	`childrennodeid` varchar(255) DEFAULT NULL ,
	`createdtime` timestamp DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETMAPDISPLAYFIELD','设置图谱显示字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETMAPDISPLAYFIELD' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETMAPDISPLAYFIELD',"Set the map display field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETMAPDISPLAYFIELD' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTLEASTONEFIELD','请至少选择一个字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESELECTLEASTONEFIELD' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTLEASTONEFIELD',"Please select at least one field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESELECTLEASTONEFIELD' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGMAP','拖动图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DRAGMAP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGMAP',"Drag map",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DRAGMAP' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGMAP','拖动图谱','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DRAGMAP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGMAP',"Drag map",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DRAGMAP' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOCKMAP','锁定图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOCKMAP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOCKMAP',"Lock map",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOCKMAP' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOCKMAP','锁定图谱','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOCKMAP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOCKMAP',"Lock map",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOCKMAP' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOBEADD','待添加','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TOBEADD' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOBEADD',"To be add",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TOBEADD' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AMPLIFIEDMAP','放大图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AMPLIFIEDMAP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AMPLIFIEDMAP',"Amplified map",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AMPLIFIEDMAP' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TEDUCETHEMAP','缩小图谱','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TEDUCETHEMAP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TEDUCETHEMAP',"Reduce the map",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TEDUCETHEMAP' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RESTOREMAPSIZE','恢复图谱大小','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RESTOREMAPSIZE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RESTOREMAPSIZE',"Restore map size",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RESTOREMAPSIZE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FULLSCREEN','全屏','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FULLSCREEN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FULLSCREEN',"Full screen",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FULLSCREEN' and labeltype='fixedstr');
delimiter;
-- 2022-10-28

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

UPDATE ld_version SET old_version='V8.4.7.8',current_version='V8.4.7.8',remark='V8.4.7.8-20221028',wx_version='V8.4.7.8';
delimiter;