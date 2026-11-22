//选择适用范围	module 模块 inputid  scopetype默认选中radio
function scopePopup_Alls(module,inputid,scopetype){
	var scopepopupobj;//自定义弹出层页面html，绑定事件
	if(empty(scopetype)) scopetype = 'user';
	var popup_selecttype = scopetype;	//默认选中
	var popup_selectvalue = '';//默认选中值
	//再次选择，或者编辑
	if(ld('#selectType') != undefined && ld('#selectType').val() != ''){
		popup_selecttype = ld('#selectType').val();
	}
	if(ld('#selectValue') != undefined){
		popup_selectvalue = ld('#selectValue').val();
	}
	var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
	var popup_profile_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=profile';
	var popup_group_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=group';
	var popup_searchTextDiv_html = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 104px;\'><div class=\'view-search\' ></div></div>';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];//标题title
		scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认值
		scopepopupobj.popup_searchTextDiv = popup_searchTextDiv_html;
		scopepopupobj.popup_header = '<div class="select-input"><input id="selectprofileuser1" type="radio" value="profile" name="selectprofileuser"><label for="selectprofileuser1">按角色设置</label><input id="selectprofileuser2" type="radio" value="user" name="selectprofileuser"><label for="selectprofileuser2">按用户设置</label><input id="selectprofileuser" type="radio" value="group" name="selectprofileuser">按部门设置<div><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'></div>';
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = module;//模块
		   cls_ScopePopup.prop.popup_value = popup_selectvalue;
		   if(popup_selecttype == 'group'){
				cls_ScopePopup.prop.popup_url = popup_group_url;
		   }else if(popup_selecttype == 'user'){
				cls_ScopePopup.prop.popup_url = popup_user_url;
		   }else{
				cls_ScopePopup.prop.popup_url = popup_profile_url;
		   }
		   
		   cls_ScopePopup.popup_more_selecttype = popup_selecttype;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		   scopepopupobj.setEventLoad=function(){
				ld('input[name="selectprofileuser"]').unbind('click').on('click',function(){
					if(ld(' input[name="selectprofileuser"]:checked ').val() == 'user'){
						scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认值
						ld('#popup_locationdiv').val(arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']);
						cls_ScopePopups.viewTree(popup_user_url);
						popup_selecttype = 'user';
					}else if(ld(' input[name="selectprofileuser"]:checked ').val() == 'group'){
						scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
						ld('#popup_locationdiv').val(arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']);
						cls_ScopePopups.viewTree(popup_group_url);
						popup_selecttype = 'group';
					}else{
						scopepopupobj.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];//查询框默认值
						ld('#popup_locationdiv').val(arrJsPopLabel['pleaseenterprofile']);
						cls_ScopePopups.viewTree(popup_profile_url);
						popup_selecttype = 'profile';
					}
				});
				scopePopup_All.setRadioBind(popup_selecttype);
		   }
		   //0026474: 快速创建-费率设定：适用范围字段后点击【+】，弹出层显示出错（参考截图）
		   document.getElementById(cls_ScopePopup.popup_divid).style.zIndex="10300";
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					//没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
						if(popup_selecttype == 'group'){
							var confirm_str =arrJsPopLabel['Pleaseselectatleastonedepartment'];
						}
						else if(popup_selecttype == 'user'){
							var confirm_str =arrJsPopLabel['PLEASESELECTLESTONEUSER'];
						}else{
							var confirm_str =arrJsPopLabel['Pleaseselectatleaprofile'];	
						}
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    }else{
                        ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
						var selected_id = cls_ScopePopup.return_obj.return_id;//选中的部门id
						var selected_name = cls_ScopePopup.return_obj.return_name;//选中的部门名称
						var selected_type = cls_ScopePopup.return_obj.return_type;

						if(ld('#'+inputid) != undefined){
							ld('#'+inputid).val(selected_name);
						}
						if(ld('#selectType') != undefined){
							ld('#selectType').val(selected_type);	//group 部门  user 用户 profile 角色
						}
						if(ld('#selectValue') != undefined){
							ld('#selectValue').val(selected_id);
						}
					}
					return false;
                });
            }
		});
	});
}
scopePopup_All.setRadioBind = function(popup_selecttype){
	if(ld('input[name="selectprofileuser"]') != undefined){
		ld('input[name="selectprofileuser"]').each(function(){
			if(ld(this).val() == popup_selecttype){
				ld(this).attr("checked","checked");
				if(popup_selecttype == 'user'){
					ld('#viewuser_nogroupuser').show();
					ld('#viewuser_nogroupuser_span').show();
				}else{
					ld('#viewuser_nogroupuser').hide();
					ld('#viewuser_nogroupuser_span').hide();
				}
			}
		})
	}
}