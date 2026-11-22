set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`='Holiday');
set @max_seq = (select MAX(sequence) from ld_option_module where tabid=@tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,@max_seq+1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`='Personnelfile');
set @max_seq = (select MAX(sequence) from ld_option_module where tabid=@tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,@max_seq+1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`='Laborcontract');
set @max_seq = (select MAX(sequence) from ld_option_module where tabid=@tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,@max_seq+1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`='Salary');
set @max_seq = (select MAX(sequence) from ld_option_module where tabid=@tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,@max_seq+1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`='Competition');
set @max_seq = (select MAX(sequence) from ld_option_module where tabid=@tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,@max_seq+1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApproveRejected','被驳回的','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ApproveRejected' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApproveRejected','Rejected','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ApproveRejected' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApproveRejected','被驳回的','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ApproveRejected' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApproveRejected','Rejected','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ApproveRejected' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOREJECTEDDATA','没有被驳回的数据','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOREJECTEDDATA' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOREJECTEDDATA','No rejected data','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOREJECTEDDATA' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOMOREREJECTEDDATA','没有更多被驳回的数据','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOMOREREJECTEDDATA' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOMOREREJECTEDDATA','No more rejected data','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOMOREREJECTEDDATA' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update  ld_field set bigtype='selectmultiuser' where fieldname='team_memberid' and uitype='154';
delimiter;

UPDATE ld_modentity_num set isallow = 0 WHERE semodule LIKE "CustomForm%" and cur_id = 1;
delimiter;

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Export','rely','导出','Batchoffshelves.png' from dual
where not exists(select 1 from ld_listview_btn where `name`='Export' and btntype='rely');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SignoutType','签退方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SignoutType' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SignoutType','Sign out type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SignoutType' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_delete_customform181_200`;
delimiter ||
CREATE PROCEDURE `ldcrm_delete_customform181_200`(
)
BEGIN
DECLARE i int DEFAULT 181;
WHILE i<=200 DO

SET @tablename=(SELECT tablename FROM ld_field WHERE tablename=CONCAT('ld_customform',i) and columnname='smownerid' LIMIT 1);
SET @tabid=(SELECT tabid FROM ld_field WHERE tablename=CONCAT('ld_customform',i) and columnname='smownerid' LIMIT 1);

IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype=CONCAT('CustomForm',i)) OR NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='source_list' AND presence IN(0,2)) THEN
    DELETE FROM ld_field WHERE tablename = @tablename AND columnname='source_list';
END IF;

SET i=i+1;
END WHILE;

end ||
delimiter;

CALL ldcrm_delete_customform181_200();
DROP PROCEDURE IF EXISTS `ldcrm_delete_customform181_200`;
delimiter;
-- 2024-04-07

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pictures','个图片','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Pictures' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pictures'," pictures",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Pictures' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOCATIONNOTEMPTY','定位不能为空','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOCATIONNOTEMPTY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOCATIONNOTEMPTY',"Location cannot be empty",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOCATIONNOTEMPTY' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTCCRANGE','请选择抄送范围','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESELECTCCRANGE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTCCRANGE',"Please select the CC range",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESELECTCCRANGE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PUBLISHEDSUCCESSFULLY','发布成功','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PUBLISHEDSUCCESSFULLY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PUBLISHEDSUCCESSFULLY',"Successfully published",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PUBLISHEDSUCCESSFULLY' and labeltype='fixedstr');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_FILE_INFORMATION';
UPDATE ld_field SET block = @blockid,sequence=1 WHERE tabid = @tabid and columnname = 'signout_imagename';
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
UPDATE ld_field SET sequence = 1 WHERE tabid = @tabid and columnname = 'signout';
SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'source_list';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'entityaddress';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signin_id';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signout_time';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signout_address';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signout_distance';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signout_type';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'timeused';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'smownerid';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'smcreatorid';
delimiter;

update ld_desk set fieldlabel='（多次查询没有结果请联系管理员检查工商查询接口信息）' where labelbol='PlaceCheckTianYanChaInterface' and languagetype='zh';
update ld_desk set fieldlabel='(Multiple queries without results, please contact the admin to check the business query interface information)' where labelbol='PlaceCheckTianYanChaInterface' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SCORE','评分','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SCORE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SCORE',"Score",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SCORE' and labeltype='fixedstr');
delimiter;


UPDATE ld_tabdetailfield SET savedatabase='yes' WHERE columnname ='remark' AND savedatabase='no';
delimiter;

