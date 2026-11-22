DROP PROCEDURE IF EXISTS `ldcrm_reset_customformdetail_fanyi`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_customformdetail_fanyi`(
)
BEGIN

	DECLARE tmp_producttoolfieldid INT(19) DEFAULT 0;
	DECLARE tmp_tabid INT(19) DEFAULT 0; 
	DECLARE tmp_columnname VARCHAR(100) DEFAULT ''; 
	DECLARE tmp_fieldtype VARCHAR(20) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR 
						SELECT
							a.producttoolfieldid,
							a.tabid,
							a.columnname,
							CASE
								WHEN a.tablename LIKE 'ld_customform%' AND a.tablename LIKE '%detail' THEN 'biaoti'
								ELSE 'biaotou'
							END AS fieldtype
						FROM ld_producttoolfield a
						WHERE a.columnname='discount_amount'
							AND a.tablename LIKE 'ld_customform%';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_producttoolfieldid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_producttoolfieldid,tmp_tabid,tmp_columnname,tmp_fieldtype;
	WHILE(tmp_producttoolfieldid IS NOT NULL) DO
		IF tmp_fieldtype='biaoti' AND (SELECT COUNT(1) FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND tabid=tmp_tabid AND Relateid=tmp_producttoolfieldid)>2 THEN
			SET @id1=(SELECT MAX(tranlabelid) FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND languagetype='zh' AND tabid=tmp_tabid AND Relateid=tmp_producttoolfieldid);
			SET @id2=(SELECT MAX(tranlabelid) FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND languagetype='en' AND tabid=tmp_tabid AND Relateid=tmp_producttoolfieldid);
			DELETE FROM ld_tranlabel WHERE tranlabelid=@id1 OR tranlabelid=@id2;
		ELSEIF tmp_fieldtype='biaotou' AND (SELECT COUNT(1) FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND tabid=tmp_tabid AND Relateid=tmp_producttoolfieldid)>2 THEN
			SET @id1=(SELECT MIN(tranlabelid) FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND languagetype='zh' AND tabid=tmp_tabid AND Relateid=tmp_producttoolfieldid);
			SET @id2=(SELECT MIN(tranlabelid) FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND languagetype='en' AND tabid=tmp_tabid AND Relateid=tmp_producttoolfieldid);
			DELETE FROM ld_tranlabel WHERE tranlabelid=@id1 OR tranlabelid=@id2;
		END IF;
		FETCH MYCUSOR INTO tmp_producttoolfieldid,tmp_tabid,tmp_columnname,tmp_fieldtype;
	END WHILE;
	CLOSE MYCUSOR;
end ||
delimiter;

CALL ldcrm_reset_customformdetail_fanyi();
DROP PROCEDURE IF EXISTS `ldcrm_reset_customformdetail_fanyi`;

SET @modulename='Users';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='wx_openid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='wx_openid' LIMIT 1);
SET @columnname='dingtalk_userid'; 
SET @fieldname='dingtalk_userid'; 
SET @zh='钉钉通讯录账号'; 
SET @en='DingDing Account'; 
SET @uitype=1; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','100',0);
CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

SET @i=0;
SET @modulename='Users';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='wx_openid' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_field WHERE tabid=@tabid AND block=@relateid AND columnname='wx_openid');
UPDATE ld_field SET sequence=sequence+1 WHERE tabid=@tabid AND block=@relateid AND sequence>@seq;
UPDATE ld_field SET sequence=@seq+1 WHERE tabid=@tabid AND block=@relateid AND columnname='dingtalk_userid';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@relateid ORDER BY sequence;
delimiter;

update ld_desk set fieldlabel='公海成员权限设置' where labelbol='PUBLICUSERSET' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='公海管理员权限设置' where labelbol='SETPUBLICCUSTOMERADMIN' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

DROP PROCEDURE IF EXISTS `fenbiao_createtables_20190911`;
delimiter ||
CREATE PROCEDURE `fenbiao_createtables_20190911`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 
	DECLARE tmp_exectag1 INT(4) DEFAULT 0; 
	DECLARE tmp_exectag2 INT(4) DEFAULT 0; 
	DECLARE tmp_querysql1 TEXT DEFAULT '';
	DECLARE tmp_querysql2 TEXT DEFAULT ''; 
	DECLARE tmp_querysql3 TEXT DEFAULT ''; 
	DECLARE tmp_querysql4 TEXT DEFAULT ''; 
  
	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				a.tabid,
				CASE
					WHEN NOT EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_ld_potentialsdetail')) THEN '1'
					ELSE 0
				END AS exectag1,
				CASE
					WHEN NOT EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_potentialsdetailscf')) THEN '1'
					ELSE 0
				END AS exectag2,
				CONCAT('CREATE TABLE IF NOT EXISTS ld_',LOWER(a.modulename),'detail LIKE ld_salesorderdetail') AS querysql1,
				CONCAT('CREATE TABLE IF NOT EXISTS ld_',LOWER(a.modulename),'detailscf LIKE ld_salesorderdetailscf') AS querysql2,
				CONCAT('INSERT INTO ld_',LOWER(a.modulename),'detail SELECT b.* FROM ', a.tablename, ' a',
						' INNER JOIN ld_salesorderdetail b ON a.',a.tablekey,'=b.id') AS querysql3,
				CONCAT('INSERT INTO ld_',LOWER(a.modulename),'detailscf SELECT c.* FROM ', a.tablename, ' a',
						' INNER JOIN ld_salesorderdetail b ON a.',a.tablekey,'=b.id'
						' INNER JOIN ld_salesorderdetailscf c ON  b.lineitem_id=c.lineitem_id') AS querysql4
			FROM (
				SELECT DISTINCT
					a.tabid,
					a.name AS modulename,
					b.tablename,
					CASE
						WHEN tablename='ld_potential' THEN 'potentialid'
						
					END AS tablekey
				FROM ld_tab a
				INNER JOIN ld_field b ON a.tabid=b.tabid AND b.columnname='smownerid'
				WHERE a.name IN (
					'Potentials'
					
					)
				ORDER BY FIELD(a.name,
				'Potentials'
				)	
			) a;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_exectag1,tmp_exectag2,tmp_querysql1,tmp_querysql2,tmp_querysql3,tmp_querysql4;
	WHILE(tmp_tabid IS NOT NULL) DO

		IF tmp_exectag1=1 THEN
			SET @query_sql1=tmp_querysql1;
			PREPARE smtp1 FROM @query_sql1;
			EXECUTE smtp1;
			DEALLOCATE PREPARE smtp1;

			SET @query_sql3=tmp_querysql3;
			PREPARE smtp3 FROM @query_sql3;
			EXECUTE smtp3;
			DEALLOCATE PREPARE smtp3;
		END IF;

		IF tmp_exectag2=1 THEN
			SET @query_sql2=tmp_querysql2;
			PREPARE smtp2 FROM @query_sql2;
			EXECUTE smtp2;
			DEALLOCATE PREPARE smtp2;
			
			SET @query_sql4=tmp_querysql4;
			PREPARE smtp4 FROM @query_sql4;		
			EXECUTE smtp4;
			DEALLOCATE PREPARE smtp4;
		END IF;

		FETCH MYCUSOR INTO tmp_tabid,tmp_exectag1,tmp_exectag2,tmp_querysql1,tmp_querysql2,tmp_querysql3,tmp_querysql4;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;
CALL fenbiao_createtables_20190911();
delimiter;

select tabid into @producttooltabid from ld_tab where name='potentials';
select tabid into @tabid from ld_tab where name='salesorder';
select max(producttoolfieldid) into @maxproducttoolfieldid from ld_producttoolfield;
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,
typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,description,nullfield)

select @maxproducttoolfieldid:=@maxproducttoolfieldid+1, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,
typeofdata,sequence,@producttooltabid,case when tablename='ld_salesorderdetail' then 'ld_potentialsdetail' when tablename='ld_salesorderdetailscf' then 'ld_potentialsdetailscf' else tablename end   ,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,description,nullfield
from ld_producttoolfield where tabid=@tabid
and not exists(select 1 from ld_producttoolfield where tabid=@producttooltabid) ;
delimiter;

update ld_producttoolfield_seq set id=(select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select ld_tranlabel.languagetype,trantable,2,tmp_potentialproducttoolfield.producttoolfieldid as relateid,ld_tranlabel.fieldlabel from ld_producttoolfield
INNER JOIN ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
INNER JOIN (select producttoolfieldid,columnname from ld_producttoolfield where tabid=2)
							as tmp_potentialproducttoolfield
on tmp_potentialproducttoolfield.columnname=ld_producttoolfield.columnname
 where ld_producttoolfield.tabid=22 and ld_tranlabel.trantable='ld_producttoolfield' 
and (ld_producttoolfield.tablename='ld_salesorderdetail' or ld_producttoolfield.tablename='ld_salesorderdetailscf')
and  not exists(select 1 from ld_systems_deploy where deploy_type=205);
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select ld_tranlabel.languagetype,trantable,2,tmp_potentialproducttoolfield.producttoolfieldid as relateid,ld_tranlabel.fieldlabel from ld_producttoolfield
INNER JOIN ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
INNER JOIN (select producttoolfieldid,columnname,tablename from ld_producttoolfield where tabid=2)
							as tmp_potentialproducttoolfield
on tmp_potentialproducttoolfield.columnname=ld_producttoolfield.columnname
 where ld_producttoolfield.tabid=22 and ld_tranlabel.trantable='ld_producttoolfield' 
and (ld_producttoolfield.tablename='ld_salesorder')
and tmp_potentialproducttoolfield.tablename='ld_potential'
and  not exists(select 1 from ld_systems_deploy where deploy_type=205);
delimiter;

call AddColumn('ld_account_set_advfilter','groupid','int',11,'1');
delimiter;

CREATE TABLE if not EXISTS `ld_account_set_advfilter_grouping` (
  `groupid` int(11) NOT NULL,
  `group_condition` varchar(255) DEFAULT NULL,
  `condition_expression` text,
  PRIMARY KEY (`groupid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

