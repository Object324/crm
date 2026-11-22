/*
*edit: duanjb
*date: 2024/07/17
*reason: 公海回收规则设置
*/
function cls_circlerule_set(module,circletype)
{
	var that = this;
	this.module = module;
	this.popupobj = '';
	this.fieldlabel_arr = []; //翻译数组
	this.divobj = '';
	this.before_type = '';
	this.before_obj = '';
	this.language_type = 'zh';
	this.circletype = circletype; //判断是普通回收规则还是公海回收规则
	this.ruleinfo = [];
	this.fieldlabel_arr = [];
	this.all_relation = [];
	this.public_pool = [];
	this.title = '';
	this.advanceFilterobj = null;

	this.set_before_obj = function (obj,type,title) {
		this.before_type = type;
		this.before_obj = obj;
		this.title = title;
	}

	this.editpopup = function (ruleid) {
		var rule_info = this.get_ruleinfo_byid(ruleid);
		this.public_pool = this.get_public_pool();

		if(!empty(rule_info)){
			this.ruleinfo = rule_info;
		}else{
			this.ruleinfo = {'advfilter':'','advfilter_grouping':'','programmeid':ruleid,'rule_arr':[],'active':'yes','programme_name':'回收方案','description':''};
			this.ruleinfo['beforereminddays'] = '';
			this.ruleinfo['objtainaccountcontroldays'] = '';
			this.ruleinfo['transfer_users_label'] = '';
			this.ruleinfo['transfer_users'] = '';
			if(this.circletype == 'public'){
				this.ruleinfo['programme_name'] = '公海回收方案';
				this.ruleinfo['from_pool_id'] = this.before_obj.pool_data['id'];
				this.ruleinfo['pool_id'] = this.before_obj.pool_data['id'];
			}else{
				this.ruleinfo['pool_id'] = this.public_pool[0]['id'];
			}
		}

		var surl = 'index.php?module='+this.module+'&action='+this.module+'Ajax&file=setRecoveyRule';
		surl += '&frommodule='+this.module;
		var param = {};
		param['circletype'] = this.circletype;
		param['advft_criteria'] = rule_info['advfilter'];
		param['advft_criteria_groups'] = rule_info['advfilter_grouping'];

		var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
		crmPopupobj.prevshow();
		this.popupobj = crmPopupobj;
		this.divobj = ld('#'+crmPopupobj.divid);
		this.popupobj.getDetailTableObj = function (){
			var tableobj = ld("#"+this.divid+" #circle_rule_table");
			return tableobj;
		}

		ldAjaxNoProgress(surl,param,function(data){
			if(data.code==1){

				that.setbasicinfo(data.result);

				crmPopupobj.setParams(that.title,that.circlerule_save,"","LdPopWidth1100px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.createScrollDiv();
				var advft_html = data.result.content;
				var all_html = that.CreatePopupHtml();
				crmPopupobj.show(all_html);
				//ld('#'+crmPopupobj.divid+' #circle_advft_html').html(advft_html);

				that.setBindPopupEvent();
				if(ruleid == -1){
					//新建时预置三条回收规则
					that.add_new_rule();
					that.add_new_rule();
					that.add_new_rule();
				}

				var paramobj = {};
				paramobj.source = data.result.source;
				paramobj.advfilterhtml = data.result.foption;
				paramobj.criteria_groups_arr = data.result.criteria_groups;
				paramobj.datetimestr = data.result.datetimestr;
				paramobj.arrJsPopupLabel = data.result.arrJsPopupLabel;
				paramobj.fLabels = data.result.flabels;
				// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
				paramobj.advanceFields = data.result.advanceFields;

				AjaxJSPage('cls_advanceFilter','include/js/cls_advanceFilter.js');
				var advanceFilterobj = new cls_advanceFilter();
				advanceFilterobj.setColumnOptionHtml(data.result.columns_block);
				advanceFilterobj.setParams(paramobj);
				advanceFilterobj.setPopupobj(crmPopupobj);
				advanceFilterobj.setDivid('circle_advft_html');
				advanceFilterobj.init();
				that.advanceFilterobj = advanceFilterobj;

				//旧版高级查找
				/*crmPopupobj.highersearchobj=new HigherSearchGroup("adv_filter_div");
				crmPopupobj.highersearchobj.columns_block=data.result.columns_block;//查询字段
				crmPopupobj.highersearchobj.fLabels=data.result.flabels;//查询条件下拉框（等于，不等于，区间 ，大于)
				crmPopupobj.highersearchobj.source=data.result.source;
				crmPopupobj.highersearchobj.foption=data.result.foption;//查询条件下拉框的html
				crmPopupobj.highersearchobj.criteria_groups=data.result.criteria_groups;//高级查询
				crmPopupobj.highersearchobj.mandatorycheck=data.result.mandatorycheck;
				crmPopupobj.showvalues=data.result.showvalues;
				crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
				crmPopupobj.viewnamelabel=data.result.viewnamelabel;
				crmPopupobj.modulelabel=data.result.modulelabel;
				crmPopupobj.highersearchobj.btn_addnewcondtiontext=data.result.btn_addnewcondtiontext;//高级查询 新条件 按钮文字
				crmPopupobj.highersearchobj.btn_addnewcombinationtext=data.result.btn_addnewcombinationtext;//高级查询　“新组合"按钮文字
				var  fori=0;
				crmPopupobj.highersearchobj.addNewConditionGroup=function() {
					this.addConditionGroup();
					this.addConditionRow(this.advft_group_index_count);
				}

				if(data.result.criteria_groups)
				{

					ld.each(data.result.criteria_groups,function(GROUP_ID,GROUP_CRITERIA){
						var GROUP_COLUMNS=GROUP_CRITERIA.columns;
						crmPopupobj.highersearchobj.addConditionGroup();
						ld.each(GROUP_COLUMNS,function(COLUMN_INDEX,COLUMN_CRITERIA){
							crmPopupobj.highersearchobj.addConditionRow(GROUP_ID);
							var advft_column_index_count=crmPopupobj.highersearchobj.advft_column_index_count;
							var conditionColumnRowElement = CrmPopup.findHtmlobj(crmPopupobj.divid,'fcol'+advft_column_index_count);
							conditionColumnRowElement.val(COLUMN_CRITERIA.columnname) ;
							//zkt 20230519 公海回收条件-编辑-对应高级查找条件
							var text = conditionColumnRowElement.find("option:selected").text();
							if(CrmPopup.findHtmlobj(crmPopupobj.divid,"cmb_span_optiontext_fcol"+advft_column_index_count).length>0){
								CrmPopup.findHtmlobj(crmPopupobj.divid,"cmb_span_optiontext_fcol"+advft_column_index_count).val(text);
							}
							crmPopupobj.highersearchobj.updatefOptions(conditionColumnRowElement, 'fop'+advft_column_index_count);
							CrmPopup.findHtmlobj(crmPopupobj.divid, 'fop'+advft_column_index_count).val(COLUMN_CRITERIA.comparator);
							crmPopupobj.highersearchobj.addRequiredElements(advft_column_index_count);
							var columnvalue = COLUMN_CRITERIA.value;
							if(COLUMN_CRITERIA.comparator == 'bw' && columnvalue != '') {
								var values = columnvalue.split(",");
								CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(values[0]) ;
								if(values.length == 2 && CrmPopup.isExistsObj(crmPopupobj.divid,'fval_ext'+advft_column_index_count))
									CrmPopup.findHtmlobj(crmPopupobj.divid,'fval_ext'+advft_column_index_count).val(values[1]) ;
							}
							else
							{
								if(columnvalue =='Accepted')
									CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(alert_arr.Accepted);
								else if(columnvalue =='Rejected')
									CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(alert_arr.Rejected);
								else{
									var values = columnvalue.split(",");
									CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val( values[0]);
								}
							}
						});

						ld.each(GROUP_COLUMNS,function(COLUMN_INDEX,COLUMN_CRITERIA){
							//查询字段下拉框
							if(CrmPopup.isExistsObj(crmPopupobj.divid,'fcon'+fori))
								CrmPopup.findHtmlobj(crmPopupobj.divid,'fcon'+fori).val(COLUMN_CRITERIA.column_condition);
							fori=fori+1;
						});

					});
					ld.each(data.result.criteria_groups,function(GROUP_ID,GROUP_CRITERIA){
						//组 且/或
						var GROUP_CRITERIA=data.result.criteria_groups[GROUP_ID];
						if(CrmPopup.isExistsObj(crmPopupobj.divid,'gpcon'+GROUP_ID))
							CrmPopup.findHtmlobj(crmPopupobj.divid,'gpcon'+GROUP_ID).val(GROUP_CRITERIA.condition);
					});

				}
				else{
					crmPopupobj.highersearchobj.addNewConditionGroup();
				}*/

				crmPopupobj.setScrollDivMaxHeight();
				crmPopupobj.center();
			}
		});


	}

	this.get_public_pool = function () {
		return this.before_obj.get_public_pool();
	}

	this.get_ruleinfo_byid = function (ruleid) {
		return this.before_obj.get_ruleinfo_byid(ruleid);
	}


	this.setbasicinfo = function (returndata) {
		this.fieldlabel_arr = returndata.fieldlabel_arr;
		this.language_type = returndata.language_type;
		this.all_relation = returndata.all_relation;
	}

	this.circlerule_save = function(){
		//因为绑定按钮事件的时候，对这个方法进行了重定向所以这里只能用that来获取对象
		var popupobj = that.popupobj;

		if(that.advanceFilterobj.checkAdvancedFilter()==false)
		{
			return false;
		}

		//自动回收规则设置天数必须输入大于等于1的整数！
		var daysbol=true;
		var textvalue = '';
		var tmp_status = '';
		for(var i =0;i<that.ruleinfo.rule_arr.length;i++){
			textvalue = that.ruleinfo.rule_arr[i]['days'];
			tmp_status = that.ruleinfo.rule_arr[i]['status'];
			//duan 20240923 BUG20240923-32：公海客户的回收规则，当规则不启用的时候，应该不判断是否“大于等于且小于等于5000”
			if(tmp_status == 'active'){
				if((!/^\d+$/.test(textvalue)||textvalue<1||textvalue>5000))
				{
					daysbol=false;
					break;
				}
			}
		}
		if(!daysbol)
		{
			confirm_str = arrJsPopLabel['DAYSMUSTGREATERQUZERO'];
			audioRemindsMsg("","","","","",confirm_str);
			return false;
		}

		// var advft_criteria = ld("#"+popupobj.divid+" [name=advft_criteria]").val();
		// var advft_criteria_groups = ld("#"+popupobj.divid+" [name=advft_criteria_groups]").val();
		that.ruleinfo['advfilter'] = that.advanceFilterobj.advft_criteria;
		that.ruleinfo['advfilter_grouping'] = that.advanceFilterobj.advft_criteria_groups;
		var param = {};
		param['ruleinfo'] = that.ruleinfo;
		param['mode'] = 'save';
		param['frommodule'] = that.module;
		param['circletype'] = that.circletype
		param['ruleid'] = that.ruleinfo['programmeid'];


		var surl = 'index.php?module=Accounts&action=AccountsAjax&file=setRecoveyRule&mode=save';

		ldAjaxNoProgress(surl,param,function(data){
			popupobj.CancelEvent();
			that.before_obj.set_ruleinfo_byid(data.result.ruleid,data.result.ruleinfo);
			MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
		})
	}

	//生成界面内容
	this.CreatePopupHtml = function () {
		var all_html = '';
		var div_style = '';

		// 回收规则基本设置区块
		var circle_set_html = this.get_circle_set_html();
		all_html += circle_set_html;
		// 设置公海回收条件
		var circle_advft_thml = '<div>'+this.get_circle_advft_html()+'</div>';
		all_html += circle_advft_thml;
		// 设置公海回收规则
		var circle_rule_html = '<div id="circle_rule_html" >'+this.get_circle_rule_html()+'</div>';
		all_html += circle_rule_html;
		// 公海业务规则
		var business_rules_html = '<div id="circle_rule_html" >'+this.get_business_rules_html()+'</div>';
		all_html += business_rules_html;

		return all_html;
	}

	//方案基本信息
	this.get_circle_set_html = function () {
		var circle_set_html = '';

		var circle_set_content = '';
		circle_set_content += '<tr class="ld-form-item">';
		//是否启用
		circle_set_content += '<td class="ld-form-item-label">' +
			'<label for="active">'+this.fieldlabel_arr['ENABLERECYCLINGSCHEME']+'</label>' +
			'</td>';
		circle_set_content += '<td class="ld-form-item-content">' +
			'<input class="second_switch"  type="checkbox" name="active" id="active" '+(this.ruleinfo['active'] == 'yes'?'checked':'')+' />' +
			'</td>';
		circle_set_content += '</tr><tr class="ld-form-item">';
		//回收至公海
		var option_html = '';
		var tmp_info = [];
		for (var i =0;i<this.public_pool.length;i++){
			tmp_info = this.public_pool[i];
			option_html += '<option value="'+tmp_info['id']+'" '+(this.ruleinfo['pool_id']==tmp_info['id']?'selected':'')+' >'+(this.language_type=='zh'?tmp_info['zh_name']:tmp_info['en_name'])+'</option>';
		}
		circle_set_content += '<td class="ld-form-item-label">' + this.fieldlabel_arr['recyclingtothehighseas'] +
			'</td>';
		circle_set_content += '<td class="ld-form-item-content">' +
			'<select class="ld-select-inner" id="pool_id" name="pool_id" >' +
			option_html +
			'</select>' +
			'</td>';
		circle_set_content += '</tr>';
		//方案名称
		circle_set_content += '<tr class="ld-form-item">';
		circle_set_content += '<td class="ld-form-item-label">' +this.fieldlabel_arr['SCHEMENAME'] +
			'</td>';
		circle_set_content += '<td class="ld-form-item-content"><div>' +
			'<input class="ld-input-inner" type="text" id="programme_name" name="programme_name" value="'+this.ruleinfo['programme_name']+'" />' +
			'</div></td>';
		circle_set_content += '</tr>';
		//方案说明
		circle_set_content += '<tr class="ld-form-item">';
		circle_set_content += '<td class="ld-form-item-label">' +this.fieldlabel_arr['SCHEMEDESCRIPTION'] +
			'</td>';
		circle_set_content += '<td class="ld-form-item-content"><div>' +
			'<textarea class="ld-textarea-inner" name="description" id="description" style="height: 32px;">'+this.ruleinfo['description']+'</textarea>' +
			'</div></td>';
		circle_set_content += '</tr>';

		circle_set_content = '<table class="ld-public-content-small padT0 padB8" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tbody>' +
			circle_set_content +
			'</tbody>' +
			'</table>';
		circle_set_html += this.gettablecontent(this.fieldlabel_arr['BASICINFO'],circle_set_content);
		return circle_set_html;
	}

	//高级查询
	this.get_circle_advft_html = function () {
		var circle_advft_html = '';

		var circle_advft_content = '<div id="circle_advft_html" style="padding: 0 24px 8px;"></div>';

		circle_advft_html += this.gettablecontent(this.fieldlabel_arr['RECYCLINGSCOPE'],circle_advft_content);
		return circle_advft_html;
	}

	//方案回收规则
	this.get_circle_rule_html = function () {
		var rule_arr = this.ruleinfo.rule_arr;

		var tmp_info = [];
		var i = 0;
		var j = 0;
		var circlerule_content = '';
		var all_circlerule_html = '';
		var tmp_content = '';

		var th_label_content = '';
		th_label_content += '<thead><tr >';
		//编号
		th_label_content += '<th style="width:4%;">#</th>';
		//规则类型
		th_label_content += '<th style="width:16%;">'+this.fieldlabel_arr['RULETYPE']+'</th>';
		//单据类型
		th_label_content += '<th style="width:55%;">'+this.fieldlabel_arr['BillType']+'</th>';
		//是否启用
		th_label_content += '<th style="width:9%;">'+this.fieldlabel_arr['WHETHERTOENABLE']+'</th>';
		//操作
		th_label_content += '<th style="width:5%;">'+this.fieldlabel_arr['OPERATING']+'</th>';
		//逻辑关系
		//th_label_content += '<th style="width:9%;">'+this.fieldlabel_arr['LOGICALRELATION']+'</th>';

		th_label_content += '</tr></thead>';
		//是否启用普通客户回收规则按钮
		var rule_condition = 'and';

		circlerule_content += '<div class="ld-pop-container ld-table-container ld-table-container-lines padB8">' +
			'<table class="publicpoolset" id="circle_rule_table" cellspacing="0" cellpadding="0" border="0">';
		circlerule_content += th_label_content;
		var tmp_class = '';
		var rule_type_arr = [{'key':'yes','label':this.fieldlabel_arr['RECYCLERULE']},{'key':'no','label':this.fieldlabel_arr['SINGLERULE']}];
		var condition_type_arr = [{'key':'or','label':this.fieldlabel_arr['OR']},{'key':'and','label':this.fieldlabel_arr['SEARCHAND']}];
		var tmp_label = '';
		var used_module_arr = [];
		var tmp_select_html = '';
		var tmp_input_html = '';
		var cur_condition = '';
		for (i = 0;i<rule_arr.length;i++){
			tmp_info = rule_arr[i];
			used_module_arr.push(tmp_info['tabname']);
		}

		for (i = 0;i<rule_arr.length;i++){
			tmp_info = rule_arr[i];
			tmp_content = '';

			tmp_select_html = '<select class="ld-select-inner circle_select" name="tabname" rule_id="'+tmp_info['id']+'" > ';
			tmp_info['show'] = 'no';
			for (j=0;j<this.all_relation.length;j++){
				if(this.all_relation[j]['key'] == tmp_info['tabname']){
					tmp_info['show'] = 'yes';
				}else if(used_module_arr.includes(this.all_relation[j]['key'])){

					continue;
				}
				tmp_select_html += '<option value="'+this.all_relation[j]['key']+'" '+(this.all_relation[j]['key']==tmp_info['tabname']?'selected':'')+' >'+this.all_relation[j]['label']+'</option>';
			}
			tmp_select_html += '</select>';
			if(tmp_info['show'] == 'no')continue;

			tmp_content += '<tr tag ="circle_rule_set" class="'+tmp_class+'" rule_id="'+tmp_info['id']+'" >';
			//编号
			tmp_content += '<td name="seq_no">'+(i+1)+'</td>';
			//规则类型
			tmp_content += '<td><select class="ld-select-inner" name="iscycle" rule_id="'+tmp_info['id']+'" >';
			for (j=0;j<rule_type_arr.length;j++){
				tmp_content += '<option value="'+rule_type_arr[j]['key']+'" '+(rule_type_arr[j]['key']==tmp_info['iscycle']?'selected':'')+' >'+rule_type_arr[j]['label']+'</option>';
			}
			tmp_content +='</select></td>';
			//单据类型
			if(tmp_info['iscycle'] == 'yes'){
				tmp_label = this.fieldlabel_arr['CIRCLERULELABEL'];
			}else{
				tmp_label = this.fieldlabel_arr['SINGLERULELABEL'];
			}
			tmp_input_html = '<input class="ld-input-inner circle_input" name="days" value="'+tmp_info['days']+'" rule_id="'+tmp_info['id']+'"  >';
			tmp_label = tmp_label.replace('{module}',tmp_select_html);
			tmp_label = tmp_label.replace('{var}',tmp_input_html);

			tmp_content += '<td style="white-space: normal;" >'+tmp_label+'</td>';
			//是否启用
			tmp_info['active_result'] = tmp_info['status']=='active'?'checked':'';
			tmp_content += '<td><input class="second_switch" type="checkbox" name="status" '+tmp_info['active_result']+' rule_id="'+tmp_info['id']+'" ></td>';
			//操作
			tmp_content += '<td ><div class="pool_btn_flex">'+
				'<a name="circle_rule_delete"  rule_id="'+tmp_info['id']+'" ><i class="ld-fonticon ld-fonticon-del"></i></a>'+
			 	'</div></td >';

			if(i == 0){
				if(empty(tmp_info['condition'])){
					cur_condition = 'or';
					tmp_info['condition'] = cur_condition;
				}else{
					cur_condition = tmp_info['condition'];
				}
			}else{
				if(empty(tmp_info['condition'])){
					tmp_info['condition'] = cur_condition;
				}
			}

			tmp_content += '</tr>';

			circlerule_content += tmp_content;
		}
		circlerule_content += '<tr>' +
			'<td colspan="5">' +
			'<div name="circle_rule_create" class="ld-btn-icontext-item">' +
			'<i class="ld-fonticon ld-fonticon-add" style="color: var(--ld-font-link-color);"></i>' +
			'<span style="color: var(--ld-font-link-color);">'+this.fieldlabel_arr['ADDRECYCLINGRULES']+'</span>' +
			'</div>' +
			'</td></tr>';
		circlerule_content += '</table></div>';

		if(tmp_info['condition'] == 'or'){
			tmp_label = '<i class="ld-fonticon ld-fonticon-help tip-items-list" data-tip="'+this.fieldlabel_arr['oneoftherulesmustbedone']+'" data-direction="top" data-type="position"></i>';
		}else{
			tmp_label = '<i class="ld-fonticon ld-fonticon-help tip-items-list" data-tip="'+this.fieldlabel_arr['alltherulesmustbedone']+'" data-direction="top" data-type="position"></i>';
		}
		var condition_content = '<select class="ld-select-inner" id="condition" name="condition" rule_id="'+tmp_info['id']+'" style="width: auto;margin: 0 8px;" >';
		for (j=0;j<condition_type_arr.length;j++){
			condition_content += '<option value="'+condition_type_arr[j]['key']+'" '+(condition_type_arr[j]['key']==cur_condition?'selected':'')+' >'+condition_type_arr[j]['label']+'</option>';
		}
		condition_content +='</select>';

		var rule_condition_html = '<table class="ld-public-content-small padT0 padB0" width="100%" cellspacing="0" cellpadding="0" border="0">' +
			'<tr class="ld-form-item">' +
			'<td class="ld-form-item-content" style="padding-left: 0px;width: 100%;">' +
			'<span >'+this.fieldlabel_arr['NORMALCUSTOMRECYCLE']+'</span>' +condition_content+ '<span class="colorRed paddT10" >'+tmp_label+'</span>'+
			'</td></tr></table>';

		circlerule_content = rule_condition_html + circlerule_content;

		all_circlerule_html += this.gettablecontent(this.fieldlabel_arr['recyclingrules'],circlerule_content);

		return all_circlerule_html;
	}

	this.gettablecontent = function (label,content) {
		var table_content = '';
		table_content += '<div style="padding: 20px 24px 16px;">' +
			'<div class="ld-pop-contnet-title-items">' +
			'<div class="ld-pop-contnet-title-item">'+label+'</div>' +
			'</div>' +
			'</div>';
		table_content += content;
		return table_content;
	}

	this.setBindPopupEvent = function () {
		//绑定按钮点击事件
		var popupobj = this.popupobj;
		var btn_key_arr = ['active','pool_id','programme_name','description','beforereminddays','objtainaccountcontroldays'];
		var i = 0;
		for (i=0;i<btn_key_arr.length;i++){
			this.divobj.find('#'+btn_key_arr[i]).on('change',function () {
				that.changefun(this);
			})
		}
		//绑定回收规则事件
		this.set_circle_rule_event();

		//beforereminddays,objtainaccountcontroldays,transfer_users_select,transfer_users_label
		// 绑定选择公海用户事件
		ld("#"+popupobj.divid+" [name=transfer_users_select],[name=transfer_users_label]").unbind('click').on('click',function(){
			var select_tag = ld(this).attr('tag');
			var select_userids = that.ruleinfo['transfer_users'];

			var usertype = '';
			var userids = 'all';
			for(var i = 0;i< that.public_pool.length;i++){
				if(that.public_pool[i]['id'] == that.ruleinfo['pool_id']){
					usertype = that.public_pool[i]['usertype'];
					userids = that.public_pool[i]['userids'];
				}
			}

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
								that.ruleinfo['transfer_users'] = cls_ScopePopup.return_obj.return_id;
								that.ruleinfo['transfer_users_label'] = cls_ScopePopup.return_obj.return_name;
								ld("#"+popupobj.divid+" [name=transfer_users_label]").html(cls_ScopePopup.return_obj.return_name);
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
							}
							that.showKehu001UserName();
						});

					}
				});
			});
		});
		// 清除所选用户事件
		ld("#"+popupobj.divid).find("[name=clearusers][tag=transfer_users_select]").off('click').on('click',function(){
			ld("#"+popupobj.divid).find("[name=transfer_users_label]").html('');
			that.ruleinfo['transfer_users'] = '';
			that.ruleinfo['transfer_users_label'] = '';
		});

	}
	//基本信息切换事件
	this.changefun = function(obj){
		var cur_obj = ld(obj);
		var cur_id = ld(obj).prop('id');
		var cur_type = ld(obj).prop('type')
		var cur_value = '';

		if(cur_type == 'checkbox'){
			cur_value = cur_obj.prop('checked')?'yes':'no';
		}else{
			cur_value = cur_obj.val();
		}
		this.ruleinfo[cur_id] = cur_value;
		if(cur_id == 'condition'){
			for (var i = 0;i<this.ruleinfo.rule_arr.length;i++){
				this.ruleinfo.rule_arr[i]['condition'] = cur_value;
			}
			this.reset_circle_rule_content();
		}else if(cur_id == 'pool_id'){
			this.ruleinfo['transfer_users'] = '';
			this.ruleinfo['transfer_users_label'] = '';
			ld("#"+this.popupobj.divid+" [name=transfer_users_label]").html('');
		}
	}
	//绑定回收规则事件
	this.set_circle_rule_event = function () {
		var basic_circle_ruleobj = this.divobj.find('#circle_rule_html');
		basic_circle_ruleobj.find('#condition').on('change',function () {
			that.changefun(this);
		})
		var btn_key_arr = ['iscycle', 'tabname', 'days', 'status'];
		var i = 0;
		for (i = 0; i < btn_key_arr.length; i++) {
			basic_circle_ruleobj.find('[name=' + btn_key_arr[i] + ']').on('change', function () {
				that.circlechangefun(this);
			})
		}
		//新增按钮事件
		basic_circle_ruleobj.find('[name=circle_rule_create]').on('click', function () {
			that.add_new_rule();
		})
		//删除按钮事件
		basic_circle_ruleobj.find('[name=circle_rule_delete]').on('click', function () {
			var rule_id = ld(this).attr('rule_id');
			var rule_arr = that.ruleinfo.rule_arr;
			for (var i = 0;i<rule_arr.length;i++){
				if(rule_arr[i]['id'] == rule_id){
					rule_arr.splice(i,1);
					break;
				}
			}
			that.reset_circle_rule_content();
		})
		tooltip(ld('#'+that.popupobj.divid+' .tip-items-list'), {transition: true, time: 200});
	}

	this.add_new_rule = function () {
		var ruleid = 1;
		var used_module_arr = [];
		var rule_arr = that.ruleinfo.rule_arr;
		var cur_module = '';
		var condition = 'or';
		if(!empty(rule_arr)){
			ruleid = rule_arr.length +1;
			for (var i = 0;i<rule_arr.length;i++){
				if(rule_arr[i]['id'] >= ruleid){
					ruleid = rule_arr[i]['id'] + 1;
				}
				used_module_arr.push(rule_arr[i]['tabname']);
			}
		}

		for (var j=0;j<this.all_relation.length;j++){
			if(used_module_arr.includes(this.all_relation[j]['key'])){
				continue;
			}else{
				cur_module = this.all_relation[j]['key'];
				condition = this.all_relation[j]['condition'];

				var tmp_rule_arr = {'id':ruleid,'status':'active','iscycle':'yes','days':'30','condition':condition,'tabname':cur_module,'tablabel':this.all_relation[j]['label']};
				that.ruleinfo.rule_arr.push(tmp_rule_arr);
				used_module_arr.push(cur_module);
				break;
			}
		}
		var basic_circle_ruleobj = this.divobj.find('#circle_rule_html');
		var btnobj = basic_circle_ruleobj.find('[name=circle_rule_create]');
		if(!empty(cur_module)){

			if(used_module_arr.length == this.all_relation.length){
				btnobj.hide();
			}else{
				btnobj.show();
			}
			this.reset_circle_rule_content();
		}else{
			btnobj.hide();
		}
	}

	this.circlechangefun = function (obj) {
		var cur_obj = ld(obj);
		var cur_name = cur_obj.prop('name');
		var cur_rule_id = cur_obj.attr('rule_id');
		var tmp_info = '';
		var cur_value = '';
		var basic_circle_ruleobj = this.divobj.find('#circle_rule_html');
		if(cur_name == 'status' ){
			cur_value = cur_obj.prop('checked')?'active':'inactive';
		}else{
			cur_value = cur_obj.val();
		}

		for(var i=0;i<this.ruleinfo.rule_arr.length;i++){
			tmp_info = this.ruleinfo.rule_arr[i];
			if(tmp_info['id'] == cur_rule_id){
				this.ruleinfo.rule_arr[i][cur_name] = cur_value;
				if(cur_name == 'tabname'){
					this.ruleinfo.rule_arr[i]['tablabel'] = cur_obj.find('option:selected').html();
				}
			}
		}

		if(cur_name == 'iscycle' || cur_name == 'tabname'){
			this.reset_circle_rule_content();
		}

	}
	// 刷新回收规则
	this.reset_circle_rule_content = function () {
		var circle_rule_html = this.get_circle_rule_html();
		this.divobj.find('#circle_rule_html').html(circle_rule_html);
		this.set_circle_rule_event();
	}
	// 设置业务规则
	this.get_business_rules_html = function () {
		var business_rules_html = '';

		business_rules_html += '<table class="ld-public-content-small" style="padding-top: 0;" width="100%" cellspacing="0" cellpadding="0" border="0">';

		business_rules_html += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-content" style="padding-left: 0;width: 100%;">' +
			'<span>'+this.fieldlabel_arr['BEFOREREMINDDAYSCUSTOMER']+'</span>' +
			'<input id="beforereminddays" class="ld-input-inner" style="width: 100px;" value="'+(empty(this.ruleinfo['beforereminddays'])?'':this.ruleinfo['beforereminddays'])+'" />' +
			'</td></tr>';

		var label = this.fieldlabel_arr['ObjtainAccountControlDays'];
		var input_html = '<input id="objtainaccountcontroldays" class="ld-input-inner" style="width: 40px;margin: 0 5px;" value="'+(empty(this.ruleinfo['objtainaccountcontroldays'])?'':this.ruleinfo['objtainaccountcontroldays'])+'" />'
		label = label.replace('__',input_html);

		business_rules_html += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-content" style="padding-left: 0;width: 100%;">' +
			'<span>'+label+'</span>' +
			'</td></tr>';

		business_rules_html += '<tr class="ld-form-item">' +
			'<td class="ld-form-item-content" style="padding-left: 0;width: 100%;">' +
			'<span>'+this.fieldlabel_arr['AUTOMATICRECOVERYMODIFYOWNER']+'</span><div style="position: absolute;display: inline;">' +
			'<div class="ld-input-inner-div ld-input-inner-add" name="transfer_users_label" style="width:200px;line-height: 30px;padding-left: 8px;background: #fff;">'+this.ruleinfo['transfer_users_label']+'</div>'+
			'<a class="ld-text-clear" name="clearusers" tag="transfer_users_select" href="javascript:;" title="'+arrJsPopLabel['CLEAR']+'" style="top: 0;">+</a>'+
			'<a class="icon-range lfloat" style="" href="javascript:;" title="选择" tag="userid_after_transfer" name="transfer_users_select"></a>'+
			'</div></td></tr>';


		business_rules_html += '</table>';

		business_rules_html = this.gettablecontent(this.fieldlabel_arr['Businessrules'],business_rules_html);
		return business_rules_html;
	}

	this.showKehu001UserName=function(){
		if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
			//通讯录(pc端企业微信)
			cls_wxOpenDataobj.bindAllOpenData();
	}
}
