/*
*edit: duanjb
*date: 2024/07/17
*reason: 公海池设置
*/
function cls_poolinfo_set(module)
{
	var that = this;
	this.module = module;
	this.popupobj = '';
	this.fieldlabel_arr = []; //翻译数组
	this.divobj = '';
	this.pool_data = {};
	this.public_recovey_rule = [];
	this.btn_profile = [];
	this.language_type = ''; //语言类型
	this.user_profile_info = [];
	this.releasetype_arr = [];
	this.public_pool = [];
	this.public_role_limitaccount = [];

	this.setbasicinfo = function (returndata) {
		this.fieldlabel_arr = returndata.fieldlabel_arr;
		this.pool_data = returndata.pool_data;
		this.public_recovey_rule = returndata.public_recovey_rule;
		this.btn_profile = returndata.btn_profile;
		this.user_profile_info = returndata.user_profile_info;
		this.releasetype_arr = returndata.releasetype_arr;
		this.public_pool = returndata.public_pool;
		this.language_type = returndata.language_type;
		this.public_role_limitaccount = returndata.public_role_limitaccount;
		this.buttonarray = returndata.buttonarray;

		var find_result = 'no';
		for(var i =0;i<this.public_pool.length;i++){
			if(this.public_pool[i]['id'] == this.pool_data['id']){
				this.public_pool[i] = this.pool_data;
				find_result = 'yes';
				break;
			}
		}
		if(find_result == 'no'){
			this.public_pool.push(this.pool_data);
		}
	}

	this.set_before_obj = function (obj,type) {
		this.before_type = type;
		this.before_obj = obj;
	}

	this.editpopup = function (pool_id) {
		this.mode = 'create';
		if(pool_id > 0){
			this.mode = 'edit';
		}
		var surl = 'index.php?module='+this.module+'&action='+this.module+'Ajax&file=EditPublicPool&pool_id='+pool_id+'&frommodule='+this.module;
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
		crmPopupobj.prevshow();
		this.popupobj = crmPopupobj;
		this.divobj = ld('#'+crmPopupobj.divid);
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				that.setbasicinfo(data.result);
				crmPopupobj.setParams(data.result.title,that.SavePoolInfo,"","LdPopWidth1100px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.createScrollDiv();

				var all_html = that.CreatePopupHtml();
				crmPopupobj.show(all_html);

				that.setBindPopupEvent();

				crmPopupobj.setScrollDivMaxHeight();
				crmPopupobj.center();
				tooltip(ld('#'+that.popupobj.divid+' .tip-items-list'), {transition: true, time: 200});
			}
		})

	}

	this.SavePoolInfo = function () {
		var expre=/^[0-9]*[1-9][0-9]*$/;
		var popupobj=that.popupobj;
		var prevpopupobj=that.before_obj;
		var pool_id = that.pool_data['id'];
		var languagetype = that.language_type;
		//公海名称（中）
		var zh_name = that.pool_data['zh_name'];
		if(empty(zh_name)){
			audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=zh_name]").attr('label')+arrJsPopLabel['CANOTEMPTY']);
			ld("#"+popupobj.divid+" [name=zh_name]").focus();
			return false;
		}
		//公海名称（英）
		var en_name = that.pool_data['en_name'];
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
		var limit_type = that.pool_data['limit_type'];
		var limit_count = that.pool_data['limit_count'];
		var role_limit_count_info = [];
		if(limit_type == 'user'){
			if(!(expre.test(limit_count))){
				audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=limit_count]").attr('label')+arrJsPopLabel['NUMONLYINT']);
				ld("#"+popupobj.divid+" [name=limit_count]").focus();
				return false;
			}
		}else if(limit_type == 'role'){
			var input_objs = ld("#"+popupobj.divid+" [name=public_role_count]");
			ld.each(input_objs,function () {
				role_limit_count_info.push({'profileid':ld(this).attr('roleid'),'limit_count':ld(this).val()})
			})
		}

		var param = {};
		var create_buttons = [];
		ld.each(that.divobj.find('#m_create_buttons').find('option:selected'),function () {
			create_buttons.push(ld(this).val());
		})
		that.pool_data.m_create_buttons =create_buttons;
		param['pool_data'] = that.pool_data;
		param['mode'] = 'save';
		param['frommodule'] = that.module;
		param['select_pool_id'] = pool_id;

		var public_recovey_rule = that.get_public_return_info();//回收方案里的数据较多，没必要全部传输
		if(public_recovey_rule.length>0){
			param['public_recovey_rule'] = public_recovey_rule;
		}else{
			param['public_recovey_rule'] = '';
		}
		if(role_limit_count_info.length>0){
			param['role_limit_count_info'] = role_limit_count_info;
		}else{
			param['role_limit_count_info'] = '';
		}
		if(that.user_profile_info.length>0){
			param['user_profile_info'] = that.user_profile_info;
		}else{
			param['user_profile_info'] = '';
		}


		var surl = 'index.php?module=Accounts&action=AccountsAjax&file=savePublicPool';

		ldAjaxNoProgress(surl,param,function(data){
			if(data.code == 1){
				that.after_save(data.result.pool_id,data.result.pool_data)
				popupobj.CancelEvent();
				var confirm_str=arrJsPopLabel['SUCCESSFULLYSAVED'];
				MessagePopup.TipZero_success(confirm_str);
			}
			else if(data.code == -1){
				MessagePopup.TipZero_warning(arrJsPopLabel['DNCNBRIE']);
				ld("#"+popupobj.divid+" #zh_name").focus();
			}

		})
	}

	this.after_save = function (pool_id,pool_data) {

		if(this.before_type == 'public_common'){
			this.before_obj.set_public_pool_byid(pool_id,pool_data);
		}else{
			var prevpopupobj = this.before_obj;
			if(prevpopupobj.type && prevpopupobj.type==ListPagePopup.type){//列表页面要刷新列表
				var searchScope = '';
				if(ld("#"+prevpopupobj.divid+" [name=SmOwnerSearchScope]")!=null)
					searchScope= encodeURIComponent(ld("#"+prevpopupobj.divid+" [name=SmOwnerSearchScope]").val());
				var viewname = ld("#"+prevpopupobj.divid+' #viewname').val();
				var listview_page=new ListView_Page(that.module,"module="+that.module+"&action="+that.module+"Ajax&file=ListView&start=1&SearchScope="+searchScope+'&viewname='+viewname,"pagecontent1");
				listview_page.callback_fun=function()
				{
					prevpopupobj.listresizeobj.setReiszeTable_Init(that.module,'ajax');
					setContentHeight(that.module);//计算内容高度
					IsFrameElement();
				}
				listview_page.page();
			}
			else{
				var pool_name = (this.language_type=='zh'?pool_data['zh_name']:pool_data['en_name']);
				if(this.mode == 'edit'){
					ld("#"+prevpopupobj.divid+" [name=td_pool_name_"+pool_id+"]").html(pool_name);
				}else{
					var newpool_html = "<tr class=\"ld-category-draggable\" pool_id="+pool_id+" name='tr_pool_id_"+pool_id+"'>"
					newpool_html += "<td><span name='td_pool_name_"+pool_id+"'>"+pool_name+"</span></td><a class=\"ld-category-icon ld-category-drag drag-handle\" style=\"cursor: pointer;\"></a>";
					newpool_html += "<td><input name=\"set_default_pool\" pool_id="+pool_id+" type=\"checkbox\" class=\"second_switch\" style=\"margin-left: 5px;\" onclick=\"publicAccounts.getInstance().SetDefaultPool(this)\"></td>";
					newpool_html += "<td class='sort_td'><div class='displayflex flexcenter'>";
					newpool_html += "<a class=\"tip-items-list\" href=\"javascript:void(0);\" tag=\"edit\" pool_id="+pool_id+" onclick=\"publicAccounts.getInstance().account_public_pool(ld(this),event);\" style=\"white-space:nowrap;margin-left:8px;\" data-tip="+arrJsPopLabel['EDIT']+" data-direction=\"top\" data-type=\"position\"><i class=\"ld-fonticon ld-fonticon-edit\"></i></a> ";
					newpool_html += "<a class=\"tip-items-list\" href=\"javascript:void(0);\" tag=\"delete\" pool_id="+pool_id+" onclick=\"publicAccounts.getInstance().del_account_public_pool(ld(this),event);\" style=\"white-space:nowrap;margin-left:8px;\" data-tip="+arrJsPopLabel['DELETE']+" data-direction=\"top\" data-type=\"position\"><i class=\"ld-fonticon ld-fonticon-del\"></i></a>";
					newpool_html += "<a class=\"ld-category-icon ld-category-drag drag-handle tip-items-list\" style=\"cursor: pointer;\" data-tip="+arrJsPopLabel['drag']+" data-direction=\"right\" data-type=\"position\"></a>";
					newpool_html += "</div></td></tr>";
					ld("#"+prevpopupobj.divid+" [name=viewpublicaccount_table]").append(newpool_html);
				}
				ld("#"+prevpopupobj.divid).find(".ld-category-drag").show();
				prevpopupobj.center();
				//that.SortPublicPool();
			}
		}

	}

	//生成界面内容
	this.CreatePopupHtml = function () {
		var all_html = '';
		var div_style = '';

		// 公海基本设置区块
		var public_set_html = this.get_poolinfo_set_html();
		all_html += public_set_html;
		// 公海管理员信息区块
		var pool_admin_set_thml = '<div id="pool_admin_set" '+div_style+' >' + this.get_pool_admin_set_html()+ '</div>';
		all_html += pool_admin_set_thml;
		// 公海成员信息区块
		var pool_memeber_set_thml = '<div id="pool_memeber_set" '+div_style+' >' + this.get_pool_memeber_set_html()+ '</div>';
		all_html += pool_memeber_set_thml;
		//客户回收方案
		var public_rule_html = '<div id="public_rule"  '+div_style+' >' + this.get_publicrule_html()+ '</div>';
		all_html += public_rule_html;
		// 公海业务规则
		var business_rules_html = '<div id="business_rule_html" >'+this.get_business_rules_html()+'</div>';
		all_html += business_rules_html;

		return all_html;
	}
	// 公海设置区块
	this.get_poolinfo_set_html = function(){

		var poolinfo_set_html = '';

		var poolinfo_set_content = '';

		//公海池名称
		poolinfo_set_content += '<tr class="ld-form-item">';
		poolinfo_set_content += '<td class="ld-form-item-label">' +
			'<span class="pad"><font color="red">*</font>'+this.fieldlabel_arr['Name(ZH)']+'</span>'+
			'</td>';
		poolinfo_set_content += '<td class="ld-form-item-content">' +
			'<input class="ld-input-inner" style="width: 350px;" type="text" id="zh_name" name="zh_name" placeholder="'+this.fieldlabel_arr['Pleaseentername']+'" label="'+this.fieldlabel_arr['Name(ZH)']+'" value="'+this.pool_data['zh_name']+'" />' +
			'</td>';
		poolinfo_set_content += '</tr>';
		poolinfo_set_content += '<tr class="ld-form-item">';
		poolinfo_set_content += '<td class="ld-form-item-label">' +
			'<span class="pad"><font color="red">*</font>'+this.fieldlabel_arr['Name(EN)']+'</span>'+
			'</td>';
		poolinfo_set_content += '<td class="ld-form-item-content">' +
			'<input class="ld-input-inner" style="width: 350px;" type="text" id="en_name" name="en_name" placeholder="'+this.fieldlabel_arr['Pleaseentername']+'" label="'+this.fieldlabel_arr['Name(EN)']+'" value="'+this.pool_data['en_name']+'" />' +
			'</td>';
		poolinfo_set_content += '</tr>';

		poolinfo_set_content = '<table class="ld-public-content-small" style="padding-top: 0;padding-bottom: 0;" cellspacing="0" cellpadding="0" border="0">' +
			'<tbody>' +
			poolinfo_set_content +
			'</tbody>' +
			'</table>';
		poolinfo_set_html += this.gettablecontent(this.fieldlabel_arr['BASICINFO'],poolinfo_set_content);
		return poolinfo_set_html;
	}
	// 公海管理员设置区块
	this.get_pool_admin_set_html = function(){
		var pool_admin_set_html = '';

		var li_content = '';
		var tmp_info = '';
		var tmp_arr = '';
		var profile_content = '';
		var tmp_class = '';
		var profileinfo = [];
		var check_result = true;
		var j = 0;
		for (var i = 0;i<this.pool_data.administrators_lastname.length ;i++){
			tmp_info = this.pool_data.administrators_lastname[i];
			li_content += '<li itemid="'+tmp_info.userid+'" emptype="p">' +
				'<span class="item-name">'+tmp_info.last_name+'</span><span class="remove-h">×</span>' +
				'</li>';

			profile_content += '<tr class="'+tmp_class+'">';
			profile_content += '<td>'+tmp_info.last_name+'</td>';
			if(this.user_profile_info[tmp_info.userid] == undefined){
				this.user_profile_info[tmp_info.userid] = [];
				for (j=0;j<this.btn_profile.length;j++){
					tmp_arr = this.btn_profile[j];
					this.user_profile_info[tmp_info.userid].push(tmp_arr.actionid);
				}
			}
			profileinfo = this.user_profile_info[tmp_info.userid]
			for (j=0;j<this.btn_profile.length;j++){
				tmp_arr = this.btn_profile[j];
				check_result = profileinfo.includes(tmp_arr.actionid);
				if(i == 0)tmp_arr['allcheck'] = 'yes';

				if(!check_result)tmp_arr['allcheck'] = 'no';

				profile_content += '<td><input actionid="'+tmp_arr.actionid+'" type="checkbox" tag="profile_btn" userid="'+tmp_info.userid+'" name="'+tmp_arr.actionname+'" '+(check_result?'checked':'')+' ></td>';
			}
			profile_content += '</tr>';
		}
		var user_profildinfo_html = '';
		var th_label_content = '';
		th_label_content += '<thead><tr>';
		//中文标签
		th_label_content += '<th width="120px"><div class="oline"><span class="olinespan1">'+this.fieldlabel_arr['ADMIN']+'</span><span class="olinespan2">'+this.fieldlabel_arr['LBL_PROFILES']+'</span></div></th>';
		for (j=0;j<this.btn_profile.length;j++){
			tmp_arr = this.btn_profile[j];
			th_label_content += '<th style="'+(tmp_arr.actionname=='transfercustomer'||tmp_arr.actionname=='displayeunallocated'?'width: 180px;':'')+'" >' +
			'<input type="checkbox" name="all_'+tmp_arr.actionname+'" tag="profile_btn_all" actionid="'+tmp_arr.actionid+'" '+(tmp_arr['allcheck'] =='yes'?'checked':'')+' >' +
			'<label style="padding: 4px;" for="all_'+tmp_arr.actionname+'">'+tmp_arr.label+'</label></th>';
		}
		th_label_content += '</tr></thead>';
		user_profildinfo_html  += '<div class="ld-pop-container ld-table-container ld-table-container-lines" style="padding: 0px;">' +
			'<table class="publicpoolset" id="user_profildinfo" cellspacing="0" cellpadding="0" border="0">';
		user_profildinfo_html += th_label_content;
		user_profildinfo_html += profile_content;
		user_profildinfo_html += '</table></div>';

		var pool_admin_set_content = '';
		pool_admin_set_content += '<table class="ld-public-content-small" style="padding-top: 0;padding-bottom: 0px;" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tbody>' +
			'<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">'+this.fieldlabel_arr['Pleasesettheadministrators']+'</td>' +
			'<td class="ld-form-item-content">' +
			'<div class="pubclear" id="sendLogFoot" >' +
			'<input type="hidden" name="select_administrators_id" value="'+this.pool_data.administrators+'" />' +
			'<div class="CCrange selectbar" name="select_administrators" tag="ccrange" style="margin-bottom: 5px;width: 100%;">' +
			'<ul class="reader-bar-list">' +
			li_content +
			'</ul>' +
			'<input class="input-field ui-hide" type="text" autocomplete="off" value="">' +
			'<a class="ld-text-arrow-before" style="height: 40px;" href="javascript:;" draggable="false"><span class="ld-text-arrow" style="margin: 9px auto;"></span></a>' +
			'</div>' +
			'</div>' +
			'</td>' +
			'</tr>' +
			'<tr class="ld-form-item">' +
			'<td class="ld-form-item-label" style="vertical-align: top;"><span style="line-height: 52px;">'+this.fieldlabel_arr['Mangers']+this.fieldlabel_arr['LBL_PROFILES']+'</span></td>' +
			'<td class="ld-form-item-content">';
		pool_admin_set_content += user_profildinfo_html;
		pool_admin_set_content += '</td>' +
			'</tr>' +
			'</tbody>' +
			'</table>';

		var table_title = '<span>'+this.fieldlabel_arr['Mangers']+'</span><span style="color: #c4bcbc;">'+this.fieldlabel_arr['SUPERADMINISTRATORHASALLPERMISSIONS']+'</span>'

		pool_admin_set_html = this.gettablecontent(table_title,pool_admin_set_content);
		return pool_admin_set_html;
	}
	//公海成员设置
	this.get_pool_memeber_set_html = function () {
		var pool_memeber_set_html = '';
		var pool_memeber_set_content = '';
		//公海成员设置
		pool_memeber_set_content += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">' +
			'<span class="pad">'+this.fieldlabel_arr['Members']+'</span>' +
			'</td>' +
			'<td class="ld-form-item-content select-input">'+
			'<input type="radio" '+(this.pool_data['usertype'] == 'all'?'checked':'')+' value="all" name="radioUser" id="pulicaccount_all">' +
			'<label class="padR20 padL10" for="pulicaccount_all">'+this.fieldlabel_arr['ALLTHEUSERS']+'</label>' +
			'<input type="radio" '+(this.pool_data['usertype'] == 'group'?'checked':'')+' value="group" name="radioUser" id="pulicaccount_group">' +
			'<label class="padR20 padL10" for="pulicaccount_group">'+this.fieldlabel_arr['SETBYDEPARTMENT']+'</label>' +
			'<input type="radio" '+(this.pool_data['usertype'] == 'user'?'checked':'')+' value="user" name="radioUser" id="pulicaccount_user">' +
			'<label class="padR20 padL10" for="pulicaccount_user">'+this.fieldlabel_arr['SETBYUSERS']+'</label>' +
			'<input id="usertype" class="templateprintuser" type="hidden" value="'+this.pool_data['usertype']+'" name="usertype">' +
			'<input id="userids" class="templateprintuser" type="hidden" value="'+this.pool_data['userids']+'" name="userids">' +
			'</td></tr>';
		//公海成员释放权限
		pool_memeber_set_content += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">' +
			'<span class="pad">'+this.fieldlabel_arr['SEASMEMBERSSCOPEOFRELEASE']+'</span>' +
			'</td>' +
			'<td class="ld-form-item-content">'+
			'<select class="ld-select-inner" id="releasetype" name="releasetype" style="width: 350px;">';
		for (var i =0;i<this.releasetype_arr.length;i++){
			pool_memeber_set_content += '<option value="'+this.releasetype_arr[i]['key']+'" '+(this.pool_data['releasetype']==this.releasetype_arr[i]['key']?'selected':'')+' >'
				+this.fieldlabel_arr[this.releasetype_arr[i]['labelbol']]+'</option>'
		}
		pool_memeber_set_content +='</select></td></tr>';

		pool_memeber_set_content += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-label" style="vertical-align: top;"><span style="position: relative;top: 4px;">'+this.fieldlabel_arr['DistributionRules'] +
			'</span></td>' +
			'<td class="ld-form-item-content">';
		// 不允许领取公海客户
		pool_memeber_set_content += '<div id="tr_allowget" style="padding: 4px 0;">' +
			'<div style="display: flex;align-items: center;">' +
			'<input type="checkbox" style="margin-right: 5px;" '+(this.pool_data['allowget'] == 'yes'?'checked':'')+'  name="allowget" id="allowget">'+
			'<label for="allowget" class="pad">'+this.fieldlabel_arr['UNALLOCATECUSTOMERADMIN']+'</label>' +
			'</div>' +
			'</div>';
		// 是否显示公海未分配页签
		pool_memeber_set_content += '<div id="tr_poolmember_show_noallocate" style="padding: 4px 0;'+(this.pool_data['allowget'] != 'yes'?'display:none;':'')+'" >' +
			'<div style="display: flex;align-items: center;">' +
			'<input type="checkbox" style="margin-right: 5px;" '+(this.pool_data['poolmember_show_noallocate'] == 'yes'?'checked':'')+'  name="poolmember_show_noallocate" id="poolmember_show_noallocate">'+
			'<label for="poolmember_show_noallocate" class="pad">'+this.fieldlabel_arr['ISSHOWUNALLOCATEDHIGHSEAS']+'</label>' +
			'</div>' +
			'</div>';
		// 允许公海成员将已分配或领取的客户转移到其他公海
		pool_memeber_set_content += '<div id="tr_poolmember_show_noallocate" style="padding: 4px 0;">' +
			'<div style="display: flex;align-items: center;">' +
			'<input type="checkbox" style="margin-right: 5px;" '+(this.pool_data['allow_trasnfer_others'] == 'yes'?'checked':'')+'  name="allow_trasnfer_others" id="allow_trasnfer_others">'+
			'<label for="allow_trasnfer_others" class="pad">'+this.fieldlabel_arr['Allowuserstotransfertheallocatedcustomerstootherseas']+'</label>' +
			'</div>' +
			'</div>';
		pool_memeber_set_content += '</td></tr>';
		var pool_memeber_set_table = '';
		pool_memeber_set_table  += '<table class="ld-public-content-small" style="padding-top: 0;padding-bottom: 0px;" width="100%" cellspacing="0" cellpadding="0" border="0">';
		pool_memeber_set_table += pool_memeber_set_content;
		pool_memeber_set_table += '</table>';

		pool_memeber_set_html = this.gettablecontent(this.fieldlabel_arr['Members'],pool_memeber_set_table);
		return pool_memeber_set_html;
	}
	this.get_publicrule_html = function(){
		var public_recovey_rule = this.public_recovey_rule;

		var tmp_info = [];
		var i = 0;
		var publicrule_content = '';
		var all_publicrule_html = '';
		var tmp_content = '';

		var th_label_content = '';
		th_label_content += '<thead><tr>';
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


		publicrule_content += '<div class="ld-pop-container ld-table-container ld-table-container-lines" style="padding-top: 0;">' +
			'<table id="public_rule_table" cellspacing="0" cellpadding="0" border="0">';

		publicrule_content += th_label_content;

		var tmp_class = '';
		var rule_label = '';
		for (i = 0;i<public_recovey_rule.length;i++){
			tmp_info = public_recovey_rule[i];
			tmp_content = '';

			tmp_content += '<tr tag ="public_rule_set" class="'+tmp_class+'" programmeid="'+tmp_info['programmeid']+'" >';
			//编号
			tmp_content += '<td name="seq_no">'+(i+1)+'</td>';
			//回收条件
			tmp_content += '<td data-tip="'+tmp_info['advf_label']+'"  onmouseenter="tooltip.bind(this)" >'+tmp_info['advf_label']+'</td>';
			//回收规则
			rule_label = this.get_rule_label(tmp_info.rule_arr);
			tmp_content += '<td data-tip="'+rule_label+'"  onmouseenter="tooltip.bind(this)" >'+rule_label+'</td>';

			//回收到公海
			tmp_content += '<td>'+this.getPoolnameByid(tmp_info['pool_id'])+'</td>';
			//方案说明
			tmp_content += '<td>'+tmp_info['description']+'</td>';
			//是否启用
			tmp_info['active_result'] = tmp_info['active']=='yes'?'checked':'';
			tmp_content += '<td><input class="second_switch" type="checkbox" name="active" '+tmp_info['active_result']+' programmeid="'+tmp_info['programmeid']+'" ></td>';
			//操作
			tmp_content += '<td ><div class="pool_btn_flex" style="display: flex;">'+
				'<a name="public_rule_edit" programmeid="'+tmp_info['programmeid']+'" ><i class="ld-fonticon ld-fonticon-edit"></i></a>'+
				'<a name="public_rule_delete" style="margin-left: 10px;" programmeid="'+tmp_info['programmeid']+'" ><i class="ld-fonticon ld-fonticon-del"></i></a>'+
				'<a data-tip="'+arrJsPopLabel['DRAGTOSORT']+'" class="ld-category-icon ld-category-drag drag-handle"></a>'
			tmp_content + '</div></td >';

			tmp_content += '</tr>';

			publicrule_content += tmp_content;
		}
		publicrule_content += '<tr>' +
			'<td colspan="7">' +
			'<div name="public_rule_create" class="ld-btn-icontext-item">' +
			'<i class="ld-fonticon ld-fonticon-add" style="color: var(--ld-font-link-color);"></i>' +
			'<span style="color: var(--ld-font-link-color);">'+this.fieldlabel_arr['addrulecomments']+'</span></div>' +
			'</td>' +
			'</tr>';
		publicrule_content += '</table></div>';

		// 公海总数量控制
		var limit_type_arr = this.get_limit_type_arr();
		var i = 0;
		var limit_type_html = '';
		var limit_type = this.pool_data['limit_type'];

		for (i =0;i<limit_type_arr.length;i++){
			limit_type_html += '<option value="'+limit_type_arr[i]['key']+'" '+(limit_type==limit_type_arr[i]['key']?'selected':'')+' >'+limit_type_arr[i]['label']+'</option>';
		}

		publicrule_content += '<table class="ld-public-content-small" style="padding-top: 0;padding-bottom: 0;" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">'+this.fieldlabel_arr['maximumnumberofhighseascustomers']+'</td>' +
			'<td class="ld-form-item-content">' +
			'<select id="limit_type" class="ld-select-inner" style="width: auto;margin: auto 10px auto 0;" >' + limit_type_html +
			'</select>' +
			'<input label="'+this.fieldlabel_arr['maximumnumberofhighseascustomers']+'" id="limit_count" class="ld-input-inner" style="width: 100px;'+(limit_type=='user'?'':'display:none;')+' " value="'+(empty(this.pool_data['limit_count'])?'':this.pool_data['limit_count'])+'" />' +
			'</td>' +
			'</tr>' +
			'</table>';
		publicrule_content += '<div id="public_role_limit_count" class="ld-pop-container ld-table-container ld-table-container-lines" style="padding-bottom: 0px;'+(limit_type=='role'?'':'display:none;')+'" >' +
			'<table border="0" cellspacing="0" cellpadding="0" width="100%">';
		publicrule_content += '<thead><tr>' +
			'<th width="50%" title="'+this.fieldlabel_arr['PROFILES']+'">'+this.fieldlabel_arr['PROFILES']+'</th>' +
			'<th width="50%" title="'+this.fieldlabel_arr['Themaximumnumberofhighseascustomers']+'">'+this.fieldlabel_arr['Themaximumnumberofhighseascustomers']+'</th>' +
			'</tr></thead>';

		i = 0;
		var tmp_class = '';
		ld.each(this.public_role_limitaccount,function (tmp_profileid,tmp_info) {
			publicrule_content += '<tr bgcolor="white" class="'+tmp_class+'">\n' +
				'<td nowrap=""><span title="'+tmp_info['role_name']+'">'+tmp_info['role_name']+'</span></td>\n' +
				'<td>\n' +
				'<input name="public_role_count" roleid="'+tmp_profileid+'" class="ld-input-inner" style="width:150px;float:left;" type="text" value="'+tmp_info['limit_count']+'" maxlength="100">\n' +
				'</td>\n' +
				'</tr>';
			i ++;
		})

		publicrule_content += '</table></div>';

		all_publicrule_html += this.gettablecontent(this.fieldlabel_arr['recyclingscheme'],publicrule_content);

		return all_publicrule_html;
	}

	// 设置业务规则
	this.get_business_rules_html = function () {
		var business_rules_html = '';

		business_rules_html += '<table class="ld-public-content-small" style="padding-top: 0;" width="100%" cellspacing="0" cellpadding="0" border="0">';

		//不控制公海未分配客户的数据权限，允许查询所有公海未分配客户
		business_rules_html += '<tr class="ld-form-item"><td class="ld-form-item-content" colspan="2" style="padding-left: 0;">' +
			'<div style="display: flex;align-items: center;">' +
			'<input type="checkbox" style="margin-right: 5px;" '+(this.pool_data['dataprofile'] == 'yes'?'checked':'')+'  name="dataprofile" id="dataprofile">'+
			'<label for="dataprofile" class="pad">'+this.fieldlabel_arr['CUSTOMERCONTROLPUBLIC']+'</label>' +
			'</div></td></tr>';
		//允许公海未分配客户显示在“全部（含公海）”列表
		business_rules_html += '<tr class="ld-form-item"><td class="ld-form-item-content" colspan="2" style="padding-left: 0;">' +
			'<div style="display: flex;align-items: center;">' +
			'<input type="checkbox" style="margin-right: 5px;" '+(this.pool_data['allow_unallocated_showinall'] == 'yes'?'checked':'')+'  name="allow_unallocated_showinall" id="allow_unallocated_showinall">'+
			'<label for="allow_unallocated_showinall" class="pad">'+this.fieldlabel_arr['Allowtheunallocatedcustomerstobedisplayedinalllist']+'</label>' +
			'</div></td></tr>';

		//允许公海未分配客户显示在“全部（含公海）”列表
		business_rules_html += '<tr class="ld-form-item"><td class="ld-form-item-content" colspan="2" style="padding-left: 0;">' +
			'<div style="display: flex;align-items: center;">' +
			'<input type="checkbox" style="margin-right: 5px;" '+(this.pool_data['allow_allocated_showinall'] == 'yes'?'checked':'')+'  name="allow_allocated_showinall" id="allow_allocated_showinall">'+
			'<label for="allow_allocated_showinall" class="pad">'+this.fieldlabel_arr['Allowtheallocatedcustomerstobedisplayedinalllist']+'</label>' +
			'</div></td></tr>';
		var create_btn_html = '';
		if(empty(this.pool_data.create_buttons))this.pool_data.create_buttons = [];
		ld.each(this.buttonarray,function (tmp_key,tmp_label) {
			create_btn_html += '<option value="'+tmp_key+'" '+(that.pool_data.create_buttons.includes(tmp_key)?'selected':'')+'>'+tmp_label+'</option>';
		})

		business_rules_html += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-label">'+this.fieldlabel_arr['NEWBUTTONDROP-DOWNOPTIONS']+'</td>' +
			'<td class="ld-form-item-content" id="dv_create_buttons" >' +
			'<select id="m_create_buttons" name="m_create_buttons[]" multiple  style="width: 100%;">' +
			create_btn_html +
			'</select>' +
			'</td></tr>';

		//客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）
		business_rules_html += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-label"><div style="display: flex;align-items: center;">'+this.fieldlabel_arr['AFTERCONVERTINGMODIFYTHEOWNER']+
			'<i class="ld-fonticon ld-fonticon-help tip-items-list" data-tip="'+this.fieldlabel_arr['AFTERCONVERTINGMODIFYTHEOWNERDES']+'" data-direction="top" data-type="position"></i></div>'+
			'</td>' +
			'<td class="ld-form-item-content">' +
			'<div style="position: absolute;display: inline;top: calc(50% - 10px);">' +
			'<div class="ld-input-inner-div ld-input-inner-add" tag="userid_after_transfer" name="userid_after_transfer_lastname" style="width:350px;line-height: 30px;padding-left: 8px;background: #fff;">'+this.pool_data['userid_after_transfer_lastname']+'</div>'+
			`<a class="ld-text-clear" style="top: 0;" name="clearusers" tag="userid_after_transfer" href="javascript:;" title="`+arrJsPopLabel['CLEAR']+`" >+</a>`+
			'<a class="icon-range lfloat" style="" href="javascript:;" title="选择" tag="userid_after_transfer" name="userid_after_transfer"></a>'+
			'</div>' +
			'</td></tr>';
		//客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）
		business_rules_html += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-label"><div style="display: flex;align-items: center;">'+this.fieldlabel_arr['AFTERRELEASINGTHEALLOCATEDHIGNSEAS']+
			'<i class="ld-fonticon ld-fonticon-help tip-items-list" data-tip="'+this.fieldlabel_arr['AFTERRELEASINGTHEALLOCATEDHIGNSEASDES']+'" data-direction="top" data-type="position"></i></div>'+
			'</td>' +
			'<td class="ld-form-item-content">' +
			'<div style="position: absolute;display: inline;top: calc(50% - 10px);">' +
			'<div class="ld-input-inner-div ld-input-inner-add" tag="userid_after_release" name="userid_after_release_lastname" style="width:350px;line-height: 30px;padding-left: 8px;background: #fff;">'+this.pool_data['userid_after_release_lastname']+'</div>'+
			`<a class="ld-text-clear" style="top: 0;" name="clearusers" tag="userid_after_release" href="javascript:;" title="`+arrJsPopLabel['CLEAR']+`" >+</a>`+
			'<a class="icon-range lfloat" style="" href="javascript:;" title="选择" tag="userid_after_release" name="userid_after_release"></a>'+
			'</div>' +
			'</td></tr>';

		business_rules_html += '</table>';

		business_rules_html = this.gettablecontent(this.fieldlabel_arr['Businessrules'],business_rules_html);
		return business_rules_html;
	}

	this.gettablecontent = function (label,content) {
		var table_content = '';
		table_content += '<div style="padding: 28px 24px 16px;">' +
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
		var btn_key_arr = ['en_name','zh_name','releasetype','allowget','poolmember_show_noallocate','allow_trasnfer_others','limit_count','limit_type','dataprofile',
			'allow_unallocated_showinall','allow_allocated_showinall'];
		var i = 0;
		for (i=0;i<btn_key_arr.length;i++){
			this.divobj.find('#'+btn_key_arr[i]).on('change',function () {
				that.changefun(this);
			})
			this.divobj.find('#'+btn_key_arr[i]).change();
		}

		ld("#"+this.popupobj.divid+ " #m_create_buttons").select2({closeOnSelect: false,dropdownParent:ld("#dv_create_buttons")});

		//绑定公海管理员切换事件
		this.set_account_public_select_user_bind();

		//绑定公海管理员权限设置按钮事件
		this.set_public_profile_bind();

		//绑定公海成员选择事件
		this.set_public_member_bind();

		//客户回收规则点击事件
		this.set_public_rule_event();
	}

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

				for(var i = 0; i < that.pool_data.administrators_lastname.length; i++){
					if(that.pool_data.administrators_lastname[i]['userid'] == remove_userid){
						that.pool_data.administrators_lastname.splice(i,1);
					}
				}
				that.pool_data['administrators'] = select_administrators_ids.join(',');
				that.reset_user_profile();
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
								that.pool_data['administrators'] = cls_ScopePopup.return_obj.return_id;
								var userid = cls_ScopePopup.return_obj.return_id.split(',');
								var username = cls_ScopePopup.return_obj.return_name.split(',');
								//每次确认之前，先情况之前记录
								ld('#'+popupobj.divid+' ul.reader-bar-list').empty();
								var new_arr = [];
								for(var i = 0; i < userid.length; i++){
									new_arr.push({'userid':userid[i],'last_name':username[i]})
								}
								that.pool_data.administrators_lastname = new_arr;
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
								that.reset_user_profile();
							}
							that.showKehu001UserName();
						});
					}
				});
			});
		});
	}
	// 刷新公海管理员信息区块
	this.reset_user_profile = function () {
		var pool_admin_set_thml = this.get_pool_admin_set_html();
		ld('#'+this.popupobj.divid+' #pool_admin_set').html(pool_admin_set_thml);
		this.set_account_public_select_user_bind();
		this.set_public_profile_bind();
	}

	this.changefun = function (obj) {
		var cur_obj = ld(obj);
		var cur_id = ld(obj).prop('id');
		var cur_type = ld(obj).prop('type')
		var cur_value = '';

		if(cur_type == 'checkbox'){
			cur_value = cur_obj.prop('checked')?'yes':'no';
		}else{
			cur_value = cur_obj.val();
		}
		this.pool_data[cur_id] = cur_value;

		if(cur_id == 'limit_type'){
			cur_obj.blur();
			if(cur_value == 'role'){
				this.divobj.find('#public_role_limit_count').show();
				this.divobj.find('#limit_count').hide();
			}else if(cur_value == 'user'){
				this.divobj.find('#public_role_limit_count').hide();
				this.divobj.find('#limit_count').show();
			}else {
				this.divobj.find('#public_role_limit_count').hide();
				this.divobj.find('#limit_count').hide();
			}
		}else if(cur_id == 'allowget'){
			if(cur_value == 'yes'){
				this.divobj.find('#tr_poolmember_show_noallocate').show();
			}else{
				this.divobj.find('#tr_poolmember_show_noallocate').hide();
				this.pool_data['poolmember_show_noallocate'] = 'no';
			}
		}

	}

	this.showKehu001UserName=function(){

		if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
			//通讯录(pc端企业微信)
			cls_wxOpenDataobj.bindAllOpenData();
	}

	this.set_public_member_bind = function () {
		var popupobj = this.popupobj;
		ld("#"+popupobj.divid+" [name=radioUser]").unbind('click').on('click',function(){
			var radiouser = ld(this).attr('value');
			if(radiouser == 'all'){
				ld("#"+popupobj.divid+" [name=usertype]").val('all');
				ld("#"+popupobj.divid+" [name=userids]").val('');
				that.pool_data['usertype'] = 'all';
				that.pool_data['userids'] = 'all';
			}else{
				var module = that.module;
				if(radiouser == 'user'){
					var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['LBL_USERS'];
					var file = 'viewuserinfo';
				}else{
					var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['USERGROUPLIST'];
					var file = 'viewgroupinfo';
				}
				//chj 2021/1/15 44284: 多公海->新建和编辑公海池设置公海成员问题：不应该控制成员范围，应该显示所有成员
				var popup_url = 'module=Users&action=UsersAjax&file='+file+'&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype='+radiouser;
				var userids = that.pool_data['userids'];
				getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
					scopepopupobj =  new ScopePopupObj(module);
					scopepopupobj.popup_caption_value = popup_caption_value;//标题title
					if(radiouser == 'group'){
						scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
						scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'></div>';
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
									that.pool_data['usertype'] = radiouser;
									that.pool_data['userids'] = selected_user;
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
							});
							return true;
						}
					});
				});
			}
		});

		// 绑定选择公海用户事件
		ld("#"+popupobj.divid+" [name=userid_after_transfer_lastname ],[name=userid_after_transfer],[name=userid_after_release_lastname ],[name=userid_after_release]").unbind('click').on('click',function(){
			var select_tag = ld(this).attr('tag');
			var select_userids = that.pool_data[select_tag];

			var usertype = '';
			var userids = 'all';
			usertype = that.pool_data['usertype'];
			userids = that.pool_data['userids'];

			var scopepopupobj;//自定义弹出层页面html，绑定事件
			var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
			var module = that.module;

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
								that.pool_data[select_tag] = cls_ScopePopup.return_obj.return_id;
								that.pool_data[select_tag+'_lastname'] = cls_ScopePopup.return_obj.return_name;
								ld("#"+popupobj.divid+" [name="+select_tag+"_lastname]").html(cls_ScopePopup.return_obj.return_name);
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
							}
							that.showKehu001UserName();
						});

					}
				});
			});
		});
		// 清除所选用户事件
		ld("#"+popupobj.divid).find("[name=clearusers]").unbind('click').on('click',function(){
			var select_tag = ld(this).attr('tag');
			ld("#"+popupobj.divid).find("[name="+select_tag+"_lastname]").html('');
			that.pool_data[select_tag] = '0';
			that.pool_data[select_tag+'_lastname'] = '';
		});
	}

	this.set_public_profile_bind = function () {
		this.divobj.find('[tag=profile_btn_all]').bind('click',function () {
			var actionid = ld(this).attr('actionid');
			var check_result = ld(this).prop('checked');
			that.divobj.find('[tag=profile_btn][actionid='+actionid+']').prop('checked',check_result);
			ld.each(that.user_profile_info,function (tmp_id,tmpinfo) {
				if(tmpinfo.includes(actionid) && !check_result){
					var index = tmpinfo.indexOf(actionid);
					tmpinfo.splice(index,1);
				}else if(!tmpinfo.includes(actionid) && check_result){
					tmpinfo.push(actionid);
				}
			})
		})

		this.divobj.find('[tag=profile_btn]').bind('click',function () {
			var actionid = ld(this).attr('actionid');
			var userid = ld(this).attr('userid');
			var check_result = ld(this).prop('checked');
			var tmpinfo = that.user_profile_info[userid];

			if(check_result){
				tmpinfo.push(actionid)
				var all_result = true;
				var userid_arr = that.pool_data['administrators'].split(',');
				ld.each(that.user_profile_info,function (tmp_id,tmpinfo) {
					if(!tmpinfo.includes(actionid) && userid_arr.includes(tmp_id)){
						all_result = false;
					}
				})
				that.divobj.find('[tag=profile_btn_all][actionid='+actionid+']').prop('checked',all_result);
			}else{
				var index = tmpinfo.indexOf(actionid);
				tmpinfo.splice(index,1);
				that.divobj.find('[tag=profile_btn_all][actionid='+actionid+']').prop('checked',false);
			}
		})
	}

	//拖动后对页签信息重新排序
	this.reset_list_table_sort = function(type){
		if(type  == 'public_rule'){
			var public_recovey_rule = this.public_recovey_rule;
			var tableobj = this.divobj.find("#public_rule_table");
			var trobjs = tableobj.find('tr[tag=public_rule_set]');
			var tmp_index = 0;
			var new_index_arr = [];
			ld.each(trobjs,function () {
				new_index_arr.push(ld(this).attr('programmeid'));
			})
			var list_tab_key_value = {};
			for (var i =0;i<public_recovey_rule.length;i++){
				list_tab_key_value[public_recovey_rule[i]['programmeid']] = public_recovey_rule[i];
			}
			for (var i =0;i<public_recovey_rule.length;i++){
				tableobj.find('tr[tag=public_rule_set][programmeid='+new_index_arr[tmp_index]+']').find('[name=seq_no]').html((tmp_index+1));
				this.public_recovey_rule[i] = list_tab_key_value[new_index_arr[tmp_index]];
				tmp_index ++;
			}
		}
	}

	//客户回收规则点击事件
	this.set_public_rule_event = function () {
		var basic_list_divobj = this.divobj.find('#public_rule');
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
				for (var j =0;j<that.public_recovey_rule.length;j++){
					if(that.public_recovey_rule[j]['programmeid'] == cur_programmeid){
						that.public_recovey_rule[j][cur_name] = cur_value;
					}
				}
			})
		}
		getJsScript('include/js/cls_circlerule_set.js', function () {
			var circleruleobj = new cls_circlerule_set(that.module,'public');
			circleruleobj.set_before_obj(that,'public_pool',that.fieldlabel_arr['recyclingscheme']);
			//新建
			basic_list_divobj.find('[name=public_rule_create]').on('click',function () {
				circleruleobj.editpopup(-1);
			})
			//编辑按钮
			basic_list_divobj.find('[name=public_rule_edit]').on('click',function () {
				var programmeid = ld(this).attr('programmeid');
				circleruleobj.editpopup(programmeid);
			})

			//删除按钮
			basic_list_divobj.find('[name=public_rule_delete]').on('click',function () {
				that.delete_public_rule(this);
			})
		});

		//回收方案拖拽
		if(!empty(this.public_recovey_rule) && this.public_recovey_rule.length >0){
			Sortable.create(this.divobj.find("#public_rule_table").find('tbody').get(0), {
				group: '',
				draggable: "[tag=public_rule_set]",
				handle: ".drag-handle",
				animation: 150,
				sort: true,
				onEnd: function (evt) {
					that.reset_list_table_sort('public_rule');
				}
			});
		}
	}
	//删除普通客户回收规则
	this.delete_public_rule = function (obj) {
		var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
		MessagePopup.TipTwo_warning(confirm_str);
		var remindpopup = CrmPopup.getPopupObj('last');
		var programmeid = ld(obj).attr('programmeid');
		ld('#'+remindpopup.divid+'_btnok').bind('click',function () {
			var deleted_index = -1;
			for (var i =0;i<that.public_recovey_rule.length;i++){
				if(that.public_recovey_rule[i]['programmeid'] == programmeid){
					deleted_index = i;
					break;
				}
			}
			if(deleted_index != -1){
				that.divobj.find('#public_rule_table').find('tr[tag=public_rule_set][programmeid='+programmeid+']').remove();
				that.public_recovey_rule.splice(deleted_index,1);
			}
		})
	}

	this.get_ruleinfo_byid = function (ruleid) {
		var tmp_info = [];
		var rule_arr = [];
		for (var i =0;i<this.public_recovey_rule.length;i++){
			if(this.public_recovey_rule[i]['programmeid'] == ruleid){
				//使用Object.assign 方法进行深复制 ,浅复制会导致弹出层内容没保存时直接修改原值 tmp_info = this.public_recovey_rule[i]
				for(var j=0;j<this.public_recovey_rule[i]['rule_arr'].length;j++){
					rule_arr.push(Object.assign({}, this.public_recovey_rule[i]['rule_arr'][j]));
				}
				tmp_info = Object.assign({}, this.public_recovey_rule[i]);
				tmp_info['rule_arr'] = rule_arr;
				break;
			}
		}
		return tmp_info;
	}

	this.set_ruleinfo_byid = function (ruleid,new_info) {
		var find_result = 'no';
		for (var i =0;i<this.public_recovey_rule.length;i++){
			if(this.public_recovey_rule[i]['programmeid'] == ruleid){
				this.public_recovey_rule[i] = new_info;
				find_result = 'yes';
				break;
			}
		}
		if(find_result == 'no'){
			this.public_recovey_rule.push(new_info);
		}
		console.log(this.public_recovey_rule);
		var publicrule_content = this.get_publicrule_html();
		this.divobj.find('#public_rule').html(publicrule_content);
		this.set_public_rule_event();
	}

	this.get_public_pool = function () {
		return this.public_pool;
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
	//回收方案里的数据较多，没必要全部传输，容易出问题
	this.get_public_return_info = function () {
		var return_info = [];
		var tmp_info = {};
		for (var i = 0;i<this.public_recovey_rule.length;i++){
			tmp_info = this.public_recovey_rule[i];
			return_info.push({'programmeid':tmp_info['programmeid'],'active':tmp_info['active'],'pool_id':tmp_info['pool_id'],'from_pool_id':tmp_info['from_pool_id']})
		}
		return return_info;
	}

	this.del_account_public_pool = function(pool_obj){
		var pool_id = ld(pool_obj).attr('pool_id');
		//var trobj=Tools.getParentobjByChild(ld(pool_obj),'tr');
		var filename = 'deletePublicAccountPool';
		if(this.module == 'Leads'){
			filename = 'deletePublicLeadsPool';
		}

		var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file='+filename+'&pool_id='+pool_id;
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"",arrJsPopLabel['CONFIRMED'],"","");
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.del_account_public_pool_save,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.prevshow();
				crmPopupobj.createScrollDiv();
				crmPopupobj.show(data.result.content);
			}
		})
	}

	this.del_account_public_pool_save =function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var prev_popupobj=CrmPopup.getPopupObj("lastprev");
		var pool_id = ld("#"+popupobj.divid+" [name=delete_pool_id]").val();
		var selected_pool_id = ld("#"+popupobj.divid+" [name=all_pool]").val();
		var confirm_str = arrJsPopLabel['afterdeletethehignseaspool'];
		var filename = 'deletePublicAccountPool';
		if(that.module == 'Leads'){
			filename = 'deletePublicLeadsPool';
			confirm_str = arrJsPopLabel['AFTERDELETETHELEADSHIGNSEASPOOL'];
		}
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file='+filename+'&pool_id='+pool_id+"&selected_pool_id="+selected_pool_id;
			ldAjax(surl,"",function(data){
				if(data.code==1){
					popupobj.CancelEvent();
					if(that.before_type == 'public_common'){
						that.before_obj.delete_public_pool(pool_id);
						prev_popupobj.center();
					}else{
						if(prev_popupobj.type && prev_popupobj.type==ListPagePopup.type){//列表页面要刷新列表
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
						}else{
							ld("#"+prev_popupobj.divid+" [name=tr_pool_id_"+pool_id+"]").hide();
							if(ld("#"+prev_popupobj.divid).find(".ld-category-drag:visible").length <= 1){
								ld("#"+prev_popupobj.divid).find(".ld-category-drag:visible").hide();
							}
							prev_popupobj.center();
						}

					}
					DelProgressObjs();
				}
			})
		})
		return false;
	}

}
cls_poolinfo_set.static_editpopup = function (module,pool_obj) {
	var circleruleobj = new cls_poolinfo_set(module);
	var popupobj = CrmPopup.getPopupObj('last');
	circleruleobj.set_before_obj(popupobj,'pool_info');
	//编辑按钮
	var pool_id = ld(pool_obj).attr('pool_id');
	circleruleobj.editpopup(pool_id);
}
cls_poolinfo_set.static_delete = function (module,pool_obj) {
	var circleruleobj = new cls_poolinfo_set(module);
	var popupobj = CrmPopup.getPopupObj('last');
	circleruleobj.set_before_obj(popupobj,'pool_info');
	//删除按钮
	circleruleobj.del_account_public_pool(pool_obj);
}



