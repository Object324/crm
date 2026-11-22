update ld_stuff set relatedmodule='Potentials' where stufftitle='StatisticsPotentialsBySalesPersonAndSalesStage';
delimiter;
ALTER TABLE `ld_homeboard`
    MODIFY COLUMN `createdtime`  timestamp NULL DEFAULT NULL AFTER `smcreatorid`;
delimiter;

set @disable_triggers = 'aaa';
set @tmp_approve = (select deploy_value from ld_systems_deploy where setype = 'ServiceContracts');
UPDATE ld_account INNER JOIN
(SELECT accountid,min(new_date) as min_end_date from
	(SELECT ld_servicecontracts.accountid,ld_servicecontractsdetail.productid,MAX(ld_servicecontractsdetail.servicecontracts_end_date) as new_date
	from ld_servicecontracts
	INNER JOIN ld_servicecontractsdetail  on ld_servicecontractsdetail.id = ld_servicecontracts.servicecontractsid
	where ld_servicecontracts.accountid >0 and IFNULL(ld_servicecontractsdetail.servicecontracts_end_date,'0000-00-00')>'1600-01-01'
	and (@tmp_approve = 1 or approvestatus = '已批准')
	GROUP BY accountid,productid) as tmpdata1
GROUP BY accountid) as tmpdata2 on tmpdata2.accountid = ld_account.accountid
set earlyservicedate=min_end_date;
set @disable_triggers = NULL; 
delimiter;


update ld_customtable set `sqlstr`='select \np.smownerid,\np.potential_no,\np.potentialid,\np.potentialname,\na.accountname,\nu.last_name,\np.total,\nmodtracker.prevalue as postvalue,\nmodtracker.createdtime,\nmodtracker.endtime,\ntimestampdiff(HOUR,modtracker.createdtime,modtracker.endtime)as gaptime\nfrom \nld_potential p \nleft join ld_account a on p.accountid=a.accountid\nleft join ld_users u on u.id=p.smownerid\nleft join(\nselect   t.crmid,t1.crmid as crmid1 ,timestampdiff(HOUR,t1.changedon,t.changedon)as gaptime,t1.j,t.prevalue,\ncase when t.crmid<>ifnull(t1.crmid,0)  then t.createdtime else t1.changedon  end as createdtime ,t.changedon as endtime \nfrom \n(select (@i:=@i+1) as i,a.*,p.createdtime,detail.postvalue,detail.prevalue from ld_modtracker_basic  as a left join ld_modtracker_detail detail on  detail.id=a.id INNER JOIN ld_potential  as p on p.potentialid=a.crmid and p.deleted=0 and detail.fieldname=\'sales_stage\' and a.module=\'Potentials\',(select @i:=0) as it    order by id asc) t\nleft join \n(select (@j:=@j+1) as j,a.* from ld_modtracker_basic as a left join ld_modtracker_detail detail on  detail.id=a.id INNER JOIN ld_potential \nas p on p.potentialid=a.crmid and p.deleted=0 and  detail.fieldname=\'sales_stage\' and a.module=\'Potentials\',(select @j:=1) as it     order by id asc ) t1\non t.i=t1.j\n\nunion all \n\nselect\n a.crmid,a.crmid as crmid1,\'-\' as gaptime,0 as j,detail.postvalue,a.changedon as createdtime,\'-\'as endtime\nfrom ld_modtracker_basic  as a left join ld_modtracker_detail detail on  detail.id=a.id\nINNER JOIN (SELECT max(a.id) AS id FROM ld_modtracker_basic a LEFT JOIN ld_modtracker_detail detail ON detail.id = a.id WHERE detail.fieldname = \'sales_stage\' AND a.module = \'Potentials\' GROUP BY crmid )b on a.id=b.id \nwhere detail.fieldname=\'sales_stage\' and a.module=\'Potentials\'\n\n)modtracker on modtracker.crmid=p.potentialid\nwhere p.deleted=0\nand p.createdtime>=DATE_FORMAT(\'{starttime}\',\'%Y-%m-%d 00:00:00\') and p.createdtime<=DATE_FORMAT(\'{endtime}\',\'%Y-%m-%d 23:59:59\')\nand find_in_set(p.smownerid,\'{userid}\')\norder by p.smownerid asc,p.potentialid desc,modtracker.createdtime desc'
where `primaryname`='potiential_report_stay_period' and deleted=0;
delimiter;


update ld_desk set fieldlabel='{$Potentials.sales_stage} Transformation analysis' where languagetype = 'en' AND labelbol='SalesPhaseTransformationAnalysis' and Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileKanbanCustomization','移动端看板定制','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MobileKanbanCustomization' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileKanbanCustomization','Mobile Kanban Customization','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MobileKanbanCustomization' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileCankao','效果仅供参考，实际以手机端为准','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MobileCankao' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileCankao','The effect is for reference only, and the actual situation is subject to the mobile end','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MobileCankao' and labeltype='jspop');
delimiter;

