UPDATE ld_mailmanager_mailrecord SET seen=1 WHERE mailtype='smtp';

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','CUSTOMIZESEARCH','高级查找','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CUSTOMIZESEARCH' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','CUSTOMIZESEARCH','Customize Search','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CUSTOMIZESEARCH' and languagetype='en' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='服务小程序登录首页设置'
where labelbol='CUSTOMERSELFSERVICECONFIG01' and languagetype='zh';
update ld_desk set fieldlabel='服务小程序模块设置'
where labelbol='CUSTOMERSELFSERVICECONFIG02' and languagetype='zh';
update ld_desk set fieldlabel='服务小程序详情界面定制'
where labelbol='CUSTOMERSELFSERVICECONFIG03' and languagetype='zh';
update ld_desk set fieldlabel='服务小程序模块列表定制'
where labelbol='CUSTOMERSELFSERVICECONFIG04' and languagetype='zh';
set @modulename ='Contacts';
insert into ld_weixinmp_set (modulename, viewall) select @modulename,'no' from dual
where not exists(select 1 from ld_weixinmp_set where modulename=@modulename);
insert into ld_weixinmp_fields (modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, sequence)
    select @modulename,'lastname','main','联系人姓名','all','m',1 from dual
    where not exists(select 1 from ld_weixinmp_fields where modulename=@modulename and fieldname='lastname');
insert into ld_weixinmp_fields (modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, sequence)
  select @modulename,'mobile','main','联系人手机','all','m',2 from dual
  where not exists(select 1 from ld_weixinmp_fields where modulename=@modulename and fieldname='mobile');
insert into ld_weixinmp_fields (modulename, fieldname, tabletype, fieldlabel, displaytype, typeofdata, sequence)
  select @modulename,'assigned_user_id','main','销售负责人','createno','o',3 from dual
  where not exists(select 1 from ld_weixinmp_fields where modulename=@modulename and fieldname='assigned_user_id');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTORECYCLERULEDATACATEGORY','自动回收规则数据分类设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AUTORECYCLERULEDATACATEGORY' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTORECYCLERULEDATACATEGORY','Data Classification Settings for Automatic Recycling Rules','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AUTORECYCLERULEDATACATEGORY' and Labeltype='fixedstr');
delimiter;

