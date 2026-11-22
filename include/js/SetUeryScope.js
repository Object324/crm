
var isSelect=true;
function change(){
     isSelect=true; 
}
 /**
 * @edit:andrew
 * @date:2015-6-17
 * @reason:6.01
 * @description:用户设置模块授权范围选择层
 */
function ShowSetUeryScops(userid){
	if(ld('#ListViewContents tr').hasClass('selectedbj')){
        ld('#ListViewContents tr').removeClass('selectedbj');
    }
	//设置当前字段所在为黄色
   	// ld('input[name=userlistview'+userid+']').parent().parent().addClass('selectedbj');
    // alert('module=Users&action=UsersAjax&file=SetUeryScopePopup&ajax=true&type=UserModuleSet&uid='+userid);
    if(userid=='-1')
        userid = ld('#ODuplicateID').val();
    else if(userid=='undefined'||userid==undefined)
        userid='-1';
	
	ldAjax('index.php','module=Users&action=UsersAjax&file=SetUeryScopePopup&ajax=true&type=UserModuleSet&uid='+userid,function (data) {
		if (data.code == 1){
			// console.log(data);
			DelProgressObjs();
			var width=CrmPopup.getClientWidth()*0.85;
			var html = '<div id="ShowSetUeryScopdiv">'+data.result.content+'</div>';
			var uidparamobj=''
			if (!empty(data.result.UID)){
				uidparamobj = [data.result.UID];
			}
			var popupobj = CrmPopup.load(data.result.title,saveScopePopup,'',width,'Users',uidparamobj,data.result.oktext,'',data.result.canceltext);
			popupobj.show(html);
			// 帮助
			if(data.result.helpHtml && data.result.helpHtml!=""){
				ld('#'+popupobj.divid + " #" + popupobj.divid + '_head').find('.E_ptita').after(data.result.helpHtml);
			}
			var divobj = ld('#'+popupobj.divid);
			var height = CrmPopup.getClientHeight() - ld('#'+popupobj.divid+'_head').outerHeight() - ld('#'+popupobj.divid+'_popupbottom').outerHeight();
			divobj.find('#uery_content').css('height',height+'px');
			divobj.find('#clearBothlabel').css('width',width+'px');
			divobj.find('#clearBothlabel_top').css('width',width+'px');
			popupobj.center();

			//zkt 20221012 BUG0057380设置成员权限，图中红色框选择/取消，保存后就会自动清空，但是蓝色框中的就会一直存在，即使这一列中有不符合的条件
			//获取对应权限设置，反写全部框
			var modulelist = divobj.find('#modulelistvar').val();
			var modulelistarr = modulelist.split(",");
			var type_arr = ['viewothers','viewcreateme','editothers','editcreateme','delothers','viewselfbills'];
			for(var i=0;i<type_arr.length;i++){
				var allstatuschange = 'yes';
				var type = type_arr[i];
				ld.each(divobj.find("[name$='_"+type+"']"),function(){
					if(ld(this).prop('checked')==false&&ld(this).css('display')!='none'){
						allstatuschange='no';
						return false;
					}
				})
				if(allstatuschange == 'yes'){
					divobj.find("[name="+type+"]").prop("checked",true);
				}
			}
		}
	});
}
var selectUserCallBack={ //打印模板分配按钮下的按部门方式时。
    
    callback:null
}
//保存设置
function saveScopePopup(uid){
	var popupobj = CrmPopup.getPopupObj('last');
    //复制
	if(ld('#ODuplicateID').val()!=''&&ld('#ODuplicateID').val()!='undefined'&&ld('#ODuplicateID').val()!=undefined){
		uid='-1';
	}
    
    if(user_pagetype=="list")
    {
        uid=ld("#allselectedboxes").val();
    }
    var moduleRecord = '';
    var modueltype = '';
    var url='module=Users&action=UsersAjax&file=SaveScope&ajax=true&uid='+uid;
	//用户所有模块业务单据授权范围
	var modulelist = ld('#modulelistvar').val();
	var modulelistarr = modulelist.split(",");
	//模块业务单据类型，数组结构：module,type
	var moduleRecordtemp = new Array();
	//模块业务单据类型值,数组结构：module,1,2,3,4,5
	var modueltypetemp = new Array();
    var viewothers='{';
    var editothers='{';
    var delothers='{';
    var viewselfbills='{';
    var viewcreateme='{';
    var editcreateme='{';
	for(var i=0;i<modulelistarr.length;i++){
		//alert( modulelistarr[i]+','+ld("input[name='"+modulelistarr[i]+"']:checked").val() +'----'+modulelistarr[i]+','+ld('#'+modulelistarr[i]+'_scopeid').val());
		modueltypetemp[i] = modulelistarr[i]+','+ld("input[name='"+modulelistarr[i]+"']:checked").val();
		moduleRecordtemp[i] = modulelistarr[i]+','+ld('#'+modulelistarr[i]+'_scopeid').val();
        if(ld("[name="+modulelistarr[i]+"_viewothers]").prop("checked"))
            viewothers+='"'+modulelistarr[i]+'":1,';
        else
           viewothers+='"'+modulelistarr[i]+'":0,';
        if(ld("[name="+modulelistarr[i]+"_viewcreateme]").prop("checked"))
            viewcreateme+='"'+modulelistarr[i]+'":1,';
        else
           viewcreateme+='"'+modulelistarr[i]+'":0,';
        if(ld("[name="+modulelistarr[i]+"_editothers]").prop("checked"))
            editothers+='"'+modulelistarr[i]+'":1,';
        else
           editothers+='"'+modulelistarr[i]+'":0,';
        if(ld("[name="+modulelistarr[i]+"_editcreateme]").prop("checked"))
            editcreateme+='"'+modulelistarr[i]+'":1,';
        else
           editcreateme+='"'+modulelistarr[i]+'":0,';
        if(ld("[name="+modulelistarr[i]+"_delothers]").prop("checked"))
            delothers+='"'+modulelistarr[i]+'":1,';
        else
           delothers+='"'+modulelistarr[i]+'":0,';
        if(ld("[name="+modulelistarr[i]+"_viewselfbills]").prop("checked"))
            viewselfbills+='"'+modulelistarr[i]+'":1,';
        else
           viewselfbills+='"'+modulelistarr[i]+'":0,'; 
	}
    viewothers=viewothers.substr(0,viewothers.length-1);
    viewothers+="}";
    viewcreateme=viewcreateme.substr(0,viewcreateme.length-1);
    viewcreateme+="}";
    editothers=editothers.substr(0,editothers.length-1);
    editothers+="}";
    editcreateme=editcreateme.substr(0,editcreateme.length-1);
    editcreateme+="}";
    
    delothers=delothers.substr(0,delothers.length-1);
    delothers+="}";
    viewselfbills=viewselfbills.substr(0,viewselfbills.length-1);
    viewselfbills+="}";
	moduleRecord = JSON.stringify(moduleRecordtemp);
	modueltype = JSON.stringify(modueltypetemp);
    url+='&moduleRecord='+moduleRecord+'&modueltype='+modueltype+"&viewothers="+viewothers+"&editothers="+editothers;
    url+="&delothers="+delothers+"&viewselfbills="+viewselfbills+"&viewcreateme="+viewcreateme+"&editcreateme="+editcreateme;
    
    
    if(ld('input[type=radio][name=all_Scope]:checked').length>0){
	   url += '&all_scope='+ld('#all_scope').val() + '&all_scopeid='+ ld('#all_scopeid').val();
    }
	//alert(url);
    //return false;
	if(uid=='-1'){
	   //新增用户界面
        ld('#moduleRecord').val(moduleRecord);
        ld('#modueltype').val(modueltype);
        ld("#viewothers").val(viewothers);
        ld("#editothers").val(editothers);
        ld("#delothers").val(delothers);
        ld("#viewselfbills").val(viewselfbills);
        ld("#viewcreateme").val(viewcreateme);
        ld("#editcreateme").val(editcreateme);
		popupobj.CancelEvent();
    }else{
        //zkt 20230411 BUG0064610 kfbcrm 成员管理---新增保存不生效 
        url += "&SaveScopeajaxsave=yes";
            ldAjax('index.php?',url,function(data) {
                DelProgressObjs();
                if(data.code == 1){
					popupobj.CancelEvent();
        			 if(user_pagetype=='list')
                     {
							 $("allselectedboxes").value = "";
                             var pagenum=ld("#ListViewContents [name=pagenum]").val();
                             getListViewEntries_js('Users','parenttab=Tools&start='+pagenum);
                     }
                     //详情页设置数据范围，增加详情页面刷新
                     else if(user_pagetype == 'edit_detail'){
                        var poupobj = CrmPopup.getPopupObj('last');
                        if(poupobj.type=='detailviewpage'&&poupobj.module=='Users'){
                            var tmparra = new Array();
                            tmparra.push(popupobj.record);
                            var refreshdetailmodules = new Array();
                            refreshdetailmodules.push(popupobj.module);
                            var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, data, tmparra);
                            tmpobj.eachrefreshDetailViewByModules(refreshdetailmodules);
                        }
                     }
                    
                }
    	   });
    }


}
/**
 * 用户模块 - 选择业务单据授权范围
 * @param 2016-10-17
 * @returns  选择模块
 * @author Chj 
 */
