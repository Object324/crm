function ProfileDetailClick(obj) {
	var popupobj = CrmPopup.getPopupObj("last");
	var crmPopupobj = CrmPopup.load("", "", "", "950", 'Settings', "", "", "", "");
	crmPopupobj.prevshow();
	var profileid = ld(obj).attr("profileid");
	var okfunparamobj = [profileid];
	ldAjaxNoProgress("index.php?module=Settings&action=SettingsAjax&file=profilePrivileges&mode=view&profileid=" + ld(obj).attr("profileid"), {}, function (data) {

		crmPopupobj.setParams(data.result.title, DetailEditProfile, "", "1050", 'Settings', okfunparamobj, data.result.oktext, "", data.result.canceltext);
		CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);

		crmPopupobj.proportion = 1;
		var PopContentHeight = crmPopupobj.getPopContentHeight();
		var Popupobj = ld('#' + crmPopupobj.divid);
		var scrollcontent_height = PopContentHeight - Popupobj.find("#EditProfilePopHead").outerHeight()
													- Popupobj.find("#RolesProfile_ParentTabs").outerHeight(true);
		Popupobj.find("#RolesProfile_MainList").css('height',scrollcontent_height);
	})
}
function DetailEditProfile(profileid) {
	//点击查看界面的编辑按钮
	// CrmPopup.getPopupObj('last').CancelEvent();
	EditProfile(profileid);
}
// //角色权限 - 编辑
// function CreateProfile() {
// 	var surl = 'index.php?module=Settings&action=SettingsAjax&file=profilePrivileges&return_module=Settings&return_action=profilePrivileges&parenttab=Settings&mode=create';
// 	var popupobj = CrmPopup.getPopupObj("last");
// 	var crmPopupobj = CrmPopup.load("", "", "", "1050", 'Settings', "", "", "", "");
// 	crmPopupobj.prevshow();
// 	ldAjaxNoProgress(surl, "", function (data) {
// 		if (data.code == 1) {
// 			crmPopupobj.setParams(data.result.title, SaveProfile, "", "1050", 'Settings', "", data.result.oktext, "", data.result.canceltext);
// 			//zkt 【角色权限，操作权限增加“全选”功能】--底部栏事件重写
// 			//createBottomHtml
// 			crmPopupobj.createTextBeforeSave = function () {

// 				var popupbottomhtml = '<div ><div style="margin-left: -15px;display: inline-block;float: left;">';
// 				popupbottomhtml += '<input type="checkbox" onclick="hideTabAll();" id="all_tab" name="all_tab" style="margin-top: -2px;"> ' + arrJsPopLabel['ALLSELECT'];
// 				popupbottomhtml += '</div><div style="display: inline-block;"><span>&nbsp;&nbsp;' + arrJsPopLabel['SELECTTHESELECTEDPERMISSIONS'] + '</span>';
// 				popupbottomhtml += '<div style="display: inline-block;">';
// 				popupbottomhtml += data.result.profileactionhtml;
// 				popupbottomhtml += '</div><div class="select-input" style="display: inline-block;">';
// 				popupbottomhtml += '<input type="radio" onclick="hideAllTabProfile(\'open\');" name="all_tabprofile">';
// 				popupbottomhtml += '<label class="padR10">' + arrJsPopLabel['OPENMODULE'] + '</label>&nbsp;';
// 				popupbottomhtml += '<input type="radio" onclick="hideAllTabProfile(\'close\');"  name="all_tabprofile">';
// 				popupbottomhtml += '<label class="padR10">' + arrJsPopLabel['CLOSE'] + '</label></div>';
// 				popupbottomhtml += '</div></div>';
// 				return popupbottomhtml;
// 			}
// 			CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj, data.result.content);
// 			//zkt 【角色权限，操作权限增加“全选”功能】--下拉框样式修改
// 			var cls_resetComboxHtmlobj = new cls_resetComboxHtml('profileaction');
// 			cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(120);
// 			ld('#' + crmPopupobj.divid + ' div[name="dv_chzn_profileaction"]').css('margin-top', '1px');
// 		}
// 	})
// }
//角色权限 - 编辑
function EditProfile(profileid) {
	var popupobj = CrmPopup.getPopupObj("last");
	var parenttabid = ld('#moduleoption').data('parenttabid');
	if (popupobj!=undefined && popupobj!='undefined') {
		popupobj.CancelEvent();
	}
	
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=profilePrivileges&return_module=Settings&return_action=profilePrivileges&parenttab=Settings&mode=edit&profileid=' + profileid;
	var crmPopupobj = CrmPopup.load("", "", "", "1050", 'Settings', "", "", "", "");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl, "", function (data) {
		if (data.code == 1) {
			//edit:can 2020724 42095: (61mis.com/kfbcrm)成员管理>序时簿界面：角色权限列点击“销售人员”，点击“编辑”按钮，“销售线索”点击全选没反应
			crmPopupobj.setParams(data.result.title, ajaxSaveProfile, "", "1050", 'Settings', "", data.result.oktext, "", data.result.canceltext);
			//zkt 【角色权限，操作权限增加“全选”功能】--底部栏事件重写
			crmPopupobj.createTextBeforeSave = function () {

				var popupbottomhtml = '<div ><div style="margin-left: -15px;display: inline-block;float: left;">';
				popupbottomhtml += '<input type="checkbox" onclick="hideTabAll();" id="all_tab" name="all_tab" style="margin-top: -2px;"> ' + arrJsPopLabel['ALLSELECT'];
				popupbottomhtml += '</div><div style="display: inline-block;"><span>&nbsp;&nbsp;' + arrJsPopLabel['SELECTTHESELECTEDPERMISSIONS'] + '</span>';
				popupbottomhtml += '<div style="display: inline-block;">';
				popupbottomhtml += data.result.profileactionhtml;
				popupbottomhtml += '</div><div class="select-input" style="display: inline-block;">';
				popupbottomhtml += '<input type="radio" onclick="hideAllTabProfile(\'open\');" name="all_tabprofile">';
				popupbottomhtml += '<label class="padR10">' + arrJsPopLabel['OPENMODULE'] + '</label>&nbsp;';
				popupbottomhtml += '<input type="radio" onclick="hideAllTabProfile(\'close\');"  name="all_tabprofile">';
				popupbottomhtml += '<label class="padR10">' + arrJsPopLabel['CLOSE'] + '</label></div>';
				popupbottomhtml += '</div></div>';
				return popupbottomhtml;
			}
			CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj, data.result.content);
			//zkt 【角色权限，操作权限增加“全选”功能】--下拉框样式修改
			var cls_resetComboxHtmlobj = new cls_resetComboxHtml('profileaction');
			cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(120);
			ld('#' + crmPopupobj.divid + ' div[name="dv_chzn_profileaction"]').css('margin-top', '1px');

			crmPopupobj.proportion = 1;
			var PopContentHeight = crmPopupobj.getPopContentHeight();
			var Popupobj = ld('#' + crmPopupobj.divid);
			var scrollcontent_height = PopContentHeight - Popupobj.find("#EditProfilePopHead").outerHeight()
														- Popupobj.find("#RolesProfile_ParentTabs").outerHeight(true);
			Popupobj.find("#RolesProfile_MainList").css('height',scrollcontent_height);
			
			//BUG20240717-23 ls 240722 编辑权限页面记住详情页选择的权限分类
			if(!empty(parenttabid)){
			    clickshowMenuProfile(parenttabid);
			}
		}
	})
}
//zkt 【角色权限，操作权限增加“全选”功能】--角色权限设置展开关闭区块
function showHideMenuProfile(parenttabid, parentname) {
	var spanobj = ld('#moduleoption span[id="parenttab_' + parenttabid + '"]');
	var trobjs = ld('#moduleoption tr[tag="parenttab_' + parenttabid + '"]');
	var showstatus = ld(spanobj).attr('tag');
	if (showstatus == 'show') {//On
		ld(spanobj).attr('class', 'On');
		ld.each(trobjs, function () {
			ld(this).css('display', 'none');
		})
		ld(spanobj).attr('tag', 'hidden');
	}
	else if (showstatus == 'hidden') {
		ld(spanobj).removeClass();
		ld.each(trobjs, function () {
			ld(this).css('display', '');
		})
		ld(spanobj).attr('tag', 'show');
	}
}
//hzx 【点击模块显示对应模块区块内容】--角色权限设置展开关闭区块
function clickshowMenuProfile(parenttabid) {
	var spanobj = ld('#moduleoption span[sontag="parenttab_' + parenttabid + '"]');
	var showstatus = ld(spanobj).attr('toptag');
	if (showstatus == 'hidden') {
		var showspanobj = ld('#moduleoption span[toptag=show]');
		if (parenttabid == 'all') {
			ld.each(ld('#moduleoption tr[tag^=parenttab_'), function () {
				ld(this).css('display', '');
			});
			ld.each(ld('#moduleoption tr[tag^=activeparenttab_'), function () {
				ld(this).css('display', 'none');
			});
		} else {
			if (showspanobj.attr('sontag') == 'parenttab_all') {
				ld.each(ld('#moduleoption tr[tag^=parenttab_'), function () {
					ld(this).css('display', 'none');
				});
				ld.each(ld('#moduleoption tr[tag^=activeparenttab_'), function () {
					ld(this).css('display', 'none');
				});
			} else {
				ld.each(ld('#moduleoption tr[tag="' + showspanobj.attr('sontag') + '"]'), function () {
					ld(this).css('display', 'none');
				});
				ld.each(ld('#moduleoption tr[tag="active' + showspanobj.attr('sontag') + '"]'), function () {
					ld(this).css('display', 'none');
				});
			}
			var trobjs = ld('#moduleoption tr[tag="parenttab_' + parenttabid + '"]');
			ld.each(trobjs, function () {
				ld(this).css('display', '');
			});
			var trheadobjs = ld('#moduleoption tr[tag="activeparenttab_' + parenttabid + '"]');
			ld.each(trheadobjs, function () {
				ld(this).css('display', '');
			});
		}
		ld('#moduleoption div[class="menustandarddiv menustandarddivactive"]').removeClass('menustandarddivactive');
		ld('#moduleoption div[name="div_parenttab_' + parenttabid + '"]').addClass('menustandarddivactive');
		ld(showspanobj).attr('toptag', 'hidden');
		ld(spanobj).attr('toptag', 'show');
	}
	if (ld('#moduleoption tr[style=""] input[type="checkbox"]:not(:checked)').length > 0) {
		ld('#all_tab').prop('checked', false);
	} else {
		ld('#all_tab').prop('checked', true);
	}

	ld("#moduleoption").data('parenttabid',parenttabid);
}
//zkt 【角色权限，操作权限增加“全选”功能】--操作权限开启关闭
function hideAllTabProfile(operation) {
	var popupobj = CrmPopup.getPopupObj("last");
	var selectobj = ld("#" + popupobj.divid + " select[name=profileaction]").get(0);
	var index = selectobj.options.selectedIndex;//获取当前选择项的索引.
	var selectval = selectobj.options[index].value;//获取当前选择项的值.
	//hzx 批量授权只勾选当前页面显示的勾选框
	if (operation == 'open') {
		if (ld('#moduleoption tr[style=""] input[id^="tab_chk_' + selectval + '_"]').length > 0) {
			var selectobjs = ld('#moduleoption tr[style=""] input[id^="tab_chk_' + selectval + '_"]');
			ld.each(selectobjs, function () {
				if (ld(this).prop('checked') == false) {
					ld(this).click();
				}

			})
		}
		if (ld('#moduleoption tr[style="display:;"] input[id^="tab_chk_' + selectval + '_"]').length > 0) {
			var selectobjs = ld('#moduleoption tr[style="display:;"] input[id^="tab_chk_' + selectval + '_"]');
			ld.each(selectobjs, function () {
				if (ld(this).prop('checked') == false) {
					ld(this).click();
				}

			})
		}
	}
	else if (operation == 'close') {
		if (ld('#moduleoption tr[style=""] input[id^="tab_chk_' + selectval + '_"]').length > 0) {
			var selectobjs = ld('#moduleoption tr[style=""] input[id^="tab_chk_' + selectval + '_"]');
			ld.each(selectobjs, function () {
				if (ld(this).prop('checked') == true) {
					ld(this).click();
				}

			})
		}
		if (ld('#moduleoption tr[style="display:;"] input[id^="tab_chk_' + selectval + '_"]').length > 0) {
			var selectobjs = ld('#moduleoption tr[style="display:;"] input[id^="tab_chk_' + selectval + '_"]');
			ld.each(selectobjs, function () {
				if (ld(this).prop('checked') == true) {
					ld(this).click();
				}

			})
		}
	}
}
// //角色权限 - 复制
// function CopyProfile(profileid) {
// 	var surl = 'index.php?module=Settings&action=SettingsAjax&file=profilePrivileges&return_module=Settings&return_action=profilePrivileges&parenttab=Settings&mode=edit&profileid=' + profileid + "&copyRole=copyRole";
// 	var popupobj = CrmPopup.getPopupObj("last");
// 	var crmPopupobj = CrmPopup.load("", "", "", "1050", 'Settings', "", "", "", "");
// 	crmPopupobj.prevshow();
// 	ldAjaxNoProgress(surl, "", function (data) {
// 		if (data.code == 1) {
// 			crmPopupobj.setParams(data.result.title, SaveProfile, "", "1050", 'Settings', "", data.result.oktext, "", data.result.canceltext);
// 			//zkt 【角色权限，操作权限增加“全选”功能】--底部栏事件重写
// 			crmPopupobj.createBottomHtml = function () {
// 				var ok_class = '';
// 				this.popupbottomhtml = '<div class="E_pbtn" id="' + this.divid + '_popupbottom"> ';
// 				this.popupbottomhtml += '<div ><div style="margin-left: -15px;display: inline-block;float: left;">';
// 				this.popupbottomhtml += '<input type="checkbox" onclick="hideTabAll();" id="all_tab" name="all_tab" style="margin-top: -2px;"> ' + arrJsPopLabel['ALLSELECT'];
// 				this.popupbottomhtml += '</div><div style="display: inline-block;"><span>&nbsp;&nbsp;' + arrJsPopLabel['SELECTTHESELECTEDPERMISSIONS'] + '</span>';
// 				this.popupbottomhtml += '<div style="display: inline-block;">';
// 				this.popupbottomhtml += data.result.profileactionhtml;
// 				this.popupbottomhtml += '</div><div class="select-input" style="display: inline-block;">';
// 				this.popupbottomhtml += '<input type="radio" onclick="hideAllTabProfile(\'open\');" name="all_tabprofile">';
// 				this.popupbottomhtml += '<label class="padR10">' + arrJsPopLabel['OPENMODULE'] + '</label>&nbsp;';
// 				this.popupbottomhtml += '<input type="radio" onclick="hideAllTabProfile(\'close\');"  name="all_tabprofile">';
// 				this.popupbottomhtml += '<label class="padR10">' + arrJsPopLabel['CLOSE'] + '</label></div>';
// 				this.popupbottomhtml += '</div></div>';

