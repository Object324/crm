//自动化进度功能页面设置相关js
function AdvanceRelation(){
    var that=this;

}

//进度跟踪设置
AdvanceRelation.getAdvanceList=function()
{
    
    AdvanceRelation.showPreviewProcess()
    return '';
    
    var popupobj=CrmPopup.getPopupObj('last');
    var frommodule=popupobj.frommodule;
    ld.ajax({

        url:'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockModuleAdvance&modulename='+frommodule,
        timeout:10000,
        type: 'POST',
        data:'',
        dataType:'json',
        success:function(data)
        {

            if(data.code==1)
            {
                hidePageLayOutDiv();
                ld("#dv_advance_content").html(data.result.content);
                ld("#dv_advance").css("display",'');

            }
        }
    })
}
//显示推进预览图
AdvanceRelation.showPreviewProcess = function () {
    var popupobj=CrmPopup.getPopupObj('last');
    var frommodule=popupobj.frommodule;
    var advance_processobj = new cls_advance_process(popupobj,frommodule);
    advance_processobj.showsetting();
}

//进度跟踪设置 - 进度跟进方式
AdvanceRelation.change_tracking_method=function(obj,module){

    var popupobj=CrmPopup.getPopupObj('last');
    var divid=popupobj.divid;
    if(obj.value == 'field'){
        ld('#td_select_field').show();
        ld('#td_select_fields').show();
        ld('#advancetask').show();
        ld('#pushstyle').show();
        ld('#tr_select_period_date').hide();
        AdvanceRelation.fieldname_change(ld('select[name=module_field]'),module);
    }else{
        ld('#td_select_field').hide();
        ld('#td_select_fields').hide();
        ld('#advancetask').hide();
        ld('#pushstyle').hide();
        ld('#tr_select_period_date').show();
    }
}

//进度跟踪设置 - 保存
AdvanceRelation.saveModuleAdvance=function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid="dv_advance_content";
    var _method = CrmPopup.findHtmlobj(divid,'method').val();
    var frommodule = CrmPopup.findHtmlobj(divid,'frommodule').val();
    var param = {};
    if(_method == 'period'){
        var start_date_field_obj = CrmPopup.findHtmlobj(divid,'module_period_start_date_field');
        var end_date_field_obj = CrmPopup.findHtmlobj(divid,'module_period_end_date_field');
        if(start_date_field_obj.val() == end_date_field_obj.val()){
            var start_date_field_label = start_date_field_obj.attr('tag');
            var end_date_field_obj_label = end_date_field_obj.attr('tag');
            var _msg = start_date_field_label + arrJsPopLabel['AND'] + end_date_field_obj_label + arrJsPopLabel['Cannotbesettothesamefield'];
            RemindsMsg("","LdPopWidth500px","","yes","yes",_msg);
            return false;
        }
    }else{
        //阶段任务信息
        //param['advancetask'] = saveAdvanceTask();
    }

    var _url = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=saveLayoutBlockAdvance&frommodule='+frommodule;
    //var state = ld("input[name='box_"+i+"']").is(':checked');
    var enable = CrmPopup.findHtmlobj(divid,'enable').is(':checked');
    //启用进度跟踪
    if(enable){
        _url += '&enable=yes';
    }else{
        _url += '&enable=no';
    }
    //进度跟踪方式
    _url += '&method='+CrmPopup.findHtmlobj(divid,'method').val();
    //选择跟踪字段
    _url += '&module_field='+CrmPopup.findHtmlobj(divid,'module_field').val();
    //选择起始日期字段
    _url += '&module_period_start_date_field='+CrmPopup.findHtmlobj(divid,'module_period_start_date_field').val();
    //选择截止日期字段
    _url += '&module_period_end_date_field='+CrmPopup.findHtmlobj(divid,'module_period_end_date_field').val();
    //显示推进人和时间
    var showadvancelog = CrmPopup.findHtmlobj(divid,'showadvancelog').val();
    _url += '&showadvancelog='+showadvancelog;

    //移动端启用进度跟踪
    var showadvancemobile = CrmPopup.findHtmlobj(divid,'showadvancemobile').is(':checked');
    if(showadvancemobile){
        _url += '&showadvancemobile=yes';
    }else{
        _url += '&showadvancemobile=no';
    }
    //允许回推（管理员自动拥有此权限）
    _url += '&pushback=no';
    //var pushback = CrmPopup.findHtmlobj(divid,'pushback').is(':checked');
//	if(pushback){
//		_url += '&pushback=yes';
//	}else{
//
//	}
    //推进操作样式
    _url += '&operatestyle='+CrmPopup.findHtmlobj(divid,'operatestyle').val();
    //推进日志显示样式
    _url += '&logshowstyle='+CrmPopup.findHtmlobj(divid,'logshowstyle').val();

    ldAjax(_url,param,function(data){
        if(data.code == 1){
            DelProgressObjs();
            var _msg = arrJsPopLabel['SUCCESSFULLYSAVED'];
            // RemindsMsg("","LdPopWidth400px","","yes","yes",_msg);
            MessagePopup.TipOne_success(_msg);
            return false;
        }else{
            DelProgressObjs();
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            return false;
        }
    })
}

//关联字段切换时，切换阶段任务
AdvanceRelation.fieldname_change=function(obj,module){
    var fieldname = ld(obj).val();
    if(empty(fieldname)){
        fieldname = obj.val();
    }
    var surl = "index.php?module=Settings&action=SettingsAjax&file=LayoutBlockModuleAdvance";
    surl += "&fieldname="+fieldname+'&modulename='+module;
    ldAjax(surl,"",function(data){
        if(data.code==1){
            ld("[name=advancetask]").html(data.result.content);
        }
        DelProgressObjs();
    });
}

