 //打印弹出层
function PrintPopup()
{
    var that = this;
    var parentshow = this.show;
    this.show = function (htmlcontent, result, PrintSettingCategoriesArr) {
        var printname = result.printname;
        var chooseoperatename = result.chooseoperatename;
        var exportname = result.exportname;
        var emailname = result.emailname;
        var print = result.print;
        var email_status = result.email_status;
        var openofficeStatus = result.openofficeStatus;

        var module = this.module;
        var templatetype = '';// 模板类型 Word,Excel或空
        var havedefault = 'no';
        ld.each(htmlcontent, function (key, text) {
            if (text[1] == 1) {
                templatetype = text[3];
                havedefault = 'yes';
            }
        });
        if(havedefault == 'no'){
            templatetype = htmlcontent[0][3];// 没有默认模板时取第一个模板的类型
        }
        var div_text = '<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">'
            + '<tr>'
            + '<td class="ld-form-item-label">' + '<span class="valign-middle lineheight20">' + printname + '</span>';
        if(openofficeStatus == 'no' && !empty(templatetype)){// 导出成pdf格式，若要与模板显示样式一致，需在服务器上安装openoffice插件
            div_text += '<i id="openoffice_tips" style="" data-status="hidden"'
                +'data-tip="'+arrJsPopLabel['ExportToPDFNeedInstallOpenOffice']+'" data-direction="top" data-type="position" data-tiptype="remain"'
                +'class="ld-fonticon ld-fonticon-helpnohover valign-middle lineheight18 tip-items-pop">'
                +'</i>';
        }
        div_text += '</td>';
        div_text += '<td class="ld-form-item-content">'
            + '<select name="print_select" id="print_select" class="commonSelectPop" style="width:70%;" onchange="PrintPopup.changeTemplate(this)">';
        ld.each(htmlcontent, function (key, text) {
            if (text[1] == 1) {
                div_text += "<option value='" + text[2] + "' type='"+text[3]+"' selected>" + text[0] + "</option>";
            }
            else {
                div_text += "<option value='" + text[2] + "' type='"+text[3]+"'>" + text[0] + "</option>";
            }
        });

        var ToPrintstyle = '';
        var ToDOCstyle = '';
        var ToPDFstyle = '';
        var ToExcelstyle = '';
        var ToEmailDocstyle = '';
        var ToEmailPdfstyle = '';
        var ToEmailExcelstyle = '';
        //zkt 20241017 BUG20241016-16 收款单、租赁合同模块，新建单据保存会一直卡住，如视频
        if(result&&result.is_admin!=undefined){
            var isadmin=result.is_admin=='yes'?1:0;
        }
        else if(document.getElementById('hdtxt_IsAdmin') == null){
            var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
            var isadmin=(popupobj!=undefined||popupobj.isadmin=='on'||popupobj.isadmin=='on')?1:0;
        }else {
            var isadmin=document.getElementById('hdtxt_IsAdmin').value;//判断是否为管理员
        }
        
        if (ld.inArray("toPrint", PrintSettingCategoriesArr) != -1) {
            ToPrintstyle = ' display:none; ';
        } if (ld.inArray("toDOC", PrintSettingCategoriesArr) != -1 || templatetype == 'Excel') {
            ToDOCstyle = ' display:none; ';
        } if (ld.inArray("toPDF", PrintSettingCategoriesArr) != -1) {
            ToPDFstyle = ' display:none; ';
        } if (ld.inArray("toEmailDoc", PrintSettingCategoriesArr) != -1 || templatetype == 'Excel') {
            ToEmailDocstyle = ' display:none; ';
        } if (ld.inArray("toEmailPdf", PrintSettingCategoriesArr) != -1) {
            ToEmailPdfstyle = ' display:none; ';
        }
        if (ld.inArray("toExcel", PrintSettingCategoriesArr) != -1 || templatetype != 'Excel') {
            ToExcelstyle = ' display:none; ';
        }
        if (ld.inArray("toEmailExcel", PrintSettingCategoriesArr) != -1 || templatetype != 'Excel') {
            ToEmailExcelstyle = ' display:none; ';
        }
        div_text += "</select>";

        div_text += '</td>'
            + '</tr>'
            + '<tr>'
            + '<td class="ld-form-item-label">'
        if(isadmin == 1){
            /*wym BUG0072154 打印设置弹窗中，点击“关闭”按钮要点击两次才能关闭弹窗*/
            div_text += '<span class="valign-middle lineheight20">'+chooseoperatename + '</span><i title="' + arrJsPopLabel['Configure'] + '" class="ld-fonticon ld-fonticon-set valign-middle lineheight18" style="" onclick="PrintPopup.printsetting(\'' + module + '\')"></i>';
        }
        div_text += '</td>'
        div_text += '<td class="ld-form-item-content">'
            + '<div class="" style="' + ToPrintstyle + '"><input type="radio" class="input-btn-align" id="toPrint" name="print_radio" value="toPrint" checked>&nbsp<label for="toPrint">' + print + '</label></div>'
            + '<div class="padT16" style="' + ToDOCstyle + '"><input type="radio" class="input-btn-align" id="toDOC" name="print_radio" value="toDOC">&nbsp<label for="toDOC">' + exportname + '</label></div>'
            + '<div class="padT16" style="' + ToPDFstyle + '"><input type="radio" class="input-btn-align" id="toPDF" name="print_radio" value="toPDF">&nbsp<label for="toPDF">' + arrJsPopLabel['exporttopdf1'] + '</label></div>'
            + '<div class="padT16" style="' + ToExcelstyle + '"><input type="radio" class="input-btn-align" id="toExcel" name="print_radio" value="toExcel">&nbsp<label for="toExcel">' + arrJsPopLabel['ExportToXLSFormat'] + '</label></div>';
        if (email_status == true) {
            div_text += '<div class="padT16" style="' + ToEmailDocstyle + '"><input type="radio" class="input-btn-align" id="toEmailDoc" name="print_radio" value="toEmailDoc">&nbsp<label for="toEmailDoc">' + arrJsPopLabel['Send_Email_Add_DOC'] + '</label></div>';
            div_text += '<div class="padT16" style="' + ToEmailPdfstyle + '"><input type="radio" class="input-btn-align" id="toEmailPdf" name="print_radio" value="toEmailPdf">&nbsp<label for="toEmailPdf">' + emailname + '</label></div>';
            div_text += '<div class="padT16" style="' + ToEmailExcelstyle + '"><input type="radio" class="input-btn-align" id="toEmailExcel" name="print_radio" value="toEmailExcel">&nbsp<label for="toEmailExcel">' + arrJsPopLabel['SendEmailAddXLS'] + '</label></div>';
        }
        div_text += '</td>'
            + '</tr>'
            + '</table>';
        parentshow.apply(this, [div_text]);

        var popupobj = CrmPopup.getPopupObj("last");
        popupobj.hideid_arr = PrintSettingCategoriesArr;

    }

}