// 				var funname = this.Okfun.funname;
// 				if (funname == undefined) {
// 					funname = this.Okfun.name;
// 				}
// 				this.popupbottomhtml += this.createTextBeforeSave();
// 				this.popupbottomhtml += ' <input name="button" id="' + this.divid + '_btnok" class="E_pbtnok ld-button ld-button-primary' + ok_class + '" value="' + this.OkText + '" tagClick="' + funname + '"  type="button">';
// 				this.popupbottomhtml += '<span>&nbsp;</span><input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="' + this.CancelText + '" id="' + this.divid + '_btncancel" type="button">'

// 				this.popupbottomhtml += ' </div>';
// 				this.btnokid = this.divid + "_btnok";
// 				this.btncancelid = this.divid + "_btncancel";
// 			}
// 			//edit:can 2020724 42095: (61mis.com/kfbcrm)成员管理>序时簿界面：角色权限列点击“销售人员”，点击“编辑”按钮，“销售线索”点击全选没反应
// 			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);
// 			//zkt 【角色权限，操作权限增加“全选”功能】--下拉框样式修改
// 			var cls_resetComboxHtmlobj = new cls_resetComboxHtml('profileaction');
// 			cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(120);
// 			ld('#' + crmPopupobj.divid + ' div[name="dv_chzn_profileaction"]').css('margin-top', '1px');

// 		}
// 	})
// }

//角色权限保存
function SaveProfile() {
	var profilename = $('profilename').value;
	var firstpopupobj = CrmPopup.getPopupObj('first');

	profilename = trim(profilename);
	if (profilename != '') {
		return Privilege_validation(profilename);
	}
	else {
		var confirm_str = arrJsPopLabel['PRIVILEGECANOTEMPTY'];
		RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
		//puyoungJS_DialogBox.unblock();
		$('profilename').focus();
		return false
	}
}
SaveProfile.funname = 'SaveProfile';
//角色权限 - 字段权限
function EditProfileField(profileid, tabid, obj, divid) {
	var clsRolesProfileObj = new cls_RolesProfile();
	clsRolesProfileObj.EditProfileField(profileid, tabid);
}

function toogleAccess(elementId) {
	var element = document.getElementById(elementId);
	if (element == null || typeof (element) == 'undefined') return;

	if (element.value == 0) {
		element.value = 1;
	} else {
		element.value = 0;
	}

	var lockedImage = document.getElementById(elementId + '_locked');
	if (lockedImage != null && typeof (lockedImage) != 'undefined') {
		if (lockedImage.style.display == 'none')
			lockedImage.style.display = 'inline';
		else
			lockedImage.style.display = 'none';
	}

	var unlockedImage = document.getElementById(elementId + '_unlocked');
	if (unlockedImage != null && typeof (unlockedImage) != 'undefined') {
		if (unlockedImage.style.display == 'none')
			unlockedImage.style.display = 'inline';
		else
			unlockedImage.style.display = 'none';
	}
}
function hideTabAll() {
	if ($('all_tab').checked == true)
	//hzx 【全选只选中当前页面显示的所有勾选框】
	{
		ld('#moduleoption tr[style=""] input[type="checkbox"]').prop('checked', true);
		ld('#moduleoption tr[style="display:;"] input[type="checkbox"]').prop('checked', true);
		//全选时设置推进按钮和批量下载按钮可用
		ld('#moduleoption input[id*="tab_chk_49"]').prop('disabled', false);
	}
	else {
		ld('#moduleoption tr[style=""] input[type="checkbox"]').prop('checked', false);
		ld('#moduleoption tr[style="display:;"] input[type="checkbox"]').prop('checked', false);
		//全选时设置推进按钮和批量下载按钮不可用
		ld('#moduleoption input[id*="tab_chk_49"]').prop('disabled', true);
	}

}