CREATE TABLE if not exists `ld_account_set_advfilter` (
  `columnindex` int(11) DEFAULT NULL,
  `columnname` varchar(250) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  `column_condition` varchar(50) DEFAULT NULL,
  `value` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_account_set','recycleselect','text',0,0 );
delimiter;

DROP FUNCTION IF EXISTS `func_changeToCapitalRMB`;
delimiter ||
CREATE FUNCTION `func_changeToCapitalRMB`(MONEY decimal(14,2)) RETURNS varchar(150) CHARSET utf8
BEGIN

	DECLARE RV_MONEY0 VARCHAR(20);
	DECLARE RV_MONEY1 VARCHAR(4);
	DECLARE RV_MONEY2 VARCHAR(4);
	DECLARE V_MONEY0 VARCHAR(28);
	DECLARE V_MONEY1 VARCHAR(4);
	DECLARE V_MONEY2 VARCHAR(4);
	DECLARE V_MONEY3 VARCHAR(4);
	DECLARE V_MONEY4 VARCHAR(4);
	DECLARE V_MONEY5 VARCHAR(4);
	DECLARE V_MONEY6 VARCHAR(4);
	DECLARE V_MONEY7 VARCHAR(4);
	DECLARE V_MONEY8 VARCHAR(4);
	DECLARE V_MONEY9 VARCHAR(4);
	DECLARE V_MONEY10 VARCHAR(4);
	DECLARE V_MONEY11 VARCHAR(4);
	DECLARE V_MONEY12 VARCHAR(4);
	DECLARE RPV_MONEY1 VARCHAR(4);
	DECLARE RPV_MONEY2 VARCHAR(4);
	DECLARE PV_MONEY0 VARCHAR(14);
	DECLARE PV_MONEY1 VARCHAR(4);
	DECLARE PV_MONEY2 VARCHAR(4);
	DECLARE PV_MONEY3 VARCHAR(4);
	DECLARE PV_MONEY4 VARCHAR(4);
	DECLARE PV_MONEY5 VARCHAR(4);
	DECLARE PV_MONEY6 VARCHAR(4);
	DECLARE PV_MONEY7 VARCHAR(4);
	DECLARE PV_MONEY8 VARCHAR(4);
	DECLARE PV_MONEY9 VARCHAR(4);
	DECLARE PV_MONEY10 VARCHAR(4);
	DECLARE PV_MONEY11 VARCHAR(4);
	DECLARE PV_MONEY12 VARCHAR(4);
	DECLARE Z_MONEY VARCHAR(28);

	SET Z_MONEY=FLOOR(MONEY);
	SET V_MONEY0=LTRIM(RTRIM(Z_MONEY));
	SET Z_MONEY=FLOOR(MONEY*100);
	SET RV_MONEY0=LTRIM(RTRIM(Z_MONEY));
	SET RV_MONEY1=SUBSTR(RV_MONEY0,LENGTH(RV_MONEY0),1);

	IF LENGTH(RV_MONEY0)>1 THEN 
		SET RV_MONEY2=SUBSTR(RV_MONEY0,LENGTH(RV_MONEY0)-1,1);
	ELSE
		SET RV_MONEY2='0';
	END IF;

	SET V_MONEY1=SUBSTR(V_MONEY0,LENGTH(V_MONEY0),1);

	IF LENGTH(V_MONEY0)-1>0 THEN
		SET V_MONEY2=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-1,1);
	ELSE
		SET V_MONEY2='0';
	END IF;

	IF LENGTH(V_MONEY0)-2>0 THEN
		SET V_MONEY3=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-2,1);
	ELSE
		SET V_MONEY3='0';

	END IF;

	IF LENGTH(V_MONEY0)-3>0 THEN
		SET V_MONEY4=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-3,1);
	ELSE
		SET V_MONEY4='0';
	END IF;

	IF LENGTH(V_MONEY0)-4>0 THEN
		SET V_MONEY5=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-4,1);
	ELSE
		SET V_MONEY5='0';
	END IF;

	IF LENGTH(V_MONEY0)-5>0 THEN
		SET V_MONEY6=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-5,1);
	ELSE
		SET V_MONEY6='0';
	END IF;

	IF LENGTH(V_MONEY0)-6>0 THEN
		SET V_MONEY7=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-6,1);
	ELSE
		SET V_MONEY7='0';
	END IF;

	IF LENGTH(V_MONEY0)-7>0 THEN
		SET V_MONEY8=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-7,1);
	ELSE
		SET V_MONEY8='0';
	END IF;

	IF LENGTH(V_MONEY0)-8>0 THEN
		SET V_MONEY9=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-8,1);
	ELSE
		SET V_MONEY9='0';
	END IF;

	IF LENGTH(V_MONEY0)-9>0 THEN
		SET V_MONEY10=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-9,1);
	ELSE
		SET V_MONEY10='0';
	END IF;

	IF LENGTH(V_MONEY0)-10>0 THEN
		SET V_MONEY11=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-10,1);
	ELSE
		SET V_MONEY11='0';
	END IF;

	IF LENGTH(V_MONEY0)-11>0 THEN
		SET V_MONEY12=SUBSTR(V_MONEY0,LENGTH(V_MONEY0)-11,1);
	ELSE
		SET V_MONEY12='0';
	END IF;


	SELECT 
		CASE
			WHEN RV_MONEY1=0 THEN ''
			WHEN RV_MONEY1=1 THEN '壹分'
			WHEN RV_MONEY1=2 THEN '贰分'
			WHEN RV_MONEY1=3 THEN '叁分'			
			WHEN RV_MONEY1=4 THEN '肆分'
			WHEN RV_MONEY1=5 THEN '伍分'
			WHEN RV_MONEY1=6 THEN '陆分'
			WHEN RV_MONEY1=7 THEN '柒分'	
			WHEN RV_MONEY1=8 THEN '捌分'	
			WHEN RV_MONEY1=9 THEN '玖分'
		END INTO RPV_MONEY1;
	SELECT 
		CASE
			WHEN RV_MONEY2=0 AND RV_MONEY1=0 THEN '整'
			WHEN RV_MONEY2=0 AND RV_MONEY1>0 THEN '零'
			WHEN RV_MONEY2=1 THEN '壹角'
			WHEN RV_MONEY2=2 THEN '贰角'
			WHEN RV_MONEY2=3 THEN '叁角'			
			WHEN RV_MONEY2=4 THEN '肆角'
			WHEN RV_MONEY2=5 THEN '伍角'
			WHEN RV_MONEY2=6 THEN '陆角'
			WHEN RV_MONEY2=7 THEN '柒角'	
			WHEN RV_MONEY2=8 THEN '捌角'	
			WHEN RV_MONEY2=9 THEN '玖角'
		END INTO RPV_MONEY2;
	SELECT 
		CASE
			WHEN V_MONEY1=0 THEN '元'
			WHEN V_MONEY1=1 THEN '壹元'
			WHEN V_MONEY1=2 THEN '贰元'
			WHEN V_MONEY1=3 THEN '叁元'			
			WHEN V_MONEY1=4 THEN '肆元'
			WHEN V_MONEY1=5 THEN '伍元'
			WHEN V_MONEY1=6 THEN '陆元'
			WHEN V_MONEY1=7 THEN '柒元'	
			WHEN V_MONEY1=8 THEN '捌元'	
			WHEN V_MONEY1=9 THEN '玖元'
		END INTO PV_MONEY1;
	SELECT 
		CASE
			WHEN V_MONEY2=0 THEN ''
			WHEN V_MONEY2=1 THEN '壹拾'
			WHEN V_MONEY2=2 THEN '贰拾'
			WHEN V_MONEY2=3 THEN '叁拾'			
			WHEN V_MONEY2=4 THEN '肆拾'
			WHEN V_MONEY2=5 THEN '伍拾'
			WHEN V_MONEY2=6 THEN '陆拾'
			WHEN V_MONEY2=7 THEN '柒拾'	
			WHEN V_MONEY2=8 THEN '捌拾'	
			WHEN V_MONEY2=9 THEN '玖拾'
		END INTO PV_MONEY2;
	SELECT 
		CASE
			WHEN V_MONEY3=0 THEN ''
			WHEN V_MONEY3=1 THEN '壹佰'
			WHEN V_MONEY3=2 THEN '贰佰'
			WHEN V_MONEY3=3 THEN '叁佰'			
			WHEN V_MONEY3=4 THEN '肆佰'
			WHEN V_MONEY3=5 THEN '伍佰'
			WHEN V_MONEY3=6 THEN '陆佰'
			WHEN V_MONEY3=7 THEN '柒佰'	
			WHEN V_MONEY3=8 THEN '捌佰'	
			WHEN V_MONEY3=9 THEN '玖佰'
		END INTO PV_MONEY3;
	SELECT 
		CASE
			WHEN V_MONEY4=0 THEN ''
			WHEN V_MONEY4=1 THEN '壹仟'
			WHEN V_MONEY4=2 THEN '贰仟'
			WHEN V_MONEY4=3 THEN '叁仟'			
			WHEN V_MONEY4=4 THEN '肆仟'
			WHEN V_MONEY4=5 THEN '伍仟'
			WHEN V_MONEY4=6 THEN '陆仟'
			WHEN V_MONEY4=7 THEN '柒仟'	
			WHEN V_MONEY4=8 THEN '捌仟'	
			WHEN V_MONEY4=9 THEN '玖仟'
		END INTO PV_MONEY4;
	SELECT 
		CASE
			WHEN V_MONEY5=0 THEN '万'
			WHEN V_MONEY5=1 THEN '壹万'
			WHEN V_MONEY5=2 THEN '贰万'
			WHEN V_MONEY5=3 THEN '叁万'			
			WHEN V_MONEY5=4 THEN '肆万'
			WHEN V_MONEY5=5 THEN '伍万'
			WHEN V_MONEY5=6 THEN '陆万'
			WHEN V_MONEY5=7 THEN '柒万'	
			WHEN V_MONEY5=8 THEN '捌万'	
			WHEN V_MONEY5=9 THEN '玖万'
		END INTO PV_MONEY5;
	SELECT 
		CASE
			WHEN V_MONEY6=0 THEN ''
			WHEN V_MONEY6=1 THEN '壹拾'
			WHEN V_MONEY6=2 THEN '贰拾'
			WHEN V_MONEY6=3 THEN '叁拾'			
			WHEN V_MONEY6=4 THEN '肆拾'
			WHEN V_MONEY6=5 THEN '伍拾'
			WHEN V_MONEY6=6 THEN '陆拾'
			WHEN V_MONEY6=7 THEN '柒拾'	
			WHEN V_MONEY6=8 THEN '捌拾'	
			WHEN V_MONEY6=9 THEN '玖拾'
		END INTO PV_MONEY6;
	SELECT 
		CASE
			WHEN V_MONEY7=0 THEN ''
			WHEN V_MONEY7=1 THEN '壹佰'
			WHEN V_MONEY7=2 THEN '贰佰'
			WHEN V_MONEY7=3 THEN '叁佰'			
			WHEN V_MONEY7=4 THEN '肆佰'
			WHEN V_MONEY7=5 THEN '伍佰'
			WHEN V_MONEY7=6 THEN '陆佰'
			WHEN V_MONEY7=7 THEN '柒佰'	
			WHEN V_MONEY7=8 THEN '捌佰'	
			WHEN V_MONEY7=9 THEN '玖佰'
		END INTO PV_MONEY7;
	SELECT 
		CASE
			WHEN V_MONEY8=0 THEN ''
			WHEN V_MONEY8=1 THEN '壹仟'
			WHEN V_MONEY8=2 THEN '贰仟'
			WHEN V_MONEY8=3 THEN '叁仟'			
			WHEN V_MONEY8=4 THEN '肆仟'
			WHEN V_MONEY8=5 THEN '伍仟'
			WHEN V_MONEY8=6 THEN '陆仟'
			WHEN V_MONEY8=7 THEN '柒仟'	
			WHEN V_MONEY8=8 THEN '捌仟'	
			WHEN V_MONEY8=9 THEN '玖仟'
		END INTO PV_MONEY8;
	SELECT 
		CASE
			WHEN V_MONEY9=0 THEN '亿'
			WHEN V_MONEY9=1 THEN '壹亿'
			WHEN V_MONEY9=2 THEN '贰亿'
			WHEN V_MONEY9=3 THEN '叁亿'			
			WHEN V_MONEY9=4 THEN '肆亿'
			WHEN V_MONEY9=5 THEN '伍亿'
			WHEN V_MONEY9=6 THEN '陆亿'
			WHEN V_MONEY9=7 THEN '柒亿'	
			WHEN V_MONEY9=8 THEN '捌亿'	
			WHEN V_MONEY9=9 THEN '玖亿'
		END INTO PV_MONEY9;
	SELECT 
		CASE
			WHEN V_MONEY10=0 THEN ''
			WHEN V_MONEY10=1 THEN '壹拾'
			WHEN V_MONEY10=2 THEN '贰拾'
			WHEN V_MONEY10=3 THEN '叁拾'			
			WHEN V_MONEY10=4 THEN '肆拾'
			WHEN V_MONEY10=5 THEN '伍拾'
			WHEN V_MONEY10=6 THEN '陆拾'
			WHEN V_MONEY10=7 THEN '柒拾'	
			WHEN V_MONEY10=8 THEN '捌拾'	
			WHEN V_MONEY10=9 THEN '玖拾'
		END INTO PV_MONEY10;
	SELECT 
		CASE
			WHEN V_MONEY11=0 THEN ''
			WHEN V_MONEY11=1 THEN '壹佰'
			WHEN V_MONEY11=2 THEN '贰佰'
			WHEN V_MONEY11=3 THEN '叁佰'			
			WHEN V_MONEY11=4 THEN '肆佰'
			WHEN V_MONEY11=5 THEN '伍佰'
			WHEN V_MONEY11=6 THEN '陆佰'
			WHEN V_MONEY11=7 THEN '柒佰'	
			WHEN V_MONEY11=8 THEN '捌佰'	
			WHEN V_MONEY11=9 THEN '玖佰'
		END INTO PV_MONEY11;
	SELECT 
		CASE
			WHEN V_MONEY12=0 THEN ''
			WHEN V_MONEY12=1 THEN '壹仟'
			WHEN V_MONEY12=2 THEN '贰仟'
			WHEN V_MONEY12=3 THEN '叁仟'			
			WHEN V_MONEY12=4 THEN '肆仟'
			WHEN V_MONEY12=5 THEN '伍仟'
			WHEN V_MONEY12=6 THEN '陆仟'
			WHEN V_MONEY12=7 THEN '柒仟'	
			WHEN V_MONEY12=8 THEN '捌仟'	
			WHEN V_MONEY12=9 THEN '玖仟'
		END INTO PV_MONEY12;

	SET V_MONEY0=CONCAT(PV_MONEY12,PV_MONEY11,PV_MONEY10,PV_MONEY9,PV_MONEY8,PV_MONEY7,PV_MONEY6,PV_MONEY5,PV_MONEY4,PV_MONEY3,PV_MONEY2,PV_MONEY1,RPV_MONEY2,RPV_MONEY1);

	IF SUBSTR(V_MONEY0,1,1)='亿' THEN
		SET V_MONEY0=SUBSTR(V_MONEY0,2,LENGTH(V_MONEY0)-1);
	END IF;

	IF SUBSTR(V_MONEY0,1,1)='万' THEN
		SET V_MONEY0=SUBSTR(V_MONEY0,2,LENGTH(V_MONEY0)-1);
	END IF;

	SET V_MONEY0=REPLACE(V_MONEY0,'亿万','亿');

	IF locate('元',V_MONEY0)-locate('亿',V_MONEY0)=2 THEN
		SET V_MONEY0=REPLACE(V_MONEY0,'亿壹','亿零壹');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿贰','亿零贰');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿叁','亿零叁');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿肆','亿零肆');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿伍','亿零伍');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿陆','亿零陆');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿柒','亿零柒');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿捌','亿零捌');
		SET V_MONEY0=REPLACE(V_MONEY0,'亿玖','亿零玖');
	END IF;

	SET V_MONEY0=REPLACE(V_MONEY0,'亿壹拾','亿零壹拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿贰拾','亿零贰拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿叁拾','亿零叁拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿肆拾','亿零肆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿伍拾','亿零伍拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿陆拾','亿零陆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿柒拾','亿零柒拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿捌拾','亿零捌拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿玖拾','亿零玖拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿壹佰','亿零壹佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿贰佰','亿零贰佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿叁佰','亿零叁佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿肆佰','亿零肆佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿伍佰','亿零伍佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿陆佰','亿零陆佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿柒佰','亿零柒佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿捌佰','亿零捌佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'亿玖佰','亿零玖佰');

	IF locate('元',V_MONEY0)-locate('万',V_MONEY0)=2 THEN
		SET V_MONEY0=REPLACE(V_MONEY0,'万壹','万零壹');
		SET V_MONEY0=REPLACE(V_MONEY0,'万贰','万零贰');
		SET V_MONEY0=REPLACE(V_MONEY0,'万叁','万零叁');
		SET V_MONEY0=REPLACE(V_MONEY0,'万肆','万零肆');
		SET V_MONEY0=REPLACE(V_MONEY0,'万伍','万零伍');
		SET V_MONEY0=REPLACE(V_MONEY0,'万陆','万零陆');
		SET V_MONEY0=REPLACE(V_MONEY0,'万柒','万零柒');
		SET V_MONEY0=REPLACE(V_MONEY0,'万捌','万零捌');
		SET V_MONEY0=REPLACE(V_MONEY0,'万玖','万零玖');
	END IF;

	SET V_MONEY0=REPLACE(V_MONEY0,'万壹拾','万零壹拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万贰拾','万零贰拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万叁拾','万零叁拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万肆拾','万零肆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万伍拾','万零伍拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万陆拾','万零陆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万柒拾','万零柒拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万捌拾','万零捌拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万玖拾','万零玖拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'万壹佰','万零壹佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万贰佰','万零贰佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万叁佰','万零叁佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万肆佰','万零肆佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万伍佰','万零伍佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万陆佰','万零陆佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万柒佰','万零柒佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万捌佰','万零捌佰');
	SET V_MONEY0=REPLACE(V_MONEY0,'万玖佰','万零玖佰');

	IF locate('元',V_MONEY0)-locate('仟',V_MONEY0)=2 THEN
		SET V_MONEY0=REPLACE(V_MONEY0,'仟壹','仟零壹');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟贰','仟零贰');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟叁','仟零叁');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟肆','仟零肆');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟伍','仟零伍');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟陆','仟零陆');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟柒','仟零柒');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟捌','仟零捌');
		SET V_MONEY0=REPLACE(V_MONEY0,'仟玖','仟零玖');
	END IF;

	SET V_MONEY0=REPLACE(V_MONEY0,'仟壹拾','仟零壹拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟贰拾','仟零贰拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟叁拾','仟零叁拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟肆拾','仟零肆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟伍拾','仟零伍拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟陆拾','仟零陆拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟柒拾','仟零柒拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟捌拾','仟零捌拾');
	SET V_MONEY0=REPLACE(V_MONEY0,'仟玖拾','仟零玖拾');

	IF locate('元',V_MONEY0)-locate('佰',V_MONEY0)=2 THEN
		SET V_MONEY0=REPLACE(V_MONEY0,'佰壹','佰零壹');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰贰','佰零贰');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰叁','佰零叁');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰肆','佰零肆');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰伍','佰零伍');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰陆','佰零陆');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰柒','佰零柒');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰捌','佰零捌');
		SET V_MONEY0=REPLACE(V_MONEY0,'佰玖','佰零玖');
	END IF;

	IF V_MONEY0='元整' THEN
		SET V_MONEY0='零元';
	END IF;

	RETURN V_MONEY0;