update ld_account_set_advfilter set groupid=1 where not
EXISTS (select 1 from ld_account_set_advfilter_grouping) and groupid is null;
delimiter;

insert into ld_account_set_advfilter_grouping(groupid,group_condition,condition_expression)
select 1,'',0 from dual where not
EXISTS (select 1 from ld_account_set_advfilter_grouping) 
and EXISTS(select * from ld_account_set_advfilter);
delimiter;
-- 2019-09-18

insert into ld_producttoolfield_formula(formulastring,columnstring,producttoolfieldid,sequence)
select formulastring,columnstring,ld_producttoolfield.producttoolfieldid,tmp.sequence 
from ld_producttoolfield INNER JOIN (

select formulastring,columnstring,columnname,ld_producttoolfield_formula.sequence from ld_producttoolfield_formula
INNER JOIN ld_producttoolfield on
 ld_producttoolfield.producttoolfieldid=ld_producttoolfield_formula.producttoolfieldid
where tabid=22 ) as tmp  on tmp.columnname=ld_producttoolfield.columnname
where ld_producttoolfield.tabid=2
and not exists(select 1 from ld_systems_deploy where deploy_type=205);
delimiter;

select sequence into @sequnece from  ld_systems_deploy where deploy_type=54 and not EXISTS(select 1 from ld_systems_deploy where deploy_type=205);
update ld_systems_deploy set sequence=sequence+2 where  ifnull(@sequnece,0)>0 and roottype=2;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,presence,inputtype,inputvalue)
select 1,205,'设置销售机会是否显示产品分录明细','',@sequnece+1,2,0,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Potentials"}]'
from dual where  not EXISTS(select 1 from ld_systems_deploy where deploy_type=205)
and ifnull(@sequnece,0)>0;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select ld_tranlabel.languagetype,trantable,2,relateid,ld_tranlabel.fieldlabel from ld_producttoolfield
INNER JOIN ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid

 where ld_producttoolfield.tabid=22 and ld_tranlabel.trantable='ld_producttoolfield'