function Privilege_validation(profilename) {
	var ModeType = 'module=Users&action=UsersAjax&file=CreateProfile&ajax=true&dup_check=true&profile_name=' + profilename
		+ "&profileid=" + document.getElementById("profileid").value
		+ "&description=" + document.getElementById("description").value;
	new Ajax.Request(
		'index.php',
		{
			queue: { position: 'end', scope: 'command' },
			method: 'post',
			postBody: ModeType,
			onComplete: function (response) {
				if (response.responseText.indexOf('SUCCESS') > -1) {
					ajaxSaveProfile('create');
				}
				else {
					//puyoungJS_DialogBox.unblock();
					RemindsMsg("", "LdPopWidth400px", "", "yes", "", response.responseText);
					$('profilename').focus();
				}
			}
		}
	);
}

function ajaxSaveProfile(mode) {
	var firstpopupobj = CrmPopup.getPopupObj('lastprev');
	var firstmodule = firstpopupobj.module;
	// @edit:dong @date:2020/09/18 @reason: 权限名称要求必填的
	var popupObj = CrmPopup.getPopupObj('last');
	var profilename = ld('#' + popupObj.divid + " [name=profilename]").val();
	if (profilename == '' || profilename == undefined) {
		RemindsMsg("", "LdPopWidth400px", "", "yes", "", arrJsPopLabel['profilenamenonull']);
		return false;
	}
	if (mode == '') {
		mode = 'edit';
	}
	if (mode == 'edit')
		var surl = "index.php?module=Users&action=UsersAjax&file=UpdateProfileChanges&parenttab=Settings&mode=&profileid=" + ld('#profileid').val();
	else {
		var copyRoleId = ld('#' + popupObj.divid + " [name=copyRoleId]").val() || '';
		var surl = "index.php?module=Users&action=UsersAjax&file=SaveProfile&parenttab=Settings&copyRoleId="+copyRoleId;
	}
	surl += '&profilename=' + encodeURIComponent(ld('#profilename').val());
	surl += '&description=' + encodeURIComponent(ld('#description').val());
	var paramsurl = '';
	ld.each(ld("[tag=module_tabid]"), function () {
		if (ld(this).is(':checked') == true) {
			paramsurl += '&' + ld(this).attr('name') + '=on';
		} else {
			paramsurl += '&' + ld(this).attr('name') + '=';
		}

	})
	ld.each(ld("[tag=module_actionname]"), function () {
		if (ld(this).is(':checked') == true) {
			paramsurl += '&' + ld(this).attr('name') + '=on';
		} else {
			paramsurl += '&' + ld(this).attr('name') + '=';
		}

	})
	ldAjax(surl, paramsurl, function (data) {
		if (data.code == 1) {
			var popupobj = CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			if (firstmodule == 'Users') {
				ld("#" + firstpopupobj.divid + " [profileid=" + data.result.profileid + "]").text(data.result.profilename);
				popupobj = CrmPopup.getPopupObj("last");

				if (typeof DetailViewPagePopup != "undefined" && popupobj.type == DetailViewPagePopup.type) {
					ld("#" + popupobj.divid + " [profileid=" + data.result.profileid + "]").text(data.result.profilename);
				}
			}
			else {
				//刷新列表
				var surl = "index.php?module=Settings&action=SettingsAjax&file=listroles";
				ldAjaxNoProgress(surl, "", function (data) {
					if (data.code == 1) {
						listcontentobj.html(data.result.content);
						// listcontentobj.clsRolesProfileObj.init(data.result);
					}
				})

			}
		}
		DelProgressObjs();
	})

}
ajaxSaveProfile.funname = 'ajaxSaveProfile';
// 角色权限 - 删除
function deleteRole(obj, profileid) {
	var surl = "index.php?module=Settings&action=SettingsAjax&file=RoleDeleteStep1&profileid="+profileid+"&parenttab=Settings&DelRole=DelRole";
	var popupobj = CrmPopup.getPopupObj("last");
	var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", 'Settings', "", "", "", "");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl, "", function (data) {
		if (data.code == 1) {
			crmPopupobj.setParams(data.result.title, roleDeleteValidate, "", "LdPopWidth600px", 'Settings', "", data.result.oktext, "", data.result.canceltext);
			crmPopupobj.show(data.result.content);
		}
	})

}

// 角色权限 - 删除
function roleDeleteValidate() {
	var surl = "index.php?module=Users&action=UsersAjax&file=DeleteProfile";
	var popupobj = CrmPopup.getPopupObj("last");
	var delete_role_id = ld("#" + popupobj.divid + " [name=delete_role_id]").val();
	var profileid = ld("#" + popupobj.divid + " [name=profileid]").val();
	surl += "&delete_role_id=" + delete_role_id;
	surl += "&profileid=" + profileid;
	//alert(surl);
	ldAjax(surl, "", function (data) {
		if (data.code == 1) {
			var popupobj = CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=Settings&action=SettingsAjax&file=listroles";
			ldAjaxNoProgress(surl, "", function (data) {
				if (data.code == 1) {
					listcontentobj.html(data.result.content);
					listcontentobj.clsRolesProfileObj.init(data.result);
				}
			})
		}
		DelProgressObjs();
	})
}


// //角色权限-拖拽
// function profileMovetable() {
// 	var dragobj = ld("table[name=rolePermissionTable]").find("tbody").get(0);
// 	ld('[name=rolePermissionTable] tr').hover(function() {
// 		ld('.ld-dragicon').hide();
// 		ld(this).find('.ld-dragicon').show();
// 	});
	
// 	Sortable.create(dragobj, {
// 		// group: 'SelfServiceConfig',
// 		// animation: 150,
// 		draggable: ".ld-category-draggable",
// 		handle: ".drag-handle",
// 		onEnd: function (evt){
// 			var sortfield_arr='', fieldid;
// 			tableobj = ld('table[name=rolePermissionTable]').find("tr");
// 			tableobj.attr('onmouseover','');
// 			tableobj.attr('onmouseout','');
// 			tableobj.removeClass('lvtColData');
// 			tableobj.removeClass('lvtColDataBj');
// 			tableobj.removeClass('lvtColDataHover');
// 			ld.each(tableobj,function(index,tmpobj){
// 				if(index>0){
// 					if(index%2==0){
// 						ld(tmpobj).addClass('lvtColDataBj');
// 						ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
// 						ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
// 						ld(tmpobj.childNodes[0]).html(index);
// 						fieldid=ld(tmpobj).attr('profileid');
// 						sortfield_arr+=fieldid+",";
// 					}else{
// 						ld(tmpobj).addClass('lvtColData');
// 						ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
// 						ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
// 						ld(tmpobj.childNodes[0]).html(index);
// 						fieldid=ld(tmpobj).attr('profileid');
// 						sortfield_arr+=fieldid+",";
// 					}
// 				}
// 			});
// 			if (sortfield_arr != '') {

// 				var update_url='index.php?module=Users&action=UsersAjax&file=MoveProfile&type=saveRolePremissionSort&ajax=true&profileids='+sortfield_arr;
// 				ldAjax(update_url, '', function (data) {
// 					if (data.code == 1) {
// 						DelProgressObjs();
// 					}
// 				})
// 			}
// 		}
// 	})
// }