SET @cvid = (select cvid from ld_cvcolumnlist WHERE columnname = "ld_signout:signout_time:signout_time:Signout_fieldlabel:DT" LIMIT 1);
INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
SELECT @cvid,CONCAT('ld_signout:createdtime:createdtime:Signout_DT~O:fieldlabel'),'desc' from dual
where not exists(select 1 from ld_cvcolumnlistsort where cvid=@cvid);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds');
UPDATE ld_field SET quickcreate=3 WHERE tabid=@tabid AND columnname='status_rmd' AND quickcreate=0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILTERCRITERIA','筛选条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FILTERCRITERIA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILTERCRITERIA',"Filter criteria",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FILTERCRITERIA' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WECHATCLIENTCHOOSEFILE','微信客户端会话选择文件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WECHATCLIENTCHOOSEFILE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WECHATCLIENTCHOOSEFILE',"WeChat client session selection file",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WECHATCLIENTCHOOSEFILE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhotoAlbum','相册','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhotoAlbum' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhotoAlbum',"Photo album",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhotoAlbum' and labeltype='fixedstr');
delimiter;

SELECT blockid,sequence into @blockid,@sequence FROM ld_settings_field WHERE name='yunzhijia_setting';
set @count = (SELECT COUNT(1) FROM ld_settings_field WHERE `name`='zhiyuan_setting');
UPDATE ld_settings_field set sequence = sequence +1 where blockid = @blockid and sequence > @sequence
and @count <= 0;

SET @MAX=(SELECT MAX(fieldid)+1 FROM ld_settings_field);
INSERT INTO ld_settings_field (fieldid,blockid,name,iconpath,description,linkto,sequence,active)
SELECT @MAX,@blockid,'zhiyuan_setting','picklistdependency.png','zhiyuan_setting','index.php?module=Settings&action=zhiyuan_setting&parenttab=Settings', @sequence+1, 1 
from dual where not EXISTS(SELECT 1 FROM ld_settings_field WHERE `name`='zhiyuan_setting');

UPDATE ld_settings_field_seq set id = (SELECT MAX(fieldid) FROM ld_settings_field);

delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','zhiyuan_setting','致远接口设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='zhiyuan_setting' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','zhiyuan_setting',"Zhiyuan Interface Settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='zhiyuan_setting' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THEINTERFACEPARAMENTERS','接口参数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='THEINTERFACEPARAMENTERS' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THEINTERFACEPARAMENTERS',"Interface",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='THEINTERFACEPARAMENTERS' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WECHATAPPLETSETTINGSTITLE02','CRM外网访问地址','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WECHATAPPLETSETTINGSTITLE02' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WECHATAPPLETSETTINGSTITLE02',"Server address",'fixedstr'from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WECHATAPPLETSETTINGSTITLE02' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZhiyuanAccessAddress','致远访问地址','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZhiyuanAccessAddress' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZhiyuanAccessAddress',"Zhiyuan access address",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZhiyuanAccessAddress' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZhiyuanSystemRegistrationCode','致远系统注册码','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZhiyuanSystemRegistrationCode' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZhiyuanSystemRegistrationCode',"Zhiyuan System Registration Code",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZhiyuanSystemRegistrationCode' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZhiyuanUsername','致远用户名','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZhiyuanUsername' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZhiyuanUsername',"Zhiyuan Username",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZhiyuanUsername' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZhiyuanUserPassword','致远密码','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZhiyuanUserPassword' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZhiyuanUserPassword',"Zhiyuan Password",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZhiyuanUserPassword' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHIYUANSETTINGSREMIND01','1、CRM外网访问地址请参照此格式输入:http://www.51mis.com/crm/','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHIYUANSETTINGSREMIND01' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHIYUANSETTINGSREMIND01',"1. CRM external network access address, please refer to this format for input: http://www.51mis.com/crm/",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHIYUANSETTINGSREMIND01' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHIYUANSETTINGSREMIND02','2、致远访问地址、致远系统注册码、致远用户名和密码都由致远供应商提供','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHIYUANSETTINGSREMIND02' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHIYUANSETTINGSREMIND02',"2. The Zhiyuan access address, Zhiyuan system registration code, Zhiyuan username and password are all provided by the Zhiyuan supplier",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHIYUANSETTINGSREMIND02' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHIYUANSETTINGSREMIND03','3、其中致远用户名建议让致远供应商在后台配置用户绑定时使用\"手机号匹配\"类型','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHIYUANSETTINGSREMIND03' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHIYUANSETTINGSREMIND03',"3. The Zhiyuan user name is suggested to let the Zhiyuan supplier use the 'mobile phone number matching' type when configuring user binding in the background",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHIYUANSETTINGSREMIND03' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHIYUANREMINDCONTENTTEXT','$CRM外网访问地址$不能为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHIYUANREMINDCONTENTTEXT' and
labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHIYUANREMINDCONTENTTEXT',"$CRM external network access address$ can not be empty！",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHIYUANREMINDCONTENTTEXT' and
labeltype='jspop');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh','INDICATORUNIT','指标单位','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'INDICATORUNIT' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','INDICATORUNIT','Indicator unit','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'INDICATORUNIT' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh','CONVERSIONRATE','换算率','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'CONVERSIONRATE' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','CONVERSIONRATE','Conversion rate','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'CONVERSIONRATE' AND labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_salestarget_basic','indicator_unit','varchar',20,'');
delimiter;