PrintPopup.operate=function()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var printid=ld("#"+popupobj.divid+" [name=print_select]").val();
    var templatetype = ld("#"+popupobj.divid).find("[name=print_select]").find('option:selected').attr('type');// 模板类型
    var prepopupobj=CrmPopup.getPopupObj("lastprev");
    var record = prepopupobj.record;
    if(!empty(popupobj.record)){
        record = popupobj.record;
    }
	//alert(prepopupobj.record);
    //打印：判断打印模板是否設置已批准才允許打印   ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印(单据详情页)  BUG0055187 打印模板导出doc、pdf应该跟打印参数一致控制
    ld.ajax("index.php?action=UsersAjax&module=Users&file=getModuleApprovePrint&print_module="+popupobj.module+'&printid='+printid+"&record="+record)
        .done(function(results){
            if(results.indexOf('error') > -1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ApprovedAllowPrintRemind']);
                return false;
            }else{
                var checked_value = ld("#"+popupobj.divid+" input[name='print_radio']:checked").val();
                if(checked_value == 'toPrint')
                {
                    var urlstring = 'index.php?module=Settings&action=TemplatePrintHtml&tabname=' + popupobj.module + '&printid=' + printid + '&record=' + record;
                    
                    if(!empty(templatetype)){// XUQIU1000367 打印模板优化--新增Word和Excel打印模板--第一版（参考纷享）
                        if(templatetype == 'Word')
                            urlstring += '&CreateDOC=true';
                        else if(templatetype == 'Excel')
                            urlstring += '&CreateExcel=true';
                        
                        urlstring += '&mode=print';
                        urlstring += '&templatetype=' + templatetype;
                        ldAjaxNoProgress(urlstring, '', function (data) {
                            if(data.code == 1){
                                Pre_Attachment(data.result.fileobj);
                            }
                        });

                    }else{
                        // 防止反复添加
                        if(!document.getElementById("PrintPopup_operate_"+printid)) {
                            var a = document.createElement('a');
                            a.setAttribute('href', urlstring);
                            a.setAttribute('target', '_blank');
                            a.setAttribute('id', "PrintPopup_operate_"+printid);
                            document.body.appendChild(a);
                        }
                        else
                        {
                            var a=document.getElementById("PrintPopup_operate_"+printid);
                        }
                        //a.click();  safari浏览器下不起效果
                        //关闭弹出层 diony 2023-06-25
                        popupobj.CancelEvent();
                        //产品模块，自动增加打印次数 diony 2023-06-25
                        if(popupobj.module == 'Products'){
                            ld.each(prepopupobj.column_fields_value,function(columnname,valueinfo){
                                if(columnname=='print_times'){
                                    var print_times = ld('#dtlview_print_times').html();
                                    ld('#dtlview_print_times').html(parseInt(print_times)+1);
                                    ld('[name=print_times_name]').val(parseInt(print_times)+1);
                                }
                            })
                        }
                        OpenNewWebTab(urlstring);
                    }
                }
                else if(checked_value=='toDOC' || checked_value=='toPDF' || checked_value=='toExcel')
                {
                    PrintPopup.ConvertToFile(checked_value,popupobj.module,record);
                }
                else if(checked_value=='toEmailDoc' || checked_value=='toEmailPdf' ||  checked_value=='toEmailExcel'){

                    var sendemail_url = 'index.php?module='+popupobj.module+'&action='+module+'Ajax&file=SendPDFMail&printid='+printid+'&record='+record;
                    if(checked_value=='toEmailDoc')
                        sendemail_url += '&CreateDoc=true';
                    else if(checked_value=='toEmailPdf')
                        sendemail_url += '&CreatePdf=true';
                    else if(checked_value=='toEmailExcel')
                        sendemail_url += '&CreateExcel=true';

                    if(!empty(templatetype)){
                        sendemail_url += '&templatetype='+templatetype;
                    }

                    ldAjax(sendemail_url,{},function(data){
                        DelProgressObjs();
                        var page_addurl=encodeURIComponent("&printid="+data.result.printid+"&attachment="+data.result.attachment+"&fromid="+record);
                        var URL='index.php?pageto_module=Emails&pageto_action=EditView&page_addurl='+page_addurl;
                        window.open(URL);

                    })
                }
            }
        })

    
}
PrintPopup.operate.funname="PrintPopup.operate";

