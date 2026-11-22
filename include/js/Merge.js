/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

//to merge a list of acounts with a template
function massMerge(module)
{
       var select_options  =  document.getElementsByName('selected_id');
	var x = select_options.length;
	var viewid =getviewId();		
	idstring = "";

	if(getObj('mergefile').value == '')
	{
	         alert(arrJsPopLabel['PLEASESELECTMERAGETEMPLATES']);
           	 return false;   
        }
	xx = 0;
	for(i = 0; i < x ; i++)
	{
		if(select_options[i].checked)
		{
			idstring = select_options[i].value +";"+idstring
				xx++
		}
	}
	if (xx != 0)
	{
		document.getElementById('idlist').value=idstring;
	}
	else
	{
		alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
		return false;
	}
        
	document.massdelete.action.value = 'Merge';
	document.getElementById('massdelete').action="index.php?module="+module+"&action=Merge&return_module="+module+"&return_action=index";
}

function mergeshowhide(argg)
{
    var x=document.getElementById(argg).style
    if (x.display=="none")
    {
        x.display="block"
   
    }
    else 
	{
		x.display="none"
	}
}

function mergehide(argg)
{
    var x=document.getElementById(argg);
	if (x != null) x.style.display = "none";
}

 function moveMe(arg1) {
    var posx = 0;
    var posy = 0;
    var e=document.getElementById(arg1);
   
    if (!e) var e = window.event;
   
    if (e.pageX || e.pageY)
    {
        posx = e.pageX;
        posy = e.pageY;
    }
    else if (e.clientX || e.clientY)
    {
        posx = e.clientX + document.body.scrollLeft;
        posy = e.clientY + document.body.scrollTop;
    }
 }

function showmergeDup(obj, module) {
    //editor:gyq_170 reason:自动查重合并返回值修改  2020/3/9 14:47
    var surl = "index.php?module=" + module + "&action="+module+"Ajax&file=CheckField&parenttab=Parent Accounts&ReportHeader=dbheader";
    ldAjax(surl, "", function (data) {
        if (data.code == 1) {
            var popupobj= CrmPopup.load(data.result.title,formSelectColumnString,'',"LdPopWidth900px",module,"",data.result.oktext,'',data.result.canceltext);
            popupobj.show(data.result.content);
            //BUG0069108 xxy 2023-8-24 “自动查重合并”功能，查询条件设置窗口，“左移”“右移”按钮无效 
            var tableobj = ld('#'+popupobj.divid).find(" .commonMultipleSelect").parents("table");
            var LeftObj = tableobj.find(" .commonMultipleSelect:first");
            var RightObj = tableobj.find(" .commonMultipleSelect:last");
            var Drag_Transfer = new DragTransfer();
            Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','360');
            popupobj.center();
            if(cls_wxOpenDataobj!=undefined&& typeof cls_wxOpenDataobj!='undefined'){
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
            }

            // 需要去掉的给高度
            popupobj.reduceBodyHeight = 0;
            if(ld('#'+popupobj.divid + ' .ld-description').length > 0){
                popupobj.reduceBodyHeight += parseInt(ld('#'+popupobj.divid + ' .ld-description').outerHeight());
            }
            // 设置内容最大高度
            popupobj.setPopBodyMaxHeight(".ld-pop-container-second");
        }
        DelProgressObjs();
    });
    /* if(trim($("mergeDup").innerHTML).length!=0)
     {

          moveMe('mergeDup');
          mergeshowhide('mergeDup');
          searchhide('searchAcc','advSearch');
          return ;
     }*/
    //$("status").style.display = "inline";
    /*new Ajax.Request
    (
        'index.php',
        {
            queue: {
                position: 'end',
                scope: 'command'
            },
            method: 'post',
            postBody: "module=" + module + "&action=CheckField&parenttab=Parent Accounts&ReportHeader=dbheader",
            onComplete: function (response) {
                $("status").style.display = "none";
                var results = response.responseText.split('&#&#&#');
                $("mergeDup").innerHTML = results[1];
                fnvshobj(obj, 'mergeDup');

            }
        }
    );*/
}
function mergeSelect() {
    var popupop=CrmPopup.getPopupObj('last');
    var divid=popupop.divid;
    ld("#"+divid+" input[name=selectall]").unbind("click").bind("click",function(){
        var tmpobjs=ld("#"+divid+" input[tag=mergerecord]");
        var that=this;
        ld.each(tmpobjs,function(){

            ld(this).prop("checked",ld(that).prop("checked"));
        });
        let state = ld(that).prop("checked");
        if(state){
            ld('#'+divid+' input[name=selectall]').addClass('tb-checkbox-selected');
            ld('#'+divid+' input[tag=mergerecord]').addClass('tb-checkbox-selected');
        }
        else{
            ld('#'+divid+' input[name=selectall]').removeClass('tb-checkbox-selected');
            ld('#'+divid+' input[tag=mergerecord]').removeClass('tb-checkbox-selected');
        }
    });

    ld("#"+divid+" input[tag=mergerecord]").unbind("click").bind("click",function(){
        let state = ld(this).prop("checked");
        if(state){
            ld(this).addClass('tb-checkbox-selected');
        }
        else{
            ld(this).removeClass('tb-checkbox-selected');
        }
    });
}

