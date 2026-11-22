/*
*edit: duanjb
*date: 2024/07/17
*reason: 公海设置
*/
function cls_publicpool_set(module)
{
	var that = this;
	this.module = module;
	this.popupobj = '';
	this.fieldlabel_arr = []; //翻译数组
	this.public_set_arr = []; //公海基本设置
	this.admin_user = []; //公海管理员
	this.list_tab = []; //列表页签信息
	this.public_pool = []; //公海池信息
	this.language_type = ''; //语言类型
	this.common_recovey_rule = []; //普通客户回收条件
	this.divobj = '';
	this.commonaccount_role_limitaccount = [];//普通客户角色数量限制
	this.all_publicpool_role_limitcount = [];//公海总数量的角色数量限制
	this.refresh_after_save = 'no';
	this.poolNavbarlist = [];//公海页签数组
	this.navbarkey = 0;//公海页签数组
	this.beforeNavbarValue = '';//当前页签历史值
	this.navbarobj = null;//页签对象
	this.savetype = 'button';

	this.setbasicinfo = function (returndata) {
		this.fieldlabel_arr = returndata.fieldlabel_arr;
		this.public_set_arr = returndata.public_set_arr;
		this.base_poolinfo = returndata.base_poolinfo;
		this.public_limit_info = returndata.public_limit_info;
		this.limit_info = returndata.limit_info;
		this.admin_user = returndata.admin_user;
		this.list_tab = returndata.list_tab;
		this.public_pool = returndata.public_pool;
		this.language_type = returndata.language_type;
		this.common_recovey_rule = returndata.common_recovey_rule;
		this.commonaccount_role_limitaccount = returndata.commonaccount_role_limitaccount;
		this.all_publicpool_role_limitcount = returndata.all_publicpool_role_limitcount;
	}

	this.CreatePopup = function () {
		var cur_module = this.module;
		var surl = 'index.php?module='+cur_module+'&action='+cur_module+'Ajax&file=setPublicPoolConfig';
		var crmPopupobj = CrmPopup.load("","","","LdPopWidth1100px",cur_module,"","","","");
		crmPopupobj.prevshow();

		this.popupobj = crmPopupobj;
		this.divobj = ld('#'+crmPopupobj.divid);
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.SavePublicInfo,"","LdPopWidth1100px",cur_module,"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.createScrollDiv();

				that.setbasicinfo(data.result);
				var popupHtml = that.CreatePopupHtml();

				crmPopupobj.show(popupHtml);
				ld("#"+crmPopupobj.divid+"_scroll").css('height',crmPopupobj.getPopContentHeight()+'px');

				var publicpoolnavbarobj = ld('#'+crmPopupobj.divid+' #publicpoolnavbar');
				if(publicpoolnavbarobj.length > 0){
					var poolnavbardata = {
						NavBarSelKey : that.navbarkey,
						ShowAllItemInfo: true,
						WidthFixed : false,
						CssVarList: {
							NavBarItemMinWidth: '120px'
						},
						NavBarMoreDefaultText: arrJsPopLabel['MORE'],
						OnClick : function(evt){
							var navbarvalue = evt.NavBarItem.value;
							that.navbarkey = evt.NavBarItem.NavBarIndex;
							var beforeNavbarValue = that.getNavbaritemValue(that.poolNavbarlist[that.navbarkey].value);
							that.beforeNavbarValue = JSON.parse(JSON.stringify(beforeNavbarValue));
							ld('#'+crmPopupobj.divid+' .publicpool_navbarblock.navbarcur').removeClass('navbarcur');
							ld('#'+crmPopupobj.divid+' [name='+navbarvalue+']').addClass('navbarcur');
						},
						OnClickBefore: async function (evt) {
							var before = evt.lastNavBarItem.value;
							var after = evt.NavBarItem.value;
							if(before == after){
								return false;
							}
							var afterNavbarValue = JSON.parse(JSON.stringify(that.getNavbaritemValue(before)));
							var contraststatus = that.contrastNavnarValue(before,that.beforeNavbarValue,afterNavbarValue);
							return new Promise((resolve, reject) => {
								if(contraststatus === false){
									RemindsMsg("", "LdPopWidth400px", that.module, "yes", "yes", that.poolNavbarlist[that.navbarkey].label+arrJsPopLabel['pulicpoolchecksave']);
									//确定按钮
									ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
										that.savetype = 'navbar';
										that.SavePublicInfo();
										resolve();
									});
									//取消按钮
									ld('input[tagclick="msgConfirmCancel"]').unbind('click').on('click', function () {
										var navvalue = that.poolNavbarlist[that.navbarkey].value;
										var surl = 'index.php?module='+cur_module+'&action='+cur_module+'Ajax&file=setPublicPoolConfig';
										ldAjaxNoProgress(surl,"",function(data){
											if(data.code==1){
												that.setbasicinfo(data.result);
												var blockdivobjs = ld('#'+that.popupobj.divid+' [name='+navvalue+']');
												if(blockdivobjs.length > 0){
													ld.each(blockdivobjs,function (index,tmpobj) {
														var tmpid = ld(tmpobj).attr('id');
														var funcname = 'get_'+tmpid+'_html';
														ld(tmpobj).html(that[funcname]());
													});
												}
												that.setBindPopupEvent();
											}
										});
										resolve();
									});
								}
								else {
									resolve();
								}
							});
						}
					};
					that.poolNavbarlist = [
						{label:arrJsPopLabel['basepoolinfolabel'],value:"base_poolinfo"},
						{label:arrJsPopLabel['publicpoolinfolabel'],value:"public_pool_info"},
						{label:that.fieldlabel_arr['publiclimitcountinfolabel'],value:"public_limit_count_info"},
						{label:that.fieldlabel_arr['limitcountinfolabel'],value:"limit_count_info"},
						{label:arrJsPopLabel['listtabinfolabel'],value:"list_tab_info"}
					];
					AjaxJSPage('ld_NavBar','include/js/component/ld_NavBar.js');
					that.navbarobj = ld_NavBar.ShowNavBar(publicpoolnavbarobj.get(0),that.poolNavbarlist,poolnavbardata);

					var beforeNavbarValue = that.getNavbaritemValue(that.poolNavbarlist[that.navbarkey].value);
					that.beforeNavbarValue = JSON.parse(JSON.stringify(beforeNavbarValue));

				}

				// 帮助
				if(data.result.helpHtml && data.result.helpHtml!=""){
					ld('#'+crmPopupobj.divid + " #" + crmPopupobj.divid + '_head').find('.E_ptita').after(data.result.helpHtml);
				}

				that.setBindPopupEvent();
				crmPopupobj.setScrollDivMaxHeight();
				crmPopupobj.center();
			}
		})
	}

	//获取当前页签 对应数据值
	this.getNavbaritemValue = function (navbarvalue) {
		var popupobj=that.popupobj;
		switch (navbarvalue) {
			case 'base_poolinfo':
				return that.base_poolinfo;
			case 'public_pool_info':
				return that.get_publicpool_return_info();
			case 'public_limit_count_info':
				var role_public_limit_count_info = [];
				if(that.public_limit_info['public_limit_type'] == 'role'){
					var input_objs = ld("#"+popupobj.divid+" [name=public_role_count]");
					ld.each(input_objs,function () {
						role_public_limit_count_info.push({'profileid':ld(this).attr('roleid'),'limit_count':ld(this).val()})
					})
				}
				var tmpdata = {
					public_limit_info: that.public_limit_info,
					role_public_limit_count_info: role_public_limit_count_info
				};
				return tmpdata;
			case 'limit_count_info':
				var role_limit_count_info = [];
				if(that.limit_info['limit_type'] == 'role'){
					var input_objs = ld("#"+popupobj.divid+" [name=normal_role_count]");
					ld.each(input_objs,function () {
						role_limit_count_info.push({'profileid':ld(this).attr('roleid'),'limit_count':ld(this).val()})
					})
				}
				var tmpdata = {
					limit_info: that.limit_info,
					role_limit_count_info: role_limit_count_info,
					common_recovey_rule: that.get_commonrule_return_info()
				};
				return tmpdata;
			case "list_tab_info":
				return that.list_tab;
			default:
				return '';
		}
	}

	//对比页签切换时该页签中的参数是否发生修改
	this.contrastNavnarValue = function (navbarvalue,beforevalue,aftervalue) {
		switch (navbarvalue) {
			case 'base_poolinfo':
				for(let key in beforevalue){
					if(aftervalue[key]){
						if(beforevalue[key] !== aftervalue[key]){
							return false;
						}
					}
					else{
						return false;
					}

				}
				return true;
			case 'public_pool_info':
				if(beforevalue.length == aftervalue.length){
					for(let i = 0;i < beforevalue.length;i++){
						for(let key in beforevalue[i]){
							if(beforevalue[i][key] !== aftervalue[i][key]){
								return false;
							}
						}
					}
				}
				else{
					return false;
				}
				return true;
			case 'public_limit_count_info':
				for(let key in beforevalue.public_limit_info){
					if(beforevalue.public_limit_info[key] !== aftervalue.public_limit_info[key]){
						return false;
					}
				}
				if(beforevalue.role_public_limit_count_info.length == aftervalue.role_public_limit_count_info.length){
					for(let i = 0;i < beforevalue.role_public_limit_count_info.length;i++){
						for(let key in beforevalue.role_public_limit_count_info[i]){
							if(beforevalue.role_public_limit_count_info[i][key] !== aftervalue.role_public_limit_count_info[i][key]){
								return false;
							}
						}
					}
				}
				else{
					return false;
				}
				return true;
			case 'limit_count_info':
				for(let key in beforevalue.limit_info){
					if(beforevalue.limit_info[key] !== aftervalue.limit_info[key]){
						return false;
					}
				}
				if(beforevalue.role_limit_count_info.length == aftervalue.role_limit_count_info.length){
					for(let i = 0;i < beforevalue.role_limit_count_info.length;i++){
						for(let key in beforevalue.role_limit_count_info[i]){
							if(beforevalue.role_limit_count_info[i][key] !== aftervalue.role_limit_count_info[i][key]){
								return false;
							}
						}
					}
				}
				else{
					return false;
				}
				if(beforevalue.common_recovey_rule.length == aftervalue.common_recovey_rule.length){
					for(let i = 0; i < beforevalue.common_recovey_rule.length; i++){
						for(let key in beforevalue.common_recovey_rule[i]){
							if(beforevalue.common_recovey_rule[i][key] !== aftervalue.common_recovey_rule[i][key]){
								return false;
							}
						}
					}
				}
				else{
					return false;
				}
				return true;
			case "list_tab_info":
				if(beforevalue.length == aftervalue.length){
					var keyarr = ['id','zhlabel','enlabel','active','isdefault'];
					for(let i = 0;i < beforevalue.length; i++){
						for(let j = 0;j<keyarr.length;j++){
							if(beforevalue[i][keyarr[j]] !== aftervalue[i][keyarr[j]]){
								return false;
							}
						}
					}
				}
				else{
					return false;
				}
				return true;
			default:
				return true;
		}
	}

	this.SavePublicInfo = function () {
		var expre=/^[0-9]*[1-9][0-9]*$/;
		var param = {};
		var popupobj=that.popupobj;
		var base_pooinfo = that.base_poolinfo;
		var _status = base_pooinfo['status'];
		var show_account_rule = base_pooinfo['show_account_rule'];
		var input_objs = '';

		//普通客户数量上限
		var limit_type = that.limit_info['limit_type'];
		var limit_count = that.limit_info['limit_count'];
		var role_limit_count_info = [];
		if(limit_type == 'user'){
			if(!(expre.test(trim(limit_count)))){
				audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=limit_count]").attr('label')+arrJsPopLabel['CONTENTCANOTEMPTY']);
				ld("#"+popupobj.divid+" [name=limit_count]").focus();
				return false;
			}
		}else if(limit_type == 'role'){
			var input_objs = ld("#"+popupobj.divid+" [name=normal_role_count]");
			ld.each(input_objs,function () {
				role_limit_count_info.push({'profileid':ld(this).attr('roleid'),'limit_count':ld(this).val()})
			})
		}
		//公海客户数量上限
		var public_limit_type = that.public_limit_info['public_limit_type'];
		var public_limit_count = that.public_limit_info['public_limit_count'];
		var role_public_limit_count_info = [];
		if(public_limit_type == 'user'){
			if(!(expre.test(trim(public_limit_count)))){
				audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=public_limit_count]").attr('label')+arrJsPopLabel['CONTENTCANOTEMPTY']);
				ld("#"+popupobj.divid+" [name=public_limit_count]").focus();
				return false;
			}
		}else if(public_limit_type == 'role'){
			var input_objs = ld("#"+popupobj.divid+" [name=public_role_count]");
			ld.each(input_objs,function () {
				role_public_limit_count_info.push({'profileid':ld(this).attr('roleid'),'limit_count':ld(this).val()})
			})
		}
		//公海超级管理员设置
		var select_administrators_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
		if(select_administrators_id == '' && _status == 'yes'){
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['Pleasesettheadministratorsjspop1']);
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				ld("#"+popupobj.divid+" [name=select_administrators]").click();
			})
			return false;
		}
		var public_tab_count = 0;
		var normal_tab_cnt = 0;
		for (var i =0;i<that.list_tab.length;i++){
			if(that.list_tab[i]['active'] == 'yes'){
				if(that.list_tab[i]['fromtype'] == 'public'){
					public_tab_count ++;
				}else{
					normal_tab_cnt ++;
				}
			}
		}
		var confirm_str = that.fieldlabel_arr['ATLEASTONETAB'];
		var error = 'no';
		if(base_pooinfo['showpublicmodule'] == 'yes'){
			if(public_tab_count == 0 || normal_tab_cnt == 0){
				error = 'yes';
			}
		}else {
			if((public_tab_count+normal_tab_cnt) == 0){
				error = 'yes';
			}
		}
		if(error == 'yes'){
			audioRemindsMsg("","","","","",confirm_str);
			ld('#'+popupobj.divid+' #list_tab_set_table').focus();
			return false;
		}



		param['base_poolinfo'] = base_pooinfo; //基本信息 页签:基础设置

		param['public_pool_info'] = that.get_publicpool_return_info(); //公海池信息里的数据较多，没必要全部传输  页签:公海池管理

		param['public_limit_info'] = that.public_limit_info; // 页签:公海客户保有量
		if(role_public_limit_count_info.length >0){
			param['role_public_limit_count_info'] = role_public_limit_count_info; // 页签:公海客户保有量
		}else{
			param['role_public_limit_count_info'] = ''; // 页签:公海客户保有量
		}
		param['limit_info'] = that.limit_info; //普通客户保有量 页签:普通客户管理
		if(role_limit_count_info.length >0){
			param['role_limit_count_info'] = role_limit_count_info; //普通客户保有量 页签:普通客户管理
		}else{
			param['role_limit_count_info'] = ''; // 页签:公海客户保有量
		}

		param['common_recovey_rule'] = that.get_commonrule_return_info(); //回收方案里的数据较多，没必要全部传输   页签:普通客户管理

		param['list_tab_info'] = that.list_tab; //列表页签  页签:公海页签设置


		var url = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=savePublicPoolConfig';

		ldAjaxNoProgress(url,param,function (data) {
			if(that.savetype == 'button'){
				popupobj.CancelEvent();
			}
			that.savetype = 'button';

			//保存完成修改  当前页面历史值
			var beforeNavbarValue = that.getNavbaritemValue(that.poolNavbarlist[that.navbarkey].value);
			that.beforeNavbarValue = JSON.parse(JSON.stringify(beforeNavbarValue));

			MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
			var module = getUrlParam("pageto_module");
			//@edit:zhaosk @date:2024/08/08 @reason:后台设置引导页处显示管理看板弹窗，module做特殊处理
			if(module=='Settings') {
				return ;
			}

			if(that.refresh_after_save == 'yes'){
				var prev_popupobj=CrmPopup.getPopupObj("first");
			 
				var searchScope = '';
				if(ld("#"+prev_popupobj.divid+" [name=SmOwnerSearchScope]")!=null)
					searchScope= encodeURIComponent(ld("#"+prev_popupobj.divid+" [name=SmOwnerSearchScope]").val());

				var viewname = ld("#"+prev_popupobj.divid+' #viewname').val();
				var listview_page=new ListView_Page(that.module,"module="+that.module+"&action="+that.module+"Ajax&file=ListView&start=1&SearchScope="+searchScope+'&viewname='+viewname,"pagecontent1");
				listview_page.callback_fun=function()
				{
					prev_popupobj.listresizeobj.setReiszeTable_Init(that.module,'ajax');
					setContentHeight(that.module);//计算内容高度
					IsFrameElement();
				}
				listview_page.page();
			}
			if(!empty(LeftMenu_functionobj)){
				LeftMenu_functionobj.LeftMenu_flesh();
			}
			return false;
		})
	}

	//生成界面内容
	this.CreatePopupHtml = function () {
		var all_html = '';
		var div_style = '';
		if(this.base_poolinfo['status'] == 'no'){
			//div_style = 'style="display:none"';
			div_style = 'poolstatusno';
		}

		//头部提示
		all_html += '<div class="publicpooltoptip">' +
			'<div class="publicpooltoptipimg"></div><span style="font-size: 14px;">'+this.fieldlabel_arr['Createandmaintainmultiplehighseaspool']+'</span>' +
			'</div>';

		//页签html
		all_html += '<div id="publicpoolnavbar" class="publicpoolnavbar"></div>';

		// 公海基本设置区块
		var public_set_html = '<div id="public_set" name="base_poolinfo" class="publicpool_navbarblock navbarcur">' + this.get_public_set_html() + '</div>';
		all_html += public_set_html;
		// 设置公海管理员
		var admin_set_thml = '<div id="basic_pool_admin" class="publicpool_navbarblock navbarcur '+div_style+' " name="base_poolinfo" tag="changestatus">' + this.get_basic_pool_admin_html()+ '</div>';
		all_html += admin_set_thml;
		// 公海池信息
		var basic_pool_html = '<div id="basic_pool_info" class="publicpool_navbarblock '+div_style+' " name="public_pool_info" tag="changestatus">' + this.get_basic_pool_info_html()+ '</div>';
		all_html += basic_pool_html;
		//公海客户保有量
		var basic_pool_html = '<div id="public_limit_count_info" class="publicpool_navbarblock '+div_style+' " name="public_limit_count_info" tag="changestatus">' + this.get_public_limit_count_info_html()+ '</div>';
		all_html += basic_pool_html;
		//普通客户数量上限
		var normal_limit_html = '<div id="normal_limit" class="publicpool_navbarblock" name="limit_count_info">' + this.get_normal_limit_html()+ '</div>';
		all_html += normal_limit_html;
		//客户回收方案
		var normal_rule_html = '<div id="normal_rule" class="publicpool_navbarblock '+div_style+' " name="limit_count_info" tag="changestatus">' + this.get_normal_rule_html()+ '</div>';
		all_html += normal_rule_html;
		// 列表页签信息设置
		var basic_list_html = '<div id="basic_list_tab" class="publicpool_navbarblock '+div_style+' " name="list_tab_info" tag="changestatus">' + this.get_basic_list_tab_html()+ '</div>'
		all_html += basic_list_html;

		return all_html;
	}
	// 公海设置区块
	this.get_public_set_html = function(){

		var public_btn_html = '';
		var i = 0;
		var tmp_info = [];
		var cnt = this.public_set_arr.length;
		var checked_str = '';
		var div_style = '';


		for (i = 0;i<cnt;i++){
			tmp_info = this.public_set_arr[i];
			if(this.base_poolinfo[tmp_info['key']] == 'yes'){
				checked_str = 'checked';
			}else{
				checked_str = '';
			}
			if(this.base_poolinfo['status'] == 'no' && tmp_info['key'] != 'status'){
				div_style = 'poolstatusno';
			}else{
				div_style = '';
			}
			public_btn_html += '<tr class="ld-form-item '+div_style+' " tag="'+tmp_info['tag']+'">';
			public_btn_html += '<td class="ld-form-item-label">' +
				'<label for="'+tmp_info['key']+'">'+this.fieldlabel_arr[tmp_info['labelbol']]+'</label>' +
				'</td>' +
				'<td class="ld-form-item-content">' +
				'<input class="second_switch" type="checkbox" name="'+tmp_info['key']+'" id="'+tmp_info['key']+'" '+checked_str+'  >' +
				'</td>';
			public_btn_html += '</tr>';
		}

		var public_set_html = '<div style="padding: 20px 24px 10px;">' +
			'<div class="ld-pop-contnet-title-items">' +
			'<div class="ld-pop-contnet-title-item">'+this.fieldlabel_arr['PUBLICCUSTOMERSET']+'</div>' +
			'</div>' +
			'</div>' +
			'<table class="ld-public-content-small" style="padding-top: 0;padding-bottom: 0;" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tbody>' +
			public_btn_html +
			'</tbody>' +
			'</table>';

		return public_set_html;
	}
	// 公海管理员设置区块
	this.get_basic_pool_admin_html = function(){
		var admin_set_thml = '';

		var user_label_html = '';
		ld.each(this.admin_user,function (tmp_key,tmp_value) {
			user_label_html += '<li itemid="'+tmp_key+'" emptype="p"><span class="item-name">'+tmp_value+'</span><span class="remove-h">×</span></li>';
		})

		admin_set_thml += '<div style="padding: 20px 24px 10px;">' +
			'<div class="ld-pop-contnet-title-items">' +
			'<div class="ld-pop-contnet-title-item">'+this.fieldlabel_arr['Highseassuperadministratorsettings']+'</div>' +
			'</div>' +
			'</div>' +
			'<table class="ld-public-content-small" style="padding-top: 0;" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tbody>' +
			'<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">'+this.fieldlabel_arr['Pleasesettheadministratorsjspop1']+'</td>' +
			'<td class="ld-form-item-content">' +
			'<input type="hidden" name="select_administrators_id" value="'+this.base_poolinfo['administrators']+'" />' +
			'<div class="pubclear pubEnd" id="sendLogFoot" style="margin-top: -10px !important;">' +
			'<div class="CCrange selectbar" name="select_administrators" tag="ccrange" style="width: 100%;" >' +
			'<ul class="reader-bar-list">' + user_label_html +
			'</ul>' +
			//'<span class="input-tip"><a href="javascript:void" name="select_administrators" title="'+this.fieldlabel_arr['Pleasesettheadministratorsjspop1']+'" class="choosepublicadmin" style="margin-left: 10px;white-space:nowrap;"> '+this.fieldlabel_arr['Pleasesettheadministratorsjspop1']+'</a></span>' +
			'<input class="input-field ui-hide" type="text" autocomplete="off" value="">' +
			// '<span class="show-select-panel" name="select_administrators_div"><span class="icon-homeimg icon-workp"></span></span>' +
			'<a class="ld-text-arrow-before" style="height: 40px;" href="javascript:;" draggable="false"><span class="ld-text-arrow" style="margin: 9px auto;"></span></a>' +
			'</div>' +
			'</div>' +
			'</td>' +
			'</tr>' +
			'</tbody>' +
			'</table>';
		return admin_set_thml;
	}
	//公海池信息设置区块
	this.get_basic_pool_info_html = function () {
		var public_pool = this.public_pool;

		var tmp_info = [];
		var i = 0;
		var public_pool_html = '';
		var all_pool_html = '';
		var tmp_content = '';

		var th_label_content = '';
		th_label_content += '<thead><tr>';
		//中文标签
		th_label_content += '<th style="width:35%;">' + this.fieldlabel_arr['Name(ZH)'] + '</th>';
		//英文标签
		th_label_content += '<th style="width:35%;">' + this.fieldlabel_arr['Name(EN)'] + '</th>';
		//是否启用
		th_label_content += '<th style="width:10%;">' + this.fieldlabel_arr['WHETHERTOENABLE'] + '</th>';
		//默认页签
		th_label_content += '<th style="width:10%;">' + this.fieldlabel_arr['Set_Default'] + '</th>';
		//操作
		th_label_content += '<th style="width: 120px;">' + this.fieldlabel_arr['OPERATING'] + '</th>';
		th_label_content += '</tr></thead>';

		all_pool_html += '<div class="ld-pop-container ld-table-container ld-table-container-lines" style="padding-top: 6px;">' +
			'<div style="width: 100%; overflow-y: auto;" id="dv_scroll">' +
			'<table class="" id="public_pool_table" cellspacing="0" cellpadding="0" border="0">';
		all_pool_html += th_label_content;
		var tmp_class = 'lvtColData';
		for (i = 0; i < public_pool.length; i++) {
			tmp_info = public_pool[i];
			tmp_content = '';
			if (i % 2 == 1) {
				tmp_class = 'lvtColDataBj';
			} else {
				tmp_class = 'lvtColData';
			}
			tmp_content += '<tr tag ="public_pool_set" pool_id="' + tmp_info['id'] + '" class="' + tmp_class + '" >';
			//中文标签
			tmp_content += '<td><span>' + tmp_info['zh_name'] + '</span></td>';
			//英文标签
			tmp_content += '<td><span>' + tmp_info['en_name'] + '</span></td>';
			//是否启用
			tmp_info['active_result'] = tmp_info['active'] == 'yes' ? 'checked' : '';
			tmp_content += '<td><input class="second_switch" type="checkbox" name="active" ' + tmp_info['active_result'] + '  pool_id="' + tmp_info['id'] + '" ></td>';
			//默认页签
			tmp_info['isdefault_result'] = tmp_info['default_pool'] == 'yes' ? 'checked' : '';
			tmp_content += '<td><input class="second_switch" type="checkbox" name="default_pool"  ' + tmp_info['isdefault_result'] + ' pool_id="' + tmp_info['id'] + '" ></td>';
			//操作
			tmp_content += '<td ><div class="pool_btn_flex" style="display: flex;">' +
				'<a name="public_pool_edit" tag="edit" pool_id="' + tmp_info['id'] + '" style="flex: unset;"><i class="ld-fonticon ld-fonticon-edit"></i></a>';
			if(tmp_info['id'] > 1){
				tmp_content += '<a name="public_pool_delete" style="margin-left: 10px;flex: unset;" tag="delete" pool_id="' + tmp_info['id'] + '"  ><i class="ld-fonticon ld-fonticon-del"></i></a>';
			}
			tmp_content += '<a data-tip="' + arrJsPopLabel['DRAGTOSORT'] + '" class="ld-category-icon ld-category-drag drag-handle" style="flex: unset;margin-left: 10px;"></a>';
			tmp_content + '</div></td >';

			tmp_content += '</tr>';

			all_pool_html += tmp_content;
		}
		all_pool_html += '<tr>' +
			'<td colspan="5">' +
			'<div name="public_pool_edit" tag="create" pool_id="0" class="ld-btn-icontext-item">' +
			'<i class="ld-fonticon ld-fonticon-add" style="color: var(--ld-font-link-color);"></i>' +
			'<span style="color: var(--ld-font-link-color);">'+this.fieldlabel_arr['createpublicaccountpool']+'</span>' +
			'</div>' +
			'</td>' +
			'</tr>';
		all_pool_html += '</table></div></div>';

		public_pool_html += this.gettablecontent(this.fieldlabel_arr['HIGHSEASPOOLMANAGEMENT'],all_pool_html);

		return public_pool_html;
	}
	//客户模块列表页签设置区块
	this.get_basic_list_tab_html = function () {
		var showpublicmodule = this.base_poolinfo['showpublicmodule'];

		var list_tab = this.list_tab;
		var normal_content = '';
		var public_content = '';
		var tmp_content = '';
		var tmp_info = [];
		var i = 0;
		//列头
		var th_label_content = '';
		th_label_content += '<thead><tr >';
		//中文标签
		th_label_content += '<th style="width:20%;">'+this.fieldlabel_arr['ZHPARENTMENUNMAE']+'</th>';
		//英文标签
		th_label_content += '<th style="width:25%;">'+this.fieldlabel_arr['ENPARENTMENUNMAE']+'</th>';
		//描述
		th_label_content += '<th style="width:25%;">'+this.fieldlabel_arr['TABDESCRIPTION']+'</th>';
		//是否启用
		th_label_content += '<th style="width:10%;">'+this.fieldlabel_arr['WHETHERTOENABLE']+'</th>';
		//默认页签
		th_label_content += '<th style="width:10%;">'+this.fieldlabel_arr['DEFAULTTAB']+'</th>';
		//操作
		th_label_content += '<th style="width: 120px;">'+this.fieldlabel_arr['OPERATING']+'</th>';
		th_label_content += '</tr></thead>';

		normal_content += '<div class="ld-pop-container ld-table-container ld-table-container-lines" style="padding-top: 6px;">' +
			'<table class="" id="list_tab_set_table" cellspacing="0" cellpadding="0" border="0">';
		normal_content += th_label_content;

		public_content += '<div class="ld-pop-container ld-table-container ld-table-container-lines" style="padding-top: 6px;">' +
			'<table class="" id="public_list_tab_set_table" cellspacing="0" cellpadding="0" border="0">';
		public_content += th_label_content;
		var tmp_class = '';
		var tag = '';
		var have_defualt = 'no';
		for (i = 0;i<list_tab.length;i++){
			tmp_info = list_tab[i];
			tmp_content = '';
			if(showpublicmodule == 'yes' && tmp_info['fromtype'] == 'public'){
				tmp_class += ' public_list_tab_set';
			}else{
				tmp_class += ' list_tab_set';
			}
			if(showpublicmodule == 'yes' && tmp_info['fromtype'] == 'public'){
				tag = 'public_list_tab_set';
			}else{
				tag = 'list_tab_set';
			}

			tmp_content += '<tr tag ="'+tag+'" tab_id="'+tmp_info['id']+'" class="'+tmp_class+'" >';
			//中文标签
			tmp_content += '<td><span name="span_zhlabel" >'+tmp_info['zhlabel']+'</span><input class="ld-input-inner" tab_id="'+tmp_info['id']+'" style="display: none;margin-left: -9px;" name="zhlabel" value="'+tmp_info['zhlabel']+'" /></td>';
			//英文标签
			tmp_content += '<td><span name="span_enlabel" >'+tmp_info['enlabel']+'</span><input class="ld-input-inner" tab_id="'+tmp_info['id']+'" style="display: none;margin-left: -9px;" name="enlabel" value="'+tmp_info['enlabel']+'" /></td>';
			//描述
			tmp_content += '<td><span name="span_description" >'+tmp_info['description']+'</span><input class="ld-input-inner" tab_id="'+tmp_info['id']+'" style="display: none;margin-left: -9px;" name="description" value="'+tmp_info['description']+'" /></td>';
			//是否启用
			tmp_info['active_result'] = tmp_info['active']=='yes'?'checked':'';
			tmp_content += '<td><input class="second_switch" type="checkbox" name="active" '+tmp_info['active_result']+' tab_id="'+tmp_info['id']+'" ></td>';
			//默认页签
			if(have_defualt == 'yes'){
				tmp_info['isdefault']='no';
			}
			if(tmp_info['isdefault'] == 'yes'){
				have_defualt='yes';
			}
			tmp_info['isdefault_result'] = tmp_info['isdefault']=='yes'?'checked':'';
			tmp_content += '<td><input class="second_switch" type="checkbox" name="isdefault"  '+tmp_info['isdefault_result']+' tab_id="'+tmp_info['id']+'" ></td>';
			//操作
			tmp_content += '<td ><div class="pool_btn_flex" style="display: flex;">'+
				'<a name="list_tab_edit" tab_id="'+tmp_info['id']+'" style="flex: unset;"><i class="ld-fonticon ld-fonticon-edit"></i></a>'+
				'<a name="list_tab_edit_other"></a>'+
				'<a name="list_tab_edit_save" tab_id="'+tmp_info['id']+'" style="flex: unset;display: none;" >'+arrJsPopLabel['SAVE']+'</a>'+
				'<a class="padL8" name="list_tab_edit_cancel" tab_id="'+tmp_info['id']+'" style="flex: unset;display: none;" >'+arrJsPopLabel['CANCEL']+'</a>'+
				'<a align="right" class="sort-tip-items ld-category-icon ld-category-drag drag-handle" data-tip="'+arrJsPopLabel['DRAGTOSORT']+'" data-direction="right" data-type="position" style="float: right; cursor: move;margin-left: 10px;"></a>'+
				'</div></td>';
			tmp_content += '</tr>';

			if(showpublicmodule == 'yes' && tmp_info['fromtype'] == 'public'){
				public_content += tmp_content;
			}else {
				normal_content += tmp_content;
			}
		}
		normal_content += '</table></div>';
		public_content += '</table></div>';

		var list_tab_html = '';

		if(showpublicmodule == 'yes'){
			list_tab_html += this.gettablecontent(this.fieldlabel_arr['CUSTOMERLISTTABSET'],normal_content);
			list_tab_html += this.gettablecontent(this.fieldlabel_arr['SEACUSTOMERLISTTABSET'],public_content);
		}else {
			list_tab_html += this.gettablecontent(this.fieldlabel_arr['CUSTOMERLISTTABSET'],normal_content);
		}

		return list_tab_html;
	}

	this.get_public_limit_count_info_html = function () {
		// 公海总数量控制
		var public_limit_html = '';
		var public_conent = '';
		var limit_type_arr = this.get_limit_type_arr();
		var i = 0;
		var limit_type_html = '';
		var public_limit_type = this.public_limit_info['public_limit_type'];

		for (i =0;i<limit_type_arr.length;i++){
			limit_type_html += '<option value="'+limit_type_arr[i]['key']+'" '+(public_limit_type==limit_type_arr[i]['key']?'selected':'')+' >'+limit_type_arr[i]['label']+'</option>';
		}

		public_conent += '<table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">'+this.fieldlabel_arr['UPPERLIMITOFALLOCATED']+'</td>' +
			'<td class="ld-form-item-content">' +
			'<select id="public_limit_type" class="ld-select-inner" style="width: auto;margin: auto 10px;" >' + limit_type_html +
			'</select>' +
			'<input label="'+this.fieldlabel_arr['UPPERLIMITOFALLOCATED']+'" id="public_limit_count" class="ld-input-inner" style="width: 100px;'+(public_limit_type=='user'?'':'display:none;')+' " value="'+this.public_limit_info['public_limit_count']+'" />' +
			'</td>' +
			'</tr>' +
			'</table>';
		public_conent += '<div id="public_role_limit_count" class="ld-pop-container ld-table-container ld-table-container-lines" style="'+(public_limit_type=='role'?'':'display:none;')+'padding-top: 0;" >' +
			'<table class="" cellspacing="0" cellpadding="0" border="0">';
		public_conent += '<thead><tr>' +
			'<th width="50%" title="'+this.fieldlabel_arr['PROFILES']+'">'+this.fieldlabel_arr['PROFILES']+'</th>\n' +
			'<th width="50%" title="'+this.fieldlabel_arr['Themaximumnumberofhighseascustomers']+'">'+this.fieldlabel_arr['Themaximumnumberofhighseascustomers']+'</th>' +
			'</tr></thead>';

		i = 0;
		var tmp_class = '';
		ld.each(this.all_publicpool_role_limitcount,function (tmp_profileid,tmp_info) {
			public_conent += '<tr bgcolor="white" class="'+tmp_class+'">\n' +
				'<td nowrap=""><span title="'+tmp_info['role_name']+'">'+tmp_info['role_name']+'</span></td>\n' +
				'<td>\n' +
				'<input name="public_role_count" roleid="'+tmp_profileid+'" class="ld-input-inner" style="width:150px;float:left;" type="text" value="'+tmp_info['limit_count']+'" maxlength="100">\n' +
				'</td>\n' +
				'</tr>';
			i ++;
		})

		public_conent += '</table></div>';

		return public_conent;
	}

	this.gettablecontent = function (label,content) {
		var table_content = '';
		table_content += '<div style="padding: 20px 24px 10px;">' +
			'<div class="ld-pop-contnet-title-items">' +
			'<div class="ld-pop-contnet-title-item">'+label+'</div>' +
			'</div>' +
			'</div>';
		table_content += content;
		return table_content;
	}

	this.get_limit_type_arr = function () {
		var limit_type_arr = [];
		limit_type_arr.push({'key':'unlimit','label':this.fieldlabel_arr['NOLIMITS']});
		limit_type_arr.push({'key':'user','label':this.fieldlabel_arr['ACCORDINGTOTHEUSEREACH']});
		limit_type_arr.push({'key':'role','label':this.fieldlabel_arr['Accordingtotherolcontrol']});
		return limit_type_arr;
	}

	this.get_normal_limit_html = function () {
		var normal_limit_html = '';
		var normal_conent = '';
		var limit_type_arr = this.get_limit_type_arr();
		var i = 0;
		var limit_type_html = '';
		var limit_type = this.limit_info['limit_type'];

		for (i =0;i<limit_type_arr.length;i++){
			limit_type_html += '<option value="'+limit_type_arr[i]['key']+'" '+(limit_type==limit_type_arr[i]['key']?'selected':'')+' >'+limit_type_arr[i]['label']+'</option>';
		}

		normal_conent += '<table class="ld-public-content-small" style="padding-top: 0;padding-bottom: 8px;" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">'+this.fieldlabel_arr['MAXIMUMREGULARCUSTOMERS']+'</td>' +
			'<td class="ld-form-item-content">' +
			'<select id="limit_type" class="ld-select-inner" style="width: auto;margin: auto 10px;" >' + limit_type_html +
			'</select>' +
			'<input id="limit_count" name="limit_count" label="'+this.fieldlabel_arr['MAXIMUMREGULARCUSTOMERS']+'" class="ld-input-inner" style="width: 100px;'+(limit_type=='user'?'':'display:none;')+' " value="'+(empty(this.limit_info['limit_count'])?'':this.limit_info['limit_count'])+'" />' +
			'</td>' +
			'</tr>' +
			'</table>';
		normal_conent += '<div id="normal_role_limit_count" class="ld-pop-container ld-table-container ld-table-container-lines" style="'+(limit_type=='role'?'':'display:none;')+'padding-top: 12px;padding-bottom: 8px;" >' +
			'<table class="" border="0" cellspacing="0" cellpadding="0" width="100%">';
		normal_conent += '<thead><tr>' +
			'<th width="50%" title="'+this.fieldlabel_arr['PROFILES']+'">'+this.fieldlabel_arr['PROFILES']+'</th>' +
			'<th width="50%" title="'+this.fieldlabel_arr['Themaximumnumberofcustomers']+'">'+this.fieldlabel_arr['Themaximumnumberofcustomers']+'</th>' +
			'</tr></thead>';

		i = 0;
		var tmp_class = '';
		ld.each(this.commonaccount_role_limitaccount,function (tmp_profileid,tmp_info) {
			normal_conent += '<tr bgcolor="white" class="'+tmp_class+'">' +
				'<td nowrap=""><span title="'+tmp_info['role_name']+'">'+tmp_info['role_name']+'</span></td>\n' +
				'<td>\n' +
				'<input name="normal_role_count" roleid="'+tmp_profileid+'" class="ld-input-inner" style="width:150px;float:left;" type="text" value="'+tmp_info['limit_count']+'" maxlength="100">\n' +
				'</td>\n' +
				'</tr>';
			i ++;
		})

		normal_conent += '</table></div>';


		normal_limit_html += this.gettablecontent(this.fieldlabel_arr['MAXIMUMREGULARCUSTOMERS'],normal_conent);
		return normal_limit_html;
	}

	this.get_normal_rule_html = function () {
		var common_recovey_rule = this.common_recovey_rule;

		var tmp_info = [];
		var i = 0;
		var normalrule_content = '';
		var all_normalrule_html = '';
		var tmp_content = '';

		var th_label_content = '';
		th_label_content += '<thead><tr >';
		//回收条件
		th_label_content += '<th style="width:5%;">#</th>';
		//回收条件
		th_label_content += '<th style="width:23%;">'+this.fieldlabel_arr['recoveryconditions']+'</th>';
		//回收规则
		th_label_content += '<th style="width:28%;">'+this.fieldlabel_arr['recyclingrules']+'</th>';
		//回收到公海
		th_label_content += '<th style="width:14%;">'+this.fieldlabel_arr['createecyclingscheme']+'</th>';
		// 方案说明
		th_label_content += '<th style="width:10%;">'+this.fieldlabel_arr['SCHEMEDESCRIPTION']+'</th>';
		//是否启用
		th_label_content += '<th style="width:10%;">'+this.fieldlabel_arr['WHETHERTOENABLE']+'</th>';
		//操作
		th_label_content += '<th style="width: 120px;">'+this.fieldlabel_arr['OPERATING']+'</th>';
		th_label_content += '</tr></thead>';
		//是否启用普通客户回收规则按钮
		var show_account_rule = this.base_poolinfo['show_account_rule'];
		normalrule_content += '<table class="ld-public-content-small" style="padding-top: 0;" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">'+this.fieldlabel_arr['Enablecommoncustomerautomaticreclaimrules']+'</td>' +
			'<td class="ld-form-item-content">' +
			'<input class="second_switch" type="checkbox" name="show_account_rule" id="show_account_rule" '+(show_account_rule=='yes'?'checked':'')+' >' +
			'</td>' +
			'</tr>' +
			'</table>';

		normalrule_content += '<div class="ld-pop-container ld-table-container ld-table-container-lines" style="padding-top: 0;">' +
			'<table id="normal_rule_table" class="" style="'+(show_account_rule=='yes'?'':'display:none;')+'" cellspacing="0" cellpadding="0" border="0">';
		normalrule_content += th_label_content;
		var tmp_class = '';
		var rule_label = '';
		for (i = 0;i<common_recovey_rule.length;i++){
			tmp_info = common_recovey_rule[i];
			tmp_content = '';

			tmp_content += '<tr tag ="normal_rule_set" class="'+tmp_class+'" programmeid="'+tmp_info['programmeid']+'" >';
			//编号
			tmp_content += '<td name="seq_no">'+(i+1)+'</td>';
			//回收条件
			tmp_content += '<td data-tip="'+tmp_info['advf_label']+'" onmouseenter="tooltip.bind(this)" >'+tmp_info['advf_label']+'</td>';
			//回收规则
			rule_label = this.get_rule_label(tmp_info.rule_arr);
			tmp_content += '<td data-tip="'+rule_label+'" onmouseenter="tooltip.bind(this)" >'+rule_label+'</td>';
			//回收到公海
			tmp_content += '<td>'+this.getPoolnameByid(tmp_info['pool_id'])+'</td>';
			//方案说明
			tmp_content += '<td>'+tmp_info['description']+'</td>';
			//是否启用
			tmp_info['active_result'] = tmp_info['active']=='yes'?'checked':'';
			tmp_content += '<td><input class="second_switch" type="checkbox" name="active" '+tmp_info['active_result']+' programmeid="'+tmp_info['programmeid']+'" ></td>';
			//操作
			tmp_content += '<td ><div class="pool_btn_flex" style="display: flex;">'+
				'<a name="normal_rule_edit" programmeid="'+tmp_info['programmeid']+'" style="flex: unset;"><i class="ld-fonticon ld-fonticon-edit"></i></a>'+
				'<a name="normal_rule_delete" style="margin-left: 10px;" programmeid="'+tmp_info['programmeid']+'" style="flex: unset;"><i class="ld-fonticon ld-fonticon-del"></i></a>'+
				'<a data-tip="'+arrJsPopLabel['DRAGTOSORT']+'" class="ld-category-icon ld-category-drag drag-handle" style="flex: unset;margin-left: 10px;"></a>'
			tmp_content + '</div></td >';

			tmp_content += '</tr>';

			normalrule_content += tmp_content;
		}
		normalrule_content += '<tr>' +
			'<td colspan="7">' +
			'<div name="normal_rule_create" tag="create" pool_id="0" class="ld-btn-icontext-item">' +
			'<i class="ld-fonticon ld-fonticon-add" style="color: var(--ld-font-link-color);"></i>' +
			'<span style="color: var(--ld-font-link-color);">'+this.fieldlabel_arr['addrulecomments']+'</span>' +
			'</div>' +
			'</td>' +
			'</tr>';
		normalrule_content += '</table></div>';

		all_normalrule_html += this.gettablecontent(this.fieldlabel_arr['REGULARCUSTOMERSRECYCLINGSCHEME'],normalrule_content);

		return all_normalrule_html;
	}

	this.getPoolnameByid = function (poolid) {
		var public_pool = this.public_pool;
		var i = 0;
		var poolname = '';
		for (i = 0;i<public_pool.length;i++){
			if(public_pool[i]['id'] == poolid){
				if(this.language_type == 'zh'){
					poolname = public_pool[i]['zh_name'];
				}else{
					poolname = public_pool[i]['en_name'];
				}
				break;
			}
		}
		return poolname;
	}

	this.setBindPopupEvent = function () {
		//绑定按钮点击事件
		var popupobj = this.popupobj;
		var btn_key_arr = ['status','showpublicmodule','is_commonaccount_create','limit_type','limit_count','public_limit_type','public_limit_count','show_account_rule'];
		var i = 0;
		for (i=0;i<btn_key_arr.length;i++){
			this.divobj.find('#'+btn_key_arr[i]).on('change',function () {
				that.changefun(this);
			})
		}

		//绑定选择公海管理员事件
		this.set_account_public_select_user_bind();
		//客户列表页签按钮点击事件
		this.set_list_tab_event();
		//公海列表按钮点击事件
		this.set_public_pool_event();
		//客户回收规则点击事件
		this.set_normal_rule_event();
	}

	this.changefun = function (obj) {
		var cur_obj = ld(obj);
		var cur_id = ld(obj).prop('id');
		var cur_type = ld(obj).prop('type')
		var cur_value = '';

		if(cur_type == 'checkbox'){
			if(cur_id == 'status'){
				cur_value = cur_obj.prop('checked')?'yes':'no';
			}else{
				cur_value = cur_obj.prop('checked')?'yes':'no';
			}
		}else{
			cur_value = cur_obj.val();
		}
		if(cur_id == 'public_limit_type' || cur_id == 'public_limit_count'){
			this.public_limit_info[cur_id] = cur_value;
		}
		else if(cur_id == 'limit_type' || cur_id == 'limit_count'){
			this.limit_info[cur_id] = cur_value;
		}
		else{
			this.base_poolinfo[cur_id] = cur_value;
		}


		if(cur_id == 'status'){
			if(cur_value == 'yes'){
				this.divobj.find('[tag=changestatus]').removeClass('poolstatusno');
			}else{
				this.divobj.find('[tag=changestatus]').addClass('poolstatusno');
			}
			this.popupobj.center();
		}else if(cur_id == 'showpublicmodule'){
			var list_tab_content = this.get_basic_list_tab_html();
			this.divobj.find('#basic_list_tab').html(list_tab_content);
			this.set_list_tab_event();
		}else if(cur_id == 'limit_type'){
			cur_obj.blur();
			if(cur_value == 'role'){
				this.divobj.find('#normal_role_limit_count').show();
				this.divobj.find('#limit_count').hide();
			}else if(cur_value == 'user'){
				this.divobj.find('#normal_role_limit_count').hide();
				this.divobj.find('#limit_count').show();
			}else {
				this.divobj.find('#normal_role_limit_count').hide();
				this.divobj.find('#limit_count').hide();
			}
		}else if(cur_id == 'public_limit_type'){
			cur_obj.blur();
			if(cur_value == 'role'){
				this.divobj.find('#public_role_limit_count').show();
				this.divobj.find('#public_limit_count').hide();
			}else if(cur_value == 'user'){
				this.divobj.find('#public_role_limit_count').hide();
				this.divobj.find('#public_limit_count').show();
			}else {
				this.divobj.find('#public_role_limit_count').hide();
				this.divobj.find('#public_limit_count').hide();
			}
		}else if (cur_id == 'show_account_rule'){
			if(cur_value == 'yes'){
				this.divobj.find('#normal_rule_table').show();
				this.divobj.find('[name=normal_rule_create]').show();
			}else{
				this.divobj.find('#normal_rule_table').hide();
				this.divobj.find('[name=normal_rule_create]').hide();
			}
		}

	}

	//公海超级管理员
	this.set_account_public_select_user_bind=function(){
		var popupobj=this.popupobj;

		//绑定公海超级管理员删除事件
		if(ld('#'+popupobj.divid+' ul.reader-bar-list .remove-h') != undefined){
			ld('#'+popupobj.divid+' ul.reader-bar-list .remove-h').unbind('click').click(function(){
				var remove_userid = ld(this).parent().attr('itemid');
				ld(this).parent().remove();
				var select_administrators_ids = [];
				var select_administrators_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
				select_administrators_ids = select_administrators_id.split(',');
				select_administrators_ids.splice(ld.inArray(remove_userid,select_administrators_ids),1);
				ld("#"+popupobj.divid+" [name=select_administrators_id]").val(select_administrators_ids.join(','));
				that.base_poolinfo['administrators'] = select_administrators_ids.join(',');
				return false;
			});
		}

		ld("#"+popupobj.divid+" [name=select_administrators],[name=select_administrators_div]").unbind('click').on('click',function(){
			var scopepopupobj;//自定义弹出层页面html，绑定事件
			var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
			var module = that.module;
			var select_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
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
								// RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
								MessagePopup.TipOne_warning(confirm_str);
								return false;
							}else{
								ld("#"+popupobj.divid+" [name=select_administrators_id]").val(cls_ScopePopup.return_obj.return_id);
								ld("#"+popupobj.divid+" [name=select_administrators_name]").html(cls_ScopePopup.return_obj.return_name);
								that.base_poolinfo['administrators'] = cls_ScopePopup.return_obj.return_id;
								var userid = cls_ScopePopup.return_obj.return_id.split(',');
								var username = cls_ScopePopup.return_obj.return_name.split(',');
								//每次确认之前，先情况之前记录
								ld('#'+popupobj.divid+' ul.reader-bar-list').empty();
								for(var i = 0; i < userid.length; i++){
									//添加新的li
									ld('#'+popupobj.divid+' ul.reader-bar-list').append('<li userid="'+userid[i]+'"><span class="item-name">'+username[i]+'</span><span class="remove-h">×</span></li>');
									//绑定删除事件
									ld('#'+popupobj.divid+' ul.reader-bar-list li[userid='+userid[i]+'] .remove-h').unbind('click').click(function(){
										var liuserid = ld(this).parent().attr('userid');
										ld('#'+popupobj.divid+' ul.reader-bar-list li[userid='+liuserid+']').remove();
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

	this.showKehu001UserName=function(){

		if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
			//通讯录(pc端企业微信)
			cls_wxOpenDataobj.bindAllOpenData();
	}

	this.set_list_tab_event = function () {
		var basic_list_divobj = this.divobj.find('#basic_list_tab');
		var btn_key_arr = ['zhlabel','enlabel','description','active','isdefault'];
		var i = 0;
		for (i=0;i<btn_key_arr.length;i++){
			basic_list_divobj.find('[name='+btn_key_arr[i]+']').on('change',function () {
				that.listchangefun(this);
			})
		}
		//编辑按钮事件
		basic_list_divobj.find('[name=list_tab_edit],[name=list_tab_edit_cancel],[name=list_tab_edit_save]').on('click',function () {
			that.listeditfun(this);
		})
		var popupobj = this.popupobj;
		var basic_list_divobj = this.divobj.find('#basic_list_tab');
		//设置拖拽事件 列表页签拖拽
		Sortable.create(basic_list_divobj.find("#list_tab_set_table").find('tbody').get(0), {
			group: '',
			draggable: ".list_tab_set",
			handle: ".drag-handle",
			animation: 150,
			sort: true,
			onEnd: function (evt) {
				that.reset_list_table_sort('normal');
			}
		});
		//列表页签拖拽
		if(basic_list_divobj.find("#public_list_tab_set_table").length >0){
			Sortable.create(basic_list_divobj.find("#public_list_tab_set_table").find('tbody').get(0), {
				group: '',
				draggable: ".public_list_tab_set",
				handle: ".drag-handle",
				animation: 150,
				sort: true,
				onEnd: function (evt) {
					that.reset_list_table_sort('public');
				}
			});
		}
	}
	//页签列表内容变化事件
	this.listchangefun = function (obj) {
		var cur_obj = ld(obj);
		var cur_name = cur_obj.prop('name');
		var cur_tab_id = cur_obj.attr('tab_id');
		var tmp_info = '';
		var cur_value = '';
		var basic_list_divobj = this.divobj.find('#basic_list_tab');
		var showpublicmodule = this.base_poolinfo['showpublicmodule'];
		if(cur_name == 'active' || cur_name == 'isdefault'){
			cur_value = cur_obj.prop('checked')?'yes':'no';
		}else{
			cur_value = cur_obj.val();
		}
		var cur_fromtype = '';

		for(var i=0;i<this.list_tab.length;i++){
			tmp_info = this.list_tab[i];
			if(tmp_info['id'] == cur_tab_id){
				this.list_tab[i][cur_name] = cur_value;
				if(cur_name == 'active'){
					if(this.list_tab[i]['listtabname'] == 'ALLACCOUNT'){
						this.base_poolinfo['show_publicaccount_tab'] = cur_value;
					}
					if(this.list_tab[i]['listtabname'] == 'COMMONACCOUNT'){
						this.base_poolinfo['show_commonaccount_tab'] = cur_value;
					}
				}
				cur_fromtype = tmp_info['fromtype'];
			}
		}
		//设为默认时要将其他列取消默认
		if(cur_name == 'isdefault' && cur_value == 'yes'){
			for(var i=0;i<this.list_tab.length;i++){
				tmp_info = this.list_tab[i];
				if(tmp_info['id'] != cur_tab_id ){
					if(showpublicmodule != 'yes' || cur_fromtype == tmp_info['fromtype']){
						this.list_tab[i][cur_name] = 'no';
						basic_list_divobj.find('tr[tab_id='+tmp_info['id']+']').find('[name='+cur_name+']').prop('checked',false);
					}
				}
			}
		}
	}
	//页签列表编辑事件
	this.listeditfun = function (obj) {
		var cur_obj = ld(obj);
		var parent_div = cur_obj.parent();
		var isedit = parent_div.attr('isedit');
		var cur_tab_id = cur_obj.attr('tab_id');
		var basic_list_divobj = this.divobj.find('#basic_list_tab');
		var trobj = basic_list_divobj.find('tr[tab_id='+cur_tab_id+']');
		var btn_key_arr = ['zhlabel','enlabel','description'];
		var cur_name = cur_obj.attr('name');
		if(isedit != 'yes' ){
			var trobjs = this.divobj.find('tr[tag=list_tab_set],[tag=public_list_tab_set]');
			ld.each(trobjs,function (tmp_index,tmp_trobj) {
				if(ld(tmp_trobj).attr('tab_id') == cur_tab_id){
					return true;
				}
				ld(tmp_trobj).find('[name=list_tab_edit]').show().parent().attr('isedit','no');
				ld(tmp_trobj).find('[name=list_tab_edit_other]').show();
				ld(tmp_trobj).find('[name=list_tab_edit_cancel]').hide();
				ld(tmp_trobj).find('[name=list_tab_edit_save]').hide();

				for (var i=0;i<btn_key_arr.length;i++){
					ld(tmp_trobj).find('[name='+btn_key_arr[i]+']').val(ld(tmp_trobj).find('[name=span_'+btn_key_arr[i]+']').text());
					ld(tmp_trobj).find('[name='+btn_key_arr[i]+']').change();
				}
			})
		}
		for (var i=0;i<btn_key_arr.length;i++){
			if(isedit != 'yes'){
				basic_list_divobj.find('[name=span_'+btn_key_arr[i]+']').show();
				basic_list_divobj.find('[name='+btn_key_arr[i]+']').hide();
			}

			if(isedit != 'yes'){
				trobj.find('[name=span_'+btn_key_arr[i]+']').hide();
				trobj.find('[name='+btn_key_arr[i]+']').show();
				if(btn_key_arr[i] == 'zhlabel'){
					var textLength = trobj.find('[name='+btn_key_arr[i]+']').val().length;
					trobj.find('[name='+btn_key_arr[i]+']').focus().get(0).setSelectionRange(textLength, textLength);
				}
			}else{
				trobj.find('[name=span_'+btn_key_arr[i]+']').show();
				trobj.find('[name='+btn_key_arr[i]+']').hide();

				if(cur_name== 'list_tab_edit_save'){
					trobj.find('[name=span_'+btn_key_arr[i]+']').text(trobj.find('[name='+btn_key_arr[i]+']').val());
				}else{
					trobj.find('[name='+btn_key_arr[i]+']').val(trobj.find('[name=span_'+btn_key_arr[i]+']').text());
					trobj.find('[name='+btn_key_arr[i]+']').change()
				}

			}
		}
		if(isedit == 'yes'){
			parent_div.find('[name=list_tab_edit]').show();
			parent_div.find('[name=list_tab_edit_other]').show();
			parent_div.find('[name=list_tab_edit_cancel]').hide();
			parent_div.find('[name=list_tab_edit_save]').hide();
			parent_div.attr('isedit','no');
		}else{
			parent_div.find('[name=list_tab_edit_cancel]').show();
			parent_div.find('[name=list_tab_edit_save]').show();
			parent_div.find('[name=list_tab_edit]').hide();
			parent_div.find('[name=list_tab_edit_other]').hide();
			parent_div.attr('isedit','yes');
		}
	}
	//拖动后对页签信息重新排序
	this.reset_list_table_sort = function(type){
		var showpublicmodule = this.base_poolinfo['showpublicmodule'];
		if(type == 'normal' || type == 'public'){
			var list_tab = this.list_tab;
			if(type == 'normal'){
				var tableobj = this.divobj.find("#list_tab_set_table");
				var trobjs = tableobj.find('tr[tag=list_tab_set]');
			}else{
				var tableobj = this.divobj.find("#public_list_tab_set_table");
				var trobjs = tableobj.find('tr[tag=public_list_tab_set]');
			}
			var tmp_index = 0;
			var new_index_arr = [];
			ld.each(trobjs,function () {
				new_index_arr.push(ld(this).attr('tab_id'));
			})
			var list_tab_key_value = {};
			for (var i =0;i<list_tab.length;i++){
				list_tab_key_value[list_tab[i]['id']] = list_tab[i];
			}
			if(showpublicmodule == 'yes'){
				for (var i =0;i<list_tab.length;i++){
					if(list_tab[i]['fromtype'] == type){
						this.list_tab[i] = list_tab_key_value[new_index_arr[tmp_index]];
						tmp_index ++;
					}
				}
			}else{
				for (var i =0;i<list_tab.length;i++){
					this.list_tab[i] = list_tab_key_value[new_index_arr[tmp_index]];
					tmp_index ++;
				}
			}
		}else if (type == 'public_pool'){
			var public_pool = this.public_pool;
			var tableobj = this.divobj.find("#public_pool_table");
			var trobjs = tableobj.find('tr[tag=public_pool_set]');
			var tmp_index = 0;
			var new_index_arr = [];
			ld.each(trobjs,function () {
				new_index_arr.push(ld(this).attr('pool_id'));
			})
			var list_tab_key_value = {};
			for (var i =0;i<public_pool.length;i++){
				list_tab_key_value[public_pool[i]['id']] = public_pool[i];
			}
			for (var i =0;i<public_pool.length;i++){
				this.public_pool[i] = list_tab_key_value[new_index_arr[tmp_index]];
				tmp_index ++;
			}
		}else if(type  == 'normal_rule'){
			var common_recovey_rule = this.common_recovey_rule;
			var tableobj = this.divobj.find("#normal_rule_table");
			var trobjs = tableobj.find('tr[tag=normal_rule_set]');
			var tmp_index = 0;
			var new_index_arr = [];
			ld.each(trobjs,function () {
				new_index_arr.push(ld(this).attr('programmeid'));
			})
			var list_tab_key_value = {};
			for (var i =0;i<common_recovey_rule.length;i++){
				list_tab_key_value[common_recovey_rule[i]['programmeid']] = common_recovey_rule[i];
			}
			for (var i =0;i<common_recovey_rule.length;i++){
				tableobj.find('tr[tag=normal_rule_set][programmeid='+new_index_arr[tmp_index]+']').find('[name=seq_no]').html((tmp_index+1));
				this.common_recovey_rule[i] = list_tab_key_value[new_index_arr[tmp_index]];
				tmp_index ++;
			}
		}
	}
	//设置公海列表按钮点击事件
	this.set_public_pool_event = function () {
		var basic_list_divobj = this.divobj.find('#basic_pool_info');
		var btn_key_arr = ['active','default_pool'];
		var i = 0;
		for (i=0;i<btn_key_arr.length;i++){
			basic_list_divobj.find('[name='+btn_key_arr[i]+']').on('change',function () {
				that.publicchangefun(this);
			})
		}
		getJsScript('include/js/cls_poolinfo_set.js', function () {
			var circleruleobj = new cls_poolinfo_set(that.module);
			circleruleobj.set_before_obj(that,'public_common');
			//编辑按钮
			basic_list_divobj.find('[name=public_pool_edit]').on('click',function () {
				var pool_id = ld(this).attr('pool_id');
				circleruleobj.editpopup(pool_id);
			})
			basic_list_divobj.find('[name=public_pool_delete]').on('click',function () {
				circleruleobj.del_account_public_pool(this,event);
			})

		});

		//公海池列表拖拽
		Sortable.create(this.divobj.find("#public_pool_table").find('tbody').get(0), {
			group: '',
			draggable: "[tag=public_pool_set]",
			handle: ".drag-handle",
			animation: 150,
			sort: true,
			onEnd: function (evt) {
				that.reset_list_table_sort('public_pool');
			}
		});
	}
	// 公海按钮切换触发事件
	this.publicchangefun = function (obj) {
		var cur_obj = ld(obj);
		var cur_name = cur_obj.prop('name');
		var cur_pool_id = cur_obj.attr('pool_id');
		var tmp_info = '';
		var cur_value = '';
		var basic_list_divobj = this.divobj.find('#basic_pool_info');
		if(cur_name == 'active' || cur_name == 'default_pool'){
			cur_value = cur_obj.prop('checked')?'yes':'no';
		}

		for(var i=0;i<this.public_pool.length;i++){
			tmp_info = this.public_pool[i];
			if(tmp_info['id'] == cur_pool_id){
				this.public_pool[i][cur_name] = cur_value;
			}else{
				if(cur_name == 'default_pool'){
					this.public_pool[i][cur_name] = 'no';
					basic_list_divobj.find('tr[pool_id='+tmp_info['id']+']').find('[name='+cur_name+']').prop('checked',false);
				}
			}
		}
	}
	//客户回收规则点击事件
	this.set_normal_rule_event = function () {
		var basic_list_divobj = this.divobj.find('#normal_rule');
		var btn_key_arr = ['active'];
		var i = 0;
		for (i=0;i<btn_key_arr.length;i++){
			basic_list_divobj.find('[name='+btn_key_arr[i]+']').on('change',function () {
				var cur_programmeid = ld(this).attr('programmeid');
				var cur_value = '';
				var cur_name = ld(this).prop('name');
				if(cur_name == 'active'){
					cur_value = ld(this).prop('checked')?'yes':'no';
				}else{
					cur_value = ld(this).val();
				}
				for (var j =0;j<that.common_recovey_rule.length;j++){
					if(that.common_recovey_rule[j]['programmeid'] == cur_programmeid){
						that.common_recovey_rule[j][cur_name] = cur_value;
					}
				}
			})
		}
		getJsScript('include/js/cls_circlerule_set.js', function () {
			var circleruleobj = new cls_circlerule_set(that.module,'normal');
			circleruleobj.set_before_obj(that,'public_common',that.fieldlabel_arr['REGULARCUSTOMERSRECYCLINGSCHEME']);
			//新建
			basic_list_divobj.find('[name=normal_rule_create]').on('click',function () {
				circleruleobj.editpopup(-1);
			})
			//编辑按钮
			basic_list_divobj.find('[name=normal_rule_edit]').on('click',function () {
				var programmeid = ld(this).attr('programmeid');
				circleruleobj.editpopup(programmeid);
			})

			//删除按钮
			basic_list_divobj.find('[name=normal_rule_delete]').on('click',function () {
				that.delete_normal_rule(this);
			})
		});

		//回收方案拖拽
		Sortable.create(this.divobj.find("#normal_rule_table").find('tbody').get(0), {
			group: '',
			draggable: "[tag=normal_rule_set]",
			handle: ".drag-handle",
			animation: 150,
			sort: true,
			onEnd: function (evt) {
				that.reset_list_table_sort('normal_rule');
			}
		});
	}
	//删除普通客户回收规则
	this.delete_normal_rule = function (obj) {
		var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
		MessagePopup.TipTwo_warning(confirm_str);
		var remindpopup = CrmPopup.getPopupObj('last');
		var programmeid = ld(obj).attr('programmeid');
		ld('#'+remindpopup.divid+'_btnok').bind('click',function () {
			var deleted_index = -1;
			for (var i =0;i<that.common_recovey_rule.length;i++){
				if(that.common_recovey_rule[i]['programmeid'] == programmeid){
					deleted_index = i;
					break;
				}
			}
			if(deleted_index != -1){
				that.divobj.find('#normal_rule_table').find('tr[tag=normal_rule_set][programmeid='+programmeid+']').remove();
				that.common_recovey_rule.splice(deleted_index,1);
			}
		})
	}

	this.get_ruleinfo_byid = function (ruleid) {
		var tmp_info = [];
		var rule_arr = [];
		for (var i =0;i<this.common_recovey_rule.length;i++){
			if(this.common_recovey_rule[i]['programmeid'] == ruleid){
				//使用Object.assign 方法进行深复制 ,浅复制会导致弹出层内容没保存时直接修改原值 tmp_info = this.common_recovey_rule[i]
				for(var j=0;j<this.common_recovey_rule[i]['rule_arr'].length;j++){
					rule_arr.push(Object.assign({}, this.common_recovey_rule[i]['rule_arr'][j]));
				}
				tmp_info = Object.assign({}, this.common_recovey_rule[i]);
				tmp_info['rule_arr'] = rule_arr;
				break;
			}
		}
		return tmp_info;
	}

	this.set_ruleinfo_byid = function (ruleid,new_info) {
		var find_result = 'no';
		for (var i =0;i<this.common_recovey_rule.length;i++){
			if(this.common_recovey_rule[i]['programmeid'] == ruleid){
				this.common_recovey_rule[i] = new_info;
				find_result = 'yes';
				break;
			}
		}
		if(find_result == 'no'){
			this.common_recovey_rule.push(new_info);
		}

		var normalrule_content = this.get_normal_rule_html();
		this.divobj.find('#normal_rule').html(normalrule_content);
		this.set_normal_rule_event();
	}

	this.get_public_pool = function () {
		return this.public_pool;
	}
	this.set_public_pool_byid = function (poolid,new_info) {
		var find_result = 'no';
		for (var i =0;i<this.public_pool.length;i++){
			if(this.public_pool[i]['id'] == poolid){
				this.public_pool[i] = new_info;
				find_result = 'yes';
				break;
			}
		}
		if(find_result == 'no'){
			this.public_pool.push(new_info);
		}
		var basic_pool_html = this.get_basic_pool_info_html();
		this.divobj.find('#basic_pool_info').html(basic_pool_html);
		this.set_public_pool_event();
	}
	this.delete_public_pool = function (pool_id) {
		for (var i =0;i<this.public_pool.length;i++){
			if(this.public_pool[i]['id'] == pool_id) {
				this.public_pool.splice(i,1);
				break;
			}
		}
		var basic_pool_html = this.get_basic_pool_info_html();
		this.divobj.find('#basic_pool_info').html(basic_pool_html);
		this.set_public_pool_event();
	}

	//生成回收规则内容
	this.get_rule_label = function (rule_arr) {
		var all_label_arr = [];
		var tmp_lable = '';
		for (var i = 0;i<rule_arr.length;i++){
			if(rule_arr[i]['status'] == 'inactive')continue;

			if(rule_arr[i]['iscycle'] == 'yes'){
				tmp_lable = this.fieldlabel_arr['CYCLENOCREATEDDAYS'];
			}else{
				tmp_lable = this.fieldlabel_arr['SINGLENOCREATEDDAYS'];
			}
			tmp_lable = tmp_lable.replace('{var}',rule_arr[i]['days']);
			tmp_lable = tmp_lable.replace('{module}',rule_arr[i]['tablabel']);
			all_label_arr.push(tmp_lable);
		}
		return all_label_arr.join('<br>');
	}
	//公海池信息里的数据较多，没必要全部传输
	this.get_publicpool_return_info = function () {
		var return_info = [];
		var tmp_info = {};

		for (var i = 0;i<this.public_pool.length;i++){
			tmp_info = this.public_pool[i];
			return_info.push({'id':tmp_info['id'],'active':tmp_info['active'],'default_pool':tmp_info['default_pool']})
		}
		return return_info;
	}

	//回收方案里的数据较多，没必要全部传输，容易出问题
	this.get_commonrule_return_info = function () {
		var return_info = [];
		var tmp_info = {};
		for (var i = 0;i<this.common_recovey_rule.length;i++){
			tmp_info = this.common_recovey_rule[i];
			return_info.push({'programmeid':tmp_info['programmeid'],'active':tmp_info['active']})
		}
		return return_info;
	}
}
