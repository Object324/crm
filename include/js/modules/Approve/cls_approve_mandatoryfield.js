/*
* edit:duan
* date:20320713
* reason:后台审批设置必填字段操作类
* */
function cls_approve_mandatoryfield(frommodule){
	var that = this;
	this.popupobj = '';
	this.tableobj = '';
	//必填字段信息
	this.mandatoryfield_arr = [];
	this.mandatoryfieldlabel_arr = [];
	//审批方式信息
	this.approveresult_arr = [];
	this.approveresult_label_arr = {};
	this.cur_rowid = -1;
	this.frommodule = frommodule;
	this.isnewapprove = '';
	this.addsign = 'yes';
	//设置审批方式选项
	this.setApproveResult = function (){
		if(this.addsign == 'yes'){
			this.approveresult_arr = ['pass','addsign','back','reject'];
		}else{
			this.approveresult_arr = ['pass','back','reject'];
		}

		this.approveresult_label_arr['pass'] = arrJsPopLabel['APPROVERESULTPASS'];
		this.approveresult_label_arr['addsign'] = arrJsPopLabel['APPROVERESULTADDSIGN'];
		this.approveresult_label_arr['back'] = arrJsPopLabel['APPROVERESULTBACK'];
		this.approveresult_label_arr['reject'] = arrJsPopLabel['APPROVERESULTREJECT'];
	}
	//设置弹出层对象
	this.setPopupobj = function (popupobj){
		this.popupobj = popupobj;
	}
	//设置字段标签数组
	this.setMandatoryFieldlabelArr = function (mandatoryfieldlabel_arr){
		this.mandatoryfieldlabel_arr = mandatoryfieldlabel_arr;
	}
	//获取table对象
	this.getTableobj = function (){
		var table_divid = 'tablemodulefield';
		this.tableobj = ld("#"+this.popupobj.divid+" #"+table_divid);
		return this.tableobj;
	}
	//生成所需要的table元素
	this.CreateTableHtml = function (parent_obj){
		this.setApproveResult();
		var popupobj = this.popupobj;
		// ljj 20240315 BUG20240206-06 旧审批界面设置审批步骤--基本信息-审批必填-时，界面显示有问题
		if (popupobj.isnewapprove == 'no'){
			this.isnewapprove = 'no';
			var html='<table id="tablemodulefield" name="tablemodulefield" class="settingPopTable lasttdbordernon"  width="100%" cellspacing="0" cellpadding="0" border="0">'
			html += '<tr rowid="-1" ><th width="20%" >审批方式</th><th width="60%">必填字段</th><th width="20%">操作</th></tr>';
			html += '</table>';
			html += '<div><input class="createauto" type="button" id="btn_mandatoryfield" value="'+arrJsPopLabel['NEW']+'" style="margin-left: 7px;"></div>';
		}else {
			var html='<table class="ld-approve-tablecontent lasttdbordernon DetailContentTable" name="tablemodulefield" id="tablemodulefield" width="100%" cellspacing="0" cellpadding="0" border="0">'+
				'<tr>' +
				'<th class="ld-from-headblock" width="90%" colspan="3"><div class="ld-from-headblock-title">审批方式设置<input class="ld-button ld-button-primary" style="margin-top: -6px;float:right" type="button" id="btn_mandatoryfield" value="'+arrJsPopLabel['NEW']+'"></div></th>'+
				'</tr>';
			html += '<tr rowid="-1" ><td width="30%" >审批方式</td><td width="60%">必填字段</td><td width="10%">操作</td>' +
				'</tr>';
			html += '</table>';
		}
		parent_obj.html(ld(html));
		//判断是否已存在数据，如果存在，则添加行
		var tmp_rowid = this.cur_rowid;
		var tmp_len = this.mandatoryfield_arr.length;
		var tmp_trobj = '';
		var tmp_approvefun = '';
		var tableobj = this.getTableobj();
		this.cur_rowid = -1;
		if(tmp_len >0){
			var i = 0;
			for(i=0;i<tmp_len;i++){
				tmp_approvefun = this.mandatoryfield_arr[i].approvefunc;
				if(!this.approveresult_arr.includes(tmp_approvefun)){
					continue;
				}
				this.addRow('edit');
				tmp_rowid = this.cur_rowid;
				tmp_trobj = tableobj.find('tr[rowid='+tmp_rowid+']');
				tmp_trobj.find('#approvefunc').val(tmp_approvefun);
				tmp_trobj.find('#mandatoryfield').val(this.getFieldLabel(this.mandatoryfield_arr[i].mandatoryfield));
			}
		}else{
			this.addRow('create');
		}

		//设置添加行按钮事件
		ld('#'+popupobj.divid+' #btn_mandatoryfield').bind('click',function () {
			that.addRow('create');
		})
		that.changeOption();
	}
	//添加行
	this.addRow = function (type){
		var rowid = this.cur_rowid + 1;
		this.cur_rowid = rowid;
		var tableobj = this.getTableobj();
		//设置行html
		var trhtml = '<tr rowid="'+rowid+'" >';
		//审批方式
		var tdhtml_1 = '<td>';
		var tmp_str = '';
		var tmp_option_html = '';
		var tmp_len = this.approveresult_arr.length;
		var i = 0;
		var existed_approve_arr = [];
		var cur_approvefunc = '';
		tableobj.find("select#approvefunc").each(function(){
			existed_approve_arr.push(ld(this).val());
		});
		//增加所有的审批方式
		for(i=0;i<tmp_len;i++){
			tmp_str = this.approveresult_arr[i];
			if(!existed_approve_arr.includes(tmp_str)||(type == 'edit'&& that.mandatoryfield_arr[this.cur_rowid].approvefunc==tmp_str)){//BUG0070745 xxy 2023-8-25 审批流程定制-应控制审批方式不能重复 所以新增行时，去掉已经被选中过的选项
				if(empty(cur_approvefunc))cur_approvefunc = tmp_str;
				tmp_option_html += '<option value="'+tmp_str+'">'+this.approveresult_label_arr[tmp_str]+'</option>';
			}
		}
		if(type == 'create'){
			that.add_updateOtherSelects(tmp_option_html);
		}
		if(tmp_option_html == ''){
			MessagePopup.TipOne_warning('已添加所有审批方式')
		}
		// ljj 20240315 BUG20240206-06 旧审批界面设置审批步骤--基本信息-审批必填-时，界面显示有问题
		if (this.isnewapprove == 'no'){
			tdhtml_1 += '<select class="commonSelectPop gwidth95" id="approvefunc" style="width: 140px">'+tmp_option_html+'</select>';
		}else {
			tdhtml_1 += '<select class="ld-select-inner gwidth70" id="approvefunc">'+tmp_option_html+'</select>';
		}
		tdhtml_1 += '</td>';
		trhtml += tdhtml_1;
		//必填字段
		var tdhtml_2 = '<td>';
		// ljj 20240315 BUG20240206-06 旧审批界面设置审批步骤--基本信息-审批必填-时，界面显示有问题
		if (this.isnewapprove == 'no'){
			tdhtml_2 += '<input readonly="readonly"  id="mandatoryfield" class="advanceTextBox  gwidth85 bgwhite" type="text" style="cursor: pointer;height: 30px;">';
		}else {
			tdhtml_2 += '<input readonly="readonly"  id="mandatoryfield" class="ld-input-inner" type="text">';
		}
		tdhtml_2 += '</td>';
		trhtml += tdhtml_2;
		//操作
		var tdhtml_3 = '<td>';
		// ljj 20240315 BUG20240206-06 旧审批界面设置审批步骤--基本信息-审批必填-时，界面显示有问题
		if (this.isnewapprove == 'no'){
			tdhtml_3 += '<a class="Anu3_a" href="javascript:;" id="deletebtn">'+arrJsPopLabel['DELETE']+'</a>';
		}else {
			tdhtml_3+='<a class="ld-category-icon ld-category-del" href="javascript:void(0);" id="deletebtn" title="'+ arrJsPopLabel['DELETE']+'"></a>';
		}
		tdhtml_3 += '</td>';
		trhtml += tdhtml_3;

		trhtml += '</tr>';
		//将生成的元素添加到table中
		var popupobj = this.popupobj;
		tableobj.append(ld(trhtml));
		//对元素进行基础的赋值
		if(type == 'create'){
			var rowinfo = {'approvefunc':cur_approvefunc,'mandatoryfield':''};
			this.mandatoryfield_arr[rowid] = rowinfo;
		}
		var trobj = tableobj.find('tr[rowid='+rowid+']');

		//绑定元素的点击事件
		trobj.find("#approvefunc").unbind('change').bind('change',function (){
			that.mandatoryfield_arr[rowid].approvefunc = ld(this).val();
		})
		trobj.find("#mandatoryfield").unbind('click').bind('click',function (){
			that.MandatoryFieldSetting(rowid);
		})
		trobj.find("#deletebtn").unbind('click').bind('click',function (){
			that.deleteRow(rowid);
		})
		that.showAddBtn();
	}

	//删除行
	this.deleteRow = function (rowid){
		var tableobj = this.getTableobj();
		var trobj = tableobj.find('tr[rowid='+rowid+']');
		ld(trobj).remove();
		that.mandatoryfield_arr[rowid].approvefunc = '';
		that.mandatoryfield_arr[rowid].mandatoryfield = '';
		this.del_updateOtherSelects(trobj);
		that.showAddBtn();

	}

	//设置必填字段弹出层
	this.MandatoryFieldSetting = function (rowid){
		var module = this.frommodule;
		var choose_fieldname = that.mandatoryfield_arr[rowid].mandatoryfield;
		var surl = "index.php?module=Approve&action=ApproveAjax&file=setMandatoryField";
		surl += '&frommodule='+module+'&choose_fieldname='+choose_fieldname;
		var Width = 'LdPopWidth800px';
		var crmPopupobj=CrmPopup.load("","","",Width,'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjax(surl,'',function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.saveMandatoryField,"",Width,module,[rowid],data.result.oktext,"",data.result.canceltext);
				crmPopupobj.show(data.result.content);
				ld("#"+crmPopupobj.divid).addClass("popMarginPadding");
			
				var tableobj = ld('#'+crmPopupobj.divid).find(" #FieldList").parents("table");
				var LeftObj = tableobj.find(" #FieldList");
				var RightObj = tableobj.find(" #selectedFieldColumns");
				var Drag_Transfer = new DragTransfer();
				Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','270');
				popupobj.center();
			}
			DelProgressObjs();
		})
	}
	//将选中的字段保存到数组中
	this.saveMandatoryField = function (rowid){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		var selectedColumnsObj=getObj("selectedFieldColumns");
		var selectedCol_arr = [];
		var fieldlabel_arr = [];
		for (i=0;i<selectedColumnsObj.options.length;i++)
		{
			selectedCol_arr.push(selectedColumnsObj.options[i].value);
			fieldlabel_arr.push(selectedColumnsObj.options[i].text);
		}
		popupobj.CancelEvent();

		var tableobj = that.getTableobj();
		var trboj = tableobj.find('tr[rowid='+rowid+']');
		trboj.find('#mandatoryfield').val(fieldlabel_arr.join(','));
		that.mandatoryfield_arr[rowid].mandatoryfield = selectedCol_arr.join(',');
	}

	//获取已设置的必填字段信息
	this.getMandatoryField = function (){
		var new_arr = [];
		var tmp_len = this.mandatoryfield_arr.length;
		var i = 0;
		var tmp_rowinfo = '';
		//循环排除可能为空的行
		for(i=0;i<tmp_len;i++){
			tmp_rowinfo = that.mandatoryfield_arr[i];
			//行数据为空或者审批方式为空,都视为空
			if(!empty(tmp_rowinfo) && !empty(tmp_rowinfo.approvefunc) && !empty(tmp_rowinfo.mandatoryfield)){
				new_arr.push(tmp_rowinfo);
			}
		}
		var json_str = JSON.stringify(new_arr);
		return json_str;
	}
	//设置读取到的必填字段信息
	this.setMandatoryField = function (json_str){
		var new_arr = [];
		if(!empty(json_str)){
			new_arr = JSON.parse(json_str);
		}
		this.mandatoryfield_arr = new_arr;
	}

	//根据字段的fieldname读取fieldlabel
	this.getFieldLabel = function (fieldname_str){
		var fieldname_arr = fieldname_str.split(',');
		var fieldlabel_arr = [];
		var mandatoryfieldlabel_arr =  this.mandatoryfieldlabel_arr;
		var tmp_str = '';
		var tmp_arr = [];
		for(var i = 0;i<fieldname_arr.length;i++){
			tmp_arr = fieldname_arr[i].split(':');
			//解析完整的字段名,例如:ld_account:industry:industry:Accounts_fieldlabel:V
			if(tmp_arr.length != undefined && tmp_arr.length>=3){
				tmp_str = tmp_arr[2];
				if(!empty(mandatoryfieldlabel_arr[tmp_str])){
					fieldlabel_arr.push(mandatoryfieldlabel_arr[tmp_str]);
				}
			}
		}
		var fieldlabel_str = fieldlabel_arr.join(',');
		return fieldlabel_str;
	}
	//BUG0070745 xxy 2023-8-25 审批流程定制-应控制审批方式不能重复
	//改变下拉框值时，改变每个下拉框的选项，去除当前已被选中值的选项
	this.updateOtherSelects = function() {
		var tableobj = this.getTableobj();
		var selectedValues = [];
		tableobj.find("select#approvefunc").each(function() {
			selectedValues.push(ld(this).val());
		});
		var availableOptions = this.approveresult_arr.filter(option => !selectedValues.includes(option));

		// 更新每一个 select
		tableobj.find("select#approvefunc").each(function() {
			var thisSelect = ld(this);
			var currentValue = thisSelect.val();
			var currentText = thisSelect.find("option:selected").text();

			// 清空当前的选项，然后添加当前的值作为默认选中的选项
			thisSelect.empty().append(`<option value="${currentValue}">${currentText}</option>`);

			// 添加其他未被选中的选项
			availableOptions.forEach(option => {
				thisSelect.append(`<option value="${option}">${that.approveresult_label_arr[option]}</option>`);
			});
		});
    }
	//动态修改option值，使其不重复
	this.changeOption = function (){
		var tableobj = this.getTableobj();
		tableobj.on('change', 'select#approvefunc', function() {
			that.updateOtherSelects();
		});
	}
	//新增行时，根据新增行的默认选中值更新其他下拉框的选项
	this.add_updateOtherSelects = function(htmlString) {
		var tableobj = this.getTableobj();
		var tempOption = ld(htmlString);
    	var selectedValue = tempOption.val();
		// 从其他所有下拉框中移除当前选中的值
		tableobj.find("select#approvefunc").each(function() {
			ld(this).find('option[value="' + selectedValue + '"]').remove();
		});
	}
	//删除行时，根据新增行的默认选中值更新其他下拉框的选项
	this.del_updateOtherSelects = function(obj) {
		var tableobj = this.getTableobj();
		var selectObj = ld(obj).find('select')
		var optionValie = selectObj.val();
		var optionText = selectObj.find('option:selected').text();
	
		// 添加值到其他所有下拉框中
		tableobj.find("select#approvefunc").each(function() {
			// 检查当前 select 是否已经有这个选项
			if (!ld(this).find('option[value="' + optionValie + '"]').length) {
				ld(this).append(`<option value="${optionValie}">${optionText}</option>`);
			}
		});
	}
	//根据是否已经有所有的审批方式下拉框来判断是否显示新增按钮
	this.showAddBtn = function (){
		var tableobj = this.getTableobj();
		var popupobj = this.popupobj;
		var existed_approve_arr = [];
		var show_addbtn = false;
		tableobj.find("select#approvefunc").each(function(){
			existed_approve_arr.push(ld(this).val());
		});
		for (var item of that.approveresult_arr) {
			if (!existed_approve_arr.includes(item)) {
				show_addbtn = true;
			}
		}
		if(!show_addbtn){
			ld('#'+popupobj.divid+' #btn_mandatoryfield').hide()
		}else{
			ld('#'+popupobj.divid+' #btn_mandatoryfield').show()
		}
	}
	//加签按钮变化事件
	this.after_change_sign = function (obj,parent_obj) {
		this.addsign = ld(obj).prop('checked')?'yes':'no';
		this.CreateTableHtml(parent_obj);
		this.updateOtherSelects();
		this.showAddBtn();
	}
}
//控制字段显示样式
cls_approve_mandatoryfield.resetfield = function (popupobj,result) {
	var mandatory_field_arr = result.mandatory_field_arr;
	var trobj= ld("#"+popupobj.divid+" #tr_mandatory_field");
	if(mandatory_field_arr != undefined && mandatory_field_arr.length >0){
		trobj.show();
		//var prevpopupobj = CrmPopup.getPopupObj("lastprev");
		var prevpopupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
		popupobj.mandatory_field_arr = mandatory_field_arr;
		popupobj.fields = prevpopupobj.fields;
		popupobj.fieldname_fields = prevpopupobj.fieldname_fields;
		popupobj.picklist_arrow_click = prevpopupobj.picklist_arrow_click;
		popupobj.picklist_end_foucs = prevpopupobj.picklist_end_foucs;
		popupobj.picklistobjarray = prevpopupobj.picklistobjarray;
		popupobj.picklistcontent = prevpopupobj.picklistcontent;
		popupobj.isadmin = result.isadmin;

		ld.each(popupobj.mandatory_field_arr, function (tmpindex, fieldinfo) {
			popupobj.fieldname_fields[fieldinfo.fieldname] = fieldinfo;
		})

		popupobj.label_arr = result.label_arr;
		var approvedata = result.approvedata;
		if(approvedata.filejsondata != undefined){
			popupobj.filejsondata = approvedata.filejsondata;
		}
		if(approvedata.sourcemodule != undefined){
			popupobj.sourcemodule_arr = approvedata.sourcemodule;
		}
		popupobj.fields = mandatory_field_arr;

		if(approvedata.mainfieldformula != undefined){
			popupobj.mainfieldformulaobj=new cls_mainfieldformula(approvedata.mainfieldformula);
			popupobj.mainfieldformulaobj.setPopupobj(popupobj);
			popupobj.mainfieldformulaobj.init();
			popupobj.mainfieldformulaobj.setEvent();
		}
		var tdobjs = ld(trobj).find('td.DetailedTd2Info');

		var tmp_fieldobj = '';
		var tmp_fieldname = '';
		var tmpdivid = popupobj.divid;
		var orgin_fields = popupobj.fields;
		
		popupobj.ueditor_fieldname_arr = new Array();
		var choose_fieldname_arr = new Array();
		for(var i=0;i<mandatory_field_arr.length;i++){
			choose_fieldname_arr.push(mandatory_field_arr[i].fieldname);
		}
		//绑定字段切换事件
		var common_field_event_obj = new cls_common_field_event(popupobj);
		common_field_event_obj.set_use_field_arr(mandatory_field_arr);
		popupobj.common_field_event_obj = common_field_event_obj;
		popupobj.common_field_event_obj.setEvent();

		for(var i=0;i<mandatory_field_arr.length;i++){
			tmp_fieldobj = mandatory_field_arr[i];
			tmp_fieldname = tmp_fieldobj.fieldname;
			if(!choose_fieldname_arr.includes(tmp_fieldname)){
				continue;
			}

			if(SaveDataRecord.isfileattachUitype(tmp_fieldobj.uitype))
			{
				var fileuploader=CrmPopup.findHtmlobj(tmpdivid,tmp_fieldname);
				if(fileuploader.length>0)
				{
					var uploadFile = new WebUploadFile();
					uploadFile.set_file_fields(mandatory_field_arr);
					globalWebUploadType = uploadFile.getScript(globalWebUploadType);


					uploadFile.setEvent(globalWebUploadType,fileuploader,popupobj,i);
				}

				if(tmp_fieldobj.uitype==28)
				{
					popupobj.docfilename=tmp_fieldname;
					showType();

				}
				window.setTimeout(function (i) {

					if(tmp_fieldobj.allowedit=='no'){
						ld('#'+tmpdivid+" [name="+tmp_fieldname+"]").find(" [tag=deletefile]").remove();
						ld('#'+tmpdivid+" [name="+tmp_fieldname+"]").find(" .webuploader-pick").remove();
						ld('#'+tmpdivid+" [name="+tmp_fieldname+"]").find(" [name=file]").parent().remove();
					}
				},200,i);
			}else if(tmp_fieldobj.uitype==33){
				//修改多选框显示
				var tmpfieldname=tmp_fieldname;
				ld('#'+tmpdivid+" [name='"+tmpfieldname+"[]']").select2({closeOnSelect: false, dropdownParent: ld("#"+tmpdivid)});
			}else if(tmp_fieldobj.uitype==202){
				//重新设置选择源单按钮事件
				var selectsourceobj = CrmPopup.findHtmlobj(tmpdivid,'selectsource');
				var selectlistvalobj = CrmPopup.findHtmlobj(tmpdivid,'selectlistval');
				var selectlistlabelobj = CrmPopup.findHtmlobj(tmpdivid,'selectlistval_label');
				selectsourceobj.attr('onchange','').bind('change',function (){
					selectlistvalobj.val('');
					selectlistlabelobj.val('');
				})
				selectlistlabelobj.parent().find('[name=selectlistval_icon_select]').attr('onclick','').bind('click',function (){
					getJsScript('include/js/SystemPopup/MultiplePopup.js',function () {
						var chooseentityidarr = [];
						if(selectsourceobj.val() == ''){
							MessagePopup.TipOne_warning(popupobj.label_arr.SELECTTHESOURCEDOCUMENTTYPE);
							return '';
						}
						if(selectlistvalobj.val() != ''){
							chooseentityidarr = selectlistvalobj.val().split(',');
						}
						var MultiplePopupobj = new MultiplePopup();
						MultiplePopupobj.init(selectsourceobj.val(),'',popupobj.module);
						MultiplePopupobj.width = CrmPopup.getClientWidth()*0.8;
						MultiplePopupobj.setChooseEntityidArr(chooseentityidarr);
						MultiplePopupobj.showPopup();
						MultiplePopupobj.setReturnField(popupobj,'selectlistval','selectlistval_label');
						MultiplePopupobj.showPopupAfter = function(){
							//记录选中的单据id以及顺序
							var that = this;
							var popupobj = that.popupobj;
							if(this.saveChooseInfo == 'yes'){
								this.setCheckBoxEvent();
							}
							//重新设置选择单据的点击事件
							if(this.selecttype == 'all' || this.selecttype == 'multiple'){
								ld("#"+popupobj.divid+" .saveauto").show().attr('onclick','').bind("click",function(){
									that.MultiplePopupSelectRecord();
								})
							}
							that.loadCheckbox();
						}
						MultiplePopupobj.ClickAfterReturn = function (){
							var that = this;
							ld("#"+that.prevpopupobj.divid+" [name='"+that.entityidlabel+"']").val(that.chooseentityid_arr.join(','));
							ld("#"+that.prevpopupobj.divid+" [name='"+that.entitynamelabel+"']").val(that.chooseentityname_arr.join(','));
							ld("#"+that.prevpopupobj.divid+" [name='"+that.entitynamelabel+"']").attr('title',that.chooseentityname_arr.join(','));
						}
					})
				})
				selectlistlabelobj.parent().find('[name=selectlistval_icon_clear]').attr('onclick','').bind('click',function (){
					selectlistvalobj.val('');
					selectlistlabelobj.val('');
				});
			}else if(tmp_fieldobj.uitype==19 || tmp_fieldobj.uitype==21){
				var textareaobj = CrmPopup.findHtmlobj(tmpdivid,tmp_fieldname);
				textareaobj.not('.proName_note').autosize();
			}
			else  if(tmp_fieldobj.uitype==230 || tmp_fieldobj.uitype==231)
			{
				var tmpfieldname=tmp_fieldname;
				if(popupobj.ueditor_fieldname_arr.indexOf(tmpfieldname) == -1){
					popupobj.ueditor_fieldname_arr.push(tmpfieldname);
				}
				//为了避免和新建、编辑页面的富文本框控件名称冲突，将fieldname加上_new后缀
				var textareaobj = CrmPopup.findHtmlobj(tmpdivid,tmpfieldname);
				var tmpfieldname_new =  tmpfieldname+'_new';
				textareaobj.attr('name',tmpfieldname_new);
				textareaobj.attr('id',tmpfieldname_new);
				textareaobj.not('.proName_note').autosize();
				textareaobj.css('resize','none');

				var tmpokeditor= UE.getEditor(tmpfieldname_new,{
					initialFrameWidth:"87%"
				});//实例化编辑器
				popupobj.oCKeditor=tmpokeditor;
				if(popupobj.oCKeditors == undefined){
					popupobj.oCKeditors = [];
				}
				popupobj.oCKeditors[tmpfieldname_new]=tmpokeditor;

				window.setTimeout(function(j){
					var id=ld('#'+j).children("div:first-child").attr("id");
					ld('#'+id).css('z-index','99999');
					//popupobj.oCKeditor.center();//38378: （51mis.com/kfbcrm）公告模块新增界面：新增弹出层没有在当前屏幕居中，太靠下了。
				},400, tmpfieldname_new);
				textareaobj.parent().css('min-width','800px');
			}
		}
		popupobj.fields = orgin_fields;
		tooltip('.tip-items-list', {transition: true, time: 200});

		var trigger_fieldname_arr = approvedata.trigger_fieldname_arr;
		if(!empty(trigger_fieldname_arr)){
			AjaxJSPage('cls_miniedit_fieldrule_js','include/js/cls_miniedit_fieldrule.js');
			popupobj.minifieldruleobj = new cls_miniedit_fieldrule(popupobj,trigger_fieldname_arr);
			popupobj.minifieldruleobj.setParentobj(ld('#'+popupobj.divid+' #div_mandatory_field'));
			popupobj.minifieldruleobj.set_trigger_fields_arr(mandatory_field_arr);
			popupobj.minifieldruleobj.setEvent();
			popupobj.minifieldruleobj.setValues(approvedata.trigger_fieldvalue_arr);

			popupobj.minifieldruleobj.reloadPopup = function (){
				var approvestatusobj = ld("#"+popupobj.divid+" [name=approvestatus]:checked");
				approvestatusobj.click();
			}
		}

	}else{
		trobj.hide();
		popupobj.mandatory_field_arr = [];
	}
	if(!empty(popupobj.ueditor_fieldname_arr) && popupobj.ueditor_fieldname_arr.length>0){
		ld("#" + popupobj.divid).css("width", 1000);
	}else{
		ld("#" + popupobj.divid).css("width", 650);
	}

	popupobj.center();
}
//设置审批方式切换事件
cls_approve_mandatoryfield.setChangeEvent = function (popupobj,record){
	var module = popupobj.module;
	var approvestatusobj = ld("#"+popupobj.divid+" [name=approvestatus]");
	popupobj.before_approvestatus = ld("#"+popupobj.divid+" [name=approvestatus]:checked").val();
	cls_approve_mandatoryfield.setSpecialFun(popupobj);

	approvestatusobj.bind('click',function (){
		var before_approvestatus = popupobj.before_approvestatus;
		var cur_approvestatus = ld(this).val();
		//判断审批方式是否发生变化,如果未发生变化,则不需要重新读取字段
		/*
		if(!cls_approve_mandatoryfield.judgeApprovefuncChange(before_approvestatus,cur_approvestatus)){
			return '';
		}*/

		popupobj.before_approvestatus = cur_approvestatus;
		var surl = 'index.php?module=Approve&action=ApproveAjax&file=getMandatoryField&record='+record;
		surl += '&frommodule='+module;
		surl += '&approvestatus='+cur_approvestatus;
		surl += '&stepid='+ld('#'+popupobj.divid+' input[name=stepid]').val();
		//+ld("#"+popupobj.divid+" #tr_mandatory_field").hide();
		if(popupobj.ueditor_fieldname_arr != undefined && popupobj.ueditor_fieldname_arr.length>0){
			for(var i=0;i<popupobj.ueditor_fieldname_arr.length;i++){
				var tmpfieldname = popupobj.ueditor_fieldname_arr[i];
				var tmpfieldname_new = tmpfieldname+'_new';
				var fieldobj = CrmPopup.findHtmlobj(popupobj.divid ,tmpfieldname_new);
				if(fieldobj.length>0){
					var tmpokeditor = popupobj.oCKeditors[tmpfieldname_new];
					fieldobj.attr('name',tmpfieldname);
					fieldobj.attr('id',tmpfieldname);
					fieldobj.html(tmpokeditor.getContent());
				}
			}
		}
		var mandatoryfield_str = SaveDataRecord.getFieldValue(popupobj,popupobj.mandatory_field_arr,'');
		var param = {};

		param['requestvalue'] = cls_approve_mandatoryfield.transFieldValue(mandatoryfield_str);
		ldAjax(surl,param,function (data){
			DelProgressObjs();
			ld("#"+popupobj.divid+" #div_mandatory_field").html(data.result.content);
			cls_approve_mandatoryfield.resetfield(popupobj,data.result);
		})
	})
}
//判断审批方式是否发生变化,如果未发生变化,则不需要重新读取字段
cls_approve_mandatoryfield.judgeApprovefuncChange = function (before_value,cur_value){
   //规定审批方式和审批结果的关系
	var approveresult_arr = {};
	approveresult_arr['pass'] = [1,2];
	approveresult_arr['back'] = [4,5];
	approveresult_arr['reject'] = [3];
	approveresult_arr['addsign'] = [6];

	var before_func = '';
	var cur_func = '';
	var tmp_arr = [];
	for(var tmp in approveresult_arr){
		tmp_arr = approveresult_arr[tmp];
		if(tmp_arr.includes(parseInt(before_value))){
			before_func = tmp;
		}
		if(tmp_arr.includes(parseInt(cur_value))){
			cur_func = tmp;
		}
	}
	//审批结果属于同一类型,则审批方式没有发生变化
	if(cur_func == before_func){
		return false;
	}else{
		return true;
	}
}
//审批时，获取字段值用于保存，并判断必填
cls_approve_mandatoryfield.formValidate = function (popupobj){
	var mandatory_field_arr = popupobj.mandatory_field_arr;
	var orgin_field = popupobj.fields;
	var orgin_type = popupobj.type;
	popupobj.fields = mandatory_field_arr;
	popupobj.type=DetailViewPage.type
	var result = doformValidation('');
	popupobj.fields = orgin_field;
	popupobj.type = orgin_type;
	return result;
}

