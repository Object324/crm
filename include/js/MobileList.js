ld(function () {
	MobileList = {};
	MobileList.set_Mobile_Block_Click = function(){
		ld("#mobile_block_create").on('click',function(){
			//editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/8 11:37 ID1000638
			var setting_position = ld('#setting_position').val();
			if(setting_position==='report'){
				var surl = 'module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=mobile_block_create&ajax=true';
			}else{
                var surl = 'module=Settings&action=SettingsAjax&file=MobileList_opertion&type=mobile_block_create&ajax=true';
            }
			var popupobj=CrmPopup.getPopupObj("last");
			var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
			crmPopupobj.prevshow();
			ld.ajax({
				url: 'index.php?'+surl,
				type: 'POST',
				data:'',
				dataType:'json',
				async: true,//
				timeout: 5000,
				success: function(data)
				{
					
					if(data.code==1)
					{
						//approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
						//EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
						crmPopupobj.setParams(data.result.title,set_Save_Mobile_Block,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
						//crmPopupobj.show(data.result.content);
						CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
						// 设置内容最大高度
						crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
						/*
						edit:weiyannan
						date:2023-11-14
						renson:XUQIU1002049 系统穿梭框界面样式统一 移动端功能菜单定制&移动端报表菜单定制
						*/
						var tableobj = ld('#'+crmPopupobj.divid).find("table#assignPicklistTable");
						var LeftObj = tableobj.find(" .commonMultipleSelect:first");
						var RightObj = tableobj.find(" .commonMultipleSelect:last");
						//传入翻译参数
						var Drag_Transfer = new DragTransfer();
						var translabel = {
							available: arrJsPopLabel['OptionModules'],
							selected: arrJsPopLabel['Selectedmodule'],
							placeholder: arrJsPopLabel['PleaseEnterColumnSearchFor'],
						};
						Drag_Transfer.SetTranslabel(translabel);
						Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','210');
						crmPopupobj.center();
					}
				}
			})
		});
		//绑定点击菜单排序按钮
        //2023427 fengxh BUG0065618 弹出框可拖动修改
		ld("#mobile_block_sort").on('click',function(){
            var setting_position = ld('#setting_position').val();
            if(setting_position==='report'){
                var mobile_block_sortUrl = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=mobile_block_sort&ajax=true';
            }else{
                var mobile_block_sortUrl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList_opertion&type=mobile_block_sort&ajax=true';
            }
			ldAjax(mobile_block_sortUrl,'',function(response){
				var crmpopuObj = CrmPopup.load("","","","LdPopWidth300px",'Settings',"","","","");
				crmpopuObj.prevshow();
				crmpopuObj.setting_position = setting_position;
				crmpopuObj.setParams(response.result.title,MobileList.SaveSortBlock,"","LdPopWidth300px",'Settings',"",response.result.oktext,"",response.result.canceltext);
				CrmPopup.setPopupobjHtmlContent_scroll(crmpopuObj,response.result.content);//后端传递数据到前端接收
				//MobileList.set_Sort_Mobile_Block(setting_position);
			})
		});
	}
   //2023427 fengxh BUG0065618 直写保存的方法，取消动态绑定
	MobileList.SaveSortBlock = function(){
		var popuobj = CrmPopup.getPopupObj('last');
		rPosition = popuobj.setting_position;
		//菜单排序的保存
		var tabids = ld("#selectedColumns2 option").map(function(){return ld(this).val();}).get().join(",");
		if(rPosition === 'report'){
			var SaveMobileBlockSortUrl = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=SaveMobileBlockSort&ajax=true&tabids='+tabids;
		}else{
			var SaveMobileBlockSortUrl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=SaveMobileBlockSort&ajax=true&tabids='+tabids;
		}
		ld.ajax(SaveMobileBlockSortUrl).done(function(response){
			popuobj.CancelEvent();
			document.getElementById('cfList').innerHTML = response;
		})
		
	}
	MobileList.set_Save_Mobile_Block = function(blockid,rPosition){
		//保存
		ld("#save_mobile_block").on('click',function(){
			var mobileblock_name = ld('#mobileblock_name').val();
			//区块名称不能为空
			if(empty(mobileblock_name)){
				var mes = ld('#mobileblock_name').attr('tag');
				var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
            if(ld('#mobileblock_name_en').length>0){
                var mobileblock_name_en = ld('#mobileblock_name_en').val();
    			//英文不能为空
    			if(empty(mobileblock_name_en)){
    				var mes = ld('#mobileblock_name_en').attr('tag');
    				var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
    				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    				return false;
    			}
            }
            
            
			//editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/8 11:13 ID1000638
			//区块名称不能重复
			if(rPosition==='report'){
                var checkblocknameUrl = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=checkblockname&ajax=true&mobileblock_name='+mobileblock_name+'&blockid='+blockid;
			}else{
                var checkblocknameUrl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=checkblockname&ajax=true&mobileblock_name='+mobileblock_name+'&blockid='+blockid;
			}
			ld.ajax(checkblocknameUrl)
			.done(function(response){
				if(response.indexOf('error') > -1){
					var mes = ld('#mobileblock_name').attr('tag');
					var confirm_str = mes+arrJsPopLabel['ALREADYEXISTSREENTRY'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}else{
					//显示的模块不能为空
					var tabids = ld("#selectedtabColumns option").map(function(){return ld(this).val();}).get().join(",");
					if(empty(tabids)){
						var mes = ld('#selectedtabColumns').attr('tag');
						var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						return false;
					}
					var presence = ld("input[id='mobileblock_presence']:checked").val();
                    var customscope_type=ld("#customscope_type").val();
                    var customscope_ids=ld("#customscope_ids").val();
                    if(rPosition==='report'){
                        var SaveMobileBlockUrl = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=SaveMobileBlock&ajax=true&mobileblock_name='+mobileblock_name+'&mobileblock_name_en='+mobileblock_name_en+'&tabids='+tabids+'&presence='+presence+'&blockid='+blockid+"&customscope_type="+customscope_type+"&customscope_ids="+customscope_ids;
                    }else{
                        var SaveMobileBlockUrl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=SaveMobileBlock&ajax=true&mobileblock_name='+mobileblock_name+'&mobileblock_name_en='+mobileblock_name_en+'&tabids='+tabids+'&presence='+presence+'&blockid='+blockid+"&customscope_type="+customscope_type+"&customscope_ids="+customscope_ids;
                    }
					ld.ajax(SaveMobileBlockUrl)
					.done(function(response){
						fninvshnew('block_create');
						document.getElementById('cfList').innerHTML = response;
					})
				}
			})
		})
		//取消
		ld("#cancel_mobile_block,#close_mobile_block").on('click',function(){
			fninvshnew('block_create');
		})
	}
	MobileList.set_Sort_Mobile_Block = function(rPosition){
		//区块排序保存
		ld("#save_mobile_block_sort").on('click',function(){
			var tabids = ld("#selectedColumns2 option").map(function(){return ld(this).val();}).get().join(",");
			if(rPosition === 'report'){
				var SaveMobileBlockSortUrl = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=SaveMobileBlockSort&ajax=true&tabids='+tabids;
			}else{
                var SaveMobileBlockSortUrl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=SaveMobileBlockSort&ajax=true&tabids='+tabids;
            }
			ld.ajax(SaveMobileBlockSortUrl).done(function(response){
				fninvshnew('block_sort');
				document.getElementById('cfList').innerHTML = response;
			})
		})
		//取消
		ld("#cancel_mobile_block_sort,#colse_mobile_block_sort").on('click',function(){
			fninvshnew('block_sort');
		})
	}
	MobileList.set_Mobile_Block_Click();
});

var set_Save_Mobile_Block = function(){
	//保存
	var blockid = ld('#blockid').val();
	var popupobj=CrmPopup.getPopupObj("last");
	var menudescription = ld("#"+popupobj.divid).find("#menudescription").val();
	var mobileblock_name = ld('#mobileblock_name').val();
	var rPosition = '';
	//模块描述去除两端空格
	menudescription = menudescription.trim();
	if(ld('#setting_position').val() != undefined){
		rPosition = ld('#setting_position').val();
	}
	//中文名称不能为空
	if(empty(mobileblock_name)){
		var mes = ld('#mobileblock_name').attr('tag');
		var confirm_str = mes+arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    //英文名称不能为空
    var mobileblock_name_en = ld('#mobileblock_name_en').val();
	if(empty(mobileblock_name_en)){
		var mes = ld('#mobileblock_name_en').attr('tag');
		var confirm_str = mes+arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	//editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/8 11:13 ID1000638
	//区块名称不能重复
	if(rPosition==='report'){
		var checkblocknameUrl = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=checkblockname&ajax=true&mobileblock_name='+mobileblock_name+'&mobileblock_name_en='+mobileblock_name_en+'&blockid='+blockid;
	}else{
		var checkblocknameUrl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=checkblockname&ajax=true&mobileblock_name='+mobileblock_name+'&mobileblock_name_en='+mobileblock_name_en+'&blockid='+blockid;
	}
	ld.ajax(checkblocknameUrl)
	.done(function(response){
		if(response.indexOf('error') > -1){
			var mes = ld('#mobileblock_name').attr('tag');
			var confirm_str = mes+arrJsPopLabel['ALREADYEXISTSREENTRY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}else if(response.indexOf('enrepeat') > -1){
			var mes = ld('#mobileblock_name_en').attr('tag');
			var confirm_str = mes+arrJsPopLabel['ALREADYEXISTSREENTRY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}else{
			//显示的模块不能为空
			var tabids = ld("#selectedtabColumns option").map(function(){return ld(this).val();}).get().join(",");
			if(empty(tabids)){
				var mes = ld('#selectedtabColumns').attr('tag');
				var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			var presence = ld("input[id='mobileblock_presence']").prop('checked')?0:1;
			var customscope_type=ld("#customscope_type").val();
			var customscope_ids=ld("#customscope_ids").val();
			if(rPosition==='report'){
				var SaveMobileBlockUrl = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=SaveMobileBlock&ajax=true';
				var param = {'mobileblock_name':mobileblock_name,'mobileblock_name_en':mobileblock_name_en,'tabids':tabids,'presence':presence,'blockid':blockid,'customscope_type':customscope_type,'customscope_ids':customscope_ids,'menudescription':menudescription};
			}else{
				var SaveMobileBlockUrl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=SaveMobileBlock&ajax=true';
				var param = {'mobileblock_name':mobileblock_name,'mobileblock_name_en':mobileblock_name_en,'tabids':tabids,'presence':presence,'blockid':blockid,'customscope_type':customscope_type,'customscope_ids':customscope_ids,'menudescription':menudescription};
			}
			ldAjaxHtml(SaveMobileBlockUrl,param,function(rest){
				CrmPopup.getPopupObj("last").CancelEvent();
				ld('#rptContentLoading').hide();
				//zxm 20240911
				if(ld('#prm_report_name_str').length>0&&rPosition==='report'){
					ld('#prm_report_name_str').html(rest);
				}else if(ld('#prm_module_name_str').length>0&&rPosition!='report'){
					ld('#prm_module_name_str').html(rest);
				}else{
					document.getElementById('cfList').innerHTML = rest;
				}
				MobileListDragSort();
				tooltip('.sort-tip-items', {transition: true, time: 200});
				DelProgressObjs();
			})
			return true;
		}
	})
	
}
function fun_mobile_list(){
	fun_mobile_list.cur_obj=null;
}

fun_mobile_list.getInstance=function(block_id){
    if(fun_mobile_list.cur_obj==null){
        fun_mobile_list.cur_obj=new fun_mobile_list();
    }
	fun_mobile_list.mobile_block_id = block_id;
    return fun_mobile_list.cur_obj;
}
//编辑
fun_mobile_list.prototype.MobileBlock_edit = function(){
	ld('#setting_position').val('');
	var surl='module=Settings&action=SettingsAjax&file=MobileList_opertion&type=mobile_block_edit&ajax=true&blockid='+fun_mobile_list.mobile_block_id;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
        success: function(data)
        {
			
            if(data.code==1)
            {
                //approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
                //EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
                crmPopupobj.setParams(data.result.title,set_Save_Mobile_Block,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
                //crmPopupobj.show(data.result.content);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
				// 设置内容最大高度
				crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");

				//设置新增区块的按钮事件
				MobileList.set_Save_Mobile_Block(fun_mobile_list.mobile_block_id,'report');


				/*
				edit:weiyannan
				date:2023-11-14
				renson:XUQIU1002049 系统穿梭框界面样式统一 移动端功能菜单定制&移动端报表菜单定制
				*/
				var tableobj = ld('#'+crmPopupobj.divid).find(" .commonMultipleSelect").parents("table");
				var LeftObj = tableobj.find(" .commonMultipleSelect:first");
				var RightObj = tableobj.find(" .commonMultipleSelect:last");
				//传入翻译参数
				var Drag_Transfer = new DragTransfer();
				var translabel = {
					available: arrJsPopLabel['OptionModules'],
					selected: arrJsPopLabel['Selectedmodule'],
					placeholder: arrJsPopLabel['PleaseEnterColumnSearchFor'],
				};
				Drag_Transfer.SetTranslabel(translabel);
				Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','210');
				crmPopupobj.center();
			}
		}
	})
}
//editor:gyq_159 reason:报表区块列表界面编辑按钮  2019/11/7 19:03 ID1000638
fun_mobile_list.prototype.MobileReportBlockEdit = function(){
	ld('#setting_position').val('report');
	var surl='module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=mobile_block_edit&ajax=true&blockid='+fun_mobile_list.mobile_block_id;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
                crmPopupobj.setParams(data.result.title,set_Save_Mobile_Block,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
				// 设置内容最大高度
				crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
				//设置新增区块的按钮事件
				var tableobj = ld('#'+crmPopupobj.divid).find(" .commonMultipleSelect").parents("table");
				var LeftObj = tableobj.find(" .commonMultipleSelect:first");
				var RightObj = tableobj.find(" .commonMultipleSelect:last");
				//传入翻译参数
				var Drag_Transfer = new DragTransfer();
				var translabel = {
					available: arrJsPopLabel['OptionModules'],
					selected: arrJsPopLabel['Selectedmodule'],
					placeholder: arrJsPopLabel['PleaseEnterColumnSearchFor'],
				};
				Drag_Transfer.SetTranslabel(translabel);
				Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','210');
				crmPopupobj.center();
			}
		}
	})
}
//editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/8 11:12 ID1000638
//删除
fun_mobile_list.prototype.MobileBlock_delete = function(rPosition){
    var str = arrJsPopLabel['SUREWANTDELETETHEDELECTED'] + arrJsPopLabel['blocks'] + '？';
    RemindsMsg("","LdPopWidth400px","","yes","yes",str);
    if(rPosition==='report'){
        var deleteblockUrl = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=deleteblock&ajax=true&block_id='+fun_mobile_list.mobile_block_id;
    }else{
        var deleteblockUrl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=deleteblock&ajax=true&block_id='+fun_mobile_list.mobile_block_id;
    }
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        ld.ajax(deleteblockUrl)
            .done(function(response){
                document.getElementById('cfList').innerHTML = response;
				//wym 240122 BUG20240119-39 移动端报表菜单定制、移动端功能菜单定制--当点击删除按钮后，列表就无法进行拖动排序
				MobileListDragSort();
            })
    });
}
//启用
fun_mobile_list.prototype.MobileBlock_activate = function(){
	if(!empty(fun_mobile_list.mobile_block_id)){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileList&type=Activate&ajax=true&block_id='+fun_mobile_list.mobile_block_id)
		.done(function(response){
			 document.getElementById('cfList').innerHTML = response;
		})
	}
}
//停用
fun_mobile_list.prototype.MobileBlock_inactivate = function(){
	if(!empty(fun_mobile_list.mobile_block_id)){
		ld.ajax('index.php?module=Settings&action=SettingsAjax&file=MobileList&type=Inactivate&ajax=true&block_id='+fun_mobile_list.mobile_block_id)
		.done(function(response){
			 document.getElementById('cfList').innerHTML = response;
		})
	}
}