function changeScopeFormAll(obj,userid){
	var modulelist = ld('#modulelistvar').val();
	var modulelistarr = modulelist.split(",");
	var viewName = obj.value;
	scopeview = ld('#all_scope').val();

	//Liver 20170112,bug0026784: 用户管理列表界面：业务单据授权范围弹出层，模块下拉框点空白处第2次弹出使用范围弹出层
	if(viewName==''||viewName=='underfind'){
		return false;
	}
	if((viewName=='0'||viewName=='1')){
		var confirm_str = arrJsPopLabel['WUATSOTMCTC'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		//点击确认
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			ld('#all_scopeid').val('');
			ld('#all_scope').val(viewName);
	        for(var i=0;i<modulelistarr.length;i++){
				if(ld('#'+modulelistarr[i]) != undefined){
					ld("input[name="+modulelistarr[i]+"][value="+viewName+"]").prop("checked",true);  
					//ld('#'+modulelistarr[i]).val(viewName);
					ld('#'+modulelistarr[i]+'_scopeid').val('');
					ld('#'+modulelistarr[i]+'_scope').val(viewName);
				}
			}
			scopeview=viewName;
		});
		//wyt 220930 BUG0057323 如附件视频，点击“全部”的时候，在弹出框里点击取消，此时圆点不会回到“自己的”，而是依旧停留在“全部”
		ld('input[tagclick="msgConfirmCancel"]').unbind('click').on('click',function(){
			if(scopeview!=viewName){
				ld("input[type=radio][name=all_Scope][value="+viewName+"]").prop("checked",false);
				ld("input[type=radio][name=all_Scope][value="+scopeview+"]").prop("checked",true);
			}
		});
	}else{
		var scopepopupobj;
		var popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];
		var popup_url;
		if(viewName == 2){
			popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module=Users&popup_inputtype=checkbox&popup_selecttype=user';
		}else{
			popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_scopetype=private&popup_module=Users&popup_inputtype=checkbox&popup_selecttype=group';
		}
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			scopepopupobj =  new ScopePopupObj('Users');
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			   cls_ScopePopup.prop.popup_module = 'Users';//模块
			   cls_ScopePopup.prop.popup_value = ld('#all_scopeid').val();
			   if(obj.value == 2){
					cls_ScopePopup.prop.disabled_value = userid;
			   }
			   //wyt 221008 BUG0057243 图中，搜索框提示文字应该改为“请输入要查找的部门”
			   if(obj.value == 3){
				   scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'></div>';
			   }
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);

				ld('#'+cls_ScopePopup.popup_divid).css('z-index','10099');
				ld("#layer").css("z-index","9999");
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						//没有选择，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							if(obj.value == 2){
								var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
								RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
								return false;
							}else{
								var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
								RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
								return false;
							}
						}else{
							//将更新所有模块的设置，是否继续？
							var confirm_str = arrJsPopLabel['WUATSOTMCTC'];
							RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							//点击确认
							ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
								scopeview=viewName;
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
								var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
								ld('#all_scopeid').val(selected_user);
								ld('#all_scope').val(viewName);

								for(var i=0;i<modulelistarr.length;i++){
									if(ld('#'+modulelistarr[i]) != undefined){
										ld("input[name="+modulelistarr[i]+"][value="+viewName+"]").prop("checked",true);  
										ld('#'+modulelistarr[i]+'_scopeid').val(selected_user);
										ld('#'+modulelistarr[i]+'_scope').val(viewName);
									}
								}
								// ld("input[name=all_Scope][value="+scopeview+"]").prop("checked",true);
							});
						}
						ld("#layer").css("z-index","9998");
					});
				}
				scopepopupobj.setEventBtnCancel=function(){

					 //关闭事件
					ld('#'+cls_ScopePopup.popup_divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
						ld("#layer").css("z-index","9998");
						return false;
					});
					//取消事件
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').trigger('closediv');
						ld("#layer").css("z-index","9998");

						//wyt 220929 BUG0057221 在成员管理，数据范围，点击所有模块的按成员，点击之后取消，也能保存
						if(scopeview!=viewName){
							ld("input[type=radio][name=all_Scope][value="+obj.value+"]").prop("checked",false);
							//防止报错
							if(scopeview != ''){
								ld("input[type=radio][name=all_Scope][value="+scopeview+"]").prop("checked",true);
							}
						}
					});
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){
						// obj.value = '';
						ld("#layer").css("z-index","9998");
						// if(ld('#'+cls_ScopePopup.popup_divid).length > 0){
						// 	//删除div
						// 	var divobj = ld('#'+cls_ScopePopup.popup_divid).get(0);
						// 	divobj.parentNode.removeChild(divobj);
						// }
					});
					return true;
				}
			});
		});
	}
}
/**
 * 用户模块 - 选择业务单据授权范围
 * @param 2016-10-17
 * @returns  选择单个模块
 * @author Chj 
 */
