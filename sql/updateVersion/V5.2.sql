drop PROCEDURE if EXISTS  InsertRole2picklist;
create PROCEDURE InsertRole2picklist

(

PickName varchar(50),

RoleID varchar(50)

)

begin

declare picklistValueid int;
declare done  int  default 0;
declare sSortID int default 0;
declare rroleid varchar(50);

declare cur1 CURSOR FOR SELECT picklist_valueid FROM  test_view;
declare continue handler  for not   found  SET done =1;

set @sql=CONCAT('select picklistid into @picklistid  from LD_picklist where name=','''',PickName,'''');

prepare stmt from @sql;

execute stmt;

deallocate  prepare stmt;
set @testview=ConCAT(' drop view if exists test_view');
prepare stmt from @testview;

execute stmt;

deallocate prepare stmt;

set @sqlstr=' create view test_view as ';

set @sqlstr=CONCAT(@sqlstr,'  select  picklist_valueid from LD_',PickName);

prepare stmtt from @sqlstr;

execute stmtt;

deallocate  prepare stmtt;

OPEN cur1;

Fetch cur1 into picklistValueid;

loop1: while  done<>1 DO

         set @sql =CONCAT('select max(sortid) into  @SortID from LD_role2picklist where roleid=' ,'''',RoleID,'''',' and picklistid=',@picklistid);

         prepare stmt from @sql;

         execute stmt;

         deallocate prepare stmt;

         set sSortID=IFNULL(@SortID,0); 

         set sSortID=sSortID+1;

 

         set @strsql =CONCAT('select max( sortid) into @eroleid from  LD_role2picklist where roleid=','''',RoleID,'''','  and picklistvalueid=',picklistValueid);

 

         prepare stmtt from @strsql;

         execute stmtt;

         deallocate  prepare stmtt;

         set rroleid=IFNULL(@eroleid,'-1');

         if(rroleid='-1') then

 

                   set @insertRole =CONCAT(' insert into LD_role2PickList(roleid,picklistvalueid,picklistid,sortid)values(','''',RoleID,'''',',',picklistValueid,',',@picklistid ,',',sSortID,')');

select @insertRole;

                   prepare stmt from @insertRole;

                   execute stmt;

                   deallocate  prepare stmt;

         end if;

 

         Fetch cur1 into picklistValueid;

end while loop1;

close cur1;

end;
 
drop PROCEDURE if EXISTS  GetAllRoleIntoPicklist;
create PROCEDURE GetAllRoleIntoPicklist
(
PickName varchar(50)

)

begin

declare done  int  default 0;

declare rroleid varchar(50);

declare curw CURSOR FOR SELECT roleid FROM  LD_Role;

 

declare continue handler  for not   found  SET done =1;

OPEN curw;

Fetch curw into rroleid;

loop1: while  done<>1 DO

 

   call InsertRole2picklist(PickName,rroleid);

 

         Fetch curw into rroleid;

end while loop1;

close curw;

end;

DROP PROCEDURE if EXISTS addtabintoprofile;
create PROCEDURE addtabintoprofile
(
tabname varchar(50),
permissions int
)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  LD_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from LD_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;

	deallocate  prepare stmt;

	OPEN cur1;
	Fetch cur1 into pprofileid;

 loop1: while  done<>1 DO
		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;
		
		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
		prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

          set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

	     set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end;

CREATE TABLE if not EXISTS `ld_sendpayment` (
  `sendpaymentid` int(19) NOT NULL,
  `Actualdate` date default NULL,
  `Actualamount` decimal(25,2) default NULL,
  `vendorid` int(19) default '0',
  `Purchaseorder_id` int(19) default '0',
  `Plandate` date default NULL,
  `Amount` decimal(25,2) default NULL,
  `Sendpayment_no` varchar(100) default NULL,
  `CPPeriodtime` varchar(50) default NULL,
  `CPStatus` varchar(50) default NULL,
  PRIMARY KEY  (`sendpaymentid`),
  KEY `idx_cpstatus_sendpayment` USING BTREE (`CPStatus`),
  KEY `idx_plandate_cp_status_sendpayment` USING BTREE (`Plandate`,`CPStatus`),
  CONSTRAINT `vk_1_sendpayment_vtiger` FOREIGN KEY (`sendpaymentid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE if not EXISTS `ld_sendpaymentscf` (
  `sendpaymentid` int(19) NOT NULL,
  KEY `vk_vtiger_sendpaymentid` (`sendpaymentid`),
  CONSTRAINT `vk_vtiger_sendpaymentid` FOREIGN KEY (`sendpaymentid`) REFERENCES `ld_sendpayment` (`sendpaymentid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE if not EXISTS `ld_sendcashbill` (
  `sendcashbillid` int(19) NOT NULL,
  `vendorid` int(19) default '0',
  `sendcashbill_no` varchar(100) default NULL,
  `purchaseorder_id` int(19) default '0',
  `cashbilldate` date default NULL,
  `crpaymentmethod` varchar(50) default NULL,
  `criscashbill` varchar(10) default NULL,
  `Total` decimal(25,2) default NULL,
  `Subtotal` decimal(25,2) default NULL,
  `nosendpayment` decimal(20,2) default NULL,
  PRIMARY KEY  (`sendcashbillid`),
  KEY `idx_crpaymentmethod_sendcashbill` USING BTREE (`crpaymentmethod`),
  KEY `idx_vendorid_sendcashbill` USING BTREE (`vendorid`),
  KEY `idx_purchaseorder_sendcashbill` USING BTREE (`purchaseorder_id`),
  CONSTRAINT `vk_1_vtiger_sendCashibll` FOREIGN KEY (`sendcashbillid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE if not EXISTS `ld_sendcashbillscf` (
  `sendcashbillid` int(19) NOT NULL,
  PRIMARY KEY  (`sendcashbillid`),
  CONSTRAINT `vk_sendcashbillid_sendcashbillscf` FOREIGN KEY (`sendcashbillid`) REFERENCES `ld_sendcashbill` (`sendcashbillid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE if not EXISTS `ld_sendcashbill2payment` (
  `sendcashbillid` int(19) default '0',
  `sendpaymentid` int(19) default '0',
  `amount` decimal(25,2) default NULL,
  `Sequence` int(10) default NULL,
  `sendcashbillstatus` int(4) default NULL,
  KEY `idx_cashbillpaymentid_sendcashbill2payment` USING BTREE (`sendcashbillid`,`sendpaymentid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
/**下拉框表是否开票***/
CREATE TABLE  if not exists `ld_criscashbill`(
  `crIscashbillid` int(19) NOT NULL auto_increment,
  `crIscashbill` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`crIscashbillid`),
  UNIQUE KEY `cashbill_crischasbill_idx` (`crIscashbill`),
  KEY `criscashbill_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE  if not exists `ld_criscashbill_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;
insert into ld_criscashbill_seq (id) select 1 from dual where not exists(select 1 from ld_criscashbill_seq);
delimiter;
/**下拉框表付款方式***/
CREATE TABLE  if not exists  `ld_crpaymentmethod`(
  `crpaymentmethodid` int(19) NOT NULL auto_increment,
  `crpaymentmethod` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`crpaymentmethodid`),
  UNIQUE KEY `crperiodtime_crperiodtime_idx` (`crpaymentmethod`),
  KEY `crpaymentmethod_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE   if not exists `ld_crpaymentmethod_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;
insert into ld_crpaymentmethod_seq (id) select 1 from dual where not exists(select 1 from ld_crpaymentmethod_seq);
delimiter;

select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='crpaymentmethod');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'crpaymentmethod'  from dual where not exists(select 1 from LD_picklist where name='crpaymentmethod');
delimiter;
select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='criscashbill');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'criscashbill' from dual where not exists(select 1 from LD_picklist where name='criscashbill');
delimiter;
/**下拉框表期次***/
CREATE TABLE  if not exists `ld_cpperiodtime` (
  `cpPeriodtimeid` int(19) NOT NULL auto_increment,
  `cpPeriodtime` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`cpPeriodtimeid`),
  UNIQUE KEY `cpPeriodtime_cpPeriodtime_idx` (`cpPeriodtime`),
  KEY `cpPeriodtime_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE   if not exists `ld_cpperiodtime_seq`(
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into `ld_cpperiodtime_seq`  (id) select 1 from dual where not exists(select 1 from `ld_cpperiodtime_seq` );
delimiter;
/**下拉框表状态***/
CREATE TABLE  if not exists `ld_cpstatus`  (
  `cpstatusid` int(19) NOT NULL auto_increment,
  `cpstatus` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`cpstatusid`),
  UNIQUE KEY `cpstatus_cpstatus_idx` (`cpstatus`),
  KEY `cpstatus_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE  if not exists `ld_cpstatus_seq`  (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into `ld_cpstatus_seq`  (id) select 1 from dual where not exists(select 1 from `ld_cpstatus_seq` );
delimiter;

/***下拉框期次内容***/
select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='cpperiodtime');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'cpperiodtime'  from dual where not exists(select 1 from LD_picklist where name='cpperiodtime');
delimiter;
select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='cpstatus');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'cpstatus' from dual where not exists(select 1 from LD_picklist where name='cpstatus');
delimiter;

select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='1');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='1');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'1',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='1');
delimiter;

select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='2');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='2');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'2',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='2');
delimiter;
select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='3');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='3');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'3',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='3');
delimiter;

select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='4');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='4');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'4',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='4');
delimiter;

select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='5');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='5');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'5',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='5');
delimiter;

select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='6');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='6');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'6',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='6');
delimiter;
select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='7');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='7');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'7',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='7');
delimiter;

select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='8');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='8');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'8',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='8');
delimiter;


select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='9');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='9');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'9',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='9');
delimiter;

select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='10');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='10');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'10',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='10');
delimiter;
select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='11');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='11');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'11',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='11');
delimiter;

select  id into @seqmaxid from ld_cpperiodtime_seq ;
update ld_cpperiodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='12');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpperiodtime where cpperiodtime='12');
INSERT INTO `ld_cpperiodtime` (cpperiodtimeid,cpperiodtime,picklist_valueid) select  @seqmaxid+1,'12',@maxid+1 from dual where not exists(select 1 from LD_cpperiodtime where cpperiodtime='12');
delimiter;
/**下拉框状态内容***/
select  id into @seqmaxid from ld_cpstatus_seq ;
update ld_cpstatus_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpstatus where cpstatus='未付');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpstatus where cpstatus='未付');
INSERT INTO `ld_cpstatus` (cpstatusid,cpstatus,picklist_valueid,presence) select  @seqmaxid+1,'未付',@maxid+1,0 from dual where not exists(select 1 from LD_cpstatus where cpstatus='未付');
delimiter;

select  id into @seqmaxid from ld_cpstatus_seq ;
update ld_cpstatus_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpstatus where cpstatus='部分已付');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpstatus where cpstatus='部分已付');
INSERT INTO `ld_cpstatus` (cpstatusid,cpstatus,picklist_valueid,presence) select  @seqmaxid+1,'部分已付',@maxid+1,0 from dual where not exists(select 1 from LD_cpstatus where cpstatus='部分已付');
delimiter;

select  id into @seqmaxid from ld_cpstatus_seq ;
update ld_cpstatus_seq set id=@seqmaxid+2 where not exists(select 1 from ld_cpstatus where cpstatus='已付');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_cpstatus where cpstatus='已付');
INSERT INTO `ld_cpstatus` (cpstatusid,cpstatus,picklist_valueid,presence) select  @seqmaxid+1,'已付',@maxid+1,0 from dual where not exists(select 1 from LD_cpstatus where cpstatus='已付');
delimiter;
/***下拉框角色权限(期次和状态***/
call GetAllRoleIntoPicklist('cpperiodtime');
delimiter;
call GetAllRoleIntoPicklist('cpstatus');
delimiter;

select  id into @seqmaxid from ld_crpaymentmethod_seq ;
update ld_crpaymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='现金');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='现金');
INSERT INTO `ld_crpaymentmethod` (crpaymentmethodid,crpaymentmethod,picklist_valueid) select  @seqmaxid+1,'现金',@maxid+1 from dual where not exists(select 1 from LD_crpaymentmethod where crpaymentmethod='现金');
delimiter;

select  id into @seqmaxid from ld_crpaymentmethod_seq ;
update ld_crpaymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='支票');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='支票');
INSERT INTO `ld_crpaymentmethod` (crpaymentmethodid,crpaymentmethod,picklist_valueid) select  @seqmaxid+1,'支票',@maxid+1 from dual where not exists(select 1 from LD_crpaymentmethod where crpaymentmethod='支票');
delimiter;


select  id into @seqmaxid from ld_crpaymentmethod_seq ;
update ld_crpaymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='电汇');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='电汇');
INSERT INTO `ld_crpaymentmethod` (crpaymentmethodid,crpaymentmethod,picklist_valueid) select  @seqmaxid+1,'电汇',@maxid+1 from dual where not exists(select 1 from LD_crpaymentmethod where crpaymentmethod='电汇');
delimiter;

select  id into @seqmaxid from ld_crpaymentmethod_seq ;
update ld_crpaymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='邮政汇款');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='邮政汇款');
INSERT INTO `ld_crpaymentmethod` (crpaymentmethodid,crpaymentmethod,picklist_valueid) select  @seqmaxid+1,'邮政汇款',@maxid+1 from dual where not exists(select 1 from LD_crpaymentmethod where crpaymentmethod='邮政汇款');
delimiter;

select  id into @seqmaxid from ld_crpaymentmethod_seq ;
update ld_crpaymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='网上银行');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='网上银行');
INSERT INTO `ld_crpaymentmethod` (crpaymentmethodid,crpaymentmethod,picklist_valueid) select  @seqmaxid+1,'网上银行',@maxid+1 from dual where not exists(select 1 from LD_crpaymentmethod where crpaymentmethod='网上银行');
delimiter;

select  id into @seqmaxid from ld_crpaymentmethod_seq ;
update ld_crpaymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_crpaymentmethod where crpaymentmethod='其他');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='其他');
INSERT INTO `ld_crpaymentmethod` (crpaymentmethodid,crpaymentmethod,picklist_valueid) select  @seqmaxid+1,'其他',@maxid+1 from dual where not exists(select 1 from LD_crpaymentmethod where crpaymentmethod='其他');
delimiter;

select  id into @seqmaxid from ld_criscashbill_seq ;
update ld_criscashbill_seq set id=@seqmaxid+2 where not exists(select 1 from ld_criscashbill where criscashbill='未开');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_criscashbill where criscashbill='未开');
INSERT INTO `ld_criscashbill` (criscashbillid,criscashbill,picklist_valueid) select  @seqmaxid+1,'未开',@maxid+1 from dual where not exists(select 1 from LD_criscashbill where criscashbill='未开');
delimiter;

select  id into @seqmaxid from ld_criscashbill_seq ;
update ld_criscashbill_seq set id=@seqmaxid+2 where not exists(select 1 from ld_criscashbill where criscashbill='已开');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_criscashbill where criscashbill='已开');
INSERT INTO `ld_criscashbill` (criscashbillid,criscashbill,picklist_valueid) select  @seqmaxid+1,'已开',@maxid+1 from dual where not exists(select 1 from LD_criscashbill where criscashbill='已开');
delimiter;

/***下拉框角色权限(付款方式和是否开票)***/
call GetAllRoleIntoPicklist('crpaymentmethod');
delimiter;
call GetAllRoleIntoPicklist('criscashbill');
delimiter;
/***添加付款计划子菜单（模块)***/
select max(tabid) into @maxid from  lD_tab  ;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,version,parent,printtab)
select @maxid+1 ,'SendPayment',0,70,'SendPayment',0,0,1,'5.0','Finacial',1  from dual where not exists(select 1 from LD_tab where name='SendPayment');

select tabid into @tabid from ld_tab where name='SendPayment';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'SendPayment','付款计划','付款计划' from dual 
where not EXISTS(select 1 from ld_languagepackage where tabid=@tabid);

select parenttabid into @parentid from ld_parenttab where parenttab_label='Finacial';
insert into LD_parenttabrel (parenttabid,tabid,sequence) select @parentid ,@tabid,3 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@tabid);
 
delimiter;
/***添加付款单子菜单（模块)***/
select max(tabid) into @maxid from  lD_tab  ;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,version,parent,printtab)
select @maxid+1 ,'SendCashBill',0,70,'SendCashBill',0,0,1,'5.0','Finacial',1  from dual where not exists(select 1 from LD_tab where name='SendCashBill');

select tabid into @tabid from ld_tab where name='SendCashBill';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'SendCashBill','付款单','付款单' from dual 
where not EXISTS(select 1 from ld_languagepackage where tabid=@tabid);

select parenttabid into @parentid from ld_parenttab where parenttab_label='Finacial';
insert into LD_parenttabrel (parenttabid,tabid,sequence) select @parentid ,@tabid,5 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@tabid);
delimiter;
/**调整子菜单顺序***/
update ld_parenttabrel set sequence=2 where tabid in(select tabid from ld_tab where name='paymentplan');
update ld_parenttabrel set sequence=5 where tabid in(select tabid from ld_tab where name='sendpayment');
update ld_parenttabrel set sequence=8 where tabid in(select tabid from ld_tab where name='invoice');
update ld_parenttabrel set sequence=11 where tabid in(select tabid from ld_tab where name='CashBill');
update ld_parenttabrel set sequence=14 where tabid in(select tabid from ld_tab where name='SendCashBill');
update ld_parenttabrel set sequence=17 where tabid in(select tabid from ld_tab where name='Expense');
delimiter;
/**付款计划和付款单模块权限**/
call addtabintoprofile('SendPayment',1);
call addtabintoprofile('SendCashBill',1);
/**付款计划共享规则**/
select tabid into @tabid from LD_tab where name='SendPayment' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;

update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

delimiter;
/**付款单共享规则***/
select tabid into @tabid from LD_tab where name='SendCashBill' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;

update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

delimiter;
/**付款计划区块**/
select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='SendPayment';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_SendPayment_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_SendPayment_INFORMATION');
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+2,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;
/**付款单区块**/
select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='SendCashBill';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_SendCashBill_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_SendCashBill_INFORMATION');
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+2,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;

select tabid into @tabid from LD_tab where name='sendpayment';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_SendPayment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='vendorid'  and tablename='ld_sendPayment' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'vendorid','LD_sendpayment',1,81,'vendor_id','供应商名称',1,0,'',100,2,@sendpaymentid,1,'I~M',3,'','',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='vendorid'  and tablename='ld_sendpayment' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='sendpayment_no'  and tablename='ld_sendpayment' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'sendpayment_no','LD_sendpayment',1,4,'sendpayment_no','SendPayment No',1,0,'',100,4,@sendpaymentid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='sendpayment_no'  and tablename='ld_sendpayment' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='purchaseorder_id'  and tablename='ld_sendPayment' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'purchaseorder_id','LD_sendpayment',1,150,'purchaseorder_id','采购订单',1,0,'',100,7,@sendpaymentid,1,'I~O',3,'','',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='purchaseorder_id'  and tablename='ld_sendpayment' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','采购负责人',1,0,'',100,8,@sendpaymentid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='plandate'  and tablename='LD_sendpayment' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'plandate','LD_sendpayment',1,5,'plandate','plandate',1,2,'',100,11,@sendpaymentid,1,'D~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='plandate'  and tablename='LD_sendpayment' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='cpperiodtime'  and tablename='LD_sendpayment' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'cpperiodtime','LD_sendpayment',1,15,'cpperiodtime','cpperiodtime',1,2,'1',100,13,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='cpperiodtime'  and tablename='LD_sendpayment' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='amount'  and tablename='LD_sendpayment' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'amount','LD_sendpayment',1,71,'amount','amount',1,2,'0.00',100,15,@sendpaymentid,1,'N~M',2,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='amount'  and tablename='LD_sendpayment' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='cpstatus'  and tablename='LD_sendpayment' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'cpstatus','LD_sendpayment',1,15,'cpstatus','cpstatus',1,2,'未付',100,16,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='cpstatus'  and tablename='LD_sendpayment' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='actualdate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'actualdate','LD_sendpayment',1,5,'actualdate','实际付款时间',1,0,'',100,21,@sendpaymentid,2,'D~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='actualdate'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='actualamount'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'actualamount','LD_sendpayment',1,71,'actualamount','已付金额',1,0,'',100,25,@sendpaymentid,2,'N~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='actualamount'  and tabid=@tabid ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','修改时间',1,0,'',100,28,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','Created Time',1,0,'',100,31,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedby','LD_crmentity',1,52,'modifiedby','最新更新人',1,0,'',100,34,@sendpaymentid,3,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedby');

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'smcreatorid','创建人',1,0,'',100,37,@sendpaymentid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;

delimiter;


select tabid into @tabid from LD_tab where name='sendpayment';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','LD_crmentity',1,19,'description','Description',1,2,'',100,1,@sendpaymentid,1,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid ) ;
delimiter;
/*-----付款单界面字段-------------------*/
select tabid into @tabid from LD_tab where name='sendcashbill';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_SendCashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='vendorid'  and tablename='ld_sendcashbill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'vendorid','LD_sendcashbill',1,81,'vendor_id','供应商名称',1,0,'',100,2,@sendpaymentid,1,'I~M',3,'','',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='vendorid'  and tablename='ld_sendcashbill' ) ;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='sendcashbill_no'  and tablename='ld_sendcashbill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'sendcashbill_no','LD_sendcashbill',1,4,'sendcashbill_no','SendCashBill No',1,0,'',100,4,@sendpaymentid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='sendcashbill_no'  and tablename='ld_sendcashbill' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='purchaseorder_id'  and tablename='ld_sendcashbill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'purchaseorder_id','LD_sendcashbill',1,150,'purchaseorder_id','采购订单',1,0,'',100,7,@sendpaymentid,1,'I~O',3,'','',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='purchaseorder_id'  and tablename='ld_sendcashbill' ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','采购负责人',1,0,'',100,8,@sendpaymentid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='cashbilldate'  and tablename='LD_sendcashbill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'cashbilldate','LD_sendcashbill',1,5,'cashbilldate','cashbilldate',1,2,'',100,11,@sendpaymentid,1,'D~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='cashbilldate'  and tablename='LD_sendcashbill' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='crpaymentmethod'  and tablename='LD_sendcashbill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'crpaymentmethod','LD_sendcashbill',1,15,'crpaymentmethod','crpaymentmethod',1,2,'现金',100,16,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='crpaymentmethod'  and tablename='LD_sendcashbill' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='criscashbill'  and tablename='criscashbill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'criscashbill','LD_sendcashbill',1,15,'criscashbill','criscashbill',1,2,'未开',100,19,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='criscashbill'  and tablename='LD_sendcashbill' ) ;
select max(fieldid) into @maxfieldid  from ld_field ;

update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='total'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'total','LD_sendcashbill',1,222,'hdnGrandTotal','合计',1,0,'',100,21,@sendpaymentid,2,'N~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='total'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','修改时间',1,0,'',100,28,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','Created Time',1,0,'',100,31,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedby','LD_crmentity',1,52,'modifiedby','最新更新人',1,0,'',100,34,@sendpaymentid,3,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedby');

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'smcreatorid','创建人',1,0,'',100,37,@sendpaymentid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;


select tabid into @tabid from LD_tab where name='sendcashbill';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','LD_crmentity',1,19,'description','Description',1,2,'',100,1,@sendpaymentid,1,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid ) ;
delimiter;


/*---付款计划和付款单编号格式----*/

select id into @maxid from LD_modentity_num_seq ;
update LD_modentity_num_seq set id=@maxid+1 where  not exists(select 1 from LD_modentity_num where  semodule='SendPayment');
insert into LD_modentity_num (num_id,semodule,prefix,start_id,cur_id,active)
select @maxid+1,'SendPayment','CP',1,1,1 from dual  where  not exists(select 1 from LD_modentity_num where  semodule='SendPayment');

select id into @maxid from LD_modentity_num_seq ;
update LD_modentity_num_seq set id=@maxid+1 where  not exists(select 1 from LD_modentity_num where  semodule='SendCashBill');
insert into LD_modentity_num (num_id,semodule,prefix,start_id,cur_id,active)
select @maxid+1,'SendCashBill','CR',1,1,1 from dual  where  not exists(select 1 from LD_modentity_num where  semodule='SendCashBill');

delimiter;
/*---付款计划数据分类(叙事簿)---*/

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='sendpayment');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'SendPayment',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='sendpayment');
delimiter;
select cvid into @cvid from LD_customview where viewname='All' and entitytype='sendpayment';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_Sendpayment_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment_cpperiodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_sendpayment:amount:amount:SendPayment_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:amount:amount:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:plandate:plandate:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_sendpayment:cpstatus:cpstatus:SendPayment_plandate:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpstatus:cpstatus:SendPayment%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_sendpayment:vendorid:vendor_id:SendPayment_vendorid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:vendorid:vendor_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment_purchaseorderid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SendPayment_Assigned_To:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SendPayment%');
delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='未付' and entitytype='sendpayment');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'未付',    0, 0, 'SendPayment',1,1,3 from dual where not exists(select 1 from LD_customview where viewname='未付' and entitytype='sendpayment');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未付' and entitytype='sendpayment';
delete from LD_cvcolumnlist where cvid=@cvid;

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_Sendpayment_No:V' from dual 
where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment_cpperiodtime:V' from dual 
where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_sendpayment:amount:amount:SendPayment_amount:N' from dual 
where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:amount:amount:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D' from dual 
where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:plandate:plandate:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_sendpayment:cpstatus:cpstatus:SendPayment_plandate:V' from dual 
where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpstatus:cpstatus:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_sendpayment:vendorid:vendor_id:SendPayment_vendorid:V' from dual 
where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:vendorid:vendor_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment_purchaseorderid:V' from dual 
where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SendPayment_Assigned_To:V' from dual 
where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SendPayment%');

delete from LD_cvadvfilter where cvid=@cvid;
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_sendpayment:cpstatus:cpstatus:SendPayment_cpstatus:V' ,'e','未付',1,'' from dual
where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_sendpayment:cpstatus:cpstatus%');

delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='已付' and entitytype='sendpayment');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'已付',    0, 0, 'SendPayment',1,1,6 from dual where not exists(select 1 from LD_customview where viewname='已付' and entitytype='sendpayment');
delimiter;
select cvid into @cvid from LD_customview where viewname='已付' and entitytype='sendpayment';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_Sendpayment_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment_cpperiodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_sendpayment:amount:amount:SendPayment_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:amount:amount:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:plandate:plandate:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_sendpayment:cpstatus:cpstatus:SendPayment_plandate:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpstatus:cpstatus:SendPayment%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_sendpayment:vendorid:vendor_id:SendPayment_vendorid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:vendorid:vendor_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment_purchaseorderid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SendPayment_Assigned_To:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SendPayment%');

delete from LD_cvadvfilter where cvid=@cvid;
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_sendpayment:cpstatus:cpstatus:SendPayment_cpstatus:V' ,'e','已付',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_sendpayment:cpstatus:cpstatus%');

delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='部分已付' and entitytype='sendpayment');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'部分已付',    0, 0, 'SendPayment',1,1,9 from dual where not exists(select 1 from LD_customview where viewname='部分已付' and entitytype='sendpayment');
delimiter;

select cvid into @cvid   from LD_customview where viewname='部分已付';
delete from LD_cvcolumnlist where cvid=@cvid;

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_Sendpayment_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment_cpperiodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_sendpayment:amount:amount:SendPayment_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:amount:amount:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:plandate:plandate:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_sendpayment:cpstatus:cpstatus:SendPayment_plandate:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpstatus:cpstatus:SendPayment%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_sendpayment:vendorid:vendor_id:SendPayment_vendorid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:vendorid:vendor_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment_purchaseorderid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SendPayment_Assigned_To:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SendPayment%');

delete from LD_cvadvfilter where cvid=@cvid;
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_sendpayment:cpstatus:cpstatus:SendPayment_cpstatus:V' ,'e','部分已付',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_sendpayment:cpstatus:cpstatus%');

delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='本月应付' and entitytype='sendpayment');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'本月应付',    0, 0, 'SendPayment',1,1,9 from dual where not exists(select 1 from LD_customview where viewname='本月应付' and entitytype='sendpayment');
delimiter;

select cvid into @cvid from LD_customview where viewname='本月应付';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_Sendpayment_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment_cpperiodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_sendpayment:amount:amount:SendPayment_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:amount:amount:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:plandate:plandate:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_sendpayment:cpstatus:cpstatus:SendPayment_plandate:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpstatus:cpstatus:SendPayment%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_sendpayment:vendorid:vendor_id:SendPayment_vendorid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:vendorid:vendor_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment_purchaseorderid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SendPayment_Assigned_To:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SendPayment%');

delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) select @cvid,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D' ,'thismonth','2013-05-01','2013-05-31' from dual
 where not exists( select 1 from ld_cvstdfilter  where cvid=@cvid and  columnname like '%LD_SendPayment:plandate:plandate%');
delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='本月已付' and entitytype='sendpayment');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'本月已付',    0, 0, 'SendPayment',1,1,9 from dual where not exists(select 1 from LD_customview where viewname='本月已付' and entitytype='sendpayment');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月已付';
delete from LD_cvcolumnlist where cvid=@cvid;

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_Sendpayment_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment_cpperiodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpperiodtime:cpperiodtime:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_sendpayment:amount:amount:SendPayment_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:amount:amount:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:plandate:plandate:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_sendpayment:cpstatus:cpstatus:SendPayment_plandate:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:cpstatus:cpstatus:SendPayment%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_sendpayment:vendorid:vendor_id:SendPayment_vendorid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:vendorid:vendor_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment_purchaseorderid:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SendPayment_Assigned_To:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SendPayment%');

delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) select @cvid,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D' ,'thismonth','2013-05-01','2013-05-31' from dual
 where not exists( select 1 from ld_cvstdfilter  where cvid=@cvid and  columnname like '%LD_SendPayment:plandate:plandate%');

insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_sendpayment:cpstatus:cpstatus:SendPayment_cpstatus:V' ,'e','已付',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_sendpayment:cpstatus:cpstatus%');

delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;
/***付款单数据分类（叙事簿)****/

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='SendCashBill');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'SendCashBill',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='SendCashBill');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='sendcashbill';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_sendcashbill:sendcashbill_no:sendcashbill_no:SendCashBill_收款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendcashbill:sendcashbill_no:sendcashbill_no%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_sendcashbill:total:hdnGrandTotal:SendCashBill_Total:N' 

 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendcashbill:total:hdnGrandTota%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_sendcashbill:cashbilldate:cashbilldate:SendCashBill_收款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendcashbill:cashbilldate:cashbilldate%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_sendcashbill:criscashbill:criscashbill:SendCashBill_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendcashbill:criscashbill:criscashbill%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_sendcashbill:crpaymentmethod:crpaymentmethod:SendCashBill_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendcashbill:crpaymentmethod:crpaymentmethod%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_sendcashbill:vendorid:vendor_id:SendCashBill_供应商名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendcashbill:vendorid:vendor_id%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_sendcashbill:purchaseorder_id:purchaseorder_id:SendCashBill_采购订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_sendcashbill:purchaseorder_id:purchaseorder_id%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SendCashBill_采购负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;


select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'SendPayment','include/Webservices/VtigerModuleOperation.php','VtigerModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='SendPayment');

select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'SendCashBill','include/Webservices/VtigerModuleOperation.php','VtigerModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='SendCashBill');
delimiter;

select  tabid into @tabid from LD_tab where name='sendpayment';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'SendPayment','LD_SendPayment','sendpayment_no','sendpaymentid','sendpayment_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);

select  tabid into @tabid from LD_tab where name='sendcashbill';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'SendCashBill','LD_SendCashBill','sencashbill_no','sendcashbillid','sendcashbill_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);

delimiter;

/**字段权限**/
call getallprofile('SendPayment');
call fieldprofile('SendPayment');
call getallprofile('SendCashBill');
call fieldprofile('SendCashBill');
delimiter;

/**付款计划更多信息****/
select tabid into @tabid from ld_tab WHERE name='sendpayment';
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='sendpayment_no';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,1,1,1 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='cpperiodtime';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='amount';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='plandate';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='vendorid';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='purchaseorder_id';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,7,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='smownerid' limit 1;
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,8,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
/**付款单更多信息字段****/
select tabid into @tabid from ld_tab WHERE name='sendcashbill';
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='sendcashbill_no';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,1,1,1 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='total';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='cashbilldate';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='criscashbill';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='crpaymentmethod';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='vendorid';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='purchaseorder_id';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,7,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='smownerid' limit 1;
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,8,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

delimiter;
/**更多信息函数**/

select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='SendCashBill';
select tabid into @tabid from LD_tab where name='Sendpayment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_sendcashbill'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_sendcashbill',1,'SendCashBill',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_sendcashbill' and tabid=@tabid);
delimiter;


select tabid into @tabid from LD_tab where name='Vendors';

select tabid into @relatedtabid from ld_tab where name='SendCashBill';
select id into @id from lD_RelatedLists_seq;
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_sendcashbill'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_sendcashbill',3,'SendCashBill',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_sendcashbill' and tabid=@tabid);


select tabid into @relatedtabid from ld_tab where name='SendPayment';
select id into @id from lD_RelatedLists_seq;
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_sendpayment'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_sendpayment',1,'SendPayment',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_sendpayment' and tabid=@tabid);

delimiter;
/**付款计划和付款单日志***/
select max(linkid) into @maxLinkid from LD_links;
update LD_links_seq set id=@maxLinkid +1;
select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='SendCashBill' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWBASIC','View History','javascript:ModTrackerCommon.showhistory(''$RECORD$'')','themes/images/pointer.gif',1,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
delimiter;

select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='SendPayment' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWBASIC','View History','javascript:ModTrackerCommon.showhistory(''$RECORD$'')','themes/images/pointer.gif',1,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
delimiter;


select tabid into @tabid from LD_tab where name='sendpayment';
insert into LD_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not exists(select 1 from LD_modtracker_tabs where tabid=@tabid);
delimiter;

select tabid into @tabid from LD_tab where name='sendcashbill';
insert into LD_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not exists(select 1 from LD_modtracker_tabs where tabid=@tabid);
delimiter;


insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,20,'在采购订单模块创建付款计划时是否控制付款计划总额必须等于订单金额' from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=20);


-- add 2014-01-11 by luyx
select max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions)
select @relation_id+1,22,13,'get_tickets',2,'HelpDesk',1,'add,select' 
from dual where not exists (select 1 from ld_relatedlists where tabid=22 and related_tabid=13);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;

update ld_relatedlists set actions='add,select' where tabid=22 and related_tabid=13;


delete from ld_relatedlists_lable where tabid=22 and fieldid not in (170,155,162,161,156);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 13,170,0,4,1,1 
from dual where not exists (select 1 from ld_relatedlists_lable where tabid=13 and fieldid=170);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 13,155,0,6,1,0 
from dual where not exists (select 1 from ld_relatedlists_lable where tabid=13 and fieldid=155);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 13,162,0,7,1,0 
from dual where not exists (select 1 from ld_relatedlists_lable where tabid=13 and fieldid=162);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 13,161,0,8,1,0 
from dual where not exists (select 1 from ld_relatedlists_lable where tabid=13 and fieldid=161);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 13,156,0,9,1,0 
from dual where not exists (select 1 from ld_relatedlists_lable where tabid=13 and fieldid=156);

update ld_relatedlists_lable set sequence=1,edit=1 where tabid=13 and fieldid=170;
update ld_relatedlists_lable set sequence=2,edit=0 where tabid=13 and fieldid=155;
update ld_relatedlists_lable set sequence=3,edit=0 where tabid=13 and fieldid=162;
update ld_relatedlists_lable set sequence=4,edit=0 where tabid=13 and fieldid=161;
update ld_relatedlists_lable set sequence=5,edit=0 where tabid=13 and fieldid=156;
delete from ld_field where tabid=2 and columnname='related_to';

CREATE TABLE if not EXISTS`ld_templateprint2user` (
  `templateprintid` int(19) NOT NULL,
  `userid` int(19) NOT NULL,
  KEY `idx_templateprintid_templateprint2user` USING BTREE (`templateprintid`),
  KEY `dx_userid_templateprint2user` USING BTREE (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO ld_systems_deploy (deploy_value,deploy_type,description) 
select 0,21,'确认出库时是否发送短信通知客户。1:是，0:否'
FROM DUAL WHERE NOT EXISTS(select 1 from ld_systems_deploy where deploy_type =21);
delimiter;

update ld_relatedlists set actions='add' where tabid=22 and related_tabid='add';
/*合同订单增加联系记录*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='SalesOrder';
select tabid into @relatedtabid from ld_tab where name='ContactRecords';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_contactRecords' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_contactRecords',28,'ContactRecords',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_contactRecords' and tabid=@tabid);
delimiter;

/*项目增加联系记录*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Project';
select tabid into @relatedtabid from ld_tab where name='ContactRecords';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_contactRecords' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_contactRecords',10,'ContactRecords',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_contactRecords' and tabid=@tabid);
delimiter;


/*项目任务增加联系记录*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='ProjectTask';
select tabid into @relatedtabid from ld_tab where name='ContactRecords';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_contactRecords' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_contactRecords',10,'ContactRecords',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_contactRecords' and tabid=@tabid);
delimiter;

/*服务单增加联系记录*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='HelpDesk';
select tabid into @relatedtabid from ld_tab where name='ContactRecords';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_contactRecords' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_contactRecords',10,'ContactRecords',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_contactRecords' and tabid=@tabid);
delimiter;


/*************************************/
/*俩系记录增加服务单，合同订单，项目，项目任务 字段*/
/*联系记录新增合同订单字段*/
call addcolumn('LD_contactrecords','salesorderid','int','11',null);
delimiter;
/*字段 表插入新字段*/
select tabid into @tabid from LD_tab where name='ContactRecords';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_CUSTOM_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesorderid','LD_contactrecords',1,80,'salesorder_id','合同订单',1,2,'',100,11,@paymentplanid,1,'I~O',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tabid=@tabid ) ;
delimiter;
/*联系记录增加服务单字段*/
call addcolumn('LD_contactrecords','troubleticketid','int','11',null);
delimiter;
/*字段 表插入新字段*/
select tabid into @tabid from LD_tab where name='ContactRecords';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_CUSTOM_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='troubleticketid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'troubleticketid','LD_contactrecords',1,240,'troubleticketid','服务单',1,2,'',100,11,@paymentplanid,1,'I~O',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='troubleticketid'  and tabid=@tabid ) ;
delimiter;
/*联系记录增加项目字段*/
call addcolumn('LD_contactrecords','projectid','int','11',null);
delimiter;
/*字段 表插入新字段*/
select tabid into @tabid from LD_tab where name='ContactRecords';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_CUSTOM_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='projectid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'projectid','LD_contactrecords',1,10,'projectid','项目',1,2,'',100,11,@paymentplanid,1,'I~O',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='projectid'  and tabid=@tabid ) ;
/*select fieldid into @fieldid where tabid=55 and  fieldname='projectid';*/
/*这里特殊控制，要插入下面数据才正常*/
insert into LD_fieldmodulerel(fieldid,module,relmodule,`status`) select @maxfieldid+1,'ContactRecords','Project',0 from dual where not exists (select 1 from LD_fieldmodulerel where module='ContactRecords' and relmodule = 'Project');
delimiter;
/**联系记录新增字段项目任务字段*/
call addcolumn('LD_contactrecords','projecttaskid','int','11',null);
delimiter;
/*字段 表插入新字段*/
select tabid into @tabid from LD_tab where name='ContactRecords';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_CUSTOM_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='projecttaskid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'projecttaskid','LD_contactrecords',1,241,'projecttaskid','项目任务',1,2,'',100,11,@paymentplanid,1,'I~O',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='projecttaskid'  and tabid=@tabid ) ;
delimiter;

call fieldprofile('ContactRecords');
call getallprofile('ContactRecords');
delimiter;

call fieldprofile('Attachment');
call getallprofile('Attachment');
delimiter;

call fieldprofile('Accounts');
call getallprofile('Accounts');
delimiter;

-- add 2014-01-13 by li
CREATE TABLE if not EXISTS `ld_vendorcontacts` (
  `vendorcontactsid` int(19) NOT NULL auto_increment,
  `salutation` varchar(20) NOT NULL,
  `Firstname` varchar(50) default NULL,
  `Lastname` varchar(50) default '',
  `Vendorid` int(19) default '0',
  `department` varchar(80) default NULL,
  `title` varchar(100) default NULL,
  `Officephone` varchar(50) default NULL,
  `mobile` varchar(50) default NULL,
  `homephone` varchar(50) default NULL,
  `Fax` varchar(50) default NULL,
  `email` varchar(100) default NULL,
  `qq` varchar(50) default NULL,
  `birthday` date default NULL,
  `vendorcontact_no` varchar(100) default NULL,
  PRIMARY KEY  (`vendorcontactsid`),
  KEY `idx_vendorid_vendorcontacts` USING BTREE (`Vendorid`),
  CONSTRAINT `vk_1_vtiger_vendorcontacts` FOREIGN KEY (`vendorcontactsid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  if not EXISTS `ld_vendorcontactscf` (
  `vendorcontactsid` int(19) NOT NULL,
  PRIMARY KEY  (`vendorcontactsid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;

/***添加供应商联系人子菜单（模块)***/
select max(tabid) into @maxid from  lD_tab  ;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,version,parent,printtab)
select @maxid+1 ,'VendorContact',0,70,'VendorContact',0,0,1,'5.0','Purchase',1  from dual where not exists(select 1 from LD_tab where name='VendorContact');

select tabid into @tabid from ld_tab where name='VendorContact';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'VendorContact','供应商联系人','供应商联系人' from dual 
where not EXISTS(select 1 from ld_languagepackage where tabid=@tabid);

select parenttabid into @parentid from ld_parenttab where parenttab_label='Purchase';
insert into LD_parenttabrel (parenttabid,tabid,sequence) select @parentid ,@tabid,3 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@tabid);
 
delimiter;

call addtabintoprofile('VendorContact',1);


select tabid into @tabid from LD_tab where name='VendorContact' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;

update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

delimiter;


call getallprofile('VendorContact');
call fieldprofile('VendorContact');
delimiter;



/**供应商联系人区块**/
select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='VendorContact';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_VendorContact_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_VendorContact_INFORMATION');
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+2,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;



select tabid into @tabid from LD_tab where name='VendorContact';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_VendorContact_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='lastname'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'lastname','LD_vendorcontacts',1,1,'lastname','姓名',1,0,'',100,2,@sendpaymentid,1,'I~M',3,'','',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='lastname'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='vendorcontact_no'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'vendorcontact_no','LD_vendorcontacts',1,4,'vendorcontact_no','Vendorcontact No',1,0,'',100,4,@sendpaymentid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='vendorcontact_no'  and tablename='LD_vendorcontacts' ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salutation'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salutation','LD_vendorcontacts',1,55,'salutationtype','称谓',1,0,'',100,5,@sendpaymentid,3,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='salutation'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='firstname'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'firstname','LD_vendorcontacts',1,55,'firstname','英文名',1,0,'',100,6,@sendpaymentid,1,'V~O',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='firstname'  and tablename='LD_vendorcontacts' ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='Vendorid'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'vendorid','LD_vendorcontacts',1,81,'vendor_id','供应商',1,0,'',100,7,@sendpaymentid,1,'I~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='vendorid'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='department'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'department','LD_vendorcontacts',1,1,'department','部门',1,0,'',100,8,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='department'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='title'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'title','LD_vendorcontacts',1,1,'title','职务',1,0,'',100,9,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='title'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='Officephone'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'Officephone','LD_vendorcontacts',1,11,'officephone','办公电话',1,0,'',100,10,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='Officephone'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='Mobile'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'Mobile','LD_vendorcontacts',1,1101,'mobile','手机',1,0,'',100,11,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='Mobile'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='homephone'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'homephone','LD_vendorcontacts',1,11,'homephone','家庭电话',1,0,'',100,12,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='homephone'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='Fax'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'Fax','LD_vendorcontacts',1,11,'Fax','传真',1,0,'',100,13,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='Fax'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='email'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'email','LD_vendorcontacts',1,13,'email','Email',1,0,'',100,14,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='email'  and tablename='LD_vendorcontacts' ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='QQ'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'qq','LD_vendorcontacts',1,1103,'qq','qq',1,0,'',100,15,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='QQ'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='birthday'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'birthday','LD_vendorcontacts',1,5,'birthday','Birthdate',1,0,'',100,16,@sendpaymentid,1,'D~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='birthday'  and tablename='LD_vendorcontacts' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','采购负责人',1,0,'',100,17,@sendpaymentid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='VendorContact');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'VendorContact',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='VendorContact');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='VendorContact';
delete from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_vendorcontacts:lastname:lastname:VendorContact_姓名:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontacts:lastname:lastname:VendorContact%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_vendorcontacts:vendorid:vendor_id:VendorContact_供应商名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontacts:vendorid:vendor_id:VendorContact%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_vendorcontacts:title:title:VendorContact_职位:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontacts:title:title:VendorContact%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_vendorcontacts:officephone:officephone:VendorContact_办公电话:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontacts:Officephone:Officephone:VendorContact%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_vendorcontacts:mobile:mobile:VendorContact_手机:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontacts:Mobile:Mobile:VendorContact%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_vendorcontacts:fax:fax:VendorContact_传真:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontacts:Fax:Fax:VendorContact%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_vendorcontacts:email:email:VendorContact_Email:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontacts:email:email:VendorContact_Email%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_vendorcontacts:birthday:birthday:VendorContact_Birthdate:D' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontacts:birthday:birthday:VendorContact_Birthdate%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:smownerid:assigned_user_id:VendorContact_采购负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;


select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'VendorContact','include/Webservices/VtigerModuleOperation.php','VtigerModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='VendorContact');
select  tabid into @tabid from LD_tab where name='VendorContact';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'VendorContact','LD_vendorcontacts','vendorcontact_no','vendorcontactid','vendorcontact_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);
delimiter;


select id into @maxid from LD_modentity_num_seq ;
update LD_modentity_num_seq set id=@maxid+1 where  not exists(select 1 from LD_modentity_num where  semodule='VendorContact');
insert into LD_modentity_num (num_id,semodule,prefix,start_id,cur_id,active)
select @maxid+1,'VendorContact','CON',1,1,1 from dual  where  not exists(select 1 from LD_modentity_num where  semodule='VendorContact');
delimiter;

-- add 2014-01-13 by li
drop procedure if exists `del_idx`;
create procedure del_idx
(
 p_idxname varchar(100),
 p_tablename varchar(50)
)

begin  
DECLARE str VARCHAR(250);  
  set @str=concat(' drop index ',p_idxname,' on ',p_tablename);   
    select database() into @tableschema;

 set @strcount=concat('select count(*) into @cnt from information_schema.statistics where table_name=''',p_tablename,''' and index_name=''',p_idxname,'''  and table_schema=''',@tableschema,'''');  

  PREPARE stmtt FROM @strcount;  
    EXECUTE stmtt ;    
if @cnt >0 then   
    PREPARE stmt FROM @str;  
    EXECUTE stmt ;  
  end if;  
end;

call del_idx('emailtemplates_foldernamd_templatename_subject_idx','ld_documenttemplates');


-- add 2014-01-13 by chen
CREATE TABLE if not EXISTS `ld_tabwithproductview` (
  `tabid` int(11) default NULL,
  `columns` varchar(255) default NULL,
  `sequence` int(11) NOT NULL default '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delete from ld_tabwithproductview;
select tabid into @tabid from ld_tab where `name` = 'SalesOrder';

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,0,'LD_salesorder:sostatus:sostatus:SalesOrder_订单状态:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 0);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,1,'LD_crmentity:createdtime:createdtime:SalesOrder_Created_Time:D' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 1);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,2,'LD_salesorder:subject:subject:SalesOrder_主题:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 2);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,3,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder_No:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 3);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,4,'LD_salesorder:accountid:account_id:SalesOrder_Account_Name:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 4);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,5,'LD_salesorder:contactid:contact_id:SalesOrder_联系人姓名:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 5);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,6,'LD_salesorder:potentialid:potential_id:SalesOrder_销售机会名称:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 6);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,7,'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 7);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,8,'LD_salesorder:duedate:duedate:SalesOrder_Due_Date:DT' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 8);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,9,'LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 9);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,10,'LD_salesorder:purchasestatus:purchasestatus:SalesOrder_采购标识:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 10);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,11,'LD_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 11);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,12,'LD_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 12);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,13,'LD_salesorder:invoiceid:invoiceid:SalesOrder_发票:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 13);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,14,'LD_salesorder:invoice_no:invoice_no:SalesOrder_发票号码:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 14);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,20,'LD_products:product_no:product_no:Products_产品编码:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 20);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,21,'LD_products:productname:productname:Products_产品名称:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 21);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,35,'LD_inventoryproductrel:quantity:quantity:Inventoryproductrel_数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 35);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,36,'LD_inventoryproductrel:listprice:listprice:Inventoryproductrel_单价:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 36);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,37,'LD_inventoryproductrel:discount_amount:discount_amount:Inventoryproductrel_折扣:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 37);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,38,'LD_inventoryproductrel:discount_percent:discount_percent:Inventoryproductrel_净价' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 38);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,39,'LD_inventoryproductrel:havepurchasecount:havepurchasecount:Inventoryproductrel_已采购数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 39);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,40,'LD_inventoryproductrel:balancepurchasecount:balancepurchasecount:Inventoryproductrel_未采购数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 40);


select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,0,'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 0);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,1,'LD_crmentity:createdtime:createdtime:PurchaseOrder_Created_Time:DT' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 1);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,2,'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 2);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,3,'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder_No:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 3);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,4,'LD_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 4);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,5,'LD_purchaseorder:contactid:contact_id:PurchaseOrder_联系人姓名:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 5);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,6,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 6);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,7,'LD_purchaseorder:duedate:duedate:PurchaseOrder_Due_Date:DT' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 7);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,9,'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 9);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,10,'LD_purchaseorder:approvestatus:approvestatus:PurchaseOrder_审批状态:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 10);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,20,'LD_products:product_no:product_no:Products_产品编码:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 20);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,21,'LD_products:productname:productname:Products_产品名称:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 21);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,35,'LD_inventoryproductrel:quantity:quantity:Inventoryproductrel_数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 35);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,36,'LD_inventoryproductrel:listprice:listprice:Inventoryproductrel_单价:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 36);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,37,'LD_inventoryproductrel:discount_amount:discount_amount:Inventoryproductrel_折扣:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 37);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,38,'LD_inventoryproductrel:discount_percent:discount_percent:Inventoryproductrel_净价' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 37);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,39,'LD_inventoryproductrel:havepurchasecount:havepurchasecount:Inventoryproductrel_已采购数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 39);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,40,'LD_inventoryproductrel:balancepurchasecount:balancepurchasecount:Inventoryproductrel_未采购数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 40);

call addcolumn('ld_inventoryproductrel','entitytype','varchar','25',null);
call addcolumn('ld_inventoryproductrel','parent_lineitem_id','int','19',0);
call addcolumn('ld_inventoryproductrel','entitytypeid','int','19',0);
call addcolumn('ld_inventoryproductrel','havepurchasecount','decimal','25,2',0);
call addcolumn('ld_inventoryproductrel','balancepurchasecount','decimal','25,2',0);

call addcolumn('ld_salesorder','purchaseStatus','Varchar','20',null);
call addcolumn('ld_salesorder','invoiceid','int','20',0);
call addcolumn('ld_salesorder','invoice_no','varchar','25',null);
delimiter;


-- add 2014-01-13 by luyx
update ld_field set quickcreatesequence=1 where tabid=6 and columnname='accountname';
update ld_field set quickcreatesequence=2 where tabid=6 and columnname='phone';
update ld_field set quickcreatesequence=3 where tabid=6 and columnname='email1';
update ld_field set quickcreatesequence=4 where tabid=6 and columnname='smownerid';

update ld_field set quickcreatesequence=1 where tabid=14 and columnname='productname';
update ld_field set quickcreatesequence=2 where tabid=14 and columnname='productcategory';
update ld_field set quickcreatesequence=3 where tabid=14 and columnname='productsheet';
update ld_field set quickcreatesequence=4 where tabid=14 and columnname='usageunit';
update ld_field set quickcreatesequence=5 where tabid=14 and columnname='unit_price';
update ld_field set quickcreatesequence=6 where tabid=14 and columnname='discontinued';
update ld_field set quickcreatesequence=7 where tabid=14 and columnname='smownerid';


update ld_field set quickcreate=1 where tabid=4 and columnname='salutation';
update ld_field set quickcreate=0 where tabid=4 and columnname='firstname';
update ld_field set quickcreatesequence=1 where tabid=4 and columnname='lastname';
update ld_field set quickcreatesequence=2 where tabid=4 and columnname='firstname';
update ld_field set quickcreatesequence=3 where tabid=4 and columnname='mobile';
update ld_field set quickcreatesequence=4 where tabid=4 and columnname='email';
update ld_field set quickcreatesequence=5 where tabid=4 and columnname='accountid';
update ld_field set quickcreatesequence=6 where tabid=4 and columnname='smownerid';

update ld_productfieldlist set fieldwidth=0;
update ld_entityname set entityidfield='vendorcontactsid' where tabid=(select tabid from ld_tab where name='VendorContact');

-- add 2014-01-14 by can
update ld_field set typeofdata='V~M' where tabid in(select tabid from ld_tab where name='vendorcontact') and COLUMNname='lastname';
update ld_entityname set entityidfield='vendorcontactsid' where modulename='VendorContact';
delimiter;

-- add 2014-01-15 by li
update lD_field set uitype=96 where tabid=21 and columnname='contactid';

/**更多信息****/
select tabid into @tabid from ld_tab WHERE name='VendorContact';
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='Lastname';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,1,1,1 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='title';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='Officephone';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='mobile';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='smownerid' limit 1;
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

/**更多信息函数**/

select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='VendorContact';
select tabid into @tabid from LD_tab where name='Vendors';

update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_vendorcontact'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_vendorcontact',1,'VendorContact',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_vendorcontact' and tabid=@tabid);
delimiter;

-- add 2014-01-15 by qiu
/*20140110*/
INSERT INTO ld_systems_deploy (deploy_value,deploy_type,description) 
select 0,21,'确认出库时是否发送短信通知客户。1:是，0:否'
FROM DUAL WHERE NOT EXISTS(select 1 from ld_systems_deploy where deploy_type =21);
delimiter;
ALTER TABLE ld_smssend MODIFY COLUMN CalledNumber varchar(500);
delimiter;
CREATE TABLE IF NOT EXISTS `ld_sendinformcontent` (
  `id` int(11) NOT NULL auto_increment,
  `content` text NOT NULL,
  `type` int(11) NOT NULL,
  `description` varchar(200) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;
INSERT INTO ld_sendinformcontent (`content`, `type`, `description`) 
select  '尊敬的客户您好，您订购的产品已发送。请注意查收！', 1, '出库单确认出库短信内容'
FROM DUAL WHERE NOT EXISTS(select 1 from ld_sendinformcontent where type =1);
delimiter;

update ld_field set uitype = 70 
where fieldname in ('createdtime','modifiedtime') and tablename='LD_crmentity'
and tabid in (select tabid from ld_tab where name in ('OutboundOrder','Stock'));
delimiter;

-- add 2014-01-15 by andy

/*6768*/
select tabid into @tabid from LD_tab where name='SendPayment';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_SendPayment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedby','LD_crmentity',1,52,'modifiedby','最新更新人',1,0,'',100,31,@paymentplanid,2,'V~O',1,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid ) ;
delimiter;

call fieldprofile('SendPayment');
call getallprofile('SendPayment');
delimiter;


/*6718*/
select tabid into @tabid from LD_tab where name='ContactRecords';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_CUSTOM_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','最新修改时间',1,2,'',100,23,@paymentplanid,2,'DT~O',1,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;
delimiter;

call fieldprofile('ContactRecords');
call getallprofile('ContactRecords');
delimiter;

select tabid into @tabid from LD_tab where name='Expense';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_Expense_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','最新修改时间',1,2,'',100,23,@paymentplanid,2,'DT~O',1,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;
delimiter;

call fieldprofile('Expense');
call getallprofile('Expense');
delimiter;

call fieldprofile('Potentials');
call getallprofile('Potentials');
delimiter;

-- add 2014-01-16 by qiu
ALTER TABLE ld_account MODIFY COLUMN lastpotential varchar(200);
delimiter;
update ld_field set uitype = 2 where tabid =6 and columnname = 'lastpotential';
delimiter;
call addcolumn('ld_attachmentsforbills','type','varchar','100',null);
delimiter;

-- add 2014-01-16 by huangjianchen
DROP PROCEDURE IF EXISTS AddProductColumn;
CREATE  PROCEDURE AddProductColumn
(
	module varchar(100)
)
BEGIN
	declare str varchar(100);
	declare cnt int(11) DEFAULT 0;
	declare i int(11) DEFAULT 0;
	declare limit_end int;
	select count(*) into cnt from ld_customview where entitytype = module;
	while i < cnt
	do
		set @stmt = concat('select cvid into @cvid from ld_customview where entitytype = ','''',module,'''',' limit ?,?');
		prepare s1 from @stmt;
		set @s1 = i;
		set @s2 = 1;
		execute s1 using @s1,@s2;
		delete from ld_cvcolumnlist where cvid = @cvid;
		if(module = 'SalesOrder')
		then
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,0,'LD_salesorder:subject:subject:SalesOrder_主题:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,1,'LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,2,'LD_salesorder:accountid:account_id:SalesOrder_Account_Name:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,3,'LD_salesorder:contactid:contact_id:SalesOrder_联系人姓名:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,4,'LD_salesorder:potentialid:potential_id:SalesOrder_销售机会名称:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,5,'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N');
		elseif(module = 'PurchaseOrder')
		then
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,0,'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,1,'LD_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,2,'LD_purchaseorder:contactid:contact_id:PurchaseOrder_联系人姓名:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,3,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N');
		end if;
		set i = i + 1;
	end while;
END;

delimiter;


ALTER TABLE ld_salesorder alter column purchaseStatus set default '未采购';

ALTER TABLE ld_inventoryproductrel  MODIFY COLUMN havepurchasecount decimal(25,2);
ALTER TABLE ld_inventoryproductrel  MODIFY COLUMN balancepurchasecount decimal(25,2);

alter table ld_inventoryproductrel alter column havepurchasecount set default '0.00';
alter table ld_inventoryproductrel alter column balancepurchasecount set default '0.00';

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select max(sequence) + 1 into @sequence from ld_tabwithproductview where tabid = @tabid;
insert into ld_tabwithproductview(tabid,`columns`,sequence)
select @tabid,'LD_inventoryproductrel:entitytypeid:entitytypeid:Inventoryproductrel_源单',@sequence from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and `columns` = 'LD_inventoryproductrel:entitytypeid:entitytypeid:Inventoryproductrel_源单');
delimiter;

call AddProductColumn('PurchaseOrder');
call AddProductColumn('SalesOrder');

-- add 2014-01-16 by mengxingli
/*按回款计划*/
select SUM(ld_paymentplan.amount-IFNULL(actualamount,0)) as paymentplan_sums  from ld_paymentplan 
INNER JOIN ld_crmentity on  ld_crmentity.crmid=ld_paymentplan.paymentplanid
inner join ld_users on ld_users.id=ld_crmentity.smownerid
where ld_crmentity.deleted=0;
/*按采购合同*/
select sum(ld_purchaseorder.total-IFNULL(temps.total_Amount,0)) as amounts from ld_purchaseorder  INNER JOIN
(select  SUM(Total) as total_Amount,Purchaseorder_id,sendcashbillid   from ld_sendcashbill  GROUP BY  Purchaseorder_id) as temps
 on  ld_purchaseorder.purchaseorderid=temps.Purchaseorder_id
INNER JOIN  ld_crmentity  on  temps.sendcashbillid=ld_crmentity.crmid
inner join ld_users on ld_users.id=ld_crmentity.smownerid
where ld_crmentity.deleted=0;
/*按付款计划*/
select SUM(ld_sendpayment.amount-IFNULL(actualamount,0)) as sendpayment_sum  from ld_sendpayment 
INNER JOIN ld_crmentity on  ld_crmentity.crmid=ld_sendpayment.sendpaymentid
inner join ld_users on ld_users.id=ld_crmentity.smownerid
where ld_crmentity.deleted=0;

-- add 2014-01-17 by mengxingli

select tabid into @tabid from ld_tab WHERE name='VendorContact';
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='email';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

update ld_relatedlists_lable set sequence=9 where fieldid in(select fieldid  from ld_field 
where columnname='smownerid' and tabid in(select  tabid from ld_tab where name='VendorContact'));

/*2014-01-18 by mengxingli*/
/*修改联系人编号*/
update lD_field set fieldlabel='联系人编号' where tabid in(select tabid from ld_tab where name='vendorcontact')
 and  fieldlabel='VendorContact NO';

/*修改菜单排序*/
update ld_parenttabrel set sequence='2'   where tabid in(select tabid from ld_tab where  name='VendorContact');
update ld_parenttabrel set sequence='3'   where tabid in(select tabid from ld_tab where  name='PurchaseOrder');

/*描述信息*/
select max(blockid) into @maxid  from LD_blocks;
update ld_blocks_seq set id=id+2  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
select tabid into @tabid from LD_tab where name='VendorContact';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;

select tabid into @tabid from LD_tab where name='VendorContact';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','LD_crmentity',1,19,'description','Description',1,2,'',100,1,@sendpaymentid,1,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid ) ;
delimiter;

/*供应商联系人模块权限*/
call addtabintoprofile('VendorContact',1);

update lD_field set typeofdata='E~O' 
where tabid in(select tabid from ld_tab where name='vendorcontact') and columnname='email';
delimiter;

/*2014-01-18 by can*/
update ld_customview set status=3 where entitytype='sendpayment' and viewname in('未付','已付','部分已付','本月应付');
update ld_entityname set fieldname='sendcashbill_no'  where modulename='sendcashbill';
delimiter;

/*2014-01-19 by chj*/
select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
update ld_tabwithproductview set columns = 'LD_salesorder:potentialid:potential_id:SalesOrder_销售机会:V' where tabid = @tabid and columns = 'LD_salesorder:potentialid:potential_id:SalesOrder_销售机会名称:V';
update ld_tabwithproductview set columns = 'LD_products:productsheet:productsheet:Products_规格型号:V' where tabid = @tabid and columns = 'LD_products:productcode:productcode:Products_规格型号:V';

insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'purchaseStatus','LD_salesorder',1,1,0,'purchaseStatus','采购标识',
(select max(sequence)+1 from ld_field where tabid = @tabid),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 
'LBL_SO_INFORMATION'),2,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchaseStatus');

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
update ld_tabwithproductview set columns = 'LD_products:productsheet:productsheet:Products_规格型号:V' where tabid = @tabid and columns = 'LD_products:productcode:productcode:Products_规格型号:V';

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'purchaseStatus','LD_salesorder',1,1,0,'purchaseStatus','采购标识',
(select max(sequence)+1 from ld_field where tabid = @tabid),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 
'LBL_SO_INFORMATION'),2,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchaseStatus');

update ld_customview_seq set id=(select max(cvid) from ld_customview);

select max(sequence)+1 into @sequence from ld_customview where entitytype = 'SalesOrder';
select id  into @maxid from LD_customview_seq;
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence)
select @maxid+1,'待采购',0,'SalesOrder',1,1,@sequence from dual where not exists (
select * from ld_customview where entitytype = 'SalesOrder' and viewname = '待采购');
update LD_customview_seq set id = @maxid+1 ;
select cvid into @cvid from ld_customview where entitytype = 'SalesOrder' and viewname = '待采购';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'LD_salesorder:purchaseStatus:purchaseStatus:SalesOrder_采购标识:V','e','未采购',1,'or' from dual where not exists (
select * from ld_cvadvfilter where cvid = @cvid and columnindex = 0);
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,1,'LD_salesorder:purchaseStatus:purchaseStatus:SalesOrder_采购标识:V','e','部分采购',1,'and' from dual where not exists (
select * from ld_cvadvfilter where cvid = @cvid and columnindex = 1);
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,2,'LD_salesorder:sostatus:sostatus:SalesOrder_订单状态:V','n','已作废',1,'' from dual where not exists (
select * from ld_cvadvfilter where cvid = @cvid and columnindex = 2);
delimiter;
select id  into @maxid from LD_customview_seq;
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence)
select @maxid+1,'已采购',0,'SalesOrder',1,1,@sequence from dual where not exists (
select * from ld_customview where entitytype = 'SalesOrder' and viewname = '已采购');
update LD_customview_seq set id = @maxid+1 ;
select cvid into @cvid from ld_customview where entitytype = 'SalesOrder' and viewname = '已采购';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'LD_salesorder:purchaseStatus:purchaseStatus:SalesOrder_采购标识:V','e','全部采购',1,'and' from dual where not exists (
select * from ld_cvadvfilter where cvid = @cvid and columnindex = 0);
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,1,'LD_salesorder:sostatus:sostatus:SalesOrder_订单状态:V','n','已作废',1,'' from dual where not exists (
select * from ld_cvadvfilter where cvid = @cvid and columnindex = 1);
delimiter;

/*2014-01-19 by limengxing*/
update LD_field  set  fieldlabel='创建时间'  where  columnname='createdtime' and  tabid in(select tabid from  LD_tab where name='VendorContact');
update LD_field  set  fieldlabel='描述'  where  columnname='description' and  tabid in(select tabid from  LD_tab where name='VendorContact');
update LD_field  set  fieldlabel='生日'  where  columnname='birthday' and  tabid in(select tabid from  LD_tab where name='VendorContact');
delimiter;

/*2014-01-20 by can*/
update lD_field set tablename='LD_sendpaymentscf' 
where tabid in(select tabid from ld_tab where name='sendpayment') and tablename='LD_SendPaymentscf';
delimiter;

/*2014-01-20 by huanjianchen*/
update ld_tabwithproductview set columns = 'LD_inventoryproductrel:productid:productid:Inventoryproductrel_净价' where columns = 'LD_inventoryproductrel:discount_percent:discount_percent:Inventoryproductrel_净价';

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into ld_tabwithproductview(tabid,columns,sequence)
select @tabid,'LD_crmentity:smownerid:assigned_user_id:SalesOrder_采购负责人:V',8 from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 8);


DROP PROCEDURE IF EXISTS AddProductColumn;
CREATE  PROCEDURE AddProductColumn
(
	module varchar(100)
)
BEGIN
	declare str varchar(100);
	declare cnt int(11) DEFAULT 0;
	declare i int(11) DEFAULT 0;
	declare limit_end int;
	select count(*) into cnt from ld_customview where entitytype = module;
	while i < cnt
	do
		set @stmt = concat('select cvid into @cvid from ld_customview where entitytype = ','''',module,'''',' limit ?,?');
		prepare s1 from @stmt;
		set @s1 = i;
		set @s2 = 1;
		execute s1 using @s1,@s2;
		delete from ld_cvcolumnlist where cvid = @cvid;
		if(module = 'SalesOrder')
		then
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,0,'LD_salesorder:subject:subject:SalesOrder_主题:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,1,'LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,2,'LD_salesorder:accountid:account_id:SalesOrder_Account_Name:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,3,'LD_salesorder:contactid:contact_id:SalesOrder_联系人姓名:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,4,'LD_salesorder:potentialid:potential_id:SalesOrder_销售机会名称:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,5,'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N');
		elseif(module = 'PurchaseOrder')
		then
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,0,'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,1,'LD_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,2,'LD_purchaseorder:contactid:contact_id:PurchaseOrder_联系人姓名:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,3,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,4,'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_Total:采购负责人');
		end if;
		set i = i + 1;
	end while;
END;

delimiter;

call AddProductColumn('PurchaseOrder');
delimiter;

/*2014-01-21 by limengxing*/
update ld_field   set columnname='officephone'  where tabid in(select tabid from ld_tab where name='vendorcontact') and columnname='Officephone';
update ld_field   set columnname='mobile'  where tabid in(select tabid from ld_tab where name='vendorcontact') and columnname='Mobile';
update ld_field   set columnname='fax' ,fieldname='fax'  where tabid in(select tabid from ld_tab where name='vendorcontact') and columnname='Fax';
delimiter;
select tabid into @tabid from ld_tab where name='vendorcontact';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_VendorContact_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','修改时间',1,0,'',100,28,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','创建时间',1,0,'',100,31,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedby','LD_crmentity',1,52,'modifiedby','最新更新人',1,0,'',100,34,@sendpaymentid,3,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedby');

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'smcreatorid','创建人',1,0,'',100,37,@sendpaymentid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;

delimiter;

call getallprofile('VendorContact');
call fieldprofile('VendorContact');
delimiter;

/*2014-01-21 by huanjiancheng*/
select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
update ld_tabwithproductview set columns = 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_采购负责人:V' where tabid = @tabid and sequence = 8; 
delimiter;

/*2014-01-21 by can*/
update lD_field set tablename='LD_sendpaymentscf' 
where tabid in(select tabid from ld_tab where name='sendpayment') and tablename='LD_SendPaymentscf';
delimiter;

/*2014-01-21 by qiu*/
CREATE TABLE if not EXISTS `ld_salesback` (
  `salesbackid` int(19) NOT NULL,
  `salesback_no` varchar(100) default NULL,
  `salesbackdate` date default NULL,
  `salesorderid` int(19) default '0',
  `accountid` int(19) default '0',
  `wareid` int(19) default '0',
  `salesbackstatus` varchar(20) default NULL,
  `havebackamount` decimal(18,2) default NULL,
	`taxtype` varchar(25) default NULL,
	`currency_id` int(19) NOT NULL default '1',
	`conversion_rate` decimal(25,3) default NULL,
  `total` decimal(25,2) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `discount_percent` decimal(25,2) default NULL,
  `discount_amount` decimal(25,2) default NULL,
  `s_h_amount` decimal(25,2) default NULL,
	`adjustment` decimal(25,2) default NULL,
  PRIMARY KEY  (`salesbackid`),
  KEY `idx_salesbackstatus_salesback` USING BTREE (`salesbackstatus`),
  CONSTRAINT `fk_1_vtiger_salesback` FOREIGN KEY (`salesbackid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE if not EXISTS `ld_salesbackscf` (
  `salesbackid` int(19) default NULL,
  KEY `fk_1_vtiger_salesbackscf` (`salesbackid`),
  CONSTRAINT `fk_1_vtiger_salesbackscf` FOREIGN KEY (`salesbackid`) REFERENCES `ld_salesback` (`salesbackid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE if not EXISTS `ld_cashback` (
  `cashbackid` int(19) default NULL,
  `cashback_no` varchar(100) default NULL,
  `cashbackdate` date default NULL,
  `salesbackid` int(19) default '0',
  `accountid` int(19) default '0',
  `crpaymentmethod` varchar(100) default NULL,
  `criscashbill` varchar(10) default NULL,
  `total` decimal(18,2) default NULL,
	`taxtype` varchar(25) default NULL,
	`currency_id` int(19) NOT NULL default '1',
	`conversion_rate` decimal(25,3) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `discount_percent` decimal(25,2) default NULL,
  `discount_amount` decimal(25,2) default NULL,
  `s_h_amount` decimal(25,2) default NULL,
	`adjustment` decimal(25,2) default NULL,
  KEY `cashbackid` (`cashbackid`),
  KEY `idx_crpayment_cashback` USING BTREE (`crpaymentmethod`),
  KEY `idx_criscashbill_cashback` USING BTREE (`criscashbill`),
  CONSTRAINT `ld_cashback_ibfk_1` FOREIGN KEY (`cashbackid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE  if not EXISTS `ld_cashbackscf` (
  `cashbackid` int(19) default NULL,
  KEY `fk_1_vtiger_cashbackscf` (`cashbackid`),
  CONSTRAINT `fk_1_vtiger_cashbackscf` FOREIGN KEY (`cashbackid`) REFERENCES `ld_cashback` (`cashbackid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

select max(tabid) into @maxid from  lD_tab  ;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,version,parent,printtab)
select @maxid+1 ,'SalesBack',0,70,'SalesBack',0,0,1,'5.0','Sales',1  from dual where not exists(select 1 from LD_tab where name='SalesBack');

select tabid into @tabid from ld_tab where name='SalesBack';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'SalesBack','销售退货单','销售退货单' from dual 
where not EXISTS(select 1 from ld_languagepackage where tabid=@tabid);

select parenttabid into @parentid from ld_parenttab where parenttab_label='Sales';
insert into LD_parenttabrel (parenttabid,tabid,sequence) select @parentid ,@tabid,8 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@tabid);
 
delimiter;

select max(tabid) into @maxid from  lD_tab  ;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,version,parent,printtab)
select @maxid+1 ,'CashBack',0,70,'CashBack',0,0,1,'5.0','Finacial',1  from dual where not exists(select 1 from LD_tab where name='CashBack');

select tabid into @tabid from ld_tab where name='CashBack';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'CashBack','销售退款单','销售退款单' from dual 
where not EXISTS(select 1 from ld_languagepackage where tabid=@tabid);

select parenttabid into @parentid from ld_parenttab where parenttab_label='Finacial';
insert into LD_parenttabrel (parenttabid,tabid,sequence) select @parentid ,@tabid,12 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@tabid);
 
delimiter;

/*退货单和退款单角色权限**/

call addtabintoprofile('SalesBack',1);
call addtabintoprofile('CashBack',1);


/*付款计划共享规则**/
select tabid into @tabid from LD_tab where name='SalesBack' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;

update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

delimiter;
/*付款单共享规则***/
select tabid into @tabid from LD_tab where name='CashBack' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;

update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

delimiter;

select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='SalesBack';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_SalesBack_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_SalesBack_INFORMATION');
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+2,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;

/*退货单界面**/
select tabid into @tabid from LD_tab where name='salesback';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_SalesBack_INFORMATION';

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesback_no'  and tablename='ld_salesback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesback_no','LD_salesback',1,4,'salesback_no','SalesBack No',1,0,'',100,1,@sendpaymentid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesback_no'  and tablename='ld_salesback' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesbackdate'  and tablename='ld_salesback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesbackdate','LD_salesback',1,5,'salesbackdate','退货日期',1,0,'thistoday',100,3,@sendpaymentid,1,'D~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesbackdate'  and tablename='ld_salesback' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tablename='ld_salesback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesorderid','LD_salesback',1,80,'salesorder_id','合同订单',1,0,'',100,6,@sendpaymentid,1,'I~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tablename='ld_salesback' ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tablename='ld_salesback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'accountid','LD_salesback',1,73,'account_id','客户名称',1,0,'',100,8,@sendpaymentid,1,'I~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tablename='ld_salesback' ) ;



select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='wareid'  and tablename='ld_salesback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'wareid','LD_salesback',1,151,'wareid','退入仓库',1,0,'',100,9,@sendpaymentid,1,'V~M',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='wareid'  and tablename='ld_salesback' ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','销售负责人',1,0,'',100,11,@sendpaymentid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesbackstatus'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesbackstatus','LD_salesback',1,2,'salesbackstatus','状态',1,0,'',100,16,@sendpaymentid,2,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesbackstatus'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='havebackamount'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'havebackamount','LD_salesback',1,7,'havebackamount','已退款',1,0,'',100,17,@sendpaymentid,2,'N~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='havebackamount'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='total'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'total','LD_salesback',1,7,'hdnGrandTotal','应退款',1,0,'',100,19,@sendpaymentid,2,'N~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='total'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','销售负责人',1,0,'',100,11,@sendpaymentid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','修改时间',1,0,'',100,28,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','创建时间',1,0,'',100,31,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedby','LD_crmentity',1,52,'modifiedby','最新更新人',1,0,'',100,34,@sendpaymentid,3,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedby');

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'smcreatorid','创建人',1,0,'',100,37,@sendpaymentid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='taxtype'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'taxtype','LD_salesback',1,16,'hdnTaxType','Tax Type',1,2,'',100,38,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='taxtype'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='currency_id'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'currency_id','LD_salesback',1,117,'currency_id','货币',1,2,1,100,39,@sendpaymentid,3,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='currency_id'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='conversion_rate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'conversion_rate','LD_salesback',1,1,'conversion_rate','汇率',1,2,1,100,40,@sendpaymentid,3,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='conversion_rate'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='subtotal'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'subtotal','LD_salesback',1,72,'hdnSubTotal','Sub Total',1,2,'',100,41,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='subtotal'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='discount_percent'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'discount_percent','LD_salesback',1,1,'hdnDiscountPercent','Discount Percent',1,2,'',100,42,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='discount_percent'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='discount_amount'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'discount_amount','LD_salesback',1,72,'hdnDiscountAmount','Discount Amount',1,0,'',100,43,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='discount_amount'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='s_h_amount'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'s_h_amount','LD_salesback',1,72,'hdnS_H_Amount','运费和物流附加费',1,2,'',100,44,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='s_h_amount'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='adjustment'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'adjustment','LD_salesback',1,72,'txtAdjustment','Adjustment',1,2,'',100,45,@sendpaymentid,3,'NN~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='adjustment'  and tabid=@tabid ) ;

select tabid into @tabid from LD_tab where name='salesback';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','LD_crmentity',1,19,'description','退货原因',1,2,'',100,1,@sendpaymentid,1,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid ) ;
delimiter;
/*退货和退款单编号**/
select id into @maxid from LD_modentity_num_seq ;
update LD_modentity_num_seq set id=@maxid+1 where  not exists(select 1 from LD_modentity_num where  semodule='SalesBack');
insert into LD_modentity_num (num_id,semodule,prefix,start_id,cur_id,active,datetype)
select @maxid+1,'SalesBack','THD',1,1,1,'yyyymmdd-' from dual  where  not exists(select 1 from LD_modentity_num where  semodule='SalesBack');

select id into @maxid from LD_modentity_num_seq ;
update LD_modentity_num_seq set id=@maxid+1 where  not exists(select 1 from LD_modentity_num where  semodule='CashBack');
insert into LD_modentity_num (num_id,semodule,prefix,start_id,cur_id,active,datetype)
select @maxid+1,'CashBack','TKD',1,1,1,'yyyymmdd-' from dual  where  not exists(select 1 from LD_modentity_num where  semodule='CashBack');

delimiter;

/*退货单数据分类（序时簿)**/
select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='SalesBack');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'SalesBack',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='SalesBack');
delimiter;
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_salesback:salesback_no:salesback_no:SalesBack_退货单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesback_no:salesback_no:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_salesback:salesbackdate:salesbackdate:SalesBack_退货日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackdate:salesbackdate:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_salesback:accountid:account_id:SalesBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:accountid:account_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_salesback:salesorderid:salesorder_id:SalesBack_合同订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesorderid:salesorder_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_salesback:total:hdnGrandTotal:SalesBack_应退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:total:hdnGrandTotal:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_salesback:havebackamount:havebackamount:SalesBack_已退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:havebackamount:havebackamount:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_状态:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SalesBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SalesBack%');

delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='未入库' and entitytype='SalesBack');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'未入库', 0, 0, 'SalesBack',1,1,3 from dual where not exists(select 1 from LD_customview where viewname='未入库' and entitytype='SalesBack');
delimiter;
select cvid into @cvid   from LD_customview where viewname='未入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_salesback:salesback_no:salesback_no:SalesBack_退货单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesback_no:salesback_no:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='未入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_salesback:salesbackdate:salesbackdate:SalesBack_退货日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackdate:salesbackdate:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='未入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_salesback:accountid:account_id:SalesBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:accountid:account_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='未入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_salesback:salesorderid:salesorder_id:SalesBack_合同订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesorderid:salesorder_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='未入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_salesback:total:hdnGrandTotal:SalesBack_应退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:total:hdnGrandTotal:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='未入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_salesback:havebackamount:havebackamount:SalesBack_已退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:havebackamount:havebackamount:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='未入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_状态:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='未入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SalesBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SalesBack%');

insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_salesbackstatus:V' ,'e','未入库',1,'' from dual
where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='已入库' and entitytype='SalesBack');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'已入库', 0, 0, 'SalesBack',1,1,3 from dual where not exists(select 1 from LD_customview where viewname='已入库' and entitytype='SalesBack');
delimiter;
select cvid into @cvid   from LD_customview where viewname='已入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_salesback:salesback_no:salesback_no:SalesBack_退货单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesback_no:salesback_no:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='已入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_salesback:salesbackdate:salesbackdate:SalesBack_退货日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackdate:salesbackdate:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='已入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_salesback:accountid:account_id:SalesBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:accountid:account_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='已入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_salesback:salesorderid:salesorder_id:SalesBack_合同订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesorderid:salesorder_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='已入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_salesback:total:hdnGrandTotal:SalesBack_应退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:total:hdnGrandTotal:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='已入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_salesback:havebackamount:havebackamount:SalesBack_已退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:havebackamount:havebackamount:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='已入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_状态:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='已入库' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SalesBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SalesBack%');

insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_salesbackstatus:V' ,'e','已入库',1,'' from dual
where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='结束' and entitytype='SalesBack');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'结束', 0, 0, 'SalesBack',1,1,3 from dual where not exists(select 1 from LD_customview where viewname='结束' and entitytype='SalesBack');
delimiter;
select cvid into @cvid   from LD_customview where viewname='结束' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_salesback:salesback_no:salesback_no:SalesBack_退货单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesback_no:salesback_no:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='结束' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_salesback:salesbackdate:salesbackdate:SalesBack_退货日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackdate:salesbackdate:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='结束' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_salesback:accountid:account_id:SalesBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:accountid:account_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='结束' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_salesback:salesorderid:salesorder_id:SalesBack_合同订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesorderid:salesorder_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='结束' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_salesback:total:hdnGrandTotal:SalesBack_应退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:total:hdnGrandTotal:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='结束' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_salesback:havebackamount:havebackamount:SalesBack_已退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:havebackamount:havebackamount:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='结束' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_状态:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='结束' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SalesBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SalesBack%');

insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_salesbackstatus:V' ,'e','结束',1,'' from dual
where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;



select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='中止' and entitytype='SalesBack');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'中止', 0, 0, 'SalesBack',1,1,3 from dual where not exists(select 1 from LD_customview where viewname='中止' and entitytype='SalesBack');
delimiter;
select cvid into @cvid   from LD_customview where viewname='中止' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_salesback:salesback_no:salesback_no:SalesBack_退货单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesback_no:salesback_no:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='中止' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_salesback:salesbackdate:salesbackdate:SalesBack_退货日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackdate:salesbackdate:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='中止' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_salesback:accountid:account_id:SalesBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:accountid:account_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='中止' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_salesback:salesorderid:salesorder_id:SalesBack_合同订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesorderid:salesorder_id:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='中止' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_salesback:total:hdnGrandTotal:SalesBack_应退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:total:hdnGrandTotal:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='中止' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_salesback:havebackamount:havebackamount:SalesBack_已退款:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:havebackamount:havebackamount:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='中止' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_状态:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

select cvid into @cvid   from LD_customview where viewname='中止' and entitytype='SalesBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:SalesBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id:SalesBack%');

insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_salesback:salesbackstatus:salesbackstatus:SalesBack_salesbackstatus:V' ,'e','中止',1,'' from dual
where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_salesback:salesbackstatus:salesbackstatus:SalesBack%');

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;



/*-----退款单界面字段-------------------*/
select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='CashBack';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_Cashback_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_Cashback_INFORMATION');
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+2,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;


select tabid into @tabid from LD_tab where name='CashBack';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_Cashback_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tablename='ld_cashback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'accountid','LD_cashback',1,73,'account_id','客户名称',1,0,'',100,2,@sendpaymentid,1,'I~M',3,'','',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tablename='ld_cashback' ) ;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='cashback_no'  and tablename='ld_cashback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'cashback_no','LD_cashback',1,4,'cashback_no','退款单编号',1,0,'',100,4,@sendpaymentid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='cashback_no'  and tablename='ld_cashback' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesbackid'  and tablename='ld_cashback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesbackid','LD_cashback',1,800,'salesbackid','退货单',1,0,'',100,7,@sendpaymentid,1,'I~O',3,'','',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesbackid'  and tablename='ld_cashback' ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','销售负责人',1,0,'',100,8,@sendpaymentid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='cashbilldate'  and tablename='LD_cashback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'cashbackdate','LD_cashback',1,5,'cashbackdate','退款日期',1,2,'',100,11,@sendpaymentid,1,'D~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='cashbackdate'  and tablename='LD_cashback' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='crpaymentmethod'  and tablename='LD_cashback' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'crpaymentmethod','LD_cashback',1,15,'crpaymentmethod','付款方式',1,2,'现金',100,16,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='crpaymentmethod'  and tablename='LD_cashback' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='criscashbill'  and tablename='criscashbill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'criscashbill','LD_cashback',1,15,'criscashbill','是否开票',1,2,'未开',100,19,@sendpaymentid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='criscashbill'  and tablename='LD_cashback' ) ;
select max(fieldid) into @maxfieldid  from ld_field ;

update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='total'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'total','LD_cashback',1,222,'hdnGrandTotal','合计',1,0,'',100,21,@sendpaymentid,2,'N~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='total'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','修改时间',1,0,'',100,28,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','Created Time',1,0,'',100,31,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedby','LD_crmentity',1,52,'modifiedby','最新更新人',1,0,'',100,34,@sendpaymentid,3,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedby');

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'smcreatorid','创建人',1,0,'',100,37,@sendpaymentid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='taxtype'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'taxtype','LD_cashback',1,16,'hdnTaxType','Tax Type',1,2,'',100,38,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='taxtype'  and tabid=@tabid ) ;
delimiter;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='currency_id'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'currency_id','LD_cashback',1,117,'currency_id','货币',1,2,1,100,39,@sendpaymentid,3,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='currency_id'  and tabid=@tabid ) ;
delimiter;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='conversion_rate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'conversion_rate','LD_cashback',1,1,'conversion_rate','汇率',1,2,1,100,40,@sendpaymentid,3,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='conversion_rate'  and tabid=@tabid ) ;
delimiter;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='subtotal'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'subtotal','LD_cashback',1,72,'hdnSubTotal','Sub Total',1,2,'',100,41,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='subtotal'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='discount_percent'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'discount_percent','LD_cashback',1,1,'hdnDiscountPercent','Discount Percent',1,2,'',100,42,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='discount_percent'  and tabid=@tabid ) ;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='discount_amount'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'discount_amount','LD_cashback',1,72,'hdnDiscountAmount','Discount Amount',1,0,'',100,43,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='discount_amount'  and tabid=@tabid ) ;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='s_h_amount'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'s_h_amount','LD_cashback',1,72,'hdnS_H_Amount','运费和物流附加费',1,2,'',100,44,@sendpaymentid,3,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='s_h_amount'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='adjustment'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'adjustment','LD_cashback',1,72,'txtAdjustment','Adjustment',1,2,'',100,45,@sendpaymentid,3,'NN~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='adjustment'  and tabid=@tabid ) ;

select tabid into @tabid from LD_tab where name='cashback';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','LD_crmentity',1,19,'description','Description',1,2,'',100,1,@sendpaymentid,1,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid ) ;
delimiter;
/*退款单数据分类**/

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='CashBack');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'CashBack',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='CashBack');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='CashBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_cashback:cashback_no:cashback_no:CashBack_退款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:cashback_no:cashback_no:CashBack%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_cashback:total:hdnGrandTotal:CashBack_金额:N' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:total:hdnGrandTotal:CashBack%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_cashback:cashbackdate:cashbackdate:CashBack_退款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:cashbackdate:cashbackdate:CashBack%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_cashback:criscashbill:criscashbill:CashBack_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:criscashbill:criscashbill:CashBack%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_cashback:crpaymentmethod:crpaymentmethod:CashBack_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:crpaymentmethod:crpaymentmethod%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_cashback:accountid:account_id:CashBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:accountid:account_id%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_cashback:salesbackid:salesbackid:CashBack_退货单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:salesbackid:salesbackid:CashBack%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:CashBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='本月退款' and entitytype='cashback');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'本月退款',    0, 0, 'CashBack',1,1,3 from dual where not exists(select 1 from LD_customview where viewname='本月退款' and entitytype='cashback');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月退款' and entitytype='cashback';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_cashback:cashback_no:cashback_no:CashBack_退款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:cashback_no:cashback_no%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_cashback:total:hdnGrandTotal:CashBack_金额:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:total:hdnGrandTota%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_cashback:cashbackdate:cashbackdate:CashBack_退款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:cashbackdate:cashbackdate%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_cashback:criscashbill:criscashbill:CashBack_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:criscashbill:criscashbill%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_cashback:crpaymentmethod:crpaymentmethod:CashBack_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:crpaymentmethod:crpaymentmethod%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_cashback:accountid:account_id:CashBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:accountid:account_id%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_cashback:salesbackid:salesbackid:CashBack_退货单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:salesbackid:salesbackid:CashBack%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:CashBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');

insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) select @cvid,'LD_cashback:cashbackdate:cashbackdate:CashBack_cashbackdate:D' ,'thismonth','2013-05-01','2013-05-31' from dual
 where not exists( select 1 from ld_cvstdfilter  where cvid=@cvid and  columnname like '%LD_cashback:cashbackdate:cashbackdate%');

delimiter;




select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='现金退款' and entitytype='cashback');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'现金退款',    1, 0, 'CashBack',3,1,2 from dual where not exists(select 1 from LD_customview where viewname='现金退款' and entitytype='cashback');
delimiter;

select cvid into @cvid   from LD_customview where viewname='现金退款' and entitytype='CashBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_cashback:cashback_no:cashback_no:CashBack_退款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:cashback_no:cashback_no%');
 
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_cashback:total:hdnGrandTotal:CashBack_金额:N' 

 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:total:hdnGrandTota%');


insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_cashback:cashbackdate:cashbackdate:CashBack_退款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:cashbackdate:cashbackdate%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_cashback:criscashbill:criscashbill:CashBack_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:criscashbill:criscashbill%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_cashback:crpaymentmethod:crpaymentmethod:CashBack_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:crpaymentmethod:crpaymentmethod%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_cashback:accountid:account_id:CashBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:accountid:account_id%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_cashback:salesbackid:salesbackid:CashBack_合同订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:salesbackid:salesbackid:CashBack%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:CashBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');

insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_cashback:crpaymentmethod:crpaymentmethod:CashBack_crpaymentmethod:V' ,'e','现金',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_cashback:crpaymentmethod:crpaymentmethod%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);


delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='无需发票' and entitytype='CashBack');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'无需发票',    0, 0, 'CashBack',1,1,3 from dual where not exists(select 1 from LD_customview where viewname='无需发票' and entitytype='CashBack');
delimiter;

select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='CashBack';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_cashback:cashback_no:cashback_no:CashBack_退款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:cashback_no:cashback_no%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_cashback:total:hdnGrandTotal:CashBack_金额:N' 

 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:total:hdnGrandTota%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_cashback:cashbackdate:cashbackdate:CashBack_退款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:cashbackdate:cashbackdate%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_cashback:criscashbill:criscashbill:CashBack_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:criscashbill:criscashbill%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_cashback:crpaymentmethod:crpaymentmethod:CashBack_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:crpaymentmethod:crpaymentmethod%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_cashback:accountid:account_id:CashBack_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:accountid:account_id%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_cashback:salesbackid:salesbackid:CashBack_合同订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashback:salesbackid:salesbackid:CashBack%');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:CashBack_销售负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');

insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_cashback:criscashbill:criscashbill:CashBack_是否开票:V' ,'e','无需发票',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_cashback:criscashbill:criscashbill%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;

/*字段权限**/
call getallprofile('SalesBack');
call fieldprofile('SalesBack');
call getallprofile('CashBack');
call fieldprofile('CashBack');
delimiter;


/*退货单和退款单日志***/
select max(linkid) into @maxLinkid from LD_links;
update LD_links_seq set id=@maxLinkid +1;
select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='SalesBack' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWBASIC','View History','javascript:ModTrackerCommon.showhistory(''$RECORD$'')','themes/images/pointer.gif',1,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
delimiter;

select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='CashBack' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWBASIC','View History','javascript:ModTrackerCommon.showhistory(''$RECORD$'')','themes/images/pointer.gif',1,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
delimiter;


select tabid into @tabid from LD_tab where name='SalesBack';
insert into LD_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not exists(select 1 from LD_modtracker_tabs where tabid=@tabid);
delimiter;

select tabid into @tabid from LD_tab where name='CashBack';
insert into LD_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not exists(select 1 from LD_modtracker_tabs where tabid=@tabid);
delimiter;




select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'SalesBack','include/Webservices/VtigerModuleOperation.php','VtigerModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='SalesBack');

select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'CashBack','include/Webservices/VtigerModuleOperation.php','VtigerModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='CashBack');
delimiter;

select  tabid into @tabid from LD_tab where name='SalesBack';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'SalesBack','LD_SalesBack','salesback_no','salesbackid','salesback_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);

select  tabid into @tabid from LD_tab where name='CashBack';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'CashBack','LD_CashBack','cashback_no','cashbackid','cashback_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);
delimiter;

select tabid into @tabid from LD_tab where name='SalesBack';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_Salesback_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedby','LD_crmentity',1,52,'modifiedby','最新更新人',1,0,'',100,31,@paymentplanid,2,'V~O',1,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid ) ;
delimiter;
call fieldprofile('SalesBack');
call getallprofile('SalesBack');
delimiter;

update ld_customview set status = 3 where entitytype in ('SalesBack','CashBack') and viewname != 'All';
delimiter;

/*2014-01-24 by qiu*/
call AddColumn('LD_troubletickets','salesorderid','int',19,null);
delimiter;
call fieldprofile('HelpDesk');
call getallprofile('HelpDesk');
delimiter;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tablename='LD_troubletickets' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 13,@maxfieldid+1,'salesorderid','LD_troubletickets',1,80,'salesorder_id','Sales Order',1,2,'',100,2,25,1,'I~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tablename='LD_troubletickets' ) ;
delimiter;

update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='SalesOrder';
select tabid into @relatedtabid from ld_tab where name='HelpDesk';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_tickets' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_tickets',10,'HelpDesk',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_tickets' and tabid=@tabid);
delimiter;

-- add 2014-02-08 by li
CREATE TABLE if not EXISTS  `ld_vendorcontactrecords` (
  `contactRecordsid` int(19) NOT NULL,
  `Subject` varchar(100) default NULL,
  `contactrecordtype` varchar(200) default NULL,
  `ContactDate` date default NULL,
  `vendorid` int(19) default NULL,
  `contactid` int(19) default NULL,
  PRIMARY KEY  (`contactRecordsid`),
  KEY `index_contactrecordtype` USING BTREE (`contactrecordtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  if not EXISTS `ld_vendorcontactrecordsscf` (
  `contactRecordsid` int(19) NOT NULL,
  PRIMARY KEY  (`contactRecordsid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

/***添加供应商联系记录子菜单（模块)***/
select max(tabid) into @maxid from  lD_tab  ;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,version,parent,printtab)
select @maxid+1 ,'VendorContactRecords',0,70,'VendorContactRecords',0,0,1,'5.0','Purchase',1  from dual where not exists

(select 1 from LD_tab where name='VendorContacTrecords');
select tabid into @tabid from ld_tab where name='VendorContactRecords';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'VendorContactRecords','供应商联系记录','供应商联系记录' from dual where not EXISTS(select 1 from ld_languagepackage where tabid=@tabid);

select parenttabid into @parentid from ld_parenttab where parenttab_label='Purchase';
insert into LD_parenttabrel (parenttabid,tabid,sequence) select @parentid ,@tabid,3 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@tabid);
delimiter;

call addtabintoprofile('VendorContactRecords',1);
delimiter;
select tabid into @tabid from LD_tab where name='VendorContactRecords' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
delimiter;

call getallprofile('VendorContactRecords');
call fieldprofile('VendorContactRecords');
delimiter;

/**供应商联系记录区块**/
select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='VendorContactRecords';
Insert into LD_Blocks

(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_vendorcontactrecords_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_VendorContactRecords_INFORMATION');
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+2,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;

select tabid into @tabid from LD_tab where name='VendorContactRecords';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_VendorContactRecords_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='subject' and tablename='LD_vendorcontactrecords' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'subject','LD_vendorcontactrecords',1,1,'subject','主题',1,0,'',100,2,@sendpaymentid,1,'V~M',3,'','',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='subject'  and tablename='LD_vendorcontactrecords') ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='contactrecordtype'  and tablename='LD_vendorcontactrecords' );
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'contactrecordtype','LD_vendorcontactrecords',1,15,'contactrecordtype','联系类型',1,0,'电话',100,3,@sendpaymentid,1,'V~O',3,'','BAS',1,''  from dual where  not exists 
(select columnname from  ld_field where columnname='contactrecordtype'  and tablename='LD_vendorcontactrecords' ) ;


select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists 
(select columnname from  ld_field where columnname='contactdate' and tablename='LD_vendorcontactrecords' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'contactdate','LD_vendorcontactrecords',1,5,'contactdate','联系日期',1,0,'',100,4,@sendpaymentid,1,'D~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='contactdate'  and tablename='LD_vendorcontactrecords' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='vendorid' and tablename='LD_vendorcontactrecords' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'vendorid','LD_vendorcontactrecords',1,81,'vendor_id','供应商名称',1,0,'',100,5,@sendpaymentid,1,'I~M',3,'','BAS',1,'' from dual where  not exists (select columnname from  ld_field where 
columnname='vendorid'  and tablename='LD_vendorcontactrecords') ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='contactid' and tablename='LD_vendorcontactrecords' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'contactid','LD_vendorcontactrecords',1,96,'contact_id','联系人姓名',1,0,'',100,6,@sendpaymentid,1,'I~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='contactid'  and tablename='LD_vendorcontactrecords' ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid' and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','采购负责人',1,0,'',100,7,@sendpaymentid,1,'V~M',3,'','BAS',1,'' from dual where  not exists (select columnname from  ld_field where 
columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;
delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='vendorcontactrecords');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'VendorContactRecords',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='vendorcontactrecords');
delimiter;
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='vendorcontactrecords';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_vendorcontactrecords:subject:subject:VendorContactRecords_主题:V' from dual where  not exists(select 1 
from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontactrecords:subject:subject:VendorContactRecords%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_vendorcontactrecords:contactrecordtype:contactrecordtype:VendorContactRecords_联系类型:V'from dual where  
not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontactrecords:contactrecordtype:contactrecordtype:VendorContactRecords%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_vendorcontactrecords:contactdate:ContactDate:VendorContactRecords_联系日期:D' from dual where  not exists
(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontactrecords:contactdate:contactdate:VendorContactRecords%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_vendorcontactrecords:vendorid:vendor_id:VendorContactRecords_供应商名称:V' from dual where  not exists
(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontactrecords:vendorid:vendor_id:VendorContactRecords%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_vendorcontactrecords:contactid:contactid:VendorContactRecords_联系人姓名:V' from dual where  not exists
(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_vendorcontactrecords:contactid:contactid:VendorContactRecords%');
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_crmentity:smownerid:assigned_user_id:VendorContactRecords_采购负责人:V'from dual where  not exists
(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'VendorContactRecords','include/Webservices/VtigerModuleOperation.php','VtigerModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='VendorContactRecords');
select  tabid into @tabid from LD_tab where name='VendorContactRecords';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'VendorContactRecords','LD_vendorcontactrecords','subject','contactrecordsid','contactrecords_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);
delimiter;

select max(blockid) into @maxid  from LD_blocks;
update ld_blocks_seq set id=id+2  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
select tabid into @tabid from LD_tab where name='VendorContactRecords';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;

select tabid into @tabid from LD_tab where name='VendorContactRecords';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','LD_crmentity',1,19,'description','Description',1,2,'',100,1,@sendpaymentid,1,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid ) ;
delimiter;


/*修改时间/创建时间*/
select tabid into @tabid from ld_tab where name='VendorContactRecords';
select blockid into @sendpaymentid from LD_blocks where tabid=@tabid and blocklabel='LBL_VendorContactRecords_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','修改时间',1,0,'',100,28,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','创建时间',1,0,'',100,31,@sendpaymentid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'smcreatorid','创建人',1,0,'',100,37,@sendpaymentid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;
delimiter;

/*更多信息*/
select tabid into @tabid from ld_tab WHERE name='VendorContactRecords';
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='subject';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,1,1,1 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='contactrecordtype';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='contactdate';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='description';
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);


select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='smownerid' limit 1;
insert into ld_relatedlists_lable(tabid,fieldid,sequence,presence,edit) select @tabid,@fieldid ,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

/*更多信息函数*/

select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='VendorContactRecords';
select tabid into @tabid from LD_tab where name='Vendors';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_VendorContactRecords'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_VendorContactRecords',1,'VendorContactRecords',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_VendorContactRecords' and tabid=@tabid);
delimiter;


/*修改日志*/
select max(linkid) into @maxLinkid from LD_links;
update LD_links_seq set id=@maxLinkid +1;
select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='VendorContactRecords' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWBASIC','View History','javascript:ModTrackerCommon.showhistory(''$RECORD$'')','themes/images/pointer.gif',1,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
delimiter;
select tabid into @tabid from LD_tab where name='VendorContactRecords';
insert into LD_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not exists(select 1 from LD_modtracker_tabs where tabid=@tabid);


/*附件更多信息*/
select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='Attachment';
select tabid into @tabid from ld_tab where name='VendorContactRecords';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;


/*评论信息*/
select max(linkid) into @maxLinkid from LD_links;
update LD_links_seq set id=@maxLinkid +1;
select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='VendorContactRecords' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='DetailViewBlockCommentWidget');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWWIDGET','DetailViewBlockCommentWidget','block://ModComments:modules/ModComments/ModComments.php','themes/images/pointer.gif',1,'','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='DetailViewBlockCommentWidget');
delimiter;

select tabid into @tabid from LD_tab where name='VendorContactRecords';
insert into LD_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not exists(select 1 from LD_modtracker_tabs where tabid=@tabid);
update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update lD_version set old_version='V3.1' ,current_version='V3.1' ,remark='V3.1-20140228';
delimiter;

-- add 2014-02-10 by li
/*采购订单关联供应商联系记录*/
select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='VendorContactRecords';
select tabid into @tabid from ld_tab where name='PurchaseOrder';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_VendorContactRecords' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_VendorContactRecords',7,'VendorContactRecords',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_VendorContactRecords' and tabid=@tabid);
delimiter;

-- add 2014-02-10 by huangjianchen
select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'','',1,200,0,'','选择源单',
(select max(sequence)+1 from ld_field where tabid = @tabid),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 
'LBL_PO_INFORMATION'),1,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and uitype = 200);

select tabid into @tabid from ld_tab where `name` = 'Invoice';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'','',1,200,0,'','选择源单',
(select max(sequence)+1 from ld_field where tabid = @tabid),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 
'LBL_INVOICE_INFORMATION'),1,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and uitype = 200);
update ld_field set presence = 1 where tabid = @tabid and uitype = 80;

select tabid into @tabid from ld_tab where `name` = 'Invoice';

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,0,'LD_invoice:invoicestatus:invoicestatus:Invoice_状态:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 0);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,1,'LD_invoicecf:invoicetype:invoicetype:Invoice_票据类型:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 1);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,2,'LD_invoice:invoicedate:invoicedate:Invoice_开票日期:D' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 2);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,3,'LD_invoice:subject:subject:Invoice_主题:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 3);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,4,'LD_invoice:invoice_no:invoice_no:Invoice_Invoice_No:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 4);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,5,'LD_invoice:accountid:account_id:Invoice_Account_Name:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 5);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,6,'LD_invoice:total:hdnGrandTotal:Invoice_Total:N' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 6);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,7,'LD_invoicecf:invoice_num:invoice_num:Invoice_发票号码:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 7);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,8,'LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 8);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,9,'LD_invoice:approvestatus:approvestatus:Invoice_审批状态:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 9);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,20,'LD_products:product_no:product_no:Products_产品编码:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 20);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,21,'LD_products:productname:productname:Products_产品名称:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 21);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,22,'LD_products:productcode:productcode:Products_规格型号:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 22);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,23,'LD_products:usageunit:usageunit:Products_计量单位:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 23);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,24,'LD_inventoryproductrel:quantity:quantity:Inventoryproductrel_数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 24);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,25,'LD_inventoryproductrel:listprice:listprice:Inventoryproductrel_单价:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 25);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,26,'LD_inventoryproductrel:entitytypeid:entitytypeid:Inventoryproductrel_源单' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 26);

-- add 2014-02-11 by huangjianchen
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'','',1,200,0,'','选择源单',
(select max(sequence)+1 from ld_field where tabid = @tabid),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 
'LBL_OUT_INFO'),1,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and uitype = 200);
update ld_field set presence = 1 where tabid = @tabid and uitype = 80;

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,0,'LD_outboundorder:out_no:out_no:OutboundOrder_出库单编号:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 0);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,1,'LD_outboundorder:wareid:wareid:OutboundOrder_仓库:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 1);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,2,'LD_outboundorder:outdate:outdate:OutboundOrder_出库日期:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 2);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,3,'LD_outboundorder:accountid:account_id:OutboundOrder_客户名称:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 3);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,4,'LD_outboundorder:presence:presence:OutboundOrder_状态:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 4);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,5,'LD_outboundorder:smownerid:assigned_user_id:OutboundOrder_负责人:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 5);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,20,'LD_products:product_no:product_no:Products_产品编码:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 20);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,21,'LD_products:productname:productname:Products_产品名称:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 21);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,22,'LD_products:productcode:productcode:Products_规格型号:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 22);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,23,'LD_products:usageunit:usageunit:Products_计量单位:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 23);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,24,'LD_inventoryproductrel:quantity:quantity:Inventoryproductrel_数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 24);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,25,'LD_inventoryproductrel:listprice:listprice:Inventoryproductrel_单价:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 25);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,26,'LD_inventoryproductrel:entitytypeid:entitytypeid:Inventoryproductrel_源单' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 26);


select tabid into @tabid from ld_tab where `name` = 'Stock';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'','',1,201,0,'','选择源单',
(select max(sequence)+1 from ld_field where tabid = @tabid),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 
'LBL_WARE_INFO'),1,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and uitype = 201);
update ld_field set presence = 1 where tabid = @tabid and uitype = 150;

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,0,'LD_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 0);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,1,'LD_stock:wareid:wareid:Stock_仓库:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 1);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,2,'LD_stock:createdate:createdate:Stock_入库日期:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 2);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,3,'LD_stock:smownerid:assigned_user_id:Stock_负责人:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 3);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,4,'LD_stock:vendor_id:vendor_id:Stock_供应商名称:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 4);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,5,'LD_stock:presence:presence:Stock_状态:' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 5);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,20,'LD_products:product_no:product_no:Products_产品编码:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 20);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,21,'LD_products:productname:productname:Products_产品名称:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 21);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,22,'LD_products:productcode:productcode:Products_规格型号:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 22);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,23,'LD_products:usageunit:usageunit:Products_计量单位:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 23);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,24,'LD_inventoryproductrel:quantity:quantity:Inventoryproductrel_数量:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 24);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,25,'LD_inventoryproductrel:listprice:listprice:Inventoryproductrel_单价:V' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 25);

insert into ld_tabwithproductview(tabid,sequence,columns)
select @tabid,26,'LD_inventoryproductrel:entitytypeid:entitytypeid:Inventoryproductrel_源单' from dual where not exists 
(select * from ld_tabwithproductview where tabid = @tabid and sequence = 26);

-- add 2014-02-11 by lukan
/*插入ld_field添加合同订单签约时间模块**/
select tabid into @tabid from LD_tab where name='SalesOrder';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_SO_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='signed_data'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'signed_data','LD_salesorder',1,5,'signed_data','签约日期',1,2,'thistoday',100,12,@paymentplanid,1,'D~M~OTH~GE~date_start~Start Date & Time',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='signed_data'  and tabid=@tabid ) ;
delimiter;
call fieldprofile('SalesOrder');
call getallprofile('SalesOrder');
delimiter;

/*插入LD_salesorder添加字段,并将createdtime数据复制**/
call addcolumn('LD_salesorder','signed_data','date',0,NULL);
delimiter;

update LD_salesorder inner join LD_crmentity on LD_salesorder.salesorderid= LD_crmentity.crmid
set  LD_salesorder.signed_data=LD_crmentity.createdtime where LD_crmentity.setype='SalesOrder';

/*插入ld_field添加采购订单签约时间模块**/
select tabid into @tabid from LD_tab where name='PurchaseOrder';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PO_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='signed_data'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'signed_data','LD_purchaseorder',1,5,'signed_data','签约日期',1,2,'thistoday',100,5,@paymentplanid,1,'D~M~OTH~GE~date_start~Start Date & Time',3,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='signed_data'  and tabid=@tabid ) ;
delimiter;
call fieldprofile('PurchaseOrder');
call getallprofile('PurchaseOrder');
delimiter;

/*插入LD_purchaseorder添加字段,并将createdtime数据复制**/
call addcolumn('LD_purchaseorder','signed_data','date',0,NULL);
delimiter; 
update LD_purchaseorder inner join LD_crmentity on LD_purchaseorder.purchaseorderid= LD_crmentity.crmid
set  LD_purchaseorder.signed_data=LD_crmentity.createdtime where LD_crmentity.setype='PurchaseOrder';

/*常用报表 合同订单跟踪表 修改表头，添加签约日期,修改时间搜索条件**/
select usereportid into @id from ld_usereport where name='salesordertrack';
update LD_usereportbasic  set columns='LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D' where usereportid=@id and Defaultvalue='thisstartmonth~thisendmonth';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D',5,1,'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D' 
from dual where not exists(select columns from LD_UseReportcolumns where Usereportid=@id and columns='LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D');

/*常用报表 应收款统计表_按回款计划统计 修改表头，添加签约日期**/
select usereportid into @id from ld_usereport where name='CashBillSum_Paymentplan';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D',9,1,'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D' 
from dual where not exists(select columns from LD_UseReportcolumns where Usereportid=@id and columns='LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D');


select usereportid into @id from ld_usereport where name='CashBillSum_SalesOrder';
update LD_usereportbasic  set columns='LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D' where usereportid=@id and Defaultvalue='thisstartmonth~thisendmonth';
update LD_UseReportcolumns  set columnshow='0' where usereportid=@id and columns='LD_crmentity:createdtime:createdtime:SalesOrder_Created Time:DT';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D',9,1,'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D' 
from dual where not exists(select columns from LD_UseReportcolumns where Usereportid=@id and columns='LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D');
delimiter;
select usereportid into @id from ld_usereport where name='Contractnumber';
update LD_usereportbasic  set columns='LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D' where usereportid=@id and Defaultvalue='thisstartmonth~thisendmonth';
delimiter;
select usereportid into @id from ld_usereport where name='Contractamount';
update LD_usereportbasic  set columns='LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D' where usereportid=@id and Defaultvalue='thisstartmonth~thisendmonth';
delimiter;

select usereportid into @id from ld_usereport where name='SalesSumSequence';
update LD_usereportbasic  set columns='LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D' where usereportid=@id and Defaultvalue='thisstartmonth~thisendmonth';
delimiter;

insert into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) 
select  733,'Reminds' ,'Vendors','0','null' from dual where not exists
(select 1 from LD_fieldmodulerel where module='Reminds' and relmodule='Vendors');
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContact';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salutation'  and tablename='LD_vendorcontacts' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salutation','LD_vendorcontacts',1,55,'salutationtype','称谓',1,0,'',100,5,@sendpaymentid,3,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='salutation'  and tablename='LD_vendorcontacts' ) ;
delimiter; 


update ld_tab set tabsequence=0 where name='Home';

update ld_tab set tabsequence=1 where name='Accounts';
update ld_tab set tabsequence=2 where name='Contacts';
update ld_tab set tabsequence=3 where name='ContactRecords';
update ld_tab set tabsequence=4 where name='ServiceContracts';
update ld_tab set tabsequence=5 where name='HelpDesk';
delimiter;
update ld_tab set tabsequence=11 where name='ReportLog';
update ld_tab set tabsequence=12 where name='Calendar';
update ld_tab set tabsequence=13 where name='Documents';
update ld_tab set tabsequence=14 where name='Webmails';
update ld_tab set tabsequence=15 where name='MailManager';
update ld_tab set tabsequence=16 where name='Emails';
update ld_tab set tabsequence=17 where name='Faq';
delimiter;

update ld_tab set tabsequence=21 where name='Campaigns';
update ld_tab set tabsequence=22 where name='MassSMS';
update ld_tab set tabsequence=23 where name='MassEmails';
update ld_tab set tabsequence=24 where name='MassFaxs';
update ld_tab set tabsequence=25 where name='MassVoices';
update ld_tab set tabsequence=26 where name='SmsPhrases';
update ld_tab set tabsequence=27 where name='EmailListtmp';
update ld_tab set tabsequence=28 where name='CommunicationLog';
delimiter;
update ld_tab set tabsequence=31 where name='Potentials';
update ld_tab set tabsequence=32 where name='Quotes';
update ld_tab set tabsequence=33 where name='SalesOrder';
update ld_tab set tabsequence=34 where name='SalesBack';
delimiter;
update ld_tab set tabsequence=41 where name='Vendors';
update ld_tab set tabsequence=42 where name='PurchaseOrder';
update ld_tab set tabsequence=43 where name='VendorContact';
update ld_tab set tabsequence=44 where name='VendorContactRecords';
delimiter;

update ld_tab set tabsequence=51 where name='Project';
update ld_tab set tabsequence=52 where name='ProjectTask';
update ld_tab set tabsequence=53 where name='ProjectMilestone';
delimiter;
update ld_tab set tabsequence=61 where name='Navigation';
update ld_tab set tabsequence=62 where name='OutboundOrder';
update ld_tab set tabsequence=63 where name='Stock';
update ld_tab set tabsequence=65 where name='Checks';
update ld_tab set tabsequence=66 where name='InventoryLedger';
update ld_tab set tabsequence=67 where name='InventoryAccount';
update ld_tab set tabsequence=68 where name='InventoryQuery';
update ld_tab set tabsequence=69 where name='Prdtnums';
delimiter;

update ld_tab set tabsequence=71 where name='Invoice';
update ld_tab set tabsequence=72 where name='CashBill';
update ld_tab set tabsequence=73 where name='SendCashBill';
update ld_tab set tabsequence=74 where name='CashBack';
update ld_tab set tabsequence=75 where name='PaymentPlan';
update ld_tab set tabsequence=76 where name='SendPayment';
update ld_tab set tabsequence=77 where name='Expense';
delimiter;
update ld_tab set tabsequence=81 where name='OftenUseReport';
update ld_tab set tabsequence=82 where name='Comprehensivereport';
update ld_tab set tabsequence=83 where name='Dashboard';
update ld_tab set tabsequence=84 where name='Reports';
delimiter;

update ld_tab set tabsequence=91 where name='Products';
update ld_tab set tabsequence=92 where name='PriceBooks';
update ld_tab set tabsequence=93 where name='Attachment';
update ld_tab set tabsequence=94 where name='ModComments';
update ld_tab set tabsequence=95 where name='Announcements';
update ld_tab set tabsequence=96 where name='RecycleBin';
update ld_tab set tabsequence=97 where name='Cache';
delimiter;
update ld_tab set tabsequence=201 where name='Leads';
update ld_tab set tabsequence=202 where name='Events';
update ld_tab set tabsequence=203 where name='Users';
update ld_tab set tabsequence=204 where name='FieldFormulas';
update ld_tab set tabsequence=205 where name='Reminds';
update ld_tab set tabsequence=206 where name='SMSNotifier';
update ld_tab set tabsequence=207 where name='Webforms';
update ld_tab set tabsequence=208 where name='Tooltip';
update ld_tab set tabsequence=209 where name='ModTracker';
update ld_tab set tabsequence=210 where name='Rss';
update ld_tab set tabsequence=211 where name='Portal';
update ld_tab set tabsequence=212 where name='ConfigEditor';
update ld_tab set tabsequence=213 where name='Import';
update ld_tab set tabsequence=214 where name='Integration';
update ld_tab set tabsequence=215 where name='Mobile';
update ld_tab set tabsequence=216 where name='PBXManager';
update ld_tab set tabsequence=217 where name='Services';
update ld_tab set tabsequence=218 where name='VtigerBackup';
update ld_tab set tabsequence=219 where name='WSAPP';
update ld_tab set tabsequence=220 where name='Assets';
update ld_tab set tabsequence=221 where name='CronTasks';
update ld_tab set tabsequence=222 where name='CustomerPortal';

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Finacial';
select tabid into @tabid1 from ld_tab where name='Invoice';
select tabid into @tabid2 from ld_tab where name='CashBill';
select tabid into @tabid3 from ld_tab where name='SendCashBill';
select tabid into @tabid4 from ld_tab where name='CashBack';
select tabid into @tabid5 from ld_tab where name='PaymentPlan';
select tabid into @tabid6 from ld_tab where name='SendPayment';
select tabid into @tabid7 from ld_tab where name='Expense';
update ld_parenttabrel set sequence=1 where parenttabid=@parenttabid and tabid=@tabid1;
update ld_parenttabrel set sequence=2 where parenttabid=@parenttabid and tabid=@tabid2;
update ld_parenttabrel set sequence=3 where parenttabid=@parenttabid and tabid=@tabid3;
update ld_parenttabrel set sequence=4 where parenttabid=@parenttabid and tabid=@tabid4;
update ld_parenttabrel set sequence=5 where parenttabid=@parenttabid and tabid=@tabid5;
update ld_parenttabrel set sequence=6 where parenttabid=@parenttabid and tabid=@tabid6;
update ld_parenttabrel set sequence=7 where parenttabid=@parenttabid and tabid=@tabid7;
delimiter;

-- add 2014-02-13 by qiu
CREATE TABLE if not EXISTS `ld_productbasevalues` (
  `type` int(11) NOT NULL,
  `value` int(11) NOT NULL,
  `describe` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
insert into ld_productbasevalues(type,`value`,`describe`)
select 1,3,'工具的长度'  from dual where not exists(select 1 from ld_productbasevalues where type=1);
insert into ld_productbasevalues(type,`value`,`describe`)
select 2,17,'产品名称的长度'  from dual where not exists(select 1 from ld_productbasevalues where type=2);
insert into ld_productbasevalues(type,`value`,`describe`)
select 3,10,'关联产品字段的长度'  from dual where not exists(select 1 from ld_productbasevalues where type=3);
insert into ld_productbasevalues(type,`value`,`describe`)
select 4,10,'产品工具自定义字段的长度'  from dual where not exists(select 1 from ld_productbasevalues where type=4);
insert into ld_productbasevalues(type,`value`,`describe`)
select 5,10,'数量、单据、总计、净价等的长度'  from dual where not exists(select 1 from ld_productbasevalues where type=5);
delimiter;
call AddColumn('LD_project','approvestatus','int',11,null);
delimiter;
call AddColumn('LD_project','approveby','int',1,null);
delimiter;
call AddColumn('LD_projecttask','approvestatus','int',11,null);
delimiter;
call AddColumn('LD_projecttask','approveby','int',1,null);
delimiter;

call fieldprofile('Project');
call getallprofile('Project');
delimiter;
call fieldprofile('ProjectTask');
call getallprofile('ProjectTask');
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='LD_project' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approvestatus','LD_project',1,53,'approvestatus','Approvestatus',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='LD_project' and fieldname='approvestatus');
delimiter;
select tabid into @tabid from ld_tab where name = 'Project';
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='LD_project' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approveby','LD_project',1,53,'approveby','Approveby',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='LD_project' and fieldname='approveby');
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectTask';
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='LD_projecttask' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approvestatus','LD_projecttask',1,53,'approvestatus','Approvestatus',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='LD_projecttask' and fieldname='approvestatus');
delimiter;
select tabid into @tabid from ld_tab where name = 'ProjectTask';
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='LD_projecttask' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approveby','LD_projecttask',1,53,'approveby','Approveby',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='LD_projecttask' and fieldname='approveby');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,'22','项目是否启用审批流程。1:否，0:是' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type='22');
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,'23','项目任务是否启用审批流程。1:否，0:是' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type='23');
delimiter;

-- add 2013-02-13 by can
update ld_field set typeofdata='D~M' where (tabid=21 or tabid=22) and columnname='signed_data';

-- add 2013-02-18 by huangjianchen
select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into ld_usereport(`name`,reportlabel,tabids,pagewidthpercent)
select 'productlistset','序时薄表格设置',@tabid,200 from dual where not exists 
(select * from ld_usereport where tabids = @tabid and `name` = 'productlistset');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into ld_usereport(`name`,reportlabel,tabids,pagewidthpercent)
select 'productlistset','序时薄表格设置',@tabid,200 from dual where not exists 
(select * from ld_usereport where tabids = @tabid and `name` = 'productlistset');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Invoice';
insert into ld_usereport(`name`,reportlabel,tabids,pagewidthpercent)
select 'productlistset','序时薄表格设置',@tabid,200 from dual where not exists 
(select * from ld_usereport where tabids = @tabid and `name` = 'productlistset');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Stock';
insert into ld_usereport(`name`,reportlabel,tabids,pagewidthpercent)
select 'productlistset','序时薄表格设置',@tabid,200 from dual where not exists 
(select * from ld_usereport where tabids = @tabid and `name` = 'productlistset');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
insert into ld_usereport(`name`,reportlabel,tabids,pagewidthpercent)
select 'productlistset','序时薄表格设置',@tabid,200 from dual where not exists 
(select * from ld_usereport where tabids = @tabid and `name` = 'productlistset');
delimiter;

-- add 2014-02-18 by huangjianchen
call addcolumn('ld_tabwithproductview','cvid','int','11',0);
call addcolumn('ld_customview','pagewidthpercent','int','11',100);
delete from ld_usereport where `name` = 'productlistset' and reportlabel = '序时薄表格设置';


select tabid into @tabid from lD_tab where name='SalesOrder';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesOrder') and columnname='salesorder_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesOrder';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesOrder') and columnname='subject';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,2,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesOrder';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesOrder') and columnname='duedate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesOrder';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesOrder') and columnname='sostatus';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,2,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesOrder';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesOrder') and columnname='total';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesOrder';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesOrder') and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,2,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

/*2014-02-18*/
insert into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) 
select  733,'Reminds' ,'HelpDesk','0','null' from dual where not exists
(select 1 from LD_fieldmodulerel where module='Reminds' and relmodule='HelpDesk');
delimiter;
ALTER TABLE LD_account MODIFY COLUMN approvestatus varchar(200); 
ALTER TABLE LD_account ALTER COLUMN approvestatus SET DEFAULT '未提交';
delimiter;
ALTER TABLE LD_notes MODIFY COLUMN approvestatus varchar(200); 
ALTER TABLE LD_notes ALTER COLUMN approvestatus SET DEFAULT '未提交';
delimiter;
ALTER TABLE LD_project MODIFY COLUMN approvestatus varchar(200); 
ALTER TABLE LD_project ALTER COLUMN approvestatus SET DEFAULT '未提交';
delimiter;
ALTER TABLE ld_projecttask MODIFY COLUMN approvestatus varchar(200); 
ALTER TABLE ld_projecttask ALTER COLUMN approvestatus SET DEFAULT '未提交';
delimiter;


delete from ld_tabwithproductview where tabid=21;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,0,'LD_purchaseorder:subject:subject:PurchaseOrder_主题:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,1,'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder No:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,2,'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,3,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,4,'LD_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor Name:I');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,5,'LD_purchaseorder:duedate:duedate:PurchaseOrder_交付日期:D');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,6,'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,7,'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(21,0,8,'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_采购负责人:V');

delete from ld_tabwithproductview where tabid=22;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,0,'LD_salesorder:subject:subject:SalesOrder_主题:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,1,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder No:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,2,'LD_salesorder:sostatus:sostatus:SalesOrder_订单状态:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,3,'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,4,'LD_salesorder:accountid:account_id:SalesOrder_客户名称:I');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,5,'LD_salesorder:duedate:duedate:SalesOrder_交付日期:D');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,6,'LD_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,7,'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(22,0,8,'LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V');
delimiter;
delete from ld_tabwithproductview where tabid=23;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,0,'LD_invoice:subject:subject:Invoice_主题:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,1,'LD_invoice:invoice_no:invoice_no:Invoice_Invoice No:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,2,'LD_invoice:invoicestatus:invoicestatus:Invoice_状态:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,3,'LD_invoice:total:hdnGrandTotal:Invoice_Total:N');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,4,'LD_invoice:accountid:account_id:Invoice_Account Name:I');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,5,'LD_invoice:invoicedate:invoicedate:Invoice_开票日期:D');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,6,'LD_invoicecf:invoicetype:invoicetype:Invoice_票据类型:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,7,'LD_invoicecf:invoice_num:invoice_num:Invoice_发票号码:V');

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
values(23,0,8,'LD_crmentity:smownerid:assigned_user_id:Invoice_销售负责人:V');

select tabid into @tabid from ld_tab where name='OutboundOrder';
delete from ld_tabwithproductview where tabid=@tabid;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,0,'LD_outboundorder:out_no:out_no:OutboundOrder_出库单编号:';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,1,'LD_outboundorder:wareid:wareid:OutboundOrder_仓库:V';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,2,'LD_outboundorder:outdate:outdate:OutboundOrder_出库日期:D';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,3,'LD_outboundorder:accountid:account_id:OutboundOrder_客户名称:I';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,4,'LD_outboundorder:presence:presence:OutboundOrder_状态:V';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,5,'LD_outboundorder:smownerid:assigned_user_id:OutboundOrder_负责人:V';
delimiter;

-- 入库单
select tabid into @tabid from ld_tab where name='Stock';
delete from ld_tabwithproductview where tabid=@tabid;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,0,'LD_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,1,'LD_stock:wareid:wareid:Stock_仓库:V';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,2,'LD_stock:createdate:createdate:Stock_入库日期:D';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,3,'LD_stock:vendor_id:vendor_id:Stock_供应商名称:';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,4,'LD_stock:presence:presence:Stock_状态:V';

insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,0,5,'LD_stock:smownerid:assigned_user_id:Stock_负责人:V';
delimiter;

-- add 2014-02-20 by huanjianchen
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'total','LD_outboundorder',72,'hdnGrandTotal','Total',(select blockid from ld_blocks where blocklabel = 'LBL_OUT_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'subtotal','LD_outboundorder',72,'hdnSubTotal','Sub Total',(select blockid from ld_blocks where blocklabel = 'LBL_OUT_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'taxtype','LD_outboundorder',16,'hdnTaxType','Tax Type',(select blockid from ld_blocks where blocklabel = 'LBL_OUT_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'taxtype');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_percent','LD_outboundorder',1,'hdnDiscountPercent','Discount Percent',(select blockid from ld_blocks where blocklabel = 'LBL_OUT_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'discount_percent');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_amount','LD_outboundorder',72,'hdnDiscountAmount','Discount Amount',(select blockid from ld_blocks where blocklabel = 'LBL_OUT_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'discount_amount');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'currency_id','LD_outboundorder',117,'currency_id','货币',(select blockid from ld_blocks where blocklabel = 'LBL_OUT_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');


select tabid into @tabid from ld_tab where `name` = 'Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'total','LD_stock',72,'hdnGrandTotal','Total',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'subtotal','LD_stock',72,'hdnSubTotal','Sub Total',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'taxtype','LD_stock',16,'hdnTaxType','Tax Type',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'taxtype');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_percent','LD_stock',1,'hdnDiscountPercent','Discount Percent',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'discount_percent');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_amount','LD_stock',72,'hdnDiscountAmount','Discount Amount',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'discount_amount');

update ld_field set displaytype = 4 where fieldlabel = "选择源单";

-- add 2014-02-20 by andy
/*付款计划增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='SendPayment';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',2,'attachment',1,'add' from dual 
where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

-- add 2014-02-20 by luyx
select tabid into @tabid from ld_tab where name='OutboundOrder';
delete from ld_relatedlists_lable where tabid=@tabid;
select max(id) into @id from ld_relatedlists_lable;
select fieldid into @fieldid1 from ld_field where tabid=@tabid and columnname='out_no';
select fieldid into @fieldid2 from ld_field where tabid=@tabid and columnname='wareid';
select fieldid into @fieldid3 from ld_field where tabid=@tabid and columnname='outdate';
select fieldid into @fieldid4 from ld_field where tabid=@tabid and columnname='presence';
select fieldid into @fieldid5 from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+1,@tabid,@fieldid1,0,1,1,1;

insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+2,@tabid,@fieldid2,0,2,1,0;

insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+3,@tabid,@fieldid3,0,3,1,0;

insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+4,@tabid,@fieldid4,0,4,1,0;

insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fieldid5,0,5,1,0;
delimiter;

select tabid into @tabid from ld_tab where name='stock';
delete from ld_relatedlists_lable where tabid=@tabid;
select max(id) into @id from ld_relatedlists_lable;
select fieldid into @fieldid1 from ld_field where tabid=@tabid and columnname='ware_stock_no';
select fieldid into @fieldid2 from ld_field where tabid=@tabid and columnname='wareid';
select fieldid into @fieldid3 from ld_field where tabid=@tabid and columnname='createdate';
select fieldid into @fieldid4 from ld_field where tabid=@tabid and columnname='presence';
select fieldid into @fieldid5 from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+1,@tabid,@fieldid1,0,1,1,1;

insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+2,@tabid,@fieldid2,0,2,1,0;

insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+3,@tabid,@fieldid3,0,3,1,0;

insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+4,@tabid,@fieldid4,0,4,1,0;

insert into ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
select @id+5,@tabid,@fieldid5,0,5,1,0;
delimiter;

-- add 2014-02-21 by huanjianchen
call addcolumn('ld_inventoryproductrel','haveoutproductcount','int','11',0);
call addcolumn('ld_inventoryproductrel','balanceoutproductcount','int','11',0);
update ld_field set displaytype = 1 where fieldlabel = "选择源单";

-- add 2014-02-21 by lukan
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='SalesOrder';
select tabid into @relatedtabid from ld_tab where name='SalesBack';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_salesback' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_salesback',29,'SalesBack',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_salesback' and tabid=@tabid);
delimiter;
/*销售退货单更多信息中字段*/
select tabid into @tabid from lD_tab where name='SalesBack';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesBack') and columnname='salesback_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesBack';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesBack') and columnname='salesbackdate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesBack';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesBack') and columnname='total';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesBack';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesBack') and columnname='havebackamount';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SalesBack';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SalesBack') and columnname='salesbackstatus';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;



update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='PurchaseOrder';
select tabid into @relatedtabid from ld_tab where name='SendPayment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_SendPayment' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_SendPayment',3,'SendPayment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_SendPayment' and tabid=@tabid);
delimiter;
/* 付款计划 更多信息中字段*/
select tabid into @tabid from lD_tab where name='SendPayment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendPayment') and columnname='sendpayment_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendPayment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendPayment') and columnname='cpperiodtime';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendPayment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendPayment') and columnname='amount';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendPayment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendPayment') and columnname='plandate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendPayment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendPayment') and columnname='cpstatus';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendPayment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendPayment') and columnname='purchaseorder_id';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendPayment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendPayment') and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;



update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='PurchaseOrder';
select tabid into @relatedtabid from ld_tab where name='SendCashBill';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_SendCashBill' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_SendCashBill',3,'SendCashBill',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_SendCashBill' and tabid=@tabid);
delimiter;
/* 付款单 更多信息中字段*/
select tabid into @tabid from lD_tab where name='SendCashBill';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendCashBill') and columnname='sendcashbill_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendCashBill';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendCashBill') and columnname='Total';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendCashBill';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendCashBill') and columnname='cashbilldate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendCashBill';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendCashBill') and columnname='crpaymentmethod';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendCashBill';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendCashBill') and columnname='purchaseorder_id';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='SendCashBill';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='SendCashBill') and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);

-- add 2014-02-21 by luyx

update ld_customview set pagewidthpercent=100 where pagewidthpercent is null;

call addcolumn('ld_systems_deploy','setype','varchar','100',null);
delimiter;

update ld_systems_deploy set setype='SalesOrder' where deploy_type=3;
update ld_systems_deploy set setype='Invoice' where deploy_type=4;
update ld_systems_deploy set setype='Quotes' where deploy_type=5;
update ld_systems_deploy set setype='HelpDesk' where deploy_type=6;
update ld_systems_deploy set setype='PurchaseOrder' where deploy_type=8;
update ld_systems_deploy set setype='Expense' where deploy_type=9;
update ld_systems_deploy set setype='Quotes' where deploy_type=10;
update ld_systems_deploy set setype='Accounts' where deploy_type=11;
update ld_systems_deploy set setype='Documents' where deploy_type=17;
update ld_systems_deploy set setype='Project' where deploy_type=22;
update ld_systems_deploy set setype='ProjectTask' where deploy_type=23;

-- add 2014-02-22 by luyx
select tabid into @tabid from LD_tab where name='ServiceContracts';
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='salesorderid');
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'salesorderid','LD_servicecontracts',1,80,'salesorder_id','合同订单',1,0,'',100,4,91,1,'I~O',3,NULL,'BAS',1,NULL,0  
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='salesorderid') ;
delimiter;

call addcolumn('LD_servicecontracts','salesorderid','int','19',0);
delimiter;

delete from ld_role2picklist where  picklistvalueid in(214,215,216);
delete from ld_contract_status where  picklist_valueid in(214,215,216); 
update ld_servicecontracts set contract_status='已创建' where contract_status=(select contract_status from ld_contract_status where picklist_valueid=217);
update ld_servicecontracts set contract_status='已审批' where contract_status=(select contract_status from ld_contract_status where picklist_valueid=218);
update ld_servicecontracts set contract_status='已作废' where contract_status=(select contract_status from ld_contract_status where picklist_valueid=219);
update ld_contract_status set presence=0,contract_status='已创建' where picklist_valueid=217;
update ld_contract_status set presence=0,contract_status='已审批' where picklist_valueid=218;  
update ld_contract_status set presence=0,contract_status='已作废' where picklist_valueid=219; 
update ld_servicecontracts set contract_status='已创建' where contract_status not in (select contract_status from ld_contract_status);

update ld_servicecontracts set contract_type='按年' where contract_type=(select contract_type from ld_contract_status where picklist_valueid=223);
update ld_servicecontracts set contract_type='按次' where contract_type=(select contract_type from ld_contract_status where picklist_valueid=224);
update ld_servicecontracts set contract_type='其他' where contract_type=(select contract_type from ld_contract_status where picklist_valueid=225);
update ld_contract_type set presence=0,contract_type='按年' where picklist_valueid=223;
update ld_contract_type set presence=0,contract_type='按次' where picklist_valueid=224;  
update ld_contract_type set presence=0,contract_type='其他' where picklist_valueid=225; 
update ld_servicecontracts set contract_status='按年' where contract_type not in (select contract_type from ld_contract_status );

select tabid into @tabid from LD_tab where name='ServiceContracts';
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='service_units');
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'service_units','LD_servicecontracts',1,7,'service_units','已服务次数',1,2,0,100,12,91,2,'NN~O~3,0',3,NULL,'BAS',1,NULL,0  
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='service_units') ;
delimiter;

call addcolumn('LD_servicecontracts','service_units','decimal','5',2);
delimiter;

update ld_field set presence=0,typeofdata='V~M',fieldlabel='签约日期',defaultvalue='thistoday' where tabid=37 and columnname='due_date';
update ld_field set sequence=1 where tabid=37 and columnname='subject';
update ld_field set sequence=2 where tabid=37 and columnname='contract_no';
update ld_field set sequence=3 where tabid=37 and columnname='accountid';
update ld_field set sequence=4 where tabid=37 and columnname='contactid';
update ld_field set sequence=5 where tabid=37 and columnname='salesorderid';

update ld_field set sequence=6,defaultvalue='按年' where tabid=37 and columnname='contract_type';
update ld_field set sequence=7 where tabid=37 and columnname='due_date';
update ld_field set sequence=8,defaultvalue='已创建' where tabid=37 and columnname='contract_status';

update ld_field set sequence=9,fieldlabel='服务开始日期' where tabid=37 and columnname='start_date';
update ld_field set sequence=10,masseditable=1,displaytype=1,fieldlabel='服务截止日期' where tabid=37 and columnname='end_date';
update ld_field set sequence=11,typeofdata='NN~O~3,0',fieldlabel='应服务次数' where tabid=37 and columnname='total_units';
update ld_field set sequence=12,typeofdata='NN~O~3,0' where tabid=37 and columnname='service_units';
update ld_field set sequence=13 where tabid=37 and columnname='smownerid';
update ld_field set sequence=14 where tabid=37 and columnname='smcreatorid';
update ld_field set sequence=15 where tabid=37 and columnname='createdtime';
update ld_field set sequence=16 where tabid=37 and columnname='modifiedby';
update ld_field set sequence=17 where tabid=37 and columnname='modifiedtime';

delete from ld_cvcolumnlist where cvid=42;
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,0,'LD_servicecontracts:subject:subject:ServiceContracts_主题:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,1,'LD_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,2,'LD_servicecontracts:contract_status:contract_status:ServiceContracts_状态:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,3,'LD_servicecontracts:accountid:account_id:ServiceContracts_Account_Name:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,4,'LD_servicecontracts:start_date:start_date:ServiceContracts_服务开始日期:D');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,5,'LD_servicecontracts:end_date:end_date:ServiceContracts_服务截止日期:D');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,6,'LD_servicecontracts:total_units:total_units:ServiceContracts_应服务次数:NN');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,7,'LD_servicecontracts:service_units:service_units:ServiceContracts_已服务次数:NN');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(42,8,'LD_crmentity:smownerid:assigned_user_id:ServiceContracts_销售负责人:V');

update ld_field set uitype=130 where tabid in (6,8,47,48) and columnname='approvestatus';
update ld_field set uitype=131 where tabid in (6,8,47,48) and columnname='approveby';
update ld_field set block=106 where tabid=47 and columnname in('approvestatus','approveby');
update ld_field set block=109 where tabid=48 and columnname in('approvestatus','approveby');

select tabid into @tabid from LD_tab where name='Project';
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='salesorderid');
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'salesorderid','LD_project',1,80,'salesorder_id','合同订单',1,0,'',100,4,109,1,'I~O',3,NULL,'BAS',1,NULL,0  
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='salesorderid') ;
delimiter;

call addcolumn('LD_project','salesorderid','int','19',0);
delimiter;

update ld_project set projectpriority='--无--' 
where projectpriority=(select projectpriority from ld_projectpriority where picklist_valueid=273);

update ld_project set projectpriority='低' 
where projectpriority=(select projectpriority from ld_projectpriority where picklist_valueid=274);


update ld_project set projectpriority='一般' 
where projectpriority=(select projectpriority from ld_projectpriority where picklist_valueid=275);

update ld_project set projectpriority='高' 
where projectpriority=(select projectpriority from ld_projectpriority where picklist_valueid=276);

update ld_projectpriority set projectpriority='--无--' where picklist_valueid=273;
update ld_projectpriority set projectpriority='低' where picklist_valueid=274;
update ld_projectpriority set projectpriority='一般' where picklist_valueid=275;
update ld_projectpriority set projectpriority='高' where picklist_valueid=276;


update ld_project set projectstatus='--无--' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=260);

update ld_project set projectstatus='调研' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=261);

update ld_project set projectstatus='开始' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=262);

update ld_project set projectstatus='进行中' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=263);


update ld_project set projectstatus='等待答复' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=264);

update ld_project set projectstatus='搁置' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=265);

update ld_project set projectstatus='已完成' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=266);

update ld_project set projectstatus='已交付' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=267);

update ld_project set projectstatus='已归档' 
where projectstatus=(select projectstatus from ld_projectstatus where picklist_valueid=268);

update ld_projectstatus set projectstatus='--无--' where picklist_valueid=260;
update ld_projectstatus set projectstatus='调研' where picklist_valueid=261;
update ld_projectstatus set projectstatus='开始' where picklist_valueid=262;
update ld_projectstatus set projectstatus='进行中' where picklist_valueid=263;
update ld_projectstatus set projectstatus='等待答复' where picklist_valueid=264;
update ld_projectstatus set projectstatus='搁置' where picklist_valueid=265;
update ld_projectstatus set projectstatus='已完成' where picklist_valueid=266;
update ld_projectstatus set projectstatus='已交付' where picklist_valueid=267;
update ld_projectstatus set projectstatus='已归档'  where picklist_valueid=268;


update ld_project set projecttype='--无--' 
where projecttype=(select projecttype from ld_projecttype where picklist_valueid=269);

update ld_project set projecttype='管理'
where projecttype=(select projecttype from ld_projecttype where picklist_valueid=270);

update ld_project set projecttype='操作'
where projecttype=(select projecttype from ld_projecttype where picklist_valueid=271);

update ld_project set projecttype='其他'
where projecttype=(select projecttype from ld_projecttype where picklist_valueid=272);

update ld_projecttype set projecttype='--无--' where picklist_valueid=269;
update ld_projecttype set projecttype='管理' where picklist_valueid=270;
update ld_projecttype set projecttype='操作' where picklist_valueid=271;
update ld_projecttype set projecttype='其他' where picklist_valueid=272;

update ld_project set progress='--无--' 
where progress=(select progress from ld_progress where picklist_valueid=277);

update ld_progress set progress='--无--' where picklist_valueid=277;


delete from ld_cvcolumnlist where cvid=48;
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,0,'LD_project:projectname:projectname:Project_Project_Name:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,1,'LD_project:project_no:project_no:Project_Project_No:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,2,'LD_project:accountid:account_id:Project_Account_Name:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,3,'LD_project:salesorderid:salesorder_id:Project_合同订单:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,4,'LD_project:projecttype:projecttype:Project_Type:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,5,'LD_project:projectstatus:projectstatus:Project_状态:V');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,6,'LD_project:startdate:startdate:Project_Start_Date:D');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,7,'LD_project:targetenddate:targetenddate:Project_Target_End_Date:D');
insert into ld_cvcolumnlist(cvid,columnindex,columnname) values(48,8,'LD_crmentity:smownerid:assigned_user_id:Project_项目负责人:V');


update ld_projecttask set projecttasktype='--无--' 
where projecttasktype=(select projecttasktype from ld_projecttasktype where picklist_valueid=241);

update ld_projecttask set projecttasktype='管理' 
where projecttasktype=(select projecttasktype from ld_projecttasktype where picklist_valueid=242);

update ld_projecttask set projecttasktype='操作'
where projecttasktype=(select projecttasktype from ld_projecttasktype where picklist_valueid=243);

update ld_projecttask set projecttasktype='其他'
where projecttasktype=(select projecttasktype from ld_projecttasktype where picklist_valueid=244);


update ld_projecttasktype set projecttasktype='--无--' where picklist_valueid=241;
update ld_projecttasktype set projecttasktype='管理' where picklist_valueid=242;
update ld_projecttasktype set projecttasktype='操作' where picklist_valueid=243;
update ld_projecttasktype set projecttasktype='其他' where picklist_valueid=244;

update ld_projecttask set projecttaskpriority='--无--' 
where projecttaskpriority=(select projecttaskpriority from ld_projecttaskpriority where picklist_valueid=245);

update ld_projecttask set projecttaskpriority='低' 
where projecttaskpriority=(select projecttaskpriority from ld_projecttaskpriority where picklist_valueid=246);


update ld_projecttask set projecttaskpriority='一般' 
where projecttaskpriority=(select projecttaskpriority from ld_projecttaskpriority where picklist_valueid=247);

update ld_projecttask set projecttaskpriority='高' 
where projecttaskpriority=(select projecttaskpriority from ld_projecttaskpriority where picklist_valueid=248);

update ld_projecttaskpriority set projecttaskpriority='--无--' where picklist_valueid=245;
update ld_projecttaskpriority set projecttaskpriority='低' where picklist_valueid=246;
update ld_projecttaskpriority set projecttaskpriority='一般' where picklist_valueid=247;
update ld_projecttaskpriority set projecttaskpriority='高' where picklist_valueid=248;

update ld_projecttask set projecttaskprogress='--无--' 
where projecttaskprogress=(select projecttaskprogress from ld_projecttaskprogress where picklist_valueid=249);

update ld_projecttaskprogress set projecttaskprogress='--无--' where picklist_valueid=249;


update ld_projectmilestone set projectmilestonetype='--无--' 
where projectmilestonetype=(select projectmilestonetype from ld_projectmilestonetype where picklist_valueid=237);

update ld_projectmilestone set projectmilestonetype='管理' 
where projectmilestonetype=(select projectmilestonetype from ld_projectmilestonetype where picklist_valueid=238);

update ld_projectmilestone set projectmilestonetype='操作' 
where projectmilestonetype=(select projectmilestonetype from ld_projectmilestonetype where picklist_valueid=239);

update ld_projectmilestone set projectmilestonetype='其他' 
where projectmilestonetype=(select projectmilestonetype from ld_projectmilestonetype where picklist_valueid=240);


update ld_projectmilestonetype set projectmilestonetype='--无--' where picklist_valueid=241;
update ld_projectmilestonetype set projectmilestonetype='管理' where picklist_valueid=242;
update ld_projectmilestonetype set projectmilestonetype='操作' where picklist_valueid=243;
update ld_projectmilestonetype set projectmilestonetype='其他' where picklist_valueid=244;

-- add 2014-02-24 by qiu
update ld_field set block = 9,displaytype = 2 where tabid = 6 and fieldname in ('approvestatus','approveby');
delimiter;
update ld_field set block = 106,displaytype = 2 where tabid = 47 and fieldname in ('approvestatus','approveby');
delimiter;
update ld_field set block = 109,displaytype = 2 where tabid = 48 and fieldname in ('approvestatus','approveby');
delimiter;
update ld_field set block = 17,displaytype = 2 where tabid = 8 and fieldname in ('approvestatus','approveby');
delimiter;

update ld_crmentity set setype='SendCashBill' where crmid  in(select  sendcashbillid from ld_sendcashbill);
update ld_field set presence=0 where columnname='salesorderid' and presence<>1 and tabid in(13,37,48);

update ld_languagepackage set tablabel = 'RecycleBin' where tabid = 49;
update ld_languagepackage set tablabel = 'ModComments' where tabid = 45;
delimiter;

-- add 2014-02-25 by li
/*销售机会共享保存表*/
CREATE TABLE if not EXISTS `ld_potential2userview` (
  `potentialid` int(11) default NULL,
  `AllViewUsers` varchar(200) default NULL,
  `shareuserid` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- add 2014-02-25 by huangjianchen
select tabid into @tabid from ld_tab where `name` = 'Invoice';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldlabel = '选择源单';
insert into ld_def_org_field(tabid,fieldid,visible,readonly)
select @tabid,@fieldid,0,0 from dual where not exists 
(select * from ld_def_org_field where tabid = @tabid and fieldid = @fieldid);

 
select tabid into @tabid from ld_tab where `name` = 'Stock';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldlabel = '选择源单';
insert into ld_def_org_field(tabid,fieldid,visible,readonly)
select @tabid,@fieldid,0,0 from dual where not exists 
(select * from ld_def_org_field where tabid = @tabid and fieldid = @fieldid);
 
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldlabel = '选择源单';
insert into ld_def_org_field(tabid,fieldid,visible,readonly)
select @tabid,@fieldid,0,0 from dual where not exists 
(select * from ld_def_org_field where tabid = @tabid and fieldid = @fieldid);

-- add 2014-02-25 by li
/*销售机会共享保存表*/
CREATE TABLE if not EXISTS `ld_potential2userview` (
  `potentialid` int(11) default NULL,
  `AllViewUsers` varchar(200) default NULL,
  `shareuserid` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- add 2014-02-26
ALTER TABLE LD_servicecontracts MODIFY COLUMN total_units decimal(3,0); 
ALTER TABLE LD_servicecontracts MODIFY COLUMN used_units decimal(3,0); 
delimiter;

call fieldprofile('Project');
call getallprofile('Project');
delimiter;
call fieldprofile('ServiceContracts');
call getallprofile('ServiceContracts');
delimiter;

-- add 2014-02-26 by andy
/*灵当CRM详细需求-附件管理序时簿*/

/*附件数据分类*/
select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='Faq');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',1, 0, 'Attachment',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='Attachment');
delimiter;
/*叙事簿列头*/
/*附件*/
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Attachment';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_attachmentsforbills:filename:filename:Attachment_附件:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_attachmentsforbills:filename:filename:Attachment%');
delimiter;
/*大小*/
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Attachment';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_attachmentsforbills:size:size:Attachment_大小:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_attachmentsforbills:size:size:Attachment%');
delimiter;
/*描述*/
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Attachment';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_attachmentsforbills:description:description:Attachment_描述:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_attachmentsforbills:description:description:Attachment%');
delimiter;
/*创建人*/
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Attachment';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_attachmentsforbills:creator:creator:Attachment_创建人:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_attachmentsforbills:creator:creator:Attachment%');
delimiter;
/*创建时间*/
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Attachment';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_attachmentsforbills:createdtime:createdtime:Attachment_创建时间:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_attachmentsforbills:createdtime:createdtime:Attachment%');
delimiter;
/*相关模块*/
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Attachment';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_attachmentsforbills:reltab:reltab:Attachment_相关模块:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_attachmentsforbills:reltab:reltab:Attachment%');
delimiter;
/*相关对象*/
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='Attachment';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_attachmentsforbills:related_to:related_to:Attachment_相关对象:V' 
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_attachmentsforbills:related_to:related_to:Attachment%');
delimiter;
/***********************************************/
/*新增字段 相关模块 相关对象*/
/*相关模块、对象*/
call addcolumn('ld_attachmentsforbills','reltab','varchar','100',null);
delimiter;
call addcolumn('ld_attachmentsforbills','related_to','int','11',null);
delimiter;
/*字段 表插入新字段*/
select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='reltab'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'reltab','ld_attachmentsforbills',1,1,'reltab','相关模块',1,2,'',100,3,@paymentplanid,2,'M',3,2,'BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='reltab'  and tabid=@tabid ) ;
delimiter;
select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='related_to'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'related_to','ld_attachmentsforbills',1,10,'related_to','相关对象',1,2,'',100,2,@paymentplanid,1,'V~O',3,3,'BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='related_to'  and tabid=@tabid ) ;
delimiter;
call fieldprofile('Attachment');
call getallprofile('Attachment');
delimiter;
/*********************/


/*补充脚本*/

/*select * from LD_fieldmodulerel;
desc LD_fieldmodulerel;*/
/*联系人*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Contacts'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Contacts' );
delimiter;
/*客户*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Accounts'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Accounts' );
delimiter;
/*销售机会*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Potentials'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Potentials' );
delimiter;
/*知识管理机会*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Documents'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Documents' );
delimiter;
/*联系记录*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','ContactRecords'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='ContactRecords' );
delimiter;
/*服务合同*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','ServiceContracts'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='ServiceContracts' );
delimiter;
/*服务单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','HelpDesk'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='HelpDesk' );
delimiter;
/*报价单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Quotes'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Quotes' );
delimiter;
/*合同订单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','SalesOrder'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='SalesOrder' );
delimiter;
/*市场活动*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Campaigns'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Campaigns' );
delimiter;
/*供应商*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Vendors'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Vendors' );
delimiter;
/*采购订单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','PurchaseOrder'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='PurchaseOrder' );
delimiter;
/*项目*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Project'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Project' );
delimiter;
/*项目任务*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','ProjectTask'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='ProjectTask' );
delimiter;
/*项目里程碑*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','ProjectMilestone'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='ProjectMilestone' );
delimiter;
/*收款单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','CashBill'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='CashBill' );
delimiter;
/*付款单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','SendCashBill'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='SendCashBill' );
delimiter;
/*费用报销*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Expense'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Expense' );
delimiter;
/*发票*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Invoice'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Invoice' );
delimiter;
/*出库单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','OutboundOrder'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='OutboundOrder' );
delimiter;
/*入库单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Stock'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Stock' );
delimiter;
/*盘点*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','Checks'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='Checks' );
delimiter;
/*付款单*/
SELECT fieldid into @fieldid  from ld_field where tabid in(select tabid from ld_tab  where name='Attachment') and columnname='related_to';
insert into LD_fieldmodulerel (fieldid,module,relmodule)
select @fieldid,'Attachment','SendCashBill'
from dual where  not exists(select 1 from LD_fieldmodulerel where fieldid=@fieldid and relmodule='SendCashBill' );
delimiter;

/*付款单增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='SendCashBill';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;


/*附件增加共享规则*/
select tabid into @tabid from LD_tab where name='Attachment' ;

insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);

select max(ruleid) into @ruleid from LD_def_org_share;

update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

insert into LD_def_org_share(ruleid,tabid,permission,editstatus)select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
delimiter;

-- add 2014-02-27 by lukan
/**服务合同中服务单老数据统计**/
UPDATE ld_servicecontracts 
LEFT JOIN(
SELECT count(*)as id,ld_crmentityrel.crmid 
from ld_crmentityrel 
LEFT JOIN ld_crmentity 
on ld_crmentity.crmid=ld_crmentityrel.relcrmid 
where ld_crmentity.deleted=0 
GROUP BY ld_crmentityrel.crmid) as m 
on m.crmid=ld_servicecontracts.servicecontractsid
set service_units=m.id;

/**合同订单更多信息添加服务合同**/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='SalesOrder';
select tabid into @relatedtabid from ld_tab where name='ServiceContracts';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_servicecontracts' and tabid=@id);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_servicecontracts',9,'ServiceContracts',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_servicecontracts' and tabid=@tabid);
delimiter;
/**合同订单更多信息中字段**/
select tabid into @tabid from lD_tab where name='ServiceContracts';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='ServiceContracts') and columnname='subject';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,1 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='ServiceContracts';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='ServiceContracts') and columnname='contract_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='ServiceContracts';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='ServiceContracts') and columnname='contract_status';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='ServiceContracts';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='ServiceContracts') and columnname='contract_type';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='ServiceContracts';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='ServiceContracts') and columnname='start_date';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='ServiceContracts';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='ServiceContracts') and columnname='end_date';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='ServiceContracts';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='ServiceContracts') and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

/**合同订单更多信息添加项目**/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='SalesOrder';
select tabid into @relatedtabid from ld_tab where name='Project';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_project' and tabid=@id);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_project',3,'Project',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_project' and tabid=@tabid);
delimiter;
/**项目更多信息中字段**/
select tabid into @tabid from lD_tab where name='Project';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Project') and columnname='subject';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,1 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='Project';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Project') and columnname='project_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='Project';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Project') and columnname='projectstatus';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='Project';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Project') and columnname='projecttype';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='Project';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Project') and columnname='startdate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='Project';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Project') and columnname='targetenddate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from lD_tab where name='Project';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Project') and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

-- add 2014-02-28 by andy
/*服务单增加服务合同字段id*/
call addcolumn('LD_troubletickets','servicecontractsid','int','11',null);
delimiter;
select tabid into @tabid from LD_tab where name='HelpDesk';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_TICKET_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='servicecontractsid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'servicecontractsid','LD_troubletickets',1,243,'servicecontractsid','服务合同',1,0,'',100,5,@paymentplanid,1,'I~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='servicecontractsid'  and tabid=@tabid ) ;
delimiter;
call fieldprofile('HelpDesk');
call getallprofile('HelpDesk');
/*系统参数*/
SELECT * from ld_systems_deploy;
insert into ld_systems_deploy (deploy_value,deploy_type,description)
select 30,24,"服务合同截止日期前Ｎ天提醒负责人（为0表示当天提醒，为空表示不提醒）" from dual where not exists(select 1 from ld_systems_deploy where deploy_type =24);
delimiter;

-- add 2014-02-28 by li
update  ld_field set  defaultvalue='thistoday'   where columnname='outdate' and  tabid in(SELECT tabid  from  ld_tab  where  name='OutboundOrder');
update  ld_field set  defaultvalue='thistoday'   where columnname='createdate' and  tabid in (SELECT tabid  from  ld_tab  where  name='Stock');

-- add 2014-02-28 by qiu
update ld_productbasevalues set value = 5 where type =1;
delimiter;

update ld_field set typeofdata='p~o'  where columnname='numcount' and tabid in (SELECT tabid from ld_tab WHERE name='Expense');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 1,25,'销售机会查看明细界面是否显示客户基本信息',NULL from dual where not exists 
(select * from ld_systems_deploy where deploy_type = 25);

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
update ld_tabwithproductview set columns = 'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D' where tabid = @tabid and columns = 'LD_purchaseorder:duedate:duedate:PurchaseOrder_交付日期:D';
select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
update ld_tabwithproductview set columns = 'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D' where tabid = @tabid and columns = 'LD_purchaseorder:duedate:duedate:PurchaseOrder_交付日期:D';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
update ld_field set tablename = 'LD_stock' where tabid = @tabid and columnname = 'currency_id';
update ld_tabwithproductview set `columns` = 'LD_stock:currency_id:currency_id:Stock_货币:N' where tabid = @tabid and `columns` like '%ld_outboundorder:currency_id:currency_id:Stock%';
update ld_tabwithproductview set `columns` = 'LD_inventoryproductrel:entitytypeid:entitytypeid:Products_源单:V' where `columns` like '%选择源单:V%';
delimiter;

-- add 2014-03-02 by can
insert into ld_ws_fieldtype(uitype,fieldtype) select 96,'reference' from dual where not EXISTS

(select 1 from ld_ws_fieldtype where uitype=96);

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=96;

insert into ld_ws_referencetype(fieldtypeid,type) select @fieldtypeid,'VendorContact' from DUAL

where not EXISTS(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='VendorContact');

update ld_entityname set fieldname='lastname' where modulename='VendorContact';

update ld_cvcolumnlist set columnname='LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_采购负责人:V' where 

cvid in(select cvid from ld_customview where viewname='all' and entitytype='purchaseorder') and columnname 

like '%LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_Total%';

-- add 2014-03-03 by li
update  ld_field set  defaultvalue='thistoday'   where columnname='cashbilldate' and  tabid in (SELECT tabid  from  ld_tab  where  name='SendCashBill');

update  ld_field set  defaultvalue='thistoday'   where columnname='contactdate' and  tabid in (SELECT tabid  from  ld_tab  where  name='VendorContactRecords');
update  ld_field set  defaultvalue='thistoday'   where columnname='signed_data' and  tabid in (SELECT tabid  from  ld_tab  where  name='SalesOrder');

-- add 2014-03-03 by can
update ld_entityname set fieldname='lastname'  where tablename='ld_contactdetails';

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='My Home Page';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid=@parenttabid;
select tabid into @tabid from ld_tab where name='Attachment';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 from dual 
where not exists (select 1 from ld_parenttabrel where tabid=@tabid); 
delimiter

-- add 2014-03-04 by luyx
select tabid into @tabid  from ld_tab where `name`='SalesBack';
update ld_tab set presence=1 where tabid=@tabid and not exists (select 1 from ld_version where versiontype=1);
delimiter


select tabid into @tabid  from ld_tab where `name`='CashBack';
update ld_tab set presence=1 where tabid=@tabid and not exists (select 1 from ld_version where versiontype=1);
delimiter


select tabid into @tabid  from ld_tab where `name`='SendPayment';
update ld_tab set presence=1 where tabid=@tabid and not exists (select 1 from ld_version where versiontype=1);
delimiter


select tabid into @tabid  from ld_tab where `name`='SendCashBill';
update ld_tab set presence=1 where tabid=@tabid and not exists (select 1 from ld_version where versiontype=1);
delimiter

select tabid into @tabid from ld_tab where `name`='ContactRecords';
update ld_field set presence=1 where tabid=@tabid and columnname in ('projectid','projecttaskid')
and not exists (select 1 from ld_version where versiontype=1);
delimiter

-- add 2014-03-04 by qiu
update LD_currency_info set currency_name = 'China, Yuan Renminbi' where id = 1;
update ld_currencies set currency_name = 'China, Yuan Renminbi' where currencyid = 13;
delimiter;

-- add 2014-03-05 by lukan
/**将原有统计排名排序到3**/
UPDATE LD_usereport set sequence=3 where name='SumSequence';

/**插入LD_usereport表增加表报链接**/
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','PurchaseReport','采购报表',0,0,0,0,0,2,0,''  
from dual where not exists(select 1 from LD_usereport where name='PurchaseReport');
delimiter;


select usereportid into @id from LD_usereport where name='PurchaseReport';
SELECT tabid into @tid from LD_tab where name='PurchaseOrder';

insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','PurchaseOrderTrack','{$PurchaseOrder}跟踪表',@tid,1,1,1,@id,3,10,180 
from dual where not exists(select usereportid from LD_usereport where name='PurchaseOrderTrack' and tabids=@tid);

insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','SendCashBillSum_PurchaseOrder','应付款统计表_按{$PurchaseOrder}统计',@tid,1,1,1,@id,6,10,180  
from dual where not exists(select usereportid from LD_usereport where name='SendCashBillSum_PurchaseOrder' and tabids=@tid);
delimiter;


SELECT tabid into @tid from LD_tab where name='SendPayment';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','SendCashBillSum_SendPayment','应付款统计表_按{$SendPayment}统计',@tid,1,1,1,@id,11,10,180  
from dual where not exists(select usereportid from LD_usereport where name='SendCashBillSum_SendPayment' and tabids=@tid);
delimiter;

/**插入LD_usereportbasic表设置$where搜索条件**/
/**采购订单跟踪表添加搜索时间**/
select usereportid into @id from LD_usereport where name='PurchaseOrderTrack';
delete from LD_usereportbasic where usereportid=@id;

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_signed_data:D','thisstartmonth~thisendmonth',3;


/**采购订单跟踪表添加搜索人**/
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_vendor:vendorname:vendorname:Vendors_VendorName:I','',6;
delimiter;


/**应付款统计表_按采购订单统计添加搜索时间**/
select usereportid into @id from LD_usereport where name='SendCashBillSum_PurchaseOrder';
delete from LD_usereportbasic where usereportid=@id;

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_PurchaseOrder:signed_data:signed_data:PurchaseOrder_signed_data:D','thisstartmonth~thisendmonth',3;  


/**应付款统计表_按采购订单统计添加搜索人**/
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_vendorPurchaseOrder:vendorname:vendor_id:PurchaseOrder_vendorname:I','',6;
delimiter;



/**应付款统计表_按付款计划统计统计添加搜索时间**/
select usereportid into @id from LD_usereport where name='SendCashBillSum_SendPayment';
delete from LD_usereportbasic where usereportid=@id;
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_SendPayment:Plandate:Plandate:SendPayment_Plandate:D','thisstartmonth~thisendmonth',3;

/**应付款统计表_按付款计划统计统计添加搜索人**/
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_vendorsendpayment:vendorname:vendor_id:sendpayment_vendorid:I','',6;  
delimiter;


/**采购订单跟踪表添加显示列名称**/
select usereportid into @id from LD_usereport where name='PurchaseOrderTrack';
delete from LD_UseReportcolumns where usereportid=@id;

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V', 7, 1, 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_采购订单_销售负责人:V';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_purchaseorder:purchaseorder_No:purchaseorder_No:PurchaseOrder_purchaseorder_No:V',6,1,'LD_purchaseorder:purchaseorder_No:purchaseorder_No:PurchaseOrder_采购订单-编号';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_purchaseorder_signed_data:D',6,1,'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_crmentity:createdtime:createdtime:PurchaseOrder_CreatedTime:DT',16,1,'LD_crmentity:createdtime:createdtime:PurchaseOrder_采购订单_创建时间:DT';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V',15,1,'LD_purchaseorder:subject:subject:PurchaseOrder_采购订单_主题:V';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_purchaseorder:postatus:postatus:PurchaseOrder_postatus:V',5,1,'LD_purchaseorder:postatus:postatus:PurchaseOrder_采购订单_订单状态:V';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_purchaseorder:duedate:duedate:PurchaseOrder_duedate:D',4,1,'LD_purchaseorder:duedate:duedate:PurchaseOrder_采购订单_交付日期:D';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_Total:N',9,1,'LD_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_采购订单_合计:N';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBillamount:N',11,1,'LD_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_付款单金额:N';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_vendor:vendorname:vendorname:Vendors_vendorname:V',11,1,'LD_vendor:vendorname:vendorname:Vendors_供应商:V';
delimiter;



/**应付款统计表_按采购订单统计添加显示列名称**/
select usereportid into @id from LD_usereport where name='SendCashBillSum_PurchaseOrder';
delete from LD_UseReportcolumns where usereportid=@id;

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V', 3, 1, 'LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder No:V', 11, 1, 'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder No:V';


insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_crmentity:createdtime:createdtime:PurchaseOrder_Created Time:DT', 12, 1, 'LD_crmentity:createdtime:createdtime:PurchaseOrder_Created Time:DT';


insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V', 5, 1, 'LD_purchaseorder:subject:subject:PurchaseOrder_Subject:V';


insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_purchaseorder:vendorid:vendorid:PurchaseOrder_vendorname:I', 6, 1, 'LD_purchaseorder:vendorid:vendorid:PurchaseOrder_vendorname:I';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V', 7, 1, 'LD_purchaseorder:postatus:postatus:PurchaseOrder_Status:V';


insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N', 8, 1, 'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_reporttable:CashBillamount:SendCashBillamount:oftenusereport_SendCashBillamount:N', 9, 1, 'ld_sendcashbill:SendCashBillamount:SendCashBillamount:oftenusereport_已付款金额:N';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'ld_sendcashbill:PaymentBalance:SendCashBillBalance:OftenUseReport_PaymentBalance:N', 10, 1, 'ld_sendcashbill:SendCashBillBalance:SendCashBillBalance:oftenusereport_应付款余额:N';
delimiter;


/**应付款统计表_按付款计划统计添加显示列名称**/
select usereportid into @id from LD_usereport where name='SendCashBillSum_SendPayment';
delete from LD_UseReportcolumns where usereportid=@id;

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_crmentity:smownerid:smownerid:SendPayment_smownerid:V', 7, 1, 'LD_crmentity:smownerid:smownerid:SendPayment_采购订单销售负责人:V';   
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '', @id, 'LD_vendor:vendorid:vendorid:SendPayment_vendorid:V', 7, 1, 'LD_vendor:vendorid:vendorid:SendPayment_采购订单_供应商:V';   

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_purchaseorder_signed_data:D',6,1,'LD_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D';    

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_purchaseorder_no:V',6,1,'LD_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_purchaseorder_no:V';    

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N',7,1,'LD_purchaseorder:total:hdnGrandTotal:PurchaseOrder_采购订单_合计:N:V';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_sendpayment_no:I',9,1,'LD_sendpayment:sendpayment_no:sendpayment_no:SendPayment_sendpayment_no:I';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D',8,1,'LD_sendpayment:plandate:plandate:SendPayment_plandate:D';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_sendpayment:Actualdate:Actualdate:SendPayment_Actualdate:V',11,1,'LD_sendpayment:Actualdate:Actualdate:SendPayment_Actualdate:V';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_sendpayment:amount:amount:SendPayment_amount:N',12,1,'LD_sendpayment:amount:amount:SendPayment_amount:N';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_sendpayment:actualamount:actualamount:SendPayment_actualamount:V',13,1,'LD_sendpayment:actualamount:actualamount:SendPayment_actualamount:V';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_sendpayment:CPStatus:CPStatus:SendPayment_CPStatus:V',14,1,'LD_sendpayment:CPStatus:CPStatus:SendPayment_CPStatus:V';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns) 
select '',@id,'LD_sendpayment:SendPaymentBalance:SendPaymentBalance:OftenUseReport_SendPaymentBalance:N',15,1,'LD_sendpayment:SendPaymentBalance:SendPaymentBalance:OftenUseReport_SendPaymentBalance:N';
delimiter;

-- add 2014-03-05 by qiu
update ld_field set defaultvalue='thistoday' 
where columnname='duedate' and tabid in (SELECT tabid from ld_tab where name='SalesOrder');

-- add 2014-03-05 
update ld_productfieldlist set fieldorder=fieldorder+2;
update ld_productfieldlist set fieldorder=1 where fieldid=174;

call addcolumn('LD_parenttab','menu_profieldid','varchar','255',null);
delimiter;

update ld_tab set printtab=0 where name ='SendCashBill';
-- add 2014-03-06 by luyx
select cvid into @cvid from ld_customview where entitytype='SalesOrder' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_salesorder:subject:subject:SalesOrder_主题:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder No:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_salesorder:sostatus:sostatus:SalesOrder_订单状态:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_salesorder:accountid:account_id:SalesOrder_客户名称:I';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_salesorder:duedate:duedate:SalesOrder_交付日期:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V';
delimiter;

select cvid into @cvid from ld_customview where entitytype='SalesOrder' and viewname like '%待审%' limit 1; 
update ld_cvadvfilter set columnname='LD_salesorder:approvestatus:approvestatus:SalesOrder_Approvestatus:V',`value`='审批中' where cvid=@cvid;
delimiter;


select cvid into @cvid from ld_customview where entitytype='SalesOrder' and viewname like '%已审%' limit 1; 
update ld_cvadvfilter set columnname='LD_salesorder:approvestatus:approvestatus:SalesOrder_Approvestatus:V',`value`='已批准' where cvid=@cvid;
delimiter;

select cvid into @cvid from ld_customview where entitytype='Invoice' and viewname like '%待审%' limit 1; 
update ld_cvadvfilter set columnname='LD_invoice:approvestatus:approvestatus:Invoice_Approvestatus:V',`value`='审批中' where cvid=@cvid;
delimiter;

select cvid into @cvid from ld_customview where entitytype='Invoice' and viewname like '%已审%' limit 1; 
update ld_cvadvfilter set columnname='LD_invoice:approvestatus:approvestatus:Invoice_Approvestatus:V',`value`='已批准' where cvid=@cvid;
delimiter;

-- add 2014-03-06
call addtabintoprofile('Attachment',0);
update lD_field set tablename='LD_attachmentsforbills' where tablename='ld_attachmentsforbills';

update lD_field set tablename='LD_account' where tablename='ld_account';
delete from ld_tabwithproductview where tabid=21 and sequence=5 and cvid=0;

call fieldprofile('ProjectTask');
call getallprofile('ProjectTask');
delimiter;

update  ld_field  set  uitype='1101'   where    columnname='phone_mobile'  and  tablename='LD_users';
update  ld_field  set  uitype='13'   where    columnname='email1'  and  tablename='LD_users'; 


select cvid into @cvid from ld_customview where entitytype='Expense' and viewname='已拒绝';
delete from ld_cvcolumnlist where cvid=@cvid;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_expense:expense_no:expense_no:Expense_Expense_No:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_expense:expensedate:expensedate:Expense_expensedate:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_expense:accountid:account_id:Expense_Account_Name:I';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_expense:salesorderid:salesorder_id:Expense_Sales_Order:I';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_expense:approvestatus:approvestatus:Expense_Approvestatus:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_expense:total:hdnGrandTotal:Expense_Total:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_crmentity:smownerid:assigned_user_id:Expense_报销人:V';

delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_expense:approvestatus:approvestatus:Expense_ApproveStatus:V','e','已拒绝',1,NUll;
insert into ld_cvadvfilter_grouping (groupid,cvid,group_condition,condition_expression)
select 1,@cvid,NULl,0;
delimiter;

update ld_languagepackage set chinesename='附件管理',newchinesename='附件管理' where tabid=(select tabid from ld_tab where `name`='Attachment') ;

-- add 2014-03-07 by luyx
update ld_field set typeofdata='I~O' where columnname='accountid' and tabid=(select tabid from ld_tab where `name`='ContactRecords');
select tabid into @tabid from ld_tab where `name`='SalesBack';
insert into ld_templateprint(printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select 'SalesBackDefault.html',@tabid,1,'销售退货单预置模板',1 from dual 
where not exists (select 1 from ld_templateprint where Tabid=@tabid and printfilename='SalesBackDefault.html');
delimiter;

select tabid into @tabid from ld_tab where `name`='Checks';
insert into ld_templateprint(printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select 'ChecksDefault.html',@tabid,1,'盘点预置模板',1 from dual 
where not exists (select 1 from ld_templateprint where Tabid=@tabid and printfilename='ChecksDefault.html');
delimiter;


update ld_inventoryproductrel inner join 
			 (select out_id,salesorderid from ld_outboundorder where salesorderid>0) as t3 on ld_inventoryproductrel.id=t3.out_id
set ld_inventoryproductrel.entitytypeid=t3.salesorderid;


update  ld_field set  defaultvalue='thistoday'   where columnname='cashbackdate' and  tabid in (SELECT tabid  from  ld_tab  where  name='CashBack');

update ld_tabwithproductview  set `columns`='LD_salesorder:adjustment:txtAdjustment:SalesOrder_调整:N'  
where `columns`='LD_salesorder:adjustment:txt调整:SalesOrder_调整:N';

update ld_def_org_share set editstatus=0 where tabid=9;

update ld_inventoryproductrel inner join 
      (select entitytypeid,productid,sum(quantity) as sum1 from ld_inventoryproductrel 
             where id in (select out_id from ld_outboundorder)group by entitytypeid,productid) as t2 
      on ld_inventoryproductrel.id=t2.entitytypeid and ld_inventoryproductrel.productid=t2.productid 
set ld_inventoryproductrel.haveoutproductcount=t2.sum1
where ld_inventoryproductrel.id in (select salesorderid from ld_salesorder);

update ld_inventoryproductrel set balanceoutproductcount=quantity-ifnull(haveoutproductcount,0)
 where id in(select salesorderid from ld_salesorder);

update ld_inventoryproductrel inner join 
      (select entitytypeid,productid,sum(quantity) as sum1 from ld_inventoryproductrel 
             where id in (select purchaseorderid from ld_purchaseorder inner join ld_crmentity
													 on ld_crmentity.crmid=ld_purchaseorder.purchaseorderid  where ld_crmentity.deleted=0 )group by entitytypeid,productid) as t1 
      on ld_inventoryproductrel.id=t1.entitytypeid and ld_inventoryproductrel.productid=t1.productid 
set ld_inventoryproductrel.havepurchasecount=t1.sum1
where ld_inventoryproductrel.id in (select salesorderid from ld_salesorder);

update ld_inventoryproductrel set balancepurchasecount=quantity-ifnull(havepurchasecount,0) 
where id in(select salesorderid from ld_salesorder);

update ld_currency_info set currency_name='人民币'  where id=1;

update ld_tabwithproductview set `columns`='LD_salesorder:total:hdnGrandTotal:SalesOrder_合计:N'
 where tabid=22 and `columns`='LD_salesorder:total:hdnGrand合计:SalesOrder_合计:N';

update ld_salesorder set stockpresence='全部出库'  where salesorderid not in (select id from ld_inventoryproductrel where balanceoutproductcount>0);
update ld_salesorder set purchaseStatus='全部采购'  where salesorderid not in (select id from ld_inventoryproductrel where balancepurchasecount>0);

update ld_field set displaytype=1 where tabid=22 and columnname='duedate';

update ld_relatedlists set actions=NUll where tabid=14 and name='get_product_pricebooks';

-- add 2014-03-10 
call AddColumn('LD_modentity_num','UseUserAccount','int',2,0);
delimiter;
call AddColumn('LD_accountscf','lastserviceenddate','date',100,NULL);
delimiter;
select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @endtime from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_INFORMATION';

delete from ld_field where tabid=6 and  columnname='lastserviceenddate' ;
call AddColumn('LD_modentity_num','UseUserAccount','int',2,0);
delimiter;
call AddColumn('LD_accountscf','lastserviceenddate','date',100,NULL);
delimiter;
select tabid into @tabid from LD_tab where name='Accounts';
select blockid into @endtime from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_INFORMATION';

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='lastserviceenddate' and tablename='LD_accountscf' );

insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'lastserviceenddate','LD_accountscf',1,70,'lastserviceenddate','服务到期日',1,0,'',100,4,@endtime,2,'D~O',1,'0','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='lastserviceenddate'  and tablename='LD_accountscf');
call fieldprofile('Accounts');
call getallprofile('Accounts');
delimiter;

update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Accounts';
select tabid into @relatedtabid from ld_tab where name='OutboundOrder';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_outorder');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_outorder',10,'OutboundOrder',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_outorder' and tabid=@tabid);
delimiter;

UPDATE ld_field set typeofdata = 'V~M' where columnname='filename' and tablename='LD_attachmentsforbills' AND fieldname='filename';
delimiter;

update ld_tab set presence=0 where tabid=35;

update ld_field set presence=2 where presence=0 and tabid=6 and columnname in ('lastserviceenddate','salutation','title','pphone','faxx','email','mailingzip','mailingstreet');
update ld_field set presence=2 where presence=0 and tabid=9 and columnname in ('description');
update ld_field set presence=2 where presence=0 and tabid=13 and columnname in ('salesorderid','servicecontractsid');
update ld_field set presence=2 where presence=0 and tabid=14 and columnname in ('vendor_id','qtyearly','qtyinstock');
update ld_field set presence=2 where presence=0 and tabid=21 and columnname in ('stockpresence');
update ld_field set presence=2 where presence=0 and tabid=22 and columnname in ('stockpresence','purchaseStatus');
update ld_field set presence=2 where presence=0 and tabid=(select tabid from ld_tab where name='Expense') and columnname in ('potentialid','salesorderid','numcount');
update ld_field set presence=2 where presence=0 and tabid=(select tabid from ld_tab where name='OutboundOrder') and columnname in ('outdate','remark');
update ld_field set presence=2 where presence=0 and tabid=(select tabid from ld_tab where name='Stock') and columnname in ('createdate','remark');
update ld_field set presence=2 where presence=0 and tabid=(select tabid from ld_tab where name='Checks') and columnname in ('checksdate','remark');
update ld_field set presence=2 where presence=0 and tabid=(select tabid from ld_tab where name='VendorContactRecords') and columnname in ('contactdate');
update ld_field set presence=2 where presence=0 and tabid=(select tabid from ld_tab where name='ContactRecords') and columnname in ('potentialid');

update ld_crmentity set setype='SendCashBill' where crmid  in(select  sendcashbillid from ld_sendcashbill);

call fieldprofile('OutboundOrder');
call fieldprofile('Stock');
call fieldprofile('Accounts');
call fieldprofile('Potentials');
call fieldprofile('SalesOrder');
call fieldprofile('ServiceContracts');
call fieldprofile('ProjectMilestone');
call fieldprofile('ProjectTask');
call fieldprofile('Project');


select tabid into @tabid from ld_tab where `name` = 'Stock';
update ld_tabwithproductview set `columns` = 'LD_stock:total:hdnGrandTotal:Stock_合计:N' where tabid = @tabid and `columns` = 'LD_stock:total:hdnGrand合计:Stock_合计:N';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
update ld_tabwithproductview set `columns` = 'LD_outboundorder:total:hdnGrandTotal:OutboundOrder_合计:N' where tabid = @tabid and `columns` = 'LD_outboundorder:total:hdnGrand合计:OutboundOrder_合计:N';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
update ld_tabwithproductview set `columns` = 'LD_invoice:total:hdnGrandTotal:Invoice_合计:N' where tabid = @tabid and `columns` = 'LD_invoice:total:hdnGrand合计:Invoice_合计:N';
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;
update lD_version set old_version='V5.2' ,current_version='V5.2' ,remark='V5.2-20140313';
delimiter;