CALL AddColumn('ld_salestarget_basic','conversion_rate','decimal',25,'');
ALTER TABLE ld_salestarget_basic MODIFY COLUMN conversion_rate double;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_salestarget_basic`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_salestarget_basic`(
)
BEGIN
    -- 声明用于循环的变量
	DECLARE finished INTEGER DEFAULT 0;
    DECLARE id int(19);
    DECLARE cur CURSOR FOR SELECT targetid FROM ld_salestarget_basic where indicator_unit is null and conversion_rate=0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
OPEN cur;
get_detailrecord: LOOP
        FETCH cur INTO id;
        IF finished = 1 THEN
            LEAVE get_detailrecord;
        END IF;
        -- 检查明细表中对应的funnmae是否存在count
        IF EXISTS(SELECT 1 FROM ld_salestarget_detail WHERE targetid = id AND funname = 'count') THEN
		    -- 存在一条funname为count的，则是计数字段
            update ld_salestarget_basic set indicator_unit='pieces',conversion_rate=1 where targetid= id;
        ELSE
            -- 不存在funname为count的，则全是求和字段，检查统计字段是否全是金融类型
			CALL ldcrm_update_salestarget_detail(id);
        END IF;
END LOOP;
CLOSE cur;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_salestarget_detail`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_salestarget_detail`(in `id` int(19))
BEGIN
    -- 声明用于循环的变量
	DECLARE finished INTEGER DEFAULT 0;
    DECLARE countfieldinfo VARCHAR(255);
    DECLARE fieldtable VARCHAR(50);
    DECLARE fieldcolumnname VARCHAR(30);
	DECLARE cur CURSOR FOR SELECT countfield FROM ld_salestarget_detail WHERE targetid = id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
OPEN cur;

get_fieldtype: LOOP
            FETCH cur INTO countfieldinfo;
            IF finished = 1 THEN
                    LEAVE get_fieldtype;
            END IF;
            SET fieldtable = SUBSTRING_INDEX(countfieldinfo, ':', 1);
            SET fieldcolumnname = SUBSTRING_INDEX(SUBSTRING_INDEX(countfieldinfo, ':', -4), ':', 1);

            IF NOT EXISTS(
                SELECT 1 FROM ld_field WHERE tablename = tablename AND columnname = fieldcolumnname AND ( uitype IN (71, 72) OR (tabid=14 and (columnname='unit_price' OR columnname='costprice')))
            union
                SELECT 1 FROM ld_producttoolfield WHERE tablename = tablename AND columnname = fieldcolumnname AND uitype IN ('28','29','32','50','163','20',730,731,810,811,72)
            union
                SELECT 1 FROM ld_tabdetailfield WHERE tablename = tablename AND columnname = fieldcolumnname AND  fieldtype IN ('amount','rmb_amount','price')
            )
            THEN
                update ld_salestarget_basic set indicator_unit='pieces',conversion_rate=1 where targetid= id;
                LEAVE get_fieldtype;
            ELSE
                update ld_salestarget_basic set indicator_unit='tenthousand',conversion_rate=0.0001 where targetid= id AND indicator_unit is null;
            END IF;
END LOOP;
CLOSE cur;
end ||
delimiter;