//保存阶段之间的推进关系
AdvanceRelation.save = function(obj){
    //控制任务阶段的设置按钮是否显示
    var set_obj = ld(obj).parent().find('b');
    if(ld(obj).is(':checked')){
        set_obj.show();
        var presence = 'yes';
    }else{
        set_obj.hide();
        var presence = 'no';
    }
    //获取当前模块和关联追踪字段
    var divid="dv_advance_content";
    var frommodule = CrmPopup.findHtmlobj(divid,'frommodule').val();
    var module_field=CrmPopup.findHtmlobj(divid,'module_field').val();

    //开始阶段编号和目标阶段编号
    var stagename_start = ld(obj).attr('stagevalue_start');
    var stagename_target = ld(obj).attr('stagevalue_target');
    //开始阶段名称和目标阶段名称
    //var stagename_start = ld("[name=stagename][stagenum="+stagenum_start+"]").val();
    //var stagename_target = ld("[name=stagename][stagenum="+stagenum_target+"]").val();

    var url = 'index.php?module=Settings&action=SettingsAjax&file=SaveAdvanceRelation';
    var param = {'frommodule':frommodule,'module_field':module_field,'stagename_start':stagename_start,'stagename_target':stagename_target};
    param['presence'] = presence;
    //传值到后台进行保存
    ldAjaxNoProgress(url,param,function(data){
        if(data.code == 1){
            set_obj.attr('advanceid',data.result.advanceid);
        }else if(data.code == -1){
            ld(obj).prop('checked',!ld(obj).is(':checked'));
            RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
        }
    });
}

