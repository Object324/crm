SET @labelbol = 'VISUALANALYSISICONMSG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'仅“%模块名称%”模块才显示该封面，建议图片尺寸比例宽*高：630 * 500','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only the \'%modulename%\' module displays this cover page,Select a file (recommended image size ratio: 630 * 500)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RECENTLYVISITED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'最近访问','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Recently Visited','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'MYCOLLECTION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'我收藏的','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'My Collection','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ASSIGNEDTOME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'分配给我的','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Assigned To Me','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CLICKEXPAND';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击展开','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click To Expand','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTCOVER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择封面','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Select Cover','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'VISUALANALYSISSEARCH';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索数据看板名称、备注、报表组件名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search Data Kanban Name, Description, Report Component Name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SEARCHKEYWORDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索关键词','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search Keywords','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'REPORTCOMPONENTNAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'报表组件名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Report Component Name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COLLET';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'收藏','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Collect','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

select tabsequence into @tabsequence from ld_tab where `name` = 'ReportAnalysis';
update ld_tab set tabsequence := tabsequence + 1 where tabsequence > @tabsequence;

select max(tabid)into @maxtabid from ld_tab ;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'VisualAnalysis',0,@tabsequence+1,'VisualAnalysis',1 from dual
where not EXISTS(select 1 from ld_tab where name='VisualAnalysis');

select tabid into @tabid from ld_tab  where name='VisualAnalysis';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'可视化分析' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Visualization Analysis' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');

select max(sequence) into @sequence from ld_parenttabrel where parenttabid=5;
insert into ld_parenttabrel (parenttabid,tabid,sequence,tab_tablename) select 5,@tabid,@sequence+1,'ld_tab' from dual
where not exists(select 1 from ld_parenttabrel where tabid=@tabid and tab_tablename='ld_tab');

SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN('index','DetailView','Create','EditView','Delete','Allocate');

call AddColumn('ld_homeboard','icon_path','text','',null);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_visualanalysis`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_visualanalysis`(
)
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	SET @tabid=(select tabid from ld_tab  where name='VisualAnalysis');

	set @operation = (SELECT actionid from ld_actionmapping where actionname = 'DetailView');

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

CALL ldcrm_add_profile_for_visualanalysis();
delimiter;