//审批必填字段保存时，将url转化为json字符串
cls_approve_mandatoryfield.transFieldValue = function(fieldvalue_url){
	if(empty(fieldvalue_url))return '';
	var tmp_fieldvalue_arr = fieldvalue_url.split('&');
	var tmp_arr = [];
	var tmp_str = '';
	var all_fieldvalue_arr = {};
	for(var i=0;i<tmp_fieldvalue_arr.length;i++){
		tmp_str = tmp_fieldvalue_arr[i];
		if(!empty(tmp_str)){
			tmp_arr = tmp_str.split('=');
			if(tmp_arr.length >=2){
				all_fieldvalue_arr[tmp_arr[0]] = tmp_arr[1];
			}
		}
	}
	var all_fieldvalue_json = JSON.stringify(all_fieldvalue_arr);

	return all_fieldvalue_json;
}
//duan 20230811 设置弹出层的特殊属性，用于进行小编辑
cls_approve_mandatoryfield.setSpecialFun = function (popupobj){
	popupobj.getDetailTableObj = function (){
		return '';
	}
	popupobj.getTrObjsByDelType = function (){
		return '';
	}
	popupobj.fieldruleobj = {};
	popupobj.fieldruleobj.CheckReLoadPopup = function (){
		return '';
	}
}





