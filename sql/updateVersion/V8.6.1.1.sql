INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','dragstuff','请从左侧拖拽报表组件至此处', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'dragstuff' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','dragstuff','Please drag the stuff from the left to this point', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'dragstuff' AND labeltype = 'fixedstr' );
delimiter;

SELECT MAX(sequence) INTO @sequence FROM ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'yes',464,'设置单据分录明细录入重复产品时是否需要提示','',@sequence+1,5,'select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 464);
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',464,464,'设置单据分录明细录入重复{$Products.Products}时是否需要提示'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_systems_deploy' and tabid = 464 and relateid=464);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',464,464,'Set whether to prompt the entry of duplicate {$Products.Products} in the document entry details'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = 464 and relateid=464);
delimiter;

CALL AddColumn('ld_stuff','pc_show','varchar','10','yes');
CALL AddColumn('ld_stuff','mobile_show','varchar','10','no');
update   ld_settings_field set linkto='index.php?module=Settings&action=mobile_home_setting&parenttab=Settings&from_module=MobileReport' where name='mobile_home_setting';

update ld_stuff set mobile_show='yes' where stufftitle in ('CUSTOMERTYPEDISSTATIS','ContactTimesRanking','CUSTOMERSOURCEDISSTATIST','AMOUNTMONTHCONTRACTYEAR','BACKAMOUNTMONTHYEAR','SALESFUNNEL','saleskit','CRITICALVIEW','Contractamount');
update ld_stuff set mobile_show='no' where stuffid=103;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show)
select 108,'commonmodules','commonmodules','','','no','yes' from dual
where not exists(select 1 from ld_stuff where stufftitle= 'commonmodules' and stufftype= 'commonmodules');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','commonmodules','常用模块','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='commonmodules' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','commonmodules','Common modules','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='commonmodules' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show)
select 109,'SaleDragonTiger','salesdragontiger','','','no','yes' from dual
where not exists(select 1 from ld_stuff where stufftitle= 'SaleDragonTiger' and stufftype= 'salesdragontiger');


insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show)
select 110,'Contractkit','Contractkit','','','no','yes' from dual
where not exists(select 1 from ld_stuff where stufftitle= 'Contractkit' and stufftype= 'Contractkit');

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show)
select 111,'CustomReportBlock','customreportblock','','','no','yes' from dual
where not exists(select 1 from ld_stuff where stufftitle= 'CustomReportBlock' and stufftype= 'customreportblock');
update ld_stuff set mobile_show='no' where stufftitle='CustomReportBlock';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CustomReportBlock','自定义报表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomReportBlock' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CustomReportBlock','Custom Report','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomReportBlock' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_init_mobilekanban`;
delimiter ||
CREATE PROCEDURE `ldcrm_init_mobilekanban`(
)
BEGIN
	IF NOT EXISTS (select 1 from ld_homeboard where boardtype='MobileReport' and deleted=0) THEN
select max(boardid)+1 into @boardid from ld_homeboard;
select IFNULL(deploy_value,'thismonth') INTO @timesearchdefault from ld_systems_deploy where deploy_type=345 GROUP BY deploy_type;
INSERT INTO ld_homeboard
(`boardid`,`boardname`,`description`,`smcreatorid`,`boardlayout`,`scope`,`createdtime`,`modifiedby`,`modifiedtime`,`timesearchdefault`,
 `approve_value`,`icon_path`,`boardtype`,`sequence`)
VALUES (@boardid,'移动端默认看板','移动端默认看板',1,1,'all',NOW(),1,NOW(),@timesearchdefault,'unapproved,approving,approved,rejected,dismissed','','MobileReport',1);

SELECT max(plateid)+1 into @plateid from ld_homeboard_plate;
INSERT INTO ld_homeboard_plate(`plateid`,`boardid`,`platetype`,`platewidth`,`sequence`) VALUES (@plateid,@boardid,'whole','1-1',1);

insert into
    ld_homeboard_plate_stuff (stuffid,boardid,plateid,stufftype,sequence,height,stufftitle_en,stufftitle_zh)
select
    ld_stuff.stuffid,@boardid,@plateid,'defaultstuff',a.home_sequence,'370px','',''
from ld_stuff
         right join (
    select
        (case when `name`='Saleskit' or `name`='commonmodules' then `name`
              when `name`='Contractamount' then 'AMOUNTMONTHCONTRACTYEAR'
              when `name`='salesdragontiger' then 'SaleDragonTiger'
              when `name`='keyViews' then 'CRITICALVIEW'
              else labelbol end)as labelbol,image,home_sequence from ld_dashboard_app where home_presence='yes' and home_sequence>0 order by home_sequence asc
)a on ld_stuff.stufftitle=a.labelbol;

insert into ld_homestuffsaleskit2board (boardid,homestuffdetailid,sequence)
select @boardid,id,sequence from ld_homestuffdetail where presence='yes' and stuffid=35 order by sequence asc ;

delete from ld_homeboard_plate_stuff where stuffid=111 and boardid=@boardid;
delete from ld_homeboard_plate_stuff where stuffid=103 and boardid=@boardid;

end if;
END ||
delimiter;

CALL ldcrm_init_mobilekanban();
DROP PROCEDURE IF EXISTS `ldcrm_init_mobilekanban`;
delimiter;

update ld_homeboard_plate_stuff  set stufftitle_en='' where stufftitle_en is null;
update ld_homeboard_plate_stuff  set stufftitle_zh='' where stufftitle_zh is null;

DROP TABLE if EXISTS `ld_shop_othersettings`;
CREATE TABLE IF NOT EXISTS `ld_shop_othersettings` (
    `keyid` int(11) NOT NULL auto_increment PRIMARY KEY,
    `entityid` int(11),
    `entityname` varchar(100),
    `display` varchar(20),
    `sequence` int(11),
    `type` Varchar(20)
    )ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_reminder`(
	tmp_content text,
	tmp_recieverid TEXT,
	tmp_reltab VARCHAR(100),
	tmp_related_to INT(19)
)
BEGIN

	DECLARE tmp_userid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			DISTINCT substring_index(substring_index(a.mytext,',', b.seq+1 ),',',- 1) AS mytext
		FROM (SELECT tmp_recieverid AS mytext) a
		LEFT JOIN sequence b ON b.seq <(length(a.mytext) - length( REPLACE(a.mytext,',',''))+1) 
		WHERE substring_index(substring_index(a.mytext,',', b.seq+1 ),',',- 1)+0>0
		ORDER BY b.seq;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_userid = NULL;


	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_userid;
	WHILE(tmp_userid IS NOT NULL) DO
	
		SET @max_remindid=(SELECT MAX(crmid) FROM ld_crmentity);
		IF EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid=@max_remindid+1) OR EXISTS (SELECT 1 FROM ld_reminds WHERE remindsid=@max_remindid+1) OR EXISTS (SELECT 1 FROM ld_reminds_accepted WHERE remindsid=@max_remindid+1) THEN
			SET @max_remindid=(SELECT MAX(crmid)+10 FROM ld_crmentity); 
		END IF;

		INSERT INTO ld_crmentity(crmid,setype)
		SELECT @max_remindid+1,'Reminds';		

		UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
		
		INSERT INTO ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
		SELECT @max_remindid+1,tmp_content,now(),tmp_userid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0;
		
		FETCH MYCUSOR INTO tmp_userid;
	END WHILE;
	CLOSE MYCUSOR;


end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_reminder_havetype`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_reminder_havetype`(
	tmp_content text,
	tmp_recieverid INT(19),
  tmp_reltab VARCHAR(100),
	tmp_related_to INT(19),
	tmp_remindstype VARCHAR(100)
    
)
BEGIN
	
	SET @max_remindid=(SELECT MAX(crmid) FROM ld_crmentity);
		IF EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid=@max_remindid+1) OR EXISTS (SELECT 1 FROM ld_reminds WHERE remindsid=@max_remindid+1) OR EXISTS (SELECT 1 FROM ld_reminds_accepted WHERE remindsid=@max_remindid+1) THEN
			SET @max_remindid=(SELECT MAX(crmid)+10 FROM ld_crmentity); 
		END IF;

	INSERT INTO ld_crmentity(crmid,setype)
	SELECT @max_remindid+1,'Reminds';		

	UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
	
	INSERT INTO ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted,remindstype)
	SELECT @max_remindid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0,tmp_remindstype;

end ||
delimiter;

CALL AddColumn('ld_users','pinyin_name','VARCHAR','100','');
delimiter;

UPDATE ld_users
SET pinyin_name = CASE
                      WHEN
                          (select LEFT(DATABASE(),2)='wx' AND RIGHT (DATABASE(),5)+0>17000)
                      THEN getpinyin(real_name)
                   ELSE
                      getpinyin(last_name)
                   END
WHERE pinyin_name IS NULL OR pinyin_name = '';
delimiter;

