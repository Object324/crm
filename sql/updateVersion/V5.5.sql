CREATE TABLE if not EXISTS `ld_purchaseback` (
  `purchasebackid` int(19) NOT NULL,
  `purchaseback_no` varchar(100) default NULL,
  `purchasebackdate` date default NULL,
  `purchaseorder_id` int(19) default '0',
  `vendorid` int(19) default '0',
  `wareid` int(19) default '0',
  `purchasebackstatus` varchar(20) default NULL,
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
  PRIMARY KEY  (`purchasebackid`),
  KEY `idx_purchasebackstatus_purchaseback` USING BTREE (`purchasebackstatus`),
  CONSTRAINT `fk_1_lingdang_purchaseback` FOREIGN KEY (`purchasebackid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE if not EXISTS `ld_purchasebackscf` (
  `purchasebackid` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

select max(tabid)+1 into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
select id into @id from ld_version where versiontype = 2;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'PurchaseBack',case when @id != '' then 1 else 0 end,@tabsequence+1,'PurchaseBack',1,'Finacial',0
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='PurchaseBack');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Purchase';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'采购退货单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='采购退货单');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'PurchaseBack'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='PurchaseBack');

insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'PurchaseBack','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'PurchaseBack' );
delimiter;

call fieldprofile('PurchaseBack');
call addtabintoprofile('PurchaseBack',0);

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);

select tabid into @tabid from LD_tab where name='PurchaseBack' ;
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

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PURCHASEBACK_INFO',1 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_PURCHASEBACK_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PURCHASEBACK_DESCRIPTION',2 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_PURCHASEBACK_DESCRIPTION' and sequence = 2);
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASEBACK_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'基本信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='基本信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Basic Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Basic Information');

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASEBACK_DESCRIPTION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'描述信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='描述信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Description Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Description Information');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASEBACK_INFO';

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'purchaseback_no','LD_purchaseback',4,'purchaseback_no','采购退货单编号',@blockid,1,0,'V~O',0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchaseback_no');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,defaultvalue,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'purchasebackdate','LD_purchaseback',5,'purchasebackdate','退货日期',@blockid,1,0,'D~M','thistoday',1
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchasebackdate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'vendorid','LD_purchaseback',81,'vendor_id','供应商名称',@blockid,1,0,'I~M',2
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'vendorid');

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASEBACK_INFO';
delete from ld_field where tabid = @tabid and columnname = 'purchaseorder_id';
delete from ld_field where tabid = @tabid and columnname = 'purchaseorderid';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'purchaseorder_id','LD_purchaseback',150,'purchaseorder_id','采购订单',@blockid,1,0,'I~O',3
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchaseorder_id');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'wareid','LD_purchaseback',151,'wareid','仓库',@blockid,1,0,'V~M',4
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'wareid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'purchasebackstatus','LD_purchaseback',2,'purchasebackstatus','状态',@blockid,2,0,'V~O',5
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchasebackstatus');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'havebackamount','LD_purchaseback',7,'havebackamount','已退款',@blockid,2,0,'N~O',6
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'havebackamount');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'total','LD_purchaseback',7,'hdnGrandTotal','应退款',@blockid,2,0,'N~O',7
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','LD_crmentity',53,'assigned_user_id','负责人',@blockid,1,0,'V~O',8
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','LD_crmentity',70,'modifiedtime','修改时间',@blockid,2,0,'DT~O',9
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','LD_crmentity',70,'createdtime','创建时间',@blockid,2,0,'DT~O',10
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','LD_crmentity',52,'modifiedby','最新更新人',@blockid,2,0,'V~O',11
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedby');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','LD_crmentity',52,'smcreatorid','创建人',@blockid,2,0,'V~O',12
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'taxtype','LD_purchaseback',16,'hdnTaxType','Tax Type',@blockid,3,0,'N~O',13
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'taxtype');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'currency_id','LD_purchaseback',117,'currency_id','货币',@blockid,3,0,'I~O',14
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'currency_id');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'conversion_rate','LD_purchaseback',1,'conversion_rate','汇率',@blockid,3,0,'V~O',15
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'conversion_rate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'subtotal','LD_purchaseback',72,'hdnSubTotal','Sub Total',@blockid,3,0,'N~O',16
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_percent','LD_purchaseback',1,'hdnDiscountPercent','Discount Percent',@blockid,3,0,'N~O',17
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'discount_percent');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_amount','LD_purchaseback',1,'hdnDiscountAmount','Discount Amount',@blockid,3,0,'N~O',18
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'discount_amount');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'s_h_amount','LD_purchaseback',72,'hdnS_H_Amount','运费和物流附加费',@blockid,3,0,'N~O',19
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 's_h_amount');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'adjustment','LD_purchaseback',72,'txtAdjustment','Adjustment',@blockid,3,0,'NN~O',20
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'adjustment');
delimiter;

select tabid into @tabid from LD_tab where name='PurchaseBack';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_PURCHASEBACK_DESCRIPTION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'description','LD_crmentity',19,'description','退货原因',@blockid,1,0,'V~O',0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'description');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchaseback_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'采购退货单编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'PurchaseBack No'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchasebackdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'退货时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'PurchaseBack Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'供应商名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Vendor Name'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchaseorder_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'采购订单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Purchase Order'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'wareid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'仓库'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Warehouse'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchasebackstatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Status'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'havebackamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'已退款'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Refunded'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'应退款'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Should Refund'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Created Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Creator'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnTaxType';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'税种' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Tax Type' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'货币' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'conversion_rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'汇率' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Exchange Rate' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnSubTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'小计' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Sub Total' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountPercent';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣百分比' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Percent' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountAmount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣直接降价' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Amount' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnS_H_Amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'运费和物流附加费' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'S&H Amount' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'txtAdjustment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'调整' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Adjustment' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'退货原因'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'PurchaseBack','CGTHD',1,2,1,'none'
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'PurchaseBack'
and prefix ='CGTHD');
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'PurchaseBack',0,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All'
and entitytype ='PurchaseBack');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PurchaseBack' and viewname = 'All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseback:purchaseback_no:purchaseback_no:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseback:purchasebackdate:purchasebackdate:PurchaseBack_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseback:vendorid:vendor_id:PurchaseBack_供应商名称:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseback:purchaseorder_id:purchaseorder_id:PurchaseBack_purchaseorder_id:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseback:total:hdnGrandTotal:PurchaseBack_应退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseback:havebackamount:havebackamount:PurchaseBack_已退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V';
delimiter;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'未出库',0,'PurchaseBack',3,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '未出库' and entitytype ='PurchaseBack');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PurchaseBack' and viewname = '未出库';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseback:purchaseback_no:purchaseback_no:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseback:purchasebackdate:purchasebackdate:PurchaseBack_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseback:vendorid:vendor_id:PurchaseBack_供应商名称:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseback:purchaseorder_id:purchaseorder_id:PurchaseBack_purchaseorder_id:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseback:total:hdnGrandTotal:PurchaseBack_应退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseback:havebackamount:havebackamount:PurchaseBack_已退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V';

delete from ld_cvadvfilter where cvid=@cvid;
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) 
select @cvid,0,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_purchasebackstatus:V' ,'e','未出库',1,'' ;

delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','';
delimiter;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'已出库',0,'PurchaseBack',3,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '已出库'
and entitytype ='PurchaseBack');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PurchaseBack' and viewname = '已出库';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseback:purchaseback_no:purchaseback_no:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseback:purchasebackdate:purchasebackdate:PurchaseBack_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseback:vendorid:vendor_id:PurchaseBack_供应商名称:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseback:purchaseorder_id:purchaseorder_id:PurchaseBack_purchaseorder_id:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseback:total:hdnGrandTotal:PurchaseBack_应退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseback:havebackamount:havebackamount:PurchaseBack_已退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V';

delete from LD_cvadvfilter where cvid=@cvid;
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) 
select @cvid,0,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_purchasebackstatus:V' ,'e','已出库',1,'';

delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','';

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'结束',0,'PurchaseBack',3,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '结束'
and entitytype ='PurchaseBack');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PurchaseBack' and viewname = '结束';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseback:purchaseback_no:purchaseback_no:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseback:purchasebackdate:purchasebackdate:PurchaseBack_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseback:vendorid:vendor_id:PurchaseBack_供应商名称:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseback:purchaseorder_id:purchaseorder_id:PurchaseBack_purchaseorder_id:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseback:total:hdnGrandTotal:PurchaseBack_应退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseback:havebackamount:havebackamount:PurchaseBack_已退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V';

delete from LD_cvadvfilter where cvid=@cvid;
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_purchasebackstatus:V' ,'e','结束',1,'';

delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','';

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'中止',0,'PurchaseBack',3,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '中止'
and entitytype ='PurchaseBack');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PurchaseBack' and viewname = '中止';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchaseback:purchaseback_no:purchaseback_no:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchaseback:purchasebackdate:purchasebackdate:PurchaseBack_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_purchaseback:vendorid:vendor_id:PurchaseBack_供应商名称:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_purchaseback:purchaseorder_id:purchaseorder_id:PurchaseBack_purchaseorder_id:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_purchaseback:total:hdnGrandTotal:PurchaseBack_应退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchaseback:havebackamount:havebackamount:PurchaseBack_已退款:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V';

delete from ld_cvadvfilter where cvid=@cvid;
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) 
select @cvid,0,'LD_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_purchasebackstatus:V' ,'e','中止',1,'';

delete from ld_cvadvfilter_grouping where cvid=@cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','';

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'PurchaseBack','LD_purchaseback','purchaseback_no','purchasebackid','purchasebackid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid
and modulename ='PurchaseBack');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'PurchaseBack';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid and visible =1);
delimiter;

update ld_tab set tabsequence = 43 where name ='PurchaseBack';
update ld_tab set tabsequence = 44 where name ='VendorContact';
update ld_tab set tabsequence = 45 where name ='VendorContactRecords';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DELIVERYCONFIRMATION','出库确认','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELIVERYCONFIRMATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DELIVERYCONFIRMATION','Delivery confirmation','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DELIVERYCONFIRMATION' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PURCHASEENDRETURN1','当前单据状态为“已出库”','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PURCHASEENDRETURN1' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PURCHASEENDRETURN1','The current document status as "outbound"','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEENDRETURN1' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PURCHASEENDRETURN2','当前单据状态为“未出库”','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PURCHASEENDRETURN2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PURCHASEENDRETURN2','The current document status as "not a library"','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEENDRETURN2' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HOWTOPURCHASERETURN','如何采购退货','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='HOWTOPURCHASERETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HOWTOPURCHASERETURN','How to purchase return','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='HOWTOPURCHASERETURN' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RETURNPURCHASE1','采购是针对{$PurchaseOrder.PurchaseOrder}的，不允许直接创建','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RETURNPURCHASE1' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RETURNPURCHASE1','PurchaseBack are for PurchaseOrder, does not allow direct creation','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RETURNPURCHASE1' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RETURNPURCHASE2','在{$PurchaseOrder.PurchaseOrder}序时簿先找到需要退货的订单，在订单查看界面单击右边操作按钮“办理退货”即可','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RETURNPURCHASE2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RETURNPURCHASE2','When PurchaseOrder first find the need to return order book orders, in order to see the right operator interface, click the button handle returns to','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RETURNPURCHASE2' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RETURNPURCHASE3','只有已经出库的订单允许办理退货','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RETURNPURCHASE3' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RETURNPURCHASE3','Only orders have been allowed in of the library handle returns','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RETURNPURCHASE3' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel = '销售退货是针对{$SalesOrder.SalesOrder}的，不允许直接创建' where labelbol = 'Returns_SalesOrder_allow_creation' and languagetype = 'zh';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select tabid into @retabid from ld_tab where `name` = 'PurchaseBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@retabid,0,0,'' from dual where not EXISTS
(select 1 from ld_quickactions  where tabid = @tabid and related_tabid =@retabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PURCHASEORDEROUTNOALLOWRETURN','该{$PurchaseOrder.PurchaseOrder}还未入库，不允许办理退货！','jspop'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PURCHASEORDEROUTNOALLOWRETURN' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PURCHASEORDEROUTNOALLOWRETURN','The {$PurchaseOrder.PurchaseOrder} not yet out of the library, do not allow for return!','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEORDEROUTNOALLOWRETURN' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PURCHASEORDERFULLYOUTNOALLOWRETURN','该{$PurchaseOrder.PurchaseOrder}已全部退货，不允许办理退货。','jspop'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PURCHASEORDERFULLYOUTNOALLOWRETURN' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PURCHASEORDERFULLYOUTNOALLOWRETURN','The PurchaseOrder has been fully returned orders, handle returns are not allowed.','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEORDERFULLYOUTNOALLOWRETURN' and Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseBack';
select tabid into @relatedtabid from ld_tab where name='PurchaseCashBack';
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_purchasecashback',1,'PurchaseCashBack',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_purchasecashback' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseBack';
select tabid into @relatedtabid from ld_tab where name='Attachment';
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_attachment',2,'Attachment',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseBack';
select tabid into @tabid2 from ld_tab where name = 'PurchaseCashBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseBack';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,1 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

CREATE TABLE if not EXISTS `ld_purchasecashback` (
  `purchasecashbackid` int(19) NOT NULL,
  `purchasecashback_no` varchar(100) default NULL,
  `purchasecashbackdate` date default NULL,
  `purchaseback_id` int(19) default '0',
  `vendorid` int(19) default '0',
  `crpaymentmethod` varchar(100) default NULL,
	`bankaccountsetid` int(19) default '0',
	`taxtype` varchar(25) default NULL,
	`currency_id` int(19) NOT NULL default '1',
	`conversion_rate` decimal(25,3) default NULL,
  `total` decimal(25,2) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `discount_percent` decimal(25,2) default NULL,
  `discount_amount` decimal(25,2) default NULL,
  `s_h_amount` decimal(25,2) default NULL,
	`adjustment` decimal(25,2) default NULL,
  PRIMARY KEY  (`purchasecashbackid`),
  KEY `idx_crpayment_purchasecashback` USING BTREE (`crpaymentmethod`),
  CONSTRAINT `fk_1_lingdang_purchasecashback` FOREIGN KEY (`purchasecashbackid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE if not EXISTS `ld_purchasecashbackscf` (
  `purchasecashbackid` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

select max(tabid)+1 into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
select id into @id from ld_version where versiontype = 2;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'PurchaseCashBack',case when @id != '' then 1 else 0 end,@tabsequence+1,'PurchaseCashBack',1,'Finacial',0
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='PurchaseCashBack');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Finacial';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'采购退款单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='采购退款单');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'PurchaseCashBack'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='PurchaseCashBack');


insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'PurchaseCashBack','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'PurchaseCashBack' );
delimiter;

call fieldprofile('PurchaseCashBack');
call addtabintoprofile('PurchaseCashBack',0);

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);

select tabid into @tabid from LD_tab where name='PurchaseCashBack' ;
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

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PURCHASECASHBACK_INFO',1 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_PURCHASECASHBACK_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PURCHASECASHBACK_DESCRIPTION',2 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_PURCHASECASHBACK_DESCRIPTION' and sequence = 2);
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASECASHBACK_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'基本信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='基本信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Basic Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Basic Information');

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASECASHBACK_DESCRIPTION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'描述信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='描述信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Description Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Description Information');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASECASHBACK_INFO';

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'purchasecashback_no','LD_purchasecashback',4,'purchasecashback_no','采购退款单编号',@blockid,1,0,'V~O',0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchasecashback_no');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,defaultvalue,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'purchasecashbackdate','LD_purchasecashback',5,'purchasecashbackdate','退款日期',@blockid,1,0,'D~M','thistoday',1
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchasecashbackdate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'vendorid','LD_purchasecashback',81,'vendor_id','供应商名称',@blockid,1,0,'I~M',2
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'vendorid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'purchaseback_id','LD_purchasecashback',801,'purchaseback_id','退货单',@blockid,1,0,'I~M',3
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchaseback_id');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'crpaymentmethod','LD_purchasecashback',15,'crpaymentmethod','退款方式',@blockid,1,0,'V~O',4
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'crpaymentmethod');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'bankaccountsetid','LD_purchasecashback',251,'bankaccountsetid','账号',@blockid,1,0,'V~O',5
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'bankaccountsetid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'total','LD_purchasecashback',7,'hdnGrandTotal','合计',@blockid,2,0,'N~O',7
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','LD_crmentity',53,'assigned_user_id','负责人',@blockid,1,0,'V~O',8
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','LD_crmentity',70,'modifiedtime','修改时间',@blockid,2,0,'DT~O',9
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','LD_crmentity',70,'createdtime','创建时间',@blockid,2,0,'DT~O',10
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','LD_crmentity',52,'modifiedby','最新更新人',@blockid,2,0,'V~O',11
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedby');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','LD_crmentity',52,'smcreatorid','创建人',@blockid,2,0,'V~O',12
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'taxtype','LD_purchasecashback',16,'hdnTaxType','Tax Type',@blockid,3,0,'N~O',13
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'taxtype');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'currency_id','LD_purchasecashback',117,'currency_id','货币',@blockid,3,0,'I~O',14
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'currency_id');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'conversion_rate','LD_purchasecashback',1,'conversion_rate','汇率',@blockid,3,0,'V~O',15
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'conversion_rate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'subtotal','LD_purchasecashback',72,'hdnSubTotal','Sub Total',@blockid,3,0,'N~O',16
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_percent','LD_purchasecashback',1,'hdnDiscountPercent','Discount Percent',@blockid,3,0,'N~O',17
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'discount_percent');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_amount','LD_purchasecashback',1,'hdnDiscountAmount','Discount Amount',@blockid,3,0,'N~O',18
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'discount_amount');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'s_h_amount','LD_purchasecashback',72,'hdnS_H_Amount','运费和物流附加费',@blockid,3,0,'N~O',19
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 's_h_amount');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'adjustment','LD_purchasecashback',72,'txtAdjustment','Adjustment',@blockid,3,0,'NN~O',20
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'adjustment');
delimiter;

select tabid into @tabid from LD_tab where name='PurchaseCashBack';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_PURCHASECASHBACK_DESCRIPTION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'description','LD_crmentity',19,'description','退款原因',@blockid,1,0,'V~O',0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'description');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchasecashback_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'采购退款单编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'PurchaseCashBack No'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchasecashbackdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'退款日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'PurchaseCashBack Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'供应商名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Vendor Name'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchaseback_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'采购退货单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'PurchaseCashBack No'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'crpaymentmethod';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'退款方式'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Method of refund'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'bankaccountsetid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'账户'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Bank Accounts'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnGrandTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'总计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Should Refund'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Created Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Creator'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnTaxType';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'税种' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Tax Type' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'货币' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'conversion_rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'汇率' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Exchange Rate' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnSubTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'小计' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Sub Total' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountPercent';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣百分比' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Percent' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountAmount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣直接降价' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Amount' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnS_H_Amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'运费和物流附加费' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'S&H Amount' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'txtAdjustment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'调整' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Adjustment' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'退货原因'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'PurchaseCashBack','CGTKD',1,2,1,'none'
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'PurchaseCashBack'
and prefix ='CGTKD');
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);


insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'PurchaseCashBack',0,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All'
and entitytype ='PurchaseCashBack');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PurchaseCashBack' and viewname = 'All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_purchasecashback:purchasecashback_no:purchasecashback_no:PurchaseCashBack_fieldlabel:V'
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid
and columnindex =0 and columnname = 'LD_purchasecashback:purchasecashback_no:purchasecashback_no:PurchaseCashBack_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_purchasecashback:purchasecashbackdate:purchasecashbackdate:PurchaseCashBack_fieldlabel:D'
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid
and columnindex =1 and columnname = 'LD_purchasecashback:purchasecashbackdate:purchasecashbackdate:PurchaseCashBack_fieldlabel:D');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_purchasecashback:total:hdnGrandTotal:PurchaseCashBack_fieldlabel:N'
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid
and columnindex =2 and columnname = 'LD_purchasecashback:total:hdnGrandTotal:PurchaseCashBack_fieldlabel:N');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_purchasecashback:bankaccountsetid:bankaccountsetid:PurchaseCashBack_fieldlabel:V'
from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid
and columnindex =3 and columnname = 'LD_purchasecashback:bankaccountsetid:bankaccountsetid:PurchaseCashBack_fieldlabel:V');

insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_purchasecashback:crpaymentmethod:crpaymentmethod:PurchaseCashBack_fieldlabel:V'
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid
and columnindex =4 and columnname = 'LD_purchasecashback:crpaymentmethod:crpaymentmethod:PurchaseCashBack_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_purchasecashback:vendorid:vendor_id:PurchaseCashBack_fieldlabel:V'
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid
and columnindex =5 and columnname = 'LD_purchasecashback:vendorid:vendor_id:PurchaseCashBack_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_purchasecashback:purchaseback_id:purchaseback_id:PurchaseCashBack_fieldlabel:V'
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid
and columnindex =6 and columnname = 'LD_purchasecashback:purchaseback_id:purchaseback_id:PurchaseCashBack_fieldlabel:V');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PurchaseCashBack_fieldlabel:V'
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid
and columnindex =7 and columnname = 'LD_crmentity:smownerid:assigned_user_id:PurchaseCashBack_fieldlabel:V');

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'PurchaseCashBack','LD_purchasecashback','purchasecashback_no','purchasecashbackid','purchasecashbackid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid
and modulename ='PurchaseCashBack');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'PurchaseCashBack';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid and visible =1);
delimiter;

update ld_tab set tabsequence = 75 where name ='PurchaseCashBack';
update ld_tab set tabsequence = 76 where name ='PaymentPlan';
update ld_tab set tabsequence = 77 where name ='SendPayment';
update ld_tab set tabsequence = 78 where name ='PutCash';
update ld_tab set tabsequence = 79 where name ='CashDeposit';
update ld_tab set tabsequence = 80 where name ='Expense';
update ld_tab set tabsequence = 81 where name ='BankCash';
update ld_tab set tabsequence = 82 where name ='OftenUseReport';
update ld_tab set tabsequence = 83 where name ='BankAccountSet';
update ld_tab set tabsequence = 84 where name ='Dashboard';
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseCashBack';
select tabid into @relatedtabid from ld_tab where name='Attachment';
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_attachment',2,'Attachment',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseCashBack';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;
update ld_parenttabrel set sequence = 5 where tabid = (select tabid from ld_tab where name ='PurchaseCashBack') and parenttabid=9;
update ld_parenttabrel set sequence = 6 where tabid = (select tabid from ld_tab where name ='PaymentPlan') and parenttabid=9;
update ld_parenttabrel set sequence = 7 where tabid = (select tabid from ld_tab where name ='SendPayment') and parenttabid=9;
update ld_parenttabrel set sequence = 8 where tabid = (select tabid from ld_tab where name ='Expense') and parenttabid=9;
update ld_parenttabrel set sequence = 9 where tabid = (select tabid from ld_tab where name ='Commission') and parenttabid=9;
update ld_parenttabrel set sequence = 10 where tabid = (select tabid from ld_tab where name ='PutCash') and parenttabid=9;
update ld_parenttabrel set sequence = 11 where tabid = (select tabid from ld_tab where name ='CashDeposit') and parenttabid=9;
update ld_parenttabrel set sequence = 12 where tabid = (select tabid from ld_tab where name ='BankCash') and parenttabid=9;
update ld_parenttabrel set sequence = 13 where tabid = (select tabid from ld_tab where name ='BankAccountSet') and parenttabid=9;
delimiter;

update ld_tranlabel set fieldlabel = '审批人' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'ContactRecords') and
Relateid in (select fieldid from LD_field where columnname= 'approveby' and tabid in (select tabid from ld_tab where name = 'ContactRecords') );
delimiter;