END ||
delimiter;

drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
create PROCEDURE  account_singlerecycle_highsea_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';

  select allotaccount into @allotaccount from ld_account_set;
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		
	  if var_condition='or'  then
			 
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
		else
			 
				if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');

		end if;
    
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
		

    if var_condition='or'  then
			
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
			end if;	
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
			  
			 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;	
			ELSE
		
			  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

		

end||
delimiter;

drop PROCEDURE if EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE PROCEDURE account_singlerecycle_normal_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
 
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
   
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		 
		  if var_iscycle ='yes' then 
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
			else
				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			 end if;
      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				
				if var_iscycle='yes' then 
					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
				else
						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
			   end if;

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then
				 
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
				end if;
		else
			 if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
			
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
		end if;

     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();


		if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
			
		      if @recycleselect<>'' and @recycleselect is not null THEN	
						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
					end if;	
				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
  
					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				  end if;
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
					
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;

end ||
delimiter;

drop PROCEDURE if EXISTS `execute_account_publicoperation`;
delimiter ||
create PROCEDURE  execute_account_publicoperation()
BEGIN
	select `status` into @status  from ld_account_set;


	if @status=0   then
		select DATE_FORMAT(eventdate,'%Y-%m-%d') into @eventdate from ld_sys_event where type='publicaccount' ORDER BY eventdate DESC LIMIT 1;
		if @eventdate!=CURDATE() then
			update  ld_sys_event set eventdate=now() where type='publicaccount';
			call account_singlerecycle_normal_rule();
			call account_singlerecycle_highsea_rule();
		end if;

	end if;