function fnToggleVIew(obj) {
	if ($(obj).hasClassName('hideTable')) {
		$(obj).removeClassName('hideTable');
	} else {
		$(obj).addClassName('hideTable');
	}
}
function invokeview_all() {
	if ($('view_all_chk').checked == true) {
		for (var i = 0; i < document.profileform.elements.length; i++) {
			if (document.profileform.elements[i].type == 'checkbox') {
				if (document.profileform.elements[i].id.indexOf('tab_chk_com_') != -1 || document.profileform.elements[i].id.indexOf('tab_chk_4') != -1 || document.profileform.elements[i].id.indexOf('_field_') != -1)
					document.profileform.elements[i].checked = true;
			}
		}
		showAllImages();
	}
}
function showAllImages() {
	for (var j = 0; j < Imagid_array.length; j++) {

		if (typeof ($(Imagid_array[j])) != 'undefined')
			$(Imagid_array[j]).style.display = 'block';
	}
}
function invokeedit_all() {
	if ($('edit_all_chk').checked == true) {
		$('view_all_chk').checked = true;
		for (var i = 0; i < document.profileform.elements.length; i++) {
			if (document.profileform.elements[i].type == 'checkbox') {
				if (document.profileform.elements[i].id.indexOf('tab_chk_com_') != -1 || document.profileform.elements[i].id.indexOf('tab_chk_4') != -1 || document.profileform.elements[i].id.indexOf('tab_chk_1') != -1 || document.profileform.elements[i].id.indexOf('_field_') != -1)
					if (document.profileform.elements[i].id.indexOf('tab_chk_11_') == -1)
						document.profileform.elements[i].checked = true;
			}
		}
		showAllImages();
	}

}
function unselectmodule(tabid, name) {
	if (tabid == oftenusereporttabid) {

		if (ld(" [name=oftenusereport_" + name + "]").prop("checked")) {

			ld("#tab_chk_com_" + tabid).prop("checked", true);
		}
		else {
			var tmp_reportnames = reportnames.split(",");
			for (var i = 0; i < tmp_reportnames.length; i++) {
				var name = tmp_reportnames[i];
				if (ld(" [name=oftenusereport_" + name + "]").prop("checked")) {
					return;
				}
			}
			ld("#tab_chk_com_" + tabid).prop("checked", false);
		}

	}
	else if (tabid == -2) {
		//移动端报表
		if (ld(" [name=mobilereport_" + name + "]").prop("checked")) {

			ld("#tab_chk_com_" + tabid).prop("checked", true);
		}
		else {
			var tmp_reportnames = mobilereportnames.split(",");
			for (var i = 0; i < tmp_reportnames.length; i++) {
				var name = tmp_reportnames[i];
				if (ld(" [name=mobilereport_" + name + "]").prop("checked")) {
					return;
				}
			}
			ld("#tab_chk_com_" + tabid).prop("checked", false);
		}
	}
}
function unSelectOthers(id, actionid) {
	var tab_id = 'tab_chk_com_' + id;
	if ($('tab_chk_' + actionid + '_' + id).checked == false) {

	}
	else {
		var viewid = 'tab_chk_4_' + id;
		if ($(viewid) != undefined) {
			$(viewid).checked = true;
		}
		$(tab_id).checked = true;
		if (actionid == 8) {
			var viewid = 'tab_chk_10_' + id;
			$(viewid).checked = true;
			$(tab_id).checked = true;
		}
		//1000066  评论功能优化（界面显示和评论内容，回复）--添加回复权限
		else if (actionid == 53) {
			var viewid = 'tab_chk_11_' + id;
			$(viewid).checked = true;
			$('tab_chk_11_' + id).checked = true;
		}
	}
}
function unSelectView(id) {
	var createid = 'tab_chk_11_' + id;
	var editid = 'tab_chk_1_' + id;
	var deleteid = 'tab_chk_2_' + id;
	var tab_id = 'tab_chk_com_' + id;
	if ($('tab_chk_4_' + id).checked == false) {


		$(tab_id).checked = false;
		var maxActionId = ld("[name = maxActionId]").val();
		for (var i = 1; i < maxActionId + 1; i++) {
			if ($('tab_chk_' + i + '_' + id) != undefined) {
				$('tab_chk_' + i + '_' + id).checked = false;
				if (i == 49) {
					ld($('tab_chk_' + i + '_' + id)).attr('disabled', true);
				}
			}
		}


	} else {
		$('tab_chk_com_' + id).checked = true;
	}
}
function unSelectCopy(id) {
	var tab_id = 'tab_chk_com_' + id;
	if ($('tab_chk_12_' + id).checked == false) {
	}
	else {
		var viewid = 'tab_chk_11_' + id;
		$(viewid).checked = true;
		$(tab_id).checked = true;
		var viewid = 'tab_chk_4_' + id;
		$(viewid).checked = true;
		$(tab_id).checked = true;
		$('tab_chk_11_' + id).checked = true;
	}
}

function unSelectCreate(id) {
	var viewid = 'tab_chk_4_' + id;
	if ($('tab_chk_11_' + id).checked == false) {
		$('tab_chk_12_' + id).checked = false;
		$('tab_chk_53_' + id).checked = false;
	}
	else {
		var viewid = 'tab_chk_4_' + id;
		$('tab_chk_com_' + id).checked = true;
		$(viewid).checked = true;
		$('tab_chk_12_' + id).checked = true;
		$('tab_chk_53_' + id).checked = true;
	}
}
/*
  add:unSelectEditView by kara
  date:2013-05-21
  reason:divide create/edit button
*/
function unSelectEditView(id) {
	var viewid = 'tab_chk_4_' + id;
	var viewMergeid = 'tab_chk_8_' + id;
	var viewDupid = 'tab_chk_38_' + id;
	if ($('tab_chk_1_' + id).checked == false) {
		$(viewDupid).checked = false;
		$(viewMergeid).checked = false;
	}
	else {
		var viewid = 'tab_chk_4_' + id;
		$('tab_chk_com_' + id).checked = true;
		$(viewid).checked = true;
		$(viewDupid).checked = true;
		$(viewMergeid).checked = true;
	}
}
function unSelectDelete(id) {
	var contid = id + '_view';
	if ($('tab_chk_2_' + id).checked == false) {
	} else {
		var viewid = 'tab_chk_4_' + id;
		$('tab_chk_com_' + id).checked = true;
		//wym 240314 BUG20240313-41 角色权限->编辑，全局快速授权“删除”权限时，部分模块（如：销售目标）授权没有生效
		if($(viewid)!='undefined' && $(viewid)!=undefined ){
			$(viewid).checked = true;
		}
	}
}

// @edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志
function unSelectDownLoadOrPreview(tabid, actionid) {
	//2023-6-21 yujun BUG0066757  增加判断：kfbcrm-角色权限-编辑权限-自定义表单-“下载和预览次数”字段应和“下载全部附件”字段一样，不勾选“下载”和“预览”时就不可勾选
	var tab_id = 'tab_chk_com_' + tabid;
	
	if ($('tab_chk_' + 42 + '_' + tabid).checked == false && $('tab_chk_' + 43 + '_' + tabid).checked == false) {
		$('tab_chk_50_' + tabid).disabled = true;
		$('tab_chk_49_' + tabid).disabled = true;
		$('tab_chk_49_' + tabid).checked = false;
		$('tab_chk_50_' + tabid).checked = false;
	}
	else if($('tab_chk_' + 42 + '_' + tabid).checked == true && $('tab_chk_' + 43 + '_' + tabid).checked == true){
		$(tab_id).checked = true;
		$('tab_chk_50_' + tabid).disabled = false;
		$('tab_chk_49_' + tabid).disabled = false;
	}
	else{
		if(actionid == 42){
			if($('tab_chk_' + actionid + '_' + tabid).checked == false){
				$('tab_chk_' + 49 + '_' + tabid).checked = false;
				$('tab_chk_49_' + tabid).disabled = true;
			}else{
				$('tab_chk_50_' + tabid).disabled = false;
				$(tab_id).checked = true;
				$('tab_chk_49_' + tabid).disabled = false;
			}
		}
		if(actionid == 43){
			if($('tab_chk_' + actionid + '_' + tabid).checked == true){
				$('tab_chk_50_' + tabid).disabled = false;
				$(tab_id).checked = true;
			}
		}
	}
	
}

//add 'editid' and change 1,4,2 with 1,2,4,3
function hideTab(id) {
	var maxActionId = ld("[name = maxActionId]").val();
	if ($('tab_chk_com_' + id).checked == false) {
		if (id == oftenusereporttabid) {
			var tmp_reportnames = reportnames.split(",");
			for (var i = 0; i < tmp_reportnames.length; i++) {
				var name = tmp_reportnames[i];
				ld(" [name=oftenusereport_" + name + "]").prop("checked", false);
			}
			for (var i = 1; i < maxActionId + 1; i++) {
				var stand = 'tab_chk_' + i + '_' + id;
				if (typeof ($(stand)) != 'undefined') {
					$(stand).checked = false;
				}
			}
		}
		else if (id == '-2') {
			var tmp_reportnames = mobilereportnames.split(",");
			for (var i = 0; i < tmp_reportnames.length; i++) {
				var name = tmp_reportnames[i];
				ld(" [name=mobilereport_" + name + "]").prop("checked", false);
			}
		}
		else {
			for (var i = 1; i < maxActionId + 1; i++) {
				var stand = 'tab_chk_' + i + '_' + id;
				if (typeof ($(stand)) != 'undefined') {
					$(stand).checked = false;
					//全选按钮修改推进、批量下载按钮状态
					if (i == 49) {
						ld($(stand)).attr('disabled', true);
					}
					//wym 240313 BUG20240313-38 角色权限，模块没有任何操作权限时，点击模块名称前面的全选按钮时，“下载和预览次数”操作权限不允许反勾选。预期结果：应该允许取消勾选
					if (i == 50) {
						ld($(stand)).attr('disabled', false);
					}
				}
			}
		}
	}
	else {
		if (id == oftenusereporttabid) {
			var tmp_reportnames = reportnames.split(",");
			for (var i = 0; i < tmp_reportnames.length; i++) {
				var name = tmp_reportnames[i];
				ld(" [name=oftenusereport_" + name + "]").prop("checked", true);
			}
			for (var i = 1; i < maxActionId + 1; i++) {
				var stand = 'tab_chk_' + i + '_' + id;
				if (typeof ($(stand)) != 'undefined') {
					$(stand).checked = true;
				}
			}
		}
		else if (id == '-2') {
			var tmp_reportnames = mobilereportnames.split(",");
			for (var i = 0; i < tmp_reportnames.length; i++) {
				var name = tmp_reportnames[i];
				ld(" [name=mobilereport_" + name + "]").prop("checked", true);
			}
		}
		else {
			for (var i = 1; i < maxActionId + 1; i++) {
				var stand = 'tab_chk_' + i + '_' + id;
				if (typeof ($(stand)) != 'undefined') {
					$(stand).checked = true;
					//全选按钮修改推进、批量下载按钮状态
					if (i == 49) {
						ld($(stand)).attr('disabled', false);
					}
					//wym 240313 BUG20240313-38 角色权限，模块没有任何操作权限时，点击模块名称前面的全选按钮时，“下载和预览次数”操作权限不允许反勾选。预期结果：应该允许取消勾选
					if (i == 50) {
						ld($(stand)).attr('disabled', false);
					}
				}
			}
		}
	}
}
function initialiseprofile() {
	var module_array = Array(1, 2, 4, 6, 7, 8, 9, 10, 13, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27);
	for (var i = 0; i < module_array.length; i++) {
		hideTab(module_array[i]);
	}
}
//角色权限 - 设置成员
function checkMember() {
	if (document.getElementById('selectedAssmablyColumns') != undefined) {
		var selectmember = '';
		var selObj = document.getElementById('selectedAssmablyColumns');
		var selectedAssmablyColumns = selObj.value;
		if (selObj.options.length <= 0) {
			//请选择字段！
			var confirm_str = arrJsPopLabel['PLEASESELECTATLEASTONEMEMBER'];
			RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
			return false;
		}
		else {
			for (var i = 0; i < selObj.options.length; i++) {
				selectmember += selObj.options[i].value + ",";
			}
			var popupobj = CrmPopup.getPopupObj("last");
			var profileid = ld("#" + popupobj.divid + " [name=profileid]").val();
			var surl = "index.php?module=Settings&action=SettingsAjax&file=SaveProfileMember&parenttab=Settings&profileid=" + profileid + "&selectmember=" + selectmember;
			ldAjax(surl, "", function (data) {
				if (data.code == 1) {
					var popupobj = CrmPopup.getPopupObj("last");
					popupobj.CancelEvent();
					DelProgressObjs();
				}
			})

		}
	}
}

