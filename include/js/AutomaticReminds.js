function AutomaticReminds(){
   var that=this;
}

//序时簿新增规则
AutomaticReminds.createRemindsRule = function(record,blockid)
{	
	var blockid = ld('#reminds_module').val();
	if(record > 0){
		var surl = "index.php?module=Settings&action=SettingsAjax&file=EditRemindsRule&mode=edit&parenttab=Settings&record="+record+"&blockid="+blockid+"&mode=edit";
	}else{
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=CreateRemindsRule&blockid='+blockid+'&mode=create';
	}
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,AutomaticReminds.save,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext); 
			crmPopupobj.createScrollDiv();//创建滚动条
			crmPopupobj.show(data.result.content);
            crmPopupobj.groupinfo=data.result.groupinfo;
            //CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
           
            AutomaticReminds.SettingInitialization = 0;
			AutomaticReminds.tmpokeditor= UE.getEditor('reminds_content');//实例化编辑器
			AutomaticReminds.tmpokeditor.ready(function() {
                var id=ld('#reminds_content').children("div:first-child").attr("id");
                ld('#'+id).css('z-index','9999');
				crmPopupobj.center();
			},2);
			AutomaticReminds.platform = data.result.platform;
			AutomaticReminds.smsrelated_arr = data.result.smsrelated_arr;

			AutomaticReminds.reminder_user_array_json = data.result.reminder_user_array;
            AutomaticReminds.remindmethod_array_json = data.result.remindmethod_array;
			AutomaticReminds.reminderChange(document.getElementById('reminds_to'));
            crmPopupobj.showvalues=data.result.showvalues;
            crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
            crmPopupobj.viewnamelabel=data.result.viewnamelabel;
            crmPopupobj.modulelabel=data.result.modulelabel;

            var advancefilterobj = new cls_advanceFilter();
            var params = {};
            params.columnOptionHtml = data.result.columns_block;
            params.fLabels = data.result.flabels;
            params.datetimestr = data.result.datetimestr;
            params.advfilterhtml = data.result.foption;
            params.fieldsinfo = data.result.fieldinfo;
            params.criteria_groups_arr = data.result.criteria_groups;
            params.module = 'Settings';
            params.source = 'AutomaticReminds';
            params.divid = 'adv_filter_div';
            // params.proportion = 0.9;
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            params.advanceFields = data.result.advanceFields;
            advancefilterobj.setHideGroupDeleteBtn('yes');
            advancefilterobj.showAdvanceFilter(crmPopupobj,params);


			if(data.result.specifyuserids != ''){
				CrmPopup.findHtmlobj(crmPopupobj.divid,'userid').val(data.result.specifyuserids) ;
              
				
			}
            for(var i=0;i<document.getElementById("remind_method").options.length;i++)
			{
				if(document.getElementById("remind_method").options[i].value==data.result.remindertype)
				{
					document.getElementById("remind_method").options.selectedIndex=i;
					break;
				}
			}
			AutomaticReminds.auotRemindmethodChange(document.getElementById('remind_method'));
            
			if(data.result.specifyusernames != ''){
				CrmPopup.findHtmlobj(crmPopupobj.divid,'userid_name').html(data.result.specifyusernames) ;
			}

            //部门下拉框
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml('positiondepartment1');
            cls_resetComboxHtmlobj.setPopupObj(crmPopupobj);
            cls_resetComboxHtmlobj.setPickListContent(crmPopupobj.groupinfo);
            cls_resetComboxHtmlobj.searchhtmltype='div';
            cls_resetComboxHtmlobj.setComboxObjHtml();
             if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
             {
                               //通讯录(pc端企业微信)
                             
                               cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);
             }
             AutomaticReminds.SettingInitialization = 1;
             
            //BUG0072928 xxy 2023-9-21 自动提醒-新增-如数据范围只有一行条件时，隐藏“删除”和“x”按钮 
            var colrow = ld("#"+crmPopupobj.divid+" [name=adv_filter_div]").find('tr[name^=conditioncolumn_]');
            ld("#"+crmPopupobj.divid+" [name=adv_filter_div]").find('tr[name^=groupheader_]').hide();
            // ld("#"+crmPopupobj.divid+" [name=adv_filter_div]").find('tr[name^=groupheader_]').find(' .icon-close').hide();
            if(colrow.length == 1){
                colrow.find('td:last').hide();
            }
		}
	})
}
//编辑规则
AutomaticReminds.editRemindsRule = function(record,tabid)
{
	AutomaticReminds.createRemindsRule(record,tabid);
}