DROP PROCEDURE IF EXISTS AddColumn;
delimiter ||
CREATE PROCEDURE AddColumn(
	tablename VARCHAR(50),
	columnname VARCHAR(50),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
		ELSEIF isdefault=0 THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default 0 ');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
END ||
delimiter;

DROP PROCEDURE IF EXISTS addfldcrmentityinfo;
delimiter ||
CREATE PROCEDURE addfldcrmentityinfo(
	IN pmodule VARCHAR(100)
)
BEGIN
	DECLARE done int default 0;

	SET @sql = CONCAT('SELECT ld_tab.tabid,ld_entityname.tablename,ld_entityname.entityidfield INTO @ptabid,@ptablename,@ptableindex
		FROM ld_entityname
			INNER JOIN ld_tab
				ON ld_tab.`tabid` = ld_entityname.`tabid`
		WHERE ld_entityname.`tabid` > 0 AND ld_tab.name = "',pmodule,'" limit 1;');

	PREPARE stmt FROM @sql;
		EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	if (@ptabid > 0) AND (@ptablename != '') THEN
		-- 获取当前数据库名，要判断的字段
		SELECT DATABASE() INTO @tableschema;
		SET @columnname = 'smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted';


		loop1: WHILE done < 1 DO
			-- 判断字段是否加入成功
			SET @tsql = CONCAT('select COUNT(column_name) INTO @colcount from information_schema.columns where  TABLE_SCHEMA ="',@tableschema,'"  and
		lower(table_name)= lower("',@ptablename,'") and FIND_IN_SET(column_name,"',@columnname,'")');
			prepare stmt from @tsql;
				execute stmt;
			DEALLOCATE PREPARE stmt;

			IF @colcount = 7 THEN
				SET done = 1;
			ELSE
				-- 加字段
				CALL AddColumn(@ptablename,'smownerid','int',19,0);
				CALL AddColumn(@ptablename,'smcreatorid','int',19,0);
				CALL AddColumn(@ptablename,'modifiedby','int',19,0);
				CALL AddColumn(@ptablename,'createdtime','datetime','','');
				CALL AddColumn(@ptablename,'modifiedtime','datetime','','');
				CALL AddColumn(@ptablename,'description','text','','');
				CALL AddColumn(@ptablename,'deleted','int',19,0);
			END IF;
		END WHILE loop1;

		SET @tsql=CONCAT('select COUNT(column_name) INTO @crmfldcount from information_schema.columns where  TABLE_SCHEMA = "',@tableschema,'"  and table_name= "ld_crmentity";');
		PREPARE stmt FROM @tsql;
			EXECUTE stmt;
		DEALLOCATE PREPARE stmt;

		IF @crmfldcount = 13 THEN
			-- 同步 crmentity表 数据
			SET @sql = CONCAT('UPDATE ',@ptablename,' INNER JOIN ld_crmentity ON ',@ptablename,'.',@ptableindex,' = ld_crmentity.crmid
			SET ',@ptablename,'.smownerid = ld_crmentity.smownerid,',@ptablename,'.smcreatorid = ld_crmentity.smcreatorid,
			',@ptablename,'.modifiedby = ld_crmentity.modifiedby,',@ptablename,'.createdtime = ld_crmentity.createdtime,
			',@ptablename,'.modifiedtime = ld_crmentity.modifiedtime,',@ptablename,'.description = ld_crmentity.description,
			',@ptablename,'.deleted = ld_crmentity.deleted where ',@ptablename,'.modifiedby = 0;');
			PREPARE stmt FROM @sql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;

			-- tablename表名，必须LD为大写，其余均为小写
			SELECT CONCAT('LD',LOWER(SUBSTRING(@ptablename,3,LENGTH(@ptablename)))) INTO @tablename;

			-- Calendar日程安排，tabid修改为16
			IF @ptabid = 9 THEN
				set @ptabid = 16;
			END IF;

			-- 修改 ld_field 表 数据
			set @sql = CONCAT('UPDATE LD_field set tablename = "',@tablename,'" where tabid = ',@ptabid,' and columnname in ("smownerid","smcreatorid","modifiedby","createdtime","modifiedtime","description","deleted") ');
			PREPARE stmt FROM @sql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END if;

	end if;
END ||
delimiter;

CALL addfldcrmentityinfo('Accounts');
CALL addfldcrmentityinfo('Contacts');
CALL addfldcrmentityinfo('ContactRecords');
CALL addfldcrmentityinfo('Calendar');
CALL addfldcrmentityinfo('Documents');
CALL addfldcrmentityinfo('Faq');
CALL addfldcrmentityinfo('Campaigns');
CALL addfldcrmentityinfo('Attachment');
CALL addfldcrmentityinfo('HelpDesk');
CALL addfldcrmentityinfo('Potentials');
CALL addfldcrmentityinfo('Quotes');
CALL addfldcrmentityinfo('SalesOrder');
CALL addfldcrmentityinfo('SalesBack');
CALL addfldcrmentityinfo('Vendors');
CALL addfldcrmentityinfo('VendorContact');
CALL addfldcrmentityinfo('VendorContact');
CALL addfldcrmentityinfo('VendorContactRecords');
CALL addfldcrmentityinfo('PurchaseOrder');
CALL addfldcrmentityinfo('Project');
CALL addfldcrmentityinfo('ProjectTask');
CALL addfldcrmentityinfo('ProjectMilestone');
CALL addfldcrmentityinfo('Invoice');
CALL addfldcrmentityinfo('CashBill');
CALL addfldcrmentityinfo('SendCashBill');
CALL addfldcrmentityinfo('CashBack');
CALL addfldcrmentityinfo('PaymentPlan');
CALL addfldcrmentityinfo('SendPayment');
CALL addfldcrmentityinfo('Expense');
CALL addfldcrmentityinfo('Commission');
CALL addfldcrmentityinfo('BankAccountSet');
CALL addfldcrmentityinfo('PutCash');
CALL addfldcrmentityinfo('CashDeposit');
CALL addfldcrmentityinfo('OutboundOrder');
CALL addfldcrmentityinfo('Stock');
CALL addfldcrmentityinfo('Checks');
CALL addfldcrmentityinfo('ModComments');
CALL addfldcrmentityinfo('Products');
CALL addfldcrmentityinfo('PriceBooks');
CALL addfldcrmentityinfo('Reminds');
CALL addfldcrmentityinfo('ServiceContracts');
delimiter;

SELECT id INTO @picklistid FROM LD_picklist_seq LIMIT 1;
UPDATE LD_picklist_seq SET id = @picklistid+1 WHERE NOT EXISTS (SELECT 1 FROM LD_picklist WHERE NAME='commissiontype');
INSERT INTO LD_picklist(picklistid,NAME)
SELECT @picklistid+1,'commissiontype'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM LD_picklist WHERE NAME='commissiontype');
delimiter;

CALL addfldcrmentityinfo('PurchaseBack');
CALL addfldcrmentityinfo('PurchaseCashBack');
delimiter;

update ld_tranlabel set fieldlabel = '审批人' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'ContactRecords') and
Relateid in (select fieldid from LD_field where columnname= 'approveby' and tabid in (select tabid from ld_tab where name = 'ContactRecords') );
delimiter;

call AddColumn('LD_project','realprojectcost','int',19,0);
ALTER TABLE ld_project MODIFY COLUMN realprojectcost decimal(25,2) default 0.00;

select tabid into @tabid from LD_tab where name='Project';
select blockid into @Projectid from LD_blocks where tabid=@tabid and blocklabel='LBL_PROJECT_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='realprojectcost'  and tabid=@tabid )and exists (select 1 from ld_version where trade='qiaiju')  ;
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxfieldid+1,'realprojectcost','LD_project',1,71,'realprojectcost','实际利润率',1,0,'',100,24,@Projectid,2,'N~O',3,'','BAS',0,'',0  
from dual where  not exists (select columnname from  ld_field where columnname='realprojectcost'  and tabid=@tabid ) and exists (select 1 from ld_version where trade='qiaiju')  ;
select fieldid  into @relateid from ld_field where tabid=@tabid and columnname='realprojectcost';
insert into  ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','LD_field',@tabid,@relateid,'实际利润率' from dual where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='LD_field' and relateid=@relateid) and exists (select 1 from ld_version where trade='qiaiju')  ;
insert into  ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','LD_field',@tabid,@relateid,'real project cost' from dual where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='LD_field' and relateid=@relateid) and exists (select 1 from ld_version where trade='qiaiju') ;
delimiter;

call AddColumn('LD_projecttask','totalcost','int',19,0);
ALTER TABLE ld_projecttask MODIFY COLUMN totalcost decimal(25,2) default 0.00;

select tabid into @tabid from LD_tab where name='ProjectTask';
select blockid into @Projectid from LD_blocks where tabid=@tabid and blocklabel='LBL_PROJECT_TASK_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='totalcost'  and tabid=@tabid )and exists (select 1 from ld_version where trade='qiaiju')  ;
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxfieldid+1,'totalcost','LD_projecttask',1,71,'totalcost','项目任务成本',0,0,'',100,24,@Projectid,1,'N~O',3,'','BAS',0,'',0  
from dual where  not exists (select columnname from  ld_field where columnname='totalcost'  and tabid=@tabid ) and exists (select 1 from ld_version where trade='qiaiju')  ;
select fieldid  into @relateid from ld_field where tabid=@tabid and columnname='totalcost';
insert into  ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','LD_field',@tabid,@relateid,'项目任务成本' from dual where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='LD_field' and relateid=@relateid) and exists (select 1 from ld_version where trade='qiaiju')  ;
insert into  ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','LD_field',@tabid,@relateid,'real project cost' from dual where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='LD_field' and relateid=@relateid) and exists (select 1 from ld_version where trade='qiaiju') ;
delimiter;
-- end 2014-07-11


UPDATE ld_desk SET Fieldlabel='期初' where labelbol='INFANCY' AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EDIT','编辑','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='EDIT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EDIT','Edit','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EDIT' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DOWNLOAD','下载','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DOWNLOAD' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DOWNLOAD','Download','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DOWNLOAD' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @Calendar_tabid from ld_tab where name = 'Calendar';
select sequence into @sequence from ld_relatedlists where tabid =@tabid and label = 'Expense';
select id into @id from ld_relatedlists_seq;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@Calendar_tabid,'get_schedule',@sequence,'Calendar','add' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@Calendar_tabid);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @Calendar_tabid from ld_tab where name = 'Calendar';
select sequence into @sequence from ld_relatedlists where tabid =@tabid and label = 'Expense';
select id into @id from ld_relatedlists_seq;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@Calendar_tabid,'get_schedule',@sequence,'Calendar','add' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@Calendar_tabid);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'Calendar';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Calendar';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

update ld_desk set Fieldlabel='一个模块可以设置多个审批流程，一个用户可以参与多个审批流程；' where labelbol='MODULECANMULAPPROVAL' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='A module can set up multiple approval process, a user can participate in more than one approval process;' where labelbol='MODULECANMULAPPROVAL' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='若有多个审批流程适用于某用户，则该用户提交单据时可以选择通过哪个流程进行审批；' where labelbol='USERMORETHANAPPROVALPRO' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel=' If more than one approval process applies to a user when the user submits the documents which can be selected through the process for approval;' where labelbol='USERMORETHANAPPROVALPRO' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='若没有审批流程适用于某用户，则该用户无法提交单据进行审批；此时，需要通知系统管理员检查并调整审批流程。' where labelbol='NOAPPROVALUSERPROCESS' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='If there is no approval process applies to a user, the user can not submit documents for approval; At this point, you need to notify the system administrator to check and adjust the approval process.' where labelbol='NOAPPROVALUSERPROCESS' and languagetype='en'and Labeltype = 'fixedstr';
delimiter;

update ld_desk set Fieldlabel='目标值由人工设定，完成值由系统自动统计得出；' where labelbol='SALESGOALINSTRUCTION4' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='The target value set by the artificial completed automatically by the system, the value of statistics;' where labelbol='SALESGOALINSTRUCTION4' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='在目标查看页签可查看销售目标设定结果及完成情况，在目标设置页签可设定销售目标；金额单位：元，客户数：个）' where labelbol='SALESGOALINSTRUCTION5' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='To view the page in the target sign can view the sales target setting and completion, in Goal Setting tab set the sales target; (monetary unit: yuan, customer number: a)' where labelbol='SALESGOALINSTRUCTION5' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='回款额统计收款单金额，根据收款日期计算；签约额统计未作废的合同订单金额，按照签约日期计算；' where labelbol='SALESGOALINSTRUCTION6' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='The amount of statistical bill amount, calculated according to the date of payment; The signing amount of contract amount is not obsolete, calculated in accordance with the date of contract. ' where labelbol='SALESGOALINSTRUCTION6' and languagetype='en'and Labeltype = 'fixedstr';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','FIELDMATCHESTIMES','字段“$fldname$”映射了多次，请重新设置！','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='FIELDMATCHESTIMES' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','FIELDMATCHESTIMES','The field‘$fieldname$’ matches more times!','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='FIELDMATCHESTIMES' AND Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASEBACK_INFO';
delete from ld_field where tabid = @tabid and columnname = 'purchaseorder_id';
delete from ld_field where tabid = @tabid and columnname = 'purchaseorderid';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'purchaseorder_id','LD_purchaseback',150,'purchaseorder_id','采购订单',@blockid,1,0,'I~O',3
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'purchaseorder_id');
delimiter;