//推进关系的任务编辑界面弹出层
AdvanceRelation.EditInfo = function(obj){
    var popupobj=CrmPopup.getPopupObj('last');

    var advanceid = ld(obj).attr('advanceid');
    //判断推进关系id是否存在，不存在则给出提示
    if(empty(advanceid)||advanceid<=0){
        RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASESETRELATION']);
        return false;
    }
    var url = 'index.php?module=Settings&action=SettingsAjax&file=EditAdvanceRelationInfo';
    var param = {'advanceid':advanceid};
    //编辑界面弹出层
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'',"","","","");
    ldAjax(url,param,function(data){
        if(data.code == 1){
            crmPopupobj.setParams(data.result.title,AdvanceRelation.SaveInfo,"","LdPopWidth800px",popupobj.module,"",data.result.oktext,"",data.result.canceltext,"");
            // crmPopupobj.show(data.result.content);
            CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            var TaskInfoArr = data.result.TaskInfoArr;
            crmPopupobj.TaskInfoArr = TaskInfoArr;
            crmPopupobj.Tasklabel_withTaskid = data.result.Tasklabel_withTaskid;
            ld("#"+crmPopupobj.divid).find("[name=selectuserfields]").select2({closeOnSelect: true,dropdownParent:ld("#"+crmPopupobj.divid)});
            ld("#"+crmPopupobj.divid+" .select2").css('width',"100%");
            AdvanceRelation.dragMoveTask();// 拖动排序
            tooltip(ld("#"+crmPopupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
        }else if(data.code == -1){
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASESETRELATION']);
        }
    });
}

//保存编辑推进详细页面信息
AdvanceRelation.SaveInfo = function(){
    var popupobj=CrmPopup.getPopupObj("last");
    //获取模块和追踪字段信息
    var divid="dv_advance_content";
    var prevpopupobj = CrmPopup.getPopupObj("lastprev");
    var frommodule = prevpopupobj.module;
    var module_field= prevpopupobj.fieldname;

    var advanceid = ld("#"+popupobj.divid+" [name=advanceid]").val();//获取推进关系id
    var profileid = ld("#"+popupobj.divid+" [name=user_role]").val();//获取角色权限id
    var userid = ld("#"+popupobj.divid+" [name=userid]").val();//获取选中用户的id
    //获取选中的用户字段字段id
    var selectdatas= ld("#"+popupobj.divid+" .selectfields").select2('data');
    var userfieldid_arr = new Array();
    ld.each(selectdatas,function(index,info){
        var userfieldid=info.id;
        userfieldid_arr.push(userfieldid);
    })
    var userfieldid_str = userfieldid_arr.join(',');

    //获取任务信息
    var taskinfo = {};
    var all_taskinfo = [];
    var stagenum = 0;
    var task_sequence = 0;
    var Tasklabel_withTaskid = popupobj.Tasklabel_withTaskid;
    // console.log('Tasklabel_withTaskid: ', Tasklabel_withTaskid);
    var tabelobj = ld("#"+popupobj.divid).find('table#AdvanceTaskTable');
    var trobjs = tabelobj.find('tr');
    var taskid = '';
    var tasklabelarr = [];
    var tasklabelinfo = {};
    // console.log(popupobj.TaskInfoArr);
    if(!empty(popupobj.TaskInfoArr)){
        ld.each(trobjs,function(i,trobj){
            if(i == 0){
                return;
            }

            taskinfo = {};
            stagenum = ld(trobj).attr('trindex');// 行号，也代表未改变排序前的task_sequence+1
            task_sequence  = stagenum-1;
            var tasktype = ld(trobj).attr('tasktype');
            var old_tasklabel_withid = Tasklabel_withTaskid[task_sequence];// 当前行原tasklabel与taskid对应关系
            taskid = '';
            tasklabelarr = [];
            tasklabelinfo = {};

            var tmp_tasklabelstr = popupobj.TaskInfoArr[tasktype];

            if(tasktype=='module'){//创建单据任务
                var tmp_modulestr = tmp_tasklabelstr;
                taskinfo['modulestr'] = tmp_modulestr[task_sequence];
                taskinfo['effect_range'] = ld(trobj).find('[name=modulename_'+stagenum+']').data('effect_range');
                taskinfo['approve_demand'] = ld(trobj).find('[name=modulename_'+stagenum+']').data('approve_demand');
                
                if(empty(taskinfo['modulestr']))
                    return;

                tasklabelarr = taskinfo['modulestr'].split("##");         
                
            }else if(tasktype == 'field'){//必填字段任务
                var tmp_fieldnamestr = tmp_tasklabelstr;
                taskinfo['fieldnamestr'] = tmp_fieldnamestr[task_sequence];
                taskinfo['effect_range'] = ld(trobj).find('[name=fieldname_'+stagenum+']').data('effect_range');

                if(empty(taskinfo['fieldnamestr']))
                    return;

                tasklabelarr = taskinfo['fieldnamestr'].split("##");  
                
            }else if(tasktype == 'checkbox'){

                var alltext = tmp_tasklabelstr;
                alltext = alltext[task_sequence];
                if(empty(alltext))
                    return;
                taskinfo['alltext']=alltext;

                tasklabelarr = alltext.split("##");

            }else if(tasktype == 'select'){//选项型任务

                var selecttaskname = ld("[name=selecttaskname_"+stagenum+"]").val();

                var allselect = tmp_tasklabelstr;
                allselect = allselect[task_sequence];
                if(empty(allselect))
                    return;
                taskinfo['allselect']=allselect;

                if(empty(selecttaskname)){
                    taskinfo['selecttaskname']="";
                }else{
                    taskinfo['selecttaskname']=selecttaskname;
                }
            }else if(tasktype == 'validata'){//验证规则

                var inputobj = ld("[name=validata_"+stagenum+"]");
                if(inputobj.length == 0){
                    return;
                }
                taskinfo['validataid'] = inputobj.data('validataid');
            }

            //是否启用
            if(ld(trobj).find(" [name=presence]").is(':checked')){
                taskinfo['presence'] = 'yes';
            }else{
                taskinfo['presence'] = 'no';
            }
            //是否必做
            if(ld(trobj).find(" [name=completerequest]").is(':checked')){
                taskinfo['completerequest'] = 'yes';
            }else{
                taskinfo['completerequest'] = 'no';
            }

            // 获取每个模块，字段，复选框先前已保存的对应taskid，若是新增的则没有taskid
            if(tasktype=='module' || tasktype=='field'){
                ld.each(tasklabelarr,function(index,tasklabel){
                    if(!empty(old_tasklabel_withid)){
                        taskid = Object.keys(old_tasklabel_withid).find(key => old_tasklabel_withid[key] === tasklabel);// 获取对应taskid
                    }
                    taskid = !empty(taskid)?taskid:'';
                    tasklabelinfo[tasklabel] = taskid;
                });
                taskinfo['tasklabelinfo'] = tasklabelinfo;
            }
            else if(tasktype == 'select'){// 下拉框直接根据行号就可以获取到taskid，选项在后台判断
                if(!empty(old_tasklabel_withid)){
                    taskid = Object.keys(old_tasklabel_withid)[0];// 获取对应taskid
                }
                taskid = !empty(taskid)?taskid:'';
                taskinfo['tasklabelinfo'] = taskid;
            }
            else if(tasktype == 'checkbox'){
                var tmp_tasklabel = {};
                ld.each(tasklabelarr,function(index,tasklabel){
                    tmp_tasklabel = {};
                    if(!empty(old_tasklabel_withid)){
                        taskid = Object.keys(old_tasklabel_withid).find(key => old_tasklabel_withid[key] === tasklabel);// 获取对应taskid
                    }
                    taskid = !empty(taskid)?taskid:'';
                    tmp_tasklabel = {'taskid':taskid,'tasklabel':tasklabel};
                    tasklabelinfo[index] = tmp_tasklabel;
                });
                taskinfo['tasklabelinfo'] = tasklabelinfo;
            }

            taskinfo['tasktype'] = tasktype;
            all_taskinfo.push(taskinfo);

        });
    }
    var surl = "index.php?module=Settings&action=SettingsAjax&file=SaveAdvanceRelationInfo";
    var param = {'frommodule':frommodule,'advanceid':advanceid,'profileid':profileid,'userid':userid,'userfieldid_str':userfieldid_str};
    param['all_taskinfo'] = all_taskinfo;
    // console.log('all_taskinfo: ', all_taskinfo);
    param['module_field'] = module_field;

    //是否完成任务后自动推进
    if(ld("#"+popupobj.divid+" [name=autopush]").is(':checked')){
        param['autopush'] = 'yes';
    }else{
        param['autopush'] = 'no';
    }

    // 任务描述
    param['taskdescription'] = ld("#"+popupobj.divid).find("[name=taskdescription]").val();

    ldAjax(surl,param,function(data){
        DelProgressObjs();
        if(data.code == 1){
            popupobj.CancelEvent();
            if(data.result.hascontent == 'yes'){
                ld("b[advanceid="+advanceid+"]").attr('class','icon-wrenchhand');
            }else{
                ld("b[advanceid="+advanceid+"]").attr('class','icon-emptywrenchhand');
            }
        }else if(data.code == -1){
            RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
        }
    })
}

//stagenum:任务的行号
//设置任务弹出框
AdvanceRelation.setAdvancetask = function(module,stagenum,tasktype,taskmode)
{
    var Width = "LdPopWidth800px";
    var param ={};
    var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    //进入修改页面后，启用该类型的任务
    ld("#"+divid+" [name=presence][stagenum="+stagenum+"]").prop('checked',true);
    // if(tasktype == 'field'){
    //     ld("#"+divid+" [name=completerequest][stagenum="+stagenum+"]").prop('checked',true);
    // }
    var completerequest = ld("#"+divid).find(" [name=completerequest][stagenum="+stagenum+"]").prop('checked');
    var stagename = CrmPopup.findHtmlobj(divid,'stagename_'+stagenum).val();
    var surl = "index.php?module=Settings&action=SettingsAjax&file=Advancetask";
    surl += "&stagenum="+stagenum+"&tasktype="+tasktype+"&taskmode="+taskmode+"&modulename="+module+"&stagename="+stagename;

    var TaskInfoArr = popupobj.TaskInfoArr[tasktype];
    var param = {};
    if(tasktype=="module"){
        if(taskmode=='edit'){
            var modulestr = ld("#"+divid+" [name=modulename_"+stagenum+"]").attr("modulestr");
            if(!empty(modulestr)){
                surl += "&modulestr="+modulestr;
            }
            surl += "&effect_range="+ld("#"+divid+" [name=modulename_"+stagenum+"]").data("effect_range");
            surl += "&approve_demand="+ld("#"+divid+" [name=modulename_"+stagenum+"]").data("approve_demand");
        }

        if(!empty(TaskInfoArr) && Object.keys(TaskInfoArr).length > 0){
            var other_modulestr = '';

            ld.each(TaskInfoArr,function(tmpi,tasklabelstr){
                if(tmpi != (stagenum-1)){
                    other_modulestr += other_modulestr+tasklabelstr;
                }
            });
            param = {'other_modulestr':other_modulestr};
        }
    }else if(tasktype=="field"){
        if(taskmode=='edit'){
            var fieldnamestr = ld("#"+divid+" [name=fieldname_"+stagenum+"]").attr("fieldnamestr");
            if(!empty(fieldnamestr)){
                surl += "&fieldnamestr="+fieldnamestr;
            }
            surl += "&effect_range="+ld("#"+divid+" [name=fieldname_"+stagenum+"]").data("effect_range");
        }

        if(!empty(TaskInfoArr) && Object.keys(TaskInfoArr).length > 0){
            var other_fieldnamestr = '';

            ld.each(TaskInfoArr,function(tmpi,tasklabelstr){
                if(tmpi != (stagenum-1)){
                    other_fieldnamestr += other_fieldnamestr+tasklabelstr;
                }
            });
            param = {'other_fieldnamestr':other_fieldnamestr};
        }
    }else if(tasktype=="checkbox"){
        var optionname = "checkinfo_"+stagenum;
        var checkinfoobj = CrmPopup.findHtmlobj(divid,optionname);
        var optionsobjs = checkinfoobj.find("option");
        var alltext = "";
        ld.each(optionsobjs,function(){
            var text=ld(this).text();
            if(alltext==""){
                alltext =text;
            }else{
                alltext +='##'+text;
            }
        });
        param = {'alltext':alltext};
    }else if(tasktype=="select") {
        var optionname = "selectinfo_" + stagenum;
        var selecttaskname = ld("[name=selecttaskname_" + stagenum + "]").val();
        var checkinfoobj = CrmPopup.findHtmlobj(divid, optionname);
        var optionsobjs = checkinfoobj.find("option");
        var allselect = "";
        ld.each(optionsobjs, function () {
            var selectstr = ld(this).text();
            if (allselect == "") {
                allselect = selectstr;
            } else {
                allselect += '##' + selectstr;
            }
        });
        param = {'allselect': allselect, 'selecttaskname': selecttaskname};
    }else if(tasktype=='validata'){
        //验证规则处理
        var validataid = ld("#"+divid+" [name=validata_"+stagenum+"]").data("validataid");
        if(empty(validataid)){
            validataid = 0;
        }
        AdvanceRelation.setValidataAdvancetask(validataid,module,stagenum);
        return '';
    }else{
        var confirm_str = arrJsPopLabel['CHOOSETASKTYPE'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }
    var crmPopupobj=CrmPopup.load("","","",Width,'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjax(surl,param,function(data){
        if(data.code==1){
            //选项型任务增加一个删除按钮
            if(tasktype == 'select'){
                crmPopupobj.setParams(data.result.title,"","",Width,module,"","","","");
                crmPopupobj.quickcreatehtml=data.result.content;
                crmPopupobj.show(data.result.content);
                crmPopupobj.tasktype = tasktype;
                crmPopupobj.stagenum = stagenum;
                ld("#"+crmPopupobj.divid).addClass("dvpopupsroll");
                AdvanceRelation.movebuttoncheck();
            }else{
                crmPopupobj.setParams(data.result.title,AdvanceRelation.advancetask_save,"",Width,module,"",data.result.oktext,"",data.result.canceltext);
                crmPopupobj.quickcreatehtml=data.result.content;
                // crmPopupobj.show(data.result.content);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
                crmPopupobj.tasktype = tasktype;
                crmPopupobj.stagenum = stagenum;
                if(tasktype =='field'){
                    ld("#"+crmPopupobj.divid+" [name=allmember]").val(data.result.reminds_field);
                    ld("#"+crmPopupobj.divid+" [name=allmember]").attr('tag',data.result.reminds_field);
                }
                if(tasktype =='module'||tasktype =='field'){
                    var tableobj = ld('#'+crmPopupobj.divid).find("table#EditTaskTable");
                    var LeftObj = tableobj.find("#AssmablyList");
                    var RightObj = tableobj.find("#selectedAssmablyColumns");
                    var Drag_Transfer = new DragTransfer();
                    if(tasktype == 'module'){
                        var translabel = {
                            available: arrJsPopLabel['OptionModules'],
                            selected: arrJsPopLabel['Selectedmodule'],
                            placeholder: arrJsPopLabel['PleaseEnterModuleSearchFor'],
                        };
                        Drag_Transfer.SetTranslabel(translabel);
                    }
                    Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','270');
                }else{
                    ld("#"+crmPopupobj.divid).addClass("dvpopupsroll");
                }
                
                crmPopupobj.center();
            }
            ld("#"+crmPopupobj.divid).find('[name=completerequest]').prop('checked',completerequest);
        }
        DelProgressObjs();
    })
}

AdvanceRelation.setValidataAdvancetask = function(id,module,stagenum){
    var popupobj = CrmPopup.getPopupObj('last');
    popupobj.frommodule = module;
    var trobj = ld('#'+popupobj.divid+' #AdvanceTaskTable tr[trindex='+stagenum+']');
    var tasktype = 'validata';
    var cls_pagevalidataobj=new cls_PageValidata();
    cls_pagevalidataobj.get_editurl = function (id) {
        var url = "index.php?module=Settings&action=SettingsAjax&file=PageValidataPopup&id="+id+"&frommodule="+module+'&fromtype=advance';
        return url;
    };
    cls_pagevalidataobj.after_save = function(ajaxdata){


        var html = '<input readonly="readonly" name="validata_'+stagenum+'" data-validataid="'+ajaxdata.result.return_id+'" onclick="AdvanceRelation.setAdvancetask(\''+module+'\',\''+stagenum+'\',\''+tasktype+'\',\'edit\')" class="advanceTextBox gwidth85 bgwhite ld-input-inner" id="setAdvancetask" type="text" style="cursor: pointer" value="'+ajaxdata.result.return_name+'"/>';
        trobj.find('[name=div_content_'+stagenum+']').html(html);
        if(ajaxdata.result.return_status == 'active'){
            trobj.find('[name=div_content_'+stagenum+']').prop('checked',true);
        }else{
            trobj.find('[name=presence]').prop('checked',false);
        }
        popupobj.TaskInfoArr[tasktype][stagenum-1] = ajaxdata.result.return_id;
    }

    cls_pagevalidataobj.operateData(id);
}

AdvanceRelation.advancetask_save = function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var tasktype = popupobj.tasktype;
    var module = popupobj.module;
    var stagenum = popupobj.stagenum;
    var presence = ld('#'+popupobj.divid).find('[name=presence]').prop('checked');
    var completerequest = ld('#'+popupobj.divid).find('[name=completerequest]').prop('checked');

    var prevpopupobj = CrmPopup.getPopupObj("lastprev");

    switch(tasktype){
        case 'module'://单据模块
            AdvanceRelation.advancetask_module_save(module,tasktype,stagenum);
            break;
        case 'checkbox'://复选框
            AdvanceRelation.advancetask_checkbox_save(module,tasktype,stagenum);
            break;
        case 'select'://下拉框
            AdvanceRelation.advancetask_select_save(module,tasktype,stagenum);
            break;
        case 'field':
            AdvanceRelation.advancetask_field_save(module,tasktype,stagenum);
            break;
        default: break;
    }
    var popupobj=CrmPopup.getPopupObj("last");
    ld("#"+popupobj.divid).find(" [name=presence][stagenum="+stagenum+"]").prop('checked',presence);
    ld("#"+popupobj.divid).find(" [name=completerequest][stagenum="+stagenum+"]").prop('checked',completerequest);

}
//单据模块保存
AdvanceRelation.advancetask_module_save = function(module,tasktype,stagenum)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    if(selectedColumnsObj.options.length > 0){
        for (i=0;i<selectedColumnsObj.options.length;i++)
        {
            selectedColStr += selectedColumnsObj.options[i].value + "##";
        }
    }else{
        var warning_tips = arrJsPopLabel['PleaseSelectAtLeastOneVar'];
	    warning_tips = warning_tips.replace("{Var}",arrJsPopLabel['MODULE']);
        MessagePopup.TipOne_warning(warning_tips);
        return;
    }
    var effect_range=ld("#"+popupobj.divid+" [name=effect_range]").val();
    var approve_demand=(ld("#"+popupobj.divid+" [name=approve_demand]").prop("checked")?'yes':'no');


    var param = {'selectedmodule':selectedColStr};
    var url = "index.php?module=Settings&action=SettingsAjax&file=Advancetask";
    url += "&stagenum="+stagenum+"&tasktype="+tasktype+"&modulename="+module+"&taskmode=save";

    url += "&effect_range="+effect_range;
    url += "&approve_demand="+approve_demand;

    popupobj.CancelEvent();

    ldAjax(url,param,function(data){
        if(data.code==1){
            ld("[name=div_content_"+stagenum+"]").html(data.result.content);
            var popupobj=CrmPopup.getPopupObj("last");
            popupobj.TaskInfoArr['module'][stagenum-1] = selectedColStr;
        }
        DelProgressObjs();
    });
}
//单选框内容保存
AdvanceRelation.advancetask_checkbox_save = function(module,tasktype,stagenum){
    var popupobj=CrmPopup.getPopupObj("last");
    var text_num_obj = CrmPopup.findHtmlobj(popupobj.divid,'tr_num');
    var maxno = text_num_obj.val();
    var checkboxstr = "";
    var checkboxarr = new Array();
    for(i=0;i<maxno;i++){
        newvalue_name = 'checkboxtext_'+i;
        if(CrmPopup.findHtmlobj(popupobj.divid,newvalue_name).length>0){
            var checkbox_obj = CrmPopup.findHtmlobj(popupobj.divid,newvalue_name);
            var tmp_str = ld.trim(checkbox_obj.val());
            if(ld.trim(tmp_str)!=""){
                if(checkboxarr.indexOf(tmp_str)!=-1){
                    var confirm_str =arrJsPopLabel['NOSAMEOPTION'];
                    // AdvanceRelation.audioRemindsMsg_advance("","","","","",confirm_str);
                    MessagePopup.TipZero_warning(confirm_str);
                    return false;
                }else{
                    checkboxarr.push(tmp_str);
                }
                checkboxstr += tmp_str +"##";
            }
        }
    }
    if(empty(checkboxstr)){
        MessagePopup.TipZero_warning(arrJsPopLabel['TaskTextCannotEmpty']);
        return false;
    }
    popupobj.CancelEvent();
    var param = {'checkboxstr':checkboxstr};
    var url = "index.php?module=Settings&action=SettingsAjax&file=Advancetask";
    url += "&stagenum="+stagenum+"&tasktype="+tasktype+"&modulename="+module+"&taskmode=save";
    ldAjax(url,param,function(data){
        if(data.code==1){
            ld("[name=div_content_"+stagenum+"]").html(data.result.content);
            if(checkboxarr.length==0){
                ld("a[name=cmb_a_checkbox_"+stagenum+"]").css('border','1px solid #dbdbdb');
            }
            var popupobj=CrmPopup.getPopupObj("last");
            popupobj.TaskInfoArr['checkbox'][stagenum-1] = checkboxstr;
        }
        DelProgressObjs();
    });
}