//获取选择之前的授权范围类型
var scopeview;
function changeScopeForm(obj,modulename,userid){
    
	//已选id
	var scopeviewid = ld('#'+modulename+'_scopeid').val();
	//获取选择之前的授权范围类型
	scopeview = ld('#'+modulename+'_scope').val();
	//用户、部门切换到个人或者普通时，再次打开弹出层，因为没有刷新页，所以scopeid值还会存在
	if(scopeview ==0 || scopeview == 1){
		ld('#'+modulename+'_scopeid').val('');
	}
	//选择用户、部门
	if(obj.value == 2 || obj.value == 3){
		//自定义弹出层页面html，绑定事件
		var scopepopupobj;
		var popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];
		var popup_value;
		//默认选中值
		if(scopeview == obj.value){
			popup_value = scopeviewid;
		}
		var popup_url;
        var popup_module=modulename;
        if(modulename=='UnAssignedAccounts')
        {
            popup_module='Accounts';
        }
		if(obj.value == 2){
			popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+popup_module+'&popup_inputtype=checkbox&popup_selecttype=user';
		}else{
			popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_scopetype=private&popup_module='+popup_module+'&popup_inputtype=checkbox&popup_selecttype=group';
		}
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			scopepopupobj =  new ScopePopupObj('Users');
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			if(obj.value == 3){
				scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'></div>';
			}
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			   cls_ScopePopup.prop.popup_module = 'Users';//模块
			   cls_ScopePopup.prop.popup_value = popup_value;
			   if(obj.value == 2){
					cls_ScopePopup.prop.disabled_value = userid;
			   }
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				ld('#'+cls_ScopePopup.popup_divid).css('z-index','10099');
			   scopepopupobj.setEventLoad=function(){
					if(obj.value == 2){
						var popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
					}else{
						var popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
					}
					 //查询选择:进入焦点时触发
					//ld('#popup_locationdiv').unbind('focus').on('focus',function(){
						cls_ScopePopups.searchTextFocus('popup_locationdiv',popup_searchvalue);
					//});
					//查询选择:失去焦点时触发
					//ld('#popup_locationdiv').unbind('blur').on('blur',function(){
					//	cls_ScopePopups.searchTextBlur('popup_locationdiv',popup_searchvalue);
					//});
			   }
               //edit:hzx 系统设置→成员管理 编辑成员数据范围设置，按成员或按部门设置范围的时候，没有遮罩层
			   ld("#layer").css("z-index","9999");
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						//没有选择，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							if(obj.value == 2){
								var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
								RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
								return false;
							}else{
								var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
								RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
								return false;
							}
						}else{
						  
							var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
							ld('#'+modulename+'_scopeid').val(selected_user);
							ld('#'+modulename+'_scope').val(obj.value);
							scopeview = obj.value;
                            //全选勾选状态修改
                            var all_scopeview = ld('#all_scope').val();
                            if(scopeview != all_scopeview){
								if(all_scopeview != undefined && all_scopeview != ''){
                                	ld('input[type=radio][name=all_Scope][value="'+all_scopeview+'"]').attr('checked',false);
								}
                                ld('#all_scope').val('');
                                ld('#all_scopeid').val('');
                            }
                            cls_ScopePopup.popupobj.CancelEvent();
							//ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
						}
                        //edit:hzx 系统设置→成员管理 编辑成员数据范围设置，按成员或按部门设置范围的时候，没有遮罩层
                        ld("#layer").css("z-index","9998");
					});
                    
				}
				scopepopupobj.setEventBtnCancel=function(){
					 //关闭事件
					ld('#'+cls_ScopePopup.popup_divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                        //edit:hzx 系统设置→成员管理 编辑成员数据范围设置，按成员或按部门设置范围的时候，没有遮罩层
                        ld("#layer").css("z-index","9998");
						return false;
					});
					//取消事件
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').trigger('closediv');
                        //edit:hzx 系统设置→成员管理 编辑成员数据范围设置，按成员或按部门设置范围的时候，没有遮罩层
                        ld("#layer").css("z-index","9998");
						//wyt 220929 BUG0057221 在成员管理，数据范围，点击所有模块的按成员，点击之后取消，也能保存
						if(scopeview !=obj.value){
							if(scopeview == '')scopeview = 0;
							ld("input[type=radio][name="+modulename+"][value="+obj.value+"]").prop("checked",false);
							ld("input[type=radio][name="+modulename+"][value="+scopeview+"]").prop("checked",true);
						}
					});
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){
						if(ld('#'+modulename+'_scope').val() != obj.value){
							if(scopeview == '')scopeview = 0;
							ld("input[type=radio][name="+modulename+"][value="+scopeview+"]").attr("checked",true);  
						}
						// if(ld('#'+cls_ScopePopup.popup_divid).length > 0){
						// 	//删除div
						// 	var divobj = ld('#'+cls_ScopePopup.popup_divid).get(0);
						// 	divobj.parentNode.removeChild(divobj);
						// }
					});
					return true;
				}
			});
		});
	}else{
		//个人、全部
		ld('#'+modulename+'_scopeid').val('');
		ld('#'+modulename+'_scope').val(obj.value);
        //全选勾选状态修改
        var all_scopeview = ld('#all_scope').val();
        if(scopeview != all_scopeview){
            ld('input[type=radio][name=all_Scope][value="'+all_scopeview+'"]').attr('checked',false);
            ld('#all_scope').val('');
            ld('#all_scopeid').val('');
        }
	}
    
}

