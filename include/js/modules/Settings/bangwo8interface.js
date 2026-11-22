function bangwo8interface(){
   var that=this;
   this.ue = '';
}
//刷新
bangwo8interface.refresh = function(){
	var surl = 'index.php?module=Settings&action=bangwo8interface&parenttab=Settings&blockidsetting=2&fieldidsetting=2&ReportHeader=dheader';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
        DelProgressObjs();
	})
}

//编辑
bangwo8interface.edit = function(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=bangwo8interface&mode=edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,bangwo8interface.save,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");

			crmPopupobj.showvalues=data.result.showvalues;
			crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
			crmPopupobj.viewnamelabel=data.result.viewnamelabel;
			crmPopupobj.modulelabel=data.result.modulelabel;

			var advancefilterobj = new cls_advanceFilter();
			var params = {};
			params.columnOptionHtml = data.result.columns_block;
			params.fLabels = data.result.flabels;
			params.datetimestr = data.result.datetimestr;
			params.advfilterhtml = data.result.foption;
			params.criteria_groups_arr = data.result.criteria_groups;
			params.module = 'Settings';
			// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
			params.advanceFields = data.result.advanceFields;
			advancefilterobj.showAdvanceFilter(crmPopupobj,params);

			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
			bangwo8interface.setBwText();
			bangwo8interface.setIsCustomer();
		}
	})
}

bangwo8interface.save = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var vendorid = ld("#"+popupobj.divid+" [name=vendorid]").val();
	var authcode = ld("#"+popupobj.divid+" [name=authcode]").val();
	var presence = ld("#"+popupobj.divid+" [name=presence]").val();
	if(presence == 0){
		if(empty(vendorid)){
			var confirm_str = document.getElementById('vendorid').title+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
			document.getElementById('vendorid').focus();    	 
			return false;
		}
		if(empty(authcode)){
			var confirm_str = document.getElementById('authcode').title+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
			document.getElementById('authcode').focus();
			return false;
		}
	}
	var is_customer = ld("#"+popupobj.divid+" [name=is_customer]").val();
	var supportname = ld("#"+popupobj.divid+" [name=supportname]").val();
	var supportpwd = ld("#"+popupobj.divid+" [name=supportpwd]").val();
	if(is_customer == 0){
		if(empty(supportname)){
			var confirm_str = document.getElementById('supportname').title+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
			document.getElementById('supportname').focus();       
			return false;
		}
		if(empty(supportpwd)){
			var confirm_str = document.getElementById('supportpwd').title+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
			document.getElementById('supportpwd').focus();
			return false;
		}
	}

	var columnlist = new Array();
	var k = 0;
	for(var i=0; i<=100;i++){
		if(ld("#"+popupobj.divid+" [name=fcol"+i+"]").val() != undefined && ld("#"+popupobj.divid+" [name=fcol"+i+"]").val() != ''){
			columnlist[k] = new Array();
			columnlist[k].push(ld("#"+popupobj.divid+" [name=fcol"+i+"]").val());
			columnlist[k].push(ld("#"+popupobj.divid+" [name=fop"+i+"]").val());
			columnlist[k].push(encodeURIComponent(ld("#"+popupobj.divid+" [name=fval"+i+"]").val()));
			columnlist[k].push(ld("#"+popupobj.divid+" [name=fcon"+i+"]").val());
			k++;
		}
	}
	var url='index.php?module=Settings&action=SettingsAjax&file=bangwo8interface&presence='+presence+'&vendorid='+vendorid+'&authcode='+authcode+'&editinterface=editinterface&supportname='+supportname+"&supportpwd="+supportpwd+"&is_customer="+is_customer+"&columnlist="+JSON.stringify(columnlist);
	ldAjax(url,"",function(data){
		if(data.code == 1){
			popupobj.CancelEvent();
			bangwo8interface.refresh();
		}else{
			if(data.msg == 'ISNULL' && presence != 1){	//判断密钥或者vendorid是否正确；
				var confirm_str = arrJsPopLabel['KEYORVENDORIDISERRORPLEASEENTERAGAIN'];
				RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
				return false;
			}else if(data.msg == 'INCORRECT' && presence != 1){	//帮我吧客服账号或者密码错误！
				var confirm_str = arrJsPopLabel['bangwobauserpwd'];
				RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
				return false;
			}else if(data.msg == 'NOURL' && presence != 1){	//判断帮我吧url是否可以访问
				var confirm_str = arrJsPopLabel['crmserver'];
				RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
				return false;
			}
			else{
				popupobj.CancelEvent();
			}
		}
        DelProgressObjs();
	})
}
/**
 *edit:cyb
 *date:2016-05-20
 *reason:设置帮我吧客服账号信息
 **/
