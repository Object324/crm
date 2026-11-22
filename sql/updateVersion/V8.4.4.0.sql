CALL  AddColumn('ld_cashbill','kis_id','varchar','200',NULL);
delimiter;
CALL  AddColumn('ld_cashbill','kis_no','varchar','200',NULL);
delimiter;


call AddColumn('ld_account_public','set_default_tab','varchar','50','COMMONACCOUNT');
delimiter;
call AddColumn('ld_leads_public','set_default_tab','varchar','50','COMMONACCOUNT');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetDefaultTab','设置默认页签','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetDefaultTab' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetDefaultTab','Set default tab','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetDefaultTab' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Setbackfillfield','设置回填字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Setbackfillfield' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Setbackfillfield',"Set the backfill field",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Setbackfillfield' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Setbackfillfield','设置回填字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Setbackfillfield' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Setbackfillfield',"Set the backfill field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Setbackfillfield' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_business_backfillfield` ( 
  `id` int(11) NOT NULL auto_increment PRIMARY KEY, 
	`tabid` int(11),
	`tianyanchalabel` varchar(50) NOT NULL,
	`tianyanchaname` varchar(50) NOT NULL,
	`trancolumnname` varchar(50),
	`defaultvalue` varchar(50),
	`trancoltype` varchar(50)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
SET @tabid = (SELECT tabid from ld_tab where name='Accounts');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'creditCode','creditCode','','taxpayer_number','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'creditCode' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyOrgType','companyOrgType','','accountproperty','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyOrgType' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'estiblishTime','estiblishTime','','registration_time','date' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'estiblishTime' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'legalPersonName','legalPersonName','','legal_representative','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'legalPersonName' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'regCapital','regCapital','','registeredcapital','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'regCapital' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'regLocation','regLocation','','locationaddress','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'regLocation' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'industry','industry','','industry','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'industry' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'businessScope','businessScope','','scope_of_business','longtextarea' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'businessScope' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'address','address','','bill_street','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'address' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'country','country','','bill_country','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'country' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'state','state','','bill_state','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'state' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'city','city','','bill_city','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'city' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'district','district','','bill_area','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'district' and tabid = @tabid);
delimiter;
SET @tabid = (SELECT tabid from ld_tab where name='ServiceCharge');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'creditCode','creditCode','','taxpayer_number','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'creditCode' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyOrgType','companyOrgType','','accountproperty','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyOrgType' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'estiblishTime','estiblishTime','','registration_time','date' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'estiblishTime' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'legalPersonName','legalPersonName','','legal_representative','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'legalPersonName' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'regCapital','regCapital','','registeredcapital','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'regCapital' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'regLocation','regLocation','','locationaddress','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'regLocation' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'industry','industry','','industry','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'industry' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'businessScope','businessScope','','scope_of_business','longtextarea' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'businessScope' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'address','address','','bill_street','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'address' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'country','country','','bill_country','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'country' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'state','state','','bill_state','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'state' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'city','city','','bill_city','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'city' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'district','district','','bill_area','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'district' and tabid = @tabid);
delimiter;
SET @tabid = (SELECT tabid from ld_tab where name='Vendors');
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'creditCode','creditCode','','taxpayer_number','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'creditCode' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'companyOrgType','companyOrgType','','vendorproperty','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'companyOrgType' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'estiblishTime','estiblishTime','','registration_time','date' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'estiblishTime' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'legalPersonName','legalPersonName','','legal_representative','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'legalPersonName' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'regCapital','regCapital','','ve_registeredcapital','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'regCapital' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'regLocation','regLocation','','locationaddress','' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'regLocation' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'industry','industry','','glacct','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'industry' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'businessScope','businessScope','','scope_of_business','longtextarea' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'businessScope' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'address','address','','street','text' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'address' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'country','country','','bill_country','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'country' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'state','state','','bill_state','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'state' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'city','city','','bill_city','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'city' and tabid = @tabid);
insert into ld_business_backfillfield(tabid,tianyanchalabel,tianyanchaname,trancolumnname,defaultvalue,trancoltype)
select @tabid,'district','district','','bill_area','picklist' from dual 
where not exists(select 1 from ld_business_backfillfield where tianyanchalabel = 'district' and tabid = @tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','creditCode','纳税人识别号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='creditCode' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','creditCode',"CreditCode",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='creditCode' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','companyOrgType','企业类型','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='companyOrgType' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','companyOrgType',"CompanyOrgType",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='companyOrgType' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','estiblishTime','注册时间','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='estiblishTime' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','estiblishTime',"EstiblishTime",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='estiblishTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','legalPersonName','法定代表人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='legalPersonName' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','legalPersonName',"LegalPersonName",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='legalPersonName' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regCapital','注册资本','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='regCapital' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regCapital',"RegCapital",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='regCapital' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regLocation','注册地址','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='regLocation' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regLocation',"RegLocation",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='regLocation' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','industry','行业','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='industry' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','industry',"Industry",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='industry' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','businessScope','经营范围','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='businessScope' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','businessScope',"BusinessScope",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='businessScope' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','address','详细地址','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='address' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','address',"Address",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='address' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','country','国家','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='country' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','country',"Country",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='country' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','state','省份','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='state' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','state',"State",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='state' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','city','城市','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='city' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','city',"City",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='city' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','district','区域','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='district' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','district',"Area",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='district' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regNumber','注册号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='regNumber' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regNumber',"RegNumber",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='regNumber' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regInstitute','登记机关','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='regInstitute' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regInstitute',"RegInstitute",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='regInstitute' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTFIELDTODATE','不能映射为日期格式!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTFIELDTODATE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTFIELDTODATE',"cannot map to date format!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTFIELDTODATE' and labeltype='jspop');
delimiter;



SET @deploy_type = 335;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'客户没有工商信息不允许导入 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 336;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'供应商没有工商信息不允许导入 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 337;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'服务收费管理没有工商信息不允许导入 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

SET @deploy_type = 338;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'客户启用工商信息模糊查询功能 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 339;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'供应商启用工商信息模糊查询功能 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 340;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'服务收费管理启用工商信息模糊查询功能 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

SET @deploy_type = 341;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'客户启用工商信息批量回填功能 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 342;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'供应商启用工商信息批量回填功能 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;
SET @deploy_type = 343;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'服务收费管理启用工商信息批量回填功能 0:是 1:否' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

SET @deploy_type = 344;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 1,@deploy_type,'天眼查工商接口KEY 0:设置 1:未设置' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUSINESSQUERYINTERFACESETTINGS','工商查询接口设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BUSINESSQUERYINTERFACESETTINGS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BUSINESSQUERYINTERFACESETTINGS',"It is not allowed to import without industrial and commercial information",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BUSINESSQUERYINTERFACESETTINGS' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='启用工商查询接口' where labelbol='ENABLEBUSINESSQUERY' and languagetype = 'zh';
update ld_desk set fieldlabel='Enable business query interface' where labelbol='ENABLEBUSINESSQUERY' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel='没有工商信息不允许保存（新建/编辑）' where labelbol='NOBUSINESSINFOLNOTALLOWSAVE' and languagetype = 'zh';
update ld_desk set fieldlabel='It is not allowed to save without business information (New / Edit)' where labelbol='NOBUSINESSINFOLNOTALLOWSAVE' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel='设置例外规则' where labelbol='SETEXCEPTION' and languagetype = 'zh';
update ld_desk set fieldlabel='Set exception rule' where labelbol='SETEXCEPTION' and languagetype = 'en';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOBUSINESSINFOLNOTALLOWIMPORT','没有工商信息不允许导入','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOBUSINESSINFOLNOTALLOWIMPORT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOBUSINESSINFOLNOTALLOWIMPORT',"It is not allowed to import without industrial and commercial information",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOBUSINESSINFOLNOTALLOWIMPORT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENABLEBUSINESSFUZZYQUERY','启用工商信息模糊查询功能','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENABLEBUSINESSFUZZYQUERY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENABLEBUSINESSFUZZYQUERY',"Enable the fuzzy query function of industrial and commercial information",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENABLEBUSINESSFUZZYQUERY' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENABLEBUSINESSBATCHBACKFILLING','启用工商信息批量回填功能','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENABLEBUSINESSBATCHBACKFILLING' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENABLEBUSINESSBATCHBACKFILLING',"Enable batch backfilling of business information",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENABLEBUSINESSBATCHBACKFILLING' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TIANYANCHABUSINESSINTERFACEKEY','天眼查工商接口KEY','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TIANYANCHABUSINESSINTERFACEKEY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TIANYANCHABUSINESSINTERFACEKEY',"Tianyancha industrial and commercial interface key",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TIANYANCHABUSINESSINTERFACEKEY' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TIANYANCHABUSINESSINTERFACEKEYNOTNULL','天眼查工商接口KEY不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TIANYANCHABUSINESSINTERFACEKEYNOTNULL' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TIANYANCHABUSINESSINTERFACEKEYNOTNULL',"Tianyancha  industrial and commercial interface key cannot be empty!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TIANYANCHABUSINESSINTERFACEKEYNOTNULL' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AFTERSETTINGSKEYCANUSERHIGHFUNCTION','设置天眼查工商接口KEY后，可使用没有工商信息不允许导入、工商信息模糊查询和批量回填功能','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AFTERSETTINGSKEYCANUSERHIGHFUNCTION' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AFTERSETTINGSKEYCANUSERHIGHFUNCTION',"After setting the Tianyan industrial and commercial interface key, you can use the functions of no import without industrial and commercial information, fuzzy query of industrial and commercial information and batch backfilling",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AFTERSETTINGSKEYCANUSERHIGHFUNCTION' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BatchBackFilling','批量回填','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BatchBackFilling' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BatchBackFilling',"Batch Backfilling",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BatchBackFilling' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BatchBackFillingunusing','批量回填功能未启用','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BatchBackFillingunusing' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BatchBackFillingunusing',"The bacth backfill function is not enabled",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BatchBackFillingunusing' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thecustomerbusiness','该客户工商信息不存在！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='thecustomerbusiness' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thecustomerbusiness',"The customer business information does not exist!",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='thecustomerbusiness' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOBACKFILLFIELDS','无可回填字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOBACKFILLFIELDS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOBACKFILLFIELDS',"No backfill fields",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOBACKFILLFIELDS' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','QUANTITYNOTLESS','数量不能小于','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='QUANTITYNOTLESS' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','QUANTITYNOTLESS','Quantity cannot be less than','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='QUANTITYNOTLESS' and Labeltype='jspop');
delimiter;
-- 2021-09-12


UPDATE ld_field SET allowhide='yes' WHERE columnname='accountid';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PCWYWTSTMTMP_VOICE','请选择要拨打语音到哪些手机','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PCWYWTSTMTMP_VOICE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PCWYWTSTMTMP_VOICE','Please choose mobile phones what you want to send text voice messages to ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PCWYWTSTMTMP_VOICE' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','CURUSER','当前用户','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='CURUSER' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','CURUSER','Current user','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='CURUSER' and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_picklist_set','picklist_allowedit','varchar','20','yes');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CustomerTelephone','客户公司电话','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CustomerTelephone' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CustomerTelephone','Customer company Telephone','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CustomerTelephone' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SalesManName','负责人','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SalesManName' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SalesManName','Salesman','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SalesManName' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SalesManMobile','负责人手机','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SalesManMobile' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SalesManMobile','Salesman mobile phone','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SalesManMobile' and Labeltype='fixedstr');
delimiter;
-- 2021-09-17


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

UPDATE ld_version SET old_version='V8.4.4.0',current_version='V8.4.4.0',remark='V8.4.4.0-20210917',wx_version='V8.4.4.0';
delimiter;