CALL ldcrm_update_salestarget_basic();
DROP PROCEDURE IF EXISTS `ldcrm_update_salestarget_basic`;
DROP PROCEDURE IF EXISTS `ldcrm_update_salestarget_detail`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_parenttab_ldsoukebao`;
delimiter ||
CREATE PROCEDURE `ldcrm_parenttab_ldsoukebao`(
)
BEGIN
	IF NOT EXISTS (select 1 from ld_parenttab where parenttab_label='LDsoukebao') THEN

		update ld_parenttab set sequence = sequence+1 where sequence >= 2;
		SET @parentid=(select max(parenttabid)+1 from ld_parenttab);

		insert into ld_parenttab(parenttabid,parenttab_label,sequence,allocatetype,imagename) VALUE (@parentid,'LDsoukebao',2,'all','left_nav_account_ico.png');

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name` = 'ldsoukebao');

		update ld_parenttabrel set parenttabid = @parentid, sequence = 1 where tabid = @tabid;

		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) value ('en','ld_parenttab',@parentid,@parentid,'搜客宝');

		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) value ('zh','ld_parenttab',@parentid,@parentid,'搜客宝');

		update ld_tranlabel set fieldlabel = '查企业' where trantable = 'ld_tab' and tabid = @tabid and languagetype = 'zh';

		update ld_tranlabel set fieldlabel = 'Find a company' where trantable = 'ld_tab' and tabid = @tabid and languagetype = 'en';

		select max(tabid) into @maxtabid from ld_tab;

		insert into ld_tab (tabid,`name`,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab,proportion)
		value (@maxtabid+1,'ldsoukebaomap',0,50,'ldsoukebaomap',0,0,1,'',0,0);

		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) value ('zh','ld_tab',@maxtabid+1,@maxtabid+1,'地图获客');

		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) value ('en','ld_tab',@maxtabid+1,@maxtabid+1,'Map search');

		insert into ld_parenttabrel(parenttabid,tabid,sequence) value (@parentid,@maxtabid+1,2);

	END IF;
end ||
delimiter;

