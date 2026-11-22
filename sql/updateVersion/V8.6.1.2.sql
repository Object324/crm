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

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','HaveSelectedWhetherReceive','您已选择{Var}条记录，是否进行领取？', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'HaveSelectedWhetherReceive' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','HaveSelectedWhetherReceive','You have selected {Var} records,whether to receive them?', 'jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'HaveSelectedWhetherReceive' AND labeltype = 'jspop' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CannotAccessedPleaseRefer','无法访问或格式不正确，请参考格式：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CannotAccessedPleaseRefer' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CannotAccessedPleaseRefer','cannot be accessed or has an incorrect format. Please refer to the format:','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CannotAccessedPleaseRefer' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CannotEnteredRepeatedly','已被其他成员账户录入，无法重复录入','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CannotEnteredRepeatedly' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CannotEnteredRepeatedly','has been entered by other member users and cannot be entered repeatedly','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CannotEnteredRepeatedly' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CurrentUsers','当前登录账号的','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CurrentUsers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CurrentUsers','The current login user`s','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CurrentUsers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','isInsufficient','不足','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='isInsufficient' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','isInsufficient','is insufficient','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='isInsufficient' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GotoUsersCheck','请前往{$Users.Users}中检查','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GotoUsersCheck' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GotoUsersCheck','Please go to {$Users.Users} to check if','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GotoUsersCheck' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','isEnteredCorrectly','是否录入正确或有值！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='isEnteredCorrectly' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','isEnteredCorrectly','is entered correctly or has a value!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='isEnteredCorrectly' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SynchronizedToCRM','会将证书对应的客户及客户相关证书同步到{$Users.Users}对应的{Var}中','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SynchronizedToCRM' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SynchronizedToCRM','The customer and customer-related certificates corresponding to the certificate are synchronized to {Var} corresponding to {$Users.Users}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SynchronizedToCRM' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReceivedFailedCustomerUpdated','领取失败，单据已存在，客户信息已更新','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReceivedFailedCustomerUpdated' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReceivedFailedCustomerUpdated','was received failed, record already exists, customer information has been updated','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReceivedFailedCustomerUpdated' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReceivedFailed','领取失败，单据已存在','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReceivedFailed' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReceivedFailed','was received failed, record already exists','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReceivedFailed' and Labeltype='fixedstr' and languagetype='en');
delimiter;

