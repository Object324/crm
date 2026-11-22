DROP TABLE if EXISTS `ld_qrcode_basic`;
CREATE TABLE IF NOT EXISTS `ld_qrcode_creation` ( 
    `qrcodebasicid` int(19) NOT NULL auto_increment PRIMARY KEY, 
    `qrcodetemplateid` int(19),
    `modulename` Varchar(50),
	`record` int(19),
	`modifiedtime` Datetime,
	`modifiedby` int(19),
	`token` Varchar(100)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

DROP TABLE if EXISTS `ld_qrcode_viewlog`;
CREATE TABLE IF NOT EXISTS `ld_qrcode_operatelog` ( 
    `qrcodeoperatelogid` int(19) NOT NULL auto_increment PRIMARY KEY, 
    `qrcodebasicid` int(19),
    `wechatuserid` int(19),
	`viewtime` Datetime,
	`type` Varchar(20),
	`trackid` int(19),
	`crmid` int(19)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @labelbol = 'DEADLINECANNOTEAILER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'截止日期不能小于当前日期','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The deadline cannot be earlier than the current date！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'DEADLINECANNOTEXCEED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'截止日期时间跨度不能超过30天','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The deadline time span cannot exceed 30 days！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

DELETE from ld_profileallpermission where operation = 49 and tabid = 85;
delimiter;

SET @modulename ='SalesOrder';
SET @tabid=(SELECT tabid from ld_tab where `name` = @modulename);
SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
SET @blockname = 'LBL_SHOP_INFORECEIVE';
SET @sequence = (SELECT max(sequence)+1 from ld_blocks where tabid=@tabid);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,@blockname,@sequence,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);

SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'收货信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Receiving Info' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
delimiter;

SET @modulename ='SalesOrder';
SET @tabid=(SELECT tabid from ld_tab where name = @modulename);
SET @relateid=(SELECT blockid FROM ld_blocks WHERE blocklabel='LBL_SHOP_INFORECEIVE' AND tabid=@tabid);
SET @maxseq=(SELECT IFNULL(MAX(sequence),0) FROM ld_field WHERE tabid=@tabid AND block=@relateid);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='appreceivername'; 
SET @fieldname='appreceivername'; 
SET @zh='收货人'; 
SET @en='Receiver '; 
SET @uitype=1; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='text';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL AddColumn(@tablename,@columnname,'varchar','80','');
delimiter;

SET @modulename='SalesOrder';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'appreceivername' and tabid = @tabid);
SET @maxseq=(SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='appreceivermobile'; 
SET @fieldname='appreceivermobile'; 
SET @zh='收货人联系方式'; 
SET @en='Contact information'; 
SET @uitype=1101; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='mobile';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
CALL AddColumn(@tablename,@columnname,'varchar','50','');
delimiter;

SET @modulename='SalesOrder';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'appreceivermobile' and tabid = @tabid);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='appreceiveradress'; 
SET @fieldname='appreceiveradress'; 
SET @zh='收货地址'; 
SET @en='Receiving address'; 
SET @uitype=19; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='longtextarea';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALL AddColumn(@tablename,@columnname,'text','','');
delimiter;

update ld_desk set fieldlabel = '是否显示为树节点' where languagetype='zh' and labelbol='whethertodisplayasatreenode' and labeltype='fixedstr';
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'SocialPromotion');
DELETE from ld_profileallpermission where tabid = @tabid and operation in (42,43,49,50);
delimiter;

update ld_field set quickcreate = 1 where tabid=14 and tablename='ld_products' and columnname='appsharetitle';
delimiter;

update ld_field set quickcreate = 1 where tabid=14 and tablename='ld_products' and columnname='appshareimage';
delimiter;

update ld_field set quickcreate = 1 where tabid=14 and tablename='ld_products' and columnname='apprecommendreason';
delimiter;

update ld_field set quickcreate = 1 where tabid=14 and tablename='ld_products' and columnname='originalprice';
delimiter;

update ld_field set quickcreate = 1 where tabid=22 and tablename='ld_salesorder' and columnname='appreceivername';
delimiter;

update ld_field set quickcreate = 1 where tabid=22 and tablename='ld_salesorder' and columnname='appreceivermobile';
delimiter;

update ld_field set quickcreate = 1 where tabid=22 and tablename='ld_salesorder' and columnname='appreceiveradress';
delimiter;

update ld_desk set fieldlabel = '皮肤设置' where languagetype='zh' and labelbol='menustyle' and labeltype='fixedstr';
update ld_desk set fieldlabel = 'Skin settings' where languagetype='en' and labelbol='menustyle' and labeltype='fixedstr';
delimiter;
-- 2022-02-07

CALL AddColumn('ld_related_field','picklistsql','text','','');
delimiter;

UPDATE ld_tranlabel a
LEFT JOIN ld_tab b ON b.tabid=a.Relateid AND a.trantable='ld_tab'
SET a.fieldlabel='项目日志'
WHERE b.`name`='ProjectProgress'
	AND a.languagetype='zh'
	AND NOT EXISTS (SELECT 1 FROM ld_projectprogress);