//下拉框内容保存
AdvanceRelation.advancetask_select_save = function(module,tasktype,stagenum){
    var popupobj=CrmPopup.getPopupObj("last");
    var selecttaskname = ld("[name=selecttaskname]").val();
    if(ld.trim(selecttaskname)==''){
        var confirm_str =arrJsPopLabel['TASKNAME']+arrJsPopLabel['CANOTEMPTYGTH'];
        // AdvanceRelation.audioRemindsMsg_advance("","","","","",confirm_str);
        MessagePopup.TipZero_warning(confirm_str);
        return false;
    }
    var text_num_obj = CrmPopup.findHtmlobj(popupobj.divid,'tr_num');
    var maxno = text_num_obj.val();
    var selectstr = "";
    var selectarr = new Array();
    for(i=0;i<maxno;i++){
        newvalue_name = 'selecttext_'+i;
        if(CrmPopup.findHtmlobj(popupobj.divid,newvalue_name).length>0){
            var select_obj = CrmPopup.findHtmlobj(popupobj.divid,newvalue_name);
            var tmp_str = ld.trim(select_obj.val());
            if(ld.trim(tmp_str)!=""){
                if(selectarr.indexOf(tmp_str)!=-1){
                    var confirm_str =arrJsPopLabel['NOSAMEOPTION'];
                    MessagePopup.TipZero_warning(confirm_str);
                    return false;
                }else{
                    selectarr.push(tmp_str);
                }
                selectstr += tmp_str +"##";
            }
        }
    }
    if(empty(selectstr)){
        MessagePopup.TipZero_warning(arrJsPopLabel['DROPDOWNBOXOPTIONCANOTEMPTY']);
        return false;
    }
    popupobj.CancelEvent();
    var param = {'selectstr':selectstr,'selecttaskname':selecttaskname};
    var url = "index.php?module=Settings&action=SettingsAjax&file=Advancetask";
    url += "&stagenum="+stagenum+"&tasktype="+tasktype+"&modulename="+module+"&taskmode=save";
    ldAjax(url,param,function(data){
        if(data.code==1){
            ld("[name=div_content_"+stagenum+"]").html(data.result.content);
            var popupobj=CrmPopup.getPopupObj("last");
            popupobj.TaskInfoArr['select'][stagenum-1] = selectstr;
        }
        DelProgressObjs();
    });
}