call getallprofile('PurchaseBack');
call fieldprofile('PurchaseBack');
call getallprofile('PurchaseCashBack');
call fieldprofile('PurchaseCashBack');
call addtabintoprofile('PurchaseBack',1);
call addtabintoprofile('PurchaseCashBack',1);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RETURNOPERATIONREVERSIBLEPURCHASE','退货出库操作不可逆，请仔细确认单据信息。是否确认退货出库？','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RETURNOPERATIONREVERSIBLEPURCHASE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RETURNOPERATIONREVERSIBLEPURCHASE','Return from the operation is not reversible, so please confirm the receipt information. To confirm the return delivery?','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RETURNOPERATIONREVERSIBLEPURCHASE' and Labeltype='jspop');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'采购负责人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnGrandTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'应退款' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Should Refund' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
update ld_desk set Fieldlabel = '采购退货是针对{$PurchaseOrder.PurchaseOrder}的，不允许直接创建' where labelbol = 'RETURNPURCHASE1' and languagetype = 'zh';
update ld_desk set Fieldlabel = '只有已经入库的订单允许办理退货' where labelbol = 'RETURNPURCHASE3' and languagetype = 'zh';
delimiter;
-- end 2014-07-15
select tabid into @tabid from ld_tab where name='PurchaseBack';
delete from LD_relatedlists where tabid = @tabid;
select tabid into @relatedtabid from ld_tab where name='PurchaseCashBack';
select max(relation_id) into @relation_id from ld_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_purchasecashback',1,'PurchaseCashBack',0,'add' from dual 
where not exists(select 1 from ld_relatedlists where name='get_purchasecashback' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseBack';
select tabid into @relatedtabid from ld_tab where name='Attachment';
select max(relation_id) into @relation_id from ld_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_attachment',2,'Attachment',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from ld_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseBack';
delete from ld_quickactions where tabid = @tabid;
select tabid into @tabid2 from ld_tab where name = 'PurchaseCashBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseBack';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,1 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseCashBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Creator'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;


select tabid into @tabid from ld_tab where name='PurchaseOrder';
select tabid into @relatedtabid from ld_tab where name='PurchaseBack';
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_purchaseback',7,'PurchaseBack',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_purchaseback' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseOrder';
select tabid into @relatedtabid from ld_tab where name='PurchaseCashBack';
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_purchasecashback',8,'PurchaseCashBack',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_purchasecashback' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

update LD_relatedlists set sequence = 9 where name = 'get_attachment' and tabid = 21;
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid2 from ld_tab where name = 'PurchaseBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,4,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid2 from ld_tab where name = 'PurchaseCashBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,5 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
update ld_quickactions set sequence = 6 where related_tabid = -1 and tabid = @tabid;
update ld_quickactions set sequence = 7 where related_tabid = -5 and tabid = @tabid;
delimiter;

update ld_modentity_num set datetype ='yyyymmdd-' where semodule = 'PurchaseBack';
update ld_modentity_num set datetype ='yyyymmdd-' where semodule = 'PurchaseCashBack';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Creator'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnTaxType';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'税种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Tax Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'货币'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'conversion_rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'汇率'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Exchange Rate'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnSubTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'小计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Sub Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountPercent';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣百分比'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Percent'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountAmount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣直接降价'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnS_H_Amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'运费和物流附加费'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'S&H Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'txtAdjustment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'调整'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Adjustment'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnTaxType';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'税种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Tax Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'货币'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'conversion_rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'汇率'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Exchange Rate'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnSubTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'小计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Sub Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountPercent';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣百分比'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Percent'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountAmount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣直接降价'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnS_H_Amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'运费和物流附加费'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'S&H Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'txtAdjustment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'调整'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Adjustment'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchasecashbackdate';
update ld_tranlabel set fieldlabel = '退款日期' where languagetype = 'zh' and trantable = 'LD_field' and tabid = @tabid and  relateid = @fieldid;
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE name='CommencementSchedule';
DELETE FROM ld_usereportcolumns WHERE usereportid=@id AND columns LIKE '%LD_salesorder:salesordertotal:salesordertotal:%';

DELETE FROM ld_usereportcolumns WHERE usereportid=@id AND columns LIKE '%LD_salesorder:PaymentBalance:PaymentBalance:%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:NN', 9, 1, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN','LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:salesordertotal:salesordertotal:%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN', 10, 1, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN','LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:PaymentBalance:PaymentBalance:%');
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE name='OverallCommencementSchedule';

DELETE FROM ld_usereportcolumns WHERE usereportid=@id
AND columns LIKE '%LD_salesorder:PaymentBalance:PaymentBalance:%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN', 7, 1, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN','LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:PaymentBalance:PaymentBalance:%');
delimiter;


SELECT usereportid INTO @id FROM ld_usereport WHERE name='PartnerCommencementSchedule';

DELETE FROM ld_usereportcolumns WHERE usereportid=@id
AND columns LIKE '%LD_salesorder:salesordertotal:salesordertotal:%';

DELETE FROM ld_usereportcolumns WHERE usereportid=@id
AND columns LIKE '%LD_salesorder:PaymentBalance:PaymentBalance:%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:NN', 8, 1, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN','LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:salesordertotal:salesordertotal:%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN', 9, 1, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN','LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:PaymentBalance:PaymentBalance:%');
delimiter;


SELECT usereportid INTO @id FROM ld_usereport WHERE name='LecturerCommencementSchedule';

DELETE FROM ld_usereportcolumns WHERE usereportid=@id
AND columns LIKE '%LD_salesorder:salesordertotal:salesordertotal:%';

DELETE FROM ld_usereportcolumns WHERE usereportid=@id
AND columns LIKE '%LD_salesorder:PaymentBalance:PaymentBalance:%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:NN', 8, 1, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN','LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:salesordertotal:salesordertotal:%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN', 9, 1, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN','LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:PaymentBalance:PaymentBalance:%');
delimiter;

update LD_settings_field set iconpath = 'ico-users.png' where iconpath = 'ico-users.gif';
update LD_settings_field set iconpath = 'ico-roles.png' where iconpath = 'ico-roles.gif';
update LD_settings_field set iconpath = 'ico-groups.png' where iconpath = 'ico-groups.gif';
update LD_settings_field set iconpath = 'shareaccess.png' where iconpath = 'shareaccess.gif';
update LD_settings_field set iconpath = 'orgshar.png' where iconpath = 'orgshar.gif';
update LD_settings_field set iconpath = 'audit.png' where iconpath = 'audit.gif';
update LD_settings_field set iconpath = 'set-IcoLoginHistory.png' where iconpath = 'set-IcoLoginHistory.gif';
update LD_settings_field set iconpath = 'vtlib_modmng.png' where iconpath = 'vtlib_modmng.gif';
update LD_settings_field set iconpath = 'pageset.png' where iconpath = 'pageset.gif';
update LD_settings_field set iconpath = 'picklist.png' where iconpath = 'picklist.gif';
update LD_settings_field set iconpath = 'picklistdependency.png' where iconpath = 'picklistdependency.gif';
update LD_settings_field set iconpath = 'ico-templates.png' where iconpath = 'ico-templates.jpg';
update LD_settings_field set iconpath = 'approvelist.png' where iconpath = 'approvelist.gif';
update LD_settings_field set iconpath = 'printtemplate.png' where iconpath = 'printtemplate.gif';
update LD_settings_field set iconpath = 'productfield.png' where iconpath = 'productfield.gif';
update LD_settings_field set iconpath = 'migrate.png' where iconpath = 'migrate.gif';
update LD_settings_field set iconpath = 'tablist.png' where iconpath = 'tablist.gif';
update LD_settings_field set iconpath = 'productfield.png' where iconpath = 'productfield.gif';
update LD_settings_field set iconpath = 'notification.png' where iconpath = 'notification.gif';
update LD_settings_field set iconpath = 'inventory.png' where iconpath = 'inventory.gif';
update LD_settings_field set iconpath = 'currency.png' where iconpath = 'currency.gif';
update LD_settings_field set iconpath = 'taxConfiguration.png' where iconpath = 'taxConfiguration.gif';
update LD_settings_field set iconpath = 'ogmailserver.png' where iconpath = 'ogmailserver.gif';
update LD_settings_field set iconpath = 'settingsInvNumber.png' where iconpath = 'settingsInvNumber.gif';
update LD_settings_field set iconpath = 'terms.png' where iconpath = 'terms.gif';
update LD_settings_field set iconpath = 'company.png' where iconpath = 'company.gif';
update LD_settings_field set iconpath = 'jk_ico.png' where iconpath = 'jk_ico.jpg';
update LD_settings_field set iconpath = 'code.png' where iconpath = 'code.gif';
update LD_settings_field set iconpath = 'public_sea_account.png' where iconpath = 'public_sea_account.gif';
update LD_settings_field set iconpath = 'wasehouse.png' where iconpath = 'wasehouse.gif';
update LD_settings_field set iconpath = 'backupserver.png' where iconpath = 'backupserver.gif';
update LD_settings_field set iconpath = 'automaticreminds.png' where iconpath = 'automaticreminds.gif';
delimiter;

update ld_desk set Fieldlabel='当"是否允许结束审批流程"设置为"是"时表示：允许该步骤的审批人结束整个审批流程，审批后单据不再继续流转；' where labelbol='ADDAPPROVALSTEPTIP1' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='When "Allow end approval process" is set to "Yes", said: This step allows the approver end of the whole approval process, after the approval of the documents no longer continue to flow;' where labelbol='ADDAPPROVALSTEPTIP1' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='当"是否允许指定审批步骤"设置为"是"时表示：允许该步骤的审批人调整接下来的审批步骤；' where labelbol='ADDAPPROVALSTEPTIP2' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='When "allows you to specify whether approval step" is set to "Yes", said: This step allows the approver for approval to adjust the next step;' where labelbol='ADDAPPROVALSTEPTIP2' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='当"审批人类型"设置为"指定用户"时，可与选择用户作为审批人，允许通过多次选择指定多个用户；' where labelbol='ADDAPPROVALSTEPTIP3' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='When the "approver type" is set to "specified user", the user can select as approver with, allows multiple users to specify multiple choice;' where labelbol='ADDAPPROVALSTEPTIP3' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='当"审批人类型"设置为"指定角色"时，可以选择角色作为审批人，但是只能选择一个角色；' where labelbol='ADDAPPROVALSTEPTIP4' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='When the "approver type" is set to "assign roles", you can select a role as an approver, but can only choose one role;' where labelbol='ADDAPPROVALSTEPTIP4' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='当"审批人类型"设置为"指定发起人所在部门用户的职位级别"时，审批时自动按发起人所在部门和设定用户的职位级别流转；' where labelbol='ADDAPPROVALSTEPTIP5' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='When the "approver type" is set to "specify where the job level department promoters users", the auto sector where promoters by job level and set the user flow of time for approval；' where labelbol='ADDAPPROVALSTEPTIP5' and languagetype='en'and Labeltype = 'fixedstr';

update ld_desk set Fieldlabel='若符合条件的审批人有多个，则表示这些审批人均可以执行审批操作，只要其中一个人执行审批操作就表示完成了该审批步骤。' where labelbol='ADDAPPROVALSTEPTIP6' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='If you meet the conditions for approval have multiple people, then you can perform these approvals per capita approval to operate, as long as one person to perform the operation on the said approval to complete the approval step.' where labelbol='ADDAPPROVALSTEPTIP6' and languagetype='en'and Labeltype = 'fixedstr';
delimiter;

update ld_desk set Fieldlabel='{$OutboundOrder.OutboundOrder}或{$Stock.Stock}必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）' where labelbol='OUTBOUNDSTOCKACCORDORIGNAL' and languagetype='zh';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RATIOS','占比','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RATIOS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RATIOS','Ratio Name','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RATIOS' and Labeltype='fixedstr');
delimiter;

DROP PROCEDURE if EXISTS fieldintoprofile;
delimiter ||
create PROCEDURE fieldintoprofile
(
profileid int(19),
tabname varchar(50)
)
begin
declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  LD_field where tabid in(select tabid from lD_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into LD_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from LD_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');
	
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;


CREATE TABLE IF NOT EXISTS `ld_publicannouncement` (
  `publicannouncementid` int(19) NOT NULL DEFAULT '0',
  `subject` varchar(255) DEFAULT NULL,
  `publicannouncement_type` varchar(255) DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `content` text,
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `modifiedby` int(11) DEFAULT '0',
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `description` text,
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`publicannouncementid`),
  KEY `startdate` (`startdate`,`enddate`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF  NOT EXISTS  `ld_receipts` (
  `id` int(19) NOT NULL DEFAULT '0',
  `userid` int(19) NOT NULL DEFAULT '0',
  `setype` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`,`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_publicannouncement_type` (
  `publicannouncement_typeid` int(19) NOT NULL auto_increment,
  `publicannouncement_type` varchar(255) default NULL,
  `presence` int(11) default NULL,
  `picklist_valueid` int(11) default NULL,
  PRIMARY KEY  (`publicannouncement_typeid`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_publicannouncement_type_seq` (
  `id` int(11) default null
);
delimiter;

select max(tabid)+1 into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'PublicAnnouncement',0,@tabsequence+1,'PublicAnnouncement',1,'Tools',1 
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='PublicAnnouncement');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Tools';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'新公告' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='新公告');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'PublicAnnouncement' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='PublicAnnouncement');

insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'PublicAnnouncement','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'PublicAnnouncement' );
delimiter;

select max(id) into @id from ld_picklistvalues_seq;
insert into ld_publicannouncement_type(publicannouncement_type,presence,picklist_valueid)
select '重要通知',1,@id+1 
from dual where not EXISTS(select 1 from ld_publicannouncement_type  where publicannouncement_type = '重要通知');
update ld_picklistvalues_seq set id = @id +1;
SELECT max(publicannouncement_typeid) into @seqid from LD_publicannouncement_type;
UPDATE ld_publicannouncement_type_seq set id=@seqid;
delimiter;

select max(id) into @id from ld_picklistvalues_seq;
insert into ld_publicannouncement_type(publicannouncement_type,presence,picklist_valueid)
select '规章制度',1,@id+1 
from dual where not EXISTS(select 1 from ld_publicannouncement_type  where publicannouncement_type = '规章制度');
update ld_picklistvalues_seq set id = @id +1;
SELECT max(publicannouncement_typeid) into @seqid from LD_publicannouncement_type;
UPDATE ld_publicannouncement_type_seq set id=@seqid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PUBLICANNOUNCEMENT_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PUBLICANNOUNCEMENT_CONTENT',2 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_PUBLICANNOUNCEMENT_CONTENT' and sequence = 2);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='基本信息');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Reminds Content' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Reminds Content');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PUBLICANNOUNCEMENT_CONTENT';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'公告内容' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='公告内容');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'The content of the announcement' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='The content of the announcement');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'subject','LD_publicannouncement',1,'subject','公告标题',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),1,0,'V~M','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'subject');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'publicannouncement_type','LD_publicannouncement',15,'publicannouncement_type','公告类型',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),1,0,'V~O','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'publicannouncement_type');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'startdate','LD_publicannouncement',5,'startdate','公告开始日期',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),1,0,'D~M','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'startdate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'enddate','LD_publicannouncement',5,'enddate','公告结束日期',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),1,0,'D~M','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'enddate');