delimiter;

SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area' LIMIT 1);
SET @listvaue='市辖区';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='禅城区';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='南海区';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='顺德区';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='三水区';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='高明区';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='祖庙街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='石湾镇街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='张槎街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='桂城街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='罗村街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='大良街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='容桂街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='伦敦街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='勒流街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='西南街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='云东海街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='荷城街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area' LIMIT 1);
SET @listvaue='南庄镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='大沥镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='里水镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='西樵镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='九江镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='丹灶镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='狮山镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='北滘镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='陈村镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='乐从镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='杏坛镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='龙江镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='均安镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='白坭镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='大塘镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='乐平镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='芦苞镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='南山镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='杨和镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='更合镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='明城镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area' LIMIT 1);
SET @listvaue='东城街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='南城街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='万江街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='莞城街道';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='石碣镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='石龙镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='茶山镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='石排镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='企石镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='横沥镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='桥头镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='谢岗镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='东坑镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='常平镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='寮步镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='樟木头镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='大朗镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='黄江镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='清溪镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='塘厦镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='凤岗镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area' LIMIT 1);
SET @listvaue='大岭山镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='长安镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='虎门镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='厚街镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='沙田镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='道滘镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='洪梅镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='麻涌镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='望牛墩镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='中堂镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='高埗镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area' LIMIT 1);
SET @listvaue='板芙镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='大涌镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='东凤镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='东升镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='阜沙镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='港口镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='古镇镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='横栏镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='黄圃镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='民众镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='南朗镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='南头镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='三角镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='三乡镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='沙溪镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='神湾镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='坦洲镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);

SET @listvaue='小榄镇';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,@listvaue,(SELECT MAX(sequence)+1 FROM ld_picklist_values WHERE listid=@listid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue=@listvaue);


UPDATE ld_picklist_dependency SET targetvalues='["市辖区","禅城区","南海区","顺德区","三水区","高明区","祖庙街道","石湾镇街道","张槎街道","桂城街道","罗村街道","大良街道","容桂街道","伦敦街道","勒流街道","西南街道","云东海街道","荷城街道","南庄镇","大沥镇","里水镇","西樵镇","九江镇","丹灶镇","狮山镇","北滘镇","陈村镇","乐从镇","杏坛镇","龙江镇","均安镇","白坭镇","大塘镇","乐平镇","芦苞镇","南山镇","杨和镇","更合镇","明城镇"]' 
WHERE sourcefield='bill_city' AND targetfield='bill_area' AND sourcevalue='佛山市'
	AND targetvalues='["市辖区","禅城区","南海区","顺德区","三水区","高明区"]';

UPDATE ld_picklist_dependency SET targetvalues='["东莞市","东城街道","南城街道","万江街道","莞城街道","石碣镇","石龙镇","茶山镇","石排镇","企石镇","横沥镇","桥头镇","谢岗镇","东坑镇","常平镇","寮步镇","樟木头镇","大朗镇","黄江镇","清溪镇","塘厦镇","凤岗镇","大岭山镇","长安镇","虎门镇","厚街镇","沙田镇","道滘镇","洪梅镇","麻涌镇","望牛墩镇","中堂镇","高埗镇"]' 
WHERE sourcefield='bill_city' AND targetfield='bill_area' AND sourcevalue='东莞市'
	AND targetvalues='["东莞市"]';

UPDATE ld_picklist_dependency SET targetvalues='["中山市","板芙镇","大涌镇","东凤镇","东升镇","阜沙镇","港口镇","古镇镇","横栏镇","黄圃镇","民众镇","南朗镇","南头镇","三角镇","三乡镇","沙溪镇","神湾镇","坦洲镇","小榄镇"]' 
WHERE sourcefield='bill_city' AND targetfield='bill_area' AND sourcevalue='中山市'
	AND targetvalues='["中山市"]';
delimiter;

SET @actions='add';
SET @i=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @j=IFNULL((SELECT mAX(sequence) FROM ld_relatedlists WHERE tabid=14),0);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @i:=@i+1,14,tabid,CONCAT('get_',LOWER(`name`)),@j:=@j+1,`name`,1,@actions,'datacategory_sql',CONCAT(LOWER(`name`),'detail.productid') FROM ld_tab
WHERE `name` LIKE 'CustomForm%'
	AND tabid IN (SELECT DISTINCT tabid FROM ld_producttoolfield)
	AND tabid NOT IN (SELECT related_tabid FROM ld_relatedlists WHERE tabid=14);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;
    
UPDATE ld_blocks SET visible=1 WHERE blocklabel='LBL_LABEL' AND tabid NOT IN (6,4,102) AND NOT EXISTS (SELECT 1 FROM ld_module_tag);
-- 2022-02-11