//必填字段保存
AdvanceRelation.advancetask_field_save = function(module,tasktype,stagenum)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    if(selectedColumnsObj.options.length > 0){
        for (i=0;i<selectedColumnsObj.options.length;i++)
        {
            selectedColStr += selectedColumnsObj.options[i].value + "##";
        }
    }else{
        var warning_tips = arrJsPopLabel['PleaseSelectAtLeastOneVar'];
	    warning_tips = warning_tips.replace("{Var}",arrJsPopLabel['LBL_Field']);
        MessagePopup.TipOne_warning(warning_tips);
        return;
    }

    var param = {'selectedfieldname':selectedColStr};
    var url = "index.php?module=Settings&action=SettingsAjax&file=Advancetask";
    url += "&stagenum="+stagenum+"&tasktype="+tasktype+"&modulename="+module+"&taskmode=save";

    var effect_range=ld("#"+popupobj.divid+" [name=effect_range]").val();
    url += "&effect_range="+effect_range;

    popupobj.CancelEvent();
    ldAjax(url,param,function(data){
        if(data.code==1){
            ld("[name=div_content_"+stagenum+"]").html(data.result.content);
            var popupobj=CrmPopup.getPopupObj("last");
            popupobj.TaskInfoArr['field'][stagenum-1] = selectedColStr;
        }
        DelProgressObjs();
    });
}