delete from ld_field where tabid=@tabid and fieldname='recipient';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'userid','LD_receipts',242,'recipient','接收人',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),1,0,'V~M','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'userid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'content','LD_publicannouncement',19,'content','公告内容',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_CONTENT'),1,0,'V~M','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'content');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','LD_publicannouncement',53,'assigned_user_id','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),1,0,'V~O','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','LD_publicannouncement',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),2,0,'V~O','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','LD_publicannouncement',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),2,0,'DT~O','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','LD_publicannouncement',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),2,0,'DT~O','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','LD_publicannouncement',52,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),2,0,'V~O','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedby');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type)
select @tabid,(select max(fieldid) from ld_field)+1,'description','LD_publicannouncement',19,'description','备注',(select blockid from ld_blocks where blocklabel = 'LBL_PUBLICANNOUNCEMENT_INFO'),2,0,'V~O','BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'description');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'PublicAnnouncement','LD_publicannouncement','subject','publicannouncementid','publicannouncementid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid 
and modulename ='PublicAnnouncement');
delimiter;

CALL addfldcrmentityinfo('PublicAnnouncement');
delimiter;
call fieldprofile('PublicAnnouncement');
delimiter;
call getallprofile('PublicAnnouncement');
delimiter;
call addtabintoprofile('PublicAnnouncement',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'subject';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'公告标题' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Subject' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'publicannouncement_type';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'公告类型' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Type' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'startdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'开始日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Start Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'enddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'结束日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'End Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'recipient';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'接收人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Receiver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'content';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'公告内容' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'The content of the announcement' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'负责人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'修改时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modification time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Create Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Creator' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'最新更新人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'备注' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Description' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'PublicAnnouncement',0,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All' 
and entitytype ='PublicAnnouncement');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = 'All';
DELETE FROM ld_cvcolumnlist WHERE cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_publicannouncement:subject:subject:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_publicannouncement:publicannouncement_type:publicannouncement_type:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_publicannouncement:enddate:enddate:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_publicannouncement:content:content:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_publicannouncement:smownerid:assigned_user_id:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_publicannouncement:recipient:recipient:PublicAnnouncement_fieldlabel:V';
delimiter;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'今日',1,'PublicAnnouncement',1,1,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '今日' and entitytype ='PublicAnnouncement');

update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '今日';
DELETE FROM ld_cvcolumnlist WHERE cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_publicannouncement:subject:subject:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_publicannouncement:publicannouncement_type:publicannouncement_type:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_publicannouncement:enddate:enddate:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_publicannouncement:content:content:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_publicannouncement:smownerid:assigned_user_id:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_publicannouncement:recipient:recipient:PublicAnnouncement_fieldlabel:V';
delimiter;


insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'本周',1,'PublicAnnouncement',1,1,2,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本周' and entitytype ='PublicAnnouncement');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '本周';
DELETE FROM ld_cvcolumnlist WHERE cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_publicannouncement:subject:subject:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_publicannouncement:publicannouncement_type:publicannouncement_type:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_publicannouncement:enddate:enddate:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_publicannouncement:content:content:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_publicannouncement:smownerid:assigned_user_id:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_publicannouncement:recipient:recipient:PublicAnnouncement_fieldlabel:V';
delimiter;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'本月',1,'PublicAnnouncement',1,1,3,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本月' and entitytype ='PublicAnnouncement');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '本月';
DELETE FROM ld_cvcolumnlist WHERE cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_publicannouncement:subject:subject:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_publicannouncement:publicannouncement_type:publicannouncement_type:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_publicannouncement:enddate:enddate:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_publicannouncement:content:content:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_publicannouncement:smownerid:assigned_user_id:PublicAnnouncement_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_publicannouncement:recipient:recipient:PublicAnnouncement_fieldlabel:V';
delimiter;

SELECT cvid INTO @cvid from ld_customview where  viewname='今日' and entitytype='PublicAnnouncement';
delete from ld_cvstdfilter where cvid=@cvid;
INSERT into ld_cvstdfilter (cvid,columnname,stdfilter) select @cvid,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel',
'today' from dual where not EXISTS (SELECT 1 from ld_cvstdfilter WHERE cvid=@cvid);
delimiter;

SELECT cvid INTO @cvid from ld_customview where  viewname='本周' and entitytype='PublicAnnouncement';
delete from ld_cvstdfilter where cvid=@cvid;
INSERT into ld_cvstdfilter (cvid,columnname,stdfilter) select @cvid,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel',
'thisweek' from dual where not EXISTS (SELECT 1 from ld_cvstdfilter WHERE cvid=@cvid);
delimiter;

SELECT cvid INTO @cvid from ld_customview where  viewname='本月' and entitytype='PublicAnnouncement';
delete from ld_cvstdfilter where cvid=@cvid;
INSERT into ld_cvstdfilter (cvid,columnname,stdfilter) select @cvid,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel',
'thismonth' from dual where not EXISTS (SELECT 1 from ld_cvstdfilter WHERE cvid=@cvid);
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
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

DROP PROCEDURE IF EXISTS insert_templatesstuff; 
delimiter || 
CREATE PROCEDURE insert_templatesstuff(IN pstuffid int,IN pstufftype VARCHAR(100),IN pseq int,IN pstufftitle VARCHAR(100)) 
BEGIN 
DECLARE done int DEFAULT 0; 
DECLARE ptemplateid int(11); 
DECLARE profileobj CURSOR FOR SELECT templateid from ld_templates; 

DECLARE CONTINUE HANDLER for not found set done = 1; 
OPEN profileobj; 
	fetch profileobj into ptemplateid; 
	LOOP1: WHILE done <> 1 DO 
		set @sql = CONCAT('insert into ld_templatesstuff(stuffId,templateid,Stufftype,stuffsequence,stufftitle) select ',pstuffid,',',ptemplateid,',"',pstufftype,'",',pseq,',"',pstufftitle,'" from dual where not EXISTS (select 1 from ld_templatesstuff where templateid = ',ptemplateid,' and stufftitle = "',pstufftitle,'")');
		prepare stmt from @sql;
			execute stmt; 
		deallocate prepare stmt; 
		fetch profileobj into ptemplateid; 
	END WHILE LOOP1;
close profileobj; 

end ||
delimiter;

call insert_templatesstuff(32,'Default',0,'PUBLICANNOUNCEMENT');
delimiter;

DROP PROCEDURE IF EXISTS update_stuffsequence; 
delimiter || 
CREATE PROCEDURE update_stuffsequence
(
) 
BEGIN 

		DECLARE done int DEFAULT 0; 
		DECLARE tmp_templateid int(11); 

		DECLARE mycursor CURSOR FOR SELECT templateid from ld_templates; 
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_templateid = NULL;

		update LD_templatesstuff set stuffsequence=stuffsequence+2 ;
		update LD_templatesstuff set stuffsequence=1 where stuffId=32;

		OPEN mycursor; 
		fetch mycursor into tmp_templateid; 
		while(tmp_templateid is not null) DO	
				select 0 into @i;
				update LD_templatesstuff set stuffsequence=(@i:=@i+1) where templateid=tmp_templateid order by stuffsequence; 
				fetch mycursor into tmp_templateid;
		end while;
		close mycursor;
end ||
delimiter;

call update_stuffsequence();
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PUBLICANNOUNCEMENT','公告','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PUBLICANNOUNCEMENT' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PUBLICANNOUNCEMENT','The announcement','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PUBLICANNOUNCEMENT' and Labeltype='fixedstr');
delimiter;


SELECT tabid into @tabid from ld_tab where name='PublicAnnouncement';
UPDATE ld_field set  displaytype=3 where tabid=@tabid and columnname='modifiedby';
delimiter;

SELECT tabid into @tabid from ld_tab where name='PurchaseBack';
UPDATE ld_field set  displaytype=3 where tabid=@tabid and columnname='modifiedby';
delimiter;

SELECT tabid into @tabid from ld_tab where name='PurchaseCashBack';
UPDATE ld_field set  displaytype=3 where tabid=@tabid and columnname='modifiedby';
delimiter;

update ld_desk set Fieldlabel ='数量不能超过引用单据数量！'
where labelbol ='CANOTEXCEEDORIGINALCONTRACTNUM' and languagetype = 'zh';
delimiter;

update LD_profile2field set visible = 0 where
fieldid = (select fieldid from ld_field where tabid = (select tabid from ld_tab where name = 'PurchaseCashBack') and fieldname = 'smcreatorid');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
delete from ld_tranlabel where tabid = @tabid and Relateid = @fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'退款原因'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

