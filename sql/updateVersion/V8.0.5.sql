DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	
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

CALL addtableIndex('ld_projectmilestone','projectid','projectid');

UPDATE ld_relatedlists SET related_coltable='attachmentsforbills.related_to' WHERE `name`='get_attachment' AND related_coltable LIKE 'attachmentsforbills.customform%';
UPDATE ld_settings_advance SET `enable`='no' WHERE tabid=37 AND module_field='contract_status';

SET @disable_triggers=1;
SET @tmp_module='CashBill';
SET @tmp_viewname='全部收款单';
SET @maxcvid=(SELECT MAX(cvid) FROM ld_customview);
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)
SELECT @maxcvid+1,@tmp_viewname,0,0,@tmp_module,3,1,101,100 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=@tmp_module and viewname=@tmp_viewname);

SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=@tmp_module AND viewname=@tmp_viewname);
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

SET @cvid_all=(SELECT cvid FROM ld_customview WHERE entitytype=@tmp_module AND viewname='All');
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(@tmp_module),':','cashtype',':','cashtype',':',@tmp_module,'_fieldlabel:V'),'e','收款',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;


SET @tmp_module='CashBill';
SET @tmp_viewname='全部预收单';
SET @maxcvid=(SELECT MAX(cvid) FROM ld_customview);
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)
SELECT @maxcvid+1,@tmp_viewname,0,0,@tmp_module,3,1,102,100 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=@tmp_module and viewname=@tmp_viewname);

SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=@tmp_module AND viewname=@tmp_viewname);
DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

SET @cvid_all=(SELECT cvid FROM ld_customview WHERE entitytype=@tmp_module AND viewname='All');
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;

INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
SELECT @cvid,0,CONCAT('ld_',LOWER(@tmp_module),':','cashtype',':','cashtype',':',@tmp_module,'_fieldlabel:V'),'e','预收',1,'';

INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
SELECT 1,@cvid,0;

SET @i=0;
UPDATE ld_customview SET sequence=sequence+10 WHERE entitytype=@tmp_module;
UPDATE ld_customview SET sequence=1 WHERE entitytype=@tmp_module AND viewname='All';
UPDATE ld_customview SET sequence=2 WHERE entitytype=@tmp_module AND viewname='全部收款单';
UPDATE ld_customview SET sequence=3 WHERE entitytype=@tmp_module AND viewname='全部预收单';
UPDATE ld_customview SET sequence=(@i:=@i+1) WHERE entitytype=@tmp_module ORDER BY sequence;
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Image','图片','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='image' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Image','Image','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='image' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='Contract Amount' where labelbol='SignContractAmount' and labeltype='fixedstr' and languagetype='en';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QTY','数量','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='QTY' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','QTY','Quantity','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='QTY' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AMOUNT','金额','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AMOUNT' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AMOUNT','Amount','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AMOUNT' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURYEAR','今年','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CURYEAR' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURYEAR','This Year','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CURYEAR' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PREVYEAR','去年','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PREVYEAR' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PREVYEAR','Prev Year','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PREVYEAR' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YUAN','元','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='YUAN' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','YUAN','','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='YUAN' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GECOUNT','个','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GECOUNT' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','GECOUNT','','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GECOUNT' and Labeltype='jspop');
delimiter;

update ld_desk set fieldlabel='Last Year' where labelbol='PREVYEAR' and labeltype='fixedstr' and languagetype='en';
delimiter;

select tabid into @tabid from ld_tab where name='cashbill';
insert into ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
select @tabid,'debuctionamount',6,'normal',0,'yes' from dual 
where not exists(select 1 from ld_fieldwxmaininfo where tabid=@tabid and fieldname='debuctionamount');

insert into ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
select @tabid,'debuctionbalanceamount',6,'normal',0,'yes' from dual 
where not exists(select 1 from ld_fieldwxmaininfo where tabid=@tabid and fieldname='debuctionbalanceamount');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thelocationaddress','定位地址中必须包含省份和城市，请输入准确的地址！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='thelocationaddress' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','thelocationaddress','The location address must contain provinces and cities. Please enter the correct address.','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='thelocationaddress' and labeltype='fixedstr');
delimiter;

delete  from ld_homestuffdetailcondition
where homestuffdetailid in(select id from ld_homestuffdetail where stufflabel='ChangePotentialStageCount');
delimiter;

delete from ld_homestuffdetail where stufflabel='ChangePotentialStageCount';
delimiter;
 
update ld_homestuffdetailcondition set `columns`='ld_contactrecords:contactdate:contactdate:ContactRecords_联系日期:DT'
where homestuffdetailid in(select id  from ld_homestuffdetail where stufflabel='NewContactRecords')
and `columns` like '%ld_contactrecords:createdtime:createdtime:ContactRecords%';
delimiter;

update ld_field set defaultvalue='' where defaultvalue='undefined';
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','已下单数量','haveordercount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='haveordercount' and labeltype='fixedstr');
insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','已下单数量','haveordercount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='haveordercount' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','未下单数量','balanceordercount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='balanceordercount' and labeltype='fixedstr');
insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','未下单数量','balanceordercount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='balanceordercount' and labeltype='fixedstr');
delimiter;

DELETE FROM ld_tabwithproductview WHERE cvid IS NULL;


update ld_desk set fieldlabel='查重' where labelbol='ACCOUNTDUPLICATECHECK' and languagetype='zh' and labeltype='fixedstr';
delimiter;
-- 2020-06-05

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

UPDATE ld_version SET old_version='V8.0.5',current_version='V8.0.5',remark='V8.0.5-20200605',wx_version='V8.0.5';
delimiter;