//选项型任务增加删除按钮
AdvanceRelation.delete_selecttask=function(){
    var popupobj_last=CrmPopup.getPopupObj("last");
    var tasktype = popupobj_last.tasktype;
    var module = popupobj_last.module;
    var stagenum = popupobj_last.stagenum;

    var confirmstr = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("", "LdPopWidth400px","", "yes", "yes",confirmstr);
    var  popupobj=CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid+' .E_pbtnok').click(function(){
        popupobj_last.CancelEvent();
        var url = "index.php?module=Settings&action=SettingsAjax&file=Advancetask";
        url += "&stagenum="+stagenum+"&tasktype="+tasktype+"&modulename="+module;
        //切换类型时，清空原任务内容
        ldAjax(url,"",function(data){
            if(data.code==1){
                ld("[name=div_content_"+stagenum+"]").html(data.result.content);
                ld("a[name=cmb_a_checkbox_"+stagenum+"]").css('border','1px solid #dbdbdb');
            }
            DelProgressObjs();
        });
    })
}

//任务单选框内容增加
AdvanceRelation.checkbox_add_text=function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var text_num_obj = CrmPopup.findHtmlobj(popupobj.divid,'tr_num');
    var count = parseInt(text_num_obj.attr('count'));
    var text_num = parseInt(text_num_obj.val());
    var nextNode = CrmPopup.findHtmlobj(popupobj.divid,'add_checkbox') ;
    var newNode = document.createElement('tr');
    newNodeId = 'text_'+text_num;
    newNode.setAttribute('name',newNodeId);
    nextNode.before(newNode);
    node1 = document.createElement('td');
    node1.innerHTML = "<td><input name='checkboxtext_"+text_num+"' class='ld-input-inner' value='' type='text' placeholder='"+arrJsPopLabel['pleaseenter']+arrJsPopLabel['TASK']+arrJsPopLabel['Text']+"'/></td>";
    newNode.appendChild(node1);
    node2 = document.createElement('td');
    node2.innerHTML += "<td><a class='icon-category category-sup marR8' index='"+text_num+"' name='moveup_"+text_num+"' texttype='checkboxtext_' style='cursor: pointer;padding:0px 6px' movetype ='up' onclick='AdvanceRelation.text_move(this)' title='"+arrJsPopLabel['MOVEUP']+"'></a>"+
        "<a class='icon-category category-sdown marR8' index='"+text_num+"' name='movedown_"+text_num+"' texttype='checkboxtext_' style='cursor: pointer;' movetype='down' onclick='AdvanceRelation.text_move(this)' title='"+arrJsPopLabel['MOVEDOWN']+"'></a> "+
        "<a class='icon-homeimg icon-sdel' href='javascript:void(0)' texttype='text_'  onclick='AdvanceRelation.text_delete(this,"+text_num+")'  title='"+arrJsPopLabel['DELETE']+"'></a></td>";
    newNode.appendChild(node2);
    ld(newNode).css('height','45px');
    text_num_obj.val(text_num+1);
    text_num_obj.attr('count',count+1);
    text_num_obj.attr('maxindex',text_num);
    AdvanceRelation.movebuttoncheck();
}

//下拉框内容增加
AdvanceRelation.select_add_text=function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var text_num_obj = CrmPopup.findHtmlobj(popupobj.divid,'tr_num');
    var count = parseInt(text_num_obj.attr('count'));
    var text_num = parseInt(text_num_obj.val());
    var nextNode = CrmPopup.findHtmlobj(popupobj.divid,'add_select') ;
    var newNode = document.createElement('tr');
    newNodeId = 'selectinfo_'+text_num;
    newNode.setAttribute('name',newNodeId);
    newNode.height = '45px';
    nextNode.before(newNode);
    node1 = document.createElement('td');
    node1.innerHTML = "<td><input class='ld-input-inner' name='selecttext_"+text_num+"' value='' style='padding-left:3px;' type='text' placeholder='"+arrJsPopLabel['pleaseenter']+arrJsPopLabel['Text']+"'></td>";
    newNode.appendChild(node1);
    node2 = document.createElement('td');
    node2.setAttribute('class', 'sort_td');
    node2.innerHTML = "<td><a class='icon-category category-sup marR8' index='"+text_num+"' name='moveup_"+text_num+"' texttype='selecttext_' style='cursor: pointer;padding:0px 6px' movetype ='up' onclick='AdvanceRelation.text_move(this)' title='"+arrJsPopLabel['MOVEUP']+"'></a>"+
        "<a class='icon-category category-sdown marR8' index='"+text_num+"' name='movedown_"+text_num+"' texttype='selecttext_' style='cursor: pointer;' movetype='down' onclick='AdvanceRelation.text_move(this)' title='"+arrJsPopLabel['MOVEDOWN']+"'></a> "+
        "<a class='icon-homeimg icon-sdel' style='cursor: pointer;' onclick='AdvanceRelation.text_delete(this,"+text_num+");' texttype='selectinfo_' title='"+arrJsPopLabel['DELETE']+"'></a> </td>";
    newNode.appendChild(node2);
    ld(newNode).css('height','45px');
    text_num_obj.val(text_num+1);
    text_num_obj.attr('maxindex',text_num);
    text_num_obj.attr('count',count+1);
    AdvanceRelation.movebuttoncheck();
}