function cls_RolesProfile(){
    var that = this;
    this.popupobj = {};
	this.NavBarList = [];
	this.allRolesBaseInfo_arr = [];
	this.AllModulePinyin_arr = [];
	this.LabelsInPopup_arr = [];// 翻译
	this.allUsersInfo_arr = [];// 用户信息

	this.surl = 'index.php?module=Settings&action=SettingsAjax&file=listroles&ajax=true';
	this.selected_profileid = 0;// 当前选中的角色id
	this.selected_btnmore_profileid = 0;// 当前点击了更多按钮的角色id

	this.NavBarSelKey = 0;// 默认选中的页签
	this.selected_navbar_type = 'setprofile';

	this.module_showhidestatus_arr = {};// 记录模块的显示隐藏状态，展开收起用
	this.rolePopupObj = {};// 新增编辑复制角色弹出层对象

	this.init = function (params){
		if(empty(this.popupobj)){
			if(!empty(params.popupobj)){
				var popupobj = params.popupobj;
			}else{
				var popupobj = CrmPopup.getPopupObj("last");
			}
			this.setPopupobj(popupobj);
		}
		this.popupobj.clsRolesProfileObj = listcontentobj.clsRolesProfileObj = this;
		this.NavBarList = params.NavBarList;
		this.selected_profileid = params.selected_profileid;
		this.allRolesBaseInfo_arr = params.allRolesBaseInfo_arr;
		this.AllModulePinyin_arr = params.AllModulePinyin_arr??[];
		this.LabelsInPopup_arr = params.LabelsInPopup_arr??[];
		// 重置默认值
		this.NavBarSelKey = 0;// 默认选中的页签
		this.selected_navbar_type = 'setprofile';
		this.module_showhidestatus_arr = {};

		this.setNavBarEvent();
		this.setListEvent();
	}

	this.setPopupobj = function(obj){
        this.popupobj = obj;
    }
	this.setHeight = function(type='setprofile'){
        var Popupobj = ld("#"+this.popupobj.divid);
		var listview_totalheight = Popupobj.height();
		// 设置高度
		if(type == 'categorytree'){
			var scrollcontent_height = listview_totalheight - Popupobj.find("#categorytree_title").outerHeight(true)
															- Popupobj.find("#rolesprofile_earch").outerHeight(true)
															- Popupobj.find("#btnarea").outerHeight(true);
			Popupobj.find('#ListViewLeft').find("#categorytree").css('height',scrollcontent_height);
		}else if(type == 'setusers'){
			var scrollcontent_height = listview_totalheight - Popupobj.find("#RolesProfile_RightHead").outerHeight()
															- Popupobj.find("#RolesProfile_RightNavbar").outerHeight(true)
															- Popupobj.find("#SetUsers_BtnArea").outerHeight(true);
			Popupobj.find("#SetUsersTableDiv").css('height',scrollcontent_height);
		}else{
			var scrollcontent_height = listview_totalheight - Popupobj.find("#RolesProfile_RightHead").outerHeight()
															- Popupobj.find("#RolesProfile_RightNavbar").outerHeight(true)
															- Popupobj.find("#RolesProfile_ParentTabs").outerHeight(true)
															- Popupobj.find("#RolesProfile_RightBottom").outerHeight(true);
			Popupobj.find("#RolesProfile_MainList").css('height',scrollcontent_height);
		}
    }
	// 界面绑定事件
    this.setListEvent = function(){
		this.setHeight('categorytree');
        var Popup_LeftObj = ld("#"+this.popupobj.divid).find("#ListViewLeft");
        // 切换模块
        Popup_LeftObj.find("[name=roleblock_div]").off('click').on('click', function (event) {
            that.selectRole(this);
        });
		// 搜索角色名
        Popup_LeftObj.find('#search_roles').off().on('keyup', function (event) {
            var e = event || window.event;
            if(e.keyCode == 13){
                that.searchRoles(this);
            }
			if(ld(this).val() != ''){
				Popup_LeftObj.find("#clear_search_roles").show();
			}else{
				Popup_LeftObj.find("#clear_search_roles").hide();
			}
        });
		// 清除搜索
		Popup_LeftObj.find("#clear_search_roles").off('click').on('click', function (event) {
            Popup_LeftObj.find('#search_roles').val('');
			that.searchRoles(this);
			ld(this).hide();
        });
		// 显示隐藏更多按钮
		Popup_LeftObj.find("[name=roleblock_div]").off('hover').hover(function (event) {
            ld(this).find("[name=operate_group]").toggle();
        });
		// 更多按钮
		Popup_LeftObj.find("[name=btn_more]").unbind("click").on('click',function(event){
			that.clickBtnMore(this);
			event.stopPropagation();
		})
		// 鼠标离开更多操作
		Popup_LeftObj.find('#role-libutton-box').unbind("mouseleave").bind("mouseleave",function(event){
			Popup_LeftObj.find('#role-libutton-box').hide();
		})
		// 新建角色
		Popup_LeftObj.find("[name=createrole]").unbind("click").on('click',function(event){
			that.selected_btnmore_profileid = 0;
			that.rolePopup(this);
		})
		// 复制角色
		Popup_LeftObj.find("[name=copyrole]").unbind("click").on('click',function(event){
			that.selected_btnmore_profileid = 0;
			that.rolePopup(this);
		})
		// 编辑角色
		Popup_LeftObj.find("[name=editrole]").unbind("click").on('click',function(event){
			that.rolePopup(this);
			Popup_LeftObj.find('#role-libutton-box').hide();
		})
		// 删除角色
		Popup_LeftObj.find("[name=deleterole]").unbind("click").on('click',function(event){
			deleteRole(this, that.selected_btnmore_profileid);
			Popup_LeftObj.find('#role-libutton-box').hide();
		})
		// 上下移角色
		Popup_LeftObj.find("[name=operate_group]").find("[name=movebtn]").unbind("click").on('click',function(event){
			that.moveUpDown(this);
			event.stopPropagation();
		})
		// 右侧界面绑定事件
		this.setProfileEvent();
	}
	// 右侧界面 - 权限设置绑定事件
    this.setProfileEvent = function(){
		that.setHeight();
		var Popup_RightObj = ld("#"+this.popupobj.divid).find("#ListViewRight");
		// 下拉框样式
		var selectobj = Popup_RightObj.find("select#profileaction");
		var cls_resetComboxHtmlobj = new cls_resetComboxHtml(selectobj.attr('name'));
		cls_resetComboxHtmlobj.setPopupObj(this.popupobj);
		var selectwidth = Tools.getParentobjByChild(selectobj, 'div').width();
		cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj, selectwidth + 10);
		// 搜索模块名
        Popup_RightObj.find('#search_content').off().on('keyup', function (event) {
            var e = event || window.event;
            if(e.keyCode == 13){
                that.searchModules(this);
            }
			if(ld(this).val() != ''){
				Popup_RightObj.find("#clear_search_content").show();
			}else{
				Popup_RightObj.find("#clear_search_content").hide();
			}
        });
		// 清除搜索
		Popup_RightObj.find("#clear_search_content").off('click').on('click', function (event) {
            Popup_RightObj.find('#search_content').val('');
			that.searchModules(this);
			ld(this).hide();
        });
		// 保存
		Popup_RightObj.find('#saveroleprofile').unbind("click").on('click', function (event) {
            that.saveRoleProfile();
        });

		Popup_RightObj.find('[name^=div_parenttab_]').unbind("click").removeAttr('onclick').on('click', function (event) {
            that.clickshowMenuProfile(ld(this).data('parenttabid'));
        });
		Popup_RightObj.find('[tag^=parenttab_head_]').find('div').unbind("click").removeAttr('onclick').on('click', function (event) {
            that.showHideMenuProfile(ld(this).data('parenttabid'));
        });
	}
	// 右侧界面 - 设置用户绑定事件
    this.setUsersEvent = function(){
		this.setHeight('setusers');
		var Popup_RightObj = ld("#"+this.popupobj.divid).find("#ListViewRight");
		// 搜索用户名
        Popup_RightObj.find('#search_content').off().on('keyup', function (event) {
            var e = event || window.event;
            if(e.keyCode == 13){
                that.searchUsers(this);
            }
			if(ld(this).val() != ''){
				Popup_RightObj.find("#clear_search_content").show();
			}else{
				Popup_RightObj.find("#clear_search_content").hide();
			}
        });
		// 清除搜索
		Popup_RightObj.find("#clear_search_content").off('click').on('click', function (event) {
            Popup_RightObj.find('#search_content').val('');
			that.searchUsers(this);
			ld(this).hide();
        });
		Popup_RightObj.find('[name=adduser]').unbind("click").on('click', function (event) {
            that.setUsers();
        });
		Popup_RightObj.find('[name=deleteuser]').unbind("click").on('click', function (event) {
            that.deleteUser(this);
        });
	}
	// 绑定页签
    this.setNavBarEvent = function (){
        var Popupobj = ld("#"+this.popupobj.divid);
		var navbarobj = Popupobj.find('#RolesProfile_RightNavbar').find('#navbar_area');
        var StuffNavBarList = [];
        if(this.NavBarList && !empty(this.NavBarList)){
            StuffNavBarList = this.NavBarList;
        }
        var NavBarSelKey = this.NavBarSelKey;// 默认选中的页签
        var ld_navbarobj = ld_NavBar.ShowNavBar(navbarobj.get(0),StuffNavBarList,{
            NavBarSelKey : NavBarSelKey,
            ShowAllItemInfo : true,
            MaxSimpleNum: 2,
            OnClick : function(evt){
                var selectNavBarItem = evt.NavBarItem;
				that.selected_navbar_type = selectNavBarItem.id;
				that.NavBarSelKey = selectNavBarItem.NavBarKey;
                that.changeNavBar(selectNavBarItem.id);// 切换页签
            },
        });
	}
	// 切换页签
    this.changeNavBar = function (type){
		var surl = this.surl;
        var param = {'navbar_type': type,'ajaxmode': 'changenavbar','selected_profileid': this.selected_profileid};
        ldAjax(surl,param,function (data){
            if(data.code == 1){
                ld("#"+that.popupobj.divid).find('#RolesProfile_MainContent').html(data.result.content);
                var Popup_RightObj = ld("#"+that.popupobj.divid).find("#ListViewRight");
				if(type == 'setusers'){
					Popup_RightObj.find('#search_content').attr('placeholder',arrJsPopLabel['SearchUsers']);
					that.setUsersEvent();
					that.allUsersInfo_arr = data.result.allUsersInfo_arr??[];
				}else{
					Popup_RightObj.find('#search_content').attr('placeholder',arrJsPopLabel['SEARCHMODULENAME']);
					that.setProfileEvent();
				}
            }else{
				MessagePopup.TipOne_warning(data.result.msg);
            }
			DelProgressObjs();
        })
	}
	// 切换角色
    this.selectRole = function(obj){
		// 重复点击不重新加载
		if(ld(obj).data('profileid') == this.selected_profileid){
			return;
		}
        if(!empty(obj)){
            this.selected_profileid = ld(obj).data('profileid');
        }else{
			this.selected_profileid = 0;
		}
		var all_roleblock_div_obj = ld('#'+this.popupobj.divid).find('[name=roleblock_div]');
		all_roleblock_div_obj.removeClass('ld-listview-left-categorytree-block-active');
		all_roleblock_div_obj.find('span').removeClass('category-name-active');
		ld(obj).addClass('ld-listview-left-categorytree-block-active');
		ld(obj).find('span').addClass('category-name-active');
        var surl = this.surl;
        var param = {'ajaxmode': 'selectrole','selected_profileid': this.selected_profileid,'selected_navbar_type': this.selected_navbar_type};
        ldAjax(surl,param,function (data){
            if(data.code == 1){
                ld("#"+that.popupobj.divid).find('#moduleoption').html(data.result.content);
				that.setNavBarEvent();
				if(that.selected_navbar_type == 'setusers'){
					that.setUsersEvent();
					that.allUsersInfo_arr = data.result.allUsersInfo_arr??[];
				}else{
					that.setProfileEvent();
				}
            }else{
				MessagePopup.TipOne_warning(data.msg);
            }
			DelProgressObjs();
        })
    }
	// 搜索角色
    this.searchRoles = function(obj){
		var searchText = ld(obj).val();
		var true_profileid = 0;
		var Popup_LeftObj = ld("#"+this.popupobj.divid).find("#ListViewLeft");
		if(searchText == ''){
			Popup_LeftObj.find("[name=roleblock_div]").show();
			Popup_LeftObj.find("[name=roleblock_div]").find("[name=operate_group]").find("[name=movebtn]").show();
		}else{
			Popup_LeftObj.find("[name=roleblock_div]").hide();
			Popup_LeftObj.find("[name=roleblock_div]").find("[name=operate_group]").find("[name=movebtn]").hide();
		}
		ld.each(this.allRolesBaseInfo_arr,function(index,roleinfo){
			ld.each(roleinfo,function(key,label){
				if(key != 'profilename' && key != 'pinyin'){
					return;
				}
				var pinyinlabel = makePy(label).join("").toLowerCase();
				if((label.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0 || (pinyinlabel.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0){
					true_profileid = roleinfo.profileid;
					Popup_LeftObj.find('[name=roleblock_div][data-profileid='+true_profileid+']').show();
				}
			});
		});
	}
	// 点击更多按钮
	this.clickBtnMore = function(obj){
		var Popup_LeftObj = ld("#"+this.popupobj.divid).find("#ListViewLeft");
		Popup_LeftObj.find('#role-libutton-box').show();
		var offset = ld(obj).offset();
        var popupOffset = ld('#'+this.popupobj.divid).offset();
		var relativeLeft = offset.left - popupOffset.left;// 相对弹出层的left
        var relativeTop = offset.top - popupOffset.top;
		Popup_LeftObj.find('#role-libutton-box').css('left',relativeLeft+8)
		Popup_LeftObj.find('#role-libutton-box').css('top',relativeTop)
		this.selected_btnmore_profileid = ld(obj).data('profileid');
	}
	// 新增编辑复制角色的弹出层
	this.rolePopup = function(obj) {
		var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth600px", 'Settings', "", "", "", "");
		crmPopupobj.prevshow();
		var mode = ld(obj).attr('name');
		crmPopupobj.setParams(this.LabelsInPopup_arr[mode], that.saveRole, "", "LdPopWidth600px", 'Settings', mode, arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
		var content_html = `<table class="ld-public-content-small" width="100%" border="0" cellspacing="0" cellpadding="0">`;
		if(mode == 'copyrole'){
			content_html += `<tr>
								<td class="ld-form-item-label"><font color="red">*</font>`+arrJsPopLabel['SELECTROLES']+`</td>
								<td class="ld-form-item-content">
									<select id="copied_profileid" name="copied_profileid">`;
			ld.each(this.allRolesBaseInfo_arr,function(index,roleinfo){
				content_html += `<option value="`+roleinfo.profileid+`" >`+roleinfo.profilename+`</option>`;
			});
			content_html += `</select>
							</td>
						</tr>`;
		}
		content_html += `<tr>
							<td class="ld-form-item-label"><font color="red">*</font>`+this.LabelsInPopup_arr['rolename']+`</td>
							<td class="ld-form-item-content">`
		if(mode == 'editrole'){
			content_html += `<input id="input_profilename" name="input_profilename" type="text" value="`+this.allRolesBaseInfo_arr[this.selected_btnmore_profileid]['profilename']+`" class="ld-input-inner">`;
		}else{
			content_html += `<input id="input_profilename" name="input_profilename" type="text" value="" class="ld-input-inner">`;
		}
		content_html += `</td>
						</tr>
						<tr>
							<td class="ld-form-item-label">`+this.LabelsInPopup_arr['description']+`</td>
							<td class="ld-form-item-content">`
		if(mode == 'editrole'){
			content_html += `<textarea id="input_description" name="input_description" class="ld-textarea-inner" type="text" style="">`+this.allRolesBaseInfo_arr[this.selected_btnmore_profileid]['description']+`</textarea>`;
		}else{
			content_html += `<textarea id="input_description" name="input_description" class="ld-textarea-inner" type="text" style=""></textarea>`;
		}
		content_html += `</td>
					</tr>
				</table>`;
		crmPopupobj.show(content_html);
		if(mode == 'copyrole'){
			// 下拉框样式
			var selectobj = ld("#"+crmPopupobj.divid).find("select#copied_profileid");
			var cls_resetComboxHtmlobj = new cls_resetComboxHtml(selectobj.attr('name'));
			cls_resetComboxHtmlobj.setPopupObj(popupobj);
			var selectwidth = Tools.getParentobjByChild(selectobj, 'td').width();
			cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj, selectwidth + 10);
		}
		this.rolePopupObj = crmPopupobj;
	}
	// 新增编辑复制角色的弹出层
	this.saveRole = function(mode) {
		var Popupobj = ld("#"+that.rolePopupObj.divid);
		var profilename = Popupobj.find('#input_profilename').val();
		if(empty(profilename)){
			var confirm_str = arrJsPopLabel['ROLENAMECANOTEMPTY'];
			MessagePopup.TipOne_warning(confirm_str);
			return false;
		}
		var description = Popupobj.find('#input_description').val();
		var profileinfo_arr = {
			'profileid' : that.selected_btnmore_profileid,
			'profilename' : profilename,
			'description' : description,
		};
		if(mode == 'copyrole'){
			var copied_profileid = Popupobj.find('#copied_profileid').val();
			profileinfo_arr['copied_profileid'] = copied_profileid;
		}
		var surl = that.surl;
		var param = {'ajaxmode': mode,'selected_profileid': that.selected_btnmore_profileid,'profileinfo_arr': profileinfo_arr};
		ldAjax(surl,param,function (data){
            if(data.code == 1){
				that.rolePopupObj.CancelEvent();
				// ld("#"+that.popupobj.divid).find('#ListViewLeft').html(data.result.content);
				listcontentobj.html(data.result.content);
				that.init(data.result);
            }else{
				MessagePopup.TipOne_warning(data.msg);
            }
			DelProgressObjs();
        })
	}
	// 右侧的保存权限设置
	this.saveRoleProfile = function() {
		var profileid = this.selected_profileid;
		var profilename = this.allRolesBaseInfo_arr[profileid]['profilename'];
		var description = this.allRolesBaseInfo_arr[profileid]['description'];
		var surl = "index.php?module=Users&action=UsersAjax&file=UpdateProfileChanges&parenttab=Settings&mode=&profileid=" + profileid;
		surl += '&profilename=' + encodeURIComponent(profilename);
		surl += '&description=' + encodeURIComponent(description);
		// 权限参数
		var paramsurl = '';
		var Popup_RightObj = ld("#"+this.popupobj.divid).find("#ListViewRight");
		ld.each(Popup_RightObj.find("[tag=module_tabid]"), function () {
			if (ld(this).is(':checked') == true) {
				paramsurl += '&' + ld(this).attr('name') + '=on';
			} else {
				paramsurl += '&' + ld(this).attr('name') + '=';
			}

		})
		ld.each(Popup_RightObj.find("[tag=module_actionname]"), function () {
			if (ld(this).is(':checked') == true) {
				paramsurl += '&' + ld(this).attr('name') + '=on';
			} else {
				paramsurl += '&' + ld(this).attr('name') + '=';
			}

		})
		ldAjax(surl, paramsurl, function (data) {
			if (data.code == 1) {
				MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
				
			}else{
				MessagePopup.TipOne_warning(data.msg);
            }
			DelProgressObjs();
		})
	}
	// 搜索模块
    this.searchModules = function(obj){
		var searchText = ld(obj).val();
		var PopupObj = ld("#"+this.popupobj.divid);
		var target_tableobj = PopupObj.find("#RolesProfile_MainList").find('table');
		// 当前选中的父级菜单id
		var active_parenttabid = PopupObj.find("#moduleoption").data('parenttabid');
		if(empty(active_parenttabid)){
			active_parenttabid = 'all';
		}
		// 搜索后全部显示/隐藏
		if(searchText == ''){
			that.module_showhidestatus_arr = [];
			this.clickshowMenuProfile(active_parenttabid);
			return;
		}else{
			target_tableobj.find('tr[tag^=parenttab_],tr[tag^=activeparenttab_]').hide();
		}

		ld.each(this.AllModulePinyin_arr,function(tabid,modulelabelinfo){
			var py_label = '';
			var needshow_parenttab = '';// 搜索后需要显示的父级菜单tab
			ld.each(modulelabelinfo,function(index,label){
				if(empty(label))
					return;
				py_label = makePy(label).join("").toLowerCase();

				if((label.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0 || (py_label.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0){
					if(target_tableobj.find('tr[tabid='+tabid+']').length > 0){
						// 处理搜索结果的显示
						if(active_parenttabid == 'all'){
							target_tableobj.find('tr[tabid='+tabid+']').show();
							needshow_parenttab = target_tableobj.find('tr[tabid='+tabid+']').attr('tag');
							var parenttab_arr = needshow_parenttab.split('_');
							var tmp_parenttabid = parenttab_arr[1];
							target_tableobj.find('tr[tag=parenttab_head_'+tmp_parenttabid+']').show();
							target_tableobj.find('span[id=parenttab_' + tmp_parenttabid + ']').removeClass();
						}else{
							target_tableobj.find('tr[tag=activeparenttab_'+active_parenttabid+']').show();
							target_tableobj.find('tr[tabid='+tabid+'][tag=parenttab_'+active_parenttabid+']').show();
						}
					}
				}
			});
		});
	}
	// 父级菜单名点击事件（原方法基础上修改）
    this.clickshowMenuProfile = function(parenttabid){
		var PopupObj = ld("#"+this.popupobj.divid);
		var spanobj = PopupObj.find('#moduleoption span[sontag="parenttab_' + parenttabid + '"]');
		var showstatus = ld(spanobj).attr('toptag');

		var showspanobj = PopupObj.find('#moduleoption span[toptag=show]');
		if (parenttabid == 'all') {
			ld.each(PopupObj.find('#moduleoption tr[tag^=parenttab_]'), function () {
				ld(this).css('display', '');
				ld(this).find('span[id^="parenttab_"]').removeClass();
			});
			ld.each(PopupObj.find('#moduleoption tr[tag^=activeparenttab_]'), function () {
				ld(this).css('display', 'none');
			});
		} else {
			if (showspanobj.attr('sontag') == 'parenttab_all') {
				ld.each(PopupObj.find('#moduleoption tr[tag^=parenttab_]'), function () {
					ld(this).css('display', 'none');
				});
				ld.each(PopupObj.find('#moduleoption tr[tag^=activeparenttab_]'), function () {
					ld(this).css('display', 'none');
				});
			} else {
				ld.each(PopupObj.find('#moduleoption tr[tag="' + showspanobj.attr('sontag') + '"]'), function () {
					ld(this).css('display', 'none');
				});
				ld.each(PopupObj.find('#moduleoption tr[tag="active' + showspanobj.attr('sontag') + '"]'), function () {
					ld(this).css('display', 'none');
				});
			}
			var trobjs = PopupObj.find('#moduleoption tr[tag="parenttab_' + parenttabid + '"]');
			ld.each(trobjs, function () {
				ld(this).css('display', '');
			});
			var trheadobjs = PopupObj.find('#moduleoption tr[tag="activeparenttab_' + parenttabid + '"]');
			ld.each(trheadobjs, function () {
				ld(this).css('display', '');
			});
		}
		PopupObj.find('#moduleoption div[class="menustandarddiv menustandarddivactive"]').removeClass('menustandarddivactive');
		PopupObj.find('#moduleoption div[name="div_parenttab_' + parenttabid + '"]').addClass('menustandarddivactive');
		ld(showspanobj).attr('toptag', 'hidden');
		ld(spanobj).attr('toptag', 'show');
		
		if (PopupObj.find('#moduleoption tr[style=""] input[type="checkbox"]:not(:checked)').length > 0) {
			PopupObj.find('#all_tab').prop('checked', false);
		} else {
			PopupObj.find('#all_tab').prop('checked', true);
		}

		PopupObj.find("#moduleoption").data('parenttabid',parenttabid);
		// 切换完后需要再根据查询条件进行搜索
		var searchText = PopupObj.find('#search_content').val();
		if(searchText != ''){
			this.searchModules(PopupObj.find('#search_content'));
		}
	}
	//zkt 【角色权限，操作权限增加“全选”功能】--角色权限设置展开关闭区块
	this.showHideMenuProfile = function(parenttabid) {
		var PopupObj = ld("#"+this.popupobj.divid);
		var spanobj = PopupObj.find('#moduleoption span[id="parenttab_' + parenttabid + '"]');
		var trobjs = PopupObj.find('#moduleoption tr[tag="parenttab_' + parenttabid + '"]');
		var showstatus = ld(spanobj).attr('tag');
		if (showstatus == 'show') {//On
			ld(spanobj).attr('class', 'On');
			that.module_showhidestatus_arr[parenttabid] = [];
			ld.each(trobjs, function () {
				// 记录收起前显示的模块
				if(ld(this).is(':visible')){
					that.module_showhidestatus_arr[parenttabid].push(ld(this).attr('tabid'));
				}
				ld(this).css('display', 'none');
			})
			ld(spanobj).attr('tag', 'hidden');
		}
		else if (showstatus == 'hidden') {
			ld(spanobj).removeClass();
			ld.each(trobjs, function () {
				if(!empty(that.module_showhidestatus_arr[parenttabid])){
					if(that.module_showhidestatus_arr[parenttabid].include(ld(this).attr('tabid'))){
						ld(this).css('display', '');
					}
				}else{
					ld(this).css('display', '');
				}
			})
			ld(spanobj).attr('tag', 'show');
		}
	}
	// 设置用户 - 添加用户
	this.setUsers = function() {
		var profileid = that.selected_profileid;
		var surl = "index.php?module=Settings&action=SettingsAjax&file=setMember&parenttab=Settings&profileid=" + profileid;
		ldAjaxNoProgress(surl, "", function (data) {
			if (data.code == 1) {
				var popup_caption_value = setmember_title;
				//@edit:liushuai,2020-07-31,reason:角色权限>设置成员弹出层，新导入的成员角色权限为空时，profileid = 0,popup_scopetype=public参数会不显示新加用户，所以改成all
				var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=all&popup_module=Accounts&popup_inputtype=checkbox&popup_selecttype=user';
				getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
					var methodObj = { 'popup_check_inactiveuser': 'yes', 'popup_check_nogroupuser': 'no' };
					scopepopupobj = new ScopePopupObj(methodObj);
					scopepopupobj.popup_caption_value = popup_caption_value;//标题title
					getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
						cls_ScopePopup.prop.popup_url = popup_url;//popup_url
						cls_ScopePopup.prop.popup_module = 'Accounts';//模块
						cls_ScopePopup.prop.popup_value = data.result.sel_role_userid;
						var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);

						//重写确认按钮事件
						scopepopupobj.setEventBtnOk = function () {
							ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
								if (empty(cls_ScopePopup.return_obj.return_id)) {
									var confirm_str = arrJsPopLabel['PLEASESELECTATLEASTONEMEMBER'];
									RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
									return false;
								} else {
									ld('#' + cls_ScopePopup.popup_divid + ' .D_pbtn .D_pbtnok').attr("disabled", true);
									var selectmember = cls_ScopePopup.return_obj.return_id;//选中的用户
									var surl = "index.php?module=Settings&action=SettingsAjax&file=SaveProfileMember&parenttab=Settings&profileid=" + profileid + "&selectmember=" + selectmember;
									ldAjax(surl, "", function (data) {
										if (data.code == 1) {
											ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
											// 刷新界面
											that.changeNavBar('setusers');
											DelProgressObjs();
										}
									});
								}
							});
						}
					});
				});
			}
		});
	}
	// 删除用户
	this.deleteUser = function(obj) {
		var delete_userid = ld(obj).data('userid');
		MessagePopup.TipTwo_warning(arrJsPopLabel['SUREWANTDELETE']);
		var popupobj = CrmPopup.getPopupObj("last");
		ld('#' + popupobj.divid).find('#' + popupobj.divid + '_btnok').unbind('click').on('click', function () {
			var surl = that.surl;
			var param = {'ajaxmode': 'deleteusers','delete_userid': delete_userid};
			ldAjaxNoProgress(surl,param,function (data){
				if(data.code == 1){
					popupobj.CancelEvent();
					MessagePopup.TipZero_success(data.msg);
					// 刷新界面
					that.changeNavBar('setusers');
				}else{
					MessagePopup.TipOne_warning(data.msg);
				}
			});
		});
	}
	// 搜索角色
    this.searchUsers = function(obj){
		var searchText = ld(obj).val();
		var Popup_RightObj = ld("#"+this.popupobj.divid).find("#ListViewRight");
		if(searchText == ''){
			Popup_RightObj.find('#SetUsersTableDiv').find("[name=userTr]").show();
		}else{
			Popup_RightObj.find('#SetUsersTableDiv').find("[name=userTr]").hide();
		}
		ld.each(this.allUsersInfo_arr,function(userid,userinfo){
			var pinyinlabel = '';
			ld.each(userinfo,function(key,label){
				if(key != 'last_name' && key != 'pinyin_name'){
					return;
				}
				pinyinlabel = makePy(label).join("").toLowerCase();
				if((label.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0 || (pinyinlabel.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0){
					Popup_RightObj.find('#SetUsersTableDiv').find("[name=userTr][userid="+userid+"]").show();
				}
			});
		});
	}
	// 上下移动角色
    this.moveUpDown = function(obj){
		var direction = ld(obj).attr('tag');
		var parentobj = ld(obj).parents('div[name=roleblock_div]'); //点击的对象所在父级div
		var tmptranobj = {};
		if (direction == 'moveup') {
			if (parentobj.prev() != undefined && parentobj.prev().length > 0) {
				tmptranobj = parentobj.prev();
				ld(tmptranobj).insertAfter(parentobj);
			}else{
				return;
			}
		}
		else if (direction == 'movedown') {
			if (parentobj.next() != undefined && parentobj.next().length > 0 && parentobj.next().attr('name') == 'roleblock_div') {
				tmptranobj = parentobj.next();
				ld(tmptranobj).insertBefore(parentobj);
			}else{
				return;
			}
		}
		var profileid = parentobj.data('profileid');
		var surl = that.surl;
		var param = {'ajaxmode': 'moveupdown','direction': direction,'selected_profileid': profileid};
		ldAjaxNoProgress(surl,param,function (data){
			if(data.code == 1){
				console.log(that.allRolesBaseInfo_arr);
			}else{
				
			}
		});
	}
	// 角色权限 - 字段权限
	this.EditProfileField = function(profileid, tabid) {
		var surl = 'index.php?module=Users&action=UsersAjax&file=editProfileField&ajax=true&tabid=' + tabid + '&profileid=' + profileid;
		var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", 'Settings', "", "", "", "");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl, "", function (data) {
			if (data.code == 1) {
				crmPopupobj.setParams(data.result.title, that.SaveProfileField, "", "LdPopWidth800px", 'Settings', "", data.result.oktext, "", data.result.canceltext);
				CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);
				// 弹出层内容高度
				crmPopupobj.proportion = 1;
				var PopContentHeight = crmPopupobj.getPopContentHeight();
				var content_height = PopContentHeight - ld("#" + crmPopupobj.divid).find("#description_area").outerHeight()
													  - ld("#" + crmPopupobj.divid).find("#search_area").outerHeight(true);
				ld("#" + crmPopupobj.divid).find("#EditProfileFieldDiv").css('height',content_height);
				ld("#" + crmPopupobj.divid).find("#EditProfileFieldScrollDiv").css('max-height',content_height-40);
				crmPopupobj.fieldBaseInfo_arr = data.result.fieldBaseInfo_arr;
				that.setPopupobj(crmPopupobj);
				that.setProfileFieldEvent();
			}
		})
	}
	//角色权限 - 保存字段权限
	this.SaveProfileField = function() {
		var surl = "index.php?module=Users&action=UsersAjax&file=SaveProfileField";
		var popupobj = that.popupobj;
		var tabid = ld("#" + popupobj.divid).find("[name=tabid]").val();
		var profileid = ld("#" + popupobj.divid).find("[name=profileid]").val();
		surl += "&tabid=" + tabid;
		surl += "&profileid=" + profileid;
		ld.each(ld("#" + popupobj.divid).find("[tag=tabid_field]"), function () {
			var fieldid = ld(this).attr('id');
			var fieldname = ld(this).attr('name');
			var fieldid_permission = ld("#" + popupobj.divid + " input[name='" + fieldid + "_" + fieldname + "']:checked").val();
			surl += '&' + fieldid + '_permission=' + fieldid_permission;
		});
		ldAjax(surl, "", function (data) {
			if (data.code == 1) {
				popupobj.CancelEvent();
			}
			DelProgressObjs();
		})
	}
	// 角色权限 - 字段权限 - 绑定事件
	this.setProfileFieldEvent = function() {
		var PopupObj = ld("#" + this.popupobj.divid);
		// 搜索字段名
		PopupObj.find('#search_fieldname').off().on('keyup', function (event) {
            var e = event || window.event;
            if(e.keyCode == 13){
                that.searchFieldname(this);
            }
			if(ld(this).val() != ''){
				PopupObj.find("#clear_search_fieldname").show();
			}else{
				PopupObj.find("#clear_search_fieldname").hide();
			}
        });
		// 清除搜索
		PopupObj.find("#clear_search_fieldname").off('click').on('click', function (event) {
            PopupObj.find('#search_fieldname').val('');
			that.searchFieldname(this);
			ld(this).hide();
        });
		// 全选
		PopupObj.find('table#EditProfileFieldTable').find('[name=selectAll_input]').unbind("click").on('click', function (event) {
            that.editProfileFieldSelectAll(this);
        });
		// 显示隐藏说明文字
		PopupObj.find('#showhide_tips').unbind("click").on('click', function (event) {
            PopupObj.find('#tipscontent').toggle();
			if (ld(this).find('b').hasClass('activeicon')) {
				ld(this).find('b').removeClass('activeicon');
			} else {
				ld(this).find('b').addClass('activeicon');
			}
			that.popupobj.center();
        });
	}
	// 角色权限 - 字段权限 - 搜索字段名
	this.searchFieldname = function(obj) {
		var searchText = ld(obj).val();
		var PopupObj = ld("#" + this.popupobj.divid);
		var targetobj = PopupObj.find('table#EditProfileFieldTable');
		if(searchText == ''){
			targetobj.find('tr[name=fieldTr]').show();
		}else{
			targetobj.find('tr[name=fieldTr]').hide();
		}
		ld.each(this.popupobj.fieldBaseInfo_arr,function(fieldid,fieldinfo){
			var pinyinlabel = '';
			ld.each(fieldinfo,function(key,label){
				if(key != 'fieldlabel'){
					return;
				}
				pinyinlabel = makePy(label).join("").toLowerCase();
				if((label.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0 || (pinyinlabel.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0){
					targetobj.find("tr[name=fieldTr][fieldid="+fieldid+"]").show();
				}
			});
		});
	}
	// 角色权限 - 字段权限 - 全选
	this.editProfileFieldSelectAll = function(obj) {
		var radiovalue = ld(obj).val();
		var PopupObj = ld("#" + this.popupobj.divid);
		var trobjs = PopupObj.find('table#EditProfileFieldTable').find('tr[name=fieldTr]');
		// 选中所有可见且没有disabled的单选
		trobjs.find('input[type=radio][value='+radiovalue+']:not(:disabled):visible').prop('checked',true);
	}
}