update ld_sendcashbill2payment set sequence_no = Sequence where IFNULL(sequence_no,0) = 0;
update ld_cashbill2paymentplan set sequence_no = Sequence where IFNULL(sequence_no,0) = 0;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOURCEFROMCAMCARD','来源名片','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SOURCEFROMCAMCARD' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOURCEFROMCAMCARD','Create from Bussiness Card','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SOURCEFROMCAMCARD' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='Leads';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_LEADS_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'sourcefrom','ld_leads',1,118,'sourcefrom','单据来源',1,0,@sequence,@blockid ,3,'V~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sourcefrom');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sourcefrom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据来源' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Source' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab where name='Accounts';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'sourcefrom','ld_account',1,118,'sourcefrom','单据来源',1,0,@sequence,@blockid ,3,'V~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sourcefrom');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sourcefrom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据来源' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Source' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab where name='Contacts';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_CONTACT_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'sourcefrom','ld_contactdetails',1,118,'sourcefrom','单据来源',1,0,@sequence,@blockid ,3,'V~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sourcefrom');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sourcefrom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据来源' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Source' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_VENDOR_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'sourcefrom','ld_vendor',1,118,'sourcefrom','单据来源',1,0,@sequence,@blockid ,3,'V~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sourcefrom');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sourcefrom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据来源' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Source' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab where name='VendorContact';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_VendorContact_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'sourcefrom','ld_vendorcontacts',1,118,'sourcefrom','单据来源',1,0,@sequence,@blockid ,3,'V~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sourcefrom');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sourcefrom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据来源' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Source' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

CALL AddColumn('ld_leads','sourcefrom','varchar','100',null);
CALL AddColumn('ld_account','sourcefrom','varchar','100',null);
CALL AddColumn('ld_contactdetails','sourcefrom','varchar','100',null);
CALL AddColumn('ld_vendor','sourcefrom','varchar','100',null);
CALL AddColumn('ld_vendorcontacts','sourcefrom','varchar','100',null);
delimiter;

insert into ld_camcard_comparison(modulename,comparisoname,status)
select 'Leads','T1',1 from dual
where not exists(select 1 from ld_camcard_comparison where modulename = 'Leads' and comparisoname = 'T1');
delimiter;

SELECT comparid INTO @comparid_Leads from ld_camcard_comparison WHERE modulename='Leads' AND comparisoname='T1' LIMIT 1;
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'formatted_name','ld_leads:contactname:contactname:Leads_fieldlabel:V' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'formatted_name');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'label','ld_leads:bill_street:bill_street:Leads_fieldlabel:V' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'label');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'organization','ld_leads:accountname:accountname:Leads_fieldlabel:V' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'organization');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'title','ld_leads:contact_job:contact_job:Leads_fieldlabel:V' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'title');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'role','' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'role');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'callular','' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'callular');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field) select @comparid_Leads,'telephone','' from dual
where not exists(select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'telephone');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'facsimile','' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'facsimile');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'email','' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'email');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'url','' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'url');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'sns','' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'sns');
insert into ld_camcard_comparison_detail(comparid,card_field,crm_field)
select @comparid_Leads,'im','' from dual where not exists(
    select 1 from ld_camcard_comparison_detail where comparid = @comparid_Leads and card_field = 'im');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','drag','拖动','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='drag' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','drag',"Drag",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='drag' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel='搜索附近客户名称' where labelbol='SEARCHLOCATION' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Search for nearby customer names' where labelbol='SEARCHLOCATION' and languagetype='en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CloudHub','云之家','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CloudHub' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CloudHub','Cloud Hub','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CloudHub' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='The total amount of the order {$PaymentPlan.PaymentPlan} shall not be greater than the {$SalesOrder.SalesOrder} amount' WHERE labelbol= 'ORDERCREATED' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='该订单{$PaymentPlan.PaymentPlan}总金额不得大于{$SalesOrder.SalesOrder}金额' WHERE labelbol= 'ORDERCREATED' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;
SET @tabid = (SELECT tabid from ld_tab where name = 'Users');
UPDATE ld_field SET fieldonly = 1,masseditable = 0 WHERE tabid = @tabid AND columnname in('wx_userid','wx_openid','dingtalk_userid','yunzhijia_wbuserid');
UPDATE ld_field SET masseditable = 0 WHERE tabid = @tabid AND columnname = 'imagename';
UPDATE ld_field SET masseditable = 2 WHERE tabid = @tabid AND columnname in('email1','phone_mobile','phone_home');
delimiter;


ALTER TABLE ld_wechatsession MODIFY COLUMN address text;
ALTER TABLE ld_wechatsession MODIFY COLUMN title text;
ALTER TABLE ld_wechatsession MODIFY COLUMN image_url text;
delimiter;
-- 2023-10-27

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

UPDATE ld_version SET old_version='V8.6.1.1',current_version='V8.6.1.1',remark='V8.6.1.1-20231027',wx_version='V8.6.1.1';
delimiter;