//下拉框内容删除
AdvanceRelation.text_delete=function(obj,text_num){
    var popupobj=CrmPopup.getPopupObj("last");
    var texttype = ld(obj).attr('texttype');
    var NodeId = texttype+text_num;
    var text_num_obj = CrmPopup.findHtmlobj(popupobj.divid,'tr_num');
    var count = parseInt(text_num_obj.attr('count'));
    var maxindex =parseInt(text_num_obj.attr('maxindex'));
    var minindex =parseInt(text_num_obj.attr('minindex'));
    var element = CrmPopup.findHtmlobj(popupobj.divid,NodeId);
    if(element){
        text_num_obj.attr('count',count-1);
        if(texttype == 'selectinfo_'){
            texttype = 'selecttext_';
        }else{
            texttype = 'checkboxtext_'
        }
        // if(count==1){//保留至少一个输入框
        //     if(texttype == 'selecttext_'){
        //         AdvanceRelation.select_add_text();
        //     }else{
        //         AdvanceRelation.checkbox_add_text();
        //     }
        // }
        element.remove();
        if(text_num==minindex){ //重新保存最大值和最小值
            for(i=0;i<=parseInt(text_num_obj.val());i++){
                newindex = i;
                newvalue_name = texttype+newindex;
                if(CrmPopup.findHtmlobj(popupobj.divid,newvalue_name).length>0){
                    text_num_obj.attr('minindex',newindex);
                    break;
                }
            }
        }else if(text_num==maxindex){
            for(i=0;i<=maxindex;i++){
                newindex = text_num-i;
                newvalue_name = texttype+newindex;
                if(CrmPopup.findHtmlobj(popupobj.divid,newvalue_name).length>0){
                    text_num_obj.attr('maxindex',newindex);
                    break;
                }
            }
        }
    }
    AdvanceRelation.movebuttoncheck();//设置上下移按钮显示或隐藏
}

//文本框内容移动
AdvanceRelation.text_move=function(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    var index = parseInt(ld(obj).attr('index'));
    var movetype = ld(obj).attr('movetype');
    var texttype = ld(obj).attr('texttype');
    var oldvalue_name = texttype+index;
    var oldinputobj = CrmPopup.findHtmlobj(popupobj.divid,oldvalue_name);
    var newindex;
    var newvalue_name;
    if(movetype=='up'){//上移
        for(i=1;i<=index;i++){
            newindex = index-i;
            newvalue_name = texttype+newindex;
            if(CrmPopup.findHtmlobj(popupobj.divid,newvalue_name).length>0){
                var newinputobj = CrmPopup.findHtmlobj(popupobj.divid,newvalue_name);
                break;
            }
        }
    }else if(movetype=='down'){//下移
        var maxno = CrmPopup.findHtmlobj(popupobj.divid,'tr_num').val();
        for(i=1;i<=maxno-index-1;i++){
            newindex = index+i;
            newvalue_name = texttype+newindex;
            if(CrmPopup.findHtmlobj(popupobj.divid,newvalue_name).length>0){
                var newinputobj = CrmPopup.findHtmlobj(popupobj.divid,newvalue_name);
                break;
            }
        }
    }
    var old_value = oldinputobj.val();
    var new_value = newinputobj.val();
    oldinputobj.val(new_value);
    newinputobj.val(old_value);
}

//隐藏第一列的上移按钮和最后一列的下移按钮
AdvanceRelation.movebuttoncheck=function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var text_num_obj = CrmPopup.findHtmlobj(popupobj.divid,'tr_num');
    var maxindex = text_num_obj.attr('maxindex');
    var minindex = text_num_obj.attr('minindex');
    var maxno = text_num_obj.val();
    for(i=0;i<maxno;i++){
        moveup_name= "moveup_"+i;
        movedown_name= "movedown_"+i;
        if(CrmPopup.findHtmlobj(popupobj.divid,moveup_name).length>0){
            var moveup_obj = CrmPopup.findHtmlobj(popupobj.divid,moveup_name);
            if(minindex==i){
                moveup_obj.css('display','none');
            }else{
                moveup_obj.css('display','inline-block');
            }
        }
        if(CrmPopup.findHtmlobj(popupobj.divid,movedown_name).length>0){
            var movedown_obj = CrmPopup.findHtmlobj(popupobj.divid,movedown_name);
            if(maxindex==i){
                movedown_obj.css('display','none');
            }else{
                movedown_obj.css('display','inline-block');
            }
        }
    }
}

