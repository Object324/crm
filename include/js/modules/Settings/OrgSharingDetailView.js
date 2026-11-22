function OrgSharingDetailView(){
   var that=this;
   this.ue = '';
}
//刷新
OrgSharingDetailView.refresh = function(){
	var surl = 'index.php?module=Settings&action=OrgSharingDetailView&parenttab=Settings&ReportHeader=dheader';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
		//@edit:liushuai,2020-12-21,reason: 0043026: 系统设置->其他设置->模块共享规则，修改保存规则之后，界面删公的滚动条不见了，没法看到下面的数据
		initRightContentHeight();//加载右侧内容中菜单和详细内容高度
        DelProgressObjs();
	})
}

//编辑
OrgSharingDetailView.edit = function(){
	var surl = 'index.php?module=Users&action=UsersAjax&file=OrgSharingEditView';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,OrgSharingDetailView.save,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.show(data.result.content);
			// 需要去掉的给高度
			crmPopupobj.reduceBodyHeight = 80;
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
			crmPopupobj.center();
		}
	})
}

OrgSharingDetailView.save = function(){
	var data = new FormData(ld(".ajax_form")[0]);
	var popupobj=CrmPopup.getPopupObj("last");
	ld('#rptContentLoading').show();
	ld.ajax({
        type: 'POST',
        dataType: 'json',
        processData: false, // 告诉jquery不要处理数据
        contentType: false, // 告诉jquery不要设置contentType
        data: data,
        url: 'index.php?module=Users&action=UsersAjax&file=SaveOrgSharing',
        success: function(json, textStatus, xhr) {
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
			OrgSharingDetailView.refresh();
			initRightContentHeight();//加载右侧内容中菜单和详细内容高度
        },
        error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
      })
}