INSERT INTO ld_relatecreatecondition(modulename,content,relatecreatemodule,sequence,contenttype)
SELECT 'CustomForm10',"ld_customform10.form10_type='中标'",'ServiceContracts',1,'sql' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatecreatecondition WHERE modulename='CustomForm10' AND relatecreatemodule='ServiceContracts')
	AND EXISTS (SELECT 1 FROM ld_version WHERE trade='construction' AND account='construction');
delimiter;    
    
update ld_tabdetailfield set allowhide = 'yes' where tabid BETWEEN 163 and 178 and columnname = 'total';
delimiter;

set @tabid = (select tabid from ld_tab where name='Accounts');
update ld_field set bigtype='translatefield' where columnname='kis_no' and tablename='ld_account'and tabid=@tabid and uitype = 1;
delimiter;

insert into ld_translatefield(columnname,column_Dbvalue,module,labelbol)
select 'kis_no','from_leads','Accounts','YES' from dual
where not exists(select 1 from ld_translatefield where columnname='kis_no' and column_Dbvalue='from_leads' and module='Accounts');
delimiter;

call addtableIndex('ld_fileoperationlog','log_crmid_idx','crmid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ScopeOfWechatappletmall','使用范围：微信小程序商城','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ScopeOfWechatappletmall' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ScopeOfWechatappletmall',"Scope of use: wechat applet mall",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ScopeOfWechatappletmall' and labeltype='fixedstr');
delimiter;
set @tabid = (select tabid from ld_tab where  `name`='WeChatUser');
update ld_tab set description='ScopeOfWechatappletmall' where tabid = @tabid and `name` = 'WeChatUser';
delimiter;


UPDATE ld_customreport_info SET report_template='default_shigongjindubiao.mrt' WHERE report_template='CustomReport_7_133.mrt' AND report_type='template_js'
 AND EXISTS (SELECT 1 FROM ld_version WHERE trade='construction' AND account='construction');
 delimiter;
 
 
DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule`;
DELIMITER ||
CREATE  PROCEDURE `account_singlerecycle_highsea_rule`(IN tmp_pool_id INT(11))
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
	and (ld_field.presence in(0,2) ) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2) 
	where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	
	select userid_after_release into @allotaccount from ld_account_public_pool where id = tmp_pool_id;
	select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;

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
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id =  ',tmp_pool_id);
		  
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
	
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);

		end if;
  
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
		

    if var_condition='or'  then
			
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ld_account.pool_id = ',tmp_pool_id);
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
    if @allotaccount>0 then 
				select  tmp.tablename into @grouptablename  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
					on ld_related_field.effect_fieldid=ld_field.fieldid
					where ld_field.uitype=1600  )  as  tmp 
					INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
					where ld_field.tabid=6 and ld_field.columnname='smownerid'
					and presence in(0,2)  GROUP BY ld_field.fieldid limit 1; 

				 select  tmp.columnname into @groupcolumnname  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
					on ld_related_field.effect_fieldid=ld_field.fieldid
					where ld_field.uitype=1600  )  as  tmp 
					INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
					where ld_field.tabid=6 and ld_field.columnname='smownerid'
					and presence in(0,2)  GROUP BY ld_field.fieldid limit 1; 
        end if;
	if var_condition='or'  then
	  
		 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		if @recycleselect<>'' and @recycleselect is not null THEN	
			set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		end if;
		set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		 if @allotaccount>0 THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
			end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;	
	ELSE

	  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
					
						if   ifnull(@groupcolumnname,'')!='' then 
					 
								select GROUP_CONCAT(groupid) into @groupid from  ld_users2group where userid =@allotaccount;
								set @TMPSQL_GroupEditSql=concat( ' update  ',@grouptablename,' inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=',@grouptablename,'.accountid ') ;
								if @grouptablename!='ld_account' then 
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' inner join ld_account on ld_account.accountid=ld_accountscf.accountid ');
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql, ' set ',@groupcolumnname,'="', @groupid,'"');
									
								end if ;
								set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
							prepare stmt1 from @TMPSQL_GroupEditSql;
							execute stmt1;
							deallocate prepare stmt1;
						end if;

end if;
  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
 end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;

		

end ||
delimiter;

SET @labelbol = 'BANGWO8ACCOUNTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未设置帮我吧账户无法启用','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'It can not be opened without bangwo8 account!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'BANGWO8SERVICEACCOUNTEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未设置帮我吧客服账户无法同步','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'It can not be opened without bangwo8 service account!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'PLEASESETMAILSERVER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请先设置邮箱服务器地址','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please set up mailserver first!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;
-- 2022-02-18

CREATE TABLE  if not EXISTS `ld_upgrade_external_userid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contactid` int(11) DEFAULT NULL,
  `upgrade` varchar(20) DEFAULT NULL,
  `upgradedatetime` datetime DEFAULT NULL,
  `external_userid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `upgrade` (`upgrade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

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

UPDATE ld_version SET old_version='V8.4.5.7',current_version='V8.4.5.7',remark='V8.4.5.7-20220218',wx_version='V8.4.5.7';
delimiter;