/* gyq_14 */
bangwo8interface.settingsBangwo8info = function(obj,bangwo8supportnameid){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=settingsBangwo8info&bangwo8supportnameid='+bangwo8supportnameid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,bangwo8interface.settingsBangwo8info_sava,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
			getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){

				ScopePopup_Details.getInstance().allocateTemplate('',-5,bangwo8supportnameid,'','','settingsBangwo8info');
			});
		}
	})
	
}
/*
*edit: chj
*date: 2020/9/29
*reason: 0042059: (http://bjbzszcrm.gnway.cc/crm/ [^])系统设置>接口设置>帮我吧接口设置：“帮我吧客服区块”操作列点击“设置”按钮，不能绑定“crm负责人”
*/
bangwo8interface.settingsBangwo8info_sava = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var bangwo8supportnameid = ld("#"+popupobj.divid+" [name=bangwo8supportnameid]").val();
	var supportname = ld("#"+popupobj.divid+" [name=supportname]").val();
	ScopePopup_Details.getInstance().SaveBangwo8info(bangwo8supportnameid,supportname);
	popupobj.CancelEvent();
}
/**
 *edit:cyb
 *date:2016-05-20
 *reason:帮我吧设置按钮弹出层中，保存事件处理；
**/
/* gyq_14XX  Has been deleted   function SaveBangwo8info(bangwo8supportnameid,supportname){*/

/**
    *edit:cyb
    *date:2016-05-18
    *reason:调用帮我吧接口，根据crm客户信息修改帮我吧系统公司信息
**/
bangwo8interface.Setbangwo8info = function(operate){
     var url='index.php?module=Settings&action=SettingsAjax&file=Setbangwo8interface&parenttab=Settings&operate='+operate;
	 ldAjax(url,"",function(data){
		if(data.code == 1){
			var confirm_str = arrJsPopLabel['CRMSYSTEMSYNCHRONIZED'];//CRM系统的客户和联系人成功同步到帮我吧系统
			RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
			return false;
		}
        DelProgressObjs();
	 })
}
//帮我吧账户是否启用
bangwo8interface.setBwText = function(){
	if(document.getElementById("presence").checked){
		ld('#presence').val(0);
		ld('#vendorid').attr("disabled",false);
		ld('#authcode').attr("disabled",false);
		ld('#tr_vendorid').show();
		ld('#tr_authcode').show();
		//wym 240508 BUG20240508-18 接口设置-帮我吧接口设置，先开启是否启用按钮，发现下方“是否同步客户和联系人到帮我吧”在未开启的状态下，出现输入框
		/*ld('#tr_supportname').show();
		ld('#tr_supportpwd').show();*/
	}else{
		ld('#presence').val(1);
		ld('#vendorid').attr("disabled",true);
		ld('#authcode').attr("disabled",true);
		ld('#tr_vendorid').hide();
		ld('#tr_authcode').hide();
		/*ld('#tr_supportname').hide();
		ld('#tr_supportpwd').hide();*/
	}
}
//是否同步客户和联系人
bangwo8interface.setIsCustomer = function(){
	if(document.getElementById("is_customer").checked){
		ld('#is_customer').val(0);
		ld('#supportname').attr("disabled",false);
		ld('#supportpwd').attr("disabled",false);
		ld('#tr_supportname').show();
		ld('#tr_supportpwd').show();
	}else{
		ld('#is_customer').val(1);
		ld('#supportname').attr("disabled",true);
		ld('#supportpwd').attr("disabled",true);
		ld('#tr_supportname').hide();
		ld('#tr_supportpwd').hide();
	}
}