and not exists(select 1 from ld_tranlabel where tabid=2 and ld_tranlabel.trantable='ld_producttoolfield');
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',205,205,'设置{$Potentials.Potentials}是否显示产品分录明细' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and tabid=205);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',205,205,'Whether to display product entry in the detailed interface of {$Potentials.Potentials}' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and tabid=205);
delimiter;

update ld_producttoolfield set tablename='ld_potential' where tabid=2 and tablename='ld_salesorder';
delimiter;

call AddColumn('ld_potential','total','decimal',25,'0');
delimiter;
alter table ld_potential modify column total decimal(25,8) ;
delimiter;

call AddColumn('ld_potential','subtotal','decimal',25,'0');
delimiter;
alter table ld_potential modify column subtotal decimal(25,8) ;
delimiter;

call AddColumn('ld_potential','discount_amount','decimal',25,0);
delimiter;

call AddColumn('ld_potential','discount_percent','decimal',25,0);
delimiter;
call AddColumn('ld_potential','discount_type','int',11,'');
delimiter;

call AddColumn('ld_potential','adjustment','decimal',25,0);
delimiter;
alter table ld_potential modify column adjustment decimal(25,8) ;
delimiter;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select 2,columnname,columnindex,ld_cvcolumnlist.cvid from ld_customview
INNER JOIN ld_cvcolumnlist 
on ld_cvcolumnlist.cvid=ld_customview.cvid
where ld_customview.entitytype='potentials'
and  not exists(select 1 from ld_tabwithproductview where tabid=2);
delimiter;

update ld_tabwithproductview set `columns` =replace(columns,'absamount','cf_1308')
where tabid=2 and `columns` like '%absamount%';
delimiter;

update ld_potential set total=amount,subtotal=amount;
delimiter;

select usereportid into @reportid from ld_usereport where name='InventoryAccount';
update ld_usereportcolumns set realencolumns='ld_products:made_in:made_in:Products_Made In:V'
where Usereportid=@reportid and realencolumns='ld_products:made_in:made_in:Products_Made_IN:V';

select usereportid into @reportid from ld_usereport where name='InventoryQuery';
update ld_usereportcolumns set realencolumns='ld_products:made_in:made_in:Products_Made In:V'
where Usereportid=@reportid and realencolumns='ld_products:made_in:made_in:Products_Made_IN:V';
delimiter;

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=537&fromuid=1'
where linktype='Settings' and linklabel='dingtalk_setting';
delimiter;
-- 2019-09-20

UPDATE ld_desk SET fieldlabel='字段公式' WHERE labelbol='ADVANCEDPROPERTIES' AND languagetype='zh' AND Labeltype='fixedstr';

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

UPDATE ld_version SET old_version='V7.8.9',current_version='V7.8.9',remark='V7.8.9-20190920',wx_version='V7.8.9';
delimiter;