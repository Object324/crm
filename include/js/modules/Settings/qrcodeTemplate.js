function qrcodeTemplate(){
    var that = this;
    this.ue = '';
}
//创建
qrcodeTemplate.create = function(fieldid,obj,selectedModule){
    var cur_module = ld('#cfList input[name="fld_module"]').val();
    var templateid = ld(obj).attr('data-templateid');
    var mode = 'create';
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=createQrCodeTemplate&cur_module='+cur_module;
    if(fieldid > 0){
        surl += '&fieldid='+fieldid;
        mode = 'edit';
    }
    if(templateid > 0){
        surl += '&qrcodetemplateid='+templateid;
        mode = 'edit';
    }
    surl += '&selectedModule='+selectedModule;
    surl += '&mode='+mode;
    var crmPopupobj = CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,qrcodeTemplate.save,"","LdPopWidth1100px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            qrcodeTemplate.ue = UE.getEditor('CKTemplatePrint');
            window.setTimeout(function(){
                var id = ld('#CKTemplatePrint').children("div:first-child").attr("id");
                ld('#'+id).css('z-index','99999');
                crmPopupobj.center();
            },400);
            if(!fieldid > 0){//xxy 2023-12-6 新建字段时，设置内容定制，因为没有fieldid所以保存在表后，再次点击设置不会返回内容，所以保存时临时将内容存在popupobj中，然后读取
                var prepopupobj = CrmPopup.getPopupObj("lastprev");
                if(prepopupobj.CKTemplatePrint){
                    qrcodeTemplate.ue.ready(function() {
                        qrcodeTemplate.ue.execCommand('inserthtml',prepopupobj.CKTemplatePrint);
                    },2);
                }
            }
            //字段
            qrcodeTemplate.moduleSel(ld('#qrcodeTemplateModuleSel')[0]);
            ld("#divPrint a").click(function(){
                var tag = ld(this).attr('tag');
                var tagArr = tag.split('_');
                var tagId = tagArr[1];
                for(var i=1;i<=12;i++){
                    ld("#divPrint"+i).hide();
                    ld("#divPrint"+i+"_1").hide();
                }
                ld("#divPrint"+tagId).show();
                ld("#divPrint"+tagId+"_1").show();
                if(tagId == 4){
                    ld("#divPrint5").show();
                    ld("#divPrint5_1").show();
                }
            });
        }
    })
}
//保存
qrcodeTemplate.save = function(){
    var param = {};
    param.CKTemplatePrint = qrcodeTemplate.ue.getContent();
    param.fieldid = ld('#fieldid').val();
    param.qrcodetemplateid = ld('#qrcodetemplateid').val();
    param.replacespacevalue = ld('#replacespacevalue').val();
    if(param.CKTemplatePrint==''||param.CKTemplatePrint==undefined){
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",'模板内容不能为空！');
        return false;
    }
    var popupobj = CrmPopup.getPopupObj("last");
    ld('#rptContentLoading').show();
    ld.ajax({
        url:'index.php?module=Settings&action=SettingsAjax&file=qrcodeTemplateSave',
        data:param,
        success:function(e){
            e = eval('(' + e + ')');
            ld('#qrcodetemplateid').val(e.result.qrcodetemplateid);
            ld('#qrcodeTemplateCreate').attr('data-templateid',e.result.qrcodetemplateid);
            ld('#qrcodeTemplateEdit').attr('data-templateid',e.result.qrcodetemplateid);
            popupobj.CancelEvent();
            ld('#rptContentLoading').hide();
            DelProgressObjs();
            popupobj = CrmPopup.getPopupObj("last");
            popupobj.CKTemplatePrint = param.CKTemplatePrint;
        }
    });
    return false;
}

//取消确认
qrcodeTemplate.cancelTemplateprint = function(){
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.CancelEvent();
}

/*
edit:can
date:20130814
reason:新增和编辑模板中选择模块事件
*/