CALL ldcrm_parenttab_ldsoukebao();
DROP PROCEDURE IF EXISTS `ldcrm_parenttab_ldsoukebao`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOREFEATURESINDUSTRY','更多功能和行业解决方案','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MOREFEATURESINDUSTRY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOREFEATURESINDUSTRY',"More features and industry solutions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MOREFEATURESINDUSTRY' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASECALLINQUIRE','请来电咨询','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASECALLINQUIRE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASECALLINQUIRE',"Please call to inquire",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASECALLINQUIRE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHENSWITCHINGVERSIONSTIP','切换版本时，可能会导致其他正在使用的用户无法保存数据，无法刷新列表（可通过退出，重新进入解决）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WHENSWITCHINGVERSIONSTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHENSWITCHINGVERSIONSTIP',"When switching versions, it may cause other users who are currently in use to be unable to save data and refresh the list (this can be resolved by exiting and re entering)",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WHENSWITCHINGVERSIONSTIP' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SWITCHING','切换中...','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SWITCHING' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SWITCHING',"Switching",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SWITCHING' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SWITCHSUCCESSFUL','切换成功','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SWITCHSUCCESSFUL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SWITCHSUCCESSFUL',"Switch successful",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SWITCHSUCCESSFUL' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENTRYINFORMATION','分录信息','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENTRYINFORMATION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENTRYINFORMATION',"Entry information",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENTRYINFORMATION' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='搜客宝' where labelbol='LINGDANGHUOKE' and languagetype='zh';
update ld_desk set fieldlabel='Sokebao' where labelbol='LINGDANGHUOKE' and languagetype='en';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_crmlog_import_soukebao` (
	`id` int(19) NOT NULL auto_increment PRIMARY KEY,
	`tabid` int(11),
	`crmid` int(19),
	`corpid` int(19),
	`createdtime` datetime DEFAULT CURRENT_TIMESTAMP
	)ENGINE=InnoDB;
delimiter;
update  ld_parenttab set parenttab_label=CONCAT(parenttab_label,'_',parenttabid)
WHERE parenttab_label REGEXP '^[0-9]+$';
delimiter;

INSERT INTO ld_module_setting_byuser (modulename, userid, label, content)
SELECT 'SMS',1,'AccountLoginCodeSMS', '{1}为您的灵当软件验证码，请在24小时内完成输入。如非本人操作，请忽略。详询客服021-63201212'
FROM dual where not EXISTS(SELECT 1 FROM ld_module_setting_byuser WHERE `modulename` = 'SMS');
delimiter;

update ld_parenttab set imagename='left_nav_search_ico.png' where parenttab_label='LDsoukebao';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pictures','个图片','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Pictures' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pictures'," pictures",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Pictures' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOCATIONNOTEMPTY','定位不能为空','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOCATIONNOTEMPTY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOCATIONNOTEMPTY',"Location cannot be empty",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOCATIONNOTEMPTY' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTCCRANGE','请选择抄送范围','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESELECTCCRANGE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTCCRANGE',"Please select the CC range",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESELECTCCRANGE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PUBLISHEDSUCCESSFULLY','发布成功','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PUBLISHEDSUCCESSFULLY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PUBLISHEDSUCCESSFULLY',"Successfully published",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PUBLISHEDSUCCESSFULLY' and labeltype='fixedstr');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_FILE_INFORMATION';
UPDATE ld_field SET block = @blockid,sequence=1 WHERE tabid = @tabid and columnname = 'signout_imagename';
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
UPDATE ld_field SET sequence = 1 WHERE tabid = @tabid and columnname = 'signout';
SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'source_list';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'entityaddress';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signin_id';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signout_time';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signout_address';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signout_distance';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'signout_type';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'timeused';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'smownerid';

SET @sequence = (select sequence from ld_field where tabid = @tabid and `columnname` = 'signout');
UPDATE ld_field SET sequence = sequence+1 WHERE tabid = @tabid and sequence>=@sequence+1;
UPDATE ld_field SET sequence = @sequence+1 WHERE tabid = @tabid and columnname = 'smcreatorid';
delimiter;

update ld_desk set fieldlabel='（多次查询没有结果请联系管理员检查工商查询接口信息）' where labelbol='PlaceCheckTianYanChaInterface' and languagetype='zh';
update ld_desk set fieldlabel='(Multiple queries without results, please contact the admin to check the business query interface information)' where labelbol='PlaceCheckTianYanChaInterface' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SCORE','评分','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SCORE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SCORE',"Score",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SCORE' and labeltype='fixedstr');
delimiter;


UPDATE ld_tabdetailfield SET savedatabase='yes' WHERE columnname ='remark' AND savedatabase='no';
delimiter;

SET @cvid = (select cvid from ld_cvcolumnlist WHERE columnname = "ld_signout:signout_time:signout_time:Signout_fieldlabel:DT" LIMIT 1);
INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
SELECT @cvid,CONCAT('ld_signout:createdtime:createdtime:Signout_DT~O:fieldlabel'),'desc' from dual
where not exists(select 1 from ld_cvcolumnlistsort where cvid=@cvid);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds');
UPDATE ld_field SET quickcreate=3 WHERE tabid=@tabid AND columnname='status_rmd' AND quickcreate=0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILTERCRITERIA','筛选条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FILTERCRITERIA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILTERCRITERIA',"Filter criteria",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FILTERCRITERIA' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WECHATCLIENTCHOOSEFILE','微信客户端会话选择文件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WECHATCLIENTCHOOSEFILE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WECHATCLIENTCHOOSEFILE',"WeChat client session selection file",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WECHATCLIENTCHOOSEFILE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PhotoAlbum','相册','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PhotoAlbum' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PhotoAlbum',"Photo album",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PhotoAlbum' and labeltype='fixedstr');
delimiter;
-- 2024-04-10


SELECT blockid,sequence into @blockid,@sequence FROM ld_settings_field WHERE name='yunzhijia_setting';
set @count = (SELECT COUNT(1) FROM ld_settings_field WHERE `name`='zhiyuan_setting');
UPDATE ld_settings_field set sequence = sequence +1 where blockid = @blockid and sequence > @sequence
and @count <= 0;

SET @MAX=(SELECT MAX(fieldid)+1 FROM ld_settings_field);
INSERT INTO ld_settings_field (fieldid,blockid,name,iconpath,description,linkto,sequence,active)
SELECT @MAX,@blockid,'zhiyuan_setting','picklistdependency.png','zhiyuan_setting','index.php?module=Settings&action=zhiyuan_setting&parenttab=Settings', @sequence+1, 1 
from dual where not EXISTS(SELECT 1 FROM ld_settings_field WHERE `name`='zhiyuan_setting');

UPDATE ld_settings_field_seq set id = (SELECT MAX(fieldid) FROM ld_settings_field);

delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','zhiyuan_setting','致远接口设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='zhiyuan_setting' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','zhiyuan_setting',"Zhiyuan Interface Settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='zhiyuan_setting' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THEINTERFACEPARAMENTERS','接口参数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='THEINTERFACEPARAMENTERS' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THEINTERFACEPARAMENTERS',"Interface",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='THEINTERFACEPARAMENTERS' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WECHATAPPLETSETTINGSTITLE02','CRM外网访问地址','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WECHATAPPLETSETTINGSTITLE02' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WECHATAPPLETSETTINGSTITLE02',"Server address",'fixedstr'from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WECHATAPPLETSETTINGSTITLE02' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZhiyuanAccessAddress','致远访问地址','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZhiyuanAccessAddress' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZhiyuanAccessAddress',"Zhiyuan access address",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZhiyuanAccessAddress' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZhiyuanSystemRegistrationCode','致远系统注册码','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZhiyuanSystemRegistrationCode' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZhiyuanSystemRegistrationCode',"Zhiyuan System Registration Code",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZhiyuanSystemRegistrationCode' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZhiyuanUsername','致远用户名','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZhiyuanUsername' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZhiyuanUsername',"Zhiyuan Username",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZhiyuanUsername' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZhiyuanUserPassword','致远密码','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZhiyuanUserPassword' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZhiyuanUserPassword',"Zhiyuan Password",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZhiyuanUserPassword' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHIYUANSETTINGSREMIND01','1、CRM外网访问地址请参照此格式输入:http://www.51mis.com/crm/','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHIYUANSETTINGSREMIND01' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHIYUANSETTINGSREMIND01',"1. CRM external network access address, please refer to this format for input: http://www.51mis.com/crm/",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHIYUANSETTINGSREMIND01' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHIYUANSETTINGSREMIND02','2、致远访问地址、致远系统注册码、致远用户名和密码都由致远供应商提供','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHIYUANSETTINGSREMIND02' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHIYUANSETTINGSREMIND02',"2. The Zhiyuan access address, Zhiyuan system registration code, Zhiyuan username and password are all provided by the Zhiyuan supplier",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHIYUANSETTINGSREMIND02' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHIYUANSETTINGSREMIND03','3、其中致远用户名建议让致远供应商在后台配置用户绑定时使用\"手机号匹配\"类型','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHIYUANSETTINGSREMIND03' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHIYUANSETTINGSREMIND03',"3. The Zhiyuan user name is suggested to let the Zhiyuan supplier use the 'mobile phone number matching' type when configuring user binding in the background",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHIYUANSETTINGSREMIND03' and
labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHIYUANREMINDCONTENTTEXT','$CRM外网访问地址$不能为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHIYUANREMINDCONTENTTEXT' and
labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHIYUANREMINDCONTENTTEXT',"$CRM external network access address$ can not be empty！",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHIYUANREMINDCONTENTTEXT' and
labeltype='jspop');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh','INDICATORUNIT','指标单位','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'INDICATORUNIT' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','INDICATORUNIT','Indicator unit','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'INDICATORUNIT' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh','CONVERSIONRATE','换算率','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'CONVERSIONRATE' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','CONVERSIONRATE','Conversion rate','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'CONVERSIONRATE' AND labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_salestarget_basic','indicator_unit','varchar',20,'');
delimiter;

CALL AddColumn('ld_salestarget_basic','conversion_rate','decimal',25,'');
ALTER TABLE ld_salestarget_basic MODIFY COLUMN conversion_rate double;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_salestarget_basic`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_salestarget_basic`(
)
BEGIN
    -- 声明用于循环的变量
	DECLARE finished INTEGER DEFAULT 0;
    DECLARE id int(19);
    DECLARE cur CURSOR FOR SELECT targetid FROM ld_salestarget_basic where indicator_unit is null and conversion_rate=0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
OPEN cur;
get_detailrecord: LOOP
        FETCH cur INTO id;
        IF finished = 1 THEN
            LEAVE get_detailrecord;
        END IF;
        -- 检查明细表中对应的funnmae是否存在count
        IF EXISTS(SELECT 1 FROM ld_salestarget_detail WHERE targetid = id AND funname = 'count') THEN
		    -- 存在一条funname为count的，则是计数字段
            update ld_salestarget_basic set indicator_unit='pieces',conversion_rate=1 where targetid= id;
        ELSE
            -- 不存在funname为count的，则全是求和字段，检查统计字段是否全是金融类型
			CALL ldcrm_update_salestarget_detail(id);
        END IF;
END LOOP;
CLOSE cur;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_salestarget_detail`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_salestarget_detail`(in `id` int(19))
BEGIN
    -- 声明用于循环的变量
	DECLARE finished INTEGER DEFAULT 0;
    DECLARE countfieldinfo VARCHAR(255);
    DECLARE fieldtable VARCHAR(50);
    DECLARE fieldcolumnname VARCHAR(30);
	DECLARE cur CURSOR FOR SELECT countfield FROM ld_salestarget_detail WHERE targetid = id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
OPEN cur;

get_fieldtype: LOOP
            FETCH cur INTO countfieldinfo;
            IF finished = 1 THEN
                    LEAVE get_fieldtype;
            END IF;
            SET fieldtable = SUBSTRING_INDEX(countfieldinfo, ':', 1);
            SET fieldcolumnname = SUBSTRING_INDEX(SUBSTRING_INDEX(countfieldinfo, ':', -4), ':', 1);

            IF NOT EXISTS(
                SELECT 1 FROM ld_field WHERE tablename = tablename AND columnname = fieldcolumnname AND ( uitype IN (71, 72) OR (tabid=14 and (columnname='unit_price' OR columnname='costprice')))
            union
                SELECT 1 FROM ld_producttoolfield WHERE tablename = tablename AND columnname = fieldcolumnname AND uitype IN ('28','29','32','50','163','20',730,731,810,811,72)
            union
                SELECT 1 FROM ld_tabdetailfield WHERE tablename = tablename AND columnname = fieldcolumnname AND  fieldtype IN ('amount','rmb_amount','price')
            )
            THEN
                update ld_salestarget_basic set indicator_unit='pieces',conversion_rate=1 where targetid= id;
                LEAVE get_fieldtype;
            ELSE
                update ld_salestarget_basic set indicator_unit='tenthousand',conversion_rate=0.0001 where targetid= id AND indicator_unit is null;
            END IF;
END LOOP;
CLOSE cur;
end ||
delimiter;

CALL ldcrm_update_salestarget_basic();
DROP PROCEDURE IF EXISTS `ldcrm_update_salestarget_basic`;
DROP PROCEDURE IF EXISTS `ldcrm_update_salestarget_detail`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_parenttab_ldsoukebao`;
delimiter ||
CREATE PROCEDURE `ldcrm_parenttab_ldsoukebao`(
)
BEGIN
	IF NOT EXISTS (select 1 from ld_parenttab where parenttab_label='LDsoukebao') THEN

		update ld_parenttab set sequence = sequence+1 where sequence >= 2;
		SET @parentid=(select max(parenttabid)+1 from ld_parenttab);

		insert into ld_parenttab(parenttabid,parenttab_label,sequence,allocatetype,imagename) VALUE (@parentid,'LDsoukebao',2,'all','left_nav_account_ico.png');

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name` = 'ldsoukebao');

		update ld_parenttabrel set parenttabid = @parentid, sequence = 1 where tabid = @tabid;

		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) value ('en','ld_parenttab',@parentid,@parentid,'搜客宝');

		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) value ('zh','ld_parenttab',@parentid,@parentid,'搜客宝');

		update ld_tranlabel set fieldlabel = '查企业' where trantable = 'ld_tab' and tabid = @tabid and languagetype = 'zh';

		update ld_tranlabel set fieldlabel = 'Find a company' where trantable = 'ld_tab' and tabid = @tabid and languagetype = 'en';

		select max(tabid) into @maxtabid from ld_tab;

		insert into ld_tab (tabid,`name`,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab,proportion)
		value (@maxtabid+1,'ldsoukebaomap',0,50,'ldsoukebaomap',0,0,1,'',0,0);

		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) value ('zh','ld_tab',@maxtabid+1,@maxtabid+1,'地图获客');

		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) value ('en','ld_tab',@maxtabid+1,@maxtabid+1,'Map search');

		insert into ld_parenttabrel(parenttabid,tabid,sequence) value (@parentid,@maxtabid+1,2);

	END IF;
end ||
delimiter;

CALL ldcrm_parenttab_ldsoukebao();
DROP PROCEDURE IF EXISTS `ldcrm_parenttab_ldsoukebao`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOREFEATURESINDUSTRY','更多功能和行业解决方案','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MOREFEATURESINDUSTRY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOREFEATURESINDUSTRY',"More features and industry solutions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MOREFEATURESINDUSTRY' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASECALLINQUIRE','请来电咨询','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASECALLINQUIRE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASECALLINQUIRE',"Please call to inquire",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASECALLINQUIRE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHENSWITCHINGVERSIONSTIP','切换版本时，可能会导致其他正在使用的用户无法保存数据，无法刷新列表（可通过退出，重新进入解决）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WHENSWITCHINGVERSIONSTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHENSWITCHINGVERSIONSTIP',"When switching versions, it may cause other users who are currently in use to be unable to save data and refresh the list (this can be resolved by exiting and re entering)",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WHENSWITCHINGVERSIONSTIP' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SWITCHING','切换中...','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SWITCHING' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SWITCHING',"Switching",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SWITCHING' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SWITCHSUCCESSFUL','切换成功','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SWITCHSUCCESSFUL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SWITCHSUCCESSFUL',"Switch successful",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SWITCHSUCCESSFUL' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENTRYINFORMATION','分录信息','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENTRYINFORMATION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENTRYINFORMATION',"Entry information",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENTRYINFORMATION' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='搜客宝' where labelbol='LINGDANGHUOKE' and languagetype='zh';
update ld_desk set fieldlabel='Sokebao' where labelbol='LINGDANGHUOKE' and languagetype='en';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_crmlog_import_soukebao` (
	`id` int(19) NOT NULL auto_increment PRIMARY KEY,
	`tabid` int(11),
	`crmid` int(19),
	`corpid` int(19),
	`createdtime` datetime DEFAULT CURRENT_TIMESTAMP
	)ENGINE=InnoDB;