PrintPopup.ConvertToFile = function(type, module, recordid){
    var popupobj = CrmPopup.getPopupObj("last");

    var printid = ld("#" + popupobj.divid + " [name=print_select]").val();
    var templatetype = ld("#"+popupobj.divid).find("[name=print_select]").find('option:selected').attr('type');// 模板类型
    if (printid == 0) {
        //请选择打印模板！
        var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return false;
    }
    var urlstring = 'index.php?module=Settings&action=TemplatePrintHtml&tabname=' + module + '&printid=' + printid + '&record=' + recordid;
    if(type == 'toDOC')
        urlstring += '&CreateDOC=true';
    else if(type == 'toPDF')
        urlstring += '&CreatePDF=true';
    else if(type == 'toExcel')
        urlstring += '&CreateExcel=true';
    urlstring += '&templatetype=' + templatetype;
    // ldAjaxHtmlNoProgress(urlstring, '', function (data) {

    // });

    var alink = document.createElement('a');
    alink.style.display = 'none'
    alink.href = urlstring;
    alink.download = '';
    document.body.appendChild(alink)
    alink.click();
    URL.revokeObjectURL(alink.href) // 释放URL 对象
    document.body.removeChild(alink)
}

//新建保存合同订单后，若设置了：设置合同订单新增或编辑后是否立即打印。需要popupobj.record值为空，因此拆分为两个函数
PrintPopup.showpopup=function ()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var module=popupobj.module;
    var recordid = popupobj.record;
    //zkt 20230302 BUG0062049 	kfbcrm 客户查看页面---点击相关信息---例 收款单---然后点击右上角打印工具---弹出框是打印收款单---并且打印出错应该弹出打印客户模板 
    if(popupobj.type == 'relatelistpage'){
        module = popupobj.headermodule;
        recordid = popupobj.detailpage_record;
    }
    var param = {'module':module,'recordid':recordid};
     PrintPopup.showpopuphaveparam(param);
}
PrintPopup.showpopuphaveparam = function(param)
{
    var module = param.module;
    var recordid = param.recordid;
    ld.ajax({
        url: "index.php?module="+module+"&action="+module+'Ajax&file=getPrintInfo&module_recordid='+recordid,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            var PrintSettingCategoriesArr=data.result.PrintSettingCategoriesArr;

            ld('#rptContentLoading').hide();
            if(data.code==1)
            {
                var PrintPopupobj=PrintPopup.load(data.result.title,PrintPopup.operate,"","LdPopWidth600px",module,"",data.result.oktext,"",data.result.canceltext);

                PrintPopupobj.show(data.result.content,data.result,PrintSettingCategoriesArr);
                PrintPopupobj.record = recordid;
                // ljj 20230904 BUG0072070 kfbcrm-弹出层的× title改为tip
                tooltip(".tip-items-pop", {transition: true, time: 200});

                // ljj 20231031 BUG0074735 联系人模块，选择任意单据，点击相关信息栏中的“打印工具”，打印下拉框，模板名称显示过长
                var print_select=ld("#"+PrintPopupobj.divid+" #print_select");
                if(print_select.length>0&&print_select!=undefined) {
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(print_select.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(PrintPopupobj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(print_select, 422);//(450*0.8-10)*0.7=245
                }

                if(ld('#'+PrintPopupobj.divid).find('input[name=print_radio]:visible').length == 1){
                    ld('#'+PrintPopupobj.divid).find('input[name=print_radio]:visible').prop('checked',true);
                }
            }
            else 
            {
                 // var div_text = '<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">'
                 //     +'<div class="msgDlg">'
                 //     +'<div class="msgDlg_right">'
                 //     +'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+data.msg
                 //     +'</div>'
                 //     +'</div>'
                 //     +'</div>'
                 //     +'</div>';
                 //
            		// var divobj = createElementDivs('friendlyreminder');
                 //    var title = arrJsPopLabel['WARMPROMPT'];
            		// ld(divobj).find('.E_pop_tit .E_ptita').html(title);
            		// ld('#friendlyremindercontent').html(div_text);
            		// ld(divobj).css('max-height','500px');
                 //    ld(divobj).css('width','400px');
                 //    ld(divobj).css('background','#FDFDFD');
            		// ld('#friendlyremindercontent').css('max-height','400px');
            		// ld('#friendlyremindercontent').css('border','none');
                 //    ld(divobj).find('div.D_pbtn').addClass('ww_dialog_foot');
                 //    // ld(divobj).find('span').remove();
                 //    // ld(divobj).find('.D_pbtncancel').remove();
                 //    ld(divobj).find('div.E_pop_tit a').attr("onclick","fninvshnew('friendlyreminder');return false;");
                 //    ld(divobj).find('div.E_pbtn .E_pbtnok').attr("onclick","fninvshnew('friendlyreminder');return false;");
                 //    fnvshobj(this,'friendlyreminder');
                 // BUG0072902 txy 20230928 kfbcrm-工单管理-打印模板-没有模板时的提示信息样式修改
                 var title = arrJsPopLabel['HAVENOPRINTTEMPLATE'];
                 MessagePopup.TipTwo_warning(title);
                
            }
        }
    });
}

PrintPopup.type="print";


PrintPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText)
{
     PrintPopup.prototype=new CrmPopup();  
     PrintPopup.prototype.constructor=ComboxPopup;  

     
     PrintPopup.prototype.type=PrintPopup.type;
     PrintPopup.prototype.module=module;
 
     var  PrintPopupobj=new PrintPopup();
     PrintPopupobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    
     return PrintPopupobj;
}
//lmq 230626 设置打印操作弹出层
PrintPopup.printsetting = function (frommodule){
    var Popupobj=CrmPopup.load("","","","LdPopWidth600px",'Home',"","","","");

    Popupobj.prevshow();

    var surl = 'index.php?module=Settings&action=SettingsAjax&file=PrintSettings&printset=showpage&frommodule='+frommodule;
    ldAjax(surl,{},function(data){
        DelProgressObjs();
        Popupobj.setParams(data.result.title,"","","LdPopWidth600px","Home","","","","","");
         // var email_status=data.result.email_status;
         //
         // if(email_status == true){
         //    ld("#"+popupobj.divid+" [value="+ToEmailDoc+']').parent().hide();
         //    ld("#"+popupobj.divid+" [value="+ToEmailPdf+']').parent().hide();
         //  }
         //else{
             //ld("#"+popupobj.divid+" [value="+ToEmailDoc+']').parent().hide();
             //ld("#"+popupobj.divid+" [value="+ToEmailPdf+']').parent().hide();
         //}

        Popupobj.show(data.result.content);
        ld('#'+Popupobj.divid).find('input').unbind('click').bind('click',function(){
            var checkedstatus = ld(this).prop("checked");
            var curprintsetid =ld(this).attr('id');

            var check_array = new Array();
            var uncheck_array = new Array();
            ld('#'+Popupobj.divid).find('input').each(function(i,inputitem){
                var checkedstatus = ld(inputitem).prop("checked");

                if(checkedstatus==false){
                    uncheck_array.push(ld(inputitem).attr('id'));
                }else{
                    check_array.push(ld(inputitem).attr('id'));
                }
            });
            if(check_array.length<=0){

                ld('#'+Popupobj.divid).find('input').last().prop('checked', true);
                tmp_curprintsetid = ld('#'+Popupobj.divid).find('input').last().attr('id'); //BUG0069320 xxy 2023-7-13 打印工具-打印设置-取消勾选左右参数后，弹出必须勾选一个参数的提示信息，且会自动将“发送邮件并添加PDF格式附件”参数勾选上，但是关闭弹出层后，保存的是别的参数
                var prevpopupobj = CrmPopup.getPopupObj('lastprev');
                ld("#"+prevpopupobj.divid+" [value="+curprintsetid+']').parent().hide();
                ld("#"+prevpopupobj.divid+" [value="+tmp_curprintsetid+']').parent().show();
                ld("#"+prevpopupobj.divid+" [value="+tmp_curprintsetid+']').prop('checked', true);
                MessagePopup.TipOne_warning(arrJsPopLabel['Enable_Category_Tip']);
                return ;
            }
            if(check_array.length == 1){
                tmp_curprintsetid = ld('#'+Popupobj.divid).find('input:checked').attr('id');
                var prevpopupobj = CrmPopup.getPopupObj('lastprev');
                ld("#"+prevpopupobj.divid+" [value="+tmp_curprintsetid+']').prop('checked', true);
            }
            var unselected_tags = uncheck_array.join(',');

            var surl = 'index.php?module=Settings&action=SettingsAjax&file=PrintSettings&printset=saveset&unselected_tags='+unselected_tags+'&frommodule='+frommodule;
            //'{$PrintSettingCategoriesArr[0]}'
            ldAjax(surl,{},function(data){
                var prevpopupobj = CrmPopup.getPopupObj('lastprev');
                if(checkedstatus==false){
                    ld("#"+prevpopupobj.divid+" [value="+curprintsetid+']').parent().hide();
                    prevpopupobj.hideid_arr.push(curprintsetid);
                }
                else {
                    var templatetype = ld("#"+prevpopupobj.divid).find("[name=print_select]").find('option:selected').attr('type');// 模板类型
                    if(empty(templatetype)){
                        if(curprintsetid != 'toExcel' && curprintsetid != 'toEmailExcel'){ // 普通模板不显示xls
                            ld("#"+prevpopupobj.divid+" [value="+curprintsetid+']').parent().show();
                        }
                    }else{
                        if(templatetype == 'Word' && (curprintsetid != 'toExcel' && curprintsetid != 'toEmailExcel')){
                            ld("#"+prevpopupobj.divid+" [value="+curprintsetid+']').parent().show();
                        }
                        else if(templatetype == 'Excel' && (curprintsetid != 'toDOC' && curprintsetid != 'toEmailDoc')){
                            ld("#"+prevpopupobj.divid+" [value="+curprintsetid+']').parent().show();
                        }
                    }
                    prevpopupobj.hideid_arr = prevpopupobj.hideid_arr.filter(item => item !== curprintsetid);
                }
                ld('#rptContentLoading').hide();
            });
        })
    })
}
// 切换打印模板事件
PrintPopup.changeTemplate = function(obj){
    var popupobj = CrmPopup.getPopupObj("last");
    var templatetype = ld("#"+popupobj.divid).find("[name=print_select]").find('option:selected').attr('type');// 模板类型

    if(ld("#"+popupobj.divid).find("#openoffice_tips"))
        ld("#"+popupobj.divid).find("#openoffice_tips").show();

    var showid_arr = [];// 需要显示的id
    var tmphideid_arr = [];// 需要隐藏的id
    var hideid_arr = popupobj.hideid_arr;// 选项设置中关闭的id

    if(templatetype == 'Word'){

        showid_arr = ['toDOC','toEmailDoc'];
        tmphideid_arr = ['toExcel','toEmailExcel'];
    }else if(templatetype == 'Excel'){

        showid_arr = ['toExcel','toEmailExcel'];
        tmphideid_arr = ['toDOC','toEmailDoc'];
    }else{

        showid_arr = ['toDOC','toEmailDoc','toPDF','toEmailPdf'];
        tmphideid_arr = ['toExcel','toEmailExcel'];

        if(ld("#"+popupobj.divid).find("#openoffice_tips"))
            ld("#"+popupobj.divid).find("#openoffice_tips").hide();
    }

    var hideid_arr = hideid_arr.concat(tmphideid_arr); // 合并数组
    var hideid_arr = hideid_arr.filter((item, index) => {// 去重
        return hideid_arr.indexOf(item) === index;
    });
    ld.each(showid_arr,function(index,id){
        if(!empty(id))
            ld("#"+popupobj.divid).find("#"+id).parent().show();
    })
    ld.each(hideid_arr,function(index,id){
        if(!empty(id))
            ld("#"+popupobj.divid).find("#"+id).parent().hide();
    })
}





 
