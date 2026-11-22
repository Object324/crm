ld(function () {
	MobileMenuList = {};
	MobileMenuList.set_Mobile_Menu_Click = function(){
		ld("#mobile_menu_create").on('click',function(){
			// 20240122 弹出层改为crmpoup弹出层
			var modulename = ld('#modulename').val();
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",modulename,"",'none',"","");
			crmPopupobj.prevshow();
			ldAjax('index.php?module=Settings&action=SettingsAjax&file=MobileMenuList_opertion&type=mobile_Menu_create&ajax=true&frommodule='+modulename,'',function (data) {
				if(data.code == 1){
					crmPopupobj.setParams(data.result.title,MobileMenuList.set_Save_Mobile_Menu,"","LdPopWidth600px",modulename,"",data.result.oktext,"",data.result.canceltext);
					crmPopupobj.module=modulename;
					crmPopupobj.mode='add';
					crmPopupobj.show(data.result.content);
					crmPopupobj.center();
					MobileMenuList.set_PopBtn_Click(crmPopupobj);
					// 设置内容最大高度
					crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
				}
			})
		});
		//wym 240123 BUG20240123-33 kfbcrm-后台设置-移动端模块列表定制-切换模块，没反应
		ld('#modulename').on('change',function(){
			var modulename = ld('#modulename').val();
			ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMenuList&type=select_mobile_module&ajax=true&frommodule='+modulename)
				.done(function(response){
					document.getElementById('cfList').innerHTML = response;
				})
		})
	}
	//新增编辑弹出框按钮点击事件
	MobileMenuList.set_PopBtn_Click = function(popupobj){
		ld("#"+popupobj.divid).find("#presence").on('click',function(){
			var isforsearch_obj = ld("#"+popupobj.divid).find("#isforsearch");
			if(ld(this).is(':checked')){
				isforsearch_obj.prop('checked',true);
				isforsearch_obj.prop('disabled',false);
				
			}else{
				isforsearch_obj.prop('checked',false);
				isforsearch_obj.prop('disabled',true);
		   	}
		});
	}
	MobileMenuList.set_Save_Mobile_Menu = function(){
		//保存
			var linenumber = ld('#linenumber').val();	//所在行
			var rownumber = ld('#rownumber').val();		//所在列
			var columnname = ld('#columnname').val();	//字段名称
			var frommodule = ld('#frommodule').val();
			var menu_id = ld('#menu_id').val();
			//字段名称不能为空
			if(empty(columnname)){
				var mes = ld('#columnname').attr('tag');
				var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
			var presence = ld("input[id='presence']").prop('checked')?0:1;
            var showtag = ld("input[id='showtag']").prop('checked')?'yes':'no';
            var isforsearch = ld("input[id='isforsearch']").prop('checked')?'yes':'no';
			ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMenuList&type=save_mobile_menu&ajax=true&linenumber='+linenumber+'&rownumber='+rownumber+'&columnname='+columnname+'&presence='+presence+'&showtag='+showtag+'&isforsearch='+isforsearch+'&frommodule='+frommodule+'&menu_id='+menu_id)
			.done(function(response){
				if(response.indexOf('error1') > -1){
					var confirm_str = arrJsPopLabel['linenumber']+linenumber+'，'+arrJsPopLabel['rownumber']+rownumber+arrJsPopLabel['existingfield']+'，'+arrJsPopLabel['pleasereset']+'！';
					MessagePopup.TipOne_warning(confirm_str);
					return false;
				}else if(response.indexOf('error2') > -1){
					var confirm_str = arrJsPopLabel['youdonotallowallfields']+'，'+arrJsPopLabel['pleasereset']+'！';
					MessagePopup.TipOne_warning(confirm_str);
					return false;
				}else if(response.indexOf('error3') > -1){
				    var confirm_str = arrJsPopLabel['SAVEFIALFORMORECOLUMNS'];
					MessagePopup.TipOne_warning(confirm_str);
					return false;
				}else if(response.indexOf('error4') > -1){
				    var confirm_str = arrJsPopLabel['SetLeastOneFieldQuerying'];
					MessagePopup.TipOne_warning(confirm_str);
					return false;
				}else {
					var crmPopupobj=CrmPopup.getPopupObj('last');
					crmPopupobj.CancelEvent();
					document.getElementById('cfList').innerHTML = response;
				}
			})

	}
	MobileMenuList.set_Mobile_Menu_Click();


});

function fun_mobile_menu(){
	fun_mobile_menu.cur_obj=null;
}

fun_mobile_menu.getInstance=function(menu_id){
    if(fun_mobile_menu.cur_obj==null){
        fun_mobile_menu.cur_obj=new fun_mobile_menu();
    }
	fun_mobile_menu.mobile_menu_id = menu_id;
    return fun_mobile_menu.cur_obj;
}
//启用
fun_mobile_menu.prototype.MobileMenu_activate = function(){
	var frommodule = ld('#modulename').val();
	if(!empty(fun_mobile_menu.mobile_menu_id)){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMenuList&type=Activate&ajax=true&menu_id='+fun_mobile_menu.mobile_menu_id+'&frommodule='+frommodule)
		.done(function(response){
			 document.getElementById('cfList').innerHTML = response;
		})
	}
}
//停用
fun_mobile_menu.prototype.MobileMenu_inactivate = function(){
	var frommodule = ld('#modulename').val();
	if(!empty(fun_mobile_menu.mobile_menu_id)){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMenuList&type=Inactivate&ajax=true&menu_id='+fun_mobile_menu.mobile_menu_id+'&frommodule='+frommodule)
		.done(function(response){
			 if(response.indexOf('error2') > -1){
				var confirm_str = arrJsPopLabel['youdonotallowallfields']+','+arrJsPopLabel['pleasereset']+'!';
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			 }else{
				document.getElementById('cfList').innerHTML = response;
			 }
		})
	}
}
//删除
fun_mobile_menu.prototype.MobileMenu_delete = function(){
	var frommodule = ld('#modulename').val();
	var str = arrJsPopLabel['SUREWANTDELETE'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",str);

	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMenuList&type=deletemenu&ajax=true&menu_id='+fun_mobile_menu.mobile_menu_id+'&frommodule='+frommodule)
		.done(function(response){
			if(response.indexOf('error2') > -1){
				var confirm_str = arrJsPopLabel['youdonotallowallfields']+','+arrJsPopLabel['pleasereset']+'!';
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			 }else{
				document.getElementById('cfList').innerHTML = response;
			 }
		})
	});
}
//编辑
fun_mobile_menu.prototype.MobileMenu_edit = function(){
	var frommodule = ld('#modulename').val();
		var modulename = ld('#modulename').val();

		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",modulename,"",'none',"","");
		crmPopupobj.prevshow();

		ldAjax('index.php?module=Settings&action=SettingsAjax&file=MobileMenuList_opertion&type=mobile_menu_edit&ajax=true&menu_id='+fun_mobile_menu.mobile_menu_id+'&frommodule='+frommodule,'',function (data) {
			if(data.code == 1){
				crmPopupobj.setParams(data.result.title,MobileMenuList.set_Save_Mobile_Menu,"","LdPopWidth600px",modulename,"",data.result.oktext,"",data.result.canceltext);
				crmPopupobj.module=modulename;
				crmPopupobj.mode='add';
				crmPopupobj.show(data.result.content);
				crmPopupobj.center();
				// 设置内容最大高度
				crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
			}
		})

	// ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMenuList_opertion&type=mobile_menu_edit&ajax=true&menu_id='+fun_mobile_menu.mobile_menu_id+'&frommodule='+frommodule)
	// .done(function(response){
	// 	//alert(response);
	// 	$('menu_create_div').innerHTML=response;
	// 	fnvshobj(this, 'menu_create');
	// 	//设置新增区块的按钮事件
	// 	MobileMenuList.set_Save_Mobile_Menu();
	// 	MobileMenuList.set_PopBtn_Click($('menu_create_div'));
	// })
}

