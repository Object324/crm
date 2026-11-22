function publicLeads(popupobj){
	this.module = 'Leads';
	this.popupobj = popupobj;
	this.arr_recovery_modules = new Array();	//回收模块
	var that = this;
	
	//设置公海池
	this.edit_account_public_pool = function(pool_obj,event){
		var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=createPublicAccountPool&getlist=yes';
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.close_account_public_pool,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.createScrollDiv();
				crmPopupobj.show(data.result.content);

				// 帮助
				if(data.result.helpHtml && data.result.helpHtml!=""){
					ld('#'+crmPopupobj.divid + " #" + crmPopupobj.divid + '_head').find('.E_ptita').after(data.result.helpHtml);
				}
				
				// 需要去掉的给高度
				crmPopupobj.reduceBodyHeight = 84;
				// 设置内容最大高度
				crmPopupobj.setPopBodyMaxHeight("#dv_scroll");

				that.SortPublicPool();
				crmPopupobj.center();
				var module = getUrlParam("pageto_module");
				//@edit:zhaosk @date:2024/08/08 @reason:后台设置引导页处显示管理看板弹窗，module做特殊处理
				if(module=='Settings'){}
				else{
					ld("#"+crmPopupobj.divid+" .E_ptitc").unbind('click').on('click',function(){
						that.refresh_list();
					})
				}
			}
		})
	}
    this.showKehu001UserName=function(){
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                     //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
    }
	this.close_account_public_pool = function(){
		that.refresh_list();
	}
	//删除公海池
	this.del_account_public_pool = function(pool_obj,event){
		getJsScript('include/js/cls_poolinfo_set.js', function () {
			cls_poolinfo_set.static_delete(that.module,pool_obj)
		});
		return '';
	}

	this.del_account_public_pool_save =function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var prev_popupobj=CrmPopup.getPopupObj("lastprev");
		var pool_id = ld("#"+popupobj.divid+" [name=delete_pool_id]").val();
		var selected_pool_id = ld("#"+popupobj.divid+" [name=all_pool]").val();
		var confirm_str = arrJsPopLabel['afterdeletethehignseaspool'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=deletePublicLeadsPool&pool_id='+pool_id+"&selected_pool_id="+selected_pool_id;
			ldAjax(surl,"",function(data){
				if(data.code==1){
					popupobj.CancelEvent();
					ld("#"+prev_popupobj.divid+" [name=tr_pool_id_"+pool_id+"]").hide();
					if(ld("#"+prev_popupobj.divid).find(".ld-category-drag:visible").length <= 1){
						ld("#"+prev_popupobj.divid).find(".ld-category-drag:visible").hide();
					}
					DelProgressObjs();
				}
			})
		})
		return false;
	}
	//新建、修改公海池
	this.account_public_pool = function(pool_obj,event){
		getJsScript('include/js/cls_poolinfo_set.js', function () {
			cls_poolinfo_set.static_editpopup(that.module,pool_obj)
		});
		return '';
	}

	//保存公海池事件
	this.save_account_public_pool = function(){
		var expre=/^[0-9]*[1-9][0-9]*$/;
		var popupobj=CrmPopup.getPopupObj("last");
		var prevpopupobj=CrmPopup.getPopupObj("lastprev");
		var pool_id = ld("#"+popupobj.divid+" [name=select_pool_id]").val();
		var languagetype = ld("#"+popupobj.divid+" [name=languagetype]").val();
		//公海名称（中）
		var zh_name =ld.trim( ld("#"+popupobj.divid+" [name=zh_name]").val());
		if(empty(zh_name)){
			audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=zh_name]").attr('label')+arrJsPopLabel['CANOTEMPTY']);
			ld("#"+popupobj.divid+" [name=zh_name]").focus();
			return false;
		}
		//公海名称（英）
		var en_name = ld("#"+popupobj.divid+" [name=en_name]").val();
		if(empty(en_name)){
			audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=en_name]").attr('label')+arrJsPopLabel['CANOTEMPTY']);
			ld("#"+popupobj.divid+" [name=en_name]").focus();
			return false;
		}
		if(languagetype == 'zh'){
			var pool_name = zh_name;
		}else{
			var pool_name = en_name;
		}
		//公海管理员
		var select_administrators_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
		if(empty(select_administrators_id)){
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['Pleasesettheadministratorsjspop']);
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				ld("#"+popupobj.divid+" [name=select_administrators]").click();
			})
			return false;
		}
		//公海已分配客户数量上限
		var limit_type = ld("#"+popupobj.divid+" [name=limit_type]:checked").val();
		var limit_count = ld("#"+popupobj.divid+" [name=limit_count]").val();
		if(limit_type == 'user'){
			if(!(expre.test(trim(limit_count)))){
				audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=limit_count]").attr('label')+arrJsPopLabel['NUMONLYINT']);
				ld("#"+popupobj.divid+" [name=limit_count]").focus();
				return false;
			}
		}
		//公海成员客户序时簿“新建”功能下拉选项
		var create_buttons = ld('#m_create_buttons').select2('data');
		var str_create_buttons = '';
		ld.each(create_buttons,function(index,info){
			if(info.text!='')
			{
				str_create_buttons=info.text;
			}
		})
		if(str_create_buttons == ''){
			var confirm_str = arrJsPopLabel['NEWBUTTONDROPDOWNOPTIONS']+arrJsPopLabel['CANOTEMPTY'];
            audioRemindsMsg("","","","","",confirm_str);
            return false;
		}
		//您启用了公海客户，需要设置回收条件
		var  atleastonechoose=false;
		ld("#"+popupobj.divid+" [accounttype=chkcomplete]").each(function () {
			if(ld(this).is(":checked"))
			{
				atleastonechoose=true;
				return false;
			}
		});
		if(!atleastonechoose)    
		{
			confirm_str = arrJsPopLabel['ATLEASTONECONDITIONSENABLED'];
			audioRemindsMsg("","","","","",confirm_str);
			return false;
		}
		
		//自动回收规则设置天数必须输入大于等于1的整数！
		var daysbol=true;
		ld.each(that.arr_recovery_modules,function(index,tmpmodule){
			if(ld(" [name="+tmpmodule+"_completechk]").prop("checked"))
			{
				if(ld(" [name=changerule_complete_"+tmpmodule+"]").val()=='no')
				{
					//单次回收
					var textvalue=ld(" [name="+tmpmodule+"_single_completedays]").val();
				}
				else
				{
					//循环回收
					//ContactRecords_completedays
					var textvalue=ld(" [name="+tmpmodule+"_completedays]").val();
				}
				//BUG0053908 wyt 220803 回收规则条件设置天数报错提示修改为“自动回收规则设置天数必须输入大于等于1且小于等于5000的整数！”
				if((!/^\d+$/.test(textvalue)||textvalue<1||textvalue>5000))
				{
					daysbol=false;
					return false;
				}
			}
		 })
		if(!daysbol)
        {
            confirm_str = ld("#"+popupobj.divid+" [name=auto_recovery_rule_label]").val() + arrJsPopLabel['DAYSMUSTGREATERQUZERO'];
			audioRemindsMsg("","","","","",confirm_str);
            return false;
        }
		if(popupobj.highersearchobj.checkAdvancedFilter()==false) 
		{
				return false;
		}
		var form_data = new FormData(ld("#"+popupobj.divid+" [name=save_public_account_pool]")[0]);
		var surl = "";
		ld('#rptContentLoading').show();
		ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: form_data,
			url: 'index.php?module=Leads&action=LeadsAjax&file=savePublicleadsPool&select_pool_id='+pool_id,
			success: function(data) {
				ld('#rptContentLoading').hide();
				var confirm_str=arrJsPopLabel['SUCCESSFULLYSAVED'];
				// RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				MessagePopup.TipOne_success(confirm_str);
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					popupobj.CancelEvent();
					if(pool_id >= 1){
						ld("#"+prevpopupobj.divid+" [name=td_pool_name_"+pool_id+"]").html(pool_name);
					}else{
						var newpool_html = "<tr class=\"ld-category-draggable\" pool_id="+data.result.pool_id+" name='tr_pool_id_"+data.result.pool_id+"'>"
						newpool_html += "<td><span name='td_pool_name_"+data.result.pool_id+"'>"+pool_name+"</span></td><a class=\"ld-category-icon ld-category-drag drag-handle\" style=\"cursor: pointer;\"></a>";
						newpool_html += "<td><input name=\"set_default_pool\" pool_id="+data.result.pool_id+" type=\"checkbox\" class=\"second_switch\" style=\"margin-left: 5px;\" onclick=\"publicLeads.getInstance().SetDefaultPool(this)\"></td>";
						newpool_html += "<td class='sort_td'><a class=\"tip-items-list\" href=\"javascript:void(0);\" tag=\"edit\" pool_id="+data.result.pool_id+" onclick=\"publicLeads.getInstance().account_public_pool(ld(this),event);\" style=\"white-space:nowrap;margin-left:8px;\" data-tip="+arrJsPopLabel['EDIT']+" data-direction=\"top\" data-type=\"position\"><b class=\"ld-category-icon ld-category-edit\"></b></a> ";
						newpool_html += "<a class=\"ld-category-icon ld-category-drag drag-handle tip-items-list\" style=\"cursor: pointer;\" data-tip="+arrJsPopLabel['drag']+" data-direction=\"right\" data-type=\"position\"></a> ";						
						newpool_html += "<a class=\"ld-category-icon ld-category-del tip-items-list\" href=\"javascript:void(0);\" tag=\"delete\" pool_id="+data.result.pool_id+" onclick=\"publicLeads.getInstance().del_account_public_pool(ld(this),event);\" style=\"white-space:nowrap;\" data-tip="+arrJsPopLabel['DELETE']+" data-direction=\"top\" data-type=\"position\"></a> </td></tr>";						
						ld("#"+prevpopupobj.divid+" [name=viewpublicaccount_table]").append(newpool_html);
					}
					ld("#"+prevpopupobj.divid).find(".ld-category-drag").show();
					that.SortPublicPool();
					//that.refresh_list();
				})
				return false;
				
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		  })
		return false;
	}

	this.refresh_list = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var prev_popupobj=CrmPopup.getPopupObj("lastprev");
		var is_none_row = 0;
		ld("#"+popupobj.divid+" [name=viewpublicaccount_table] tr").each(function(i){
			if(ld(this).css('display') == 'none'){
				is_none_row = 1;
				return;
			}
		});
		popupobj.CancelEvent();
		var module = getUrlParam("pageto_module");
		if(module=='Settings')
			return;
		if(is_none_row == 1){
			var searchScope = '';
			if(ld("#"+prev_popupobj.divid+" [name=SmOwnerSearchScope]")!=null)
				searchScope= encodeURIComponent(ld("#"+prev_popupobj.divid+" [name=SmOwnerSearchScope]").val());
			var listview_page=new ListView_Page('Leads',"module=Leads&action=LeadsAjax&file=ListView&start=1&SearchScope="+searchScope+"&pool_id=1","pagecontent1");
			listview_page.callback_fun=function()
			{
				//wym 231227 BUG0077623 销售线索->编辑公海池界面，删除公海池保存确认后，界面显示异常
				prev_popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
				setContentHeight(module);//计算内容高度   
				IsFrameElement();
			}
			listview_page.page();
		}else{
			var tmparra=new Array();
			var tmpobj= new AfterUpdatePrevPopupObjContent(that.module,"",tmparra);
			var refreshlistmodules = new Array(that.module);
			tmpobj.eachrefreshlistbyModules(refreshlistmodules);
		}
	}

	//新增公海事件绑定
	this.create_account_public_pool_bind = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		//公海成员
		ld("#"+popupobj.divid+" [name=radioUser]").unbind('click').on('click',function(){
			var radiouser = ld(this).attr('value');
			if(radiouser == 'all'){
				ld("#"+popupobj.divid+" [name=usertype]").val('all');
				ld("#"+popupobj.divid+" [name=userids]").val('');
			}else{
				var module = 'Leads';
				if(radiouser == 'user'){
					var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['LBL_USERS'];
					var file = 'viewuserinfo';
				}else{
					var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['USERGROUPLIST'];
					var file = 'viewgroupinfo';
				}
				//chj 2021/1/15 44284: 多公海->新建和编辑公海池设置公海成员问题：不应该控制成员范围，应该显示所有成员
				var popup_url = 'module=Users&action=UsersAjax&file='+file+'&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype='+radiouser;
				var userids = ld("#"+popupobj.divid+" [name=userids]").val();
				getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
					scopepopupobj =  new ScopePopupObj(module);
					scopepopupobj.popup_caption_value = popup_caption_value;//标题title
					if(radiouser == 'group'){
						scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
						scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'></div>';
					}
					getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
						cls_ScopePopup.prop.popup_url = popup_url;//popup_url
						cls_ScopePopup.prop.popup_module = module;//模块
						cls_ScopePopup.prop.popup_value = userids;
						var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
						//重写确认按钮事件
						scopepopupobj.setEventBtnOk=function(){
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
								if(empty(cls_ScopePopup.return_obj.return_id)){
									if(radiouser == 'group'){
										var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
									}else{
										var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
									}
									RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
									return false;
								}else{
									var selected_user = cls_ScopePopup.return_obj.return_id;//选中的部门
									ld("#"+popupobj.divid+" [name=usertype]").val(radiouser);
									ld("#"+popupobj.divid+" [name=userids]").val(selected_user);
									ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
								}
							});
                            that.showKehu001UserName();
						}
						scopepopupobj.setEventBtnCancel=function(){
							//关闭事件
							ld('#'+cls_ScopePopup.popup_divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
								var usertype = ld("#"+popupobj.divid+" [name=usertype]").val();
								ld("#"+popupobj.divid+" [name=radioUser]").each(function(i){
									if(usertype==ld(this).val()){
										ld(this).prop('checked',true);
									}
								});
								return false;
							});
							//取消事件
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').trigger('closediv');
								var usertype = ld("#"+popupobj.divid+" [name=usertype]").val();
								ld("#"+popupobj.divid+" [name=radioUser]").each(function(i){
									if(usertype==ld(this).val()){
										ld(this).prop('checked',true);
									}
								});
							});
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){
								
								var usertype = ld("#"+popupobj.divid+" [name=usertype]").val();
								ld("#"+popupobj.divid+" [name=radioUser]").each(function(i){
									if(usertype==ld(this).val()){
										ld(this).prop('checked',true);
									}
								});
								// fninvshnew(cls_ScopePopup.popup_divid);
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
		});
		//公海管理员
		that.set_account_public_select_user_bind();
        that.showKehu001UserName();
		//公海已分配客户数量上限
		ld("#"+popupobj.divid+" [name=limit_type]").unbind('click').on('click',function(){
			var limit_type = ld(this).attr('value');
			if(limit_type == 'user'){
				ld("#"+popupobj.divid+" [name=select_limit_type_role]").hide();
				ld("#"+popupobj.divid+" [name=limit_count]").attr('disabled',false);
			}else{
				ld("#"+popupobj.divid+" [name=select_limit_type_role]").show();
				ld("#"+popupobj.divid+" [name=limit_count]").attr('disabled',true);
			}
		});
		//客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）  tag=userid_after_transfer
		// 公海已分配客户释放后，更改客户负责人为（为空表示不更改） tag=userid_after_release
		ld("#"+popupobj.divid+" [name=select_user_name]").unbind('click').on('click',function(){
			var select_tag = ld(this).attr('tag');
			if(select_tag == 'userid_after_transfer'){
				var usertype = ld("#"+popupobj.divid+" [name=usertype]").val();
				var userids = ld("#"+popupobj.divid+" [name=userids]").val();
				//请先设置公海成员！
				if(usertype == ''){
					audioRemindsMsg("","","","","",arrJsPopLabel['Pleasesetuphighseasmemberfirst']);
					return false;
				}
			}
			var select_userids = ld("#"+popupobj.divid+" [name=userid_after_transfer]").val();
			var scopepopupobj;//自定义弹出层页面html，绑定事件
			var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
			var module = 'Leads';
			getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
				var methodObj = {'popup_check_inactiveuser':'no'};
				scopepopupobj =  new ScopePopupObj(methodObj);
				scopepopupobj.popup_caption_value = popup_caption_value;//标题title
				getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
					cls_ScopePopup.prop.popup_module = module;//模块
					cls_ScopePopup.prop.popup_value = select_userids;
					if(select_tag == 'userid_after_transfer'){
						cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&publiaccount=yes&usertype='+usertype+'&ids='+userids;
					}else{
						cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user';
					}
					var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
					//重写确认按钮事件
					scopepopupobj.setEventBtnOk=function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
							if(empty(cls_ScopePopup.return_obj.return_id)){
								var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
								RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
								return false;
							}else{
								ld("#"+popupobj.divid+" [name="+select_tag+"]").val(cls_ScopePopup.return_obj.return_id);
                              
								ld("#"+popupobj.divid+" [name="+select_tag+"_name]").html(cls_ScopePopup.return_obj.return_name);
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
							}
                            that.showKehu001UserName();
						});
                        
					}
				});
			});
		});
		//清空：客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）  tag=userid_after_transfer
		//清空：公海已分配客户释放后，更改客户负责人为（为空表示不更改） tag=userid_after_release
		ld("#"+popupobj.divid+" [name=clear_user_name]").unbind('click').on('click',function(){
			var select_tag = ld(this).attr('tag');
			ld("#"+popupobj.divid+" [name="+select_tag+"]").val('');
			ld("#"+popupobj.divid+" [name="+select_tag+"_name]").html('');
		})
		//绑定公海超级管理员删除事件
		if(ld('#'+popupobj.divid+' [name=administrators_div] ul.reader-bar-list .remove-h') != undefined){
			ld('#'+popupobj.divid+' [name=administrators_div] ul.reader-bar-list .remove-h').unbind('click').click(function(){
				var remove_userid = ld(this).parent().attr('itemid');
				ld(this).parent().remove();
				var select_administrators_ids = [];
				var select_administrators_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
				select_administrators_ids = select_administrators_id.split(',');
				select_administrators_ids.splice(ld.inArray(remove_userid,select_administrators_ids),1);
				ld("#"+popupobj.divid+" [name=select_administrators_id]").val(select_administrators_ids.join(','));
				return false;
			});
		}
		//绑定允许“公海分配”的成员删除事件
		if(ld('#'+popupobj.divid+' [name=allow_user_div] ul.reader-bar-list .remove-h') != undefined){
			ld('#'+popupobj.divid+' [name=allow_user_div] ul.reader-bar-list .remove-h').unbind('click').click(function(){
				var remove_userid = ld(this).parent().attr('itemid');
				ld(this).parent().remove();
				var allow_user_ids = [];
				var allow_user_id = ld("#"+popupobj.divid+" [name=allow_user_id]").val();
				allow_user_ids = allow_user_id.split(',');
				allow_user_ids.splice(ld.inArray(remove_userid,allow_user_ids),1);
				ld("#"+popupobj.divid+" [name=allow_user_id]").val(allow_user_ids.join(','));
				return false;
			});
		}
		//绑定允许“转换公海”的成员删除事件
		if(ld('#'+popupobj.divid+' [name=transfer_user_div] ul.reader-bar-list .remove-h') != undefined){
			ld('#'+popupobj.divid+' [name=transfer_user_div] ul.reader-bar-list .remove-h').unbind('click').click(function(){
				var remove_userid = ld(this).parent().attr('itemid');
				ld(this).parent().remove();
				var transfer_user_ids = [];
				var transfer_user_id = ld("#"+popupobj.divid+" [name=transfer_user_id]").val();
				transfer_user_ids = transfer_user_id.split(',');
				transfer_user_ids.splice(ld.inArray(remove_userid,transfer_user_ids),1);
				ld("#"+popupobj.divid+" [name=transfer_user_id]").val(transfer_user_ids.join(','));
				return false;
			});
		}
		//公海客户参与回收，回收规则条件逻辑关系
		ld("#"+popupobj.divid+" [name=completeopt]").unbind('change').on('change',function(){
			if(ld(this).val() == 'and'){
				ld("#"+popupobj.divid+" [name=completeopt_and]").show();
				ld("#"+popupobj.divid+" [name=completeopt_or]").hide();
			}else{
				ld("#"+popupobj.divid+" [name=completeopt_and]").hide();
				ld("#"+popupobj.divid+" [name=completeopt_or]").show();
			}
		})
		//不允许领取公海未分配客户，只能由公海管理员分配=》 允许公海成员查看“公海未分配”列表
		if(ld("#"+popupobj.divid+" [name=allowget]").length>0){
			var allowgetobj = ld("#"+popupobj.divid+" [name=allowget]");
			allowgetobj.on('click',function(){
				if(ld("#"+popupobj.divid+" #poolmember_show_noallocate_li").length>0){
					if(allowgetobj.prop('checked') == true){
						ld("#"+popupobj.divid+" #poolmember_show_noallocate_li").css('display','');
					}
					else{
						ld("#"+popupobj.divid+" #poolmember_show_noallocate_li").css('display','none');
						ld("#"+popupobj.divid+" #poolmember_show_noallocate").prop('checked',false);
					}
				}
			});
		}
	}

	//自动回收规则设置
	this.changeRule = function(type,tabname,obj)
	{
		var selectindex=obj.selectedIndex;
		var selectvalue=obj.options[selectindex].value;
		if(selectvalue=='yes')
		{
			var spanname=type+'_'+tabname+'_span_recycle';
			var hidespanname=type+'_'+tabname+'_span_single';
		}
		else
		{
			var spanname=type+'_'+tabname+'_span_single';
			var hidespanname=type+'_'+tabname+'_span_recycle';
		}
		var popupobj=CrmPopup.getPopupObj("last");
		ld("#"+popupobj.divid+" [name="+spanname+"]").show();
		ld("#"+popupobj.divid+" [name="+hidespanname+"]").hide();
	}

	//公海管理员、允许"公海分配"的成员、允许"转换公海"的成员 事件绑定
	this.set_account_public_select_user_bind=function(){
		var popupobj=CrmPopup.getPopupObj("last");
		ld("#"+popupobj.divid+" [name=select_administrators],[name=select_administrators_div],[name=select_allow_user],[name=select_allow_user_div],[name=select_transfer_user],[name=select_administrators_div]").unbind('click').on('click',function(){
			var select_user_type = ld(this).attr('tag');
			var scopepopupobj;//自定义弹出层页面html，绑定事件
			var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
			var module = 'Leads';//edit:can 2020-12-28 43990: 多公海：新建公海选择公海管理员，只能选择管理员用户
			if(select_user_type == 'allow_user'){
				var select_id = ld("#"+popupobj.divid+" [name=allow_user_id]").val();
			}else if(select_user_type == 'transfer_user'){
				var select_id = ld("#"+popupobj.divid+" [name=transfer_user_id]").val();
			}else{
				var select_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
			}
			getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
				scopepopupobj =  new ScopePopupObj(module);
				scopepopupobj.popup_caption_value = popup_caption_value;//标题title
				getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
				   cls_ScopePopup.prop.popup_module = module;//模块
				   cls_ScopePopup.prop.popup_value = select_id;
				   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
				   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
					//重写确认按钮事件
					scopepopupobj.setEventBtnOk=function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
							if(empty(cls_ScopePopup.return_obj.return_id)){
								var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
								RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
								return false;
							}else{
								if(select_user_type == 'allow_user'){
									ld("#"+popupobj.divid+" [name=allow_user_id]").val(cls_ScopePopup.return_obj.return_id);
								}else if(select_user_type == 'transfer_user'){
									ld("#"+popupobj.divid+" [name=transfer_user_id]").val(cls_ScopePopup.return_obj.return_id);
								}else{
									ld("#"+popupobj.divid+" [name=select_administrators_id]").val(cls_ScopePopup.return_obj.return_id);
								}
									
								//ld("#"+popupobj.divid+" [name=select_administrators_name]").html(cls_ScopePopup.return_obj.return_name);
								var userid = cls_ScopePopup.return_obj.return_id.split(',');
								var username = cls_ScopePopup.return_obj.return_name.split(',');
								//每次确认之前，先情况之前记录
								ld('#'+popupobj.divid+' [name='+select_user_type+'_div] ul.reader-bar-list').empty();
								for(var i = 0; i < userid.length; i++){
									//添加新的li
									ld('#'+popupobj.divid+' [name='+select_user_type+'_div] ul.reader-bar-list').append('<li userid="'+userid[i]+'"><span class="item-name">'+username[i]+'</span><span class="remove-h">×</span></li>');
									//绑定删除事件
									ld('#'+popupobj.divid+' [name='+select_user_type+'_div] ul.reader-bar-list li[userid='+userid[i]+'] .remove-h').unbind('click').click(function(){
										var liuserid = ld(this).parent().attr('userid');
										ld('#'+popupobj.divid+' [name='+select_user_type+'_div] ul.reader-bar-list li[userid='+liuserid+']').remove();
										return false;
									});
								}
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
							}
                             that.showKehu001UserName();
						});
                       
					}
				});
			});
		});
	}

	//设置默认公海
	this.SetDefaultPool = function(obj){
		var popupobj=CrmPopup.getPopupObj("last");
		var pool_id = ld(obj).attr('pool_id');
		var cheakstatus = ld(obj).prop('checked');
		if(cheakstatus == true){//设为默认后取消原来的默认选择
			ld("#"+popupobj.divid).find('input[name=set_default_pool][pool_id!='+pool_id+']').prop('checked',false);
		}

		var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=createPublicAccountPool&setdefaultpool=yes';
		surl += '&cheakstatus='+cheakstatus+'&pool_id='+pool_id;
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				var confirm_str = arrJsPopLabel['SUCCESSFULLYMODIFIED'];
				MessagePopup.TipZero_success(confirm_str);
			}
		})
	}
	//公海拖动排序
	this.SortPublicPool = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		// var pool_id = ld(obj).attr('pool_id');
		var tableobj = ld("#"+popupobj.divid).find('[name=viewpublicaccount_table]');
		tableobj.find('tr').off('hover').hover(function(){
			tableobj.find('.ld-category-drag').hide();
			ld(this).find('.ld-category-drag').show();
		});
		tableobj.find('tr').off('mouseleave').mouseleave(function(){
			tableobj.find('.ld-category-drag').hide();
		});
		var dragobj = tableobj.find("tbody").get(0);
		Sortable.create(dragobj, {
			draggable:".ld-category-draggable",
			handle:".drag-handle",
			onEnd: function (evt){
				var pool_ids_str='';
				trobj = ld('table[name=viewpublicaccount_table]').find("tr.ld-category-draggable");
				ld.each(trobj,function(index,tmpobj){
					pool_id = ld(tmpobj).attr('pool_id');
					pool_ids_str += pool_id + ";";
				});
				if(pool_ids_str !=''){
					var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=createPublicAccountPool&sortpublicpool=yes';
					surl += '&pool_ids_str='+pool_ids_str;
					ldAjax(surl,'',function(data){
						if(data.code==1){
							DelProgressObjs();
							var tmparra=new Array();
							var tmpobj= new AfterUpdatePrevPopupObjContent(that.module,"",tmparra);
							var refreshlistmodules = new Array(that.module);
							tmpobj.eachrefreshlistbyModules(refreshlistmodules);
						}
					})
				}
			}
		});
		tooltip(tableobj.find('.tip-items-list'), {transition: true, time: 200});
	}
}
publicLeads.getInstance = function(){
    if(publicLeads.publicleadsobj == undefined){
        publicLeads.publicleadsobj = new publicLeads();
        
    }
    return publicLeads.publicleadsobj;
}