AutomaticReminds.save = function(){
    var popupobj=CrmPopup.getPopupObj("last");
	//规则名称不能为空判断
    var remindRuleName=document.forms['CustomView'].remindRuleName.value;
    if(remindRuleName.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
    {
        var confirm_str = arrJsPopLabel['RULENAMECANNOTBEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);

        //document.forms['CustomView'].remindRuleName.focus();
        return false;
    }
    
    //验证规则时间是否符合规则
    var FieldType =document.getElementById('FieldType').value
    //var FieldType = document.forms['CustomView'].FieldType.value;
    var startdata = document.forms['CustomView'].startdata.value;//规则起始时间
    var NowTime   = CurentTime(); 
    //不能为空
    if(startdata.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0 && FieldType =='FieldType')
    {    
        var confirm_str = arrJsPopLabel['STARTTIMEMUSTNOTBEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        //document.forms['CustomView'].startdata.focus();
        return false;
    }
    //不能小于当前日期
    if(startdata < NowTime && FieldType =='FieldType')
    {    
        var confirm_str = arrJsPopLabel['THESTARTDATECANNOTBELESS'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        //document.forms['CustomView'].startdata.focus();
        return false;
    }
    //验证规则次数开始
    var method=document.forms['CustomView'].reminds_method.value;
    //@固定周期
    if(method == '1')
    {
        var remindnums1=document.forms['CustomView'].remindnums1.value;
        //alert(remindRuleName)
        //验证不能为空
        if(remindnums1.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
        {
            //alert('固定周期提醒天数不能为空！');
            var confirm_str = arrJsPopLabel['FIXEDCYLEREMINDDAYSCANNOTBEEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            //document.forms['CustomView'].remindnums1.focus();
            return false;
        }
        //验证格式
        var ab=/^[0-9]*[1-9][0-9]*$/;//整数验证
        if(ab.test(remindnums1) != true)
        {
            //alert(arrJsPopLabel['THERULENAMEISALREADYINUSE']);
            //alert('固定周期提醒天数格式错误！');
            var confirm_str = arrJsPopLabel['FIXEDCYLEREMINDDAYSCANNOTBEEMPTYERROR'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            document.forms['CustomView'].remindnums1.focus();
            return false;
        }
    }
    else if(method == '3')//每年提醒
    {
        
    }
    else//@指定周期
    {
        var remindnums2=document.forms['CustomView'].remindsNums.value;
        //alert(remindnums2);
        for(var i=1;i<=remindnums2;i++)
        {
            if(document.getElementById('remindnums2'+i).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
            {
                //alert('指定周期提醒天不能为空！');
                var confirm_str = arrJsPopLabel['THESPECIFIEDMINDDAYSCANNOTBEEMPTYERROR'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
            //验证格式
            var ab=/^-?[0-9]\d*$/;//整数       
            if(ab.test(document.getElementById('remindnums2'+i).value) != true)
            {
                //alert(document.getElementById('remindnums2'+i).value)
                var confirm_str = arrJsPopLabel['THESPECIFIEDPERIODTOREMINDNUMBERFORMATERRER'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
            
            if(i<remindnums2 && (parseInt(document.getElementById('remindnums2'+i).value)>parseInt(document.getElementById('remindnums2'+(i+1)).value)))
            {
                var confirm_str = '第'+i+'天提醒时间不能大于第'+(i+1)+'天';
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }
    }
    //zxm 2021-0909 阳光创信 语音提醒  201 提醒方式为语音提醒
    var remind_method = document.getElementById('remind_method').value;
    var SMSVoice_template = document.getElementById('SMSVoice_template').value;
    if(remind_method==201&&SMSVoice_template==''){
        var confirm_str = "语音模板" + arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    var reminds_to = document.getElementById('reminds_to').options[document.getElementById('reminds_to').selectedIndex].value;
    if(reminds_to=='specifyuser')
    {//指定成员
        if(trim(document.getElementById('userid').value)==''){
            var confirm_str = arrJsPopLabel['USERCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    else if(reminds_to == 3){//指定角色
        if(ld("#"+popupobj.divid+" [name=user_role]").val()==''){
            var confirm_str = arrJsPopLabel['ROLECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    else if(reminds_to == 6){//指定部门成员的职位级别
        if(ld("#"+popupobj.divid+" [name=positiondepartment1]").val()==''){
            var confirm_str = arrJsPopLabel['DEPARTMENTLEVELCANNOTBEEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    if(reminds_to == 4||reminds_to == 5||reminds_to == 6){
        //判断职位级别
		if(reminds_to == 4){
			var levelposition = ld("#"+popupobj.divid+" [name=position]").val();
		}else if(reminds_to == 3){
			var levelposition = ld("#"+popupobj.divid+" [name=positionlevel]").val();
		}else if(reminds_to == 4){
			var levelposition = ld("#"+popupobj.divid+" [name=positiondepartment2]").val();
		}
		if(levelposition == ''){
            var confirm_str = arrJsPopLabel['POSTITIONLEVELCANNOTBEEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		
	}
    
    
    //验证提醒内容不为空  语音提醒不需要内容，短信对话框为文本框
    if(remind_method==2 && AutomaticReminds.platform == 'aliyun'){
        var select_smstemplateid = ld("#"+popupobj.divid+" [name=smstemplatelist]").val();
        if (select_smstemplateid < 1) {
            var confirm_str = arrJsPopLabel["TEMPLATE"]+arrJsPopLabel["CANOTEMPTY"];
            MessagePopup.TipZero_warning(confirm_str);
            return false;
        }

        var templateparamconf = {};
        try {
            ld.each(SmsContentSetting.getInstance().smsTemplateList,function(tmpindex,tmpsmstemplateinfo){
                if (select_smstemplateid == tmpsmstemplateinfo.templateid) {
                    var templateparaminfo = JSON.parse(tmpsmstemplateinfo.templateparaminfo) || eval('('+tmpsmstemplateinfo.templateparaminfo+')');
                    if (!empty(templateparaminfo)) {
                        ld.each(templateparaminfo,function(tmp_varname,tmp_crmvarname){
                            //console.log("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]");
                            var tmp_crmvarname_value = trim(ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]").val());
                            if (tmp_crmvarname_value.length == 0) {
                                ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]").focus();
                                // var confirm_str = tmp_varname + arrJsPopLabel['CANOTEMPTY'] + '!';
                                var confirm_str = 'CRM' + arrJsPopLabel['VAR'] + arrJsPopLabel['CANOTEMPTY'] + '!';
                                MessagePopup.TipZero_warning(confirm_str);
                                throw 'ExitLoops';
                            }

                            templateparamconf[tmp_varname] = tmp_crmvarname_value;
                        })

                    }
                    return false;//跳出循环
                }

            })
        }catch(e){
            if (e === 'ExitLoops') {
                // console.log('退出循环');
                return false;
            }
            // else {
            //     throw e;  // 如果不是我们自定义的异常，重新抛出
            // }
        }


    }
    else if(remind_method==0||remind_method==2){
        var popupobj=CrmPopup.getPopupObj("last");
        var reminds_content = ld("#"+popupobj.divid).find(" textarea[id=reminds_content_text]").val();
        if(reminds_content.length==0){
            var confirm_str = arrJsPopLabel['REMINDERSCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    else if(remind_method!=0&&remind_method!=2&&remind_method!=201){
        if(document.getElementById('reminds_content') != undefined){
            //0012657: 新增自动提醒时不输入提醒内容点击保存时异常,新增判断
            var reminds_content = AutomaticReminds.tmpokeditor.getContent(); //获取编辑器内容
            if(reminds_content.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
            {
                //alert('提醒内容不能为空！');
                var confirm_str = arrJsPopLabel['REMINDERSCANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }else{

            var confirm_str = arrJsPopLabel['REMINDERSCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    //验证规则名称是否占用
    var edittype=document.forms['CustomView'].mode.value;
    //conditiongrouptable_1获取ID为 conditiongrouptable_1 的行数
    /*var tableName = document.getElementById('conditiongrouptable_1');
	var prev = tableName.rows.length - 2;
    document.getElementById('selectrow').value = prev;*/
    //新建验证
    //alert(edittype)    
    /*if(edittype != 'edit'){
        var mode=document.forms['CustomView'].blockid.value;
        new Ajax.Request(
        'index.php',
        {queue: {position: 'end', scope: 'command'},
        method: 'post',
        postBody: 'module=Settings&action=SettingsAjax&file=ControllReminds&remindRuleName='+remindRuleName+'&mode='+mode+'&ajax='+'true',
            onComplete: function(response) {
                if(response.responseText.indexOf('USED')>-1){
                    //该规则正在被使用，无法删除！
                    var confirm_str = arrJsPopLabel['THERULENAMEISALREADYINUSE'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                    document.forms['CustomView'].remindRuleName.focus();
                    return false;
                }else{
                    document.forms['CustomView'].submit(); 
                }
            }
        });
    }
    else
    {
        document.forms['CustomView'].submit();    
    }   */ 
	var data = new FormData(ld(".ajax_form")[0]);
    if (!empty(select_smstemplateid)) {
        data.append('smstemplateparamconf', !empty(templateparamconf)?JSON.stringify(templateparamconf):'');
        data.append('smstemplateid', select_smstemplateid);
    }

	var mode = ld("#"+popupobj.divid+" [name=mode]").val();
	var blockid = ld('#reminds_module').val();
	var record = ld("#"+popupobj.divid+" [name=record]").val();
	ld('#rptContentLoading').show();
	//alert('index.php?module=Settings&action=SettingsAjax&file=SaveRemindsRule&mode='+mode+'&blockid='+blockid+'&record='+record);
	ld.ajax({
        type: 'POST',
        dataType: 'json',
        processData: false, // 告诉jquery不要处理数据
        contentType: false, // 告诉jquery不要设置contentType
        data: data,
        url: 'index.php?module=Settings&action=SettingsAjax&file=SaveRemindsRule&mode='+mode+'&blockid='+blockid+'&record='+record,
        success: function(json, textStatus, xhr) {
			ld('#rptContentLoading').hide();
			AutomaticReminds.confirmAutomaticReminds();
			AutomaticReminds.refresh();
        },
        error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
      })
}
//查看
AutomaticReminds.viewRemindsRule = function(reocrd,tabid){
	var surl = "index.php?module=Settings&action=SettingsAjax&file=AutomaticRemindsDetailView&parenttab=Settings&record="+reocrd+"&blockid="+tabid;
	var popupobj=CrmPopup.getPopupObj("last");
    EmptyProgressObjs();
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
		  
			crmPopupobj.setParams(data.result.title,AutomaticReminds.confirmAutomaticReminds,"","LdPopWidth800px",'Settings',"",data.result.oktext,"","");  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            //DelProgressObjs();
		}
	})
}
AutomaticReminds.confirmAutomaticReminds = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
}
//刷新
AutomaticReminds.refresh = function(){
	var blockid = ld('#reminds_module').val();
    //仅更新下方列表内容，directmode=ajax作为判断条件
	var surl = 'index.php?module=Settings&action=AutomaticReminds&parenttab=Settings&ReportHeader=dheader&blockid='+blockid+"&directmode=ajax";
	ldAjax(surl,"",function(data){
		if(data.code==1){
			 DelProgressObjs();
			ld(' [name=automaticremindslists]').html(data.result.content);
           initRightContentHeight();//加载右侧内容中菜单和详细内容高度
		}
	})
}

AutomaticReminds.auotRemindmethodChange = function(obj)
{
    var popupobj=CrmPopup.getPopupObj("last");
    document.getElementById('SMSVoicearray').hide();
    document.getElementById('reminds_content_table').hide();
    ld("#"+popupobj.divid+" #sms_reminds_content_table").hide();

    if (obj.options[obj.selectedIndex].value == 2 && AutomaticReminds.platform == 'aliyun') {
        ld("#"+popupobj.divid+" #sms_reminds_content_table").show();
        ld("#"+popupobj.divid+" [name=selField]").val('');//显示后重新赋值

        var record=document.forms['CustomView'].record.value;
        var tabid=document.forms['CustomView'].blockid.value;

        AutomaticReminds.automaticmoduleSel(tabid);//模块可选字段

        //获取短信模板  并赋值
        var templateparamconf_arr = [];
        if (record > 0 && typeof AutomaticReminds.smsrelated_arr['templateparamconf_arr'] != 'undefined') {//编辑
            ld("#"+popupobj.divid+" [name=smstemplatelist]").val(AutomaticReminds.smsrelated_arr['templateid']);
            templateparamconf_arr = AutomaticReminds.smsrelated_arr['templateparamconf_arr'];

            SmsContentSetting.getInstance().ShowSmsTemplateEvent(popupobj,templateparamconf_arr);
        }else{
            ld("#"+popupobj.divid+" [name=smstemplatelist]").change();//初始化短信内容html //等价于 SmsContentSetting.getInstance().ShowSmsTemplateEvent();
        }


        var selectsmsobj=ld('#'+popupobj.divid).find("[name=smstemplatelist]");
        //获取元素
        var divElement = ld('#'+popupobj.divid).find("[name=dv_chzn_smstemplatelist]");
        // 获取宽度
        var width = ld(divElement).width();
        if(selectsmsobj.length>0&&selectsmsobj!=undefined) {
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectsmsobj.attr("name"));
            cls_resetComboxHtmlobj.setPopupObj(popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectsmsobj, width+10);
        }
        var selectobj=ld('#'+popupobj.divid).find("[name=moduleselect]");
        if(selectobj.length>0&&selectobj!=undefined) {
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
            cls_resetComboxHtmlobj.setPopupObj(popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj, width+10);
        }
    }
    else{
        if(obj.options[obj.selectedIndex].value==201){
            document.getElementById('SMSVoicearray').show();
        }else{
            document.getElementById('reminds_content_table').show();
        }

        //非加载过程清空提醒内容
        if(AutomaticReminds.SettingInitialization != 0 && AutomaticReminds.ChangeReminder == 'no'){
            ld("#"+popupobj.divid).find(" textarea[id=reminds_content_text]").text('');
            AutomaticReminds.tmpokeditor.setContent('');
        }
        //设置提醒内容框
        document.getElementById('reminds_content').hide();
        document.getElementById('reminds_content_text').hide();
        if(obj.options[obj.selectedIndex].value==0||obj.options[obj.selectedIndex].value==2){

            document.getElementById('reminds_content_text').show();
        }
        else{

            document.getElementById('reminds_content').show();
        }
    }




}

AutomaticReminds.reminderChange = function(obj)
{
    AutomaticReminds.ChangeReminder = 'yes';
    //编辑时，重复方式后面显示提示信息不正确
    var reminds_method = ld("#reminds_method").val();
    ld('#remindrule1').hide();
    ld('#remindrule2').hide();
    //首先2个都隐藏，然后按选中的重复方式显示提示信息
    ld('#remindrule'+reminds_method).show();


    document.getElementById('dv_specify_reminder').style.display='none';
    document.getElementById('tr_specify_reminder').style.display='none';
    document.getElementById('tr_role_name').style.display='none';
    document.getElementById('tr_position').style.display='none';
    document.getElementById('tr_positionlevel').style.display='none';
    document.getElementById('tr_positiondepartment').style.display='none';
    document.getElementById('tr_positiondepartment_position').style.display='none';
   
    if(obj.options[obj.selectedIndex].value=='specifyuser')
    {//指定成员=》成员
        document.getElementById('dv_specify_reminder').style.display='inline';
        document.getElementById('tr_specify_reminder').style.display='';
    }
    else if(obj.options[obj.selectedIndex].value==3)
    {//指定角色=角色权限
        document.getElementById('tr_role_name').style.display='';
    }
    else if(obj.options[obj.selectedIndex].value==4)
    {//单据负责人部门成员的职位级别=》职位级别
        document.getElementById('tr_position').style.display='';
    }
    else if(obj.options[obj.selectedIndex].value==5)
    {//单据负责人直属上级部门成员的职位级别=》职位级别
        document.getElementById('tr_positionlevel').style.display='';
    }
    else if(obj.options[obj.selectedIndex].value==6)
    {//指定部门成员的职位级别=》部门、职位级别
        document.getElementById('tr_positiondepartment').style.display='';
        document.getElementById('tr_positiondepartment_position').style.display='';
    }
    
    //提醒人选择“负责人”、“创建人”、“指定成员”、“服务代表”时，提醒方式“对话框”可选
    //设置提醒方式选择框内容
    var remindmethod_array=eval('('+ AutomaticReminds.remindmethod_array_json +')')?eval('('+ AutomaticReminds.remindmethod_array_json  +')'):JSON.parse(AutomaticReminds.remindmethod_array_json);
    document.getElementById('remind_method').options.length=0;
    if(obj.options[obj.selectedIndex].value==201||obj.options[obj.selectedIndex].value=='Accounts'||obj.options[obj.selectedIndex].value=='Contacts'||obj.options[obj.selectedIndex].value=='Accounts##Primary##Contacts'||obj.options[obj.selectedIndex].value=='Accounts##All##Contacts'
    ||obj.options[obj.selectedIndex].value=='Vendors'||obj.options[obj.selectedIndex].value=='VendorsContacts'||obj.options[obj.selectedIndex].value=='Vendors##All##VendorsContacts')
    {
        for(var i=0;i<remindmethod_array['nodialog'].length;i++){
                document.getElementById("remind_method").options.add(new Option(remindmethod_array['nodialog'][i].text,remindmethod_array['nodialog'][i].value));
        }
    }
    else
    {
        for(var i=0;i<remindmethod_array['dialog'].length;i++){
                document.getElementById("remind_method").options.add(new Option(remindmethod_array['dialog'][i].text,remindmethod_array['dialog'][i].value));
        }
    }

    AutomaticReminds.auotRemindmethodChange(document.getElementById("remind_method"));
    AutomaticReminds.ChangeReminder = 'no';
}

//设定提醒内容
AutomaticReminds.SetcontentFormat = function(obj,divid){
    //$("status").style.display="inline";
     calendarParentid="divSendInform_content";//该变量在jscalendar/dynamiccalendar.js/
    //新增或者编辑
    var record=document.forms['CustomView'].record.value;
    var tabid=document.forms['CustomView'].blockid.value;
    //var remind_content=document.forms['CustomView'].reminds_content.value;
    //添加编辑器后原先的内容获取不到
    var popupobj=CrmPopup.getPopupObj("last");
    var remind_method=ld("#"+popupobj.divid).find("select[id=remind_method]").val();
    if(remind_method==0||remind_method==2){     //提醒方式为“对话框/移动端”或“短信”时，提醒内容保存在文本框
        var text = ld("#"+popupobj.divid).find(" textarea[id=reminds_content_text]").val(); //获取编辑器内容
    }
    else{
        var text = AutomaticReminds.tmpokeditor.getContent(); //获取编辑器内容
    }
    var remind_content=text;//document.forms['CustomView'].reminds_content.value;
    var url="index.php?module=Settings&action=SettingsAjax&file=SendInformContent_remind&ajax="+'true'+'&tabid='+tabid;
    //postBody: 'module=Settings&action=SettingsAjax&file=ControllReminds&mode='+mode+'&ajax='+'true',
    if(record != '')
    {   
        url+='&record='+record+'&remind_content='+remind_content;
    }else{
        url+='&remind_content='+remind_content;
    }
	
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(url,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,AutomaticReminds.SaveSendInfoContent_Reminds,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);  
			crmPopupobj.show(data.result.content);
			AutomaticReminds.automaticmoduleSel(tabid);
            // ljj 20240104 BUG0078093 后台设置-消息提醒-设置提醒内容界面，变量信息改为搜索下拉框
            var selectobj=ld('#'+crmPopupobj.divid).find("[name=moduleselect]");
            if(selectobj.length>0&&selectobj!=undefined) {
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(crmPopupobj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj, 160);
            }
		}
	})
}

AutomaticReminds.SaveSendInfoContent_Reminds =function(){
	var CKcontent=document.getElementById('CKcontent').value;
	//document.forms['CustomView'].reminds_content.value=CKcontent;
	//document.getElementsByTagName("iframe")[0].contentWindow.document.body.innerHTML = CKcontent;
	if(document.getElementById('remind_method').value==0||document.getElementById('remind_method').value==2){
	   var prevpopupobj=CrmPopup.getPopupObj("lastprev");
       //zkt 20220728 BUG0054384https://www.81mis.com/kfbtest/ 自动提醒设置，提醒内容动态变量保存出错
       ld("#"+prevpopupobj.divid).find(" textarea[id=reminds_content_text]").val(CKcontent);
	}
    else{
        AutomaticReminds.tmpokeditor.setContent(CKcontent);
    }
    
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
}

AutomaticReminds.automaticmoduleSel = function(tabid)
{
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField&printtabid='+tabid;
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			var popupobj=CrmPopup.getPopupObj("last");
			ld("#"+popupobj.divid+" [id=tabField]").html(data.result.fieldsel);
            DelProgressObjs();
		}else{
			var confirm_str = alert_arr.ERROR_WHILE_EDITING;
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            DelProgressObjs();
			return false;
		}
	})
}

//禁用和删除规则
AutomaticReminds.ControllReminds = function(record,mode,type){
   if(type == '3')
    {
        var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

        //确定按钮
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            AutomaticReminds.ContdControllReminds(record,mode,type);
        });
        return ;
    }
    AutomaticReminds.ContdControllReminds(record,mode,type);

}
//禁用和删除规则
AutomaticReminds.ContdControllReminds = function(record,mode,type){
	var surl =  'index.php?module=Settings&action=SettingsAjax&file=ControllReminds&record='+record+'&blockid='+mode+'&type='+type;
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			AutomaticReminds.refresh();
            DelProgressObjs();
		}
	})
}
//提醒时间 自定义 或者 参考字段
function getdatashow(obj)
{
    var dothis = obj.options[obj.options.selectedIndex].value;
    //alert(dothis)
    if(dothis == 'dothis'){
        document.getElementById('showcanlender').style.display = '';
        document.getElementById('FieldType').value='FieldType';
    }else{
        document.getElementById('showcanlender').style.display = 'none';
        document.getElementById('FieldType').value='';
    }   
}

function RemindsMethod(obj){
    var reminds_method= document.getElementById('reminds_method');
    var method = obj.options[reminds_method.options.selectedIndex].value;
    // alert(method)
    ld('.borderBR br').remove();
    if(method == '2'){
        document.getElementById('remindnums').style.display = 'none';
        //ld('#remindrule2').after('<br>');//指定提醒周期，后面换行显示
        var remindNum = document.getElementById('remindsNums').value;
        remindNum = parseInt(remindNum);//转数值类型
       
        var remindhtml ="";
       
        if(remindNum  > 0){
            for(var i=1;i<=remindNum;i++){
                remindhtml += '<span>'+arrJsPopLabel['LINE']+i+arrJsPopLabel['TIME']+'&nbsp;<input type="text" size=12 id="remindnums2'+i+'" name="remindnums2'+i+'" class="ld-input-inner width50">&nbsp;'+arrJsPopLabel['DAY']+arrJsPopLabel['AFTERTHE']+'</span>&nbsp;&nbsp;&nbsp;&nbsp;';
                document.getElementById('method2Nums').value=i;
                if(i%4 == 0)
                    remindhtml +="<br>";
            }
        }
        if(remindhtml != ''){
            document.getElementById('remindhtml1').innerHTML = remindhtml;
            document.getElementById('remindrule2').style.display = 'inline'; 
            document.getElementById("remindsNums").style.display='inline';
            document.getElementById('remindrule1').style.display = 'none';
            document.getElementById('remindrule3').style.display = 'none';
            document.getElementById('remindhtml3').style.display = 'none'; 
            document.getElementById('remindnums1').style.display='none';
            if(document.getElementById("remindsNums_label")!=undefined)
			    document.getElementById('remindsNums_label').style.display = 'inline';                      
        }
        document.getElementById('autoremindtimes').style.display = '';
    }
    else if(method == '3')
    {
        document.getElementById('remindhtml1').innerHTML = '';
        document.getElementById('remindrule1').style.display = 'none';
        document.getElementById('remindrule2').style.display = 'none'; 
        document.getElementById('remindrule3').style.display = 'inline';  
        document.getElementById('remindhtml3').style.display = 'inline';   
        document.getElementById('remindnums').style.display = 'none';
        if(document.getElementById("remindsNums_label")!=undefined)
		    document.getElementById('remindsNums_label').style.display = 'none';
        document.getElementById("remindnums1").style.display='none';
        document.getElementById("remindsNums").style.display='none';
        document.getElementById('method2Nums').value='';
        document.getElementById('autoremindtimes').style.display = 'none';//49169
    }
    else
    {
        document.getElementById('remindhtml1').innerHTML = '';
        document.getElementById('remindnums1').style.display='inline';
        document.getElementById('remindrule1').style.display = 'inline';
        document.getElementById("remindsNums").style.display='inline';
        document.getElementById('remindrule2').style.display = 'none'; 
        document.getElementById('remindrule3').style.display = 'none';  
        document.getElementById('remindhtml3').style.display = 'none';     
        document.getElementById('remindnums').style.display = '';
        document.getElementById('method2Nums').value='';
        if(document.getElementById("remindsNums_label")!=undefined)
		  document.getElementById('remindsNums_label').style.display = 'inline';
        document.getElementById('autoremindtimes').style.display = '';
    }
}
//获取提醒次数
function getRemindsnums(obj)
{
    //提醒次数
    var remindsNums = obj.options[obj.options.selectedIndex].value;
 
    //return remindsNums;
    RemindsMethod(obj);
}
//自动提醒规则表单验证
function formValidateRemind(){ 

    
}


//模拟提醒内容设置,现这样处理
function formatInfocontent(){
    var remindcontent=document.forms['formatInfo'].remindcontent.value;
    document.getElementById('divSendInform').style.display = 'none';
    document.getElementById('reminds_content').value=remindcontent;
    fninvshnew('','divSendInform');
}
//获取当前时间
function CurentTime()
{ 
    var now = new Date();
   
    var year = now.getFullYear();       //年
    var month = now.getMonth() + 1;     //月
    var day = now.getDate();            //日
   
    var hh = now.getHours();            //时
    var mm = now.getMinutes();          //分
    var ss = now.getSeconds(); 
   
    var clock = year + "-";
   
    if(month < 10)
        clock += "0";
   
    clock += month + "-";
   
    if(day < 10)
        clock += "0";
       
    clock += day + " ";
   
    if(hh < 10)
        clock += "0";
       
    clock += hh + ":";
    if (mm < 10) clock += '0'; 
    clock += mm + ":";
    
    if (ss < 10) clock += '0'; 
    clock += ss;  
    return(clock); 
}

function InsertTemplate(obj)
{
    var popupobj=CrmPopup.getPopupObj("last");
    if(trim(ld("#"+popupobj.divid+" #selField").val())=="")
    {
        //请选择字段！
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    ld("#"+popupobj.divid+" #CKcontent").val(ld("#"+popupobj.divid+" #CKcontent").val()+ld("#"+popupobj.divid+" #selField").val());
}


function insertText(obj,str) {
    if (document.selection) {
        var sel = document.selection.createRange();
        sel.text = str;
    } else if (typeof obj.selectionStart === 'number' && typeof obj.selectionEnd === 'number') {
        var startPos = obj.selectionStart,
            endPos = obj.selectionEnd,
            cursorPos = startPos,
            tmpStr = obj.value;
        obj.value = tmpStr.substring(0, startPos) + str + tmpStr.substring(endPos, tmpStr.length);
        cursorPos += str.length;
        obj.selectionStart = obj.selectionEnd = cursorPos;
    } else {
        obj.value += str;
    }
}

function CloseDivSendInformContent(idname){
    var newbox=document.getElementById(idname);
    newbox.style.display="none";
    var divold=document.getElementById(divold);
    fninvshnew('divSendInform_content');
}


function getRemindsModule(reminds_module,BLOCKIDSETTING,FIELDIDSETTING)
{
    var modulename = reminds_module.options[reminds_module.options.selectedIndex].value;
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Settings&action=SettingsAjax&file=AutomaticReminds&blockid='+modulename+'&parenttab=Settings&ajax=true&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
            onComplete: function(response) {
                //$("cfList").innerHTML=response.responseText;
                document.getElementById('cfList').innerHTML = response.responseText;
                autoRemindMovetable();
            }
        }
    );    
}

function getSpecifyUserIds()
{
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        
        ScopePopup_Details.getInstance().wareHouseselectUser('userid','userid_name','approvestep');
    });
}