DROP PROCEDURE IF EXISTS setacctaddressfld;
delimiter ||
CREATE PROCEDURE setacctaddressfld(

)
BEGIN
	DECLARE done int default 0;
	SELECT DATABASE() INTO @tableschema;
	SET @columnname = 'bill_city,bill_code,bill_country,bill_state,bill_street,bill_pobox,ship_city,ship_code,ship_country,ship_state,ship_pobox,ship_street';

	-- 添加客户地址字段
	loop1: WHILE done < 1 DO
			SET @psql = CONCAT('SELECT COUNT(column_name) INTO @colcount from information_schema.columns WHERE TABLE_SCHEMA ="',@tableschema,'"  AND
		LOWER(table_name)= LOWER("LD_account") AND FIND_IN_SET(column_name,"',@columnname,'")');
			PREPARE stmt FROM @psql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;

			IF @colcount = 12 THEN
				SET done = 1;
			ELSE
				-- 加字段
				CALL AddColumn('LD_account','bill_city','varchar',30,NULL);
				CALL AddColumn('LD_account','bill_code','varchar',30,NULL);
				CALL AddColumn('LD_account','bill_country','varchar',30,NULL);
				CALL AddColumn('LD_account','bill_state','varchar',30,NULL);
				CALL AddColumn('LD_account','bill_street','varchar',250,NULL);
				CALL AddColumn('LD_account','bill_pobox','varchar',30,NULL);
				CALL AddColumn('LD_account','ship_city','varchar',30,NULL);
				CALL AddColumn('LD_account','ship_code','varchar',30,NULL);
				CALL AddColumn('LD_account','ship_country','varchar',30,NULL);
				CALL AddColumn('LD_account','ship_state','varchar',30,NULL);
				CALL AddColumn('LD_account','ship_street','varchar',250,NULL);
				CALL AddColumn('LD_account','ship_pobox','varchar',30,NULL);
			END IF;
	END WHILE loop1;

	-- 同步客户地址信息到客户表中
	SET @psql = CONCAT('SELECT COUNT(TABLE_NAME) INTO @tablecount FROM INFORMATION_SCHEMA.TABLES WHERE LOWER(TABLE_NAME) IN (LOWER("LD_accountbillads"),LOWER("LD_accountshipads")) AND TABLE_SCHEMA = "',@tableschema,'";');
	PREPARE stmt FROM @psql;
		EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	IF @tablecount = 2 THEN -- 判断表是否存在
			-- 同步数据
			SET @psql = CONCAT('UPDATE LD_account
						LEFT JOIN LD_accountbillads
							ON LD_account.accountid = LD_accountbillads.accountaddressid
						LEFT JOIN LD_accountshipads
							ON LD_account.accountid = LD_accountshipads.accountaddressid
						SET LD_account.bill_city = LD_accountbillads.bill_city,
						LD_account.bill_code = LD_accountbillads.bill_code,
						LD_account.bill_country = LD_accountbillads.bill_country,
						LD_account.bill_state = LD_accountbillads.bill_state,
						LD_account.bill_street = LD_accountbillads.bill_street,
						LD_account.bill_pobox = LD_accountbillads.bill_pobox,
						LD_account.ship_city = LD_accountshipads.ship_city,
						LD_account.ship_code = LD_accountshipads.ship_code,
						LD_account.ship_country = LD_accountshipads.ship_country,
						LD_account.ship_state = LD_accountshipads.ship_state,
						LD_account.ship_street = LD_accountshipads.ship_street,
						LD_account.ship_pobox = LD_accountshipads.ship_pobox
						where LD_account.bill_city is NULL;');
			PREPARE stmt FROM @psql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;

			-- 修改 ld_field 表 数据
			SET @psql = CONCAT('UPDATE LD_field SET tablename = "LD_account" WHERE tabid = 6
														and tablename != "LD_account" AND FIND_IN_SET(columnname,"',@columnname,'");');
			PREPARE stmt FROM @psql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
	END IF;

	-- 联系人 LD_contactaddress、LD_contactsubdetails 表字段同步到联系人表中
	SET @columnname = 'mailingcity,mailingstreet,mailingcountry,othercountry,mailingstate,mailingpobox,othercity,otherstate,mailingzip,otherzip,otherstreet,otherpobox,homephone,otherphone,assistant,assistantphone,birthday,laststayintouchrequest,laststayintouchsavedate,leadsource';
	-- 添加联系人地址、电话字段
	SET done = 0;
	loop2: WHILE done < 1 DO
			SET @psql = CONCAT('select COUNT(column_name) INTO @colcount from information_schema.columns where TABLE_SCHEMA ="',@tableschema,'"  and
		LOWER(table_name)= LOWER("LD_contactdetails") and FIND_IN_SET(column_name,"',@columnname,'")');
			prepare stmt from @psql;
				execute stmt;
			DEALLOCATE PREPARE stmt;

			IF @colcount = 20 THEN
				SET done = 1;
			ELSE
				-- 加字段
				CALL AddColumn('LD_contactdetails','mailingcity','varchar',40,NULL);
				CALL AddColumn('LD_contactdetails','mailingstreet','varchar',250,NULL);
				CALL AddColumn('LD_contactdetails','mailingcountry','varchar',40,NULL);
				CALL AddColumn('LD_contactdetails','othercountry','varchar',30,NULL);
				CALL AddColumn('LD_contactdetails','mailingstate','varchar',30,NULL);
				CALL AddColumn('LD_contactdetails','mailingpobox','varchar',30,NULL);
				CALL AddColumn('LD_contactdetails','othercity','varchar',40,NULL);
				CALL AddColumn('LD_contactdetails','otherstate','varchar',50,NULL);
				CALL AddColumn('LD_contactdetails','mailingzip','varchar',30,NULL);
				CALL AddColumn('LD_contactdetails','otherzip','varchar',30,NULL);
				CALL AddColumn('LD_contactdetails','otherstreet','varchar',250,NULL);
				CALL AddColumn('LD_contactdetails','otherpobox','varchar',30,NULL);
				CALL AddColumn('LD_contactdetails','homephone','varchar',50,NULL);
				CALL AddColumn('LD_contactdetails','otherphone','varchar',50,NULL);
				CALL AddColumn('LD_contactdetails','assistant','varchar',30,NULL);
				CALL AddColumn('LD_contactdetails','assistantphone','varchar',50,NULL);
				CALL AddColumn('LD_contactdetails','birthday','date','','');
				CALL AddColumn('LD_contactdetails','laststayintouchrequest','int',30,0);
				CALL AddColumn('LD_contactdetails','laststayintouchsavedate','int',19,0);
				CALL AddColumn('LD_contactdetails','leadsource','varchar',200,NULL);
			END IF;
	END WHILE loop2;

	-- 同步联系人地址、电话信息到联系人表中
	SET @psql = CONCAT('SELECT COUNT(TABLE_NAME) INTO @tablecount FROM INFORMATION_SCHEMA.TABLES WHERE LOWER(TABLE_NAME) IN (LOWER("LD_contactaddress"),LOWER("LD_accountshipads")) AND TABLE_SCHEMA = "',@tableschema,'";');
	PREPARE stmt FROM @psql;
		EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	IF @tablecount = 2 THEN -- 判断表是否删除
			SET @psql = CONCAT('UPDATE LD_contactdetails
						left JOIN LD_contactaddress
							ON LD_contactdetails.contactid = LD_contactaddress.contactaddressid
						left JOIN LD_contactsubdetails
							ON LD_contactdetails.contactid = LD_contactsubdetails.contactsubscriptionid
							SET LD_contactdetails.mailingcity = LD_contactaddress.mailingcity,
						LD_contactdetails.mailingstreet = LD_contactaddress.mailingstreet,
						LD_contactdetails.mailingcountry = LD_contactaddress.mailingcountry,
						LD_contactdetails.othercountry = LD_contactaddress.othercountry,
						LD_contactdetails.mailingstate = LD_contactaddress.mailingstate,
						LD_contactdetails.mailingpobox = LD_contactaddress.mailingpobox,
						LD_contactdetails.othercity = LD_contactaddress.othercity,
						LD_contactdetails.otherstate = LD_contactaddress.otherstate,
						LD_contactdetails.mailingzip = LD_contactaddress.mailingzip,
						LD_contactdetails.otherzip = LD_contactaddress.otherzip,
						LD_contactdetails.otherstreet = LD_contactaddress.otherstreet,
						LD_contactdetails.otherpobox = LD_contactaddress.otherpobox,
						LD_contactdetails.homephone = LD_contactsubdetails.homephone,
						LD_contactdetails.otherphone = LD_contactsubdetails.otherphone,
						LD_contactdetails.assistant = LD_contactsubdetails.assistant,
						LD_contactdetails.assistantphone = LD_contactsubdetails.assistantphone,
						LD_contactdetails.birthday = LD_contactsubdetails.birthday,
						LD_contactdetails.laststayintouchrequest = LD_contactsubdetails.laststayintouchrequest,
						LD_contactdetails.laststayintouchsavedate = LD_contactsubdetails.laststayintouchsavedate,
						LD_contactdetails.leadsource = LD_contactsubdetails.leadsource
					WHERE LD_contactdetails.contactid > 0;');
			PREPARE stmt FROM @psql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			-- 修改 ld_field 表 数据
			SET @psql = CONCAT('UPDATE LD_field SET tablename = "LD_contactdetails" WHERE tabid = 4
														and tablename != "LD_contactdetails" AND FIND_IN_SET(columnname,"',@columnname,'");');
			PREPARE stmt FROM @psql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
	END IF;

END ||
delimiter;

call setacctaddressfld;
delimiter;

DROP PROCEDURE IF EXISTS setacctaddressfld;
delimiter;

-- 删除客户、联系人多余的表
DROP TABLE IF EXISTS LD_accountbillads;
DROP TABLE IF EXISTS LD_accountshipads;
DROP TABLE IF EXISTS LD_contactaddress;
DROP TABLE IF EXISTS LD_accountshipads;
DROP TABLE IF EXISTS LD_campaignrelstatus;
delimiter;

select usereportid into @id from LD_usereport where name='PartnerCommencementSchedule';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_expense:total:total:expense_total:NN', 15, 1, 'ld_expense:total:total:expense_佣金(费用报销):NN','ld_expense:total:total:expense_佣金(费用报销):NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%ld_expense:total:total:%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:yishoutotal:yishoutotal:salesorder_yishoutotal:V', 16, 1, 'LD_salesorder:yishoutotal:yishoutotal:SalesOrder_已收金额:NN','LD_salesorder:yishoutotal:yishoutotal:sSalesOrder_已收金额:NN' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:yishoutotal:yishoutotal:%');

select usereportid into @id from LD_usereport where name='KPCCommencementDetails';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V', 16, 1, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_合同号:V','LD_salesorder:salesorder_no:salesorder_no:SalesOrder_Contract Number:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_salesorder:salesorder_no:salesorder_no:%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesordertotal:salesordertotal:SalesOrder_salesordertotal:N', 17, 1, 'LD_salesorder:salesordertotal:salesordertotal:SalesOrder_合同总金额:N','LD_salesorder:salesordertotal:salesordertotal:SalesOrder_totalss contract amount:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE  '%LD_salesorder:salesordertotal:salesordertotal:%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_expense:total:total:expense_total:NN', 18, 1, 'ld_expense:total:total:expense_佣金(费用报销):NN','ld_expense:total:total:expense_佣金(费用报销):NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%ld_expense:total:total:%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_invoicecf:cf_1205:cf_1205:invoice_cf_1205:V', 19, 1,
 'ld_invoicecf:cf_1205:cf_1205:invoice_发票签收与否:v','ld_invoicecf:cf_1205:cf_1205:invoice_发票签收与否:v'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%ld_invoicecf:cf_1205:cf_1205:%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_invoicecf:invoicetype:invoicetype:invoice_invoicetype:V', 20, 1,
 'ld_invoicecf:invoicetype:invoicetype:invoice_发票类型:v','ld_invoicecf:invoicetype:invoicetype:invoice_发票类型:v'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%ld_invoicecf:invoicetype:invoicetype:%');
delimiter;

update ld_tranlabel set fieldlabel = '合计' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'CashBill') and 
Relateid in (select fieldid from LD_field where columnname= 'total' and tabid in (select tabid from ld_tab where name = 'CashBill') );
update ld_tranlabel set fieldlabel = '合计' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'SendCashBill') and 
Relateid in (select fieldid from LD_field where columnname= 'total' and tabid in (select tabid from ld_tab where name = 'SendCashBill') );
update ld_tranlabel set fieldlabel = '合计' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Expense') and 
Relateid in (select fieldid from LD_field where columnname= 'total' and tabid in (select tabid from ld_tab where name = 'Expense') );
update ld_tranlabel set fieldlabel = '合计' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Commission') and 
Relateid in (select fieldid from LD_field where columnname= 'total' and tabid in (select tabid from ld_tab where name = 'Commission') );
delimiter;

update ld_desk set Fieldlabel = '{$ServiceContracts.ServiceContracts}中产品服务到期前N天提醒' where labelbol= 'REMINDSERVICECONTRACTSDEADLINE'
and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel = 'Products service N days before to reminder about the service contracts' where labelbol= 'REMINDSALESORDERDUEDATE'
and languagetype='en' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel = '{$SalesOrder.SalesOrder}交付日期前N天提醒负责人' where labelbol= 'REMINDSALESORDERDUEDATE'
and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel = 'Sales order delivery N days before date to remind the person in charge' where labelbol= 'REMINDSALESORDERDUEDATE'
and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ZEROSAMEDAYREMIND','为０表示当天提醒，为空表示不提醒','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ZEROSAMEDAYREMIND' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ZEROSAMEDAYREMIND','of 0 said the same day to remind, empty not remind','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ZEROSAMEDAYREMIND' and Labeltype='fixedstr');
delimiter;

update LD_settings_field set iconpath = 'proxy.png' where iconpath = 'proxy.gif';
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = 'All';
UPDATE ld_cvcolumnlist set columnname='LD_receipts:userid:recipient:PublicAnnouncement_fieldlabel:V' where 
columnname like '%LD_receipts:recipient:recipient:PublicAnnouncement%' and cvid=@cvid;
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '今日';
UPDATE ld_cvcolumnlist set columnname='LD_receipts:userid:recipient:PublicAnnouncement_fieldlabel:V' where
columnname like '%LD_receipts:recipient:recipient:PublicAnnouncement%' and cvid=@cvid;
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '本周';
UPDATE ld_cvcolumnlist set columnname='LD_receipts:userid:recipient:PublicAnnouncement_fieldlabel:V' where
columnname like '%LD_receipts:recipient:recipient:PublicAnnouncement%' and cvid=@cvid;
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '本月';
UPDATE ld_cvcolumnlist set columnname='LD_receipts:userid:recipient:PublicAnnouncement_fieldlabel:V' where
columnname like '%LD_receipts:recipient:recipient:PublicAnnouncement%' and cvid=@cvid;
delimiter;

SELECT tabid into @tabid  from ld_tab where name='PublicAnnouncement';
UPDATE ld_tranlabel set fieldlabel='公告' where  Relateid=@tabid and tabid=@tabid and languagetype='zh' and trantable='LD_tab';
UPDATE ld_tranlabel set fieldlabel='Announcements' where  Relateid=@tabid and tabid=@tabid and languagetype='en' and trantable='LD_tab';
delimiter;

SELECT tabid into @tabid  from ld_tab where name='PublicAnnouncement';
UPDATE ld_field  set defaultvalue= 'thistoday' where tabid=@tabid and fieldname in ('startdate','enddate');
delimiter;
-- end 2014-07-16

update ld_tab set presence=1 where `name`='Announcements';
delete from ld_parenttabrel where parenttabid=6 and tabid=54;

select tabid into @tabid from ld_tab where name='HelpDesk';
select ifnull(max(fieldid),0) into @maxid from ld_field;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_TICKET_INFORMATION';
select ifnull(max(sequence),0) into @seq from ld_field where tabid=@tabid and block=@blockid and presence<>1 and displaytype=1;
select 'fees' into @columnname;
select 'fees' into @en;
select '收费金额' into @zh;
select 'LD_troubletickets' into @tablename;
select 71 into @uitype;
select 'N~O' into @typeofdate;


update ld_blocks set visible=0 where blockid=@blockid and tabid=@tabid;
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@columnname,@zh,0,2,'',100,@seq+1,@blockid,1,@typeofdate,1,NULL,'BAS',1,NULL,0  
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname=@columnname);
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@blockid and sequence>@seq and columnname<>@columnname;

update ld_field_seq set id=(select max(fieldid) from ld_field);

select fieldid into @relateid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@relateid,@zh from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@relateid,@en from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_field');

call addcolumn(@tablename,@columnname,'int','19',0);
alter table LD_troubletickets modify column fees decimal(25,2);
call fieldprofile(@tablename);
call getallprofile(@tablename);
delimiter;


-- 删除ld_crmentity表相对应的字段 
DROP PROCEDURE IF EXISTS delcrmentityfld; 
delimiter || 
CREATE PROCEDURE delcrmentityfld( 

) 
BEGIN 
SELECT DATABASE() INTO @tableschema; 
set @ptablename = 'ld_crmentity'; 
SET @tsql=CONCAT('select COUNT(column_name) INTO @colcount from information_schema.columns where TABLE_SCHEMA = "',@tableschema,'" and table_name= "',@ptablename,'";'); 
PREPARE stmt FROM @tsql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 
IF @colcount = 13 THEN 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN smownerid;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN smcreatorid;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN modifiedby;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN createdtime;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN modifiedtime;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN viewedtime;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN description;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN status;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN version;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN presence;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN deleted;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

END IF; 

END || 
delimiter; 

CALL delcrmentityfld();
delimiter;

SELECT tabid into @tabid  from ld_tab where name='PublicAnnouncement';
UPDATE ld_profile2field set readonly=0 where tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where name='Announcements';
UPDATE ld_tab set presence=1 where tabid=@tabid;
delimiter;

SELECT tabid into @tabid  from ld_tab where name='PublicAnnouncement';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
UPDATE ld_field set sequence=1 where tabid =@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='publicannouncement_type';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='startdate';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='enddate';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='content';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='userid';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='userid';
SELECT MAX(sequence) into @maxsequence from ld_field where tabid=@tabid;
UPDATE ld_field set sequence =@maxsequence+1 where tabid=@tabid and fieldid=@fieldid;

UPDATE ld_field set maximumlength=100 where tabid=@tabid;
delimiter;

SELECT tabid into @tabid  from ld_tab where name='PublicAnnouncement';
DELETE  from ld_tranlabel where tabid=@tabid and trantable='LD_tab' and languagetype='zh';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'公告'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='公告');
delimiter;