qrcodeTemplate.moduleSel=function(obj)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var printtabid = ld("#"+popupobj.divid+" [name=printtabid]").val();
    var urlstring = '&tabid='+printtabid+'&printtabid='+obj.value;
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField'+urlstring;
    ldAjax(surl,"",function(data){
        if(data.code == 1){
            ld("#"+popupobj.divid+" [name=tabField]").html(data.result.fieldsel);
        }
        DelProgressObjs();
    })
}

//选择模块字段事件
var fieldSel = function(obj)
{
    var popupobj=CrmPopup.getPopupObj("last");
    ld("#"+popupobj.divid+" [name=selField]").val("[var."+obj.value+"]");
}

//打印模板中插入模板
qrcodeTemplate.InsertTemplate = function(obj)
{
    var popupobj=CrmPopup.getPopupObj("last");
    if(trim(ld("#"+popupobj.divid+" [name=selField]").val())==""){
        //请选择字段！
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }
    var selField = ld("#"+popupobj.divid+" [name=selField]").val();
    qrcodeTemplate.ue.ready(function() {
        qrcodeTemplate.ue.focus();
        qrcodeTemplate.ue.execCommand('inserthtml',selField);
        //	qrcodeTemplate.ue.setContent(selField,true);
    },2);
}

//导入excel文件到打印模板中
qrcodeTemplate.ImportTemplate = function(obj){
    fnvshobj('','InportExcelDiv');
    ld('#InportExcelDiv div.D_pbtn .D_pbtnok').unbind('click');//每次点击导入打印模板按钮时解除掉按钮（确定按钮）上面的所有绑定事件；
    ld('#InportExcelDiv div.D_pbtn .D_pbtnok').on('click',function(){
        if(!empty(ld('#upload_file_name').html())){
            var urlstring = 'module=Settings&action=SettingsAjax&file=UploadExcel';
            urlstring += '&file_path='+ld('#upload_file_name').attr('path')+'';
            urlstring += '&file_name='+ld('#upload_file_name').attr('file')+'';
            urlstring += '&ajax=true&setype=excel';
            RequestAjax(urlstring,function(rest){
                if('' == rest) return false;
                //ue.execCommand('insertHtml',rest);
                ue.setContent(rest);
                DelProgressObjs();
                ld('#InportExcelDiv div.D_pbtn .D_pbtncancel').click();
            });
        }
        else{
            var confirm_str = arrJsPopLabel['PLEASESELECTAFILE'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        }
    });
    ld('#InportExcelDiv div.E_pop_tit .E_ptitc').on('click',function(){
        ld('#InportExcelDiv div.D_pbtn .D_pbtncancel').click();
        return false;
    });
    ld('#InportExcelDiv div.D_pbtn .D_pbtncancel').on('click',function(){
        fninvshnew('InportExcelDiv');puyoungJS_DialogBox.unblock();
        // unsetUnloadExcel();
    });
}
//表单码编辑字段弹出层
qrcodeTemplate.Formcreate = function(fieldid,obj,module){
    var templateid = ld(obj).attr('data-templateid');
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=FormcodeSet';
    surl +='&fieldid='+fieldid+'&frommodule='+module+'&mode=edit&templateid='+templateid;
    var crmPopupobj = CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjax(surl,"",function(data){
        DelProgressObjs();
        if(data.code == 1){
            crmPopupobj.setParams(data.result.title,qrcodeTemplate.Formsave,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            crmPopupobj.templateid = templateid;
            //判断永久有效选项是否可以显示
            qrcodeTemplate.permanently_judge();
            qrcodeTemplate.reset_allselected(crmPopupobj.divid);
        }
    })
}
//保存表单码设置
qrcodeTemplate.Formsave = function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var prevpopupobj = CrmPopup.getPopupObj("lastprev");
    var divid = popupobj.divid;
    var tagname_arr = {'view':'checkbox_view','input':'checkbox_input','edit':'checkbox_edit','approve':'checkbox_approve','require':'checkbox_require'};
    var tmp_tag = "";
    var detail_tmp_tag = "";
    var tmp_tagname = "";
    var detail_tmp_tagname = "";
    //保存所有字段设置
    var tableobj = ld("#"+divid+" table[name=formcode_fieldinfo]");
    var trobjs = ld(tableobj).find("tr[name=fieldinfo]");
    var detailedtrobjs=ld(tableobj).find("tr[name=detail_fieldinfo]");;
    var fieldid = 0;
    var detail_fieldid = 0;
    var labelnotempty = true;
    var detailedlabelnotempty = true;
    var tmp_fieldlabel = "";
    var tmp_detail_fieldlabel = "";
    var param = {};
    var tmp_param = {};
    var detail_tmp_param = {};
    var fieldinfo_param = {};
    var detail_fieldinfo_param = {};
    var num_permit = 0;
    ld.each(trobjs,function(){
        tmp_param = {};
        if(ld(this).find("[name=fieldid]") != undefined && ld(this).find("[name=fieldid]").val()>0){
            fieldid = ld(this).find("[name=fieldid]").val();
            tmp_fieldlabel = ld("#"+divid+" input[name=fieldlabel_label_"+fieldid+"]").val();
            if(empty(tmp_fieldlabel)||tmp_fieldlabel==""){
                labelnotempty = false;
                ld("#"+divid+" input[name=fieldlabel_label_"+fieldid+"]").focus();
                return false;
            }
            if(labelnotempty){
                tmp_param['label'] = ld("#"+divid+" input[name=fieldlabel_label_"+fieldid+"]").val();
                for(tmp_tag in tagname_arr){
                    tmp_tagname = tagname_arr[tmp_tag];
                    if(ld("#"+divid+" input[name="+tmp_tagname+"_"+fieldid+"]").is(':checked')){
                        tmp_param[tmp_tag] = "yes";
                        num_permit++;
                    }else{
                        tmp_param[tmp_tag] = "no";
                    }
                }
                fieldinfo_param[fieldid] = tmp_param;
            }
        }
    });
    //分录字段的保存
    ld.each(detailedtrobjs,function(){
        detail_tmp_param = {};
        if(ld(this).find("[name=detail_fieldid]") != undefined && ld(this).find("[name=detail_fieldid]").val()>0){
            detail_fieldid = ld(this).find("[name=detail_fieldid]").val();
            var tmp_detail_fieldlabel = ld("#"+divid+" input[name=fieldlabel_label_"+detail_fieldid+"]").val();
            if(empty(tmp_detail_fieldlabel)||tmp_detail_fieldlabel==""){
                detailedlabelnotempty = false;
                ld("#"+divid+" input[name=fieldlabel_label_"+detail_fieldid+"]").focus();
                return false;
            }
            if(detailedlabelnotempty){
                detail_tmp_param['label'] = ld("#"+divid+" input[name=fieldlabel_label_"+detail_fieldid+"]").val();
                for(detail_tmp_tag in tagname_arr){
                    detail_tmp_tagname = tagname_arr[detail_tmp_tag];
                    if(ld("#"+divid+" input[name="+detail_tmp_tagname+"_"+detail_fieldid+"]").is(':checked')){
                        detail_tmp_param[detail_tmp_tag] = "yes";
                        num_permit++;
                    }else{
                        detail_tmp_param[detail_tmp_tag] = "no";
                    }
                }
                detail_fieldinfo_param[detail_fieldid] = detail_tmp_param;
            }
        }
    });

    if(!labelnotempty){
        var confirmstr = arrJsPopLabel['FORMCODENOTEMPTY'];
        audioRemindsMsg("","LdPopWidth400px",'',"yes","yes",confirmstr);
        return false;
    }
    //至少设置一个可查看字段
    if(num_permit == 0){
        var confirmstr = arrJsPopLabel['LEASTONEFIELD'];
        audioRemindsMsg("","LdPopWidth400px",'',"yes","yes",confirmstr);
        return false;
    }
    
    
    var url = 'index.php?module=Settings&action=SettingsAjax&file=FormcodeSet';
    param['mode'] = 'save';
    param['fieldinfo'] = fieldinfo_param;
    param['detail_fieldinfo'] = detail_fieldinfo_param;
    
    //访问人数
    var humanlimit;
    var wrong_humanlimit = 'no';
    ld.each(ld("#"+divid+" input[typeofradio=humanlimit]"),function(){
        if(ld(this).is(':checked')){
            if(ld(this).attr('name')=='nolimit'){
                param['limit'] = 'nolimit';
            }else if(ld(this).attr('name')=='viewnum'){
                humanlimit = !empty(popupobj.humanlimit)?popupobj.humanlimit:ld("#"+divid+" input[name=humanlimit]").val();
                var reg = /[1-9]+\d*/;
                if(reg.test(humanlimit)&&humanlimit>0){
                    param['limit'] = humanlimit;
                }else{
                    wrong_humanlimit = 'yes';
                }
            }
        }
    })
    if(wrong_humanlimit == 'yes'){
        var confirmstr = arrJsPopLabel['ENTERCORRECTNUMBER'];
        MessagePopup.TipZero_warning(confirmstr);
        return false;
    }
    //有效时间
    var duration;
    var wrong_date = '';
    ld.each(ld("#"+divid+" input[typeofradio=duration]"),function(){
        if(ld(this).is(':checked')){
            if(ld(this).attr('tag')=='endate'){
                var endate_str = ld("#"+divid+" input[name=endatetime]").val();
                var endateobj = new Date(endate_str);
                var datenowobj = new Date();
                if(endate_str =='' || endate_str == undefined){//时间不能为空
                    var confirmstr = arrJsPopLabel['pleaseselectdate'];
                    audioRemindsMsg("","LdPopWidth400px",'',"yes","yes",confirmstr);
                    wrong_date = 'yes';
                    return false;
                }else if(datenowobj.getTime()>endateobj.getTime()){//选择日期不能小于当前日期
                    var confirmstr = arrJsPopLabel['DEADLINECANNOTEAILER'];
                    audioRemindsMsg("","LdPopWidth400px",'',"yes","yes",confirmstr);
                    wrong_date = 'yes';
                    return false;
                }
                //20230601 duan BUG0067405:去掉表单码有效期限制
                //限制最长有效期30天
                /*
                var limit_dateobj = new Date();
                limit_dateobj.setDate(datenowobj.getDate()+30)
                if(endateobj.getTime()>limit_dateobj.getTime()){
                    var confirmstr = arrJsPopLabel['DEADLINECANNOTEXCEED'];
                    audioRemindsMsg("","LdPopWidth400px",'',"yes","yes",confirmstr);
                    wrong_date = 'yes';
                    return false;
                }
                */
                param['endatetime'] = endate_str;
            }
            param['duration'] = ld(this).attr('tag');
        }
    })
    //错误日期停止保存
    if(wrong_date == 'yes'){
        return false;
    }
    
    
    if(popupobj.templateid>0){
        param['templateid'] = popupobj.templateid;
    }
    
    ldAjax(url,param,function(data){
        DelProgressObjs();
        if(data.code == 1){
            //ld('#qrcodetemplateid').val(data.result.qrcodetemplateid);
            ld('#'+prevpopupobj.divid+' [id=formqrcodeTemplateCreate]').attr('data-templateid',data.result.qrcodetemplateid);
            ld('#'+prevpopupobj.divid+' [id=formqrcodeTemplateEdit]').attr('data-templateid',data.result.qrcodetemplateid);
            popupobj.CancelEvent();
            ld('#'+prevpopupobj.divid+' [name=resetformcode]').click();
        }
    });
    
    
}
//还原已修改的字段名称
qrcodeTemplate.fieldllabel_turnback = function(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var from_span = ld(obj).attr('fromspan');
    var to_input = ld(obj).attr('toinput');
    var detail_from_span = "detail_fieldlabel_";
    var tableobj = ld("#"+divid+" table[name=formcode_fieldinfo]");
    var trobjs = ld(tableobj).find("tr[name=fieldinfo]");
    var detail_trobjs=ld(tableobj).find("tr[name=detail_fieldinfo]");
    var fieldid = 0;
    var detail_fieldid = 0;
    ld.each(trobjs,function(){
        if(ld(this).find("[name=fieldid]") != undefined && ld(this).find("[name=fieldid]").val()>0){
            fieldid = ld(this).find("[name=fieldid]").val();
            ld("#"+divid+" input[name="+to_input+fieldid+"]").val(ld("#"+divid+" span[name="+from_span+fieldid+"]").text());
        }
    });
    //分录字段名称的一键还原
    ld.each(detail_trobjs,function(){
        if(ld(this).find("[name=detail_fieldid]") != undefined && ld(this).find("[name=detail_fieldid]").val()>0){
            detail_fieldid = ld(this).find("[name=detail_fieldid]").val();
            ld("#"+divid+" input[name="+to_input+detail_fieldid+"]").val(ld("#"+divid+" span[name="+detail_from_span+detail_fieldid+"]").text());
        }
    });
}
//第一列全选操作按钮
qrcodeTemplate.allfield_checkbox = function(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var tableobj = ld("#"+divid+" table[name=formcode_fieldinfo]");
    var trobjs = ld(tableobj).find("tr[name=fieldinfo]");
    var tagname = ld(obj).attr('name');
    var fieldid = 0;
    var checked = ld(obj).is(":checked");
    
    ld("#"+divid+" input[name*="+tagname+"]").prop('checked',checked);
    //增加选项之间的级联关系
    switch(tagname){
        case 'checkbox_view':
            if(!checked){
                ld("#"+divid+" input[name*=checkbox]").prop('checked',checked);
            }
            break;
        case 'checkbox_input':
            if(!checked){
                ld("#"+divid+" input[name*=checkbox_edit]").prop('checked',checked);
                ld("#"+divid+" input[name*=checkbox_approve]").prop('checked',checked);
                ld("#"+divid+" input[name*=checkbox_require]").prop('checked',checked);
            }else{
                ld("#"+divid+" input[name*=checkbox_view]").prop('checked',checked);
            }
            break;
        case 'checkbox_edit':
        case 'checkbox_approve':
        case 'checkbox_require':
        if(!checked){
        }else{
            ld("#"+divid+" input[name*=checkbox_input]").prop('checked',checked);
            ld("#"+divid+" input[name*=checkbox_view]").prop('checked',checked);
        }
        break;
        default:break;
    }
    //判断永久有效选项是否显示
    qrcodeTemplate.permanently_judge();
}
//每一行单选按钮
qrcodeTemplate.field_checkbox = function(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var fieldid = ld(obj).attr('fieldid');
    var checked = ld(obj).is(":checked");
    var tagname = ld(obj).attr('tag');
    //设置按钮之间的级联关系
    switch(tagname){
        case 'checkbox_view':
            if(!checked){
                ld("#"+divid+" input[name=checkbox_input_"+fieldid+"]").prop('checked',checked);
                ld("#"+divid+" input[name=checkbox_edit_"+fieldid+"]").prop('checked',checked);
                ld("#"+divid+" input[name=checkbox_approve_"+fieldid+"]").prop('checked',checked);
                ld("#"+divid+" input[name=checkbox_require_"+fieldid+"]").prop('checked',checked);
            }
            break;
        case 'checkbox_input':
            if(!checked){
                ld("#"+divid+" input[name=checkbox_edit_"+fieldid+"]").prop('checked',checked);
                ld("#"+divid+" input[name=checkbox_approve_"+fieldid+"]").prop('checked',checked);
                ld("#"+divid+" input[name=checkbox_require_"+fieldid+"]").prop('checked',checked);
            }else{
                ld("#"+divid+" input[name=checkbox_view_"+fieldid+"]").prop('checked',checked);
            }
            break;
        case 'checkbox_edit':
        case 'checkbox_approve':
        case 'checkbox_require':
        if(!checked){
        }else{
            ld("#"+divid+" input[name=checkbox_input_"+fieldid+"]").prop('checked',checked);
            ld("#"+divid+" input[name=checkbox_view_"+fieldid+"]").prop('checked',checked);
        }
        break;
        default:break;
    }
    qrcodeTemplate.reset_allselected(divid);
    //判断永久有效选项是否显示
    qrcodeTemplate.permanently_judge();
}

//重新判断按钮的全选状态
qrcodeTemplate.reset_allselected = function(divid){
    var tagname_arr = {'view':'checkbox_view','input':'checkbox_input','edit':'checkbox_edit','approve':'checkbox_approve','require':'checkbox_require'};
    var tmp_tag = "";
    var tmp_tagname = "";
    var all_checked = true;
    for(tmp_tag in tagname_arr){
        tmp_tagname = tagname_arr[tmp_tag];
        ld.each(ld("#"+divid+" input[name*="+tmp_tagname+"_]"),function(){
            if(ld(this).is(':checked')){
            }else{
                all_checked = false;
            }
        })
        ld("#"+divid+" input[name="+tmp_tagname+"]").prop('checked',all_checked);
        all_checked = true;
    }
}

//选择限制人数和有效时间
qrcodeTemplate.limit_checkbox = function(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var typeofradio = ld(obj).attr('typeofradio');
    var checked = ld(obj).is(':checked');
    ld("#"+divid+" input[typeofradio="+typeofradio+"]").prop('checked',false);
    ld(obj).prop('checked',true);
}

//限制只选中查看权限时，可以勾选永久有效
qrcodeTemplate.permanently_judge = function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var tagname_arr = {'input':'checkbox_input','edit':'checkbox_edit','approve':'checkbox_approve','require':'checkbox_require'};
    var tmp_tag = "";
    var tmp_tagname = "";
    var find_checked = false;
    //判断永久有效按钮是否允许显示
    for(tmp_tag in tagname_arr){
        tmp_tagname = tagname_arr[tmp_tag];
        ld.each(ld("#"+divid+" input[name*="+tmp_tagname+"_]"),function(){
            if(ld(this).is(':checked')){
                find_checked = true;
                return false;
            }
        })
        if(find_checked){
            break;
        }
    }
    
    if(find_checked){
        ld("#"+divid+" input[name=permanently]").hide();
        ld("#"+divid+" span[name=permanently_span]").hide();
        //永久有效按钮隐藏后,取消选中
        if(ld("#"+divid+" input[name=permanently]").is(':checked')){
            ld("#"+divid+" input[name=permanently]").prop('checked',false);
            ld("#"+divid+" input[name=duration_1]").prop('checked',true);
        }
    }else{
        ld("#"+divid+" input[name=permanently]").show();
        ld("#"+divid+" span[name=permanently_span]").show();
    }
}

//判断输入的数字是否正确
qrcodeTemplate.quantity_change = function(obj){
    var reg = /[1-9]+\d*/;
    var num = ld(obj).val();
    if(reg.test(num)&&num>0){
        ld(obj).val(Math.ceil(num));
    }else{
        var confirmstr = arrJsPopLabel['ENTERCORRECTNUMBER'];
        audioRemindsMsg("","LdPopWidth400px",'',"yes","yes",confirmstr);
        ld(obj).val(10);
    }
}

// 将设置的人数用onkeyup监听放在popupobj上，防止输入框在没失焦时点击保存获取不到新输入的值
qrcodeTemplate.quantity_onkeyup = function(obj){
    var num = ld(obj).val();
    var popupobj = CrmPopup.getPopupObj("last");
    popupobj.humanlimit = num;
}