OrgSharingDetailView.checkAccessPermission = function(share_value)
{
	var popupobj=CrmPopup.getPopupObj("last");
	var modulelabel_all = ld("#"+popupobj.divid+" [name=allmodulelabel]").val();
	if (share_value == "3")
	{
		var str = arrJsPopLabel['ACCOUNT_ACCESS_INFO'];
		str=str.replace("Mtd",modulelabel_all);
		RemindsMsg("","LdPopWidth400px","","yes","",str);
		document.getElementById('2_perm_combo').options[3].selected=true
		document.getElementById('13_perm_combo').options[3].selected=true
		document.getElementById('20_perm_combo').options[3].selected=true
		document.getElementById('22_perm_combo').options[3].selected=true
		document.getElementById('23_perm_combo').options[3].selected=true

	}
}
//wym XUQIU1001811 显示共享自定义规则
OrgSharingDetailView.showCustomrules = function(obj)
{
	var popupobj=CrmPopup.getPopupObj("last");
	var trobj=Tools.getParentobjByChild(ld(obj),'tr');
	var rowindex = trobj.attr('id').split("_")[1];
	var frommodule = ld(obj).attr('module');
	if(ld(obj).attr('stauts')=='hide'){
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=OrgSharingCustomrulesShow';
		surl += '&tabid='+frommodule;
		ldAjax(surl,'',function(data){
			if(data.code==1){
				trobj.find('td').eq(0).attr('rowspan','2');
				var Customrules_trhtml="<tr id='Customrules_"+rowindex+"'>";
				Customrules_trhtml += "<td colspan='3' class='BorLnone'>";
				Customrules_trhtml += data.result.content;
				Customrules_trhtml += "</td>";
				Customrules_trhtml += "</tr>";
				trobj.after(Customrules_trhtml);
				DelProgressObjs();
				ld(obj).attr('data-tip',arrJsPopLabel['COLLAPSE']);
				ld(obj).attr('stauts','show');
				ld(obj).toggleClass("ld-category-expansion ld-category-collapse");
			}
		});
	}else{
		if(popupobj!=undefined){
			ld("#"+popupobj.divid+ " #Customrules_"+rowindex).remove();
		}else{
			ld("#Customrules_"+rowindex).remove();
		}
		trobj.find('td').eq(0).attr('rowspan','1');
		ld(obj).attr('data-tip',arrJsPopLabel['EXPANSION']);
		ld(obj).attr('stauts','hide');
		ld(obj).toggleClass("ld-category-expansion ld-category-collapse");
	}
}
//wym XUQIU1001811 新增共享自定义规则
OrgSharingDetailView.addCustomrules = function (obj){
	OrgSharingDetailView.editCustomrules(obj,'');
}
//wym XUQIU1001811 编辑共享自定义规则
OrgSharingDetailView.editCustomrules = function (obj,record){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=OrgSharingCustomrules';
	var mode = 'create';
	var frommodule = ld(obj).attr('module');
	if(!empty(record)){
		mode = 'edit';
		surl += '&customrule_id='+record;
	}
	surl += '&mode='+mode;
	surl += '&frommodule='+frommodule;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	crmPopupobj.frommodule=frommodule;
	ldAjaxNoProgress(surl,"",function(data){

		if(data.code==1){
			crmPopupobj.setParams(data.result.title,OrgSharingDetailView.saveCustomrules,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.createScrollDiv();//创建滚动条
			crmPopupobj.show(data.result.content);

			crmPopupobj.showvalues=data.result.showvalues;
			crmPopupobj.viewnamelabel=data.result.viewnamelabel;
			crmPopupobj.modulelabel=data.result.modulelabel;
			crmPopupobj.datetimestr=data.result.datetimestr;//基本查询

			var advancefilterobj = new cls_advanceFilter();
			var params = {};
			params.columnOptionHtml = data.result.columns_block;
			params.fLabels = data.result.flabels;
			params.datetimestr = data.result.datetimestr;
			params.advfilterhtml = data.result.foption;
			params.criteria_groups_arr = data.result.criteria_groups;
			params.module = 'Settings';
			params.source = 'SharingCustomRules';
			// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
			params.advanceFields = data.result.advanceFields;
			advancefilterobj.showAdvanceFilter(crmPopupobj,params);

			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
			crmPopupobj.center();
		}else{
			crmPopupobj.CancelEvent();
			DelProgressObjs();
			RemindsMsg("","LdPopWidth400px",'',"yes","",data.result.msg);
			return false;
		}
	})
}
//wym XUQIU1001811 保存自定义共享规则
OrgSharingDetailView.saveCustomrules = function (){
	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj.advanceFilterObj.checkAdvancedFilter()==false) {
		return false;
	}
	var frommodule = popupobj.frommodule;

	var groupid = ld("#"+popupobj.divid+" [name=groupid]").val();	//部门id
	var userid = ld("#"+popupobj.divid+" [name=userid]").val();	//用户id
	var user_role = ld("#"+popupobj.divid+" [name=user_role]").val();	//角色id
	var customrule_id = ld("#"+popupobj.divid+" [name=customrule_id]").val();	//规则id
	if(empty(groupid)&&empty(userid)&&empty(user_role)){
		var confirm_str = arrJsPopLabel['CUSTOMSHARESELECTATLEASTONETIP'];
		ld("#"+popupobj.divid+" groupid").focus();
		RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
		return false;
	}
	var permission = ld("#"+popupobj.divid+" [name=sharecustomrule_permission]:checked").val();	//共享权限
	var advft_criteria = popupobj.advanceFilterObj.advft_criteria; //共享条件
	var advft_criteria_groups = popupobj.advanceFilterObj.advft_criteria_groups;

	var urlstring = 'index.php?module=Settings&action=SettingsAjax&mode=save&file=OrgSharingCustomrulesSave&frommodule='+frommodule;
	var formdata= {};
	formdata['customruleid']=customrule_id;
	formdata['groupid']=groupid;
	formdata['userid']=userid;
	formdata['user_role']=user_role;
	formdata['permission']=permission;
	formdata['advft_criteria']=advft_criteria;
	formdata['advft_criteria_groups']=advft_criteria_groups;
	ldAjax(urlstring,formdata,function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			OrgSharingDetailView.refreshCustomrules(frommodule);
			DelProgressObjs();
		}
	});
	return false;
}
//wym XUQIU1001811 删除自定义共享规则
OrgSharingDetailView.deleteCustomrules = function (obj){
	var customrule_id = ld(obj).attr('record');
	var frommodule = ld(obj).attr('module');
	var confirm_str = arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK'];
	RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
	//确认事件
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=OrgSharingCustomrulesShow&ajax=true&frommodule='+frommodule+'&mode=delete&customrule_id='+customrule_id;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				OrgSharingDetailView.refreshCustomrules(frommodule);
			}
			DelProgressObjs();
		})
	});
}
//wym XUQIU1001811 刷新自定义共享规则
OrgSharingDetailView.refreshCustomrules = function(tabid){
	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj!=undefined){
		var tableobj=ld("#"+popupobj.divid+ " #Customrules_table_"+tabid);
	}
	else{
		var tableobj=ld("#Customrules_table_"+tabid);
	}
	var trobj=Tools.getParentobjByChild(tableobj,'tr');
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=OrgSharingCustomrulesShow&ajax=true&tabid='+tabid;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			var Customrules_trhtml = "<td colspan='3' class='BorLnone'>";
			Customrules_trhtml += data.result.content;
			Customrules_trhtml += "</td>";
			trobj.html(Customrules_trhtml);
		}
		DelProgressObjs();
	})
}