//原来的提示框用不了，新加一个
AdvanceRelation.audioRemindsMsg_advance=function(headtitle,cssWidth,module,OkText,CancelText,ContentText){
    if(ContentText == '') ContentText=arrJsPopLabel['PLEASESELECTONEENTITY'];//内容
    var content = '<div id="audioCloseConfirm" class="pop_remind_content showError">'
        +'<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">'
        +'<div class="msgDlg_left">'
        +'<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>'
        +'</div>'
        +'<div class="msgDlg_right">'
        +'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+ContentText
        +'</div>'
        +'</div>'
        +'</div>'
        +'</div>';
    var popupobj=CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid).append(content);
    //1秒后，自动关闭提示弹出层
    setTimeout(function(){
        ld("#audioCloseConfirm").remove();
        return false;
    }, 1000);
}
//启用对应任务类型，set代表是否需要触发setAdvancetask函数
AdvanceRelation.enabletask = function(obj,set='yes'){
    var checkedobj = ld(obj);
    var trobj = checkedobj.parents('tr:first')
    var tasktype = trobj.attr('tasktype');
    tasktype = empty(tasktype)?ld(obj).attr('tasktype'):tasktype;
    var popupobj = CrmPopup.getPopupObj('last');
    var prevpopupobj = CrmPopup.getPopupObj('lastprev');
    var divid="dv_advance_content";
    if(checkedobj.prop('checked') && set == 'yes'){
        var frommodule = prevpopupobj.module;
        //var frommodule = CrmPopup.findHtmlobj(divid,'frommodule').val();
        var stagenum = checkedobj.attr('stagenum');
        if(empty(popupobj.TaskInfoArr[tasktype][stagenum-1])){// BUG20240712-27 启用之前配置好的推进任务，不需要进入“推进任务”弹窗
            AdvanceRelation.setAdvancetask(frommodule,stagenum,tasktype,'edit');
        }
    }
    // if(tasktype == 'field'){
    //     trobj.find(" [name=completerequest]").prop('checked',checkedobj.prop('checked'));
    // }
}
// 新增任务
AdvanceRelation.createTask = function(){
    var popupobj = CrmPopup.getPopupObj('last');
    var frommodule = popupobj.module;
    var tabelobj = ld("#"+popupobj.divid).find('table#AdvanceTaskTable');
    // var trobjs = tabelobj.find('tr');
    var tasktype_arr = {'field' : arrJsPopLabel['FieldTasks'],
                        'module' : arrJsPopLabel['CreateRecord'],
                        'select' : arrJsPopLabel['SelectType']+'('+arrJsPopLabel['PickList']+')',
                        'checkbox' : arrJsPopLabel['TickSelection']+'('+arrJsPopLabel['CheckBox']+')',
                        'validata' : arrJsPopLabel['CHECKVALIDATARULESJS'],
    };
    // 获取最大trindex
    var max_index = 0;
    var trobjs = tabelobj.find('tr');
    if(trobjs.length > 1){// 只有一行代表是表头
        trobjs.each(function() {
            var cur_index = parseInt(ld(this).attr('trindex')); // 获取当前tr的index属性值并转换为整数
            if (!isNaN(cur_index) && cur_index > max_index) { // 检查是否为有效数字且比当前最大值大
                max_index = cur_index; // 更新最大值
            }
        });
    }
    var trindex = max_index + 1;
    var trhtml = '<tr class="ld-category-draggable" tasktype="field" trindex="'+trindex+'" style="border-bottom: 1px solid #F1F1F1;">'
                    +'<td align="left" style="border-bottom: 1px solid #F1F1F1;">'
                        +'<select id="selecttasktype" name="selecttasktype_'+trindex+'" class="ld-select-inner" style="height: 30px;" onchange="AdvanceRelation.changeTasktype(this)">';
    ld.each(tasktype_arr, function(type, label) {
        trhtml += '<option value="'+type+'">'+label+'</option>';
    });
    trhtml += '</select></td>';

    trhtml += '<td style="overflow: inherit;border-bottom: 1px solid #F1F1F1;">'
                +'<div name="div_content_'+trindex+'">'
                    +`<input readonly="readonly" class="advanceTextBox gwidth85 bgwhite ld-input-inner" id="setAdvancetask" onclick="AdvanceRelation.setAdvancetask('`+frommodule+`',`+trindex+`,'field','create')" type="text" style="cursor: pointer" value=""/>`
    trhtml += '</div>'
            +'</td>'
    // 是否启用
    trhtml += '<td style="border-bottom: 1px solid #F1F1F1;">'
                +'<input type="checkbox" stagenum="'+trindex+'" name="presence" onclick="AdvanceRelation.enabletask(this)" class="second_switch"/>'  
            +'</td>';
    // 是否必做
    trhtml += '<td style="border-bottom: 1px solid #F1F1F1;">'
                +'<input type="checkbox" stagenum="'+trindex+'" name="completerequest" class="second_switch"/>'
            +'</td>';
    // 操作列
    trhtml += '<td style="border-bottom: 1px solid #F1F1F1;">'
                +`<a class="ld-category-icon ld-category-edit tip-items-list" name="setAdvancetask" href="javascript:void(0);" style="white-space:nowrap;margin-left:8px;" data-tip="`+arrJsPopLabel['EDIT']+`"></a>`
                +`<a class="ld-category-icon ld-category-del tip-items-list" href="javascript:void(0);" onclick="AdvanceRelation.deleteTask(this)" style="white-space:nowrap;margin-left: 10px;" data-tip="`+arrJsPopLabel['DELETE']+`"></a>`
                +`<a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;margin-left: 10px;" data-tip="`+arrJsPopLabel['drag']+`" data-direction="right"></a>`
            +'</td>';
    trhtml += '</tr>';
    tabelobj.append(trhtml);
    tabelobj.find('tr[trindex='+trindex+']').find('[name=setAdvancetask]').unbind('click').on('click', function (event) {
        AdvanceRelation.setAdvancetask(frommodule,trindex,'field','create')
    })
    AdvanceRelation.dragMoveTask();// 拖动排序

}
// 改变新增的任务类型
AdvanceRelation.changeTasktype = function(obj){
    var popupobj = CrmPopup.getPopupObj('last');
    var frommodule = popupobj.module;
    var tasktype = ld(obj).val();
    var trobj = ld(obj).parents('tr:first');
    var trindex = trobj.attr('trindex');

    trobj.attr('tasktype',tasktype);
    trobj.find('[name=div_content_'+trindex+']').html('<input readonly="readonly" onclick="AdvanceRelation.setAdvancetask(\''+frommodule+'\',\''+trindex+'\',\''+tasktype+'\',\'create\')" class="advanceTextBox gwidth85 bgwhite ld-input-inner" id="setAdvancetask" type="text" style="cursor: pointer" value=""/>');
    trobj.find('[name=setAdvancetask]').unbind('click').on('click', function (event) {
        AdvanceRelation.setAdvancetask(frommodule,trindex,tasktype,'create');
    })
    if(tasktype == 'validata'){
        trobj.find('[name=completerequest]').hide();
    }else{
        trobj.find('[name=completerequest]').show();
    }

    AdvanceRelation.setAdvancetask(frommodule,trindex,tasktype,'create');
}
// 删除任务
AdvanceRelation.deleteTask = function(obj){
    var popupobj = CrmPopup.getPopupObj('last');
    var frommodule = popupobj.module;
    var trobj = ld(obj).parents('tr:first');
    var tasktype = trobj.attr('tasktype');
    var issaved = trobj.attr('saved');
    var trindex = trobj.attr('trindex');

    MessagePopup.TipTwo_warning(arrJsPopLabel['COMFIRMTODELETE']);
    var msgpopupobj = CrmPopup.getPopupObj('last');
    ld("#" + msgpopupobj.divid).find("input[tagclick='msgConfirm']").unbind("click").bind("click", function () {
        trobj.remove();
        delete popupobj.TaskInfoArr[tasktype][trindex-1];
    });

}
// 拖动排序任务
AdvanceRelation.dragMoveTask = function(){
    var popupobj = CrmPopup.getPopupObj('last');
    var frommodule = popupobj.module;

    var dragobj = ld("#" + popupobj.divid).find("table#AdvanceTaskTable").find("tbody").get(0);
    Sortable.create(dragobj, {
        draggable:".ld-category-draggable",
        handle:".drag-handle",
        onStart: function (evt){

        },
        onEnd: function (evt){

        }
    });
}