update ld_homeboard set boardtype = 'Home' where ISNULL(boardtype) or boardtype = '';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_loginpolicy` (
  `ruleid` int(10) NOT NULL AUTO_INCREMENT,
	`rulename` varchar(200) NOT NULL,
  `priority` int(10) DEFAULT NULL ,
  `ruletype` varchar(200) DEFAULT NULL,
  `applicablescope` varchar(100) DEFAULT NULL,
  `controlmode` varchar(200) DEFAULT NULL,
  `enablestatus` varchar(20) DEFAULT NULL,
  `description` text(0) DEFAULT NULL,
	`typecontent` text(0) DEFAULT NULL,
	`statusvalue` text(0) DEFAULT NULL,
  PRIMARY KEY (`ruleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_loginpolicy_user` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
	`ruleid` int(10) DEFAULT NULL,
	`userid` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_loginpolicy(ruleid,rulename,priority,ruletype,applicablescope,controlmode,enablestatus,description)
select '1','默认策略','1','Unlimited','all','enable','yes','默认策略' from dual
where not exists
(select 1 from ld_loginpolicy where ruleid='1');
delimiter;

insert into ld_loginpolicy_user(id,ruleid,userid)
select '1','1','-1' from dual
where not exists
(select 1 from ld_loginpolicy_user where id='1' and ruleid='1' and userid='-1');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOGINPOLICY','登陆策略','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LOGINPOLICY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOGINPOLICY','Login Policy','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LOGINPOLICY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOGINPOLICY','登陆策略','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='LOGINPOLICY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOGINPOLICY','Login Policy','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='LOGINPOLICY' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RULETYPE','规则类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RULETYPE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RULETYPE','Rule type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RULETYPE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTROLMODE','控制方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CONTROLMODE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTROLMODE','Control mode','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CONTROLMODE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RULESETTINGS','规则设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RULESETTINGS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RULESETTINGS','Rule Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RULESETTINGS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RULEDESCRIPTION','规则描述','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RULEDESCRIPTION' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RULEDESCRIPTION','Rule description','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RULEDESCRIPTION' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNLIMITED2','无限制','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UNLIMITED2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNLIMITED2','Unlimited ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UNLIMITED2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WEB','WEB端','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WEB' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WEB','WEB','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WEB' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IPADDRESS','IP地址','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IPADDRESS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IPADDRESS','IP address','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IPADDRESS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOCATEDCITY','所在城市','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LOCATEDCITY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOCATEDCITY','Located city','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LOCATEDCITY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOWEDLOGIN','允许登录','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ALLOWEDLOGIN' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOWEDLOGIN','Allowed to Login','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ALLOWEDLOGIN' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTALLOWEDLOGIN','不允许登录','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOTLOCATEDCITY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTLOCATEDCITY','Not allowed to Login','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOTLOCATEDCITY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENTERTOADDIPADDRESS','请输入IP地址并按回车添加','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENTERTOADDIPADDRESS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENTERTOADDIPADDRESS','Please enter the IP address and press ’Enter‘ to add','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENTERTOADDIPADDRESS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDYOURIP','添加您的当前IP','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDYOURIP' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDYOURIP','Add your current IP','fixedstr'  from dual
where not exists(select 1 from ld_desk where labelbol='ADDYOURIP' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALREADYADDEDTHEIP','您已添加过该IP地址','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ALREADYADDEDTHEIP' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALREADYADDEDTHEIP','You have already added the IP address','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ALREADYADDEDTHEIP' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASECREATEONECITY','请至少创建一条所在城市数据！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASECREATEONECITY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASECREATEONECITY','Please create at least one city data!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASECREATEONECITY' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CITYSELECTIONCANOTEMPTY','所在城市选择不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CITYSELECTIONCANOTEMPTY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CITYSELECTIONCANOTEMPTY','The city selection can not be empty','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CITYSELECTIONCANOTEMPTY' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASECREATEONEIP','请至少创建一条IP地址！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASECREATEONEIP' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASECREATEONEIP','Please create at least one IP address!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASECREATEONEIP' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONFIRMWANTDELETERULE','确认要删除该条规则吗？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CONFIRMWANTDELETERULE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONFIRMWANTDELETERULE','Are you certain that you want to delete this rule?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CONFIRMWANTDELETERULE' and Labeltype='jspop' and languagetype='en');
delimiter;

SET @labelbol = 'UNCOLLET';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'取消收藏','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Uncollect','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COLLET';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'收藏','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Collect','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'UNCOLLET';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'取消收藏','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Uncollect','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOSHARE','自动共享','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AUTOSHARE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOSHARE','Auto Share','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AUTOSHARE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTSHARER','请选择共享人','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASESELECTSHARER' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTSHARER','Please select a sharer','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASESELECTSHARER' and Labeltype='jspop' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workflow_autoshare` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`workflow_action_id` int(11) DEFAULT NULL,
	`share_setmode` varchar(50) DEFAULT NULL,
	`share_setvalue` varchar(200) DEFAULT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Sharingmethod','共享方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Sharingmethod' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Sharingmethod','Sharing method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Sharingmethod' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SPECIFYFIELDS','指定字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SPECIFYFIELDS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SPECIFYFIELDS','Specify fields','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SPECIFYFIELDS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_calendarcolorsetting` (
    `colorsetting_id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'table index',
    `date_start` DATE NOT NULL COMMENT 'change color start day',
    `date_end` DATE NOT NULL COMMENT 'change color end day',
    `color` varchar(100) NOT NULL COMMENT 'change color describ or HEX',
    PRIMARY KEY (`colorsetting_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

DROP PROCEDURE IF EXISTS `reset_fieldinfo_slw`;
delimiter ||
CREATE  PROCEDURE `reset_fieldinfo_slw`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE account='shenglawei') THEN
		ALTER TABLE ld_customform01scf MODIFY cf_7441 DATE;
	END IF;

end ||
delimiter;

CALL reset_fieldinfo_slw();
DROP PROCEDURE IF EXISTS `reset_fieldinfo_slw`;
delimiter;

SET @module='Products';
SET @related_module='ContactRecords';
SET @actions='add';
SET @type='datacategory_sql';
SET @related_coltable='contactrecords.product_id';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module);
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=@related_module);
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @presence=1;

INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,CONCAT('get_',LOWER(@related_module)),@seq+1,@related_module,@presence,@actions,@type,@related_coltable FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND label=@related_module);

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;
-- 2023-07-14

drop  PROCEDURE  if exists insertinto_visualanalysisboard;
delimiter ||
create PROCEDURE insertinto_visualanalysisboard()
begin
if not  exists(select * from ld_homeboard where boardtype='VisualAnalysis') then
CREATE TABLE ldcrm_tpm_visualanalysis LIKE ld_homeboard;

delete from ldcrm_tpm_visualanalysis;

INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('12', '线索转化分析', '线索分析', '1', '2023-07-14 11:19:54', '1', '2023-07-14 11:19:54', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '3', '120', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_12.png');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('13', '客户360°报告', '客户分析', '1', '2023-07-14 11:23:19', '1', '2023-07-14 11:23:19', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '4', '120', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_13.png');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('15', '商机跟进、转化分析', '商机分析', '1', '2023-07-14 11:23:35', '1', '2023-07-14 11:23:35', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '3', '120', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_15.png');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('16', '销售行为、销售业绩分析', '销售分析', '1', '2023-07-14 11:23:53', '1', '2023-07-14 11:23:53', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '4', '120', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_.png');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('17', '服务业绩、售后管理分析', '服务分析', '1', '2023-07-14 11:24:11', '1', '2023-07-14 11:24:11', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '4', '120', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_17.png');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('18', '采购管理分析', '采购分析', '1', '2023-07-14 11:24:25', '1', '2023-07-14 11:24:25', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '3', '120', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_18.png');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('19', '产品采购、销量分析', '产品分析', '1', '2023-07-14 11:27:16', '1', '2023-07-14 11:27:16', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '0', '0', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_19.png');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('21', '销售业绩统计排名', '统计排名', '1', '2023-07-14 11:24:58', '1', '2023-07-14 11:24:58', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '0', '0', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_21.png');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('22', '收款、合同同比环比', '同比环比分组统计（YoY and MoM）', '1', '2023-07-14 11:25:53', '1', '2023-07-14 11:25:53', '0', 'tl1r1', 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '0', '0', 'yes', 'VisualAnalysis', 'storage/VisualAnalysisIcon/active_icon_22.png');

select ifnull(max(boardid),0) into @maxboardid  from ld_homeboard;

insert into ld_homeboard (boardid,description,boardname,smcreatorid,createdtime,modifiedby,modifiedtime,deleted,boardlayout,`scope`,timesearchdefault,approve_value,saleskit_colcount,saleskit_height,saleskit_isshowpredata,boardtype,icon_path)
select @maxboardid+boardid,description,boardname,smcreatorid,createdtime,modifiedby,modifiedtime,deleted,boardlayout,`scope`,timesearchdefault,approve_value,saleskit_colcount,saleskit_height,saleskit_isshowpredata,boardtype,icon_path
from  ldcrm_tpm_visualanalysis ;

drop table ldcrm_tpm_visualanalysis;


CREATE TABLE ldcrm_tpm_visualanalysis LIKE ld_homeboard_plate;

delete from ldcrm_tpm_visualanalysis;

INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('43', '12', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('44', '12', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('45', '12', 'right', '1-2', '2');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('46', '13', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('47', '13', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('48', '13', 'right', '1-2', '2');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('52', '15', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('53', '15', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('54', '15', 'right', '1-2', '2');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('55', '16', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('56', '16', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('57', '16', 'right', '1-2', '2');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('58', '17', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('59', '17', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('60', '17', 'right', '1-2', '2');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('61', '18', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('62', '18', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('63', '18', 'right', '1-2', '2');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('64', '19', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('65', '19', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('66', '19', 'right', '1-2', '2');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('70', '21', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('71', '21', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('72', '21', 'right', '1-2', '2');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('73', '22', 'whole', '1-1', '0');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('74', '22', 'left', '1-2', '1');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('75', '22', 'right', '1-2', '2');

select ifnull(max(plateid),0) into @maxplateid  from ld_homeboard_plate;

insert into ld_homeboard_plate (plateid,	boardid,	platetype,	platewidth,	`sequence`)
select @maxplateid + plateid,	@maxboardid + boardid,	platetype,	platewidth,	`sequence`
from  ldcrm_tpm_visualanalysis ;

drop table ldcrm_tpm_visualanalysis;

CREATE TABLE ldcrm_tpm_visualanalysis LIKE ld_homeboard_plate_stuff;

delete from ldcrm_tpm_visualanalysis;

INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('67', '35', '12', '43', 'defaultstuff', '0', '', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('71', '35', '13', '46', 'defaultstuff', '0', '', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('72', '20', '13', '47', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('73', '144', '13', '47', 'customreport', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('74', '146', '13', '47', 'customreport', '2', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('75', '148', '13', '47', 'customreport', '3', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('76', '160', '13', '47', 'customreport', '4', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('77', '150', '13', '47', 'customreport', '5', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('78', '152', '13', '47', 'customreport', '6', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('79', '13', '13', '48', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('80', '145', '13', '48', 'customreport', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('81', '147', '13', '48', 'customreport', '2', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('82', '159', '13', '48', 'customreport', '3', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('83', '149', '13', '48', 'customreport', '4', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('84', '151', '13', '48', 'customreport', '5', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('85', '161', '13', '48', 'customreport', '6', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('86', '35', '15', '52', 'defaultstuff', '0', '', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('87', '19', '15', '53', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('88', '44', '15', '53', 'defaultstuff', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('89', '14', '15', '54', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('90', '45', '15', '54', 'defaultstuff', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('91', '168', '15', '52', 'customreport', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('92', '35', '16', '55', 'defaultstuff', '0', '', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('93', '16', '16', '56', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('94', '40', '16', '56', 'defaultstuff', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('95', '9', '16', '56', 'defaultstuff', '2', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('96', '34', '16', '57', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('97', '41', '16', '57', 'defaultstuff', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('98', '1', '16', '57', 'defaultstuff', '2', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('100', '141', '16', '56', 'customreport', '3', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('101', '165', '16', '57', 'customreport', '3', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('102', '139', '16', '56', 'customreport', '4', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('103', '35', '17', '58', 'defaultstuff', '0', '', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('104', '156', '17', '59', 'customreport', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('105', '158', '17', '60', 'customreport', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('106', '35', '18', '61', 'defaultstuff', '0', '', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('108', '3', '19', '64', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('110', '33', '21', '71', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('111', '154', '21', '71', 'customreport', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('112', '163', '21', '71', 'customreport', '2', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('113', '57', '21', '72', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('114', '155', '21', '72', 'customreport', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('115', '164', '21', '72', 'customreport', '2', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('116', '4', '22', '74', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('117', '41', '22', '74', 'defaultstuff', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('118', '5', '22', '75', 'defaultstuff', '0', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('119', '42', '22', '75', 'defaultstuff', '1', '370px', '', '');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('120', '167', '12', '43', 'customreport', '1', '370px', '', '');

select ifnull(max(boardstuffid),0) into @maxboardstuffid from ld_homeboard_plate_stuff;

insert into ld_homeboard_plate_stuff (boardstuffid,stuffid,boardid,plateid,stufftype,`sequence`,height,stufftitle_zh,stufftitle_en)
select @maxboardstuffid + boardstuffid,stuffid,@maxboardid + boardid,@maxplateid + plateid,stufftype,`sequence`,height,stufftitle_zh,stufftitle_en
from  ldcrm_tpm_visualanalysis ;

drop table ldcrm_tpm_visualanalysis;


CREATE TABLE ldcrm_tpm_visualanalysis LIKE ld_homeboard_plate_filter;

delete from ldcrm_tpm_visualanalysis;

INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('264', '91', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('265', '91', 'timecomponent', 'yes', 'ld_account:lastservicedate:lastservicedate:Accounts_fieldlabel:D', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('266', '91', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('267', '87', 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'VisualAnalysis', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('268', '87', 'timecomponent', 'yes', '', 'Potentials', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('269', '87', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('270', '88', 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'VisualAnalysis', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('271', '88', 'timecomponent', 'yes', '', 'Potentials', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('272', '88', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('273', '89', 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'VisualAnalysis', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('274', '89', 'timecomponent', 'yes', '', 'Potentials', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('275', '89', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('276', '90', 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'VisualAnalysis', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('277', '90', 'timecomponent', 'yes', '', 'Potentials', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('278', '90', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('279', '93', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('280', '93', 'timecomponent', 'yes', '', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('281', '93', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('282', '93', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('283', '94', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('284', '94', 'timecomponent', 'yes', '', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('285', '94', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('286', '94', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('287', '94', 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'VisualAnalysis', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('288', '94', 'timecomponent', 'yes', '', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('289', '94', 'approvestatuscomponent', 'yes', 'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('290', '94', 'highsearch', 'yes', null, 'ServiceContracts', 'ServiceContracts', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('291', '94', 'usercomponent', 'yes', 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V', 'VisualAnalysis', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('292', '94', 'timecomponent', 'yes', '', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('293', '94', 'approvestatuscomponent', 'yes', 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('294', '94', 'highsearch', 'yes', null, 'CashBill', 'CashBill', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('295', '94', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('296', '94', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('297', '94', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('298', '94', 'usercomponent', 'yes', 'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V', 'VisualAnalysis', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('299', '94', 'timecomponent', 'yes', '', 'Invoice', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('300', '94', 'approvestatuscomponent', 'yes', 'ld_invoice:approvestatus:approvestatus:Invoice_fieldlabel:V', 'Invoice', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('301', '94', 'highsearch', 'yes', null, 'Invoice', 'Invoice', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('302', '94', 'usercomponent', 'yes', 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V', 'VisualAnalysis', 'OutboundOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('303', '94', 'timecomponent', 'yes', '', 'OutboundOrder', 'OutboundOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('304', '94', 'approvestatuscomponent', 'yes', 'ld_outboundorder:approvestatus:approvestatus:OutboundOrder_fieldlabel:V', 'OutboundOrder', 'OutboundOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('305', '94', 'highsearch', 'yes', null, 'OutboundOrder', 'OutboundOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('306', '95', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('307', '95', 'timecomponent', 'yes', '', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('308', '95', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('309', '95', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('310', '95', 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'VisualAnalysis', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('311', '95', 'timecomponent', 'yes', '', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('312', '95', 'approvestatuscomponent', 'yes', 'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('313', '95', 'highsearch', 'yes', null, 'ServiceContracts', 'ServiceContracts', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('314', '100', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('315', '100', 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('316', '100', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('317', '100', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('318', '96', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('319', '96', 'timecomponent', 'yes', '', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('320', '96', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('321', '96', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('322', '96', 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'VisualAnalysis', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('323', '96', 'timecomponent', 'yes', '', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('324', '96', 'approvestatuscomponent', 'yes', 'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('325', '96', 'highsearch', 'yes', null, 'ServiceContracts', 'ServiceContracts', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('326', '96', 'usercomponent', 'yes', 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V', 'VisualAnalysis', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('327', '96', 'timecomponent', 'yes', '', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('328', '96', 'approvestatuscomponent', 'yes', 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('329', '96', 'highsearch', 'yes', null, 'CashBill', 'CashBill', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('330', '96', 'usercomponent', 'yes', 'ld_cashback:smownerid:assigned_user_id:CashBack_fieldlabel:V', 'VisualAnalysis', 'CashBack', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('331', '96', 'timecomponent', 'yes', '', 'CashBack', 'CashBack', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('332', '96', 'approvestatuscomponent', 'yes', 'ld_cashback:approvestatus:approvestatus:CashBack_fieldlabel:V', 'CashBack', 'CashBack', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('333', '96', 'highsearch', 'yes', null, 'CashBack', 'CashBack', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('334', '97', 'usercomponent', 'yes', 'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V', 'VisualAnalysis', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('335', '97', 'timecomponent', 'yes', '', 'Invoice', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('336', '97', 'approvestatuscomponent', 'yes', 'ld_invoice:approvestatus:approvestatus:Invoice_fieldlabel:V', 'Invoice', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('337', '97', 'highsearch', 'yes', null, 'Invoice', 'Invoice', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('338', '98', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('339', '98', 'timecomponent', 'yes', '', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('340', '98', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('341', '98', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('342', '98', 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'VisualAnalysis', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('343', '98', 'timecomponent', 'yes', '', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('344', '98', 'approvestatuscomponent', 'yes', 'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('345', '98', 'highsearch', 'yes', null, 'ServiceContracts', 'ServiceContracts', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('346', '101', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('347', '101', 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('348', '101', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('349', '101', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('350', '94', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('351', '102', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('352', '102', 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('353', '102', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('354', '102', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('355', '101', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('356', '101', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('357', '101', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('358', '120', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('359', '120', 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('360', '120', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('361', '120', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('362', '73', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('363', '73', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('364', '73', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('365', '74', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('366', '74', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('367', '74', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('368', '75', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('369', '75', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('370', '75', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('371', '76', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('372', '76', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('373', '76', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('374', '77', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('375', '77', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('376', '77', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('377', '78', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('378', '78', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('379', '78', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('380', '79', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('381', '79', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('382', '79', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('383', '80', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('384', '80', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('385', '80', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('386', '81', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('387', '81', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('388', '81', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('389', '82', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('390', '82', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('391', '82', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('392', '83', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('393', '83', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('394', '83', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('395', '84', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('396', '84', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('397', '84', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('398', '85', 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'VisualAnalysis', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('399', '85', 'timecomponent', 'yes', '', 'Accounts', 'Accounts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('400', '85', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('401', '73', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('402', '74', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('403', '75', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('404', '76', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('405', '77', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('406', '78', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('407', '79', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('408', '80', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('409', '81', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('410', '82', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('411', '83', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('412', '84', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('413', '85', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('414', '91', 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'VisualAnalysis', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('415', '91', 'timecomponent', 'yes', '', 'Potentials', 'Potentials', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('416', '91', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('417', '87', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('418', '88', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('419', '89', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('420', '90', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('421', '94', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('422', '101', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('423', '104', 'usercomponent', 'yes', 'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V', 'VisualAnalysis', 'HelpDesk', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('424', '104', 'timecomponent', 'yes', '', 'HelpDesk', 'HelpDesk', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('425', '104', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('426', '105', 'usercomponent', 'yes', 'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V', 'VisualAnalysis', 'HelpDesk', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('427', '105', 'timecomponent', 'yes', '', 'HelpDesk', 'HelpDesk', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('428', '105', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('429', '108', 'usercomponent', 'yes', 'ld_products:smownerid:prosmownerid:Products_fieldlabel:V', 'VisualAnalysis', 'Products', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('430', '108', 'timecomponent', 'yes', '', 'Products', 'Products', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('431', '108', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('432', '110', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('433', '110', 'timecomponent', 'yes', '', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('434', '110', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('435', '110', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('436', '110', 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'VisualAnalysis', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('437', '110', 'timecomponent', 'yes', '', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('438', '110', 'approvestatuscomponent', 'yes', 'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('439', '110', 'highsearch', 'yes', null, 'ServiceContracts', 'ServiceContracts', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('440', '110', 'usercomponent', 'yes', 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V', 'VisualAnalysis', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('441', '110', 'timecomponent', 'yes', '', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('442', '110', 'approvestatuscomponent', 'yes', 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('443', '110', 'highsearch', 'yes', null, 'CashBill', 'CashBill', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('444', '111', 'usercomponent', 'yes', 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_fieldlabel:V', 'VisualAnalysis', 'ContactRecords', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('445', '111', 'timecomponent', 'yes', '', 'ContactRecords', 'ContactRecords', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('446', '111', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('447', '112', 'usercomponent', 'yes', 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V', 'VisualAnalysis', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('448', '112', 'timecomponent', 'yes', '', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('449', '112', 'approvestatuscomponent', 'yes', 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('450', '112', 'highsearch', 'yes', null, 'CashBill', 'CashBill', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('451', '113', 'usercomponent', 'yes', 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_fieldlabel:V', 'VisualAnalysis', 'ContactRecords', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('452', '113', 'timecomponent', 'yes', '', 'ContactRecords', 'ContactRecords', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('453', '113', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('454', '113', 'usercomponent', 'yes', 'ld_singin:smownerid:assigned_user_id:Singin_fieldlabel:V', 'VisualAnalysis', 'Singin', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('455', '113', 'timecomponent', 'yes', '', 'Singin', 'Singin', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('456', '113', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('457', '114', 'usercomponent', 'yes', 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_fieldlabel:V', 'VisualAnalysis', 'ContactRecords', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('458', '114', 'timecomponent', 'yes', '', 'ContactRecords', 'ContactRecords', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('459', '114', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('460', '115', 'usercomponent', 'yes', 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V', 'VisualAnalysis', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('461', '115', 'timecomponent', 'yes', '', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('462', '115', 'approvestatuscomponent', 'yes', 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('463', '115', 'highsearch', 'yes', null, 'CashBill', 'CashBill', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('464', '116', 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'VisualAnalysis', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('465', '116', 'timecomponent', 'yes', '', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('466', '116', 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('467', '116', 'highsearch', 'yes', null, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('468', '116', 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'VisualAnalysis', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('469', '116', 'timecomponent', 'yes', '', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('470', '116', 'approvestatuscomponent', 'yes', 'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V', 'ServiceContracts', 'ServiceContracts', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('471', '116', 'highsearch', 'yes', null, 'ServiceContracts', 'ServiceContracts', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('472', '117', 'usercomponent', 'yes', 'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V', 'VisualAnalysis', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('473', '117', 'timecomponent', 'yes', '', 'Invoice', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('474', '117', 'approvestatuscomponent', 'yes', 'ld_invoice:approvestatus:approvestatus:Invoice_fieldlabel:V', 'Invoice', 'Invoice', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('475', '117', 'highsearch', 'yes', null, 'Invoice', 'Invoice', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('476', '118', 'usercomponent', 'yes', 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V', 'VisualAnalysis', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('477', '118', 'timecomponent', 'yes', '', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('478', '118', 'approvestatuscomponent', 'yes', 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', 'CashBill', 'CashBill', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('479', '118', 'highsearch', 'yes', null, 'CashBill', 'CashBill', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('480', '119', 'usercomponent', 'yes', 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V', 'VisualAnalysis', 'OutboundOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('481', '119', 'timecomponent', 'yes', '', 'OutboundOrder', 'OutboundOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('482', '119', 'approvestatuscomponent', 'yes', 'ld_outboundorder:approvestatus:approvestatus:OutboundOrder_fieldlabel:V', 'OutboundOrder', 'OutboundOrder', null, null);
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('483', '119', 'highsearch', 'yes', null, 'OutboundOrder', 'OutboundOrder', '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('484', '108', 'highsearch', 'yes', null, null, null, '[]', '[]');
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('485', '108', 'highsearch', 'yes', null, null, null, '[]', '[]');

select ifnull(max(filterid),0) into @maxfilterid from ld_homeboard_plate_filter;

insert into ld_homeboard_plate_filter (filterid,boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule,advance_demand,advance_demand_groups)
select @maxfilterid + filterid,@maxboardstuffid + boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule,advance_demand,advance_demand_groups
from  ldcrm_tpm_visualanalysis ;

drop table ldcrm_tpm_visualanalysis;

update ld_customreport set show_athome = 'yes' where report_id in (SELECT stuffid from ld_homeboard_plate_stuff where stufftype = 'customreport');

CREATE TABLE  ldcrm_tpm_visualanalysis LIKE ld_homestuffsaleskit2board;

delete from ldcrm_tpm_visualanalysis;

select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewLeadsCount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('1', '12', @saleskitid, '1');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'LeadUgradeToCustomerCount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('2', '12', @saleskitid, '2');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'LeadUgradeToPotentials' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('3', '12', @saleskitid, '3');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'LeadUgradeToPotentials' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('4', '12', @saleskitid, '3');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewAccounts';
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('5', '13', @saleskitid, '1');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewSalesOrderAmount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('43', '16', @saleskitid, '1');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'SignContractAmount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('44', '16', @saleskitid, '4');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewInvoiceAmount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('45', '16', @saleskitid, '6');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewCashBillAmount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('46', '16', @saleskitid, '7');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewSalesOrderReceipts' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('47', '16', @saleskitid, '3');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'SalesorderBalanceReceivable' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('48', '16', @saleskitid, '2');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'SignContractBalanceReceivable' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('49', '16', @saleskitid, '5');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewPotentialsCount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('74', '15', @saleskitid, '1');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewPotentialsAmount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('75', '15', @saleskitid, '2');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'AdvancePotentialsAmount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('76', '15', @saleskitid, '3');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewServiceContractsAmount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('77', '17', @saleskitid, '1');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewServiceContractsReceipts' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('78', '17', @saleskitid, '2');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'ServiceContractBalanceReceivable' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('79', '17', @saleskitid, '3');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewServiceChargeNums' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('80', '17', @saleskitid, '4');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewPurchaseOrderCount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('81', '18', @saleskitid, '1');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'NewPurchaseOrderAmount' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('82', '18', @saleskitid, '2');
select id into @saleskitid from ld_homestuffdetail where stufflabel = 'PurchaseOrderPayBalance' ORDER BY id limit 1;
INSERT INTO `ldcrm_tpm_visualanalysis` VALUES ('83', '18', @saleskitid, '3');

select ifnull(max(id),0) into @maxid from ld_homestuffsaleskit2board;

insert into ld_homestuffsaleskit2board (id,boardid,homestuffdetailid,`sequence`)
select @maxid + id,@maxboardid + boardid,homestuffdetailid,`sequence`
from  ldcrm_tpm_visualanalysis ;

drop table ldcrm_tpm_visualanalysis;
end if ;
end ||
delimiter;

drop table if  exists  ldcrm_tpm_visualanalysis;
call insertinto_visualanalysisboard();
delimiter;
-- 2023-07-15

update ld_desk set fieldlabel = '拖拽排序' WHERE labelbol = 'DRAGTOSORT' and languagetype = 'zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel = 'Drag Sort' WHERE labelbol = 'DRAGTOSORT' and languagetype = 'en' and Labeltype='fixedstr';
update ld_desk set fieldlabel = '拖拽排序' WHERE labelbol = 'DRAGTOSORT' and languagetype = 'zh' and Labeltype='jspop';
update ld_desk set fieldlabel = 'Drag Sort' WHERE labelbol = 'DRAGTOSORT' and languagetype = 'en' and Labeltype='jspop';
delimiter;

SET @labelbol = 'CARDVIEW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'卡片视图','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Card View','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LISTVIEW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'列表视图','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'List View','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

update ld_appsystem set module = name WHERE module IS NULL;
delimiter;

UPDATE ld_desk SET fieldlabel='显示按钮个数' where labelbol='OPERATIONBUTTONNUM' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='Number of display buttons' where labelbol='OPERATIONBUTTONNUM' and languagetype='en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','importtemplate','导入模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='importtemplate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','importtemplate',' import template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='importtemplate' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2023-07-17

UPDATE ld_module_setting_byuser set content = 20 where label = 'MaxEntriesPerPage' and content = 'undefined';
UPDATE ld_module_setting_byuser set content = 'comfortable' where label = 'TableLineHightSet' and content = 'undefined';
delimiter;

UPDATE ld_desk SET fieldlabel='最多显示按钮个数' where labelbol='OPERATIONBUTTONNUM' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='Max Number of display buttons' where labelbol='OPERATIONBUTTONNUM' and languagetype='en' and Labeltype='fixedstr';
delimiter;

SET @labelbol = 'ICONERROR';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'图标上传失败：','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Icon upload failed: ','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','choose','已选','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='choose' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','numbill','条单据','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='numbill' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','have','共有','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='have' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','billdetails','条分录明细','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='billdetails' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

DELETE from ld_btnset WHERE tabid = 14 and btnkey = 'dividend_rules' and  not EXISTS (select 1 from ld_version where trade='finance');
delimiter;

DELETE from ld_btnset WHERE tabid = 6 and btnkey = 'transfer';
delimiter;

UPDATE ld_field SET typeofdata = 'V~M' WHERE tabid = 100 and columnname = 'content' and `uitype` = 230;
delimiter;

DELETE from ld_settings_field where linkto='index.php?module=Settings&action=WorkRemindSet&parenttab=Settings' and `name` = 'LBL_REMIND_SET';
delimiter;


update ld_organizationdetails set menuback_color='#3388FF',menuhover_color='#98C3FF' where menustyle='dark' and menuback_color='#2e68db' and menuhover_color='#2a83e8';
delimiter;
update ld_organizationdetails set logoname='',small_logoname='' where logoname='logo_big_white.png' and small_logoname='logo_mini_1.png';
delimiter;
update ld_parenttab set imagename='left_nav_base_ico.png' where parenttab_label='Tools';
delimiter;

CREATE TABLE if not EXISTS `ld_approvestep_mandatoryfield` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
	`stepid` int(19) DEFAULT NULL,
	`approveresult` varchar(30) DEFAULT NULL,
  `allfieldname` text,
	`sequence` int(4) DEFAULT NULL,
  `createdtime` datetime DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

INSERT into ld_approvestep_mandatoryfield(stepid,approveresult,allfieldname,sequence)
SELECT tmp_id,'pass',tmp_column,1 from (
	SELECT GROUP_CONCAT(CONCAT(ld_field.tablename,':',ld_field.columnname,':',
		ld_field.fieldname,':',ld_tab.`name`,'_fieldlabel:',SUBSTR(IFNULL(ld_field.typeofdata,'V'),1,1))) as tmp_column,ld_approvestep.id as tmp_id
	from ld_approvestep 
	INNER JOIN ld_approve on ld_approve.id = ld_approvestep.approveid
	INNER JOIN ld_field on ld_field.tabid = ld_approve.tabid
	INNER JOIN ld_tab on ld_tab.tabid = ld_field.tabid
	where LOCATE(ld_field.fieldname,ld_approvestep.module_field) > 0
	GROUP BY ld_approvestep.id
) as tmp_data
where NOT EXISTS(SELECT 1 from ld_approvestep_mandatoryfield where stepid = tmp_data.tmp_id);
delimiter;

SET @labelbol = 'APPROVERESULTPASS';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'通过（审批通过）',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Pass (Approved)',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'APPROVERESULTBACK';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不通过（审批驳回）',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Not pass (Dismissed)',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'APPROVERESULTREJECT';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不通过（审批拒绝）',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Not pass (Rejected)',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;
-- 2023-07-21

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

UPDATE ld_version SET old_version='V8.6.0.1',current_version='V8.6.0.1',remark='V8.6.0.1-20230721',wx_version='V8.6.0.1';
delimiter;