SELECT tabid into @tabid from ld_tab where name='PublicAnnouncement';
UPDATE ld_field set  displaytype=2 where tabid=@tabid and columnname='modifiedby';
delimiter;
SELECT tabid into @tabid from ld_tab where name='PurchaseBack';
UPDATE ld_field set  displaytype=2 where tabid=@tabid and columnname='modifiedby';
delimiter;
SELECT tabid into @tabid from ld_tab where name='PurchaseCashBack';
UPDATE ld_field set  displaytype=2 where tabid=@tabid and columnname='modifiedby';
delimiter;

SELECT cvid INTO @cvid FROM LD_customview WHERE entitytype = 'PurchaseCashBack' AND viewname = 'ALL' LIMIT 1;
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,8,'LD_purchasecashback:createdtime:createdtime:PurchaseCashBack_Created_Time:T'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_cvcolumnlist  WHERE cvid = @cvid
AND columnindex =8 AND columnname = 'LD_purchasecashback:createdtime:createdtime:PurchaseCashBack_Created_Time:T');
delimiter;
UPDATE ld_field SET tablename = 'LD_contactdetails' WHERE tabid = 6 AND tablename = 'LD_contactaddress';
delimiter;

delete from ld_tranlabel where relateid in(select fieldid from ld_field
 where tabid in(select tabid from ld_tab where name='publicannouncement')
 and columnname='description');

delete from ld_field where tabid in(select tabid from ld_tab where name='publicannouncement') and columnname='description';
 delimiter;
Select  max(tabid) into @tabid from LD_tab;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileProducts',1,50,'mobileProducts',0,0,1,'Finacial',1 from dual where not exists(select 1 from lD_tab where name='mobileProducts');
select MAX(cvid) into @maxid  from ld_customview;
update LD_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileProducts' and entitytype='mobileProducts');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileProducts',0,0,'mobileProducts',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileProducts' and entitytype='mobileProducts');
select cvid into @cvid   from LD_customview where viewname='mobileProducts' and entitytype='mobileProducts';
delete from LD_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileProducts' and entitytype='mobileProducts' );
insert into LD_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'LD_products:productname:productname:Products_产品名称:V' );
delimiter;

Select  max(tabid) into @tabid from LD_tab;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobilePublicAnnouncement',1,50,'mobilePublicAnnouncement',0,0,1,'Finacial',1 from dual where not exists(select 1 from lD_tab where name='mobilePublicAnnouncement');
select MAX(cvid) into @maxid  from ld_customview;
update LD_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobilePublicAnnouncement' and entitytype='mobilePublicAnnouncement');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobilePublicAnnouncement',0,0,'mobilePublicAnnouncement',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobilePublicAnnouncement' and entitytype='mobilePublicAnnouncement');
select cvid into @cvid   from LD_customview where viewname='mobilePublicAnnouncement' and entitytype='mobilePublicAnnouncement';
delete from LD_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobilePublicAnnouncement' and entitytype='mobilePublicAnnouncement' );
insert into LD_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'LD_publicannouncement:subject:subject:PublicAnnouncement_标题:V' );
insert into LD_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'LD_publicannouncement:startdate:startdate:PublicAnnouncement_发布日期:D' );
insert into LD_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'LD_publicannouncement:content:content:PublicAnnouncement_content:V' );
delimiter;
-- 2014-07-17

update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_account:') where cvid in (select cvid from ld_customview where entitytype='Accounts');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_accountbillads:','LD_account:') where cvid in (select cvid from ld_customview where entitytype='Accounts');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_contactdetails:') where cvid in (select cvid from ld_customview where entitytype='Contacts');
delete from ld_field where columnname='campaignrelstatus';
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_potential:') where cvid in (select cvid from ld_customview where entitytype='Potentials');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_troubletickets:') where cvid in (select cvid from ld_customview where entitytype='HelpDesk');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_quotes:') where cvid in (select cvid from ld_customview where entitytype='Quotes');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_purchaseorder:') where cvid in (select cvid from ld_customview where entitytype='PurchaseOrder');
update ld_tabwithproductview set `columns`=replace(`columns`,'LD_crmentity:','LD_purchaseorder:') where tabid=21;
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_salesorder:') where cvid in (select cvid from ld_customview where entitytype='SalesOrder');
update ld_tabwithproductview set `columns`=replace(`columns`,'LD_crmentity:','LD_salesorder:') where tabid=22;
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_invoice:') where cvid in (select cvid from ld_customview where entitytype='Invoice');
update ld_tabwithproductview set `columns`=replace(`columns`,'LD_crmentity:','LD_invoice:') where tabid=23;
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_notes:') where cvid in (select cvid from ld_customview where entitytype='Documents');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_pricebook:') where cvid in (select cvid from ld_customview where entitytype='PriceBooks');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_products:') where cvid in (select cvid from ld_customview where entitytype='Products');
delimiter;

update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_vendor:') where cvid in (select cvid from ld_customview where entitytype='Vendors');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_campaign:') where cvid in (select cvid from ld_customview where entitytype='Campaigns');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_servicecontracts:') where cvid in (select cvid from ld_customview where entitytype='ServiceContracts');
update ld_tabwithproductview set `columns`=replace(`columns`,'LD_crmentity:','LD_servicecontracts:') where tabid=37;
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_modcomments:') where cvid in (select cvid from ld_customview where entitytype='ModComments');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_projectmilestone:') where cvid in (select cvid from ld_customview where entitytype='ProjectMilestone');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_projecttask:') where cvid in (select cvid from ld_customview where entitytype='ProjectTask');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_project:') where cvid in (select cvid from ld_customview where entitytype='Project');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_contactrecords:') where cvid in (select cvid from ld_customview where entitytype='ContactRecords');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_paymentplan:') where cvid in (select cvid from ld_customview where entitytype='PaymentPlan');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_cashbill:') where cvid in (select cvid from ld_customview where entitytype='CashBill');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_faq:') where cvid in (select cvid from ld_customview where entitytype='Faq');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_expense:') where cvid in (select cvid from ld_customview where entitytype='Expense');
update ld_tabwithproductview set `columns`=replace(`columns`,'LD_crmentity:','LD_stock:') where tabid=(select tabid from ld_tab where name='Stock');
update ld_tabwithproductview set `columns`=replace(`columns`,'LD_crmentity:','LD_outboundorder:') where tabid=(select tabid from ld_tab where name='OutboundOrder');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_sendpayment:') where cvid in (select cvid from ld_customview where entitytype='SendPayment');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_vendorcontacts:') where cvid in (select cvid from ld_customview where entitytype='VendorContact');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_vendorcontacts:') where cvid in (select cvid from ld_customview where entitytype='VendorContactRecords');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_attachmentsforbills:') where cvid in (select cvid from ld_customview where entitytype='Attachment');
delimiter;

update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_bankaccountset:') where cvid in (select cvid from ld_customview where entitytype='BankAccountSet');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_putcash:') where cvid in (select cvid from ld_customview where entitytype='PutCash');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_cashdeposit:') where cvid in (select cvid from ld_customview where entitytype='CashDeposit');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_commission:') where cvid in (select cvid from ld_customview where entitytype='Commission');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_lessionplan:') where cvid in (select cvid from ld_customview where entitytype='LessionPlan');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_purchaseback:') where cvid in (select cvid from ld_customview where entitytype='PurchaseBack');
update ld_cvcolumnlist set columnname=replace(columnname,'LD_crmentity:','LD_purchasecashback:') where cvid in (select cvid from ld_customview where entitytype='PurchaseCashBack');
delimiter;
-- end 2014-07-18

select max(fieldid) into @fieldid from ld_field;
update ld_field_seq set id=@fieldid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SELECTOFPERSONNEL','选择人员','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SELECTOFPERSONNEL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SELECTOFPERSONNEL','Selection of personnel','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SELECTOFPERSONNEL' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AVAILABLEPERSONNEL','可用人员','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AVAILABLEPERSONNEL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AVAILABLEPERSONNEL','Available personnel','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AVAILABLEPERSONNEL' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SELECTEDPERSONNEL','已选人员','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SELECTEDPERSONNEL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SELECTEDPERSONNEL','Selected personnel','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SELECTEDPERSONNEL' and Labeltype='fixedstr');
delimiter;

UPDATE ld_tab set printtab=0 where name='ld_publicannouncement';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','STARTDATECANNOTBEGREATERTHANENDDATE','开始日期不能大于结束日期!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='STARTDATECANNOTBEGREATERTHANENDDATE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','STARTDATECANNOTBEGREATERTHANENDDATE',"Start date cannot be greater than end date!",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='STARTDATECANNOTBEGREATERTHANENDDATE' and Labeltype='jspop');
delimiter;

select max(picklistid) into @picklistid from ld_picklist;
insert into ld_picklist
select @picklistid+1,'publicannouncement_type'
from dual where not exists (select 1 from ld_picklist where name='publicannouncement_type');
update ld_picklist_seq set id=(select max(picklistid) from ld_picklist);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '今日';
UPDATE ld_customview set `status`=3 where cvid=@cvid;
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '本周';
UPDATE ld_customview set `status`=3 where cvid=@cvid;
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'PublicAnnouncement' and viewname = '本月';
UPDATE ld_customview set `status`=3 where cvid=@cvid;
delimiter;

SELECT tabid into @tabid  from ld_tab where name='PublicAnnouncement';
UPDATE ld_field set typeofdata='V~O' where tabid=@tabid and columnname='content';
UPDATE ld_field set presence=1 where tabid=@tabid and columnname='description';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='content';
UPDATE ld_tranlabel set fieldlabel='内容' where tabid=@tabid and trantable='LD_field' and languagetype='zh' and Relateid=@fieldid;
UPDATE ld_tranlabel set fieldlabel='Content' where tabid=@tabid and trantable='LD_field' and languagetype='en' and Relateid=@fieldid;
delimiter;

select tabid into @tabid from ld_tab where name = 'InventoryAccount';
update ld_field set uitype = 71 where tabid = @tabid and columnname in ('inputqty','outputqty','lastqty','firstqty');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Emails';
UPDATE ld_field SET tablename = 'LD_activity' WHERE tabid = @tabid AND tablename = 'LD_crmentity';
UPDATE ld_field SET displaytype = 2 WHERE tabid = @tabid AND fieldname = 'createdtime' AND displaytype != 2;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ALLNOPUBLIC','全部(非公海)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ALLNOPUBLIC' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ALLNOPUBLIC','ALL(no public)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ALLNOPUBLIC' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ALLCONTAINPUBLIC','全部(含公海)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ALLCONTAINPUBLIC' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ALLCONTAINPUBLIC','ALL(contain public)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ALLCONTAINPUBLIC' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ALLNOPUBLIC','全部(非公海)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ALLNOPUBLIC' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ALLNOPUBLIC','ALL(no public)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ALLNOPUBLIC' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AFTERCONVERTINGMODIFYTHEOWNER','普通客户转为公海后，更改客户负责人为（为空表示不更改）','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AFTERCONVERTINGMODIFYTHEOWNER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AFTERCONVERTINGMODIFYTHEOWNER','After converting modify the owner as（if not null）','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AFTERCONVERTINGMODIFYTHEOWNER' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WEHERTODISPLAYTHEPUBLICCUSTOMERES','客户序时簿“全部”页签是否显示公海客户','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WEHERTODISPLAYTHEPUBLICCUSTOMERES','Wether to display the public customers on the “All” tab','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES' and Labeltype='fixedstr');
delimiter;

call addcolumn('LD_account_set','wheathershow ','int','11',1);
UPDATE ld_account_set set  wheathershow=1;
delimiter;
call addcolumn('LD_account_set','userid ','int','11',1);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FIELDSMAPPEDMORETHANONCE','以下字段映射不止一次请检查映射','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FIELDSMAPPEDMORETHANONCE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FIELDSMAPPEDMORETHANONCE','The following fields mapped more than once pleace check mapping','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FIELDSMAPPEDMORETHANONCE' and Labeltype='jspop');
delimiter;
-- end 2014-07-21