delimiter;
update  ld_parenttab set parenttab_label=CONCAT(parenttab_label,'_',parenttabid)
WHERE parenttab_label REGEXP '^[0-9]+$';

delimiter;

INSERT INTO ld_module_setting_byuser (modulename, userid, label, content)
SELECT 'SMS',1,'AccountLoginCodeSMS', '{1}为您的灵当软件验证码，请在24小时内完成输入。如非本人操作，请忽略。详询客服021-63201212'
FROM dual where not EXISTS(SELECT 1 FROM ld_module_setting_byuser WHERE `modulename` = 'SMS');
delimiter;

update ld_parenttab set imagename='left_nav_search_ico.png' where parenttab_label='LDsoukebao';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ModComments');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='filename' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='filename' LIMIT 1);
SET @columnname='image';
SET @fieldname='image';
SET @fieldlabel='图片';
SET @zh='图片';
SET @en='Image';
SET @uitype=69;
SET @typeofdata='V~O';
SET @quickcreate=3;
SET @displaytype=1;
SET @bigtype='fileattachment';
SET @datarang='all';
SET @maxrowsshow=5;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @allowhide='yes';
SET @readonly=1;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND fieldlabel=@fieldlabel);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILLINCOMMENTS','请填写评论内容','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FILLINCOMMENTS' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILLINCOMMENTS',"Please fill in the comments",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FILLINCOMMENTS' and labeltype='jspop');
delimiter;
-- 2024-04-12

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name` = 'ldsoukebao');
update ld_tranlabel set fieldlabel = '找企业' where trantable = 'ld_tab' and tabid = @tabid and languagetype = 'zh';
delimiter;

drop PROCEDURE  if EXISTS crm_addtab_intoprofile_20240415;
delimiter ||
create PROCEDURE crm_addtab_intoprofile_20240415
(
	tabname varchar(100),
	operation int(10)
)
BEGIN
	declare var_profileid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT profileid   FROM  ld_profile;
declare continue handler  for not   found  SET done =1;
	set @sql='select tabid into @tabid from ld_tab  where ';
	set @sql=CONCAT(@sql, " name='",tabname,"'");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
open cur1;
Fetch cur1 into var_profileid;
loop1: while  done<>1 DO

        set @sql=" insert into ld_profile2tab(profileid,tabid,permissions) select ";
        set @sql=concat(@sql,var_profileid,",",@tabid,",",0 ," from dual where not exists(select 1 from ld_profile2tab where tabid=",@tabid," and profileid=",var_profileid,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

set @sql=" insert into ld_profileallpermission(tabid,operation,sequence) select ";
        set @sql=concat(@sql,@tabid,",",operation ,",",0, " from dual where not exists(select 1 from ld_profileallpermission where tabid=",@tabid ,' and operation=',operation,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

set @sql=" insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select ";
        set @sql=concat(@sql,var_profileid,',',@tabid,",",operation ,",",0,",",0, " from dual where not exists(select 1 from ld_profile2standardpermissions where profileid=" ,var_profileid," and tabid=",@tabid ,' and operation=',operation,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

Fetch cur1 into var_profileid;
end while loop1;
close cur1;
end ||
delimiter;

call crm_addtab_intoprofile_20240415('ldsoukebaomap',3);
drop PROCEDURE  if EXISTS crm_addtab_intoprofile_20240415;
delimiter;

UPDATE ld_tab SET presence=0,mobilepresence=0 WHERE `name` IN ('ldsoukebao','ldsoukebaomap');

UPDATE ld_relatedlists SET presence=1,mobile_presence=1 WHERE tabid=14 AND related_tabid IN (20,21,22,23,37,6,7,4,2,13) AND (SELECT COUNT(1) FROM ld_products WHERE deleted=0)<=2;
delimiter;

update ld_tab set mobilepresence='weixin' where tabid>=359 and tabid<=364 and mobilepresence is null ;
delimiter;
-- 2024-04-15


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

UPDATE ld_version SET old_version='V8.6.3.0',current_version='V8.6.3.0',remark='V8.6.3.0-20240412',wx_version='V8.6.3.0';
delimiter;