drop PROCEDURE  if EXISTS test_proce;
delimiter ||
create PROCEDURE test_proce
(
)
BEGIN
	declare var_userid int(19);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT 1 from ld_version where trade = 'zhongsiplatfrom';
	declare continue handler for not found SET done =1;	
	
	open cur1;
	Fetch cur1 into var_userid;
	loop1: while  done<>1 DO
						insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
						select 'zh','CF54massget','领取客户和证书','fixedstr' from dual
						where not exists(select 1 from ld_desk where labelbol='CF54massget' and Labeltype='fixedstr' and languagetype='zh');
						insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
						select 'en','CF54massget','Receiving customers and certificates','fixedstr' from dual
						where not exists(select 1 from ld_desk where labelbol='CF54massget' and Labeltype='fixedstr' and languagetype='en');

						set @tabid = (SELECT tabid from ld_tab WHERE name = 'CustomForm54');
						select (max(IFNULL(sequence,0))+1) into @sequence from ld_btnset where tabid = @tabid;
						select DISTINCT shownum into @shownum from ld_btnset where tabid = @tabid;
						insert into ld_btnset(tabid,buttonlabel,sequence,btnkey,shownum,createdtime)
						select @tabid,'领取客户和证书',@sequence,'CF54massget',@shownum,NOW() from dual
						where not exists(select 1 from ld_btnset where buttonlabel = '领取客户和证书' and btnkey = 'CF54massget');

						SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Users');
						SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
						SET @trantable='ld_field';
						SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @columnname='access_address'; 
						SET @fieldname='access_address'; 
						SET @zh='CRM外网访问地址'; 
						SET @en='CRM external login address'; 
						SET @uitype=17;
						SET @typeofdata='V~O';
						SET @quickcreate=0;
						SET @displaytype=1;
						SET @bigtype='url';
						SET @datarang=NULL;
						SET @maxrowsshow=0;
						SET @savedatabase = 'yes';
						SET @allowedit = 'yes';
						SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
						INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
						SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,1,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
						WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
						UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

						SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
						INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
						WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
						INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
						WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

						CALL AddColumn(@tablename,@columnname,'varchar','100','');

						SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Users');
						SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
						SET @trantable='ld_field';
						SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @columnname='receivable_total'; 
						SET @fieldname='receivable_total'; 
						SET @zh='客户领取总数'; 
						SET @en='Total customer receive amount'; 
						SET @uitype=7;
						SET @typeofdata='NN~O~50,0';
						SET @quickcreate=0;
						SET @displaytype=1;
						SET @bigtype='number';
						SET @datarang=NULL;
						SET @maxrowsshow=0;
						SET @savedatabase = 'yes';
						SET @allowedit = 'yes';
						SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
						INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
						SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit,'yes','yes','yes','yes' from dual 
						WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
						UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

						SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
						INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
						WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
						INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
						WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

						CALL AddColumn(@tablename,@columnname,'int','10','');

						SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Users');
						SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
						SET @trantable='ld_field';
						SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @columnname='receivable_remain'; 
						SET @fieldname='receivable_remain'; 
						SET @zh='客户剩余领取数'; 
						SET @en='Customer remain receive amount'; 
						SET @uitype=7;
						SET @typeofdata='NN~O~50,0';
						SET @quickcreate=0;
						SET @displaytype=2;
						SET @bigtype='number';
						SET @datarang=NULL;
						SET @maxrowsshow=0;
						SET @savedatabase = 'yes';
						SET @allowedit = 'no';
						SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
						INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
						SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit,'no','no','no','no' from dual 
						WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
						UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

						SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
						INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
						WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
						INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
						WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

						CALL AddColumn(@tablename,@columnname,'int','10','');

						SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Users');
						SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
						SET @trantable='ld_field';
						SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @columnname='receivable_haved'; 
						SET @fieldname='receivable_haved'; 
						SET @zh='客户已领取数'; 
						SET @en='Customer received quantity'; 
						SET @uitype=7;
						SET @typeofdata='NN~O~50,0';
						SET @quickcreate=0;
						SET @displaytype=2;
						SET @bigtype='number';
						SET @datarang=NULL;
						SET @maxrowsshow=0;
						SET @savedatabase = 'yes';
						SET @allowedit = 'no';
						SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
						INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
						SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit,'no','no','no','no' from dual 
						WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
						UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

						SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
						INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
						WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
						INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
						SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
						WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

						CALL AddColumn(@tablename,@columnname,'int','10','');

						SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Users');
						SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
						SET @trantable='ld_field';
						SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid LIMIT 1);
						SET @columnname='IP_Filename'; 
						SET @fieldname='IP_Filename'; 
						SET @zh='IP地址与文件路径'; 
						SET @en='IP and filename'; 
						SET @uitype=19;
						SET @typeofdata='V~O';
						SET @quickcreate=0;
						SET @displaytype=1;
						SET @bigtype='text';
						SET @datarang=NULL;
						SET @maxrowsshow=0;
						SET @savedatabase = 'no';
						SET @allowedit = 'no';
						SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
						INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
						SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,200,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit,'no','no','no','no' from dual 
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

						Fetch cur1 into var_userid;
	end while loop1;
	close cur1;
end ||
delimiter;

call test_proce();
drop PROCEDURE  if EXISTS test_proce;


update ld_desk set fieldlabel = '请从左侧拖拽简报至此处' where labelbol = 'dragmodule';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MoveRightToDisplay','拖动到右侧显示','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MoveRightToDisplay' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MoveRightToDisplay','Drag to the right to display','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MoveRightToDisplay' and Labeltype='jspop' and languagetype='en');
delimiter;

call AddColumn('ld_workflowdatalog','modifiedtime','datetime','',NULL);
ALTER TABLE ld_workflowdatalog MODIFY COLUMN modifiedtime datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
delimiter;

SET @labelbol = 'PRODUCTSENTRYFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'产品分录模块特殊字段: 产品ID:{productid}  分录行ID:{lineitem_id}  源单分录行ID:{parent_lineitem_id}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Products entry module speicial field: Products ID:{productid}  Entry line ID:{lineitem_id}  Source entry line ID:{parent_lineitem_id}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','nobusinessimportfailed','列值工商信息不存在，导入失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='nobusinessimportfailed' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','nobusinessimportfailed',' the column value business information does not exist, import failed!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='nobusinessimportfailed' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @labelbol = 'EmptyConfirm';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'建议','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Suggest','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

CALL AddColumn('ld_socialpromotionscf','sharepicture','text','0','');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='SocialPromotion');
UPDATE ld_field SET tablename='ld_socialpromotionscf' WHERE tabid=@tabid AND fieldname='sharepicture';
delimiter;

insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show)
select 112,'SalesPhaseTransformationAnalysis','chart','Potentials','Potentials','yes','yes' from dual
where not exists(select 1 from ld_stuff where stufftitle= 'SalesPhaseTransformationAnalysis' and stufftype= 'chart');
SET @labelbol = 'SalesPhaseTransformationAnalysis';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'{$Potentials.sales_stage}转化分析','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'{$Potentials.sales_stage}转化分析','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CREATE TABLE if not EXISTS `ld_homeboard_plate_setting` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`boardid` int(11) DEFAULT 0 COMMENT 'ld_homeboard表的boardid',
	`stuffid` int(11) DEFAULT 0 COMMENT 'ld_homeboard_plate_stuff表的stuffid',
	`boardstuffid` int(11) DEFAULT 0 COMMENT 'ld_homeboard_plate_stuff表的boardstuffid',
	`type` varchar(100) DEFAULT NULL COMMENT '设置的类型',
	`setvalue` varchar(255) DEFAULT '' COMMENT '设置的值',
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @labelbol = 'SalesPhaseTransformationAnalysis';
select max(wx_sequence) into @wx_sequence from ld_dashboard_app;

insert into ld_dashboard_app(`name`,labelbol,modulenames,wx_sequence,image,presence,wx_presence,home_presence,home_sequence)
select @labelbol,@labelbol,'Potentials',@wx_sequence+1,'dashboard_4',0,1,'yes',20 from dual
where not exists(select 1 from ld_dashboard_app where `name`='SalesPhaseTransformationAnalysis');
delimiter;
SET @sequence = (select max(sequence)+1 from ld_mobile_report_tab_rel);
select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='statistical';
select id into @reportid from ld_dashboard_app where name = @labelbol;
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename) select @block_id,@reportid,1,'ld_tab'
from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
delimiter;

SET @labelbol = 'Win';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'赢单','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Win','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'passthroughnums';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'经过该阶段的商机数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Pass Through Nums','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'curnums';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该阶段商机数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Current Nums','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'failnums';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'失败商机数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Fail Nums','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'successnums';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'成功商机数','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Success Nums','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'allnums';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'总数量','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Total Nums','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Conversionrate1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'转化率','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Conversion rate','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Averagetimeconsumption';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'平均耗时','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Average time consumption','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Currentstay';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前停留','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Current Stay','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Loss';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'流失','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Loss','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Lossrate';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'流失率','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Loss Rate','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Winningcycle';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'赢单周期','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Winningcycle','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'avgunitprice';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'平均客单价','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Average unit price per customer','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'wincodition';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'赢单条件','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Win Codition','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'failcodition';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'输单条件','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Fail Codition','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'PotentialTotalType';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'商机金额计算方式','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Calculation method for business opportunity amount','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '最多只能定义26个变量。' where labelbol = 'CANHAVEATMOST10VARIABLES' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Can have at most 26 variables.' where labelbol = 'CANHAVEATMOST10VARIABLES' and languagetype = 'en';
delimiter;
-- 2023-11-05

CALL addtableIndex('ld_users','pinyin_name','pinyin_name');
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

UPDATE ld_version SET old_version='V8.6.1.2',current_version='V8.6.1.2',remark='V8.6.1.2-20231106',wx_version='V8.6.1.2';
delimiter;