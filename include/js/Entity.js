/*
{*窗口  选择模块entityname链接名称，调用JS事件
*/ 
function set_return_account_address(account_id, account_name, bill_street, ship_street,smownerid, bill_city, ship_city, bill_state, ship_state, bill_code, ship_code, bill_country, ship_country,bill_pobox,ship_pobox,discount_rate) {
	//选择客户回传函数
    ///弹出层和弹出窗体都调用该函数
   var parentwindow=window;
   var browser = getBrowserInfo() ;
   var verinfo = (browser+"").replace(/[^0-9.]/ig,""); 
   var bol=true;
 
   
   if(document.all &&verinfo.indexOf("10")>=0)//ie10浏览器特殊 判断
   {
       if(window.top!=window.self)
       {
         bol=false;
       }
   }
    //&& window.opener.setAccountInfo != undefined
	//if( bol&& window.opener != undefined && window.opener.setAccountInfo != undefined){//日志，微博哦
   
     
		//var b = window.opener.setAccountInfo(account_id, account_name);
		//if(b) return false;
	//}
    var search_from_name;
    
	if(search_form_obj != undefined&&search_form_obj!=null)
	{
		search_from_name = search_form_obj.name;
		
        
		if(search_from_name == 'QcEditView' && document.opener != undefined)
		{
		   
			//parentwindow = window.opener;
		}
	}


    //isPopupButton：变量:在include/js/general.js,用于判断点击按钮是否是弹出框
    //isContactRecordsQuickCreate:跟进判断
    if((typeof isPopupButton!='undefined'&&isPopupButton=='yes')||(typeof isContactRecordsQuickCreate!='undefined'&&isContactRecordsQuickCreate=='yes')|| (window.document != undefined && window.document.QcEditView != undefined)) {
		parentwindow=window;
        parentwindow.document.QcEditView.accounts_name.value = account_name;
        parentwindow.document.QcEditView.account_id.value = account_id;
       
        /**
        *@author:andy
        *@data:20141027
        *@reason:选择客户带出联系人
        *@version:v5.8
        */
        /*if(parentwindow.document.QcEditView.contacts_name != undefined && parentwindow.document.QcEditView.contact_id != undefined)
        {
                var quickform=parentwindow.document.QcEditView;
                var frommodule=parentwindow.document.QcEditView.module;
                parentwindow.customerintocontact(account_id,quickform,frommodule,'Accounts');//带入该客户的联系人
               
        }*/
	} else {
	   
	   /**
       *新增操作,销售机会增加 相关客户字段
       *date 20140318
       * by andy
       */
    
	   var url=location.search;
        var Request = new Object();
        if(url.indexOf("?")!=-1)
        {
            var str = url.substr(1)  //去掉?号
            strs = str.split("&");
            for(var i=0;i<strs.length;i++)
            {
                Request[strs[i].split("=")[0]]=unescape(strs[i].split("=")[1]);
            }
        }
        
        if(Request["related"] ==2){
            var related_accountid=window.opener.document.EditView.related_accountid;
            var related_accountid_name= window.opener.document.EditView.related_accountid_name;
            if(related_accountid != undefined)
                related_accountid.value=account_id;
            if(related_accountid_name != undefined){
                related_accountid_name.value=account_name;
				//选中客户后，将客户文本框变为不可用
				related_accountid_name.disabled = true;
			}
        }else{
            var modulename='';
            if(window.top!=window.self&&window.opener.document.EditView!=undefined){
                modulename = window.opener.document.EditView.module.value;
            }else  if(window.top==window.self&&window.opener!=undefined&&window.opener.document.EditView!=undefined){//附件管理，评论相关对象
                modulename = window.opener.document.EditView.module.value;
            }else if(document.EditView != undefined){
				modulename=document.EditView.module.value;
			}
            
			/**
			 * 对提醒模块、附件模块做特别处理
			 * @reason 0012540: 附件管理、提醒新增界面：选择客户后，没有带出客户名称
			 * @author Tujt 2014-11-14
			 */
			if(modulename == 'Reminds'){  
				window.document.EditView.related_to_name.value = account_name;
				window.document.EditView.related_to.value = account_id;
				var popupobj=CrmPopup.getPopupObj("last");
				popupobj.CancelEvent();
				return;
			}else if(modulename == 'Attachment'||modulename=='ModComments'){
			
				window.document.EditView.related_to_name.value = account_name;
				window.document.EditView.related_to.value = account_id;
                var popupobj=CrmPopup.getPopupObj("last");
				popupobj.CancelEvent();
				return;
			}else{
				
				if(window.document.EditView != undefined){
					 //17382: 客户模糊匹配，失效
					window.document.EditView.accounts_name.value = account_name;
					window.document.EditView.account_id.value = account_id;
					//选中客户后，将客户文本框变为不可用
					window.document.EditView.accounts_name.disabled = true;
				}
			}
        }
        /**
        *@author:andy
        *@data:20141027
        *@reason:选择客户带出联系人，及相关字段信息
        *@version:v5.8
        */
       /* if(parentwindow.document.EditView.contacts_name != undefined && parentwindow.document.EditView.contact_id != undefined)
        {
            
                var form=parentwindow.document.EditView;
                if(parentwindow.document.EditView.module.value!='Contacts'){
                    parentwindow.customerintocontact(account_id,form,'Users','Accounts');//带入该客户的联系人
                }
        }*/
        
	}
 
    /**
    * edit:chj
    * date:2014-7-5
    * reason:服务单选择客户自动带出客户的服务信息
    */
    //document.getElementById('frommodule') && document.getElementById('frommodule').value != ''
    if(account_id >0 && module=='HelpDesk' )
    {
        //19733: 客户服务单>新建：客户名称字段，模糊匹配，选择后，服务信息区块，没有显示内容。
      //  if(frommodule == 'HelpDesk')
       // {
         // parentwindow.onClickShowServiewDetail(account_id,module);
      //  }
    }
	
	if(modulename == 'HelpDesk'){
		if(getOpenerObj("parent_id_display") != undefined){
			getOpenerObj("parent_id_display").value = account_name;
		}
		if(getOpenerObj("parent_id") != undefined){
			getOpenerObj("parent_id").value = account_id;
		}
	}
   
	/**
	 * @edit:chj
	 * @date:2015/4/17
	 * @reason: V6.0 角色权限改进
	 * @description:收款单、合同订单、服务合同 选中客户后，负责人默认为客户的负责人
	 */
     
     //26050: 自用系统 客户服务单 选择客户后 服务人员带不出来
     //26400: 销售机会>新建： 选择客户后，销售负责人应该默认显示为当前操作员
     //27257: 费用报销模块，选择客户后，报销人为客户负责人，应该默认为当前操作员
     //Liver 项目/项目计划/服务回访单/联系人/联系记录/出库单、bug(...跟路宇翔确认过)
	 /*if(account_id > 0 &&parentwindow.document.EditView!=undefined&& parentwindow.document.EditView.module != undefined&&module!='HelpDesk'
        &&module!='Potentials'&&module!='Expense'&&module!='Project'&&module!='ProjectTask'&&module!='ServiceReturn'&&module!='Contacts'&&module!='CashBill'
        &&module!='OutboundOrder'&&module!='Commission'&&module!='ContactRecords'){
		 var EditViewModule = parentwindow.document.EditView.module.value;
       
        
		 //if(EditViewModule == 'SalesOrder' || EditViewModule == 'CashBill' ){
			if(EditViewModule == 'ServiceContracts')
				var fldname = 'ServiceContractsassigned_user_id';
			else
				var fldname = 'assigned_user_id';*/
             //edit:can reason:15312: 服务合同模块的“销售负责人”改进：新增时，销售负责人默认显示为当前操作员，选择客户后不需要自动更新为该客户的“负责人”。
            /** if(EditViewModule == 'ServiceContracts')
             {
                 fldname="ServiceContractsassigned_user_id";//edit:can reason:14542: 服务合同>新增：新增时，销售负责人默认显示为当前操作员，选择客户后没有自动更新为该客户的“负责人”。
             }**/
			/* if(parentwindow.document.getElementById(fldname) != undefined){
				var objoption=parentwindow.document.getElementById(fldname);
				var optiontext='';
				picklist=true;
				if(objoption.length != undefined){
					for(var i=0;i<objoption.length;i++)
					{
						if(objoption[i].value==smownerid)
						{
							objoption[i].selected=true;
							optiontext=objoption[i].text;
							parentwindow.document.getElementById(fldname).options[i].selected=true;
						 
							parentwindow.document.getElementById(fldname).selectedIndex=i;
							parentwindow.document.getElementById(fldname).options[i].value=smownerid;
							if(typeof parentwindow.document.getElementById(fldname).onchange=='function')
								parentwindow.document.getElementById(fldname).onchange();
							if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
							{
								var sourcename = objoption.name;
								var sourcevalue = objoption.value;	
								fielddepend.fieldValueChange(sourcename, sourcevalue);
							}
							break;
						}
					}
					parentwindow.document.getElementById('cmb_span_optiontext_'+fldname).innerHTML=optiontext;
				}
			 }*/
		// }
	/* }*/
   
	/**
	 * @edit:chj
	 * @date:2014-9-22
	 * @reason: 选择客户名称时，获取客户ID
	 * @description:客户和联系人关联字段
	 */
	if(parentwindow.document.getElementById('bemodulestatus') != undefined && parentwindow.document.getElementById('bemodulestatus').value == 'YES')
	{
		if(parentwindow.document.EditView.contact_id != undefined)
		{
			var contact_id = parentwindow.document.EditView.contact_id.value;
		}
        //var frommodule = document.getElementById('returnmodule').value;
		parentwindow.getAccountsContactsInfo(account_id,contact_id,module,'EditView');
	}
   
	/*if(!discount_rate) discount_rate = 0;
	discount_rate = parseFloat(discount_rate);
    if(discount_rate != '' && discount_rate >= 0 && parentwindow.document.EditView.totalProductCount != undefined)
    {
        var disrate = 0;
        //if(discount_rate == 0)
           // discount_rate = 100;
        parentwindow.document.getElementById('discount_rate').value = discount_rate;
        var max_row_count = parentwindow.document.EditView.totalProductCount.value;
        if(max_row_count > 0)
        {
			var discount_checks = {};
            for(var i=1;i<=max_row_count;i++)
            {
				if( parentwindow.document.getElementById("discount_percent"+i) != undefined){
					parentwindow.document.getElementById("discount_percent"+i).value = discount_rate;
				}
				discount_checks = parentwindow.document.getElementsByName("discount"+i);
				if(discount_checks[2].checked) continue;//直接降价情况下不修改折扣额
                if(parentwindow.document.getElementById("grossprofit"+i) != undefined)
                {
                    var qty = parentwindow.document.getElementById("qty"+i).value;
                    var listPrice = parentwindow.document.getElementById("listPrice"+i).value;
                    var costprice = parentwindow.document.getElementsByName("costprice"+i)[0].value; //成本价
                    var grossprofit = parentwindow.document.getElementById("grossprofit"+i).value;   //期望GP(毛利率)
                    disrate = roundValue(qty*listPrice*(100-discount_rate)/100);
                    var taxTotal = parentwindow.document.getElementById('taxTotal'+i).innerHTML;
                    //parentwindow.document.getElementById("listPrice"+i).value = roundValue(costprice/((1-grossprofit/100) * (1 - discount_rate/100+taxTotal/100)));
                    //alert(roundValue((1-5000/(8000*(1-discount_rate/100)))*100));
                    discount_rate = 100 - discount_rate;
                    parentwindow.document.getElementById("grossprofit"+i).value = roundValue((1-costprice/(listPrice*(1-discount_rate/100+taxTotal/100)))*100);
                    parentwindow.document.getElementById("discountTotal"+i).innerHTML = disrate.toString();
                }
            }
        }
		parentwindow.isupdateacctrate = 2;
    }*/
   return false;

}
/**
 * 获取当前window对象
 * @author Tujt 2015-07-24
 */
