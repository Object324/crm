ld(function () {
	MobileMainInfo = {};
	MobileMainInfo.set_Mobile_Menu_Click = function(){
		ld("#mobile_maininfo_create").on('click',function(){
		  //zkt 20230425 BUG0065031 后台设置->移动端详情界面定制，选择“自定义表单104”，新建字段提示“最多显示5行数据” 
			if(ld("#cfList" ).find(' td[id^=ispresence_]').find('input[type=checkbox]:checked').length>=5){
				//BUG0063400 zxm 20230322 kfbcrm 移动端详情界面定制----当添加字段已经5行---点击新建按钮，直接弹出下图中的提示信息
				var confirm_str = arrJsPopLabel['MOSTOFFIVELINE']+'！';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			var modulename = ld('#modulename').val();
			//BUG0065612  crmpopup实现弹窗拖拽功能 2023-4-26  徐心玥
			var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", "", "", "", "", "");
            crmPopupobj.prevshow();
            ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo_opertion&type=mobile_Menu_create&ajax=true&frommodule='+modulename, "", function (data) {
                if (data.code == 1) {
                    crmPopupobj.setParams(data.result.title, MobileMainInfo.SaveMobileMainInfo, "", "LdPopWidth600px", "", "", data.result.oktext, "", data.result.canceltext, "");
                    crmPopupobj.show(data.result.content);
					// 设置内容最大高度
					crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                }
            })
		});
		ld('#modulename').on('change',function(){
			var modulename = ld('#modulename').val();
			ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo&type=select_mobile_module&ajax=true&frommodule='+modulename)
			.done(function(response){
				document.getElementById('cfList').innerHTML = response;
				//zxm 20230316
				MobileDetailInfoObj.init();
			})
		})
	}
	MobileMainInfo.set_Save_Mobile_MainInfo = function(){
		//保存
		ld("#save_mobile_maininfo").on('click',function(){
			var linenumber = ld('#linenumber').val();	//所在行
			var fieldname = ld('#fieldname').val();	//字段名称
			var frommodule = ld('#frommodule').val();
			var maininfo_id = ld('#maininfo_id').val();
			//字段名称不能为空
			if(empty(fieldname)){
				var mes = ld('#fieldname').attr('tag');
				var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			var presence = ld("input[id='presence']").prop('checked')?0:1;
            var showtag = ld("input[id='showtag']").prop('checked')?'yes':'no';
			ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo&type=save_mobile_maininfo&ajax=true&linenumber='+linenumber+'&fieldname='+fieldname+'&presence='+presence+'&showtag='+showtag+'&frommodule='+frommodule+'&maininfo_id='+maininfo_id)
			.done(function(response){
			    if(response.indexOf('error1') > -1){
					var confirm_str = arrJsPopLabel['MOSTOFFIVELINE']+'，'+arrJsPopLabel['pleasereset']+'！';
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}else if(response.indexOf('error2') > -1){
					var confirm_str = arrJsPopLabel['youdonotallowallfields']+'，'+arrJsPopLabel['pleasereset']+'！';
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}else {
					fninvshnew('maininfo_create');
					document.getElementById('cfList').innerHTML = response;
				}
			})
		})
		//取消
		ld("#cancel_mobile_maininfo,#colse_mobile_maininfo").on('click',function(){
			fninvshnew('maininfo_create');
		})
	}
	//BUG0065612 使用crmpopup实现弹窗拖拽，可以调用的新保存函数(okfun) 2023-4-26  徐心玥
	MobileMainInfo.SaveMobileMainInfo = function(){
		var popupobj = CrmPopup.getPopupObj('last');
		var linenumber = ld('#linenumber').val();	//所在行
		var fieldname = ld('#fieldname').val();	//字段名称
		var frommodule = ld('#frommodule').val();
		var maininfo_id = ld('#maininfo_id').val();
		//字段名称不能为空
		if(empty(fieldname)){
			var mes = ld('#fieldname').attr('tag');
			var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		var presence = ld("input[id='presence']").prop('checked')?0:1;
		var showtag = ld("input[id='showtag']").prop('checked')?'yes':'no';
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo&type=save_mobile_maininfo&ajax=true&linenumber='+linenumber+'&fieldname='+fieldname+'&presence='+presence+'&showtag='+showtag+'&frommodule='+frommodule+'&maininfo_id='+maininfo_id)
		.done(function(response){
			if(response.indexOf('error1') > -1){
				var confirm_str = arrJsPopLabel['MOSTOFFIVELINE']+'，'+arrJsPopLabel['pleasereset']+'！';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}else if(response.indexOf('error2') > -1){
				var confirm_str = arrJsPopLabel['youdonotallowallfields']+'，'+arrJsPopLabel['pleasereset']+'！';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}else {
				fninvshnew('maininfo_create');
				popupobj.CancelEvent();
				document.getElementById('cfList').innerHTML = response;
				//zxm 20230914 移动端详情界面定制，编辑后点保存没反应，分录明细显示样式编辑保存不生效
				MobileDetailInfoObj.init();
			}
		})
	}
	MobileMainInfo.set_Mobile_Menu_Click();
});

function fun_mobile_maininfo(){
	fun_mobile_maininfo.cur_obj=null;
}

fun_mobile_maininfo.getInstance=function(maininfo_id){
    if(fun_mobile_maininfo.cur_obj==null){
        fun_mobile_maininfo.cur_obj=new fun_mobile_maininfo();
    }
	fun_mobile_maininfo.mobile_maininfo_id = maininfo_id;
    return fun_mobile_maininfo.cur_obj;
}
//启用
fun_mobile_maininfo.prototype.MobileMainInfo_activate = function(){
	var frommodule = ld('#modulename').val();
	if(!empty(fun_mobile_maininfo.mobile_maininfo_id)){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo&type=Activate&ajax=true&maininfo_id='+fun_mobile_maininfo.mobile_maininfo_id+'&frommodule='+frommodule)
		.done(function(response){
		     if(response.indexOf('error1') > -1){
				alert(arrJsPopLabel['MOSTOFFIVELINE']+'，'+arrJsPopLabel['pleasereset']+'！');
				return false;
			 }
			 document.getElementById('cfList').innerHTML = response;
		})
	}
}
//停用
fun_mobile_maininfo.prototype.MobileMainInfo_inactivate = function(){
	var frommodule = ld('#modulename').val();
	if(!empty(fun_mobile_maininfo.mobile_maininfo_id)){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo&type=Inactivate&ajax=true&maininfo_id='+fun_mobile_maininfo.mobile_maininfo_id+'&frommodule='+frommodule)
		.done(function(response){
			 if(response.indexOf('error2') > -1){
				alert(arrJsPopLabel['youdonotallowallfields']+','+arrJsPopLabel['pleasereset']+'!');
				return false;
			 }else{
				document.getElementById('cfList').innerHTML = response;
			 }
		})
	}
}
//删除
fun_mobile_maininfo.prototype.MobileMainInfo_delete = function(){
	var frommodule = ld('#modulename').val();
	var str = arrJsPopLabel['SUREWANTDELETE'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",str);
	//确定按钮
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){		
        ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo&type=deletemaininfo&ajax=true&maininfo_id='+fun_mobile_maininfo.mobile_maininfo_id+'&frommodule='+frommodule)
		.done(function(response){
			if(response.indexOf('error2') > -1){
				var confirm_str = arrJsPopLabel['youdonotallowallfields']+','+arrJsPopLabel['pleasereset']+'!';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			 }else{
				document.getElementById('cfList').innerHTML = response;
			 }
		})
	});
}
//编辑
fun_mobile_maininfo.prototype.MobileMainInfo_edit = function(){
	//BUG0065612  实现弹窗拖拽功能 2023-4-26  徐心玥
	var frommodule = ld('#modulename').val();
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px","","","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo_opertion&type=mobile_maininfo_edit&ajax=true&maininfo_id='+fun_mobile_maininfo.mobile_maininfo_id+'&frommodule='+frommodule,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,MobileMainInfo.SaveMobileMainInfo,"","LdPopWidth600px","","",data.result.oktext,"",data.result.canceltext,"");
            crmPopupobj.show(data.result.content);
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
        }
    })
}