update ld_account_set set status=1 where not exists (select 1 from ld_account where publicaccount=1);
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','GUOTONGREPORT','国通报表','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='GUOTONGREPORT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','GUOTONGREPORT','GuoTongReport','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='GUOTONGREPORT' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Customerclassification','客户分类','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Customerclassification' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Customerclassification','Customer classification','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Customerclassification' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Unit','单位','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Unit' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Unit','Unit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Unit' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DoctorsName','医生姓名','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DoctorsName' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DoctorsName','Doctors Name','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DoctorsName' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Model','产品型号','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Model' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Model','Model','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Model' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Direct','直营','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Direct' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Direct','Direct','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Direct' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Proxy','代理','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Proxy' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Proxy','Proxy','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Proxy' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Whetherthebilling','是否开票','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Whetherthebilling' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Whetherthebilling','Whether the billing','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Whetherthebilling' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Doctor','医生','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Doctor' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Doctor','Doctor','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Doctor' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CostStatistics','成本统计表','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CostStatistics' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CostStatistics','Cost Statistics','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CostStatistics' and Labeltype='fixedstr');
delimiter;

update ld_field set uitype = 72 where fieldname = 'hdnDiscountPercent';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DELETEFOLDER','删除文件夹','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELETEFOLDER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DELETEFOLDER','Delete Folder','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DELETEFOLDER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RENAMEFOLDER','重命名文件夹','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RENAMEFOLDER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RENAMEFOLDER','Rename Folder','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RENAMEFOLDER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEPLANTHISMONTHLASTMONTHCOMPLETED','本月计划(上月填写)：','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='THEPLANTHISMONTHLASTMONTHCOMPLETED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEPLANTHISMONTHLASTMONTHCOMPLETED','The plan this month (last month completed):','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEPLANTHISMONTHLASTMONTHCOMPLETED' and Labeltype='fixedstr');
delimiter;

update ld_desk set Fieldlabel = '合计' where Fieldlabel = '总计';
update ld_tranlabel set fieldlabel = '合计' where fieldlabel = '总计';
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
select fieldid into @fieldid from ld_field where tabid = @tabid and uitype = 200;
update ld_tranlabel set fieldlabel = '选择源单' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delimiter;
select tabid into @tabid from ld_tab where name = 'Commission';
select fieldid into @fieldid from ld_field where tabid = @tabid and uitype = 200;
update ld_tranlabel set fieldlabel = '选择源单' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delimiter;
select tabid into @tabid from ld_tab where name = 'Invoice';
select fieldid into @fieldid from ld_field where tabid = @tabid and uitype = 200;
update ld_tranlabel set fieldlabel = '选择源单' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delimiter;

select tabid into @tabid from ld_tab where name = 'Expense';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid' and uitype = 80;
update ld_tranlabel set fieldlabel = '选择源单' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
update ld_field set uitype = 202 where  tabid = @tabid and fieldid = @fieldid;
delimiter;

call addcolumn('ld_cashbill','entitytype','varchar',25,null);
call addcolumn('ld_cashbill2paymentplan','entitytypeid','int','19',0);
call addcolumn('ld_cashbill2paymentplan','entitytype','varchar',25,null);

call addcolumn('ld_commission','entitytype','varchar',25,null);
call addcolumn('ld_commission2payment','entitytypeid','int','19',0);
call addcolumn('ld_commission2payment','entitytype','varchar',25,null);

call addcolumn('ld_invoice','entitytype','varchar',25,null);

call addcolumn('ld_expense','entitytype','varchar',25,null);

select tabid into @tabid from ld_tab where name = 'CashBill';
update ld_field set uitype = 202 where tabid = @tabid and uitype = 200;
delimiter;

select tabid into @tabid from ld_tab where name = 'Commission';
update ld_field set uitype = 202 where tabid = @tabid and uitype = 200;
delimiter;

select tabid into @tabid from ld_tab where name = 'Invoice';
update ld_field set uitype = 202 where tabid = @tabid and uitype = 200;
delimiter;

update ld_cashbill2paymentplan set entitytypeid = salesorderid where salesorderid >0;
delimiter;

update ld_commission2payment set entitytypeid = salesorderid where salesorderid >0;
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','SERVICECONTRACTSTYPE','类型','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='SERVICECONTRACTSTYPE');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','SERVICECONTRACTSTYPE','Type','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='SERVICECONTRACTSTYPE');
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','ASSIGNEDTO','负责人','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='ASSIGNEDTO');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','ASSIGNEDTO','Assigned To','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='ASSIGNEDTO');
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','SOURCEMODULE','选择源单','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='SOURCEMODULE');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','SOURCEMODULE','Select SourceModule','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='SOURCEMODULE');
delimiter;

delete from ld_cvcolumnlist where columnname = 'LD_expense:salesorderid:salesorder_id:Expense_Sales_Order:I' and 
cvid in (select cvid from ld_customview where entitytype = 'Expense');
delimiter;

update ld_expense set entitytype = 'SalesOrder' where entitytype is null;
delimiter;
update ld_cashbill set entitytype = 'SalesOrder' where entitytype is null;
delimiter;
update ld_commission set entitytype = 'SalesOrder' where entitytype is null;
delimiter;
update ld_invoice set entitytype = 'SalesOrder' where entitytype is null;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_sourcemodule` (
  `module` varchar(25) DEFAULT NULL,
  `fieldname` varchar(25) DEFAULT NULL,
  `entitytype` varchar(25) DEFAULT NULL,
  `sequence` int(19) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into ld_sourcemodule(module,fieldname,entitytype,sequence)
select 'Expense', 'salesorder_id', 'SalesOrder', '1' from dual where not EXISTS
(select 1 from ld_sourcemodule where module = 'Expense' and entitytype = 'SalesOrder');

insert into ld_sourcemodule(module,fieldname,entitytype,sequence)
select 'Expense', 'servicecontractsid', 'ServiceContracts', '2' from dual where not EXISTS
(select 1 from ld_sourcemodule where module = 'Expense' and entitytype = 'ServiceContracts');

insert into ld_sourcemodule(module,fieldname,entitytype,sequence)
select 'CashBill', 'salesorder_id', 'SalesOrder', '1' from dual where not EXISTS
(select 1 from ld_sourcemodule where module = 'CashBill' and entitytype = 'SalesOrder');

insert into ld_sourcemodule(module,fieldname,entitytype,sequence)
select 'CashBill', 'servicecontractsid', 'ServiceContracts', '2' from dual where not EXISTS
(select 1 from ld_sourcemodule where module = 'CashBill' and entitytype = 'ServiceContracts');

insert into ld_sourcemodule(module,fieldname,entitytype,sequence)
select 'Commission', 'salesorder_id', 'SalesOrder', '1' from dual where not EXISTS
(select 1 from ld_sourcemodule where module = 'Commission' and entitytype = 'SalesOrder');

insert into ld_sourcemodule(module,fieldname,entitytype,sequence)
select 'Commission', 'servicecontractsid', 'ServiceContracts', '2' from dual where not EXISTS
(select 1 from ld_sourcemodule where module = 'Commission' and entitytype = 'ServiceContracts');
delimiter;
-- end 2014-07-22

update LD_account set lastcontactdate=date_format(createdtime,'%Y-%m-%d') where lastcontactdate is null;

SELECT tabid into @tabid  from ld_tab where name='PublicAnnouncement';
DELETE  from ld_tranlabel where tabid=@tabid and trantable='LD_tab' and languagetype='zh';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'公告'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='公告');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','UPLOADAGAIN','重新上传','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='UPLOADAGAIN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','UPLOADAGAIN','Upload again','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='UPLOADAGAIN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','THENUMBEROFRETURNS1','退货数量不允许超过已退货后的退货单数量','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='THENUMBEROFRETURNS1');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','THENUMBEROFRETURNS1','The number of returns does not allow more than has been returned after the return quantity','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='THENUMBEROFRETURNS1');
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','THENUMBEROFRETURNS2','退货金额不允许超过退货单金额','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='THENUMBEROFRETURNS2');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','THENUMBEROFRETURNS2','Returning amount does not exceed the amount of the return of single','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='THENUMBEROFRETURNS2');
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','THENUMBEROFRETURNS3','退款数量不允许超过已退款后的退款单数量','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='THENUMBEROFRETURNS3');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','THENUMBEROFRETURNS3','Refund amount does not exceed refund refund after the order quantity','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='THENUMBEROFRETURNS3');
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','THENUMBEROFRETURNS4','退款金额不允许超过退款单金额','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='THENUMBEROFRETURNS4');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','THENUMBEROFRETURNS4','Refund amount does not exceed the amount of the refund of a single','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='THENUMBEROFRETURNS4');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PaymentPlan';
UPDATE ld_field SET tablename = 'LD_paymentplan' WHERE tabid = @tabid AND tablename = 'LD_crmentity' AND columnname = 'smownerid';
delimiter;

update ld_desk set Fieldlabel = '{$SalesOrder.SalesOrder}交付日期前N天提醒' where labelbol= 'REMINDSALESORDERDUEDATE'
and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel = 'Sales order delivery N days before date reminder' where labelbol= 'REMINDSALESORDERDUEDATE'
and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
-- end 2014-04-23

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PaymentPlan';
UPDATE ld_field SET tablename = 'LD_paymentplan' WHERE tabid = @tabid AND tablename = 'LD_crmentity' AND columnname = 'smownerid';
delimiter;
UPDATE ld_customview SET STATUS = '0' WHERE 3 = STATUS AND 'All' = viewname AND entitytype IN ('CashBill','SendCashBill');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'PaymentPlan';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
delete from ld_tranlabel where trantable='LD_field' and tabid=@tabid and Relateid=@fieldid;
DELETE FROM ld_field WHERE tabid = @tabid AND columnname = 'smownerid';
SELECT MAX(fieldid) INTO @fieldid FROM ld_field;
SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_PaymentPlan_INFORMATION';
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
SELECT @tabid,@fieldid+1,'smownerid','LD_paymentplan',53,'assigned_user_id','负责人',@blockid,1,0,'V~O',8
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid = @tabid AND columnname = 'smownerid');
UPDATE ld_field_seq SET id=@fieldid+1;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'负责人' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','COMMONACCOUNT','普通客户','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='COMMONACCOUNT' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','COMMONACCOUNT','Common Account','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMONACCOUNT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','PUBLICACCOUNT','公海客户','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PUBLICACCOUNT' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','PUBLICACCOUNT','Public Account','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PUBLICACCOUNT' and Labeltype='fixedstr');
delimiter;

update ld_field set presence=1 where tabid=6 and columnname='lastserviceenddate';

update ld_tab set presence=1 where name in('commission','putcash','bankcash','cashdeposit','BankAccountSet') and EXISTS(select 1 from ld_version where versiontype=2);
update ld_tab set presence=1 where name in('commission','putcash','bankcash','cashdeposit','BankAccountSet') and EXISTS(select 1 from ld_version where versiontype=7);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SORRYPREVIEWFAILEDPLEASERETURN','未找到文件，预览失败！','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SORRYPREVIEWFAILEDPLEASERETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SORRYPREVIEWFAILEDPLEASERETURN','File not found, preview failed!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SORRYPREVIEWFAILEDPLEASERETURN' and Labeltype='fixedstr');
delimiter;

insert into ld_sourcemodule(module,fieldname,entitytype,sequence)
select 'Invoice', 'salesorder_id', 'SalesOrder', '1' from dual where not EXISTS
(select 1 from ld_sourcemodule where module = 'Invoice' and entitytype = 'SalesOrder');

insert into ld_sourcemodule(module,fieldname,entitytype,sequence)
select 'Invoice', 'servicecontractsid', 'ServiceContracts', '2' from dual where not EXISTS
(select 1 from ld_sourcemodule where module = 'Invoice' and entitytype = 'ServiceContracts');
delimiter;

delete from ld_tabwithproductview where tabid=37 and cvid=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_servicecontracts:contract_no:contract_no:ServiceContracts_fieldlabel:V',0,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_servicecontracts:accountid:account_id:ServiceContracts_fieldlabel:I',1,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:V',2,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_servicecontracts:contract_type:contract_type:ServiceContracts_fieldlabel:V',3,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_servicecontracts:contract_status:contract_status:ServiceContracts_fieldlabel:V',4,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_servicecontracts:total:hdnGrandTotal:ServiceContracts_fieldlabel:N',5,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_servicecontracts:smownerid:assigned_user_id:ServiceContracts_fieldlabel:V',6,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_products:productname:productname:Products_fieldlabel:V',7,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_products:productsheet:productsheet:Products_fieldlabel:V',8,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_inventoryproductrel:servicecontracts_start_date:servicecontracts_start_date:Products_fieldlabel:D',9,0;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select 37,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D',10,0;
delimiter;

update ld_desk set Fieldlabel='小计' where labelbol='RECEIPT' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='小计' where labelbol='PAYMENT' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='小计' where labelbol='NETTOTAL' and languagetype='zh' and Labeltype='fixedstr';
-- end 2014-04-24

update ld_field set presence=2 where tabid=13 and columnname='servicecontractsid';
-- end 2014-07-25

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.5' ,current_version='V5.5' ,remark='V5.5-20140725';
delimiter;