function getWinObject(){
	var win = window;var winIdx = 0;
    if(window.opener){
		if(window.opener.document.QcEditView != undefined || window.opener.document.EditView != undefined || window.opener.document.sendLog != undefined){
			win = window.opener;winIdx = 1;
		}
	}
	return {'win':win,'idx':winIdx};
}
function set_return_contact_address(contact_id,contact_name, mailingstreet, otherstreet, mailingcity, othercity, mailingstate, otherstate, mailingcode, othercode, mailingcountry, othercountry,mailingpobox,otherpobox,formName) {
	//选择客户回传函数
	var winObj = getWinObject();
	if(winObj.idx == 1 && winObj.win.setContactInfo != undefined){
		var b = window.opener.setContactInfo(contact_id, contact_name);
		//if(b) return false;
	}
    var parentwindow = window;
  
    //var search_from_name;
	//if(search_form_obj != undefined)
	//{
		//search_from_name = search_form_obj.name;
		
		//if(search_from_name == 'QcEditView'&& document.opener != undefined)
		//{
		   //if(window.opener!=undefined)
			//parentwindow = window.opener;
		//}
	//}
	//else if(window.opener!=undefined){
		//parentwindow = window.opener;
	//}
     //isPopupButton：变量:在include/js/general.js,用于判断点击按钮是否是弹出框
    //isContactRecordsQuickCreate:跟进判断
    if((typeof isPopupButton!='undefined'&&isPopupButton=='yes')||(typeof isContactRecordsQuickCreate!='undefined'&&isContactRecordsQuickCreate=='yes')) {
		parentwindow.document.QcEditView.contacts_name.value = contact_name;
        parentwindow.document.QcEditView.contact_id.value = contact_id;
	}
    else
    {
    	if (formName == null || formName == '')
        {
			if(document.QcEditView != undefined){
				formName = 'QcEditView';
			}else{
				formName = 'EditView';
			}
    	}else {
    		// In case formName is specified but does not exists then revert to EditView form
    		if(parentwindow.document.forms[formName] == null) formName = 'EditView';
    	}  
    	var form = parentwindow.document.forms[formName];
            /**
           *新增操作,销售机会增加 相关客户字段
           *date 20140318
           * by andy
           */
    	   var url=location.search;
           
            var Request = new Object();
            if(url.indexOf("?")!=-1)
            {
                var str = url.substr(1)  //去掉?号
                strs = str.split("&");
                for(var i=0;i<strs.length;i++)
                {
                    Request[strs[i].split("=")[0]]=unescape(strs[i].split("=")[1]);
                }
            }
            //alert(Request["related"])
            if(Request["related"] ==2)
            {
                form.related_contact_name.value = contact_name;
                form.related_contactid.value = contact_id;
            }else
            {
				if(form.module.value == 'ModComments'){
					form.related_to_name.value = decodeURIComponent(contact_name);
					form.related_to.value = contact_id;					
				}else{
				    if(form.contacts_name!='undefined'&&form.contacts_name!=undefined){
				     // 24489: 新增联系人：上级联系人选择带有特殊字符的单据”张 ！@##￥￥￥“，文本中显示错误
   					    form.contacts_name.value = decodeURIComponent(contact_name);
					   form.contact_id.value = contact_id;
				    }

				}
            }
        
    	if(typeof(form.bill_street) != 'undefined' &&typeof(mailingstreet) != 'undefined')
    	if(confirm(alert_arr.OVERWRITE_EXISTING_CONTACT1+contact_name+alert_arr.OVERWRITE_EXISTING_CONTACT2))
    	{
    	  
    		//made changes to avoid js error -- ref : hidding fields causes js error(ticket#4017)
                    if(typeof(form.bill_street) != 'undefined'&&typeof(mailingstreet)!='undefined')
                            form.bill_street.value = mailingstreet;
                    if(typeof(form.ship_street) != 'undefined'&&typeof(otherstreet)!='undefined')
                            form.ship_street.value = otherstreet;
                    if(typeof(form.bill_city) != 'undefined'&&typeof(mailingcity)!='undefined')
                            form.bill_city.value = mailingcity;
                    if(typeof(form.ship_city) != 'undefined'&&typeof(othercity)!='undefined')
                            form.ship_city.value = othercity;
                    if(typeof(form.bill_state) != 'undefined'&&typeof(mailingstate)!='undefined')
                            form.bill_state.value = mailingstate;
                    if(typeof(form.ship_state) != 'undefined'&&typeof(otherstate)!='undefined')
                            form.ship_state.value = otherstate;
                    if(typeof(form.bill_code) != 'undefined'&&typeof(mailingcode)!='undefined')
                            form.bill_code.value = mailingcode;
                    if(typeof(form.ship_code) != 'undefined'&&typeof(othercode)!='undefined')
                            form.ship_code.value = othercode;
    				if(typeof(form.bill_country) != 'undefined'&&typeof(mailingcountry)!='undefined')
                            form.bill_country.value = mailingcountry;
                    if(typeof(form.ship_country) != 'undefined'&&typeof(othercountry)!='undefined')
                            form.ship_country.value = othercountry;
                    if(typeof(form.bill_pobox) != 'undefined'&&typeof(mailingpobox)!='undefined')
                            form.bill_pobox.value = mailingpobox;
                    if(typeof(form.ship_pobox) != 'undefined'&&typeof(otherpobox)!='undefined')
                            form.ship_pobox.value = otherpobox;
    		//end
    	}
     }
	  /**
        *@author:andy
        *@data:20141027
        *@reason:选择联系人带出客户信息
        *@version:v5.8
        */
		/*if(document.QcEditView != undefined){
			formName = 'QcEditView';
		}else{
			formName = 'EditView';
		}
        if(parentwindow.document.forms[formName].accounts_name != undefined && parentwindow.document.forms[formName].account_id != undefined)
        {
                var form=parentwindow.document.forms[formName];
                if(parentwindow.document.forms[formName].module.value!='Accounts'){
                    parentwindow.customerintocontact(contact_id,form,'Users','Contacts');//带入联系人的客户信息
                }
        }*/
     /**
     * @edit:chj
     * @date:2014-9-22
     * @reason: 选择客户名称时，获取客户ID
     * @description:客户和联系人关联字段
     */
    if(parentwindow.document.getElementById('bemodulestatus') != undefined && parentwindow.document.getElementById('bemodulestatus').value == 'YES')
    {
        //frommodule 不能更改成窗口当前模块module:因为得根据frommodule判断联系人和客户字段是否被启用
        if(parentwindow.document.EditView.account_id != undefined)
        {
            var account_id = parentwindow.document.EditView.account_id.value;
        }
        
        parentwindow.getAccountsContactsInfo(account_id,contact_id,'','EditView');
    }
}