function List_Merge(module=""){
    var that = this;
    this.module = module;
    this.popupobj = {};
    this.tableobj = {};
    this.multifields_value = {};
    this.main_record = 0;
    this.mergetype = 'merge';
    this.editfield_status = 'complete';// 编辑字段的状态：进行中（editing）和完成（complete）
    //Eidtor:gyq_65 Reason:客户、服务收费、联系人合并功能 Date:2018/3/23 0023 下午 4:34
    this.getPopup = function(obj) {
        var module = this.module;
        List_CheckBox_Ids.getIds(module);
        var numOfRows = List_CheckBox_Ids.num_rows;
        var excludedRecords = $('excludedRecords').value;
        //	0033534: 客户、联系人、服务收费管理序时簿界面：勾选10条以上单据，点击“合并”，结果提示信息是错误的
        if(List_CheckBox_Ids.ids=='all') {
            var select_ids = List_CheckBox_Ids.ids;
        }else{
            var select_ids = List_CheckBox_Ids.ids.split(';').join(',')
        }
        if((numOfRows>10 && module != 'Accounts') || (numOfRows>100 && module == 'Accounts')){
            if(module == 'Accounts'){
                var confirm_str = arrJsPopLabel['MASSELECTTENTIP2'];
                this.mergetype = 'bigmerge';
            }else{
                var confirm_str = arrJsPopLabel['MASSELECTTENTIP'];
            }
            confirm_str = confirm_str.replace('{Var}', numOfRows);
            MessagePopup.TipTwo_warning(confirm_str);
            var popupobj = CrmPopup.getPopupObj('last');
            ld('#'+popupobj.divid).find('[tagclick=msgConfirm]').unbind('click').bind('click',function (event) {
                var ids_arr = List_CheckBox_Ids.ids.split(";");
                if(module == 'Accounts'){
                    select_ids = ids_arr.slice(0,100).join(',');
                }else{
                    select_ids = ids_arr.slice(0,10).join(',');
                }
                var info = {};
                info['module'] = module;
                info['select_ids'] = select_ids;
                info['excludedRecords'] = excludedRecords;
                that.showPopup(info);
            });
            ld('#'+popupobj.divid).find('[tagclick=msgConfirmCancel]').bind('click',function (event) {//刷新列表
                var tmparra = new Array();
                var tmpmodule = new Array();
                tmpmodule.push(module);
                var tmpobj = new AfterUpdatePrevPopupObjContent(module, "", tmparra);
                tmpobj.eachrefreshlistbyModules(tmpmodule);
            });
        }else if(numOfRows>1){
            if(numOfRows>3 && module == 'Accounts'){// 2024-10-16 超过3条时
                this.mergetype = 'bigmerge';
            }
            var info = {};
            info['module'] = module;
            info['select_ids'] = select_ids;
            info['excludedRecords'] = excludedRecords;
            that.showPopup(info);
        }else{
            var confirm_str = arrJsPopLabel['SELECTLEASTTWO'];
            MessagePopup.TipOne_warning(confirm_str);
            return false;
        }
    }
    // 合并-弹出层
    this.showPopup = function(info) {
        var module = info.module;
        var select_ids = info.select_ids;
        var excludedRecords = info.excludedRecords;
        var surl = "module="+module+"&action="+module+"Ajax&file=field_merge&mergemode=mergefields&passurl="+select_ids+"&excludedRecords="+excludedRecords+"&parenttab=&second_action=merge";
        surl += "&mergetype="+this.mergetype;
        ldAjax('index.php?' + surl,'',function (data) {
            if (data.code == 1) {
                $("status").style.display = "none";
                var crmPopupobj = CrmPopup.load(data.result.title, that.saveRecordMerge, "", 'LdPopWidth800px', module, '', data.result.oktext, "", data.result.canceltext);
                crmPopupobj.Okfun.funname='that.saveRecordMerge';
                // 新不超过10条合并，增加弹出层放大缩小
                if(data.result.params_arr && that.mergetype == 'merge'){
                    crmPopupobj.isShowFullscreen = 'yes';
                    crmPopupobj.Fullscreencallback = function(switchtotype){
                        // 需要去掉的给高度
                        crmPopupobj.reduceBodyHeight = 0;
                        var contentHeight = 0;
                        if(ld('#'+crmPopupobj.divid + ' .ld-description').length > 0){
                            crmPopupobj.reduceBodyHeight += parseInt(ld('#'+crmPopupobj.divid).find(".ld-description").outerHeight());
                        }
                        if(ld('#'+crmPopupobj.divid + ' .ld-pop-container-mergetype').length > 0){
                            crmPopupobj.reduceBodyHeight += parseInt(ld('#'+crmPopupobj.divid).find(".ld-pop-container-mergetype").outerHeight());
                        }
                        if(ld('#ld-pop-container-MergeTableDiv').length > 0) {
                            crmPopupobj.reduceBodyHeight += parseInt(ld('#ld-pop-container-MergeTableDiv').css('padding-top').replace('px', ''));//获取上边距
                            crmPopupobj.reduceBodyHeight += parseInt(ld('#ld-pop-container-MergeTableDiv').css('padding-bottom').replace('px', ''));//获取下边距
                        }
                        if(switchtotype == 'fullscreen'){
                            crmPopupobj.proportion = 1;
                            contentHeight = crmPopupobj.getPopContentHeight()-crmPopupobj.reduceBodyHeight;

                            // 设置内容最大高度
                            crmPopupobj.setPopBodyMaxHeight("#MergeTableDiv");

                            that.tableobj.find('th').css('min-width','350px');
                        }
                        else{
                            crmPopupobj.proportion = 0.8;
                            contentHeight = crmPopupobj.getPopContentHeight()-crmPopupobj.reduceBodyHeight;

                            // 设置内容最大高度
                            crmPopupobj.setPopBodyMaxHeight("#MergeTableDiv");

                            ld('#'+crmPopupobj.divid).css('width','');
                            that.tableobj.find('th').css('min-width','250px');
                            crmPopupobj.center();
                        }

                        // 计算固定列和表头整体高度
                        if (ld('#'+crmPopupobj.divid + ' .ld-table-container').length > 0) {
                            var containerObj = ld('#'+crmPopupobj.divid + ' .ld-table-container');
                            var options = {'height':contentHeight,'width':820,'thwidth':275};
                            lockingHeaderColumn(containerObj, options);
                        }
                        that.tableobj.find('th').eq(0).css('min-width','');
                    };
                }
                crmPopupobj.show(data.result.content);
                // 需要去掉的给高度
                crmPopupobj.reduceBodyHeight = 0;
                if(ld('#'+crmPopupobj.divid + ' .ld-description').length > 0){
                    crmPopupobj.reduceBodyHeight += parseInt(ld('#'+crmPopupobj.divid).find(".ld-description").outerHeight());
                }
                if(ld('#'+crmPopupobj.divid + ' .ld-pop-container-mergetype').length > 0){
                    crmPopupobj.reduceBodyHeight += parseInt(ld('#'+crmPopupobj.divid).find(".ld-pop-container-mergetype").outerHeight());
                }
                if(ld('#ld-pop-container-MergeTableDiv').length > 0) {
                    crmPopupobj.reduceBodyHeight += parseInt(ld('#ld-pop-container-MergeTableDiv').css('padding-top').replace('px', ''));//获取上边距
                    crmPopupobj.reduceBodyHeight += parseInt(ld('#ld-pop-container-MergeTableDiv').css('padding-bottom').replace('px', ''));//获取下边距
                }
                var contentHeight = crmPopupobj.getPopContentHeight()-crmPopupobj.reduceBodyHeight;

                // 设置内容最大高度
                crmPopupobj.setPopBodyMaxHeight("#MergeTableDiv");
                crmPopupobj.center();

                // 计算固定列和表头整体高度
                if (ld('#'+crmPopupobj.divid + ' .ld-table-container').length > 0) {
                    var containerObj = ld('#'+crmPopupobj.divid + ' .ld-table-container');
                    var options = {'height':contentHeight,'width':820,'thwidth':272};
                    lockingHeaderColumn(containerObj, options);
                }
                                
                that.popupobj = crmPopupobj;
                that.popupobj.listmerge_obj = that;
                that.tableobj = ld('#'+crmPopupobj.divid).find("#MergeTable");
                crmPopupobj.params_arr = data.result.params_arr;
                crmPopupobj.bigtype_arr = data.result.bigtype_arr;
                that.multifields_value = data.result.multifields_value;
                that.main_record = (select_ids.split(','))[0];// 主单据
                that.setBindEvent();
                DelProgressObjs();
            }
        });
    }
    //确定按钮事件
    this.saveRecordMerge = function(){
        var popupobj = that.popupobj;
        var module = that.module;

        if(that.editfield_status == 'editing'){
            var editingobj = ld('#'+popupobj.divid).find('[data-name=merge_editsave]:visible');// 仍处于编辑状态的对象
            var tdobj = editingobj.parents('td:first');
            var fieldname = tdobj.data('fieldname');
            var trobj = editingobj.parents('tr:first');
            var fieldlabel = trobj.find('td:first').text();
            var confirm_str = arrJsPopLabel['PleaseSaveVarFirst'].replace('{Var}', fieldlabel);// 请先保存字段
            MessagePopup.TipZero_warning(confirm_str);
            var editing_input_obj = trobj.find('[data-name=merge_editarea]').find('input[fieldname='+fieldname+']:visible');// 编辑中的input框
            editing_input_obj.addClass('border_red1');// 标红
            setTimeout(function (){
                editing_input_obj.removeClass('border_red1');
            },2000);
            var editarea_top = trobj.find('[data-name=merge_editarea]').find('input[fieldname='+fieldname+']:visible').offset().top;
            var tabledivobj = trobj.parents('div:first')
            var tablediv_top = tabledivobj.offset().top;
            trobj.parents('div:first').animate({ scrollTop: ((editarea_top - tablediv_top)<0?editarea_top - tablediv_top:0)});// 聚焦到目标输入框
            return;
        }

        var FormData = CrmPopup.findHtmlobj(popupobj.divid,"merge_fields_form").find('[name]').serializeArray();
        var surl = "index.php?";
        
        if(!empty(popupobj.params_arr)){// 新的客户合并从对象中取值
            var FormData_parent = FormData.find(function(obj) { return obj.name === 'parent'; }).value;
            var FormData_pass_rec = FormData.find(function(obj) { return obj.name === 'pass_rec'; }).value;
    
            var params = popupobj.params_arr;
            params.forEach(item => {// 去掉多余属性
                delete item.recordid;
            });
            if(that.mergetype != 'bigmerge'){
                that.main_record = FormData.find(function(obj) { return obj.name === 'record'; }).value;
            }
            if(empty(that.main_record)){
                that.main_record = (FormData_pass_rec.split(','))[0];
            }
            surl += "module="+module+"&action="+module+"Ajax&file=field_merge&mergemode=mergesave&return_module="+module+"&parent="+FormData_parent
                +"&pass_rec="+FormData_pass_rec+"&return_action=FindDuplicateRecords&second_action=merge";
            surl += "&record="+that.main_record;
        }else{
            var params = FormData;
        }

        var add_teammember_obj = ld('#'+popupobj.divid).find("#add_teammember");// 合并后，将被删除记录的单据负责人自动添加到主记录团队成员中
        if(add_teammember_obj && add_teammember_obj.length > 0){
            var add_teammember = add_teammember_obj.prop('checked')?'yes':'no';
            surl += "&add_teammember="+add_teammember;
        }
        
        
        ldAjax(surl, params, function (data) {
            if (data.code == 1) {
                popupobj.CancelEvent();
                popupobj=CrmPopup.getPopupObj("last");
                if(popupobj.type==ListPagePopup.type)
                {
                    //合并
                    // @edit:liushuai,2021-07-16,reason: 0046957: https://81mis.com/kfbcrm/ [^]，客户管理——客户——合并两条客户信息后，继续合并其他客户时点击合并无反应
                        ld("#selectedboxes").val("");//edit；can 20200724 如果不添加该语句 ，合并后不刷新界面继续合并，会有错误
                        ld("#allselectedboxes").val("");//取得是name=allselectedboxes的值
                        getListViewEntries_js(popupobj.module,"start="+ld("#"+popupobj.divid+" [name=pagenum]").val());//刷新页面
                }
                else//自动查重合并
                    getDuplicateListViewEntries_jss(popupobj.module,"start="+ld("#"+popupobj.divid+" [name=pagenum]").val());
            }else{
                RemindsMsg("","LdPopWidth400px",module,"yes","yes",data.msg);
                return false;
            }
            DelProgressObjs();
            // window.location.reload();
        });
        /*
        CrmPopup.findHtmlobj(popupobj.divid,"merge_fields_form").submit();*/
    }
    // 绑定事件
    this.setBindEvent = function (){
        var popupobj = this.popupobj;
        var targetobj = ld("#"+popupobj.divid);
        var tableobj = this.tableobj;

        // ld('#'+popupobj.divid+'_btncancel,#'+popupobj.divid+'_imgclose').bind('click',function (event) {
        //     var tmparra = new Array();
        //     var tmpmodule = new Array();
        //     tmpmodule.push(module);
        //     var tmpobj = new AfterUpdatePrevPopupObjContent(module, "", tmparra);
        //     tmpobj.eachrefreshlistbyModules(tmpmodule);
        // })

        that.showEditbtn();

        if(tableobj.find('[data-name=merge_editbtn]') && tableobj.find('[data-name=merge_editbtn]').length > 0){
            tableobj.find('[data-name=merge_editbtn]').unbind('click').on('click', function (event) {
                that.editField(this);
            });
        }

        if(this.mergetype == 'bigmerge'){
            // 可搜索下拉框
            var selectobj = ld("#"+popupobj.divid).find("select#selectvalue");
            if(selectobj && selectobj.length > 0){
                for(var i=0;i<selectobj.length;i++){
                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(selectobj.eq(i).attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(popupobj);
                    var selectwidth = Tools.getParentobjByChild(selectobj.eq(i),'td').width();
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj.eq(i),selectwidth+10);
                }
            }
            targetobj.find("[name^=selectvalue_]").unbind('change').on('change', function (event) {
                that.selectValue(this);
            });
            targetobj.find("[name=transfervalue]").unbind('click').on('click', function (event) {
                that.setValuePopup(this);
            });
            targetobj.find("[name=clearvalue]").unbind('click').on('click', function (event) {
                that.clearValue(this);
            });
            
        }
    }
    // 浮显小编辑按钮
    this.showEditbtn = function(){
        // var popupobj = this.popupobj;
        var tableobj = this.tableobj;
        if(tableobj.find('td[data-edit=yes]') && tableobj.find('td[data-edit=yes]').length > 0){
            tableobj.find('td[data-edit=yes]').unbind('mouseenter').on('mouseenter', function (event) {
                ld(this).find('[data-name=merge_editbtn]').show();
            });
            tableobj.find('td[data-edit=yes]').unbind('mouseleave').on('mouseleave', function (event) {
                ld(this).find('[data-name=merge_editbtn]').hide();
            });
        }
    }
    // 编辑字段
    this.editField = function(obj){
        var popupobj = this.popupobj;
        var tableobj = this.tableobj;
        var targetid = ld(obj).data('id');
        ld(obj).hide();
        if(this.mergetype == 'bigmerge'){
            tableobj.find('div[name=dv_cmb_selectvalue_'+targetid+']').hide();// 隐藏可搜索下拉框
            // tableobj.find('select[name=multichoosevalue_'+targetid+']').hide();
        }else{
            tableobj.find('[data-name=merge_displayvalue][data-id='+targetid+']').hide();
            tableobj.find('[data-name=merge_editbtn][data-id='+targetid+']').hide();
            tableobj.find('td[data-edit=yes]').unbind('mouseenter');// 解绑浮显事件
            tableobj.find('td[data-edit=yes]').unbind('mouseleave');
        }
        // 显示编辑框和保存按钮
        tableobj.find('[data-name=merge_editarea][data-id='+targetid+']').css('display','contents');
        var editsave_obj = tableobj.find('[data-name=merge_editsave][data-id='+targetid+']');
        editsave_obj.show();
        editsave_obj.find('[name=cancelbtn]').unbind('click').on('click', function (event) {
            that.cancelEditField(this);
        });
        editsave_obj.find('[name=savebtn]').unbind('click').on('click', function (event) {
            that.saveField(this);
        });
        this.editfield_status = 'editing';
    }
    // 取消编辑字段
    this.cancelEditField = function(obj){
        var popupobj = this.popupobj;
        var parentobj = ld(obj).parents('div:first');
        var targetid = parentobj.data('id')
        parentobj.hide();
        if(this.mergetype == 'bigmerge'){
            var tdobj = ld(obj).parents('tr:first').find('td[name=content_'+targetid+']');
            tdobj.find('div[name=dv_cmb_selectvalue_'+targetid+']').css('display','inline');
            parentobj.parents('td:first').find('[data-name=merge_editbtn][data-id='+targetid+']').show();
        }else{
            var tdobj = ld(obj).parents('td:first');
            tdobj.find('[data-name=merge_displayvalue][data-id='+targetid+']').show();
            tdobj.find('[data-name=merge_editbtn][data-id='+targetid+']').hide();
        }
        tdobj.find('[data-name=merge_editarea][data-id='+targetid+']').hide();
        // ld('#'+popupobj.divid).find('[data-name=merge_editsave][data-id='+targetid+']').hide();
        that.showEditbtn();
        this.editfield_status = 'complete';
    }
    // 保存所编辑的字段
    this.saveField = function(obj){
        var popupobj = this.popupobj;
        var fieldname = '';
        var savedvalue = '';
        if(this.mergetype == 'bigmerge'){
            var parentobj = ld(obj).parents('div:first');
            fieldname = parentobj.data("id");
            var tdobj = ld(obj).parents('tr:first').find('td[name=content_'+fieldname+']');
        }else{
            var tdobj = ld(obj).parents('td:first');
            fieldname = tdobj.data("fieldname");
        }
        savedvalue = tdobj.find('[data-name=merge_editarea]').find('input[fieldname='+fieldname+']').val();
        if(savedvalue == ''){// 编辑内容不能为空
            var trobj = tdobj.parents('tr:first');
            var fieldlabel = trobj.find('td:first').text();
            MessagePopup.TipZero_warning(fieldlabel + arrJsPopLabel['CANOTEMPTY']);
            tdobj.find('[data-name=merge_editarea]').find('input[fieldname='+fieldname+']').addClass('border_red1');
            tdobj.find('[data-name=merge_editarea]').find('input[fieldname='+fieldname+']').focus();
            return;
        }
        if(this.mergetype == 'bigmerge'){
            tdobj.find('input#cmb_span_optiontext_selectvalue_'+fieldname).val(savedvalue);
        }else{
            tdobj.find('[data-name=merge_displayvalue]').text(savedvalue);
            tdobj.find('input[name='+fieldname+'][type=radio]').prop('checked',true);
        }
        this.setValue(fieldname,savedvalue);// 更新编辑所保存的value
        this.cancelEditField(obj);
    }
    // 对params中指定name的value进行修改
    this.setValue = function(name,value){
        var popupobj = this.popupobj;
        var params = popupobj.params_arr;
        let obj = params.find(item => item.name === name);
        if (obj) {
            obj.value = value;
        }
    }
    // 单选框选择
    this.chooseValue = function(obj){
        var targetvalue = ld(obj).val();
        var fieldname = ld(obj).attr("name");
        this.setValue(fieldname,targetvalue);
    }
    // 多选框选择
    this.multiChooseValue = function(obj){
        var popupobj = this.popupobj;
        var bigtype_arr = popupobj.bigtype_arr;

        var fieldname = ld(obj).attr("name");
        var trobj = ld(obj).parents('tr:first');
        var targetobj = trobj.find('[name='+fieldname+'][type=checkbox]:checked');
        var bigtype = bigtype_arr[fieldname];
        var targetvalue_arr = [];
        ld.each(targetobj,function(index,tmpobj){
            var tmpvalue = ld(this).val();
            if(bigtype == 'selectmultiuser'){// 多选用户
                tmpvalue_arr = tmpvalue.split(',');
                targetvalue_arr = targetvalue_arr.concat(tmpvalue_arr);
                targetvalue_arr = [...new Set(targetvalue_arr)];
            }else if(bigtype == 'multipicklist'){// 多选框
                tmpvalue_arr = tmpvalue.split(' |##| ');
                targetvalue_arr = targetvalue_arr.concat(tmpvalue_arr);
                targetvalue_arr = [...new Set(targetvalue_arr)];
            }else{
                targetvalue_arr.push(tmpvalue);
            }
        });
        targetvalue_arr = targetvalue_arr.filter(item => item !== null && item !== undefined && item !== "");// 去除空值
        if(bigtype == 'multipicklist'){
            var targetvalue = targetvalue_arr.join(' |##| ');
        }else{
            var targetvalue = targetvalue_arr.join(',');
        }
        this.setValue(fieldname,targetvalue);
    }
    // 下拉框选择
    this.selectValue = function(obj){
        var popupobj = this.popupobj;
        var targetvalue = ld(obj).val();
        var fieldname = ld(obj).data("fieldname");

        // 处理可重复的字段
        if(ld(obj).find("option:selected").attr("allowduplicate") && !empty(ld(obj).find("option:selected").attr("allowduplicate"))){
            if(ld(obj).find("option:selected").attr("allowduplicate") == 'yes'){
                targetvalue = (targetvalue.split('_'))[0];
            }
        }
        // 更新主单据
        if(ld(obj).find("option:selected").data("recordid") && !empty(ld(obj).find("option:selected").data("recordid"))){
            this.main_record = ld(obj).find("option:selected").data("recordid");
        }
        this.setValue(fieldname,targetvalue);
        ld('#'+popupobj.divid).find('[data-name=merge_editarea][data-id='+fieldname+']').find('input[fieldname='+fieldname+']').val(targetvalue);

    }
    // 设置value的弹出层
    this.setValuePopup = function(obj){
        var popupobj = this.popupobj;
        var fieldname  = ld(obj).data('fieldname');
        var bigtype_arr = popupobj.bigtype_arr;
        var bigtype = bigtype_arr[fieldname];
        if(bigtype == 'richtext'){// 富文本框
            this.richTextPopup(obj);
        }else{
            this.transferPopup(obj);
        }
    }
    // 穿梭框弹出层
    this.transferPopup = function(obj){
        var popupobj = this.popupobj;
        var module = this.module;
        var fieldname  = ld(obj).data('fieldname');
        var multifields_value = this.multifields_value;// 所有多选类字段穿梭框的可选/已选值
        var fieldvalues = multifields_value[fieldname]

        var leftfields_arr = fieldvalues['available'];
        var rightfields_arr = fieldvalues['selected'];
        if(rightfields_arr.length > 0)
                leftfields_arr = leftfields_arr.filter(leftitem => !rightfields_arr.some(rightitem => rightitem.value === leftitem.value));// 在左侧数组中去掉右侧已选字段
        // 无可选选项值
        if(empty(leftfields_arr) && empty(rightfields_arr)){
            MessagePopup.TipOne_warning(arrJsPopLabel['NoOptionalValues']);
            return false;
        }
        
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
        crmPopupobj.prevshow();
        var title = arrJsPopLabel['SetAsPrimaryRecord'] + '->' + ld(obj).data('title');
        crmPopupobj.setParams(title,that.transferSave,"","LdPopWidth800px",module,"",arrJsPopLabel['CONFIRME'],"",arrJsPopLabel['CANCEL']);
        crmPopupobj.show('<div id="MultichooseTransferDiv" class="ld-pop-container-second"></div>');

        var tableobj = ld('#'+crmPopupobj.divid).find("div#MultichooseTransferDiv");// 加载穿梭框
        var LeftObj = leftfields_arr;
        var RightObj = rightfields_arr;
        var Drag_Transfer = new DragTransfer();
        var translabel = {
            available: arrJsPopLabel['OptionalValues'],
            selected: arrJsPopLabel['SelectedValues'],
            placeholder: arrJsPopLabel['PleaseEnterOptionValueSearch'],
        };
        Drag_Transfer.SetTranslabel(translabel);
        Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'set','335');
        crmPopupobj.center();

        crmPopupobj.target_fieldname = fieldname;
    }
    // 穿梭框保存
    this.transferSave = function(obj){
        var transfer_popupobj = CrmPopup.getPopupObj('last');// 穿梭框弹出层
        var fieldname  = transfer_popupobj.target_fieldname;

        var Drag_Transfer = new DragTransfer();
        Drag_Transfer.tableObj = ld('#'+transfer_popupobj.divid).find("div#MultichooseTransferDiv");
        var selectvalue_arr = Drag_Transfer.getData('right');// 获取已选值的value
        var selectlabel_arr = Drag_Transfer.getData('right','text');// 获取已选值的label
        var select_arr = Drag_Transfer.getData('right','array');
        var selectlabel_str = selectlabel_arr.join(',');
        that.multifields_value[fieldname]['selected'] = select_arr;// 给对应字段的已选穿梭框值重新赋值

        transfer_popupobj.CancelEvent();

        var popupobj = CrmPopup.getPopupObj('last');// 合并弹出层
        var bigtype_arr = popupobj.bigtype_arr;
        var bigtype = bigtype_arr[fieldname];
        if(bigtype == 'multipicklist'){// 多选框
            var targetvalue = selectvalue_arr.join(' |##| ');
        }else{
            var targetvalue = selectvalue_arr.join(',');
        }
        that.setValue(fieldname,targetvalue);
        var selectlabel_str = selectlabel_arr.join(',');
        ld('#'+popupobj.divid).find('div[name=multichoosevalue_'+fieldname+']').html(selectlabel_str);// label显示到div框
    }
    // 富文本框弹出层
    this.richTextPopup = function(obj){
        var popupobj = this.popupobj;
        var module = this.module;

        var fieldname  = ld(obj).data('fieldname');
        var multifields_value = this.multifields_value;
        var fieldvalues = multifields_value[fieldname];// 获取富文本框字段所有值
        
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
        crmPopupobj.prevshow();
        var title = arrJsPopLabel['SetAsPrimaryRecord'] + '->' + ld(obj).data('title');
        crmPopupobj.setParams(title,that.richTextSave,"","LdPopWidth800px",module,"",arrJsPopLabel['CONFIRME'],"",arrJsPopLabel['CANCEL']);
        
        var content_html = `<div style="overflow-x: auto;">`
                            +`<table class="settingPopTable lasttdbordernon" id="" border="0" cellpadding="0" cellspacing="0" width="100%">`
                                +`<tr style="">`;
        if(!empty(fieldvalues['available'])){
            var checked = '';
            ld.each(fieldvalues['available'], function(index, info) {
                checked = '';
                if(index == 0){
                    checked = 'checked';
                }
                content_html += '<td style="white-space: inherit;padding: 10px 30px;" data-fieldname="">'
                                    +`<div style="display: flex;align-items: center;">`
                                        +`<input name="`+fieldname+`" id="`+fieldname+`_`+index+`" value="`+info.value+`" type="radio" `+checked+` style="margin-right: 10px;"/>`
                                        +`<label for="`+fieldname+`_`+index+`" data-name="merge_displayvalue" style="width: 70%;">`+info.text+`</label>`
                                    +`</div>`
                                +`</td>`
            });
        }
        content_html += `</tr></table></div>`;
        crmPopupobj.show(content_html);
        crmPopupobj.center();

        crmPopupobj.target_fieldname = fieldname;
    }
    // 富文本框保存
    this.richTextSave = function(obj){
        var rich_popupobj = CrmPopup.getPopupObj('last');// 富文本框弹出层
        var fieldname  = rich_popupobj.target_fieldname;

        var targetvalue = ld('#'+rich_popupobj.divid).find("input[name="+fieldname+"]:checked").val();
        var targetid = ld('#'+rich_popupobj.divid).find("input[name="+fieldname+"]:checked").attr('id');
        var targettext = ld('#'+rich_popupobj.divid).find("label[for="+targetid+"]").html();

        rich_popupobj.CancelEvent();

        var popupobj = CrmPopup.getPopupObj('last');// 合并弹出层
        
        that.setValue(fieldname,targetvalue);
        ld('#'+popupobj.divid).find('div[name=multichoosevalue_'+fieldname+']').html(targettext);// label显示到div框
        var select_arr = [];
        select_arr.push({'value' : targetvalue,'text' : targettext});
        that.multifields_value[fieldname]['selected'] = select_arr;
    }
    // 多选时清除value
    this.clearValue = function(obj){
        var popupobj = this.popupobj;
        var tdobj = ld(obj).parents('td:first');
        var targetobj = tdobj.find('#multichoosevalue');
        targetobj.val("");
        targetobj.html("");

        var fieldname  = ld(obj).data('fieldname');
        this.setValue(fieldname,"");
        this.multifields_value[fieldname]['selected'] = [];
    }
    // 合并中的工商查询
    this.getTianyanByKeyWord = function(obj,rowid,module,event){
        getTianyanByKeyWord(obj,rowid,module,event);
        var popupobj = this.popupobj;
        var tdobj = ld(obj).parents('td:first');
        var fieldname  = tdobj.data('fieldname');
        var gongshang_icon = tdobj.find('#business_'+fieldname);

        var offset = gongshang_icon.offset();// 工商图标位置
        var popupOffset = ld('#'+popupobj.divid).offset();
        var Width = gongshang_icon.outerWidth();
        
        var relativeLeft = offset.left - popupOffset.left;// 工商图标相对弹出层的left
        var relativeTop = offset.top - popupOffset.top;
        var newLeft = relativeLeft + Width;
        var newTop = relativeTop;
        // 重新给模糊查询结果弹窗位置
        setTimeout(() => {
            ld('#'+popupobj.divid).find('[name=check_kewords]').css({
                left: newLeft + 'px',
                top: newTop + 'px',
            });
        }, 400);
    }
}

// List_Merge.curobj = '';
// List_Merge.getInstance=function(module=""){
// 	if(!empty(List_Merge.curobj)){

// 	}else{
// 		List_Merge.curobj=new List_Merge(module);
// 	}
//     return List_Merge.curobj;
// }