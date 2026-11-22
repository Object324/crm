
var popupobj=CrmPopup.getPopupObj("last");
popupobj.before_validate=function()
{
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	//系统设置增加参数-客户最晚服务到期日到期后是否允许创建客户服务单
	var s_url = "action=HelpDeskAjax&module=HelpDesk&file=getAccountsForLastsevicedate";
	var account_id = '';	//客户
	var contact_id = '';	//联系人
	var salesorder_id = '';	//合同订单
	var servicecontractsid = '';	//服务合同
	var product_id = '';	//产品管理
	var projectid = '';	//项目
	if(CrmPopup.isExistsObj(divid,'account_id'))
	{
	   account_id=CrmPopup.getHtmlobjval(divid,"account_id");
	   s_url += '&account_id='+account_id;
	}
	if(CrmPopup.isExistsObj(divid,'contact_id'))
	{
	   contact_id=CrmPopup.getHtmlobjval(divid,"contact_id");
	   s_url += '&contact_id='+contact_id;
	}
	if(CrmPopup.isExistsObj(divid,'salesorder_id'))
	{
	   salesorder_id=CrmPopup.getHtmlobjval(divid,"salesorder_id");  
	   s_url += '&salesorder_id='+salesorder_id;
	}
	if(CrmPopup.isExistsObj(divid,'servicecontractsid'))
	{
	   servicecontractsid=CrmPopup.getHtmlobjval(divid,"servicecontractsid");        
	   s_url += '&servicecontractsid='+servicecontractsid;
	}
	if(CrmPopup.isExistsObj(divid,'product_id'))
	{
	   product_id=CrmPopup.getHtmlobjval(divid,"product_id");     
	   s_url += '&product_id='+product_id;
	}
	if(CrmPopup.isExistsObj(divid,'projectid'))
	{
	   projectid=CrmPopup.getHtmlobjval(divid,"projectid"); 
	   s_url += '&projectid='+projectid;
	}
    var bol = true;
    ld.ajax({
		type : "post",
		url : "index.php",
		data : s_url,
		async:false,
		success : function(response) {
			if(trim(response) == 'error'){
				var _msg = arrJsPopLabel['thecurstomerserviceordersarenotallowedtobe'];
				RemindsMsg("","LdPopWidth400px","","yes","",_msg);
				bol = false;
			}
		}
	});
	if(bol){
		return true;
	}
}
popupobj.after_validate=function()
{
  
     var popupobj=CrmPopup.getPopupObj("last");
     var divid=popupobj.divid;
     //edit:can 20211021 48356: （http://47.116.130.205:85/crm/index.php [^]）（嘉兴汇智）客户服务单》编辑，单据adminTT20211020-00662，编辑时下次联系时间（原预约上门时间）不能为空
     /*
    if(CrmPopup.isExistsObj(divid,'cmb_span_optiontext_servicetype'))
        {
		
				 var servicetype=ld("#"+divid+" [name=servicetype]").val().replace(/^\s+/g, '').replace(/\s+$/g, '');
				if(servicetype.indexOf('上门')>=0)
				{   
					var hopetime='';
					var hopetime_end='';
					var hope_address='';
					if(CrmPopup.isExistsObj(divid,'hopetime'))
					{
					   hopetime=CrmPopup.getHtmlobjval(divid,"hopetime");                   
					}
					if(CrmPopup.isExistsObj(divid,'hopetime_end'))
					{
					   hopetime_end=CrmPopup.getHtmlobjval(divid,"hopetime_end");                 
					}
					if(CrmPopup.isExistsObj(divid,'hope_address'))
					{
						hope_address=ld("#"+divid+" [name=hope_address]").val();               
					} 
					
				   if(hopetime==''&&CrmPopup.isExistsObj(divid,'hopetime')) 
				   {                 
						for(var j=0;j<popupobj.fields.length;j++)
						{
							if("hopetime"==popupobj.fields[j].columnname)
							{
								var confirm_str = popupobj.fields[j].fieldlabel+arrJsPopLabel['CANOTEMPTY'];
								RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
								break;
							}
						}
					   
					   var currObj = CrmPopup.findHtmlobj(divid,'hopetime');
					   currObj.focus();
					 
					   return false; 
				   }             
				   else if(hopetime_end==''&&CrmPopup.isExistsObj(divid,'hopetime_end'))
					{               
						for(var j=0;j<popupobj.fields.length;j++)
						{
							if("hopetime_end"==popupobj.fields[j].columnname)
							{
								var confirm_str = popupobj.fields[j].fieldlabel+arrJsPopLabel['CANOTEMPTY'];
								RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
								break;
							}
						}
					   
					   var currObj = CrmPopup.findHtmlobj(divid,'hopetime_end');
					   
						currObj.focus(); 
					   return false; 
					}
					else if(CrmPopup.isExistsObj(divid,'hope_address')&&trim(hope_address.replace(/[\n]/ig,''))==''||trim(hope_address.replace(/[\n]/ig,''))=='<br>')
					{                  
					   for(var j=0;j<popupobj.fields.length;j++)
						{
							if("hope_address"==popupobj.fields[j].columnname)
							{
								var confirm_str = popupobj.fields[j].fieldlabel+arrJsPopLabel['CANOTEMPTY'];
								RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
								break;
							}
						}
					   
					   var currObj = CrmPopup.findHtmlobj(divid,'hope_address');                 
					   currObj.focus(); 
					   return false;
					}                
					if(hopetime>hopetime_end&&CrmPopup.isExistsObj(divid,'hopetime')&&CrmPopup.isExistsObj(divid,'hopetime_end')  ) 
					{               
						for(var j=0;j<popupobj.fields.length;j++)
						{
							if("hope_address"==popupobj.fields[j].columnname)
							{
								hopetime_fieldlabel=popupobj.fields[j].fieldlabel;
								break;
							}
							if("hopetime_end"==popupobj.fields[j].columnname)
							{
								hopetime_end_fieldlabel=popupobj.fields[j].fieldlabel;
								break;
							}
						}
							 
						var confirm_str = hopetime_fieldlabel+arrJsPopLabel['SHOULDLESSTHANOREQUAL']+hopetime_end_fieldlabel;
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						return false;
					}                              
				}
			
            return true;                
         }*/
	return true;    
}

popupobj.showafter=function()
{
 
  
     var  popupobj=CrmPopup.getPopupObj("last");
     var accountid=popupobj.columnfields_value['account_id'];
    
     if(popupobj.type==CreatePagePopup.type&&popupobj.clickchangepage=='yes'&&popupobj.showquickcreate=='no')
     {
        
        //新建界面点击展开
        
        accountid=CrmPopup.getHtmlobjval(popupobj.divid,"account_id");
       
     }
     if(accountid==undefined||accountid==''||accountid==0)
     {
        ld("#"+popupobj.divid+" [name=showServiceContactsInfo]").parent().parent().css("display","none");
        //HelpDeskHistory
     }
     else
     {
        showServiceContractsDetail(accountid,"HelpDesk",popupobj);  
       
		if(popupobj.helpdesk_log == 1){
		  //是否显示服务信息
			getAccountByHelpDeskHistory(accountid,'',popupobj); 
            
            
            
		}else{
			//31776: 客户服务单新增弹出鞥：没有选择客户名称时，客户服务单历史记录、服务信息区块应该不显示
			ld("#"+popupobj.divid+" [name=HelpDeskHistorytr]").css("display","none");
			ld("#"+popupobj.divid+" [name=HelpDeskHistory]").parent().css("display","none");
		}
     }
	 //chj 界面显示后，加载腾讯地图
	 getLocationAddress('locationaddress','edit');
}