function changeUserScopeOperation(obj,type)
{
    var confirm_str = arrJsPopLabel['WUATSOTMCTC'];
	MessagePopup.TipTwo_warning(confirm_str);
	var msgpopupobj = CrmPopup.getPopupObj('last');
	//点击确认
	ld("#" + msgpopupobj.divid).find("input[tagclick='msgConfirm']").off("click").on("click", function () {
		var modulelist = ld('#modulelistvar').val();
		var modulelistarr = modulelist.split(",");
		for(var i=0;i<modulelistarr.length;i++)
		{
			// alert("[name="+modulelistarr[i]+"_"+type+"]");
			ld("[name="+modulelistarr[i]+"_"+type+"]").prop("checked",obj.checked);

		}
	});
	//点击取消
	ld("#" + msgpopupobj.divid).find("input[tagclick='msgConfirmCancel']").off('click').on('click',function(){
		ld(obj).prop("checked",!obj.checked);
	});
}

function changeUserScopeOperation_module(obj,type)
{
    var allstatuschange = 'no';
    var modulelist = ld('#modulelistvar').val();
	var modulelistarr = modulelist.split(",");
    for(var i=0;i<modulelistarr.length;i++)
    {
        if(ld("[name="+modulelistarr[i]+"_"+type+"]").prop("checked") != obj.checked&&ld(this).css('display')!='none'){
            allstatuschange = 'yes';
        }
	}
    if(allstatuschange == 'yes'){
        ld("[name="+type+"]").prop("checked",obj.checked);
    }
}