end||
delimiter;


SET @tabid=22;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='description' LIMIT 1);
UPDATE ld_profile2field SET visible=0 WHERE tabid=@tabid AND fieldid=@fieldid;
delimiter;

UPDATE ld_documenttemplates SET body=REPLACE(body,'.font2 {','.font222 {');
UPDATE ld_documenttemplates SET body=REPLACE(body,'class="font2"','class="font222"');

UPDATE ld_documenttemplates SET body=REPLACE(body,'.font3 {','.font333 {');
UPDATE ld_documenttemplates SET body=REPLACE(body,'class="font3"','class="font333"');

UPDATE ld_documenttemplates SET body=REPLACE(body,'.font4 {','.font444 {');
UPDATE ld_documenttemplates SET body=REPLACE(body,'class="font4"','class="font444"');

DROP PROCEDURE IF EXISTS `ldcrm_reset_uitype230_20190312`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_uitype230_20190312`(
)
BEGIN

	DECLARE tmp_fieldid INT(19) DEFAULT 0;
	DECLARE tmp_columnname VARCHAR(200) DEFAULT ''; 
	DECLARE tmp_tablename VARCHAR(200) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR SELECT fieldid,columnname,tablename FROM ld_field WHERE uitype=230 AND presence<>1;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_fieldid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_fieldid,tmp_columnname,tmp_tablename;
	WHILE(tmp_fieldid IS NOT NULL) DO
		SET @update_sql1=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", '.font2 {','.font222 {')");	
		SET @update_sql2=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", '.font3 {','.font333 {')");
		SET @update_sql3=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", '.font4 {','.font444 {')");
		SET @update_sql4=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", 'class=",'"font2"',"','class=",'"font222"',"')");	
		SET @update_sql5=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", 'class=",'"font3"',"','class=",'"font333"',"')");	
		SET @update_sql6=CONCAT(" UPDATE ",tmp_tablename, " SET ",tmp_columnname,"=REPLACE(",tmp_columnname,", 'class=",'"font4"',"','class=",'"font444"',"')");	

		PREPARE stalter1 FROM @update_sql1;
		PREPARE stalter2 FROM @update_sql2;
		PREPARE stalter3 FROM @update_sql3;
		PREPARE stalter4 FROM @update_sql4;
		PREPARE stalter5 FROM @update_sql5;
		PREPARE stalter6 FROM @update_sql6;

		EXECUTE stalter1;
		EXECUTE stalter2;
		EXECUTE stalter3;
		EXECUTE stalter4;
		EXECUTE stalter5;
		EXECUTE stalter6;

		DEALLOCATE PREPARE stalter1;
		DEALLOCATE PREPARE stalter2;
		DEALLOCATE PREPARE stalter3;
		DEALLOCATE PREPARE stalter4;
		DEALLOCATE PREPARE stalter5;
		DEALLOCATE PREPARE stalter6;

		FETCH MYCUSOR INTO tmp_fieldid,tmp_columnname,tmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_reset_uitype230_20190312;
DROP PROCEDURE IF EXISTS `ldcrm_reset_uitype230_20190312`;
delimiter;
-- 2019-03-12

UPDATE ld_desk SET fieldlabel='Select the high seas administrators' WHERE labelbol='CHOOSEPUBLICACCOUNTADMIN' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='High seas customers execution recycling,set the rule' WHERE labelbol='COMPLETEAUTOMATICRECOVERYRULE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Common customers execution recycling,set the rule' WHERE labelbol='NORMALCUSTOMRECYCLE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Multiple recycling rules' WHERE labelbol='RECYCLERULE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Single recycle Rule' WHERE labelbol='RECYCLERULE' AND languagetype='en';
UPDATE ld_tranlabel SET fieldlabel='Position' WHERE fieldlabel='职务' AND trantable='ld_field' AND languagetype='en';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply' LIMIT 1);
UPDATE ld_tabdetailfield SET defaultcolumn=1 WHERE tabid=@tabid AND columnname IN ('source','destination','starttime','endtime','traffictype','description');
delimiter;

update ld_desk set fieldlabel='CRM小程序企业号设置' where labelbol='WECHATAPPLETSETTINGS' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='设置CRM小程序企业号' where labelbol='WECHATAPPLETSETTINGSWEBURL' and Labeltype='fixedstr' and languagetype='zh';
delimiter;
-- 2019-03-15

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BEFOREREMINDDAYSCUSTOMER','How many days before customer recycling is set to remind the sales person in charge (0 for day reminder, empty for no reminder)','fixedstr'
from dual where not exists(select 1 from ld_desk  where languagetype='en' and labelbol='BEFOREREMINDDAYSCUSTOMER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BEFOREREMINDDAYSCUSTOMER','客户回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒）','fixedstr'
from dual where not exists(select 1 from ld_desk  where languagetype='zh' and labelbol='BEFOREREMINDDAYSCUSTOMER' and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_account_set','beforereminddays','varchar',50,'' );
delimiter;

drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
create PROCEDURE  account_singlerecycle_highsea_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
  select beforereminddays into @var_beforereminddays from ld_account_set;
 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
  select allotaccount into @allotaccount from ld_account_set;
	select recycleselect into @recycleselect from ld_account_set;
	set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;
			if var_days<=0 THEN
				leave loop1;
		   end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0');

                    if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;

	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' ORDER BY ld_account_set_rule.sequence asc ) ";

			 set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
				end if;
				
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
		delete from ld_publicaccount_remindtableview ;
     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
			prepare stmt from @tmpthree;
			execute stmt;
			deallocate prepare stmt;

			call crm_publicaccount_beforereminds();
	end if;
end||
delimiter;


drop PROCEDURE if exists account_singlerecycle_normal_rule_beforeremind;
delimiter ||
create PROCEDURE account_singlerecycle_normal_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
 
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
   
	select beforereminddays into @var_beforereminddays from ld_account_set;
  if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
   set @maxdays=@maxdays-@var_beforereminddays;
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
			 set var_days=var_days-@var_beforereminddays;
			if var_days<=0 THEN
				leave loop1;
		   end if;
		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		 
		  if var_iscycle ='yes' then 
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
			else
				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			 end if;
      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				
				if var_iscycle='yes' then 
					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
				else
						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
			   end if;

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
			set @len=CHAR_LENGTH(' union all ');
			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

			if var_condition='or'  then
				 set @TMP_TMPTable=" ( select 'normal', concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' ORDER BY ld_account_set_rule.sequence asc ) ";

				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

				set @TMPSQL_ONE=concat( ' select  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				if @recycleselect<>'' and @recycleselect is not null THEN	
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
				end if;	
				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
					end if;
				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		  else
				if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
				end if;
			
				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
			end if;
	 	delete from ld_publicaccount_remindtableview ;
		 set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
			prepare stmt from @tmpthree;
			execute stmt;
			deallocate prepare stmt;

			call crm_publicaccount_beforereminds();
	 end if;

end||
delimiter;

drop PROCEDURE if exists crm_publicaccount_beforereminds;
delimiter ||
create PROCEDURE crm_publicaccount_beforereminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，即将要回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
		
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

end||
delimiter;


drop PROCEDURE if EXISTS `execute_account_publicoperation`;
delimiter ||
create PROCEDURE  execute_account_publicoperation()

BEGIN
	select `status` into @status  from ld_account_set;


	if @status=0   then
		select DATE_FORMAT(eventdate,'%Y-%m-%d') into @eventdate from ld_sys_event where type='publicaccount' ORDER BY eventdate DESC LIMIT 1;
		if @eventdate!=CURDATE() then
			 update  ld_sys_event set eventdate=now() where type='publicaccount';
			call account_singlerecycle_normal_rule_beforeremind();
			call account_singlerecycle_highsea_rule_beforeremind();
			call account_singlerecycle_normal_rule();
			call account_singlerecycle_highsea_rule();
		end if;

	end if;
end||
delimiter;

insert into ld_account_set_rule(tabname,type,labelbol,sequence,status,columnname,iscycle,singlelabelbol)
SELECT  'Singin','normal','ALLOCATEORGETSTARTNOCREATESINGINCREATE/Days',0,'inactive','createdtime','no','ALLOCATEORCREATETIMESTART/NOTCREATESINGIN'
from dual where not exists(select 1 from ld_account_set_rule  where tabname='Singin' and type='normal');

insert into ld_account_set_rule(tabname,type,labelbol,sequence,status,columnname,iscycle,singlelabelbol)
SELECT  'Singin','complete','ALLOCATEORGETSTARTNOCREATESINGIN/Days',0,'inactive','createdtime','no','ALLOCATEORGETSTART/NOTCREATESINGIN'
from dual where not exists(select 1 from ld_account_set_rule  where tabname='Singin' and type='complete');
delimiter;
update ld_account_set_rule set sequence=1 where tabname='ContactRecords' ;
update ld_account_set_rule set sequence=2 where tabname='Singin' ;
update ld_account_set_rule set sequence=3 where tabname='Potentials' ;
update ld_account_set_rule set sequence=4 where tabname='SalesOrder' ;
update ld_account_set_rule set sequence=5 where tabname='ServiceContracts' ;
update ld_account_set_rule set sequence=6 where tabname='ServiceContracts' ;
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATESINGIN','自分配或领用之日起距最近一次最近一次外勤签到的创建时间已超过','fixedstr'
 from dual  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOCATEORGETSTARTNOCREATESINGIN' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATESINGIN','The nearest createdtime of singin has exceed  the date of distribution or receive','fixedstr'
 from dual  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLOCATEORGETSTARTNOCREATESINGIN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTCREATESINGIN','天没有创建考勤签到','fixedstr'
 from dual  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOTCREATESINGIN' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTCREATESINGIN',' days of singin','fixedstr'
 from dual  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOTCREATESINGIN' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATESINGINCREATE','自分配或创建之日起距最近一次考勤签到的创建时间已超过','fixedstr'
 from dual  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOCATEORGETSTARTNOCREATESINGINCREATE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATESINGINCREATE',' The nearest createdtime of singin has exceed  the date of distribution or creation','fixedstr'
from dual  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLOCATEORGETSTARTNOCREATESINGINCREATE' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='singin';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1
where not exists(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,presence)
select @tabid,@maxfieldid+1,'createdtime','ld_singin',73,'createdtime',0 from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='createdtime');
delimiter;

call AddColumn('ld_singin','deleted','int',11,0 );
delimiter;

update ld_singin set accountid=record where tabid=6;
delimiter;
-- 2019-03-22


drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
create PROCEDURE  account_singlerecycle_highsea_rule()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and (ld_field.presence in(0,2) ) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';

  select allotaccount into @allotaccount from ld_account_set;
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			
				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
	
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
	
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
	  if var_condition='or'  then
			 
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  
			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
			
		else
			 
				if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
	
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');

		end if;
  
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
		

    if var_condition='or'  then
			
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
			end if;	
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
			  
			 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;	
			ELSE
		
			  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
		 end if;
select @TMPSQL_TWO;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

		

end||
delimiter;

drop PROCEDURE if EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE PROCEDURE account_singlerecycle_normal_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
 DECLARE var_smownercolumn varchar(50);
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
   
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		 
		  if var_iscycle ='yes' then 
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
			else
				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			 end if;
      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				
				if var_iscycle='yes' then 
					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
				else
						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
			   end if;

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then
				 
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
				end if;
		else
			 if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;
			
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		 	end if;	
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
		end if;

     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();


		if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
			
		      if @recycleselect<>'' and @recycleselect is not null THEN	
						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
					end if;	
				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
  
					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				  end if;
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
					
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;


end||
delimiter;


drop PROCEDURE if exists account_singlerecycle_normal_rule_beforeremind;
delimiter ||
create PROCEDURE account_singlerecycle_normal_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
 
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
   
	select beforereminddays into @var_beforereminddays from ld_account_set;
  if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
   set @maxdays=@maxdays-@var_beforereminddays;
	select recycleselect into @recycleselect from ld_account_set;
	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
			 set var_days=var_days-@var_beforereminddays;
			if var_days<=0 THEN
				leave loop1;
		   end if;
		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		 
		  if var_iscycle ='yes' then 
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
			else
				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

			 end if;
      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				
				if var_iscycle='yes' then 
					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
				else
						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname); 
						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
			   end if;

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
			set @len=CHAR_LENGTH(' union all ');
			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
			
			if var_condition='or'  then
				 set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.status='active' and ld_account_set_rule.status='active' ORDER BY ld_account_set_rule.sequence asc ) ";

				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				if @recycleselect<>'' and @recycleselect is not null THEN	
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
				end if;	
				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
					end if;
				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
				
		  else
				if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
				end if;
			
				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
			end if;
	 	delete from ld_publicaccount_remindtableview ;
		 set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
			prepare stmt from @tmpthree;
			execute stmt;
			deallocate prepare stmt;

			call crm_publicaccount_beforereminds();
	 end if;

end||
delimiter;

drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
create PROCEDURE  account_singlerecycle_highsea_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
  select beforereminddays into @var_beforereminddays from ld_account_set;
 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
  select allotaccount into @allotaccount from ld_account_set;
	select recycleselect into @recycleselect from ld_account_set;
	set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;
			if var_days<=0 THEN
				leave loop1;
		   end if;
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;

	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' ORDER BY ld_account_set_rule.sequence asc ) ";

			 set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
				end if;
				
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
		delete from ld_publicaccount_remindtableview ;
     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
			prepare stmt from @tmpthree;
			execute stmt;
			deallocate prepare stmt;

			call crm_publicaccount_beforereminds();
	end if;
end||
delimiter;

update ld_inventorytaxinfo set percentage=13 where taxname='tax2';
delimiter;

update ld_producttoolfield_formula set formulastring='date_add(a-1 day,1,year)' where
producttoolfieldid in(select producttoolfieldid from ld_producttoolfield where tabid=37 and columnname='servicecontracts_end_date');
delimiter;

call AddColumn('ld_field','take_photo_only','int',11,0);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','takephotopnly','移动端仅允许拍照上传','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='takephotopnly');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','takephotopnly','Take photo only','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='takephotopnly');
delimiter;
-- 2019-03-25

CALL AddColumn('ld_weixinmp_users','module','varchar',255,null);

SET @i=0;
SET @j=0;
SET @blockid=(SELECT blockid FROM ld_settings_blocks WHERE label='LBL_INTERFACE_SETTINGS' ORDER BY active,sequence LIMIT 1);
UPDATE ld_settings_field SET sequence=sequence+100 WHERE blockid=@blockid;
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='LBL_SMS_SETTINGS';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='LBL_MAIL_SERVER_SETTINGS';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='LBL_DATAINTERFACE_SETTING';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='LBL_EXPANSION_CAMCARD';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='BANGWO8INTERFACE';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='LBL_PHONESTEWARD_SET';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='ExternalContactSetting';
UPDATE ld_settings_field SET sequence=(@j:=@j+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

SET @i=0;
SET @j=0;
SET @blockid=(SELECT blockid FROM ld_settings_blocks WHERE label='LBI_MINI_SETTINGS' ORDER BY active,sequence LIMIT 1);
UPDATE ld_settings_field SET sequence=sequence+100 WHERE blockid=@blockid;
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='WECHATAPPLETSETTINGS';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='CUSTOMERSELFSERVICECONFIG01';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='CUSTOMERSELFSERVICECONFIG02';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='CUSTOMERSELFSERVICECONFIG04';
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid AND `name`='CUSTOMERSELFSERVICECONFIG03';
UPDATE ld_settings_field SET sequence=(@j:=@j+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

UPDATE ld_desk SET fieldlabel='系统管理员服务小程序下载' WHERE labelbol='CUSTOMERSELFSERVICECONFIGHOME06' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='System administrator service WeChat applet download' WHERE labelbol='CUSTOMERSELFSERVICECONFIGHOME06' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='其他成员的服务小程序请在成员详情界面下载' WHERE labelbol='CUSTOMERSELFSERVICECONFIGHOME07' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='The service WeChat applet of other members can be downloaded from the details interface' WHERE labelbol='CUSTOMERSELFSERVICECONFIGHOME07' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='手机号码显示样式是否根据系统参数“设置系统中手机字段显示的样式（是否隐藏部分内容）”控制' WHERE labelbol='is_mobile_style' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='{$Accounts.Accounts}和{$HelpDesk.HelpDesk}详情界面是否显示具体的服务到期日' WHERE labelbol='select_due_date' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='单据相关信息列表是否允许查询所有关联数据' WHERE labelbol='accountallview' AND languagetype='zh';

SET @tabid=29;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountallview' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='单据相关信息查询所有关联数据' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
delimiter;

UPDATE ld_desk SET fieldlabel='{$ServiceContracts.ServiceContracts}信息' WHERE labelbol='SERVICEINFORMATION' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='{$ServiceContracts.ServiceContracts} Information' WHERE labelbol='SERVICEINFORMATION' AND languagetype='en';

SET @tabid=29;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='select_servicedetail' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='显示{$ServiceContracts.ServiceContracts}信息' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel='Display {$ServiceContracts.ServiceContracts} Information' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en';
delimiter;

UPDATE ld_desk SET fieldlabel='{$Accounts.Accounts}和{$HelpDesk.HelpDesk}详情界面是否显示{$ServiceContracts.ServiceContracts}信息' WHERE labelbol='select_servicedetail' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Does {$Accounts.Accounts} and {$HelpDesk.HelpDesk} details interface display the {$ServiceContracts.ServiceContracts} information' WHERE labelbol='select_servicedetail' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='{$HelpDesk.HelpDesk}详情界面是否显示{$HelpDesk.HelpDesk}历史记录' WHERE labelbol='helpdesk_log' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Does {$HelpDesk.HelpDesk} details interface display the {$HelpDesk.HelpDesk} history?' WHERE labelbol='helpdesk_log' AND languagetype='en';
-- 2019-03-26

UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm01' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm01') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm02' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm02') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm03' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm03') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm04' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm04') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm05' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm05') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm06' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm06') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm07' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm07') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm08' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm08') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm09' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm09') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm10' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm10') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm11' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm11') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm12' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm12') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm13' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm13') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm14' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm14') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm15' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm15') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm16' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm16') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm17' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm17') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm18' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm18') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm19' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm19') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm20' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm20') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm21' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm21') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm22' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm22') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm23' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm23') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm24' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm24') AND prefix NOT LIKE '%-%';
UPDATE ld_modentity_num SET prefix=CONCAT(prefix,'-') WHERE semodule='CustomForm25' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype='CustomForm25') AND prefix NOT LIKE '%-%';

call AddColumn('ld_weixinmp_users','module','varchar',255,null );
delimiter;

update ld_attachmentsforbillsdetails set imagefromtype = 'Computer' where imagefromtype is NULL;
update ld_attachmentsforbillsdetails set imagefromtype = 'Albums' where imagefromtype = '相册选择';
update ld_attachmentsforbillsdetails set imagefromtype = 'Takephoto' where imagefromtype = '拍照上传';
update ld_attachmentsforbillsdetails set imagefromtype = 'Albums' where imagefromtype = '从相册选择';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Computer','电脑硬盘','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='Computer');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Computer','Computer','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='Computer');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Albums','选择相册','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='Albums');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Albums','Albums','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='Albums');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Takephoto','拍照上传','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='Takephoto');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Takephoto','Take photo','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='Takephoto');
delimiter;

call AddColumn('ld_attachments','imagefromtype','varchar',100,null );
alter table ld_attachments alter column imagefromtype set default 'Computer';
delimiter;

select max(sequence) into @sequencemax from ld_dashboard_app;
INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'InventoryQuery','InventoryQuery','','',@sequencemax+1,0,'dashboard_10' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='InventoryQuery' );

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DEPENCYCYCLE','选择的级联字段重复或形成循环级联关系,不可建立此级联关系！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DEPENCYCYCLE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DEPENCYCYCLE','选择的级联字段重复或形成循环级联关系,不可建立此级联关系！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DEPENCYCYCLE' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)select 'zh','DEPENCYSELECTNEXTPREVFIELD','步骤1：选择一个上级字段和一个下级字段。完成后点击"下一步"','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DEPENCYSELECTNEXTPREVFIELD' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DEPENCYSELECTNEXTPREVFIELD','步骤1：选择一个上级字段和一个下级字段。完成后点击"下一步"','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DEPENCYSELECTNEXTPREVFIELD' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DEPENCYEDITSECOND','步骤2：设置级联字段的每个值对应关系，设置后选择上级字段值，则下级字段仅显示设置的对应值','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DEPENCYEDITSECOND' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DEPENCYEDITSECOND','步骤2：设置级联字段的每个值对应关系，设置后选择上级字段值，则下级字段仅显示设置的对应值','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DEPENCYEDITSECOND' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETTINGDEPENCYPARENTCHILD','设置级联字段的每个值对应关系，设置后选择上级字段值，则下级字段仅显示设置的对应值','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETTINGDEPENCYPARENTCHILD' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETTINGDEPENCYPARENTCHILD','设置级联字段的每个值对应关系，设置后选择上级字段值，则下级字段仅显示设置的对应值','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETTINGDEPENCYPARENTCHILD' and labeltype='fixedstr');

delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OFCHOOSE','选择的','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OFCHOOSE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OFCHOOSE','Choosen ','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OFCHOOSE' and labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel='Salesman'
where relateid in(
select fieldid from ld_field where tabid in(select tabid from ld_tab where name='Accounts' or name="ServiceCharge")
and columnname='smownerid') and trantable='ld_field' and languagetype='en'
and fieldlabel='Assigned to';

update ld_tranlabel set fieldlabel='Service Personal'
where relateid in(
select fieldid from ld_field where tabid in(select tabid from ld_tab where name='Accounts' or name="ServiceCharge")
and columnname='servicecasher') and trantable='ld_field' and languagetype='en'
and fieldlabel='Service casher';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryLedger';
update ld_usereportcolumns set realcolumns = 'ld_stock:bill_date:createdate:Stock_日期:D' where Usereportid = @usereportid and `realcolumns` = 'ld_stock:bill_date:createdate:Stock_日期:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryAccount';
update ld_usereportcolumns set realcolumns = 'ld_stock:bill_date:createdate:Stock_日期:D' where Usereportid = @usereportid and `realcolumns` = 'ld_stock:bill_date:createdate:Stock_日期:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryQuery';
update ld_usereportcolumns set realcolumns = 'ld_products:unit_price:unit_price:Products_单价:I' where Usereportid = @usereportid and `realcolumns` = 'ld_products:unit_price:unit_price:Products_单价:V';
update ld_usereportcolumns set realcolumns = 'ld_products:inventory_qty:weight:Products_库存数量:I' where Usereportid = @usereportid and `realcolumns` = 'ld_products:inventory_qty:weight:Products_库存数量:V';
update ld_usereportcolumns set realcolumns = 'ld_products:qtyearly:qtyearly:Products_安全库存:I' where Usereportid = @usereportid and `realcolumns` = 'ld_products:qtyearly:qtyearly:Products_安全库存:V';
update ld_usereportcolumns set realcolumns = 'ld_products:costprice:costprice:Products_库存金额:I' where Usereportid = @usereportid and `realcolumns` = 'ld_products:costprice:costprice:Products_库存金额:V';
update ld_usereportcolumns set realcolumns = 'ld_products:dairu_qty:qtyearly:Products_待入库数量:I' where Usereportid = @usereportid and `realcolumns` = 'ld_products:dairu_qty:qtyearly:Products_待入库数量:V';
update ld_usereportcolumns set realcolumns = 'ld_products:daichu_qty:qtyearly:Products_待出库数量:I' where Usereportid = @usereportid and `realcolumns` = 'ld_products:daichu_qty:qtyearly:Products_待出库数量:V';
update ld_usereportcolumns set realcolumns = 'ld_products:cha_qty:qtyearly:Products_安全库存差额:I' where Usereportid = @usereportid and `realcolumns` = 'ld_products:cha_qty:qtyearly:Products_安全库存差额:V';
delimiter;

call AddColumn('ld_usereportcolumns','is_advanced','int','11',0);
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryLedger';
update ld_usereportcolumns set is_advanced = 1 where Usereportid = @usereportid and `columns` = 'ld_products:productname:productname:Products_产品名称#:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryAccount';
update ld_usereportcolumns set is_advanced = 1 where Usereportid = @usereportid and `columns` = 'ld_products:productname:productname:Products_单据产品名称:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryQuery';
update ld_usereportcolumns set is_advanced = 1 where Usereportid = @usereportid and `columns` = 'ld_products:productname:productname:Products_产品名称#:V';
delimiter;
-- 2019-03-27

DROP PROCEDURE IF EXISTS `ldcrm_add_choosebillfield`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_choosebillfield`(
	tmp_modulename VARCHAR(100),
	tmp_uitype INT(19)
)
BEGIN

	-- 73 	单选客户
	-- 57 	单选联系人
	-- 76 	单选销售机会
	-- 82		单选项目
	-- 240 	单选服务单
	-- 241 	单选项目任务
	-- 59		单选产品
	-- 81   单选供应商
	-- 96		单选供应商联系人
	-- 80   单选合同订单
	-- 243  单选服务合同

	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename) AND tmp_uitype IN (73,57,76,82,240,241,59,81,96,80,243) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
		SET @trantable='ld_field';
		
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @columnname=(SELECT columnname FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1);
		SET @fieldname=(SELECT fieldname FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1);
		SET @zh=(SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_field' AND languagetype='zh' AND Relateid=(SELECT fieldid FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1) LIMIT 1); 
		SET @en=(SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_field' AND languagetype='en' AND Relateid=(SELECT fieldid FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1) LIMIT 1);  
		
		SET @uitype=tmp_uitype; 
		SET @typeofdata='V~O';
		SET @quickcreate=0;
		SET @presence=2;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@blockid,1,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,0,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND uitype=@uitype LIMIT 1);
		SET @cnt=(SELECT COUNT(1) FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid);
		DELETE FROM ld_tranlabel WHERE trantable=@trantable AND tabid = @tabid AND relateid=@fieldid AND @cnt>2; 
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@fieldid,@zh FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid AND languagetype='zh');

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@fieldid,@en FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid AND languagetype='en');

		CALl AddColumn(@tablename,@columnname,'INT','19',NULL);
		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);

		IF tmp_uitype=73 THEN
			SET @choosetabid=6;
		ELSEIF tmp_uitype=57 THEN
			SET @choosetabid=4;
		ELSEIF tmp_uitype=76 THEN
			SET @choosetabid=2;
		ELSEIF tmp_uitype=82 THEN
			SET @choosetabid=48;
		ELSEIF tmp_uitype=240 THEN
			SET @choosetabid=13;
		ELSEIF tmp_uitype=241 THEN
			SET @choosetabid=47;
		ELSEIF tmp_uitype=59 THEN
			SET @choosetabid=14;
		ELSEIF tmp_uitype=81 THEN
			SET @choosetabid=18;
		ELSEIF tmp_uitype=96 THEN
			SET @choosetabid=(SELECT tabid FROM ld_tab WHERE name='VendorContact' LIMIT 1);
		ELSEIF tmp_uitype=80 THEN
			SET @choosetabid=22;
		ELSEIF tmp_uitype=243 THEN
			SET @choosetabid=37;
		END IF;

		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@choosetabid);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@choosetabid,@tabid,LOWER(CONCAT('get_',tmp_modulename)),@seq+1,tmp_modulename,1,'add',LOWER(CONCAT(tmp_modulename,'.',@columnname)),'datacategory_sql' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@choosetabid AND related_tabid=@tabid);
		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
	END IF;