DROP PROCEDURE IF EXISTS `addproducttoolfilecolumn`;
delimiter ||
CREATE  PROCEDURE `addproducttoolfilecolumn`()
BEGIN
	declare done  int  default 0;
	declare ccolumnname varchar(100) ;
	declare ttablename varchar(100);
	declare cur2 CURSOR FOR select columnname,tablename from ld_producttoolfield where (uitype=69 or uitype=1109) and savedatabase='yes'
                                                                                   and tablename!="ld_products" ;
declare continue handler  for not   found  SET done =1;
open cur2;
fetch cur2 into ccolumnname ,ttablename;
loop2: while  done<>1 DO
		set @sql=Concat(' call AddColumn( "',ttablename,'","',ccolumnname,'","char","5","")');
prepare stmt from @sql;
execute stmt;
deallocate  prepare  stmt;
fetch cur2 into ccolumnname ,ttablename;
end while loop2;
close cur2;
end ||
delimiter;
call addproducttoolfilecolumn();


DROP PROCEDURE IF EXISTS `addtablefilecolumn`;
delimiter ||
CREATE PROCEDURE `addtablefilecolumn` ()
BEGIN
	DECLARE done INT DEFAULT 0 ;
	DECLARE ccolumnname VARCHAR (100) ;
    DECLARE ttablename VARCHAR (100) ;
    DECLARE cur2 CURSOR FOR
        SELECT columnname,tablename FROM ld_tabdetailfield
            WHERE (bigtype = 'fileattachment' OR bigtype = 'image') AND savedatabase = 'yes';
DECLARE CONTINUE HANDLER FOR NOT found SET done = 1 ;
OPEN cur2 ;
FETCH cur2 INTO ccolumnname,ttablename ;
loop2: WHILE done <> 1
			  	DO SET @SQL = Concat(' call AddColumn( "',ttablename,'","',ccolumnname,'","char","5","")') ;
        PREPARE stmt FROM @SQL ;
        EXECUTE stmt ;
        DEALLOCATE PREPARE stmt ;
        FETCH cur2 INTO ccolumnname,ttablename ;
        END
WHILE loop2 ;
CLOSE cur2 ;
END||
delimiter;

CALL addtablefilecolumn();
delimiter ;

UPDATE ld_desk SET fieldlabel='皮肤定制' WHERE labelbol='menustyle' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk SET fieldlabel='Skin customization' WHERE labelbol='menustyle' and Labeltype='fixedstr' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DataDictionary','数据字典','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DataDictionary' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DataDictionary','Data Dictionary','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DataDictionary' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FieldLocation','字段位置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FieldLocation' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FieldLocation','field location','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FieldLocation' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TableFieldLocated','字段所在表名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TableFieldLocated' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TableFieldLocated','Table name the field is located','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TableFieldLocated' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOCHEAD','单据头','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DOCHEAD' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOCHEAD','Document header','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DOCHEAD' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOCENTRY','单据分录','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DOCENTRY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOCENTRY','Document entry','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DOCENTRY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_stuff set datarangmodule='Potentials' where stufftitle='StatisticsPotentialsBySalesPersonAndSalesStage';
delimiter;

SET @labelbol = 'DefaultSaleskit';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'预设简报','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Default Saleskit','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CustomSaleskit';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自定义简报','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Custom Saleskit','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CustomSaleskit';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自定义简报','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Saleskit Saleskit','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

UPDATE ld_homestuffdetail SET is_default = 'no' WHERE stuffid = 100 AND stufflabel LIKE 'custom_%';
delimiter;

SET @labelbol = 'DefaultDragonTigerList';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'预设龙虎榜','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Default Dragon Tiger List','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CustomDragonTigerList';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自定义龙虎榜','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Custom Dragon Tiger List','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OperationTip';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'操作提示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Operation Tip','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DragonTigerListTip';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击添加龙虎榜组件','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click to add the Dragon Tiger List component','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SaleskitTip';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'拖动简报移入画板以添加简报','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Drag the Saleskit into the drawing board to add it','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SaleskitTip2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'双击添加简报','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Double-click to add the Saleskit','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EditHomeBoardTip';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'拖动组件移入画板以添加组件','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Drag the Component into the drawing board to add it','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EditHomeBoardTip2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'双击添加组件','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Double-click to add the Component','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2023-12-07

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

UPDATE ld_version SET old_version='V8.6.1.7',current_version='V8.6.1.7',remark='V8.6.1.7-20231207',wx_version='V8.6.1.5';
delimiter;