end ||
delimiter;

update ld_producttoolfield set allowhide='yes' where columnname='taxprice' or columnname='listprice';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AVAILABLE','可用的','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AVAILABLE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AVAILABLE','Available ','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AVAILABLE' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_shujuzidian`;
delimiter ||
CREATE PROCEDURE `ldcrm_shujuzidian`(
	tmp_modulelabel VARCHAR(100)
)
BEGIN

	(SELECT
		f.fieldlabel AS '表单名称',
		CONCAT('单据表头-',e.fieldlabel) AS '区块名称',
		b.columnname AS '字段名称',
		s.COLUMN_TYPE AS '字段类型',
		b.tablename AS '数据库表名',
		d.fieldlabel AS '显示名称（CH）'
	FROM ld_tab a
	LEFT JOIN ld_field b ON a.tabid=b.tabid
	LEFT JOIN ld_blocks c ON c.blockid=b.block
	LEFT JOIN ld_tranlabel d ON d.trantable='ld_field' AND d.Relateid=b.fieldid AND d.languagetype='zh'
	LEFT JOIN ld_tranlabel e ON e.trantable='ld_blocks' AND e.Relateid=c.blockid AND e.languagetype='zh'
	LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
	INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
	WHERE f.fieldlabel=tmp_modulelabel
		AND b.presence<>1
	ORDER BY b.block,b.sequence)
	UNION ALL
	(SELECT
		f.fieldlabel AS '表单名称',
		'单据分录-字段信息' AS '区块名称',
		b.columnname AS '字段名称',
		s.COLUMN_TYPE AS '字段类型',
		b.tablename AS '数据库表名',
		d.fieldlabel AS '显示名称（CH）'
	FROM ld_tab a
	LEFT JOIN ld_producttoolfield b ON a.tabid=b.tabid
	LEFT JOIN ld_tranlabel d ON d.trantable='ld_producttoolfield' AND d.Relateid=b.producttoolfieldid AND d.languagetype='zh'
	LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
	INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
	WHERE f.fieldlabel=tmp_modulelabel
		AND b.presence<>1
	ORDER BY b.sequence)
	UNION ALL
	(SELECT
		f.fieldlabel AS '表单名称',
		'单据分录-字段信息' AS '区块名称',
		b.columnname AS '字段名称',
		s.COLUMN_TYPE AS '字段类型',
		b.tablename AS '数据库表名',
		d.fieldlabel AS '显示名称（CH）'
	FROM ld_tab a
	LEFT JOIN ld_tabdetailfield b ON a.tabid=b.tabid
	LEFT JOIN ld_tranlabel d ON d.trantable='ld_tabdetailfield' AND d.Relateid=b.tabdetailfieldid AND d.languagetype='zh'
	LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
	INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
	WHERE f.fieldlabel=tmp_modulelabel
		AND b.presence<>1
	ORDER BY b.sequence);

END ||
delimiter;

UPDATE ld_field SET defaultvalue=0 WHERE tabid=29 AND columnname='is_mobile_style' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname='select_servicedetail' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname='select_due_date' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname='helpdesk_log' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname='campaignsview' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
-- 2019-03-28

UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq set id=(SELECT MAX(relation_id) FROM ld_relatedlists);
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

UPDATE ld_version SET old_version='V7.7.1',current_version='V7.7.1',remark='V7.7.1-20190328',wx_version='V7.7.1';
delimiter;