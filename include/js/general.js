var global_flash_fileattachmentphp='index.php?module=Users&action=UsersAjax&file=File_Upload';
var global_flash_delfileattachmentphp='index.php?module=Users&action=UsersAjax&file=File_DelUpload';
function QCreate(qcoptions){

    var objparams=new CreatePagePopup.params();
    objparams.params['refreshpage']='no';
    objparams.params['createdtype']='quickcreate';
    var lasturl = '';

    getJsScript('include/js/modules/'+qcoptions+'/'+qcoptions+'.js',function() {
        CreatePagePopup.showpage(qcoptions, lasturl, objparams);
    });
}
function getnextstepinfo(obj){
    var recordid = document.frmsubmitapprove.idstring.value;
    ldAjaxNoProgress("index.php",{getnextstepinfo : ld(obj).val(),module:"Approve",file:"SubmitApprove",action:"ApproveAjax",approve_recordid:recordid},function(data){
        ChangeSubmitHtml(data);
    })
}
function ChangeSubmitHtml(data){
    if(!empty(data.pagetype)){
        //duan 20230905 BUG0072197:复制单据时，出现了产品禁用提示，导致审批流程中没有审批人,增加pagetype获取弹出层
        var popupobj=CrmPopup.getlastPopupObjByPageType(data.pagetype);
    }
    else{
        var popupobj=CrmPopup.getPopupObj('last');
    }
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var submitapprovestep_tableobj=ld("#"+popupobj.divid+" [name=submitapprovestep_table]");
    ld("#"+popupobj.divid+" [name=concurrentidStepCount]").val(data.result.steplist.length);
    ld("#"+popupobj.divid+" [name=old_submitapprovelog]").hide();
    ld("#"+popupobj.divid+" [name=submitapprovelog]").html(data.result.submitapprovelog);
    $(submitapprovestep_tableobj).find("tr[tag=rowdata]").remove();
    var trhtml='';
    ld.each(data.result.steplist,function(tmpindex,tmpinfo){
        trhtml += "<tr tag='rowdata'>";
        trhtml += '<td class="ld-form-item-label">'+arrJsPopLabel['APPROVALSTEP']+'</td>';
        trhtml += '<td class="ld-form-item-content">';
        trhtml += '<input type="text" readonly=true class="ld-input-inner" name="nextstepname_'+tmpindex+'" value="'+tmpinfo.nextstepname+'">';
        trhtml += '<input type="hidden" class="commonTextBoxPop" name="nextstep_'+tmpindex+'" value="'+tmpinfo.stepid+'">';
        trhtml += '<input type="hidden" class="commonTextBoxPop" name="stepseq_'+tmpindex+'" value="'+tmpindex+'">';
        trhtml += '<input type="hidden" name="nextstep_countersigner_'+tmpindex+'" value="'+tmpinfo.countersigner+'"/>'
        trhtml += '<input type="hidden" name="nextstep_augmentsinger_'+tmpindex+'" value="'+tmpinfo.countersigner+'"/>';
        trhtml += '<input type="hidden" name="allow_emptyapprover_'+tmpindex+'" value="'+tmpinfo.allow_emptyapprover+'"/>';
        //edit:can 20210129 44445: 页面左侧列表 工程师管理 模块> 报损单>选择多条单据，批量提交>审批流程页面无法选择审批人>在下拉框重新选择审批流程之后，才可以选择审批人，
        var tmpb=false;
        if(tmpinfo.specifyapproverid==0){
            tmpb=true;
            if(prevpopupobj!=undefined&&prevpopupobj.type==ListPagePopup.type&&(popupobj.type != 'createpage'||popupobj.type != 'pagerecord')){
                if(ld("#"+prevpopupobj.divid+" [name=selected_id]:checked").length>1){
                    tmpb=false;
                }
            }
        }

        trhtml += '    <div name="userid_name_'+tmpindex+'" id="userid_name_'+tmpindex+'" style="display:none">'+tmpinfo.newstepapprover+'</div>';
        trhtml += '    <input type="hidden" name="userid_'+tmpindex+'" id="userid_'+tmpindex+'" value="'+tmpinfo.stepuserids+'"/>';
        trhtml += '</td>';
        trhtml += "</tr>";
        //zkt 1002441 审批，审批人添加框样式优化
        var tmpuserarr = tmpinfo.stepuseridtonamearr;
        trhtml += '<tr tag="rowdata" id="approvestep_selecttr_'+tmpindex+'" name="approvestep_selecttr_'+tmpindex+'" >';
        trhtml += '<td class="ld-form-item-label">';
        if (tmpinfo.countersigner == 'yes'){
            trhtml += '<span tag="label_countersigner">'+data.result.labels.Countersigner+'</span>';
        }
        else{
            trhtml += '<span tag="label_approver">'+data.result.labels.APPROVER+'</span>';
        }
        trhtml += '</td>';
        trhtml += '<td class="ld-form-item-content">';
        trhtml += '<div class="pubclear" id="before_approve_selectdiv_'+tmpindex+'">';
        trhtml += '<div class="CCrange ld-input-inner-div" id="approvers_div_'+tmpindex+'" name="approvers_div_'+tmpindex+'" tag="ccrange" style="margin-top: 0;border-radius:4px;overflow-y: auto;max-height:90px;">';
        trhtml += '<ul class="ld-input-inner-div-items">';
        if(!empty(tmpuserarr)){
            ld.each(tmpuserarr,function(id,name){
                trhtml += '<li class="ld-input-inner-div-item" itemid="approver_'+tmpindex+'_'+id+'">';
                trhtml += '<span class="item-name">'+name+'</span>';
                //可以选择审批人时显示
                if(tmpb){
                    trhtml += '<span class="remove-h" onclick="ApproveSelectApproverDiv_remove_oneuser(this,\'userid_'+tmpindex+'\',\'userid_name_'+tmpindex+'\')">×</span>';
                }
                trhtml += '</li>';
            });
        }
        trhtml += '</ul>';
        trhtml +='</div>';
        //可以选择审批人时显示
        if(tmpb){
            trhtml +="<div class='ld-text-change' onclick='concurrentstepapprove_selectuser("+tmpindex+");'>"+arrJsPopLabel['replacement']+"</div>";
        }
        trhtml += '</div></td></tr>';
    });

    $(submitapprovestep_tableobj).append(trhtml);
    popupobj.center();
    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
        //通讯录(pc端企业微信)
        cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
    }
}
//审批人选择框移除单个审批人事件
function ApproveSelectApproverDiv_remove_oneuser(obj,removeidinputname,removenameinputname){//
    var popupobj=CrmPopup.getPopupObj('last');
    var liobj=Tools.getParentobjByChild(ld(obj),'li');

    var itemid = ld(liobj).attr('itemid');
    var itemidarr = itemid.split('_');
    var rowindex = itemidarr[1];//并发确定行
    var remove_userid = itemidarr[2];//用户ID
    var remove_username = ld(liobj).attr('title');
    //移除选择框
    ld(liobj).remove();
    //修改userid_[rowindex]内容ser_idarr = [];
    if(ld("#" + popupobj.divid + " [name="+removeidinputname+"]").length>0){
        var select_user_id = ld("#" + popupobj.divid + " [name="+removeidinputname+"]").val();
        var select_user_idarr = select_user_id.split(',');
        select_user_idarr.splice(ld.inArray(remove_userid,select_user_idarr), 1);
        ld("#" + popupobj.divid + " [name="+removeidinputname+"]").val(select_user_idarr.join(','));
    }

    if(ld("#" + popupobj.divid + " [name="+removenameinputname+"]").length>0){
        var select_user_name = ld("#" + popupobj.divid + " [name="+removenameinputname+"]").val();
        if(select_user_name == ''){
            select_user_name = ld("#" + popupobj.divid + " [name="+removenameinputname+"]").get(0).innerHTML;
        }
        var select_user_namearr = select_user_name.split(',');
        select_user_namearr.splice(ld.inArray(remove_username, select_user_namearr), 1);
        ld("#" + popupobj.divid + " [name="+removenameinputname+"]").val(select_user_namearr.join(','));
        ld("#" + popupobj.divid + " [name="+removenameinputname+"]").html(select_user_namearr.join(','));
    }
    return false;
}
function toThousands(num) {
    return (num+ '').replace(/(\d{1,3})(?=(\d{3})+(?:$|\.))/g,'$1,');
    // return result;
}
/**

 */
function JsNumbertoFixed(number,len)
{


    //含税单价47245.7x0.05=2362.285，四舍五入应该是2362.29，
    var add = 0;
    var s,temp;
    var s1 = number + "";
    len=parseInt(len);

    var start = s1.indexOf(".");
    start=parseInt(start)
    var str_ret='';
    if(start>0)
    {


        if(s1.substr(start+len+1,1)==5)
        {
            add=1;
            var temp = Math.pow(10,len);

            s = Math.floor(number * temp) + add;

            str_ret= s/temp;
        }
        else if(s1.substr(start+len+3,1)==9 && s1.substr(start+len+4,1)==9){
            //duan 20230206 检测缩进位置的后3,4位是否为9，如果是就在此缩进一次，避免js浮点数计算不精确的问题
            add=1;
            var temp = Math.pow(10,len+2);

            s = Math.floor(number * temp) + add;

            str_ret= s/temp;

            var temp1 = Math.pow(10,len);
            str_ret = Math.round(str_ret*temp1)/temp1;
        }
        else
        {
            str_ret= parseFloat(number).toFixed(len);

        }
    }
    else{
        str_ret= parseFloat(number).toFixed(len);;
    }

    return str_ret;
}
//明细选择源单  -  快速创建
function Detail_QCreate(qcoptions){
    var columnname = arguments[1] ? arguments[1] : 2;
    var detail_row = arguments[2] ? arguments[2] : 0;
    getJsScript('include/js/QuickCreate.js',function(){
        quickPop(qcoptions,columnname,detail_row);
    });
}

function setproduct_values(a,b,c){
    // getJsScript('include/js/Inventory.js',function(){

    setproduct_value(a,b,c);
    // });
}
/* 全选、全不选相关代码 begin */
//function toggleSelect(state,relCheckName) {getJsScript('include/js/ldcrm.base.js',function(){toggleSelects(state,relCheckName);});}
function SelectListValAll(mod,frommod,span) {getJsScript('include/js/ldcrm.base.js',function(){SelectListValAlls(mod,frommod,span);});}
function SelectProductAll(mod,parmod) {getJsScript('include/js/ldcrm.base.js',function(){SelectProductAlls(mod,parmod);});}
function SelectAll(mod,parmod){getJsScript('include/js/ldcrm.base.js',function(){SelectAlls(mod,parmod);});}
function showDivImports(obj,module){getJsScript('include/js/importUpload.js',function(){showDivImport(obj,module);});}
function DownLoadDocuments(fileid,record = 0){getJsScript('include/js/EditView.js',function(){DownLoadDocumentss(fileid,record);});}
/* 全选、全不选相关代码 end */
/*均摊js*/
function showAllocation(a,b,c,d){getJsScript('include/js/ShareEqually.js',function(){showAllocations(a,b,c,d);});}
function setShareSourceModule(a,b){getJsScript('include/js/ShareEqually.js',function(){setShareSourceModules(a,b);});}

function CrmPopupWindow(a,b,c){getJsScript('include/js/SystemPopup/CrmPopupWindows.js',function(){fun_setCrmPopupWindow(a,b,c);});}
/*chj:seelct上下移动：后面统一修改成以下方法*/
function select_moveUp(select_id){getJsScript('include/js/ldcrm.list.js',function(){select_moveUps(select_id);});}
function select_moveDown(select_id){getJsScript('include/js/ldcrm.list.js',function(){select_moveDowns(select_id);});}
/*
{*修改编码格式:统一编码：UTF-8*}
*/
var gValidationCall='';
if (document.all)
    var browser_ie=true
else if (document.layers)
    var browser_nn4=true
else if (document.layers || (!document.all && document.getElementById))
    var browser_nn6=true
var gBrowserAgent = navigator.userAgent.toLowerCase();

function hideSelect(){getJsScript('include/js/ldcrm.base.js',function(){hideSelects();});}
function showSelect(){getJsScript('include/js/ldcrm.base.js',function(){showSelects();});}
function getObj(n,d) {
    var p,i,x;
    if(!d) d=document;
    if(n != undefined) {
        if((p=n.indexOf("?"))>0&&parent.frames.length) {
            d=parent.frames[n.substring(p+1)].document;
            n=n.substring(0,p);
        }
    }
    if(d.getElementById) {
        x=d.getElementById(n);
        if(x && x.id != n) x = false;
    }
    if(d.forms==undefined ){
        x=d[n];
    }else{
        for(i=0;!x && i<d.forms.length;i++) {
            x=d.forms[i][n];
        }
    }
    for(i=0; !x && d.layers && i<d.layers.length;i++) {
        x=getObj(n,d.layers[i].document);
    }
    if(!x && !(x=d[n]) && d.all) x=d.all[n];
    if(typeof x == 'string') x=null;
    return x;
}
function getOpenerObj(n) {return getObj(n,document)}
function findPosX(obj) {
    var curleft = 0;
    if (document.getElementById || document.all) {
        while (obj.offsetParent) {
            curleft += obj.offsetLeft
            obj = obj.offsetParent;
        }
    } else if (document.layers) {
        curleft += obj.x;
    }
    return curleft;
}
function findPosY(obj) {
    var curtop = 0;
    if (document.getElementById || document.all) {
        while (obj.offsetParent) {
            curtop += obj.offsetTop-obj.scrollTop
            obj = obj.offsetParent;
        }
    }else if (document.layers) {
        curtop += obj.y-obj.scrollTop;
    }
    return curtop-ld('.Tdcenter div.DivCTable').scrollTop();
}

function patternValidate(fldName,fldLabel,type) {
//	var currObj=getObj(fldName);
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var currObj=CrmPopup.findHtmlobj(divid,fldName);

    if (type.toUpperCase()=="EMAIL") //Email ID validation
    {

        //Changes made to fix tickets #4633, #5111  to accomodate all possible email formats
        // var re=new RegExp(/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/);
        var re=new RegExp(/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/);//mekia_@libero.com  国际邮件不通过 ls 241216
    }

    if (type.toUpperCase()=="DATE") {//DATE validation

        var re = /^\d{4}(\-|\/|\.)\d{1,2}\1\d{1,2}$/;
    }
    if (type.toUpperCase()=="TIME") {//TIME validation
        var re = /^\d{1,2}\:\d{2}:\d{2}$|^\d{1,2}\:\d{2}$/
    }

    //zkt 202311162 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
    var fieldinfo = [];
    if(popupobj != undefined && popupobj.type!= undefined &&(popupobj.type==DetailViewPage.type||popupobj.pagetype==CreatePagePopup.pagetype||popupobj.pagetype==ListEditPagePopup.pagetype))
    {
        if(popupobj.fieldname_fields[fldName]!=undefined){
            fieldinfo = popupobj.fieldname_fields[fldName];
        }
    }
    var currobjvalue = currObj.val();
    if(fieldinfo != [] && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
        currobjvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
    }
    //Asha: Remove spaces on either side of a Email id before validating
    if (type.toUpperCase()=="EMAIL" || type.toUpperCase() == "DATE") currObj.val(trim(currObj.val()));

    if(fldName=='email_remind'||fldName=='date_time'){
        if (!re.test(currObj.val().substr(0,10))) {
            var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+ fldLabel  + " ("+type+")";
            audioRemindsMsg("","","","","",confirm_str);
            try {
                currObj.focus()
            } catch(error) {

            }
            return false
        }
        else return true

    }else if (!re.test(currobjvalue)) {


        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        audioRemindsMsg("","","","","",confirm_str);
        try {
            currObj.focus()
        } catch(error) {
            // Fix for IE: If element or its wrapper around it is hidden, setting focus will fail
            // So using the try { } catch(error) { }
        }
        return false;
    }else{
        return true;
    }
}

function numValidate(fldName,fldLabel,format,neg) {
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    //editor:gyq_132 reason:库存报表高级查找的分页，此时获取的divid错误，需要特殊赋值  2019/7/18 15:43
    if(ld('#advanced_filter_mark').val()==='yes'){
        divid = 'dv_listhighersearch' ;
    }
    var currObj=CrmPopup.findHtmlobj(divid,fldName);
    if(CrmPopup.findHtmlobj(divid,'span_'+fldName).length > 0){
        currObj=CrmPopup.findHtmlobj(divid,'span_'+fldName)
    }
    //zkt 202311162 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
    var fieldinfo = [];
    if(popupobj != undefined && popupobj.type!= undefined &&(popupobj.type==DetailViewPage.type||popupobj.pagetype==CreatePagePopup.pagetype||popupobj.pagetype==ListEditPagePopup.pagetype))
    {
        if(popupobj.fieldname_fields[fldName]!=undefined){
            fieldinfo = popupobj.fieldname_fields[fldName];
        }
    }
    var currobjvalue = currObj.val();
    if(fieldinfo != [] && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
        currobjvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
    }
    //duan 20240311封装一下数据类型判断函数，便于分录使用
    if(detail_numValidate(fldName,fldLabel,format,neg,currobjvalue)){
        return true;
    }else{
        try {
            currObj.focus()
        }catch(error) { }
        return false;
    }


    return true
}

function numConstComp(fldName,fldLabel,type,constval) {

    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var currObj=CrmPopup.findHtmlobj(divid,fldName);
    var val=currObj.val().replace(/^\s+/g, '').replace(/\s+$/g, '');
    constval=parseFloat(constval)
    //duan 20240311封装一下数据类型判断函数，便于分录使用
    var ret = detail_numConstComp(fldName,fldLabel,type,constval,val);

    if (ret==false) {
        try {
            currObj.focus()
        } catch(error) { }
        return false
    } else return true;
}


function splitDateVal(dateval) {
    var datesep;
    var dateelements = new Array(3);

    if (dateval.indexOf("-")>=0) datesep="-"
    else if (dateval.indexOf(".")>=0) datesep="."
    else if (dateval.indexOf("/")>=0) datesep="/"
    userDateFormat="yyyy-mm-dd";
    switch (userDateFormat) {
        case "yyyy-mm-dd" :
            dateelements[0]=dateval.substr(dateval.lastIndexOf(datesep)+1,dateval.length) //dd
            dateelements[1]=dateval.substring(dateval.indexOf(datesep)+1,dateval.lastIndexOf(datesep)) //mm
            dateelements[2]=dateval.substring(0,dateval.indexOf(datesep)) //yyyyy
            break;
        case "mm-dd-yyyy" :
            dateelements[0]=dateval.substring(dateval.indexOf(datesep)+1,dateval.lastIndexOf(datesep))
            dateelements[1]=dateval.substring(0,dateval.indexOf(datesep))
            dateelements[2]=dateval.substr(dateval.lastIndexOf(datesep)+1,dateval.length)
            break;
        case "dd-mm-yyyy" :
            dateelements[0]=dateval.substring(0,dateval.indexOf(datesep))
            dateelements[1]=dateval.substring(dateval.indexOf(datesep)+1,dateval.lastIndexOf(datesep))
            dateelements[2]=dateval.substr(dateval.lastIndexOf(datesep)+1,dateval.length)
    }

    return dateelements;
}
function dateComparison(fldName1,fldLabel1,fldName2,fldLabel2,type) {

    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var currObj1=CrmPopup.findHtmlobj(divid,fldName1);
    var currObj2=CrmPopup.findHtmlobj(divid,fldName2);
    if(currObj1 != undefined && currObj2 != undefined&&currObj1.length>0&&currObj2.length>0){
        var dateval1=currObj1.val().replace(/^\s+/g, '').replace(/\s+$/g, '')
        var dateval2=currObj2.val().replace(/^\s+/g, '').replace(/\s+$/g, '')

        var dateelements1=splitDateVal(dateval1)
        var dateelements2=splitDateVal(dateval2)

        dd1=dateelements1[0]
        mm1=dateelements1[1]
        yyyy1=dateelements1[2]

        dd2=dateelements2[0]
        mm2=dateelements2[1]
        yyyy2=dateelements2[2]
        //duan 20230131 修改Date.setMonth 函数，传入参数为8（九月）,实际结果为十月的问题（虽然看起来很离谱，但确实是这样的）
        var date1=new Date(yyyy1,mm1-1,dd1)
        var date2=new Date(yyyy2,mm2-1,dd2)

        //date1.setYear(yyyy1)
//        date1.setMonth(mm1-1)
//        date1.setDate(dd1)
//
//        date2.setYear(yyyy2)
//        date2.setMonth(mm2-1)
//        date2.setDate(dd2)
        if (type!="OTH") {
            if (!compareDate(date1,fldLabel1,date2,fldLabel2,type)) {
                // try {
                //     currObj1.focus();
                // } catch(error) { }
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    currObj1.focus();
                });
                return false
            } else return true;
        } else return true
    }
    return true;
}

function compareDate(date1,fldLabel1,date2,fldLabel2,type) {
    var ret=true
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    switch (type) {
        case 'L'	:
            if (date1>=date2) {
                var confirm_str = fldLabel1+ arrJsPopLabel['SHOULDLESSTHAN'] +fldLabel2;
                MessagePopup.TipOne_warning(confirm_str);
                ret=false
            }
            break;
        case 'LE'	:
            if (date1>date2) {//DATE1 VALUE LESS THAN OR EQUAL TO DATE2
                var confirm_str = fldLabel1+ arrJsPopLabel['SHOULDLESSTHANOREQUAL'] +fldLabel2;
                MessagePopup.TipOne_warning(confirm_str);
                ret=false
            }
            break;
        case 'E'	:
            if (date1!=date2) {//DATE1 VALUE EQUAL TO DATE
                var confirm_str = fldLabel1+ arrJsPopLabel['SHOULDBEEQUAL'] +fldLabel2;
                MessagePopup.TipOne_warning(confirm_str);
                ret=false
            }
            break;
        case 'G'	:
            if (date1<=date2) {//DATE1 VALUE GREATER THAN DATE2
                var confirm_str = fldLabel1+ arrJsPopLabel['SHOULDBEGREATER'] +fldLabel2;
                MessagePopup.TipOne_warning(confirm_str);
                ret=false
            }
            break;
        case 'GE'	:
            if (date1<date2)//DATE1 VALUE GREATER THAN OR EQUAL TO DATE2
            {
                if(typeof popupobj.fields!=undefined )
                {
                    var fldnamelen = popupobj.fields.length;
                    for(var i=0;i<fldnamelen;i++){
                        if(popupobj.fields[i].fieldname == fldLabel2){
                            fldLabel2 = popupobj.fields[i].fieldlabel;break;
                        }
                    }
                    var confirm_str = fldLabel1+ arrJsPopLabel['SHOULDGREATEROREQUAL'] +fldLabel2;
                    MessagePopup.TipOne_warning(confirm_str);
                    ret=false;
                }
                else
                {
                    ///快速创建
                    var confirm_str = fldLabel1+ arrJsPopLabel['SHOULDGREATEROREQUAL'] +fldLabel2;
                    MessagePopup.TipOne_warning(confirm_str);
                    ret=false;
                }
            }
            break;
    }

    if (ret==false) return false
    else return true
}
function dateValidate(fldName,fldLabel,type) {
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var currObj=CrmPopup.findHtmlobj(divid,fldName);

    if(patternValidate(fldName,fldLabel,"DATE")==false)
        return false;
    dateval=currObj.val().replace(/^\s+/g, '').replace(/\s+$/g, '')

    var dateelements=splitDateVal(dateval);
    dd=dateelements[0];
    mm=dateelements[1];
    yyyy=dateelements[2];

    if (dd<1 || dd>31 || mm<1 || mm>12 || yyyy<1 || yyyy<1000) {
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        try {
            currObj.focus()
        } catch(error) { }
        return false
    }
    if ((mm==2) && (dd>29)) {//checking of no. of days in february month
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        try {
            currObj.focus()
        } catch(error) { }
        return false
    }

    if ((mm==2) && (dd>28) && ((yyyy%4)!=0)) {//leap year checking
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        try {
            currObj.focus()
        } catch(error) { }
        return false
    }

    switch (parseInt(mm)) {
        case 2 :
        case 4 :
        case 6 :
        case 9 :
        case 11 :
            if (dd>30) {
                var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                try {
                    currObj.focus()
                } catch(error) { }
                return false
            }
    }

    var currdate=new Date()
    var chkdate=new Date()

    chkdate.setYear(yyyy)
    chkdate.setMonth(mm-1)
    chkdate.setDate(dd)

    if (type!="OTH") {
        if (!compareDate(chkdate,fldLabel,currdate,arrJsPopLabel['CURRENTDATE'],type)) {
            try {
                currObj.focus()
            } catch(error) { }
            return false
        } else return true;
    } else return true;
}
function intValidate(fldName,fldLabel,fieldlabel) {

    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var currObj=CrmPopup.findHtmlobj(divid,fldName);

    if(currObj.length<=0)
    {
        //edit:can 20200820 42450: （http://corp.mdmedical.com.cn/ [^])客户问题（美迪）常用报表>即时库存查询：点击“高级查找”录入查找条件“库存数量-小于-0”立即查找，然后点击“下一页”没反应
        return true;
    }
    //zkt 202311162 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
    var fieldinfo = [];
    if(popupobj != undefined && popupobj.type!= undefined &&(popupobj.type==DetailViewPage.type||popupobj.pagetype==CreatePagePopup.pagetype||popupobj.pagetype==ListEditPagePopup.pagetype))
    {
        if(popupobj.fieldname_fields[fldName]!=undefined){
            fieldinfo = popupobj.fieldname_fields[fldName];
        }
    }
    var currobjvalue = currObj.val();
    if(fieldinfo != [] && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
        currobjvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
    }
    var val=currobjvalue.replace(/^\s+/g, '').replace(/\s+$/g, '');
    var confirm_str = '';
    if(typeof userCurrencySeparator != 'undefined' && userCurrencySeparator != '') {
        while(val.indexOf(userCurrencySeparator) != -1) {
            val = val.replace(userCurrencySeparator,'');

        }
    }
    if (isNaN(val) || (val.indexOf(".")!=-1 && fldName != 'potential_amount' && fldName != 'list_price'))
    {
        /*
       edit；cdw
       date:20130726
       reason:0004494: 页面设置，新增自定义字段中 长度和小数点字段 输入错误时提示信息未汉化
       */
        if(fldLabel == "Length")
            var confirm_str = arrJsPopLabel['INVALID']+' '+arrJsPopLabel['LENGTH'];
        else if(fldLabel == "Decimal")
            var confirm_str = arrJsPopLabel['INVALID']+' '+arrJsPopLabel['Decimal'];
        else
        {
            var confirm_str = arrJsPopLabel['INVALID']+' '+fieldlabel+' '+'字段';
        }
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        try {
            currObj.focus()
        } catch(error) { }
        return false
    }
    else if((fldName != 'employees' || fldName != 'noofemployees') && (val < -2147483648 || val > 2147483647))
    {
        /*
       edit:cdw
       date:20130801
       reason:0004555: 价格表明细界面更多信息产品中，批发价长度过长或者无效时提示信息未汉化
       */

        if(fldLabel == "EditListPrice")
            var confirm_str = arrJsPopLabel['WHOLESALEPRICE']+arrJsPopLabel['OUTOFRANGE'];
        else if(fldLabel == "Decimal")
            var confirm_str = arrJsPopLabel['Decimal']+arrJsPopLabel['OUTOFRANGE'];
        else if(fldLabel == "Length")
            var confirm_str = arrJsPopLabel['LENGTH']+arrJsPopLabel['OUTOFRANGE'];
        else
            var confirm_str =fldLabel+arrJsPopLabel['OUTOFRANGE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    else if((fldName == 'employees' || fldName != 'noofemployees') && (val < 0 || val > 2147483647))
    {

        /*
       edit:cdw
       date:20130808
       reason:0004670: 页面设置中：输入超出范围的长度和小数点时，提示信息未汉化
       */
        if(fldLabel == "EditListPrice")
            var confirm_str = arrJsPopLabel['WHOLESALEPRICE']+arrJsPopLabel['OUTOFRANGE'];
        else if(fldLabel == "Decimal")
            var confirm_str = arrJsPopLabel['Decimal']+arrJsPopLabel['OUTOFRANGE'];
        else if(fldLabel == "Length")
            var confirm_str = arrJsPopLabel['LENGTH']+arrJsPopLabel['OUTOFRANGE'];
        else
            var confirm_str = fldLabel+arrJsPopLabel['OUTOFRANGE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    else
    {
        return true;
    }
}



function dateTimesecValidate(dateFLdName,fldLabel,type){

    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var currObj=CrmPopup.findHtmlobj(divid,dateFLdName);
    var dateValue=currObj.val().substr(0,10);
    var timeValue=currObj.val().substr(11,currObj.val().length);
    userDateFormat="yyyy-mm-dd";

    switch (userDateFormat) {
        case "yyyy-mm-dd" :
            var reDate = /^\d{4}(\-|\/|\.)\d{1,2}\1\d{1,2}$/;
            break;
        case "mm-dd-yyyy" :
        case "dd-mm-yyyy" :
            var reDate = /^\d{1,2}(\-|\/|\.)\d{1,2}\1\d{4}$/;
    }
    var reTime = /^(0\d{1}|1\d{1}|2[0-3]):[0-5]\d{1}:([0-5]\d{1})$/;

    //chj 2020/12/18 43846: （http://xiaoshou360.com/xs/lufei [^]）（路飞网络科技(广州)）销售机会，点击任意小编辑编辑数据保存时，提示“请输入正确的最新联系日期”
    if(!reDate.test(dateValue) || (!reTime.test(timeValue) && timeValue != '')){
        /*
        add:kara "if...else"
        date:2013-06-08
        reason:bug:4007
        */
        if(currObj.val()==""){
            var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
        }
        else{
            var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        }
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        try {
            currObj.focus()
        } catch(error) {
        }
        return false
    }else return true;
}
function timeValidate(fldName,fldLabel,type) {
    if (patternValidate(fldName,fldLabel,"TIME")==false)
        return false
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var currObj=CrmPopup.findHtmlobj(divid,fldName);
    var timeval=currObj.val().replace(/^\s+/g, '').replace(/\s+$/g, '')
    var hourval=parseInt(timeval.substring(0,timeval.indexOf(":")))
    var minval=parseInt(timeval.substring(timeval.indexOf(":")+1,timeval.length))
    var secval=parseInt(timeval.substring(timeval.indexOf(":")+4,timeval.length))


    if (hourval>23 || minval>59 || secval>59) {
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        try {
            currObj.focus()
        } catch(error) { }
        return false
    }

    var currtime=new Date()
    var chktime=new Date()

    chktime.setHours(hourval)
    chktime.setMinutes(minval)
    chktime.setSeconds(secval)

    if (type!="OTH") {
        if (!compareDates(chktime,fldLabel,currtime,arrJsPopLabel['CURRENTTIME'],type)) {
            try {
                currObj.focus()
            } catch(error) { }
            return false
        } else return true;
    } else return true
}

/**
 *更新操作
 *edit:kevin
 *date:2013-11-27
 *reason:
 */
function fnvshobj(obj,idname)
{
    var isIE = (document.all) ? true : false;
    //var isIE6 = isIE && ([/MSIE (\d)\.0/i.exec(navigator.userAgent)][0][1] == 6);
    var isIE6 = isIE;
    var newbox=document.getElementById(idname);
    //editor:gyqX160811  Bug:0023798: 页面设置>付款计划>页面设置：新增区块保存后再点击【新增区块】按钮，弹出层的值没有清空
    if(idname == 'addblock'){
        ld('#blocklabel,#blocklabel2,#after_blockid').val('');
    }
    if(idname=='approvestepresult' || idname=='approvelog' || idname=='check_repeat'|| idname=='selectrelateddiv'){
        if(ld("#qcformDiv").css('display')=='block')
            newbox.style.zIndex="10201";
        else if(ld("#Second_qcformDiv").css('display')=='block')
            newbox.style.zIndex="10203";
        else
            newbox.style.zIndex="10100";
    }else if(idname=='qcformDiv')
        newbox.style.zIndex="10200";
    else if(idname=='Second_qcformDiv')
        newbox.style.zIndex="10202";
    else if(idname=='div_check_repeat')
        newbox.style.zIndex="10300";
    else if(idname=='div_setDuplicates' || idname=='setColumnDisplay')
        newbox.style.zIndex="10400";
    else if(idname=='RecycleBin_hy'){
        newbox.style.zIndex="1000";
    }
    else
        newbox.style.zIndex="9999";
    newbox.style.display="block";

    if(idname =='check_repeat')
    {
        newbox.style.position = "absolute";
    }
    else
    {
        newbox.style.position = (!isIE6 && (idname !='check_repeat' || !isIE))? "fixed" : "absolute";
    }
    if(idname =='EditWorkingSpace'){
        newbox.style.top='40%';
        newbox.style.left = "50%";
    }else{
        newbox.style.top =newbox.style.left = "50%";
    }
    if(newbox.offsetHeight == 0)
    {
        newbox.style.marginTop = - 130  + "px";
    }
    else
    {
        if(idname == 'qcbomnumberDiv'){
            newbox.style.marginTop = - newbox.clientHeight / 2 -115 + "px";
        }else{
            if(document.all){
                newbox.style.marginTop = - newbox.offsetHeight / 2 + document.documentElement.scrollTop +"px";
            }

            else{
                newbox.style.marginTop = - newbox.offsetHeight / 2 +"px";
                /*
				* editor:gyq_05  gyq_09
				* reason:根据新增审批通知标签页高度微调审批弹框上边距
				* date : 2016 2 23
				* reason:派息规则界面上边距微调
				  date:2016 4 5
				* */
                //idname == 'approvestep' || 0028125: 控制面板>审批流程管理：新增审批步骤，弹出框没有显示在居中位置。
                if(idname == 'Products_dividendRules'){
                    newbox.style.marginTop = - newbox.offsetHeight / 2 - 80 + "px";
                }
            }

        }

    }
    newbox.style.marginLeft = - newbox.offsetWidth / 2 + "px";

    if(!document.getElementById("layer"))
    {
        var layer=document.createElement("div");
        layer.id="layer";
        layer.style.width=layer.style.height="100%";
        //(!isIE6 && (idname !='check_repeat' || !isIE)) ? "fixed" : "absolute"
        layer.style.position= "fixed";

        layer.style.top=layer.style.left=0;
        layer.style.backgroundColor="#808080";
        layer.style.zIndex="9998";
        if(idname=='RecycleBin_hy'){
            layer.style.zIndex="999";
        }
        layer.style.opacity="0.6";
        if(idname == 'check_repeat')//快速创建中客户查重
        {
            //puyoungJS_DialogBox.unblock();
        }
        else
        {
            document.body.appendChild(layer);
        }
    }
    else
    {
        var layer=document.getElementById("layer");
    }
    var sel=document.getElementsByTagName("select");
    if(isIE){layer.style.filter ="alpha(opacity=60)";}
    //14582: 关于"高级"弹出层显示问题
    /*function layer_iestyle(){
        layer.style.width=Math.max(document.documentElement.scrollWidth, document.documentElement.clientWidth)+ "px";
        layer.style.height= Math.max(document.documentElement.scrollHeight, document.documentElement.clientHeight) +"px";
    }*/

    function newbox_iestyle(){
        //17323: 首页>组件视图：销售漏斗点击后，弹出层显示在最上方，需要滑动滚动条到最上方才能看到弹出层
        if(document.documentElement.scrollTop - newbox.offsetHeight / 2>0)
        {
            newbox.style.marginTop = document.documentElement.scrollTop - newbox.offsetHeight / 2 + "px";

            newbox.style.marginLeft = document.documentElement.scrollLeft - newbox.offsetWidth / 2 + "px";
        }
        else
        {
            newbox.style.top=( document.documentElement.clientHeight-newbox.offsetHeight)/2+document.documentElement.scrollTop+"px";
            //23898：审批流程管理 > 产品 ，【新增审批步骤】弹出窗口贴顶部且被挡住的部分内容
            newbox.style.marginTop=0;
        }

    }


    if(isIE6){
        //layer_iestyle()
        //17323: 首页>组件视图：销售漏斗点击后，弹出层显示在最上方，需要滑动滚动条到最上方才能看到弹出层
        //newbox_iestyle();
        window.attachEvent("onscroll",function(){
            newbox_iestyle();
        })

        // window.attachEvent("onresize",layer_iestyle);
    }

}
//xxy 2023-11-17 页面设置，显示隐藏字段优化样式
function fnvshobj_HiddenFields(obj,idname){
    fnvshobj(obj,idname);
    // getJsScript('include/js/DragTransfer.js',function(){
    var tableobj = ld('div#'+idname+'').find("table[name=HiddenFieldsTable]");
    var dragtransfer_tr = tableobj.find('[name=DragTransfer_tr]');
    if(dragtransfer_tr.length < 1){
        var RightObj = tableobj.find("select:first");
        var Drag_Transfer = new DragTransfer();
        var translabel = {
            available: '',
            selected: '',
            placeholder: arrJsPopLabel['PleaseEnterFieldSearchFor'],
        };
        Drag_Transfer.SetTranslabel(translabel);
        Drag_Transfer.right_Sortable = false;
        Drag_Transfer.SetDragTransfer(tableobj,"",RightObj,'reset','372');
        ld('div#'+idname+'').css('top','42%');
        ld("#keywordsearch_Right").focus();
    }
    // });
}
//添加必填红色边框提示
function emptyCheckObj(currJqueryObj, fieldtype) {
    // console.log(fieldtype);
    if(fieldtype == 'Text' || fieldtype == 'TextArea' || fieldtype == '1'){
        ld(currJqueryObj).focus();
        ld(currJqueryObj).addClass('border_red1');
        ld(currJqueryObj).on('input',function(e){
            ld(currJqueryObj).removeClass('border_red1');
        });
    }
    else if(fieldtype == 'Select' || fieldtype == '60'){
        ld(currJqueryObj).parent().find('a').addClass('border_red1');
    }
    //edit: xll 2023/05/16 BUG0066221 产品分录的必填项为空时点击保存，应在弹出提示信息的同时将输入框标红
    else if(ld(currJqueryObj)[0]!= undefined && ld(currJqueryObj)[0].type != undefined && (ld(currJqueryObj)[0].type == 'text' || ld(currJqueryObj)[0].type == 'textarea')){
        ld(currJqueryObj).focus();
        ld(currJqueryObj).addClass('border_red1');
        ld(currJqueryObj).on('input',function(e){
            ld(currJqueryObj).removeClass('border_red1');
        });
    }
}
function ChangeValue()
{

}

function emptyCheck(fldName,fldLabel,fldType) {
//	var currObj = getObj(fldName);
    var currObj;
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj != undefined){
        currObj=CrmPopup.findHtmlobj(popupobj.divid,fldName);
        if(currObj.length>1) {
            var tmpcurr_fieldnameobjs = currObj;
            ld.each(tmpcurr_fieldnameobjs,function (){
                if(ld(this).attr('fieldname') != undefined && ld(this).attr('fieldname') == fldName){
                    currObj = ld(this);
                    return false;
                }
            })

        }
    }
    var  uitype='';
    var fieldinfo = [];
    if(popupobj.type==DetailViewPage.type||popupobj.pagetype==CreatePagePopup.pagetype||popupobj.pagetype==ListEditPagePopup.pagetype||popupobj.pagetype=='advancepopup')
    {
        //popupobj.pagetype:新增和编辑的值一样
        if(popupobj.fieldname_fields[fldName]!=undefined){
            fieldinfo = popupobj.fieldname_fields[fldName];
            uitype= popupobj.fieldname_fields[fldName].uitype;
        }
    }
    if(uitype!=''&&SaveDataRecord.isfileattachUitype(uitype))
    {
        //31845: 附件管理新增界面：添加附件，在删除掉添加的附件。结果：也能保存。
        //40559: （http://51mis.com/demo/panlulu008演示账套 [^]）客户->页面设置新增附件字段且设置为必填字段，单据新建界面添加附件保存时，仍提示“附件不能为空”
        for(var i=0;i<=220;i++)
        {
            if(CrmPopup.findHtmlobj(popupobj.divid,fldName+'-file_name_'+i)!=undefined&&CrmPopup.findHtmlobj(popupobj.divid,fldName+'-file_name_'+i).length>0&&
                CrmPopup.findHtmlobj(popupobj.divid,fldName+'-file_name_'+i).val()!='')
            {
                return true;
            }

        }

        if(CrmPopup.findHtmlobj(popupobj.divid,'filelocationtype') != undefined && CrmPopup.findHtmlobj(popupobj.divid,'filelocationtype').val() == 'E' && CrmPopup.findHtmlobj(popupobj.divid,'name_E__').val() != ''){
            return true;
        }

        var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];

        audioRemindsMsg("","","","","",confirm_str);
        return false;
    }
    if(currObj=='undefined'||currObj==undefined)
    {
        return true;
    }
    //zkt 20230208 描述字段和审批意见字段name相同 BUG0061392kfbcrm   工单管理---不填写必填字段“问题描述”---会弹出提示，但会把审批意见框标红
    if(fldName == 'description' && currObj.length>1){
        currObj = ld(currObj[0]);
    }
    if (fldType=="text"||uitype==15) {
        var currobjvalue = currObj.val();
        if(fieldinfo != [] && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
            currobjvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
        }
        if (currobjvalue != undefined && currobjvalue.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0) {
            var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
            // audioRemindsMsg("","","","","",confirm_str);
            MessagePopup.TipZero_warning(confirm_str);
            try {
                currObj.focus();
                if(uitype == 15){
                    ld(currObj).parent().find('a').addClass('border_red1');
                }
                else{
                    ld(currObj).addClass('border_red1');
                }
                ld(currObj).on('blur',function(){
                    // if(ld(this).val()!='')
                    // {
                    //edit:can 046476: 单据保存时->时间类型的字段提示必填->录入时间->必填的红色边框没有消失
                    ld(this).removeClass('border_red1');
                    // }

                })
            } catch(error) {

            }
            return false
        }
        else{
            return true
        }
    }else if((fldType == "textarea")
        && (typeof(CKEDITOR)!=='undefined' && CKEDITOR.intances[fldName] !== 'undefined')) {
        var textObj = CKEDITOR.intances[fldName];
        var textValue = textObj.getData();
        if(fieldinfo != [] && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
            textValue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
        }
        if (trim(textValue) == '' || trim(textValue) == '<br>') {
            var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
            // audioRemindsMsg("","","","","",confirm_str);
            MessagePopup.TipZero_warning(confirm_str);
            return false;
        } else{
            return true;
        }
    }
    else if(fldType=='select-multiple')
    {
        //23925: 联系人>编辑：多选框字段设为必填字段，编辑联系人，保存提示“多选框”不能为空。实际上已经录入内容。
        if(CrmPopup.findHtmlobj(this.divid,curr_fieldname).find( "option:selected").length<=0){
            var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
            // audioRemindsMsg("","","","","",confirm_str);
            MessagePopup.TipZero_warning(confirm_str);
            return false;
        }
    }
    else if(currObj.prop("tagName")!=undefined&&currObj.prop("tagName").toLowerCase()=='select')
    {
        //41598: （61mis/kfbtest）（客户001名称）模块新增界面：录入值点击保存，保存是提示“销售负责人”不允许为空，实际该字段是有值的。
        if(trim(currObj.find("option:selected").val())=='')
        {

            var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
            // audioRemindsMsg("","","","","",confirm_str);
            MessagePopup.TipZero_warning(confirm_str);
            return false;
        }
    }
    else{
        // if (trim(currObj.val()) == '' || trim(currObj.val()) == '0') {
        //ls 2022-03-25 0050626: （http://aodejx.gnway.org/crm [^]）（奥德）销售合同-苏奥模块中，保存的时候提示‘包含配件费’不能为空，实际上这个字段是文本字段，内容是0，（字段为不可编辑时）
        //duan 2022-10-8 关联选择单据字段值为0时，需要识别为空
        var currobjvalue = currObj.val();
        if(fieldinfo != [] && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
            currobjvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
        }
        if (empty(trim(currobjvalue))|| (popupobj.fieldname_fields != undefined && !empty(popupobj.fieldname_fields[fldName])&&popupobj.fieldname_fields[fldName].bigtype=='reference' && trim(currobjvalue) == '0') ) {
            var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
            // audioRemindsMsg("","","","","",confirm_str);
            MessagePopup.TipZero_warning(confirm_str);
            currObj.focus();
            ld(currObj).addClass('border_red1');

            var currnameObj=CrmPopup.findHtmlobj(popupobj.divid,fldName+'_name');
            if(currnameObj){
                ld(currnameObj).focus();
                ld(currnameObj).addClass('border_red1');
            }
            return false
        } else
            return true
    }
    return true;
}



function dateTimeValidate(a,b,c,d){getJsScript('include/js/ldcrm.base.js',function(){dateTimeValidates(a,b,c,d);});}
function dateTimeComparison(a,b,c,d,e,f,g){getJsScript('include/js/ldcrm.base.js',function(){dateTimeComparisons(a,b,c,d,e,f,g);});}


function timeComparison(a,b,c,d,e){getJsScript('include/js/ldcrm.base.js',function(){timeComparisons(a,b,c,d,e);});}

function getFileNameOnly(a){getJsScript('include/js/ldcrm.base.js',function(){getFileNameOnlys(a);});}
function validateFilename(a){getJsScript('include/js/ldcrm.base.js',function(){validateFilenames(a);});}
function clearId(fldName){var currObj=getObj(fldName);currObj.value='';}
function comparestartdate(chkdate) {var currdate = new Date();
    return compareDates(chkdate,arrJsPopLabel['STARTTIME'],currdate,arrJsPopLabel['CURRENTTIMESTATEISPLANNED'],"GE");}
function openPopUp(a,b,c,d,e,f,g){getJsScript('include/js/ldcrm.base.js',function(){openPopUp(a,b,c,d,e,f,g);});}
//自动执行的js，暂时不知道是干什么的
var scrX=0,scrY=0,pgeX=0,pgeY=0;
if (browser_nn4 || browser_nn6) {
    document.addEventListener("click",popUpListener,true)
}
function popUpListener(ev) {
    if (browser_nn4 || browser_nn6) {
        scrX=ev.screenX
        scrY=ev.screenY
        pgeX=ev.pageX
        pgeY=ev.pageY
    }
}
function toggleDiv(id) {
    var listTableObj=getObj(id)
    if (listTableObj.style.display=="block")
        listTableObj.style.display="none"
    else listTableObj.style.display="block"
}
function changeratio(a,b,c,d){getJsScript('include/js/ldcrm.core.js',function(){changeratios(a,b,c,d);});}
function changeamountn(a,b,c,d){getJsScript('include/js/ldcrm.core.js',function(){changeamountns(a,b,c,d);});}
function toggleAssignTypes(a){getJsScript('include/js/ldcrm.base.js',function(){toggleAssignTypess(a);});}
function show(divId){ld('#'+divId).css('display','inline');}
function hide(divId){ld('#'+divId).css('display','none');}
function New_show(divname){
    var popupojb=CrmPopup.getPopupObj('last');
    ld('#'+popupojb.divid+" [name="+divname+"]").css('display','inline');
}
function New_hide(divname){

    var popupojb=CrmPopup.getPopupObj('last');
    ld('#'+popupojb.divid+" [name="+divname+"]").css('display','none');
}
function showBlock(divId){
    var id = document.getElementById(divId);
    id.style.display = 'block';
    if(document.getElementById("reminderOptions3")!=undefined)
        document.getElementById("reminderOptions3").style.display="block";
}
function fnhide(divId){
    var popupobj=CrmPopup.getPopupObj('last');

    var id = ld("#"+popupobj.divid+" [name="+divId+"]").get(0);//document.getElementById(divId);
    //zkt 20221017 BUG0057619首页-新建日程管理，视频中部分，当点击否的时候，时间框不会自动隐藏，见附件视频
    if(empty(id)){
        id = ld("#"+popupobj.divid+" [id='"+divId+"']").get(0);
    }
    id.style.display = 'none';
    //Edit by LD Can  邮件提醒添加提醒框
    /*if(document.getElementById("reminderOptions2")!=undefined && document.getElementById("reminderOptions")!=undefined)
        if(document.getElementById("reminderOptions2").style.display=="none" && document.getElementById("reminderOptions").style.display=="none")
            document.getElementById("reminderOptions3").style.display="none";*/

}
function fnLoadValues(a,b,c,d,e,f){getJsScript('include/js/ldcrm.base.js',function(){fnLoadValuess(a,b,c,d,e,f);});}
function fnCopy(source,design){
    document.getElementById(source).value=document.getElementById(design).value;
    document.getElementById(source).disabled=true;
}
function fnClear(source){
    document.getElementById(source).value=" ";
    document.getElementById(source).disabled=false;
}
/*
* javascript function to add field rows
* @param option_values :: List of Field names
*/
var count = 0;
var rowCnt = 1;
function fnvsh(obj,Lay){
    var tagName = document.getElementById(Lay);
    var leftSide = findPosX(obj);
    var topSide = findPosY(obj);
    tagName.style.left= leftSide + 175 + 'px';
    tagName.style.top= topSide + 'px';
    tagName.style.visibility = 'visible';
}
function hideOptions(id){hide(id);}
function exportTypeTelect(a,b){getJsScript('include/js/ldcrm.base.js',function(){exportTypeTelects(a,b);});}

function fnvshobj_back(a,b){getJsScript('include/js/ldcrm.core.js',function(){fnvshobj_backs(a,b);});}
function posLay(a,b){getJsScript('include/js/ldcrm.core.js',function(){posLays(a,b);});}
function fninvsh(a){getJsScript('include/js/ldcrm.core.js',function(){fninvshs(a);});}
/*
edit:can
date:20140306
reason:获取月份最大天数
*/
function getDaysInMonth(year,month){
    month = parseInt(month,10);
    var temp = new Date(year,month,0);
    return temp.getDate();
}
function fninvshnew(idname){
    puyoungJS_DialogBox.unblock();
    if(document.getElementById(idname) != undefined){
        var newbox=document.getElementById(idname);
        newbox.style.display="none";
        // ljj 20231030 BUG0073655 kfbcrm-入库单-打印模板名称过长时超出宽度 改为可搜索下拉框，取消和关闭时去除自建obj
        if (idname == 'printview'){
            if(CrmPopup.getPopupObj('last').divid=="printview" && CrmPopup.getPopupObj("lastprev").divid=="ListViewContents") {
                CrmPopup.global_listPopupObj.pop();//把自建对象移除，移除当前弹出层
            }
        }

    }
    if(idname=='qcformDiv'&& typeof isPopupButton!=undefined)//用于选择客户，联系人等判断弹出框是否为快速创建
    {
        isPopupButton='no';
        if(document.getElementById('qcform') != undefined){
            document.getElementById('qcform').innerHTML = '';
        }
        cur_PageInfo.clear();
    }


}
function fnvshNrm(Lay){
    var tagName = document.getElementById(Lay);
    tagName.style.visibility = 'visible';
    tagName.style.display = 'block';
    show(Lay);
    puyoungJS_DialogBox.block();
}
function cancelForm(frm){window.history.back();}
function trim(str){
    if(str != '' && str != undefined){
        var s = str.replace(/\s+$/,'');
        s = s.replace(/^\s+/,'');
        return s;
    }
    return '';
}
function clear_form(form){
    for (j = 0; j < form.elements.length; j++){
        if (form.elements[j].type == 'text' || form.elements[j].type == 'select-one')
            form.elements[j].value = '';
    }
}
function ActivateCheckBox(){
    var map = document.getElementById("saved_map_checkbox");
    var source = document.getElementById("saved_source");
    if(map.checked == true){
        source.disabled = false;
    }else source.disabled = true;
}
function addOnloadEvent(a){getJsScript('include/js/ldcrm.base.js',function(){addOnloadEvent(a);});}
function InternalMailer(record_id,field_id,field_name,par_module,type) {
    var url;
    switch(type) {
        case 'record_id':
            url = 'index.php?module=Emails&action=EmailsAjax&internal_mailer=true&type='+type+'&field_id='+field_id+'&rec_id='+record_id+'&fieldname='+field_name+'&file=EditView&par_module='+par_module;//query string field_id added for listview-compose email issue
            break;
        case 'email_addy':
            url = 'index.php?module=Emails&action=EmailsAjax&internal_mailer=true&type='+type+'&email_addy='+record_id+'&file=EditView';
            break;
    }
    openPopUp('xComposeEmail',this,url,'createemailWin',830,662,"menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes");
}
function fnHide_Event(obj){document.getElementById(obj).style.visibility = 'hidden';}
function ReplyCompose(id,mode){
    var url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&record='+id+'&reply=true';
    openPopUp('xComposeEmail',this,url,'createemailWin',820,689,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
}
function OpenCompose(a,b){getJsScript('include/js/ldcrm.base.js',function(){OpenCompose(a,b);});}
function ShowEmail(id){
    url = 'index.php?module=Emails&action=EmailsAjax&file=DetailView&record='+id;
    openPopUp('xComposeEmail',this,url,'createemailWin',820,695,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
}
var bSaf = (navigator.userAgent.indexOf('Safari') != -1);
var bOpera = (navigator.userAgent.indexOf('Opera') != -1);
var bMoz = (navigator.appName == 'Netscape');
function execJS(a){getJsScript('include/js/ldcrm.base.js',function(){execJSs(a);});}
function fnLoadCvValues(a,b,c,d){getJsScript('include/js/ldcrm.base.js',function(){fnLoadCvValuess(a,b,c,d);});}
function fnDropDown(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){fnDropDowns(a,b,c);});}
function fnShowDrop(obj){
    if(document.getElementById(obj)!=undefined)
        document.getElementById(obj).style.display = 'block';
}
function fnHideDrop(obj){
    if(document.getElementById(obj)!=undefined)
        document.getElementById(obj).style.display = 'none';
}
function _2digit( no ){
    if(no < 10) return "0" + no;
    else return "" + no;
}
//function modified to apply the patch ref : Ticket #4065
function valid(c,type){
    if(type == 'name'){
        return (((c >= 'a') && (c <= 'z')) ||((c >= 'A') && (c <= 'Z')) ||((c >= '0') && (c <= '9')) || (c == '.') || (c == '_') || (c == '-') || (c == '@') );
    }else if(type == 'namespace'){
        return (((c >= 'a') && (c <= 'z')) ||((c >= 'A') && (c <= 'Z')) ||((c >= '0') && (c <= '9')) || (c == '.')||(c==' ') || (c == '_') || (c == '-') );
    }
}
function CharValidation(s,type){
    for (var i = 0; i < s.length; i++){
        if (!valid(s.charAt(i),type))
            return false;
    }
    return true;
}
/** Check Upload file is in specified format(extension).
 * @param fldName -- name of the file field
 * @param filter -- List of file extensions to allow. each extension must be seperated with a | sybmol.
 * Example: upload_filter("imagename","Image", "jpg|gif|bmp|png")
 * @returns true -- if the extension is IN  specified extension.
 * @returns false -- if the extension is NOT IN specified extension.
 *
 * NOTE: If this field is mandatory,  please call emptyCheck() function before calling this function.
 */

function upload_filter(fldName, filter)
{

    var currObj=getObj(fldName)
    if(currObj==undefined){
        return true;
    }
    if(currObj.value !="")
    {
        var file=currObj.value;
        var type=file.toLowerCase().split(".");
        var valid_extn=filter.toLowerCase().split("|");

        if(valid_extn.indexOf(type[type.length-1]) == -1)
        {
            var confirm_str = arrJsPopLabel['PLEASESELECTFOLLOWINGEXTENSIONS']+'\n'+valid_extn;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            try {
                currObj.focus()
            } catch(error) {
                // Fix for IE: If element or its wrapper around it is hidden, setting focus will fail
                // So using the try { } catch(error) { }
            }
            return false;
        }
    }
    return true

}
//function upload_filter(a,b){getJsScript('include/js/ldcrm.base.js',function(){upload_filters(a,b);});}
//执行验证函数去除用户输入网址的http或者mailto2
function validateUrl(a){getJsScript('include/js/ldcrm.base.js',function(){validateUrls(a);});}
function LTrim( value ){var re = /\s*((\S+\s*)*)/;return value.replace(re, "$1");}
function selectedRecords(a,b){getJsScript('include/js/ldcrm.core.js',function(){selectedRecordss(a,b);});}
function expoer_account(a,b,c,d){getJsScript('include/js/ldcrm.core.js',function(){expoer_accounts(a,b,c,d);});}
function record_export(a,b,c,d){getJsScript('include/js/ldcrm.core.js',function(){record_exports(a,b,c,d);});}
function setMsg(){
    var exportrealcount=exportcount;
    if(exportcount.toLowerCase().indexOf('details')>0)
    {
        var spcount=exportcount.split('details');
        exportrealcount=spcount[0];
    }
    var mun=Math.ceil(exportrealcount/200);
    if(exportNUm<=mun){
        openNewDivExport('newDiv',exportcount,exportNUm,'export');
        exportNUm++;
        setTimeout(setMsg,10*300);
    }
}
function hideErrorMsg1(){$('not_search').style.display = 'none';}
function escapeAll(tagValue){return encodeURIComponent(tagValue.replace(/%/g, '%25'));}
function removeHTMLFormatting(str) {
    str = str.replace(/<([^<>]*)>/g, " ");
    str = str.replace(/&nbsp;/g, " ");
    return str;
}
function get_converted_html(str){
    var temp = str.toLowerCase();
    if(temp.indexOf('<') != '-1' || temp.indexOf('>') != '-1'){
        str = str.replace(/</g,'&lt;');
        str = str.replace(/>/g,'&gt;');
    }
    if( temp.match(/(script).*(\/script)/))
        str = str.replace(/&/g,'&amp;');
    else if(temp.indexOf('&') != '-1')
        str = str.replace(/&/g,'&amp;');
    return str;
}
function default_togglestate(a,b){getJsScript('include/js/ldcrm.base.js',function(){default_togglestates(a,b);});}
function clear_checked_all(a){getJsScript('include/js/ldcrm.base.js',function(){clear_checked_alls(a);});}
function gotourl(url){document.location.href=url;}
//function toggleShowHide(a,b){getJsScript('include/js/ldcrm.base.js',function(){toggleShowHides(a,b);});}
function toggleShowHide(a,b){getJsScript('include/js/ldcrm.base.js',function(){fnvshobj(b,a);});}
function MoreCurrencytoggleShowHide(a,b,c){getJsScript('include/js/ldcrm.base.js',function(){MoreCurrencytoggleShowHides(a,b,c);});}
function getTianyanByKeyWord(a,b,c,d){getJsScript('include/js/tianyancha.js',function(){getTianyanByKeyWords(a,b,c,d);});}
function getTianyanSearchInfo(a,b,c,d){getJsScript('include/js/tianyancha.js',function(){getTianyanSearchInfos(a,b,c,d);});}
function getTianyanByKeyWordForInfo(a,b){getJsScript('include/js/tianyancha.js',function(){getTianyanByKeyWordForInfos(a,b);});}
function MoreCurrencySetPopup(base_currency,fldname)
{
    //产品更多币种设置

    var popupobj=CrmPopup.getPopupObj("last");



    var divid=popupobj.divid;
    if(popupobj.type==PageRecordPopup.type)
    {
        var id=popupobj.record;
    }
    else
    {
        var id=0;
    }
    var base_currency_value=CrmPopup.findHtmlobj(divid,fldname).val();

    ld.ajax({
        url: 'index.php?module=Products&action=ProductsAjax&file=MoreCurrencySet&fldname='+fldname+"&productid="+id+"&base_currency_value="+base_currency_value,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 5000,

        success: function(data)
        {
            if(data.code==1)
            {

                ld('#rptContentLoading').hide();
                var jspopup=[];
                jspopup.push('multiple_currencies');
                jspopup.push(fldname+'_currency_class');
                jspopup.push(fldname);
                var module='Products';
                var QcPopupobj=CrmPopup.load(data.result.title,MoreCurrencytoggleShowHide,"","LdPopWidth800px",module,jspopup,data.result.oktext,"",data.result.canceltext);

                jspopup.push(document.getElementById(QcPopupobj.divid+"_btnok"));

                jspopup.push(module);
                QcPopupobj.show(data.result.content);
                var curpopup=CrmPopup.getPopupObj("last");
                var curdivid=curpopup.divid;
                var hiddens=ld("#"+curdivid).find("[name=base_currency_curid]");
                var price_type=fldname;
                //zkt 20230609 BUG0066978 官网下载的8502最新版安装包-产品管理-新建-点击更多币种-价格字段小数位数不显示，点击重算价格后小数位数才会出现
                var price_decimal = 2;
                if(CrmPopup.isExistsObj(curdivid,'price_decimal')){
                    price_decimal = CrmPopup.findHtmlobj(divid,'price_decimal').val();
                }

                for(var i=0;i<hiddens.length;i++)
                {
                    var hiddenobj=hiddens[i];

                    CrmPopup.findHtmlobj(curdivid,price_type+"_cur_"+hiddenobj.value+"_check").prop("checked", CrmPopup.findHtmlobj(divid,price_type+"_cur_"+hiddenobj.value+"_check").prop("checked"));
                    //BUG0069027 xxy 2023-7-19 对读取的val用Number转为数字型再toFixed 产品管理，“产品报价”和“参考成本价”字段，勾选更多币种弹窗中的其他币种保存后，勾选其他币种没有保存上
                    CrmPopup.findHtmlobj(curdivid,price_type+"_curname"+hiddenobj.value).val(Number(CrmPopup.findHtmlobj(divid,price_type+"_curname"+hiddenobj.value).val()).toFixed(price_decimal));
                    if(CrmPopup.findHtmlobj(curdivid,price_type+"_cur_"+hiddenobj.value+"_check").prop("checked"))
                    {
                        CrmPopup.findHtmlobj(curdivid,price_type+"_curname"+hiddenobj.value).attr("disabled",false);
                    }
                    CrmPopup.findHtmlobj(curdivid,price_type+"_cur_conv_rate"+hiddenobj.value).val(CrmPopup.findHtmlobj(divid,price_type+"_cur_conv_rate"+hiddenobj.value).val());

                }
                // wym 230804 BUG0070468 kfbcrm-产品管理-批量编辑产品价格信息-点击更多币种-其他币种价格没有小数位数，点击重算价格后才会有小数位数
                //因为更多币种弹窗固定有人民币的重算价格按钮，所以这里写死了name
                if(CrmPopup.findHtmlobj(curdivid,"cur_reset1").length>0){
                    CrmPopup.findHtmlobj(curdivid,"cur_reset1").click();
                }
            }

        }
    });
}
/**
 edit:can
 reason:产品编辑界面更多币种弹出框隐藏和显示
 **/
function fnshowHide(currObj,txtObj) {
    var popupobj=CrmPopup.getPopupObj("last");//BUG0065480 选产品分录界面快速创建产品时，增值税字段的id和分录id冲突了
    if(currObj.checked == true)
        ld("#"+popupobj.divid+" #"+txtObj).css("visibility","visible");
    else
        ld("#"+popupobj.divid+" #"+txtObj).css("visibility","hidden");
}
/**
 *edit:kevin
 *date:2013-05-30
 *reason:4050
 numValidate(txtObj,'Tax',"any")
 */
function fntaxValidation(txtObj) {
    if (!numValidate(txtObj,arrJsPopLabel['SURTAXESSALESSERVICE'],"any"))
        document.getElementById(txtObj).value = 0;
}
function fnpriceValidation(txtObj) {
    if (!numValidate(txtObj,"Price","any"))
        document.getElementById(txtObj).value = 0;
}
// Function to enable/disable related elements based on whether the current object is checked or not
function fnenableDisable(currObj,enableId,price_type) {
    var disable_flag = true;
    if(currObj.checked == true)
        disable_flag = false;

    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;

    CrmPopup.findHtmlobj(divid,price_type+'_curname'+enableId).attr("disabled",disable_flag);
//	document.getElementById(price_type+'_curname'+enableId).disabled = disable_flag;
}
function updateCurrencyValue(a,b,c,d){getJsScript('include/js/ldcrm.core.js',function(){updateCurrencyValues(a,b,c,d);});}
function resetCurrencyValue(a,b,c,d){getJsScript('include/js/ldcrm.core.js',function(){resetCurrencyValues(a,b,c,d);});}
function updateUnitPrice(from_cur_id, to_cur_id) {
    var from_ele = document.getElementById(from_cur_id);
    if (from_ele == null) return;
    var to_ele = document.getElementById(to_cur_id);
    if (to_ele == null) return;
    to_ele.value = from_ele.value;
}
function updateBaseCurrencyValue(a){getJsScript('include/js/ldcrm.core.js',function(){updateBaseCurrencyValues(a);});}
/******************************************************************************/
/* Activity reminder Customization: Setup Callback */
function ActivityReminderProgressIndicator(show) {
    if(show) $("status").style.display = "inline";
    else $("status").style.display = "none";
}
function ActivityReminderPostponeCallback(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){ActivityReminderPostponeCallbacks(a,b,c);});}
function ActivityReminderPostponeCallbackProcess(message) {ActivityReminderProgressIndicator(false);}
function ActivityReminderRemovePopupDOM(id) {if($(id)) $(id).remove();}
/* END */
/* ActivityReminder Customization: Pool Callback */
var ActivityReminder_regcallback_timer;
var ActivityReminder_callback_delay = 4000 * 1000; // Milli Seconds
var ActivityReminder_autohide = false; // If the popup should auto hide after callback_delay?
var ActivityReminder_popup_maxheight = 75;
var ActivityReminder_callback;
var ActivityReminder_timer;
var ActivityReminder_progressive_height = 2; // px
var ActivityReminder_popup_onscreen = 2 * 1000; // Milli Seconds (should be less than ActivityReminder_callback_delay)
var ActivityReminder_callback_win_uniqueids = new Object();
function ActivityReminderCallback() {

    if(typeof(Ajax) == 'undefined') return;
    if(ActivityReminder_regcallback_timer) {
        window.clearTimeout(ActivityReminder_regcallback_timer);
        ActivityReminder_regcallback_timer = null;
    }

    //editor:gyq_161缓存 reason:带分录模块弹出层   2019/11/14 10:00
    //弹出框提醒
    //CrmPopup.start_progressObjs.push(new Object());
    ldAjaxHtmlNoProgress('index.php?','module=Reminds&action=RemindsAjax&file=RemindsPopup&ajax=true',function(rest){
        if(rest=='#LoginUSERERROR#'){
            window.location="index.php";
            return false;
        }

        //  alert('wwww');
        ActivityReminderCallbackProcessg(rest);
        //  DelProgressObjs();
    });
    //邮件提醒
    // CrmPopup.start_progressObjs.push(new Object());
    ldAjaxHtmlNoProgress('index.php?module=Reminds&action=RemindsAjax&file=RemindsEmail&ajax=true',{},function(rest){
        if(rest=='#LoginUSERERROR#'){
            window.location="index.php";
            return false;
        }

        //    DelProgressObjs();
    });
}
function ActivityReminderCallbackProcessg(a,isReminds_popupexist){getJsScript('include/js/ldcrm.core.js',function(){ActivityReminderCallbackProcesss(a,isReminds_popupexist);});}
function ActivityReminderCallbackRollout(a,b){getJsScript('include/js/ldcrm.core.js',function(){ActivityReminderCallbackRollouts(a,b);});}
function ActivityReminderCallbackRollin(a,b){getJsScript('include/js/ldcrm.core.js',function(){ActivityReminderCallbackRollins(a,b);});}
function ActivityReminderCallbackReset(a,b){getJsScript('include/js/ldcrm.core.js',function(){ActivityReminderCallbackResets(a,b);});}
function ActivityReminderRegisterCallback(timeout) {
    //if(timeout == null) timeout = 1;
//
//    if(ActivityReminder_regcallback_timer == null){
//        ActivityReminder_regcallback_timer = setTimeout("ActivityReminderCallback()", timeout);
//    }
}
//added for finding duplicates
function selectedColClick(oSel){
    if (oSel.selectedIndex == -1 || oSel.options[oSel.selectedIndex].disabled == true){
        var confirm_str = arrJsPopLabel['FIELDDOSENOTALLOWEDIT'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        oSel.options[oSel.selectedIndex].selected = false;
    }
}
function delete_fields(a){getJsScript('include/js/ldcrm.core.js',function(){delete_fieldss(a);});}
function validate_merge(a){getJsScript('include/js/ldcrm.core.js',function(){validate_merges(a);});}
function select_All(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){select_Alls(a,b,c);});}
function selectAllDel(state,checkedName){
    var selectedOptions=document.getElementsByName(checkedName);
    var length=document.getElementsByName(checkedName).length;
    if(typeof(length) == 'undefined') return false;
    for(var i=0;i<length;i++){
        selectedOptions[i].checked=state;
    }
}
function selectDel(a,b){getJsScript('include/js/ldcrm.core.js',function(){selectDels(a,b);});}
function getDuplicateListViewEntries_js(a,b){getJsScript('include/js/ldcrm.core.js',function(){getDuplicateListViewEntries_jss(a,b);});}

function positionDivToCenter(targetDiv){
    getViewPortDimension();
    divWidth =(parseInt(document.getElementById(targetDiv).style.width))/2;
    divHeight=(parseInt(document.getElementById(targetDiv).style.height))/2;
    mx = parseInt(XX/2)-parseInt(divWidth);
    my = parseInt(YY/3)-parseInt(divHeight);
    document.getElementById(targetDiv).style.left=mx+"px";
    document.getElementById(targetDiv).style.top=my+"px";
}
function getViewPortDimension(){
    if(!document.all){
        XX = self.innerWidth;
        YY = self.innerHeight;
    }else if(document.all){
        XX = document.documentElement.clientWidth;
        YY = document.documentElement.clientHeight;
    }
}
function toggleTable(id) {
    var listTableObj=getObj(id);
    if(listTableObj.style.display=="none")
        listTableObj.style.display="";
    else
        listTableObj.style.display="none";
}
function FileAdd(obj,Lay,return_action){
    fnvshobj(obj,Lay);
    window.frames['AddFile'].document.getElementById('divHeader').innerHTML="Add file";
    window.frames['AddFile'].document.FileAdd.return_action.value=return_action;
    positionDivToCenter(Lay);
}
function dldCntIncrease(fileid){
    EmptyProgressObjs();

    ldAjaxsyncNoProgress('index.php?action=DocumentsAjax&mode=ajax&file=SaveFile&module=Documents&file_id='+fileid+'&act=updateDldCnt','',function(){
        DelProgressObjs();
    });
}
function placeAtCenter(id){
    var centerPixel = getViewPortCenter();
    document.getElementById(id).style.position = "absolute";
    var point = getDimension(id);
    var topvalue = (centerPixel.y - point.y/2) ;
    var rightvalue = (centerPixel.x - point.x/2);
    if(topvalue<0) topvalue = 0;
    if(rightvalue < 0) rightvalue = 0;
    if(topvalue<80)
        document.getElementById(id).style.top = topvalue  + "px";
    else
        document.getElementById(id).style.top = topvalue - 80 + "px";
    document.getElementById(id).style.right =rightvalue + 250 + "px";
}

/**
 * this function gets the dimension of a node
 * @param node - the node whose dimension you want
 * @return height and width in array format
 */
function getDimension(id){
    if(document.getElementById(id)==undefined) return;
    var ht = document.getElementById(id).offsetHeight;
    var wdth = document.getElementById(id).offsetWidth;
    var nodeChildren = document.getElementById(id).getElementsByTagName("*");
    //var nodeChildren = 1;
    var noOfChildren = nodeChildren.length;
    for(var index =0;index<noOfChildren;++index){
        ht = Math.max(nodeChildren[index].offsetHeight, ht);
        wdth = Math.max(nodeChildren[index].offsetWidth,wdth);
    }
    return {
        x: wdth,
        y: ht
    };
}
function getViewPortCenter(){getJsScript('include/js/ldcrm.base.js',function(){getViewPortCenters();});}
function startCall(jqueryobj){getJsScript('include/js/ldcrm.base.js',function(){startCalls(jqueryobj);});}
function ToolTipManagers(){getJsScript('include/js/ldcrm.base.js',function(){ToolTipManager();});}
if(!tooltip){ var tooltip = ToolTipManagers();}
function submitFormForActionWithConfirmation(a,b,c){getJsScript('include/js/ldcrm.base.js',function(){submitFormForActionWithConfirmations(a,b,c);});}
/*
who:BY LD CAN
Date:20130118
reason:鎵€鏈夋槑缁嗙晫闈㈠鍔犺繑鍥炲垪琛ㄥ拰鏂板鎸夐挳
*/
function NewInfo(event,module,parenttab){
    var url = "index.php?module="+module+"&action=EditView&return_action=DetailView&parenttab="+parenttab;
    url = cls_encryptyurl.Puyoung_Encryptyurl(url,'');
    window.location=url;
}
function submitFormForAction(a,b){getJsScript('include/js/ldcrm.core.js',function(){submitFormForActions(a,b);});}
/** Javascript dialog box utility functions **/
puyoungJS_DialogBox = {
    _olayer : function(toggle) {
        var olayerid = "__puyoungjs_dialogbox_olayer__";
        puyoungJS_DialogBox._removebyid(olayerid);
        if(typeof(toggle) == 'undefined' || !toggle) return;
        var olayer = document.getElementById(olayerid);
        if(!olayer) {
            olayer = document.createElement("div");
            olayer.id = olayerid;
            olayer.className = "small veil veil_p";
            olayer.style.zIndex = 1;
            if(olayer.style.zIndex < 0) olayer.style.zIndex *= -1;
            if (browser_ie) {
                olayer.style.height = document.body.offsetHeight + (document.body.scrollHeight - document.body.offsetHeight) + "px";
            } else if (browser_nn4 || browser_nn6) {
                olayer.style.height = document.body.offsetHeight + "px";
            }
            olayer.style.width = "100%";
            olayer.style.height = "100%";
            document.body.appendChild(olayer);
        }
        if(olayer) {
            olayer.style.zIndex = 1001;
            if(toggle) olayer.style.display = "block";
            else olayer.style.display = "none";
        }
        return olayer;
    },
    _removebyid : function(id) {
        if($(id)) $(id).remove();
    },
    unblock : function() {
        if(document.getElementById("layer"))
        {
            var layer=document.getElementById('layer');
            layer.style.display="none";
            document.body.removeChild(layer);
        }
        if(document.getElementById("olayernodeid"))
        {
            var olayer=document.getElementById("olayernodeid");
            olayer.style.display = "none";
            document.body.removeChild(olayer);
        }
    },
    block : function(opacity) {
        if(!document.getElementById("layer")&&!document.getElementById("olayernodeid")){
            if(typeof(opactiy)=='undefined') opacity = '0.5';
            var olayernode = puyoungJS_DialogBox._olayer(true);
            olayernode.id="olayernodeid";
            olayernode.className = 'mask opacity';
            olayernode.style.opacity = opacity;
        }
    },
    hideprogress : function() {
        puyoungJS_DialogBox._olayer(false);
        puyoungJS_DialogBox._removebyid('__puyoungjs_dialogbox_progress_id__');
    },
    progress : function(imgurl) {
        puyoungJS_DialogBox._olayer(true);
        if(typeof(imgurl) == 'undefined') imgurl = 'themes/images/plsWaitAnimated.gif';
        var prgbxid = "__puyoungjs_dialogbox_progress_id__";
        var prgnode = document.getElementById(prgbxid);
        if(!prgnode) {
            prgnode = document.createElement("div");
            prgnode.id = prgbxid;
            prgnode.className = 'veil_new';
            prgnode.style.position = 'absolute';
            prgnode.style.width = '100%';
            prgnode.style.top = '0';
            prgnode.style.left = '0';
            prgnode.style.display = 'block';
            document.body.appendChild(prgnode);
            prgnode.innerHTML =
                '<table border="0" cellpadding="0" cellspacing="0" align="center" style="vertical-align:middle;width:100%;height:100%;">' +
                '<tr><td class="big" align="center"><img src="'+ imgurl + '"></td></tr></table>';
        }
        if(prgnode) prgnode.style.display = 'block';
    },
    hideconfirm : function() {
        puyoungJS_DialogBox._olayer(false);
        puyoungJS_DialogBox._removebyid('__puyoungjs_dialogbox_alert_boxid__');
    },
    confirm : function(msg, onyescode) {
        puyoungJS_DialogBox._olayer(true);

        var dlgbxid = "__puyoungjs_dialogbox_alert_boxid__";
        var dlgbxnode = document.getElementById(dlgbxid);
        if(!dlgbxnode) {
            dlgbxnode = document.createElement("div");
            dlgbxnode.style.display = 'none';
            dlgbxnode.className = 'veil_new small';
            dlgbxnode.id = dlgbxid;
            dlgbxnode.innerHTML =
                '<table cellspacing="0" cellpadding="18" border="0" class="options small">' +
                '<tbody>' +
                '<tr>' +
                '<td nowrap="" align="center" style="color: rgb(255, 255, 255); font-size: 15px;">' +
                '<b>'+ msg + '</b></td>' +
                '</tr>' +
                '<tr>' +
                '<td align="center">' +
                '<input type="button" style="text-transform: capitalize;" onclick="$(\''+ dlgbxid + '\').hide();puyoungJS_DialogBox._olayer(false);puyoungJS_DialogBox._confirm_handler();" value="'+ arrJsPopLabel['YES'] + '"/>' +
                '<input type="button" style="text-transform: capitalize;" onclick="$(\''+ dlgbxid + '\').hide();puyoungJS_DialogBox._olayer(false)" value="' + arrJsPopLabel['NO'] + '"/>' +
                '</td>'+
                '</tr>' +
                '</tbody>' +
                '</table>';
            document.body.appendChild(dlgbxnode);
        }
        if(typeof(onyescode) == 'undefined') onyescode = '';
        dlgbxnode._onyescode = onyescode;
        if(dlgbxnode) dlgbxnode.style.display = 'block';
    },
    _confirm_handler : function() {
        var dlgbxid = "__puyoungjs_dialogbox_alert_boxid__";
        var dlgbxnode = document.getElementById(dlgbxid);
        if(dlgbxnode) {
            if(typeof(dlgbxnode._onyescode) != 'undefined' && dlgbxnode._onyescode != '') {
                eval(dlgbxnode._onyescode);
            }
        }
    }
}
//function re_dateValidate(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){re_dateValidates(a,b,c);});}
function re_dateValidate(fldval,fldLabel,type) {
    if(re_patternValidate(fldval,fldLabel,"DATE")==false)
        return false;
    dateval=fldval.replace(/^\s+/g, '').replace(/\s+$/g, '')

    var dateelements=splitDateVal(dateval)

    dd=dateelements[0]
    mm=dateelements[1]
    yyyy=dateelements[2]

    if (dd<1 || dd>31 || mm<1 || mm>12 || yyyy<1 || yyyy<1000) {
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false
    }

    if ((mm==2) && (dd>29)) {//checking of no. of days in february month
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false
    }

    if ((mm==2) && (dd>28) && ((yyyy%4)!=0)) {//leap year checking
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false
    }

    switch (parseInt(mm)) {
        case 2 :
        case 4 :
        case 6 :
        case 9 :
        case 11 :
            if (dd>30) {
                var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false
            }
    }

    var currdate=new Date()
    var chkdate=new Date()

    chkdate.setYear(yyyy)
    chkdate.setMonth(mm-1)
    chkdate.setDate(dd)

    if (type!="OTH") {
        if (!compareDates(chkdate,fldLabel,currdate,arrJsPopLabel['CURRENTDATE'],type)) {
            return false
        } else return true;
    } else return true;
}
//function re_patternValidate(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){re_patternValidates(a,b,c);});}
function re_patternValidate(fldval,fldLabel,type) {

    if (type.toUpperCase()=="EMAIL") {
        /*changes made to fix -- ticket#3278 & ticket#3461
		  var re=new RegExp(/^.+@.+\..+$/)*/
        //Changes made to fix tickets #4633, #5111  to accomodate all possible email formats
        var re=new RegExp(/^[a-zA-Z0-9]+([\_\-\.]*[a-zA-Z0-9]+[\_\-]?)*@[a-zA-Z0-9]+([\_\-]?[a-zA-Z0-9]+)*\.+([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)*$/)
    }

    if (type.toUpperCase()=="DATE") {//DATE validation



        var re = /^\d{4}(-)\d{1,2}\1\d{1,2}$/

    }


    if (type.toUpperCase()=="TIMESECONDS") {//TIME validation
        var re = new RegExp("^([0-1][0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9])$|^([0-1][0-9]|[2][0-3]):([0-5][0-9])$");
    }
    if (!re.test(fldval)) {
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false
    }
    else return true
}
function copySelectedOptionss(source, destination) {

    var srcObj =document.getElementById(source);// $(source);
    var destObj =document.getElementById(destination);// $(destination);

    if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    /**
     *AUTHOR:BY LD KEVIN
     *DATE:20130326
     *DESPRITION:bug3591
     */
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    for (i=0;i<srcObj.length;i++) {
        if (srcObj.options[i].selected==true) {
            var rowFound=false;
            var existingObj=null;
            for (j=0;j<destObj.length;j++) {
                if (destObj.options[j].value==srcObj.options[i].value) {
                    rowFound=true
                    existingObj=destObj.options[j]
                    break
                }
            }

            if (rowFound!=true) {
                var newColObj=document.createElement("OPTION")
                newColObj.value=srcObj.options[i].value
                if (browser_ie) newColObj.innerText=srcObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=srcObj.options[i].text
                destObj.appendChild(newColObj)
                srcObj.options[i].selected=false
                //srcObj.options.remove(i);//20140902，diony，右移时删除左边信息
                //i=-1;//20140902，diony，右移时删除左边信息，i=-1应该是让循环开始
                newColObj.selected=true
                rowFound=false
            } else {
                if(existingObj != null) existingObj.selected=true
            }
        }
    }
}
function getTranslatedString(key, alertArray){
    if(alertArray != undefined) {
        if(alertArray[key] != undefined)
            return alertArray[key];
    }
    if(alert_arr[key] != undefined) {
        return alert_arr[key];
    }else return key;
}
function copySelectedOptions(a,b){getJsScript('include/js/ldcrm.core.js',function(){copySelectedOptionss(a,b);});}
function removeSelectedOptions(objName) {
    var obj = getObj(objName);
    if(obj == null || typeof(obj) == 'undefined') return;
    for (i=obj.options.length-1;i>=0;i--) {
        if (obj.options[i].selected == true)
            obj.options[i] = null;
    }
}
function convertOptionsToJSONArray(objName,targetObjName) {
    var obj = $(objName);
    var arr = [];
    if(typeof(obj) != 'undefined') {
        for (i=0; i<obj.options.length; ++i) {
            arr.push(obj.options[i].value);
        }
    }
    if(targetObjName != 'undefined') {
        var targetObj = $(targetObjName);
        if(typeof(targetObj) != 'undefined') targetObj.value = JSON.stringify(arr);
    }
    return arr;
}
function fnvshobjMore(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){fnvshobjMores(a,b,c);});}
function getNoOfRows(a){getJsScript('include/js/ldcrm.core.js',function(){getNoOfRowss(a);});}
function getNoOfRelatedRows(current_module,related_module){
    var recordid = document.getElementById('recordid').value;
    var urlstring = "module="+current_module+"&related_module="+related_module+"&action="+current_module+"Ajax&idlist="+recordid+"&file=ListViewCount&mode=relatedlist";
    ldAjaxHtmlNoProgress('index.php?',urlstring,function(response) {
        $(current_module+'_'+related_module+'_numOfRows').value = response.responseText;
        $(related_module+'_count').innerHTML = response.responseText;
        if(parseInt($('maxrecords').value) < parseInt(response.responseText)){
            $(current_module+'_'+related_module+'_linkForSelectAll').show();
        }
    });
}
function updateParentCheckbox(obj,id){
    var parentCheck=true;
    if (obj) {
        for (var i=0; i<obj.length; ++i) {
            if(obj[i].checked != true){
                var parentCheck=false;
            }
        }
    }
    if(parentCheck){
        $(id+'_selectCurrentPageRec').checked=parentCheck;
    }
}

function showSelectAllLink(obj,exculdedArray){
    var viewForSelectLink = true;
    for (var i=0; i<obj.length; ++i) {
        obj[i].checked = true;
        for(var j=0; j<exculdedArray.length; ++j) {
            if(exculdedArray[j] == obj[i].value) {
                obj[i].checked = false;
                viewForSelectLink = false;
            }
        }
    }
    return viewForSelectLink;
}
/**
 *@author:chj
 *@data:2015/4/20
 *@reason:批量操作时记录数上限
 *@version:V6.0 权限角色改进
 */
function getMaxMassOperationLimit() {
    if(document.getElementById('batchnum') != undefined){
        return document.getElementById('batchnum').value;
    }
    return 500;
}

function getviewId()
{
    if(document.getElementById("viewname") != null && typeof(document.getElementById("viewname")) != 'undefined') {
        var oViewname = document.getElementById("viewname");
        var viewid = oViewname.value;
    } else {
        var viewid = '';
    }
    return viewid;
}


function addListener(element, e, fn) {
    if (element.addEventListener) {
        element.addEventListener(e, fn, false);
    } else {
        element.attachEvent("on" + e, fn);
    }
}
function BodyClick(obj,lay){
    addListener(document, "click",
        function(evt) {
            var evt = window.event ? window.event: evt,
                target = evt.srcElement || evt.target;

            if (target == obj||target.id == lay||target.parentNode==undefined) {
                document.getElementById(lay).style.display = "";
                document.getElementById(lay).style.zIndex=1;
                return;
            } else {
                while (target.nodeName.toLowerCase()) {
                    target = target.parentNode;
                    if(target==undefined)
                    {
                        document.getElementById(lay).style.display="";
                        return ;
                    }
                    if (target== obj||target.id == lay) {
                        document.getElementById(lay).style.display = "";
                        return;
                    }
                    if (target.nodeName.toLowerCase() == "body") {
                        document.getElementById(lay).style.display = "none";
                        return;
                    }
                }
            }
        });
}

function fn_display_div(){
    obj=document.getElementById('reminds_popup');
    if(obj!=undefined)
        obj.style.display='';
    if(ld('#reminds_popup_expansion') != undefined){
        ld('#reminds_popup_expansion').hide();
    }
}
function fn_close_div(){
    obj=document.getElementById('reminds_popup');
    if(obj!=undefined)
        obj.style.display='none';
    if(ld('#reminds_popup_expansion') != undefined){
        // ld('#reminds_popup_expansion').show();
    }
}
//wyt 220921 BUG0056552 首页-消息提醒，展开之后，没有收起的按钮
function fn_folded_div(){
    obj=document.getElementById('reminds_popup');
    if(obj!=undefined)
        obj.style.display='none';
    if(ld('#reminds_popup_expansion') != undefined){
        ld('#reminds_popup_expansion').show();
    }
}


function getDigital(num){
    if(num<10){
        num='0'+num;
    }
    return num;
}

function findPopX(obj)
{
    var curleft = 0;
    if (document.getElementById || document.all) {
        while (obj.offsetParent && obj.offsetParent.id!="qcform") { curleft += obj.offsetLeft; obj = obj.offsetParent;}
    }
    else if (document.layers) { curleft += obj.x; }
    return curleft;
}

function findPopY(obj)
{
    var curtop = 0;
    if (document.getElementById || document.all) {
        while (obj.offsetParent && obj.offsetParent.id!="qcform") { curtop += obj.offsetTop; obj = obj.offsetParent;}
    }
    else if (document.layers) { curtop += obj.Y; }
    return curtop;

}
/**
 *edit:kevin
 *date:2013-07-08
 reason:价格表选择产品时用到
 */
function toggleSelectAll(relCheckName,selectAllName,sel_id) {
    var popupobj=CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    var checkboxnum =  ld("#"+popupobj.divid+" [name=selected_id]").length;
    var selectedbox = ld("#"+popupobj.divid+" [name=selected_id]");
    if(checkboxnum > 0){
        var resetclass_arr = [];//zkt 防止已经被添加过的内容循环中多次添加
        for(var i = 0; i < checkboxnum; i++){
            if(selectedbox[i].checked == true){
                ld(selectedbox[i]).addClass('tb-checkbox-selected');
                //zkt 20220929 BUG0055571如图，新建合同产品分录选产品套餐时只有第一个产品被选中显示蓝色，
                var selectedtrobj = ld(selectedbox[i]).parent().parent();
                var selectedtrid = ld(selectedtrobj).attr('id');
                var selectedtridarr = selectedtrid.split(',');
                if(resetclass_arr.includes(selectedtridarr[0])){
                    continue;
                }
                resetclass_arr.push(selectedtridarr[0]);
                var selectedtrobjs = ld('#'+divid+' tr[id^="'+selectedtridarr[0]+',"]');
                if(ld(selectedtrobjs).length<=0||ld(selectedtrobjs.get(1)).find(" [name=selected_id]").length>=0){
                    ld(selectedtrobj).attr('class','lvtColDataSelected');
                }
                else{
                    //tr没有复选框时需要给单据对应的所有tr添加对应calss
                    ld.each(ld('#'+divid+' tr[id^="'+selectedtridarr[0]+',"]'),function(){
                        ld(this).attr('class','lvtColDataSelected');
                    });
                }
            }
            else{
                ld(selectedbox[i]).removeClass('tb-checkbox-selected');
                var selectedtrobj = ld(selectedbox[i]).parent().parent();
                var selectedtrid = ld(selectedtrobj).attr('id');
                var selectedtridarr = selectedtrid.split(',');
                if(resetclass_arr.includes(selectedtridarr[0])){
                    continue;
                }
                resetclass_arr.push(selectedtridarr[0]);
                var tmpclass = 'lvtColDataBj';
                if((i+1)%2==1){
                    tmpclass = 'lvtColData';
                }
                var selectedtrobjs = ld('#'+divid+' tr[id^="'+selectedtridarr[0]+',"]');
                if(ld(selectedtrobjs).length<=0||ld(selectedtrobjs.get(1)).find(" [name=selected_id]").length>=0){
                    ld(selectedtrobj).attr('class',tmpclass);
                }
                else{
                    //tr没有复选框时需要给单据对应的所有tr添加对应calss
                    ld.each(ld('#'+divid+' tr[id^="'+selectedtridarr[0]+',"]'),function(){
                        ld(this).attr('class',tmpclass);
                    });
                }
            }
        }
    }
    if (typeof(getObj(relCheckName).length)=="undefined") {
        getObj(selectAllName).checked=getObj(relCheckName).checked
    } else {
        var atleastOneFalse=false;
        for (var i=0;i<getObj(relCheckName).length;i++) {
            if (getObj(relCheckName)[i].checked==false) {
                atleastOneFalse=true
                break;
            }
        }
        getObj(selectAllName).checked=!atleastOneFalse
    }
}
function toggleSelect(state,relCheckName) {
    var popupobj=CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    if (CrmPopup.findHtmlobj(divid,relCheckName) != undefined) {
        //editor:gyq_20200311 reason:全选的操作，需要排除disabled项
        // 0039003: (51mis.com/kfbcrm)合同订单>新建单据界面>点击“+”选择客户>弹出层点击“设置字段”按钮:全选“字段名”然后在取消全选会把“客户名称”也取消掉且无法勾选
        var checkList = CrmPopup.findHtmlobj(divid,relCheckName);
        if (typeof(checkList.length)=="undefined") {
            checkList.attr('checked',state);
            //getObj(relCheckName).checked=state
        } else {
            checkList.each(function(){
                //此处如果用attr，会出现第三次失效的情况
                if(ld(this).attr("disabled") != 'disabled'){
                    ld(this).prop("checked",state);
                }
            });

        }
    }
    //BUG20240807-94 成员管理-设置普通成员可编辑的字段，当我里面点击全选的时候，后方列表会变色
    if (relCheckName == 'popup_selected_id'){
        return false;
    }
    if(state){
        //BUG20240807-94 成员管理-设置普通成员可编辑的字段，当我里面点击全选的时候，后方列表会变色
        if (relCheckName == 'selected_id'){
            ld('#'+divid+' input[name=selected_id]').parent().parent().attr('class','lvtColDataSelected');
        }
    }else{
        //BUG20240807-94 成员管理-设置普通成员可编辑的字段，当我里面点击全选的时候，后方列表会变色
        if (relCheckName == 'selected_id'){
            ld('#'+divid+' input[name=selected_id]').parent().parent().attr('class','lvtColDataBj');
        }
        var checkObj = document.getElementsByName(relCheckName);
        for(var i=0;i<checkObj.length;i++){
            var rows = "row_"+checkObj[i].value;
            if(document.getElementById(rows) != undefined){
                if((i+1)%2==1){
                    document.getElementById(rows).className = "lvtColData";
                }
                else{
                    document.getElementById(rows).className = "lvtColDataBj";
                }
            }
        }
    }
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj!=undefined &&popupobj.module=='Prdnums')
    {
        return true;
    }
    //027265: 市场活动>明细>相关信息>客户：选择客户，没有显示【全选所有N条记录】按钮。
    if(state==true&&document.getElementById("popup_cur_rows_count")!='undefined'&&document.getElementById("popup_cur_rows_count")!=undefined)
    {

        if(parseInt(document.getElementById('popup_cur_rows_count').value)<parseInt(document.getElementById('popup_num_rows').value))
        {
            if($('Popup_choose_linkForSelectAll')){
                $('Popup_choose_linkForSelectAll').show();
                $("Popup_choose_selectAllRec").show();
            }
        }

    }else{
        if($('Popup_choose_linkForSelectAll')){
            $('Popup_choose_linkForSelectAll').hide();
        }
        if($('Popup_choose_selectAllRec')){
            $('Popup_choose_selectAllRec').hide();
        }
    }
}
function Popup_choose_SelectAll_Records(module,checked,htmlid)
{
    //027265: 市场活动>明细>相关信息>客户：选择客户，没有显示【全选所有N条记录】按钮。
    if(checked==true)
    {
        ld("#Popup_choose_selectAllRec").hide();
        ld("#Popup_choose_deSelectAllRec").show();
        ld("#popup_rows_selectall").val("all");
    }
    else
    {
        ld("#Popup_choose_selectAllRec").hide();
        ld("#Popup_choose_deSelectAllRec").hide();
        ld("#Popup_choose_linkForSelectAll").hide();
        ld("#popup_rows_selectall").val("");
    }
}

function ViewfnDropDown(a,b){getJsScript('include/js/ldcrm.core.js',function(){ViewfnDropDown(a,b);});}
/**
 edit:kevin
 date:2013-09-10
 reason:弹出框位置计算
 */
function setPosition(obj,divid){
    oBtnObj = obj;
    var tagName = document.getElementById(divid);
    leftpos  = document.body.scrollLeft;
    toppos = document.body.scrollTop;
    aTag = oBtnObj;
    do{
        leftpos  += aTag.offsetLeft;
        toppos += aTag.offsetTop;
    } while(aTag = aTag.offsetParent);

    tagName.style.top= toppos + 20 + 'px';
    tagName.style.left= leftpos - 276 + 'px';
    tagName.style.display = 'block';
    tagName.style.visibility = "visible";
}
function getSelectedappove(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('username');
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+i);
                txt_obj=document.getElementById('txt_user_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=trim(txtobj_str);
        txtidobj.value=trim(txtidobj_str);
    }
}
function ExportTemplate(obj)
{
    var frm=document.forms['frmExport'];
    frm.submit();
}
function validateInputData(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){validateInputDatas(a,b,c);});}
function merge_fields(a,b,c){
    getJsScript('include/js/ldcrm.core.js',
        function(){
            //merge_fieldss(a,b,c);}   editor:gyq_72 reason:查重合并样式修改 date:20180705
            duplicate_check_merge_field(a,b,c);}
    );
}
/*
edit:can
date:20140402
reason:获取带变量的字符串（inventory.js用到该函数)
*/
function getThreeVarJsPop(labelbol,t0,t1,t2)
{
    var jspopinfo=arrJsPopLabel[labelbol];
    var res=jspopinfo.split('{Var}');
    jspopinfo=res[0]+t0+res[1]+t1+res[2]+t2;
    if(res.length>3)
    {
        jspopinfo+=res[3];
    }
    return jspopinfo;
}

/**
 * 弹出呼叫中心集成界面
 * @project 天润呼叫中心集成
 * @author Tujt 2014-05-14
 */
function OpenCallCenterInfo(){
    window.open("./CallCenter/index.php","CallCenter","width=1200,height=602,menubar=no,toolbar=no,location=no,status=no,resizable=no,scrollbars=yes");
}

/**
 * 调用天润工具条外呼接口，实现电话外呼
 * 如果非iframe嵌套情况下，则不执行任何操作
 * @project 天润呼叫中心集成
 * @param mobile Mobile(Integer) 外呼电话、手机号码
 * @returns 调用天润工具条外呼接口，实现电话外呼
 * @author Tujt 2014-05-15
 */
function CallCenterOut(mobile){
    if(window.frameElement != null){//ifame嵌套情况下
        window.parent.CallCenterOut(mobile);
    }
}

/**
 * 检查是否是iFrame嵌套页面，如果不是，则隐藏外呼图标
 * @project 天润呼叫中心集成
 * @author Tujt 2014-05-15
 */
function IsFrameElement(){


    if(ld(' .callcenterImg').length > 0){//带产品
        var urlfilter = 'module=Users&action=UsersAjax&file=CallCenterHandle';
        var urldata = urlfilter+'&setype=gettype';
        RequestAjax(urldata,function(res){
            if(empty(res)) return false;
            var resArr = res.split('-');

            var rest = resArr[0].trim();
            switch (rest){
                case '3'://天润融通旧
                case 'tianrunnew': //天润融通新
                    if(window.frameElement != null){
                        ld(' .callcenterImg').css('display','');
                        ld(' .callcenterImg').unbind("click").bind('click',function(){
                            var columnname = ld(this).attr('tag');
                            var modulename = ld(this).attr('key_module');
                            var tablename = ld(this).attr('key_tablename');
                            var record = ld(this).attr('key_recordid');
                            var detailrecordid = ld(this).attr('key_detailrecordid');
                            new Ajax.Request
                            (
                                'index.php',
                                {
                                    queue: {
                                        position: 'end',
                                        scope: 'command'
                                    },
                                    method: 'post',
                                    postBody:"module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid,
                                    onComplete: function(response)
                                    {
                                        if(!empty(response.responseText)){
                                            mobilenum = response.responseText.split('##$$##');
                                            ld('#toolbar',window.parent.document)[0].contentWindow.TianrunOldTools.getInstance().callout( mobilenum[1],'detail',record+'_'+modulename);
                                            return;
                                        }else{
                                            var confirm_str = '电话号码不能为空！';
                                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            return false;
                                        }
                                    }
                                }
                            )
                            DelProgressObjs();
                            return false;
                        });
                    }
                    break;
                case '4'://汉天
                    if(window.frameElement != null){
                        ld(' .callcenterImg').css('display','');
                        ld(' .callcenterImg').unbind("click").bind('click',function(){
                            var columnname = ld(this).attr('tag');
                            var modulename = ld(this).attr('key_module');
                            var tablename = ld(this).attr('key_tablename');
                            var record = ld(this).attr('key_recordid');
                            var detailrecordid = ld(this).attr('key_detailrecordid');
                            new Ajax.Request
                            (
                                'index.php',
                                {
                                    queue: {
                                        position: 'end',
                                        scope: 'command'
                                    },
                                    method: 'post',
                                    postBody:"module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid,
                                    onComplete: function(response)
                                    {
                                        if(!empty(response.responseText)){
                                            mobilenum = response.responseText.split('##$$##');
                                            ld('#toolbar',window.parent.document)[0].contentWindow.HantianTools.getInstance().callout( mobilenum[1],'detail',record+'_'+modulename);
                                            return;
                                        }else{
                                            var confirm_str = '电话号码不能为空！';
                                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            return false;
                                        }
                                    }
                                }
                            )
                            DelProgressObjs();
                            return false;
                        });
                    }
                    break;
                /* editor:gyq_11 reason:九维详情页呼叫图标 */
                case '5'://苏州九维
                    if(window.frameElement != null){
                        ld(' .callcenterImg').css('display','');
                        ld(' .callcenterImg').unbind("click").bind('click',function(){
                            //editor:gyqX20161102    Bug:0025512: 苏州九维呼叫中心：点击电话或手机号码的拨号，下方弹出CounterPath eyeBeam 弹出框，点击摘机后，电话没有拨打出去。
                            var columnname = ld(this).attr('tag');
                            var modulename = ld(this).attr('key_module');
                            var tablename = ld(this).attr('key_tablename');
                            var record = ld(this).attr('key_recordid');
                            var detailrecordid = ld(this).attr('key_detailrecordid');
                            new Ajax.Request
                            (
                                'index.php',
                                {
                                    queue: {
                                        position: 'end',
                                        scope: 'command'
                                    },
                                    method: 'post',
                                    postBody:"module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid,
                                    onComplete: function(response)
                                    {
                                        if(!empty(response.responseText)){
                                            ld('#toolbar',window.parent.document)[0].contentWindow.JiuWeiTools.getInstance().callout( response.responseText,modulename,record);/*gyq_25*/
                                            return;
                                        }else{
                                            var confirm_str = '电话号码不能为空！';
                                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            return false;
                                        }
                                    }
                                }
                            )
                            return false;
                        });
                        DelProgressObjs();
                    }
                    break;
                case '6'://思孚
                    if(window.frameElement != null){
                        ld(' .callcenterImg').css('display','');
                        ld(' .callcenterImg').unbind("click").bind('click',function(){
                            var columnname = ld(this).attr('tag');
                            var modulename = ld(this).attr('key_module');
                            var tablename = ld(this).attr('key_tablename');
                            var record = ld(this).attr('key_recordid');
                            var detailrecordid = ld(this).attr('key_detailrecordid');
                            new Ajax.Request
                            (
                                'index.php',
                                {
                                    queue: {
                                        position: 'end',
                                        scope: 'command'
                                    },
                                    method: 'post',
                                    postBody:"module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid,
                                    onComplete: function(response)
                                    {
                                        if(!empty(response.responseText)){
                                            ld('#toolbar',window.parent.document)[0].contentWindow.JiuWeiTools.getInstance().callout( response.responseText);
                                            return;
                                        }else{
                                            var confirm_str = '电话号码不能为空！';
                                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            return false;
                                        }
                                    }
                                }
                            )
                            return false;
                        });
                        DelProgressObjs();
                    }
                    break;
                case '1'://电话录音盒

                    if(window.external == 'CallButler.BrowserControl' || window.external == null){
                        ld(' .callcenterImg').css('display','');
                        var issubmit=1;
                        ld(' .callcenterImg').unbind("click").bind('click',function(){
                            if(issubmit!=1)
                            {
                                return ;
                            }
                            issubmit=2;
                            popupobj=CrmPopup.getPopupObj("last");
                            var mobile = ld(this).attr('keyval');//获取当前拨号的号码
                            var sMobile = resArr[1] + mobile;
                            var columnname = ld(this).attr('tag');
                            //40377: （51mis.com/kfbcrm）电话小管家>合同订单模块>选择单据编号为“SO252”进入详情界面：客户和联系人关联字段和引用手机、电话字段应该不显示电话图标
                            var modulename =ld(this).attr("key_module");


                            var tablename = ld(this).attr('key_tablename');
                            var record = ld(this).attr('key_recordid');
                            var detailrecordid = ld(this).attr('key_detailrecordid');
                            // 	alert("module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid);
                            // alert("module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid);
                            new Ajax.Request
                            (
                                'index.php',
                                {
                                    queue: {
                                        position: 'end',
                                        scope: 'command'
                                    },
                                    method: 'post',
                                    postBody:"module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid,
                                    onComplete: function(response)
                                    {
                                        issubmit=1;
                                        if(!empty(response.responseText)){
                                            var results=response.responseText.split('##$$##');

                                            if(tablename=='ld_contactdetails'||tablename=='ld_contactscf')
                                            {
                                                //edit:can 2020-09-03 42563: （https://61mis.com/kfbtest/ [^]）客户问题（安康金源），使用电话管家登陆，客户单据列表界面，点击联系人姓名“测试001”联系人手机后面的电话图标外呼时，跟进记录新建界面的联系人姓名显示“测试”（需要补丁）
                                                CallCenterJs.crm_callPhone(trim(results[1]),'callid='+trim(results[1])+"&frommodule=Contacts&fromid="+detailrecordid);
                                            }
                                            else
                                                CallCenterJs.crm_callPhone(trim(results[1]),'callid='+trim(results[1])+"&frommodule="+modulename+"&fromid="+record);

                                            return;
                                        }else{
                                            var confirm_str = '电话号码不能为空！';
                                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            return false;
                                        }
                                        return false;
                                    }
                                }
                            )
                        });
                        DelProgressObjs();
                    }
                    break;
                case 'zhongjian'://Eidtor:gyq_68 Reason:江阴紫金呼叫 Date:2018/4/23 0023 下午 4:09
                    if(window.frameElement != null){
                        ld(' .callcenterImg').css('display','');
                        ld(' .callcenterImg').unbind("click").bind('click',function(){
                            //editor:gyqX20161102    Bug:0025512: 苏州九维呼叫中心：点击电话或手机号码的拨号，下方弹出CounterPath eyeBeam 弹出框，点击摘机后，电话没有拨打出去。
                            var columnname = ld(this).attr('tag');
                            var modulename = ld(this).attr('key_module');
                            var tablename = ld(this).attr('key_tablename');
                            var record = ld(this).attr('key_recordid');
                            var detailrecordid = ld(this).attr('key_detailrecordid');
                            new Ajax.Request
                            (
                                'index.php',
                                {
                                    queue: {
                                        position: 'end',
                                        scope: 'command'
                                    },
                                    method: 'post',
                                    postBody:"module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid,
                                    onComplete: function(response)
                                    {
                                        var mobile = response.responseText.replace(/##\$\$##/g, "");
                                        ld('#toolbar',window.parent.document)[0].contentWindow.MakeCall(mobile);
                                        return false;
                                    }
                                }
                            )
                            return false;
                        });
                        DelProgressObjs();
                    }
                    break;
                case 'bangwo8'://editor:gyq_69 reason:帮我吧呼叫中心 2018/6/6 16:13
                    if(window.frameElement != null){
                        ld(' .callcenterImg').css('display','');
                        ld(' .callcenterImg').unbind("click").bind('click',function(){
                            //editor:gyqX20161102    Bug:0025512: 苏州九维呼叫中心：点击电话或手机号码的拨号，下方弹出CounterPath eyeBeam 弹出框，点击摘机后，电话没有拨打出去。
                            var columnname = ld(this).attr('tag');
                            var modulename = ld(this).attr('key_module');
                            var tablename = ld(this).attr('key_tablename');
                            var record = ld(this).attr('key_recordid');
                            var detailrecordid = ld(this).attr('key_detailrecordid');
                            new Ajax.Request
                            (
                                'index.php',
                                {
                                    queue: {
                                        position: 'end',
                                        scope: 'command'
                                    },
                                    method: 'post',
                                    postBody:"module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid,
                                    onComplete: function(response)
                                    {
                                        var mobile = response.responseText.replace(/##\$\$##/g, "");
                                        ld('#toolbar',window.parent.document)[0].contentWindow.call(mobile);
                                        return false;
                                    }
                                }
                            )
                            return false;
                        });
                        DelProgressObjs();
                    }
                    break;
                case 'yiwei'://亿维电话语音盒 //@edit:liushuai,2021-05-27,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”（列表详情页拨打电话）
                    // ljj 20231030 XUQIU1002019 客户和联系人模块的“自动拨号”增加显示控制（刘素）
                    //控制手机号旁边的“拨号”图标显示
                    if (YiweiTools.getInstance().isconnect === true){
                        ld(' .callcenterImg').css('display','block');
                    }
                    ld(' .callcenterImg').unbind("click").bind('click',function(){
                        var columnname = ld(this).attr('tag');
                        var modulename = ld(this).attr('key_module');
                        var tablename = ld(this).attr('key_tablename');
                        var record = ld(this).attr('key_recordid');
                        var detailrecordid = ld(this).attr('key_detailrecordid');
                        new Ajax.Request
                        (
                            'index.php',
                            {
                                queue: {
                                    position: 'end',
                                    scope: 'command'
                                },
                                method: 'post',
                                postBody:"module=Users&action=UsersAjax&file=getModuleMobile&frommodule="+modulename+"&columnname="+columnname+"&tablename="+tablename+"&record="+record+"&detailrecordid="+detailrecordid,
                                onComplete: function(response)
                                {
                                    if(!empty(response.responseText)){
                                        var mobile = response.responseText.replace(/##\$\$##/g, "");
                                        YiweiTools.getInstance().ListOnDailout(mobile,modulename,record,tablename,detailrecordid);
                                        return;
                                    }else{
                                        var confirm_str = '电话号码不能为空！';
                                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                        return false;
                                    }
                                }
                            }
                        )
                        return false;
                    });
                    DelProgressObjs();
                    break;
            }

            DelProgressObjs();
        });
    }
}

/*
edit:can
date:20130727
reason:延期界面
*/
function generateautoReminds()
{

    new Ajax.Request
    (
        'index.php',
        {
            queue: {
                position: 'end',
                scope: 'command'
            },
            method: 'post',
            postBody:"module=Reminds&action=autoRemind&ReportHeader=dheader",
            onComplete: function(response)
            {

            }
        }
    )
}


function synchronousInventory(){
    hideOptions('synchronousInventoryDiv');
    var sel = $('synchronousOne');
    var layout = sel.checked;
    var typename = 'typename';
    if(layout)
    {
        typename = 'synchronous';
    }
    else
    {
        typename = 'synchronousandinput';
    }
    new Ajax.Request(
        'index.php',
        {queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody:'module=Products&action=SynchronousInventory&type='+typename,
            onComplete: function(response){
                var responseVal=response.responseText;
                if(responseVal.indexOf('###SUCCESS###')>-1)
                {
                    var confirm_str = arrJsPopLabel['SUCCESSFULOPERATION'];
                }
                else
                {
                    var confirm_str = arrJsPopLabel['OPERATIONFAILED'];
                }
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                puyoungJS_DialogBox.unblock();
                hideOptions('divId');
            }
        }
    );
}
var http_reqfield;

function createfieldXMLHTTP()
{
    var request;
    var browser=navigator.appName;

    if(browser=="Microsoft Internet Explorer")
    {
        var arrVersions=["MSXML2.XMLHttp.5.0","MSXML2.XMLHTTP.4.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"];
        for( var i=0;i<arrVersions.length;i++)
        {
            try
            {
                request=new ActiveXObject(arrVersions[i]);
                return request;
            }
            catch(exception)
            {
            }
        }
    }
    else
    {
        request=new XMLHttpRequest();
        return request;
    }
}
function RequestFieldDuplicate()
{

    if(http_reqfield.readyState==4)
    {
        if(http_reqfield.status==0||http_reqfield.status==200)
        {
            var str=http_reqfield.responseText;
            if(str.indexOf('##systemcode##$$')>=0)
            {
                var results=str.split('##systemcode##$$');
                var objid=results[1];
                var systemcode=results[2];
                document.getElementById(objid).value=systemcode;
                //022073: 单据保存时，去掉编号重复的提示信息。
                //  alert(results[3]);
                //20834: 单据编号重复问题：单据编号重复时，需要点击三次才能保存
                isDuplicate=false;
                return ;
            }else if(str.indexOf('##error##') > -1)
            {
                var results=str.split('##error##');
                //zkt 20230328 BUG0063174 kfbcrm 成员管理---新建---姓名重复提示信息缺少 ！号
                if(results[1].indexOf("!") == -1 &&results[1].indexOf("！") == -1){
                    results[1]+='！';
                }
                audioRemindsMsg("","","","","",results[1]);
                //wym 240205 BUG20240202-22 客户管理--新建单据保存时，公司电话字段不可重复提示 没有focus和变红
                if(http_reqfield.fieldobj.length>0){
                    http_reqfield.fieldobj.focus();
                    http_reqfield.fieldobj.addClass('border_red1');
                    http_reqfield.fieldobj.bind('mouseover',function(){
                        ld(this).removeClass('border_red1');
                    });
                }
                isDuplicate=true;
            }else if(str.indexOf('##confirm##') > -1){//名称重复提示
                var results=str.split('##confirm##');
                if(results[1].indexOf("!") == -1 &&results[1].indexOf("！") == -1){
                    results[1]+='！';
                }
                if(confirm(results[1])){
                    isDuplicate=false;
                }else{
                    isDuplicate=true;
                }
            }else if(str.indexOf('divNoRecord') > -1){
                //您没有权限执行这个操作（可能是查重）
                var confirm_str = arrJsPopLabel['NOPERMITTEDEXECUTE'];
                audioRemindsMsg("","","","","",confirm_str);
                isDuplicate=true;
            }
            else
            {
                isDuplicate=false;
            }
        }
    }
}
/*
edit:can
date:20130805
reason:自定义设置增加是否允许重复设置

*/
var fileflag = false; //用来防止单据重复点击保存 Liver2016/06/17
function FieldDuplicateValidate(module,oform,obj)
{
    //puyoungJS_DialogBox.block();
    var popupobj=CrmPopup.getPopupObj("last");
    if(module=='Users')
    {
        if(ld("#"+popupobj.divid+" [name=sel_login_sms]").prop('checked'))
        {
            for(var i=0;i<popupobj.fields.length;i++)
            {
                //35780: （1.6）成员管理编辑界面：当勾选了“登录时启用手机短信验证”参数且没有填写手机字段为空的情况下，点击保存应弹出提示“手机字段不能为空”
                if(popupobj.fields[i].fieldname=='phone_mobile')
                {

                    if(ld("#"+popupobj.divid+" [name=phone_mobile]")!=undefined && trim(ld("#"+popupobj.divid+" [name=phone_mobile]").val())=='')
                    {
                        var fieldlabel=popupobj.fields[i].fieldlabel;
                        audioRemindsMsg("","",popupobj.module,"","",fieldlabel+arrJsPopLabel['CANOTEMPTY']);
                        return false;
                    }
                    break;
                }

            }

        }

    }
    if(popupobj.type=='moduledetailpage')
    {

        oform=ld("#div_pagerecord [name=EditView]");
        if(popupobj.delfileids!=undefined&&popupobj.delfileids.length>0)
            ld("#div_pagerecord [name=delfileid]").val(popupobj.delfileids.join());
        //图片
        if(popupobj.imagedelfileids!=undefined&&popupobj.imagedelfileids.length>0)
            CrmPopup.findHtmlobj(popupobj.divid,"imagedelfileid").val(popupobj.imagedelfileids.join());
    }


    var url="";
    var fieldvalue="";
    var recordid=oform.find("[name=record]").val();

    if(module=='Events')
    {
        module='Calendar';//edit:can reason:014634: 公司CRM：编辑日程管理，然后再保存，结果提示undefined。(账号：liver)
    }
    var bill_city='';
    var bill_state='';
    var is_duplicate ='';
    isDuplicate=false;
    //duan 20240606 复制将record置为空的操作移到循环外
    if (popupobj.isduplicate == 'yes'){
        recordid = '';
    }
    for(var i=0;i<popupobj.fields.length;i++)
    {

        if (iskehu001=='yes' && module == 'Users' && popupobj.fields[i].fieldname=='last_name') {
            continue;
        }

        //edit:can reason:16558: 控制面板>用户管理>查看用户界面：附件区块，新建附件，点击“保存”，页面一直显示被灰色。,IE10
        if(popupobj.fields[i].fieldonly==1&&((oform.find("[name="+popupobj.fields[i].fieldname+"]")!=undefined
            &&oform.find("[name="+popupobj.fields[i].fieldname+"]").length>0)||(popupobj.fields[i].bigtype == 'multipicklist' && oform.find(" [name='" + popupobj.fields[i].fieldname + "[]']").length>0)))
        {

            //多选框数据库值为 |##| 分隔，传参应该如此
            if(popupobj.fields[i].bigtype == 'multipicklist'){// 多选框
                if (oform.find(" [name='" + popupobj.fields[i].fieldname + "[]']").length <= 0) {
                    fieldvalue = CrmPopup.getHtmlobjval(popupobj.divid, popupobj.fields[i].fieldname);
                } else {
                    fieldvalue = (oform.find(" [name='" + popupobj.fields[i].fieldname + "[]']").val()).join(' |##| ');// 拼接多选框选项;
                }
            }
            else if(oform.find("[name="+popupobj.fields[i].fieldname+"]").prop('tagName').toLowerCase()=="select")
            {
                fieldvalue=trim(oform.find("[name="+popupobj.fields[i].fieldname+"]").val());

            }else{
                fieldvalue=trim(oform.find("[name="+popupobj.fields[i].fieldname+"]").val());
            }

            if(fieldvalue=="")
            {
                continue;
            }

            //ls 2022-01-05 0049529: (https://www.51mis.com/hy/slgc/index.php? [^])（客户问题）进项发票模块，复制单据时，发票号码没有不允许重复的提示 (复制单据判断是否重复的条件不应该排除被复制的单据,编辑单据需排除)

            fieldvalue=encodeURIComponent(fieldvalue);
            url="index.php?module="+module+"&action="+module+"Ajax&file=FieldDuplicate&fieldname="+popupobj.fields[i].fieldname+"&fieldvalue="+fieldvalue+"&fieldid="+recordid;
            //wym 240418 1000195 销售线索和客户增加一起查重功能，包括新增、导入 升级到客户不需要查重
            if(popupobj.upgradefrommodule && popupobj.upgradefromid){
                url+="&upgradefrommodule="+popupobj.upgradefrommodule+"&upgradefromid="+popupobj.upgradefromid;
            }

            //edit:can date:20140821 reason:10837: 【保存】单据时，若提示单据编号重复，建议点击确定后，系统会自动生成新的，并且不重复的流水编号
            if(oform.find("[name=bill_city]")!=undefined&&oform.find("[name=bill_city]").length>0)
            {
                bill_city=oform.find("[name=bill_city]").val();
                url=url+'&bill_city='+encodeURIComponent(bill_city);
            }
            if(oform.find("[name=bill_state]")!=undefined&&oform.find("[name=bill_state]").length>0)
            {
                bill_state=oform.find("[name=bill_state]").val();
                url=url+'&bill_state='+encodeURIComponent(bill_state);
            }
            http_reqfield=createfieldXMLHTTP();
            http_reqfield.open("POST",url,false);
            isDuplicate=false;
            if(ld(obj).length>0){//wym 240205 BUG20240202-22 客户管理--新建单据保存时，公司电话字段不可重复提示 没有focus和变红
                http_reqfield.fieldobj=ld(obj);
            }else{
                http_reqfield.fieldobj=oform.find("[name="+popupobj.fields[i].fieldname+"]");
            }
            http_reqfield.onreadystatechange=RequestFieldDuplicate;
            http_reqfield.setRequestHeader("If-Modified-Since","0");
            http_reqfield.send();

            if(isDuplicate==true)
            {
                return false;
            }

        }
    }
    if(isDuplicate==true)
    {
        return false;
    }
    // 审批弹窗调用仅用于判断字段是否重复
    if(popupobj.pagetype == 'approvepopup'){
        return true;
    }

    var isedit='no';

    ld.ajax({
        // PC端+微信端：模块单据提交审批后，系统应该做实时判断
        //chj 2020/12/23 43869: （61mis.com/kfbcrm）OA表单-常用审批单；单据编号PTSP96，审批流中设置了审批必填字段，编辑保存时提示“该记录正在审批中，不允许编辑！ ”
        url: 'index.php?module=Users&action=UsersAjax&file=callStaticMethod&static=puyoung&method=checkEditInfo&fld_module='+module+"&record="+recordid+"&cur_module_step=1",
        type: 'POST',
        data:{"namename": "uname", "namenameage": 18},
        async: false,//
        timeout: 10000,
        success: function(rest)
        {
            var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);

            if(restobj.check.indexOf("SUCCESS")<0)
            {

                RemindsMsg("","LdPopWidth400px",module,"yes","yes",restobj.check);
                return false;
            }
            else
            {
                isedit='yes';

            }
        },
    });
    if(isedit=='no')
    {
        return false;
    }
    if(module=='SendPayments' && oform.cpstatus!=undefined)
    {

        if(oform.cpstatus[oform.cpstatus.selectedIndex].value.indexOf('已付')!=-1)
        {

            if(confirm(arrJsPopLabel['ifthestatehasebeenselectedaspartofthe'])==false)
            {
                puyoungJS_DialogBox.unblock();
                return false;
            }
        }

    }


    //btn_quick_save:快速创建
    ///用户姓名判断是否重复，会用到该函数
    //||(obj!=undefined&&obj.id!=undefined)&&obj.id=='btn_quick_save'
    //20948: 联系人>序列表界面：操作列点击“跟进”，填好各项信息后不能对其进行保存
    if(module=='Users')
    {

        if(typeof User_verify_data=="undefined"||typeof User_verify_data==undefined)
        {

            AjaxJSPage("Users_js",'include/js/modules/Users/Users.js');
        }
        return User_verify_data(oform);
        //return true;
    }
    else if(obj!=undefined&&obj.id!=undefined&&obj.id=='btn_quick_save')
    {
        //20948: 联系人>序列表界面：操作列点击“跟进”，填好各项信息后不能对其进行保存
        return true;
    }
    else
    {

        //diony 2014-11-26 合同订单保存判断仓库是否被禁用，如果被禁用弹出窗口
        if(module=='SalesOrder'&&document.getElementById('autowarehouseid')!=undefined)
        {
            ///  fnvshobj(this,'outboundorderDiv');
            //  return false;;
        }
        else
        {

            if(popupobj.type=='moduledetailpage')
            {

                //销售合同模块中有逾期字段，如超过逾期字段时间时，不允许出库
                if(ld('#version_trade').val() != undefined && ld('#version_trade').val() == 'jiangjing' && module =='OutboundOrder' && ld('#salesorder_id').val() != undefined && ld('#salesorder_id').val() != ''){
                    var entitytypeid = '';
                    var max_row_count = document.getElementById('rowcnt').value;
                    for (var i=1;i<=max_row_count;i++) {
                        if(ld('#entitytypeid'+i).val() != undefined && ld('#entitytypeid'+i).val() > 0 && ld('#entitytype'+i).val() != undefined && ld('#entitytype'+i).val() == 'SalesOrder'){
                            entitytypeid += ld('#entitytypeid'+i).val() + ',';
                        }
                    }
                    if(!empty(entitytypeid)){
                        ld.ajax("index.php?action=SalesOrderAjax&module=SalesOrder&file=jiangjing_getOverDue_Date&entitytypeid="+entitytypeid)
                            .done(function(results){
                                var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
                                if(restobj.code == 2){
                                    var isinit = 0;
                                    if(ld('#findproductqtyinstock_div').length == 1){
                                        if(0 == isinit) isinit = 1;
                                    }
                                    var divobj = createElementDivs('findproductqtyinstock_div');
                                    ld(divobj).find('.D_pop_tit .D_ptita').html(arrJsPopLabel['WARMPROMPT']);
                                    ld(divobj).css('max-height','500px');
                                    ld('#findproductqtyinstock_divcontent').html(restobj.error);
                                    ld('#findproductqtyinstock_divcontent').css('max-height','300px');
                                    ld('#findproductqtyinstock_divcontent').css('overflow-y','auto');
                                    ld('#findproductqtyinstock_divcontent').css('border','none');
                                    ld('#findproductqtyinstock_div .D_pbtn .D_pbtncancel').css('display','none');
                                    if(0 == isinit){//初次加载的时候才显示
                                        ld('#findproductqtyinstock_div').css('top','28%');
                                    }
                                    //确认事件
                                    ld('#findproductqtyinstock_div .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                                        fninvshnew('findproductqtyinstock_div');
                                        return false;
                                    });
                                }else{
                                    //目前是带明细还没有做弹出层
                                    if(!fileflag){ //判断明细重复点击保存
                                        oform.find("[name=action]").val("Save");
                                        oform.submit();
                                        fileflag = true;
                                        return false;
                                    }
                                }
                            });
                    }
                }else{
                    //目前是带明细还没有做弹出层
                    if(!fileflag){ //判断明细重复点击保存
                        oform.find("[name=action]").val("Save");
                        oform.submit();
                        fileflag = true;
                        return false;
                    }
                }
            }
            return true;
        }


    }
    return false;

}
/**
 更新操作
 edit：cyb
 date:2015-10-29
 reason: 客户查重易用性改进(希望改进部分)，具体如下：
 ***/
function cleanall()
{
    var cheak = document.getElementById("cheack_repeat_columnname").value;
    if(cheak==arrJsPopLabel['PLEASEENTERKEYWORDRECHECKING'])
    {
        document.getElementById("cheack_repeat_columnname").value="";
    }
}
/**
 更新操作
 edit:cdw
 date:20131025
 reason:客户查重：再次查的时候如果input为空则不显示
 **/
function cleandata()
{
    if(document.getElementById('accounts_table')!=undefined)
    {
        while(document.getElementById('accounts_table').rows.length>1)
        {
            document.getElementById('accounts_table').deleteRow(1);
        }
    }

}

/**
 更新操作
 edit:diony
 date:20140708
 reason:特殊字符转义
 **/
function charEscape(str) {
    var RexStr = /\<|\>|\"|\'|\&/g
    str = str.replace(RexStr, function(MatchStr) {
        switch (MatchStr) {
            case "<":
                return "&lt;";
                break;
            case ">":
                return "&gt;";
                break;
            case "\"":
                return "&quot;";
                break;
            case "'":
                return "&#39;";
                break;
            case "&":
                return "&amp;";
                break;
            default:
                break;
        }
    })
    return str;
}
function selectSalesOrder(a){getJsScript('include/js/ldcrm.core.js',function(){selectSalesOrders(a);});}
function originBill_select(a){getJsScript('include/js/ldcrm.core.js',function(){originBill_selects(a);});}
/**
 edit:andrew
 date:2014-08-15
 reason:下一步骤审批人显示隐藏
 */
function changenetapproval(specifyapproveid){

    if(specifyapproveid==0)
        if(document.getElementById('username_approver') != undefined)
            document.getElementById('username_approver').style.display='contents';
        else
        {
            if(document.getElementById('username_approver') != undefined)
                document.getElementById('username_approver').style.display='none';
        }


}

function ApproveStepChange(a){getJsScript('include/js/ldcrm.core.js',function(){ApproveStepChange(a);});}
/**
 * edit:chj
 * date:2014-9-13
 * reason: 屏蔽页面所有的回车键事件
 **/
document.onkeypress=function(event)
{
    var e = event || window.event;
    var obj=e.srcElement||e.target;
    if(obj.tagName=='TEXTAREA'&&e.keyCode==13)
    {
        return true;

    }

    if(e.keyCode==13)
    {

        return false;
    }
}

function userEnterKey()
{
    //16845: 销售机会>新建：客户名称、联系人模糊匹配功能失效。（IE10、IE9）
    //arguments:是js系统变量，可以上网查看
    var event=arguments[arguments.length-1];

    var e=event||window.event;
    var code=e.keyCode||e.which;
    var obj=e.srcElement||e.target;

    if(e.keyCode==13)
    {


        var fun=arguments[0];

        fun.apply(this,arguments[1]);


    }
    return true;
}
/**
 * Ajax 封装方法
 * @author Tujt 2014-11-03
 */
function RequestAjax(data,callback){
    ldAjaxHtml('index.php?'+data,{},callback);
    /* ld('#rptContentLoading').show();
 >>>>>>> .r56728
     new Ajax.Request(
         'index.php',
         {queue:{position:"end", scope:"command"},
             method:"post",
             postBody:data,
             onComplete:function (response) {
                 ld('#rptContentLoading').hide();
                 callback(trim(response.responseText));
             }
         }
     );*/
}
/* gyq_11 reason:播放按钮 */
function play_click_jiuwei(type,url){
    /*if(type == 'chrome'){
        window.location.href="index.php?module=Accounts&action=Playforrecord&download=" + url;
    }else {*/
    //editor:gyq_69 reason:帮我吧呼叫中心 2018/6/6 15:03
    ld.get("index.php", {module: "Accounts", file: "Playforrecord", 'action': "AccountsAjax"}, function (response) {
        RemindsMsg("通话记录","LdPopWidth600px","","yes","yes",response);
        ld('div[class="qui_dialog_body ww_dialog_body"]').remove();
        ld('#null_remindercontent').append(response);
        ld('div[class="D_pbtn ww_dialog_foot"]').hide();
        if (type === 'ie') {
            ld('#embed').attr('src', url).show();
        }else{
            ld('#audio').attr('src', url);
            ld('#audioCon').show();
            getJsScript('include/js/Playforrecord.js', function () {
                window_onload();
            });
        }
    });
    //}
}


function play_click(sef,url){
    new Ajax.Request(
        'index.php',
        {queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody:'module=Users&action=UsersAjax&file=FileCheck&passUrl='+url+'&type=callbutler',
            onComplete: function(response) {
                if(response.responseText.split("#########:#")[1]=='no')
                {
                    var confirm_str = "录音文件不存在！";
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    return false;
                }
                else
                {
                    var popupobj=CrmPopup.getPopupObj('last');
                    //edit:can 20211230 49446: （http://xiaoshou360.com/KH/chongwen [^] ）（江苏崇文）在跟进记录的相关信息中查看录音文件，点击播放按钮，但是却是下载录音文件，并且没有播放录音；如果是去电话管家中点击播放，虽然会播放录音，但是依旧会弹出下载文件的页面，
                    var div = document.getElementById('divFileCallButlerlist');
                    ld(div).css("display",'');
                    ld(div).css("position", "fixed");
                    ld(div).css("right", "10px");
                    ld(div).css("top", "50px");
                    div.innerHTML='<audio controls id="audio_player" >  <source src="'+url+'" > </audio> <embed src="'+url+'" loop="0" autostart="true" hidden="true"></embed> ';
                    div.innerHTML+='<input class="E_pbtnok" type="button" onclick="play_click.AudioStop(this)" value="停止" />';
                    div.innerHTML+='<input class="E_pbtnok" type="button" onclick="play_click.download(this)" value="下载" />';
                    //  div.innerHTML = '<embed src="'+url+'" loop="0" autostart="true" hidden="true"></embed>';
                    //  var emb = document.getElementsByTagName('EMBED')[0];
                    // if (emb) {
                    // window.location.href = emb.src;
                    audio_player.play();
                    //setTimeout(function(){div.innerHTML='';},1000);
                    //}
                }
            }
        }
    );
    play_click.AudioStop=function(obj){
        audio_player.pause();
        var div = document.getElementById('divFileCallButlerlist');
        div.innerHTML='';

    }
    play_click.download=function(obj){
        var emb = document.getElementsByTagName('EMBED')[0];
        window.location.href = emb.src;
    }
}
/**
 *@edit: andy
 *@date: 20141203
 *@reason: 左右项选择
 *@version: v5.6
 */
function selectOptions(colunsleft,colunsright)
{
    //zxm 20230407 改成jqdom  BUG0063142“级联字段定制”新建或编辑界面，选择字段组件，选择多条已选字段（不要全选），点击左移，只有部分被选字段左移
    var availListObj=ld(getObj(colunsleft)).find('option');
    var selectedColumnsObj=ld(getObj(colunsright)).find('option');
    var selectlength=selectedColumnsObj.length
    var availlength=availListObj.length

    for (var i=0;i<selectlength;i++)
    {
        selectedColumnsObj[i].selected=false
    }

    for (var i=0;i<availlength;i++)
    {
        if (availListObj[i].selected==true)
        {
            var rowFound = false;
            var existingObj = null;
            for (var j=0;j<selectlength;j++)
            {
                if (selectedColumnsObj[j].value==availListObj[i].value)
                {
                    availListObj[i].remove();//无论默认有无，都去掉该备选项
                    rowFound=true;
                    existingObj=selectedColumnsObj[j];
                    break
                }
            }
            if (rowFound!=true)
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=availListObj[i].value
                if (browser_ie) newColObj.innerText=availListObj[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=availListObj[i].text
                selectedColumnsObj.appendChild(newColObj)
                availListObj[i].selected=false
                availListObj[i].remove();
                i=-1;
                newColObj.selected=true
                rowFound=false
            }
            else
            {
                if (existingObj != null) existingObj.selected=true
            }
        }

    }



}


function moveRightNoRemove(colunsleft,colunsright)
{
    availListObj=getObj(colunsleft)
    selectedColumnsObj=getObj(colunsright)
    var selectlength=selectedColumnsObj.length
    var availlength=availListObj.length

    for (i=0;i<selectedColumnsObj.length;i++)
    {
        selectedColumnsObj.options[i].selected=false
    }

    for (i=0;i<availListObj.length;i++)
    {
        if (availListObj.options[i].selected==true)
        {
            var rowFound = false;
            var existingObj = null;
            for (j=0;j<selectedColumnsObj.length;j++)
            {
                if (selectedColumnsObj.options[j].value==availListObj.options[i].value)
                {
                    //availListObj.options.remove(i);//无论默认有无，都去掉该备选项
                    rowFound=true;
                    existingObj=selectedColumnsObj.options[j]
                    break
                }
            }
            if (rowFound!=true)
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=availListObj.options[i].value
                if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                selectedColumnsObj.appendChild(newColObj)
                availListObj.options[i].selected=false
                //  availListObj.options.remove(i);
                i=-1;
                newColObj.selected=true
                rowFound=false
            }
            else
            {
                if (existingObj != null) existingObj.selected=true
            }
        }

    }



}
/**
 *@edit:andy
 *@date:
 *@reason:左右结构点击事件
 *@version:
 */
function clickAddColumn(source, destination)
{
    var sourceavailListObj = document.getElementById(source);//$(source);
    var destinationColumnsObj = document.getElementById(destination);//$(destination);
    for (i=0;i<sourceavailListObj.length;i++)
    {
        if (sourceavailListObj.options[i].selected==true)
        {
            var rowFound=false;
            var existingObj=null;
            for (j=0;j<destinationColumnsObj.length;j++)
            {
                if (destinationColumnsObj.options[j].value==sourceavailListObj.options[i].value)
                {
                    rowFound=true
                    existingObj=destinationColumnsObj.options[j]
                    break
                }
            }
            if (rowFound!=true)
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=sourceavailListObj.options[i].value
                if (browser_ie) newColObj.innerText=sourceavailListObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=sourceavailListObj.options[i].text
                destinationColumnsObj.appendChild(newColObj)
                sourceavailListObj.options[i].selected=false
                newColObj.selected=true

                rowFound=false
            }
            else
            {
                if(existingObj != null) existingObj.selected=true
            }
            //控制面板-》级联字段
            sourceavailListObj.remove(i);//20140902，diony，右移时删除左边信息
        }
    }
}
//带有搜索的下拉框，z-index赋值，解决低版本 下拉框覆盖问题
function dropDownBoxSearch(obj){
    if(obj != undefined){
        var numzIndex = 800;
        var clsobj = obj.getElementsByTagName('div');
        var clslen = clsobj.length;
        if(clslen > 0){
            for(var i=0;i<clslen;i++){
                if(clsobj[i].className != '' && clsobj[i].className.indexOf('chzn-container') > -1){
                    clsobj[i].style.zIndex = numzIndex;
                    numzIndex --;
                }
            }
        }
    }
}

/**
 * IE浏览器下innerHTML有的时候会出问题，
 * 用try监控，如果出现问题则使用另一种方式插入数据
 * @param Object obj 相关节点
 * @param String html 要插入的html
 * @returns 替代innerHTML方法
 * @author Tujt 2015-01-06
 */
function sethtml(obj,html){
    try{
        obj.innerHTML = html;
    }catch(e){
        var div = document.createElement('div');
        div.innerHTML = '<table cellspacing="0" cellpadding="0" border="0" width="100%"><tr><td>' + html + '</td></tr></table>';
        while(obj.firstChild) {
            obj.removeChild(obj.firstChild);
        }
        obj.appendChild(div.firstChild);
    }
}
/**
 * 获取对应id的节点对象，取不到返回空
 * @param String ids 节点id值
 * @returns 替代getElementById方法
 * @author Tujt 2015-01-22
 */
function getId(ids){
    return document.getElementById(ids);
}

/**
 *@edit:diony
 *@date:2014-01-06
 *@reason:关闭一个DIV，再打开另外的一个DIV
 */
function closeAndOpenDiv(idname,divold){
    var newbox=document.getElementById(idname);
    newbox.style.display="none";
    var divold=document.getElementById(divold);
    divold.style.display="inline";
}
/**
 * 明细选择源单 模糊匹配
 * @param
 * @returns
 * @author Chj
 */
function getKeyWordsDetail(obj,event){
    var module;
    var popupobj=CrmPopup.getPopupObj('last');
    //
    if(popupobj.pagetype && popupobj.pagetype == 'create_edit_modulepage'){}else{
        return false;
    }
    var e=event||window.event;
    var scrElement=e.srcElement||e.target;

    var rowobj= popupobj.getTrObjByChild(ld(scrElement));
    var rowid=ld(rowobj).attr("rowindex");//考虑到行可以拖动，则需要重新定义rowid的变量的值
    if(obj.getAttribute("tag") != null){

        var column = obj.getAttribute("tag");
        var bigtype = obj.getAttribute("bigtype");
        if(bigtype == 'selectsource'){
            if( ld('#'+popupobj.divid+' [name=select_'+column+']').length>0){
                module = ld('#'+popupobj.divid+' [name=select_'+column+']').val();
            }
        }else{
            module = obj.getAttribute("referencemodule");
        }
        //分录源单模糊匹配 没有源单类型
        if(empty(module)){
            var confirm_str = arrJsPopLabel['pleaseselect'] + ld('#'+popupobj.divid+' tr[tag=trhead] td[name="detail_entitytype"]').first().html();
            RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
            return false;
        }
        getKeyWords(obj,rowid,module,event);
    }
}
//当前选择的区域ID
var dropselectField='';
//匹配项 当前选择行数
var trNum = 0;
//当前匹配区域总行数
var trRowNum;
//滚动条默认TOP位置
var scrollTop = 0;
//默认8行 出现下拉拖动按钮
var scrollTrNum = 8;
var swidth = 0;//默认下拉表格宽度
var search_form_obj;//from obj
var search_form;
var search_obj;//div obj
var selectFieldName;


function getKeyWords(obj,rowid,module,event)
{
    //获取form的name
    var popupobj=CrmPopup.getPopupObj('last');

    search_form_obj = obj.parentNode||obj.parentElement;

    while('form' != search_form_obj.tagName.toLowerCase()){
        search_form_obj = search_form_obj.parentNode||obj.parentElement;
    }
    if(search_form_obj.name == 'EditView')
        search_form = document.EditView;
    else
        search_form = document.QcEditView;
    //alert(search_form_obj.name);
    var parentobj = obj.parentNode;
    var bigtype = obj.getAttribute("bigtype");
    var inputs = parentobj.getElementsByTagName('div');
    var inputlen = inputs.length;
    for(var i=0; i<inputlen; i++){
        if(bigtype == 'reference'){
            if('SearchResult_Reference_'+module == inputs[i].id && ld(inputs[i]).hasClass('SearchResult')){ //'SearchResult' == inputs[i].className
                search_obj = inputs[i];
                break;
            }
        }else{
            if(ld(inputs[i]).hasClass('SearchResult')){

                search_obj = inputs[i];
                break;
            }
        }
    }

    var e = event || window.event;
    if(obj.value.replace(/[ ]/g,"") != '')
    {


        //获取DIV下拉拖动高度
        var scrollHeight = search_obj.scrollHeight;
        var currencyid = 1; //1默认为人民币
        var scrollTrNumber = 6;
        if(e.keyCode == 40 || e.keyCode == 38){//方向键(下：40，上38)
            var trHeight = scrollHeight/trRowNum;
            if(e.keyCode == 40)
            {
                if(trNum == trRowNum)
                {
                    trNum = 0;
                    scrollTop = 0;
                }
                if(trNum < trRowNum)
                    trNum++;
                //默认8行
                if(eval(trNum) > eval(scrollTrNumber))
                {
                    scrollTop = scrollTop+trHeight;
                }
            }
            else{
                if(trNum == 1)
                {
                    trNum = trRowNum;
                    scrollTop = scrollHeight;
                }
                else if(trNum > 1)
                {
                    trNum--;
                    if(eval(trRowNum) - eval(trNum) > eval(scrollTrNumber))
                    {
                        scrollTop = scrollTop-trHeight;
                    }
                }
            }
            search_obj.scrollTop = scrollTop;
            trMouseover(trNum);
            return false;
        }
        else if(e.keyCode == 13)    //回车键13
        {
            if(trNum > 0)
            {
                var tableName = document.getElementById('selectTable_'+obj.name);
                var rowId = tableName.rows[trNum - 1].id;
                document.getElementById(rowId).onclick();
                //scrollTop = 0;
                if (e && e.stopPropagation){
                    e.stopPropagation();
                    e.preventDefault();
                }
                else{
                    e.returnValue = false;
                    e.cancelBubble=true;
                }
                search_obj.style.display = 'none';
                return false;
            }
            else
            {
                search_obj.style.display = 'none';
                return false;
            }
        }
        var urlstring = 'module=Users&action=UsersAjax&file=GetSearchInfo&ReportHeader=dheader&selectmodule='+module+'';

        var currentModule = popupobj.module;
        urlstring += '&frommodule='+currentModule;
        var searchText = encodeURIComponent(obj.value.toLowerCase());//关键字
        urlstring += '&keywords='+searchText;
        var popupobj=CrmPopup.getPopupObj('last');
        /* var  requestvalues="{";
           ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
            if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0)
             requestvalues+='"'+tmpfieldinfo.columnname+'":"'+ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val()+'",';
           })
           requestvalues=requestvalues.substr(0,requestvalues.length-1);//删除“，”
           requestvalues+="}"*/

        var  requestvalues=getPageValueByCrmPopupFields(popupobj);

        urlstring+="&requestvalues="+encodeURIComponent(requestvalues['requestvalue']);
        urlstring+="&sensitiverequestfield="+encodeURIComponent(requestvalues['sensitiverequestfield']);

        var fieldname=obj.getAttribute("fieldname");

        if(rowid>0&&(bigtype == 'selectsource' || bigtype == 'reference'))
        {
            urlstring +="&selectrelationfrom=entry";
            if(bigtype == 'selectsource')
                fieldname='entitytypeid';
        }
        urlstring +="&fieldname="+fieldname;
        var keyids = '';
        if(module == 'PurchaseOrder' || module == 'VendorContact'){
            if(search_form.vendor_id != undefined && search_form.vendor_id.value > 0)
                keyids=search_form.vendor_id.value;
        }
        if(search_form.account_id != undefined && search_form.account_id.value > 0){
            keyids = search_form.account_id.value;
        }
        urlstring += '&keyids='+keyids;
        if(search_form.account_id != undefined)
            urlstring +='&accountid='+search_form.account_id.value;
        dropselectField = obj.name;
        selectFieldName = obj.name;
        var fieldname=obj.getAttribute("fieldname");
        if(getKeyWords.ajax!=''&&getKeyWords.ajax!=undefined)
        {
            getKeyWords.ajax.abort();
        }
        var fieldinfo=popupobj.fieldname_fields[fieldname];
        var uitype=0;
        if(fieldinfo!=undefined)
        {
            uitype=fieldinfo.uitype;
        }
        //   console.log(uitype);
        //zkt 20240805 BUG20240731-21 销售订单模块，新建销售订单，检索客户名称不会显示出检索的客户。（报价单模块可以）（赵克听：可能的原因为销售订单条款与条件字段内容过长，导致访问错误）
        getKeyWords.ajax=	ldAjax('index.php?',urlstring,function(data){
            if(data.code == 1){
                trNum = 0;
                trRowNum = 0;
                var columnnameLen = data.result.columnname.length;

                swidth = obj.clientWidth+100;
                if(columnnameLen > 2){
                    swidth += (columnnameLen-2)*70;
                    //超过2列，每增加一列宽度加70. Edit by luyx at 2015-07-08
                }
                if(columnnameLen == 0 || columnnameLen < 1){
                    //无任何记录
                    var info = '<table id="selectTable_'+selectFieldName+'" class="SelTabPro" width="100%" border="0" cellspacing="0" cellpadding="0">';
                    info +='<tr height="30" style="background-color: #fff;"><td id="selectRow">'+arrJsPopLabel['NORECORDSAREFOUND']+'</td></tr>';
                    info += '</table>';
                }
                else{
                    //显示模糊查询内容
                    var info = '<table id="selectTable_'+selectFieldName+'" class="SelTabPro" width="100%" border="0" cellspacing="0" cellpadding="0">';
                    info += '<input type="hidden" id="returnmodule" name="returnmodule" value="'+currentModule+'" />';
                    var records = new Array();
                    records = data.result.ids.split(',');
                    ld.each(records,function(i,record){
                        trRowNum++;
                        var trClass = 'lvtColData';
                        if(trRowNum % 2 == 0){
                            trClass = 'lvtColDataBj';
                        }
                        var entityname = data.result.entries[record]['entityname'];
                        var smownerid = data.result.entries[record]['column_smownerid'];
                        if(obj.getAttribute("tag") != null){
                            var tag = obj.getAttribute("tag");
                            info += '<tr class="'+trClass+'" width="100%" height="30" onmouseover="trMouseover('+trRowNum+')" id="trRow_'+record+'_'+selectFieldName+'"  name="trRow_'+record+'_'+selectFieldName+'" curmodule="'+currentModule+'" frommodule="'+currentModule+'" record="'+record+'" linkname="'+entityname+'" referencemodule="'+module+'" columnname= "'+tag+'" onclick="selectTabDetailRelateds(this,event,'+rowid+')" title="'+decodeURI(entityname)+'">';
                        }
                        else{
                            if(uitype==173){
                                //edit:can 20220705  053567（https://www.51mis.com/hy/zxyjxs220704）【通用问题】，申请的【经销商管理演示账套】中合同订单编辑页面，选择最终用户字段模糊查询的结果会把渠道伙伴字段的内容覆盖。
                                info += '<tr class="'+trClass+'" width="100%" height="30" onmouseover="trMouseover('+trRowNum+')" id="trRow_'+record+'_'+selectFieldName+'"  name="trRow_'+record+'_'+selectFieldName+'" onclick="dropdownselectrelateds_special(\''+module+'\','+record+',\''+entityname+'\',\''+fieldname+'\',\''+smownerid+'\',\''+currentModule+'\')" title="'+decodeURI(entityname)+'">';
                            }
                            else
                                info += '<tr class="'+trClass+'" width="100%" height="30" onmouseover="trMouseover('+trRowNum+')" id="trRow_'+record+'_'+selectFieldName+'"  name="trRow_'+record+'_'+selectFieldName+'" onclick="selectrelated(\''+module+'\','+rowid+','+record+',\''+entityname+'\',\''+fieldname+'\',\''+smownerid+'\',\''+currentModule+'\')" title="'+decodeURI(entityname)+'">';
                        }
                        for(var j=0;j<columnnameLen;j++){
                            var columnname = data.result.columnname[j];
                            info += '<td id="selectRow">&nbsp;'+data.result.entries[record][columnname]+'&nbsp;</td>';
                        }
                        info += '</tr>';
                    });
                    info += '</table>';
                }
                search_obj.style.width = ''+swidth+'px';
                search_obj.style.display = 'block';
                search_obj.innerHTML = info;
                // @edit:diony @date:2023/12/02
                // hzx BUG0078138 跟进记录，客户名称输入关键字后，下拉模糊查询列表错位
                /*ld(search_obj).css("top",ld(obj).offset().top+parseInt(ld(obj).css("height")));
				search_obj.style.zIndex=999999;
				//显示位置 diony 20231202
				var a = window.screen.width;
				var b = ld(obj).offset().left;
                var c = ld('#'+popupobj.divid).offset().left;
				if(parseInt(a) - parseInt(b) - parseInt(c) < parseInt(ld(search_obj).width())){
					ld(search_obj).css("right",'0px');
					ld(search_obj).css("left",'');
				}
				else{
					ld(search_obj).css("right",'');
					ld(search_obj).css("left",parseInt(b)-parseInt(c)+'px');
				}*/
                //duan 20240508 修复分录中搜索时，搜索结果显示不全的问题
                if(ld(search_obj).css('position') == 'fixed'){
                    var position = ld(obj).offset();
                    var tmpheight = parseInt(ld(obj).css("height"));
                    ld(search_obj).css("top", (position.top + tmpheight) + "px");
                    var tmpwidth = parseInt(ld(obj).css("width"));
                    var windowwidth = ld(window).width();
                    ld(search_obj).css("left", position.left+"px");
                    /*
                    if(windowwidth/2 < position.left){
                        ld(search_obj).css("right", parseInt(windowwidth)-parseInt(windowwidth)*0.2-parseInt(position.left)-tmpwidth+"px");
                    }else{
                        ld(search_obj).css("left", position.left+"px");
                    }*/
                }

                scrollTop = 0;
                ld('#selectTable_'+selectFieldName).parent().addClass('ld-box-shadow');
            }
            ld('#rptContentLoading').hide();
        });
        return;
        //alert(urlstring);
        /*  new Ajax.Request('index.php',{
              queue: {position: 'end',scope: 'command'},
              method: 'post',
              postBody: urlstring,
              onComplete: function(response) {
                  var results = trim(response.responseText);
                  trNum = 0;
                  trRowNum = 0;
                  if(results != ''){
                      var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
                      //显示列头信息
                      var len = restobj['header'].length;
                      //显示列字段名称

                      var columnnameLen = restobj['columnname'].length;
                      swidth = obj.clientWidth+100;
                      //弹出的列表框宽度等于该字段输入框宽度+100. Edit by luyx at 2015-07-08

                      if(restobj['columnname'].length > 2)
                      {
                          swidth += (restobj['columnname'].length-2)*70;
                          //超过2列，每增加一列宽度加70. Edit by luyx at 2015-07-08
                      }

                      if(restobj['columnname'].length == 0 || restobj['columnname'].length < 1)
                      {
                          //无任何记录
                          var info = '<table  id="selectTable_'+selectFieldName+'" class="SelTabPro" width="100%" border="0" cellspacing="0" cellpadding="0">';
                          info +='<tr height="30"><td id="selectRow">'+arrJsPopLabel['NORECORDSAREFOUND']+'</td></tr>';
                          info += '</table>';
                      }
                      else
                      {
                          //显示模糊查询内容
                          var info = '<table  id="selectTable_'+selectFieldName+'" class="SelTabPro" width="100%" border="0" cellspacing="0" cellpadding="0">';
                          info += '<input type="hidden" id="returnmodule" name="returnmodule" value="'+currentModule+'" />';
                          for(var i in restobj['entries']){
                              trRowNum++;
                              var entityname = restobj['entries'][i]['entityname'];
                              var smownerid = restobj['entries'][i]['column_smownerid'];
                              if(obj.getAttribute("tag") != null){
                                  var tag = obj.getAttribute("tag");
                                  info += '<tr width="100%" height="30" onmouseover="trMouseover('+trRowNum+')" id="trRow_'+i+'_'+selectFieldName+'"  name="trRow_'+i+'_'+selectFieldName+'" curmodule="'+currentModule+'" frommodule="'+currentModule+'" record="'+i+'" linkname="'+entityname+'" referencemodule="'+module+'" columnname= "'+tag+'" onclick="selectTabDetailRelateds(this,event,'+rowid+')" title="'+decodeURI(entityname)+'">';
                              }else{
                                  info += '<tr width="100%" height="30" onmouseover="trMouseover('+trRowNum+')" id="trRow_'+i+'_'+selectFieldName+'"  name="trRow_'+i+'_'+selectFieldName+'" onclick="selectrelated(\''+module+'\','+rowid+','+i+',\''+entityname+'\',\''+fieldname+'\',\''+smownerid+'\',\''+currentModule+'\')" title="'+decodeURI(entityname)+'">';
                              }
                              for(var j=0;j<columnnameLen;j++)
                              {
                                  var columnname = restobj['columnname'][j];
                                  info += '<td id="selectRow">&nbsp;'+restobj['entries'][i][columnname]+'&nbsp;</td>';
                              }
                              info += '</tr>';
                          }
                          info += '</table>';
                      }
                      search_obj.style.width = ''+swidth+'px';

                      search_obj.style.display = 'block';
                   //
                      search_obj.innerHTML = info;
                      // @edit:dong @date:2020/09/21 @reason: 0042701 ld(obj).offset() 改为ld(obj).position()
                      ld(search_obj).css("top",ld(obj).position().top+parseInt(ld(obj).css("height")));
                      search_obj.style.zIndex=999999;
                      //显示位置 diony 20210203
                      var a = ld('#'+popupobj.divid).width();
                      var b = ld(obj).position().left;
                      if(parseInt(a) - parseInt(b) < parseInt(swidth)){
                          ld(search_obj).css("right",'0px');
                          ld(search_obj).css("left",'');
                      }
                      else{
                          ld(search_obj).css("right",'');
                          ld(search_obj).css("left",parseInt(b)+'px');
                      }
                      scrollTop = 0;
                  }
              }
          });*/
    }
}
getKeyWords.ajax="";
//基本信息 -选择带出值
function getColReturnData(module,mid,fldname,colname,entityname,inputname){
    entityname = decodeURI(entityname);
    if(mid > 0 && !empty(entityname)){
        var parentwindow = window;
        if(search_form_obj != undefined&&search_form_obj!=null){
            search_from_name = search_form_obj.name;
            if(search_from_name == 'QcEditView' && document.opener != undefined){
                parentwindow = window.opener;
            }
        }
        if((typeof isPopupButton!='undefined'&&isPopupButton=='yes')|| (window.document != undefined && window.document.QcEditView != undefined)) {
            parentwindow=window;
            parentwindow.document.QcEditView.elements[inputname].value = entityname;
            parentwindow.document.QcEditView.elements[fldname].value = mid;
            var form=parentwindow.document.QcEditView;
        }else{
            parentwindow.document.EditView.elements[inputname].value = entityname;
            parentwindow.document.EditView.elements[fldname].value = mid;
            var form=parentwindow.document.EditView;
        }

        getJsScript('include/js/popupselectfield.js',function(){
            parentwindow.getRelatedData(form.module.value,mid,colname,'');
        });
    }
}

//Chj:点击模糊查询序时簿时触发事件
function OnclikModuleLinkName(module,rowid,mid,entityname,fieldname,smownerid)
{
    entityname = decodeURI(entityname);
    if(mid > 0 && !empty(entityname)){
        //模块 选择 客户、联系人

        getJsScript('include/js/Entity.js',function(){

            if((module == 'Accounts' && fieldname == 'account_id') || module == 'Contacts'){
                //选择客户带出客户和联系人关联字段

                if(document.getElementById('bemodulestatus') != undefined && document.getElementById('bemodulestatus').value == 'YES'){
                    var contact_id = 0;
                    var accountid=0;
                    if(module == 'Accounts'){
                        if(document.EditView.contact_id != undefined)
                            contact_id = document.EditView.contact_id.value;
                        accountid=mid;
                    }
                    else if(module=='Contacts')
                    {
                        if(document.EditView.account_id!=undefined)
                            accountid=document.EditView.account_id.value;
                        contact_id=mid;
                    }
                    var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或者编辑界面
                    getAccountsContactsInfo(accountid,contact_id,module,popupobj);//(accountid,contact_id,module,'EditView');
                }
                //客户服务单 - 模糊匹配选择客户
                if(document.EditView != undefined && document.EditView.module != undefined && module == 'Accounts'){
                    if(document.EditView.module.value == 'HelpDesk'){
                        var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或者编辑界面
                        getAccountByHelpDeskHistory(mid,'',popupobj)
                    }
                }
            }
        });

        //设置文本不可输入
        var form = document.forms['EditView'];
        if(form==undefined)
        {
            return false;
        }
        if(form.module.value==module){
            if(fieldname=='lastname')
                fieldname='contacts_name';
        }
        /*search_form.elements[fieldname].disabled  = true;
		search_form.elements[fieldname].style.cursor = 'not-allowed';
		search_obj.style.display = 'none';*/
    }
    return false;
}

/**
 * edit:chj
 * date:2014-9-2
 * reason:鼠标移动到匹配项
 **/
function trMouseover(rowid)
{

    var tableName = document.getElementById('selectTable_'+dropselectField);
    var rowcount = tableName.rows.length;
    for(var i=0;i<rowcount;i++)
    {
        var trId = tableName.rows[i].id;    //每一行ID
        if(i == rowid - 1){
            ld('#'+trId+' td' ).css('background-color','#e7f4fe');
        }else{
            ld('#'+trId+' td' ).css('background-color','');
        }
    }
    trNum = rowid;
}
function customerintocontact(a,b,c,d){getJsScript('include/js/ldcrm.core.js',function(){customerintocontacts(a,b,c,d);});}
function clearAccountsContactsInfo(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){clearAccountsContactsInfos(a,b,c);});}
clearAccountsContactsInfo.other_clear=function()
{

}
function clearVendors(obj,module)
{
    obj.form.vendor_id.value='';
    //editor:gyq_161 reason:带分录模块弹出层   2019/11/27 15:44
    if(obj.form.vendors_name != undefined){
        obj.form.vendors_name.value='';
    }
    clearVendors.other_clear();
    return false;
}
clearVendors.other_clear=function()
{

}
function changeUser(type,userid,username)
{

}
changeUser.saveretjson=[];
changeUser.afterOperation=function (type,userid,username,module)
{

    if(type=='Allocate')
    {
        if(isadmin==1)
        {
            //
            ld('#dtlview_assigned_user_id_'+module).html('<a href="index.php?module=Users&action=DetailView&record='+userid+'&blockidsetting=2&fieldidsetting=1">'+username+'</a>');

        }
        else
        {
            ld('#dtlview_assigned_user_id_'+module).text(username);
        }
        if(module=="Accounts")
        {
            //33722: 客户、联系人模块分配功能中被勾选单据的明细界面中“最新分配日期”字段值没有默认为当前时间
            ld('#dtlview_distributiondate').text(changeUser.saveretjson.operatedate);
        }
    }
    else  if(type=='ChangeCreator')
    {
        ld('#dtlview_创建人').text(username);
        /*if(module=="PublicAnnouncement")
        {
            ld('#dtlview_创建人').text(username);
        }
        else
        ld('#dtlview_creator').text(username);*/
    }

}
//判断非空
function empty(v){
    switch (typeof v){
        case 'undefined' : return true;
        case 'string' : if(trim(v).length == 0) return true; break;
        case 'boolean' : if(!v) return true; break;
        case 'number' : if(0 === v) return true; break;
        case 'object' :
            if(null === v) return true;
            if(undefined !== v.length && v.length==0) return true;
            for(var k in v){return false;} return true;
            break;
    }
    return false;
}
//统计图Y轴刻度值格式化 从homestuff.js拿过来的，homestuff.js和renderChart.js通用的  参数：value-值；unit-单位；
function yAxisFormatter(orgvalue,unit){
    //parseInt会截断小数点
    orgvalue = parseFloat(orgvalue);
    var value = orgvalue>0?orgvalue:-orgvalue;
    if(language=='en'){
        if((value/(1000*1000*1000*1000))>1){
            return (orgvalue/(1000*1000*1000*1000))+"T"+unit;
        }else if((value/(1000*1000*1000))>1){
            return (orgvalue/(1000*1000*1000))+"G"+unit;
        }else if((value/(1000*1000))>1){
            return (orgvalue/(1000*1000))+"M"+unit;
        }else if((value/(1000))>1){
            return (orgvalue/(1000))+"K"+unit;
        }else{
            return orgvalue+unit;
        }
    }else{
        if((value/(10000*10000))>=1){
            return (orgvalue/(10000*10000))+"亿"+unit;
        }else if((value/(10000))>=1&&(value/(10000))<10000){
            return (orgvalue/(10000))+"万"+unit;
        }else if((value/(1000))>=1&&(value/1000)<10) {
            return (orgvalue / (1000)) + "千" + unit;
        }else{
            return orgvalue+unit;
        }
    }
}
function ModuleDetailmoveUp(objid)
{
    var elem = document.getElementById(objid);
    if(elem.options.selectedIndex>=0){
        for (var i=1;i<elem.options.length;i++){
            if(elem.options[i].selected == true){
                //swap with one up
                var first = elem.options[i-1];
                var second = elem.options[i];
                var temp = new Array();

                temp.value = first.value;
                temp.innerHTML = first.innerHTML;

                first.value = second.value;
                first.innerHTML = second.innerHTML;

                second.value = temp.value;
                second.innerHTML = temp.innerHTML;

                first.selected = true;
                second.selected = false;

            }
        }
    }

    var popupobj=CrmPopup.getPopupObj("last");

    if(popupobj!=undefined&&popupobj!='undefined'){
        var elem2 =CrmPopup.findHtmlobj(popupobj.divid,objid);
        ld(elem2).animate({ scrollTop: "-=22" });
    }
}
function ProductDetailmoveDown(objid)
{
    if(objid==undefined || objid=='undefined') objid='selectedAssmablyColumns';
    var elem = document.getElementById(objid);
    if(elem.options.selectedIndex>=0){
        for (var i=elem.options.length-2;i>=0;i--){
            if(elem.options[i].selected == true){
                //swap with one down
                var first = elem.options[i+1];
                var second = elem.options[i];
                var temp = new Array();

                temp.value = first.value;
                temp.innerHTML = first.innerHTML;

                first.value = second.value;
                first.innerHTML = second.innerHTML;

                second.value = temp.value;
                second.innerHTML = temp.innerHTML;

                first.selected = true;
                second.selected = false;
            }
        }
    }
    var popupobj=CrmPopup.getPopupObj("last");

    if(popupobj!=undefined&&popupobj!='undefined'){
        var elem2 =CrmPopup.findHtmlobj(popupobj.divid,objid);
        ld(elem2).animate({ scrollTop: "+=22" });
    }

}

//function clickSelectMember(a,b){	getJsScript('include/js/multipingyin.js',function(){clickSelectMembers(a,b)});}
function clickSelectMember(a,b){	getJsScript('include/js/multipingyin.js',function(){//Liver 20170217,bug0027285: 控制面板-部门设置-添加成员可用成员和选择成员不能进行模糊查寻
    getJsScript('include/js/ldcrm.core.js',function(){clickSelectMembers(a,b);});});}

function createElementDiv(a){createElementDivs(a);}
function showBgDiv(){getJsScript('include/js/ldcrm.base.js',function(){showBgDiv();});}
function closeDiv(){
    var divid = arguments[0]?arguments[0]:'bgDiv';
    if(document.getElementById(divid))
        document.getElementById(divid).style.display = 'none';
}
function checkProductNum(a,b,c,d,e){getJsScript('include/js/ldcrm.core.js',function(){checkProductNum(a,b,c,d,e);});}
/**
 edit:can
 reason:动态加载js
 **/
var loadScript = function(url, callback, charset){
    var head = document.getElementsByTagName('head')[0];
    var script = document.createElement('script');
    if(charset){
        script.charset = charset;
    }
    script.src = url;
    if(!callback){
        return;
    }
    script.onload = script.onreadystatechange = function(){
        if(!this.readyState || this.readyState==='loaded' || this.readyState==='complete'){
            callback();
        }
    };
    head.appendChild(script);
};

/**
 * 跳转页面
 * @author Tujt 2015-05-29
 */
function redirect(url){
    var target = arguments[1]?arguments[1]:0;
    url = 'index.php?'+url;
    switch (target){
        case 0://当前页跳转
            location.href = url;
            break;
        case 1://打开新标签页
            var linkObj;var ids = 'redirect_link_target';
            if(ld('#'+ids).length == 0){

                linkObj = document.createElement('a');
                linkObj.id = ids;
                linkObj.target = '_blank';
                linkObj.style.display = "none";
                document.body.appendChild(linkObj);
            }else{
                linkObj = document.getElementById(ids);
            }
            linkObj.href = url;
            linkObj.click();
            break;
    }
}
/**
 * 异步加载js文件，然后执行方法
 * @author Tujt 2015-06-02
 */
var dynamicJsScript = {};
function getJsScript(JsFile,callback){
    if(dynamicJsScript != undefined && 1 == dynamicJsScript[JsFile]){
        callback();//不加载第二次
    }else{//异步加载
        //global_js_url+
        if(JsFile.indexOf("https://")>=0)
        {
            var url=JsFile;
        }
        else
            var url=global_js_url+JsFile;

        ld.getScript(url,function(data, textStatus, jqxhr) {
            if('success' == textStatus){

                dynamicJsScript[JsFile] = 1;

                callback();
            }
        });
    }
}
//zxm 20230509 crmcommon中js异步加载方法
function getCommonJsScript(JsFile,callback){
    if(dynamicJsScript != undefined && 1 == dynamicJsScript[JsFile]){
        callback();//不加载第二次
    }else{//异步加载
        ld.getScript(global_commonurl+JsFile,function(data, textStatus, jqxhr) {
            if('success' == textStatus){

                dynamicJsScript[JsFile] = 1;

                callback();
            }
        });
    }
}
/**
 * 同步加载js文件，然后执行方法
 * global_js_url
 */
function getScriptBackWithURL(JsFile,callback){
    if(dynamicJsScript != undefined && 1 == dynamicJsScript[JsFile]){
        if(callback!=undefined)
            callback();//不加载第二次
    }else{//同步加载
        ld.ajax({
            url: global_js_url+JsFile,
            dataType: 'script',
            async: false,

            success: function(rest){
                eval(rest);
                dynamicJsScript[JsFile] = 1;
                if(callback!=undefined)
                    callback();
            }
        });
    }
}

/**
 * 同步加载js文件，然后执行方法
 * @author Tujt 2015-06-02
 */
function getScriptBack(JsFile,callback){
    if(dynamicJsScript != undefined && 1 == dynamicJsScript[JsFile]){
        if(callback!=undefined)
            callback();//不加载第二次
    }else{//同步加载
        ld.ajax({
            url: JsFile,
            dataType: 'script',
            async: false,

            success: function(rest){
                eval(rest);
                dynamicJsScript[JsFile] = 1;
                if(callback!=undefined)
                    callback();
            }
        });
    }
}
/**
 * 同步加载js文件，然后执行方法，用于数据分类
 * @author diony 2016-10-19
 */
function getJsScriptCategory(JsFile,callback){
    ld.ajax({
        url: JsFile,
        dataType: 'script',
        async: false,
        success: function(rest){
            eval(rest);
            dynamicJsScript[JsFile] = 1;
            if(callback!=undefined)
                callback();
        }
    });
}
/**
 * 图片延迟加载，这个还没考虑好！
 * @author Tujt 2015-06-05
 */
function setlazyload(){
    if(ld('img[lazy_src]').length > 0){
        ld('img[lazy_src]').each(function(){
            ld(this).attr('src',ld(this).attr('lazy_src'))
        });
    }
}
var viewuserpopup_type = '';
function ViewUserPopup(obj,saveback,callback){
    getJsScript('include/jquery/treeview/jquery.treeview.js',function(){
        getJsScript('include/js/higerUser.js',function(){
            ViewUserPopups(obj,saveback,callback);
        });
    });
}

function showrelatedlist(module,selectmodule,type,isPopupButton,fieldname,obj=''){


    var eobj = ld(event.target);
    if (eobj.attr('isClicked') == 'yes'){
        return;
    }
    eobj.attr('isClicked','yes');
    setTimeout(() => {
        eobj.attr('isClicked','no');
    }, 2000);
    getJsScript('include/js/popupselectfield.js',function(){

        showrelatedlists(module,selectmodule,type,isPopupButton,fieldname,obj);

    });

}
//wym 多选关联字段 编辑页弹出框点击事件
function showrelatedlist_multi(formmodule,selectmodule,fieldname){
    var popupobj=CrmPopup.getPopupObj('last');
    popupobj.fieldname = fieldname;
    getJsScript('include/js/SystemPopup/MultiplePopup.js',function () {
        var chooseentityidarr = [];
        if(ld("#"+popupobj.divid+" input[name="+fieldname+"]").val() != ''){
            chooseentityidarr = ld("#"+popupobj.divid+" input[name="+fieldname+"]").val().split(',');
        }
        var MultiplePopupobj = new MultiplePopup();
        MultiplePopupobj.init(selectmodule,'&fieldname='+fieldname,formmodule);
        MultiplePopupobj.setChooseEntityidArr(chooseentityidarr);
        MultiplePopupobj.showPopup();
        MultiplePopupobj.setReturnField(popupobj,fieldname,fieldname+"_name");
        //批量编辑时，修改多选字段之后选中复选框
        if(popupobj.type == "masseditpopup"){
            var checkboxobj = ld('#'+popupobj.divid+' #'+fieldname+'_mass_edit_check');
            if (checkboxobj.length>0) checkboxobj.prop('checked',true);
        }
    })
}

function showrelatedlist_special(module,selectmodule,type,isPopupButton,fieldname){
    getJsScript('include/js/popupselectfield.js',function(){

        showrelatedlists_special(module,selectmodule,type,isPopupButton,fieldname);

    });

}
function scopePopup_All(module,inputid,scopetype){
    getJsScript('include/js/ScopePopup_All.js',function(){

        scopePopup_Alls(module,inputid,scopetype);

    });
}
//服务单 - 常见问题，弹出层特殊控制展示层
function showrelatedspeciallist(module,selectmodule,type,isPopupButton){
    getJsScript('include/js/popupselectfield.js',function(){

        showrelatedspeciallists(module,selectmodule,type,isPopupButton);

    });

}

function selectSearch(fieldname){
    getJsScript('include/js/popupselectfield.js',function(){
        selectSearchs(fieldname);
    });
}
//zxm 20221214 XUQIU1000736	其他 关联单据选择界面的查找搜索框显示优化
function clearRelatedSearch(obj,selectrealtionfrom,fieldname){
    getJsScript('include/js/popupselectfield.js',function(){
        clearRelatedSearchs(obj,selectrealtionfrom,fieldname);
    });
}
//zxm 20221214 XUQIU1000736	其他 关联单据选择界面的查找搜索框显示优化
function setRelatedShowOrHideClearIcon(){
    getJsScript('include/js/popupselectfield.js',function(){
        setRelatedShowOrHideClearIcons();
    });
}
function setSearch(module,frommodule,fieldname){
    getJsScript('include/js/popupselectfield.js',function(){
        setSearchs(module,frommodule,fieldname);
    });
}

function checkFieldlist(module,frommodule,fieldname){
    getJsScript('include/js/popupselectfield.js',function(){
        checkFieldlists(module,frommodule,fieldname);
    });
}
function checkDupFieldlist(module,frommodule){
    getJsScript('include/js/popupselectfield.js',function(){
        checkDupFieldlists(module,frommodule);
    });
}
//选择弹出层
function selectrelated(module,rowid,mid,entityname,fieldname,smownerid,frommodule){
    getJsScript('include/js/popupselectfield.js',function(){
        selectrelateds.spop = 'pop_div';
        selectrelateds(module,rowid,mid,entityname,fieldname,smownerid,frommodule);
    });
}
//选择新窗口
function pop_selectrelated(module,rowid,mid,entityname,fieldname,smownerid,frommodule){
    getJsScript('include/js/popupselectfield.js',function(){
        selectrelateds.spop = 'pop';

        selectrelateds(module,rowid,mid,entityname,fieldname,smownerid,frommodule);
    });
}

//清空关联带出值
function clear_relatedfielddata(module,input_id,input_name,fieldname,frommodule,popupselectfield,obj=''){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var version_account = '';
    var mid = CrmPopup.findHtmlobj(divid,input_id).val();

    var entityname = CrmPopup.findHtmlobj(divid,input_name).val();
    CrmPopup.findHtmlobj(divid,input_name).attr("disabled",false);
    CrmPopup.findHtmlobj(divid,input_name).css("cursor",'');
    if(!empty(ld(obj))&&!empty(ld(obj).attr('index'))){
        var index = ld(obj).attr('index');
        var input_obj = ld("#"+divid+" input[name="+input_id+index+"]");
        var before_value = input_obj.val();
        input_obj.val('');
        ld("#"+divid+" input[name="+input_id+index+"_name]").val('');

    }else{
        CrmPopup.findHtmlobj(divid,input_id).val('').trigger('change');
        CrmPopup.findHtmlobj(divid,input_name).val('');

        //duan 20240926字段变更后触发公共变化事件
        if(!empty(popupobj.common_field_event_obj) && mid > 0 ){
            popupobj.common_field_event_obj.common_changefun(CrmPopup.findHtmlobj(divid,input_id),input_id);
        }
        //清空部门候清空对象信息
        if(popupobj.module == 'Users' && popupobj.pagetype == CreatePagePopup.pagetype){
            if(input_id == 'groupid'){
                popupobj.cur_groupinfo = [];
                show_related_picklist_content('userlevel','yes');
            }
        }
    }

    //edit:can 20200713 用户界面选择部门(kehu001)
    CrmPopup.findHtmlobj(divid,input_name).html('');
    if(input_id == 'related_to'){
        module = CrmPopup.findHtmlobj(divid,'related_to_type').val();
    }
    if(!empty(module)){
        getJsScript('include/js/relatedfield.js',function(){
            clear_relatedfielddatas(module,mid,entityname,fieldname,frommodule,popupselectfield);

        });
    }
    if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined){
        version_account = CrmPopup.findHtmlobj(popupobj.divid,'version_account').val();
    }
    //克莱门特：热线单先输入序列号后，再选客户可以谁便选，会造成错误，如何避免？需客户没选时不能选产品，或产品为空；（老系统亦有控制必须先选客户）
    if(version_account != undefined && version_account == 'climaveneta' && module == 'Accounts' && frommodule == 'Potentials'){
        if(CrmPopup.findHtmlobj(divid,'product_id').val() != undefined && CrmPopup.findHtmlobj(divid,'product_id').val() != ''){
            var mid = CrmPopup.findHtmlobj(divid,'product_id').val();
            var entityname = CrmPopup.findHtmlobj(divid,'products_name').val();
            CrmPopup.findHtmlobj(divid,'product_id').val('');
            CrmPopup.findHtmlobj(divid,'products_name').val('');
            getJsScript('include/js/relatedfield.js',function(){
                clear_relatedfielddatas('Products',mid,entityname,'productname',frommodule,popupselectfield);
            });
        }
    }
    if(module=="Potentials"&&ld("#"+divid+" input[name=deploy_205]").val() != undefined)
    {

        if(ld("#"+divid+" input[name=deploy_205]").val()!=''&&parseInt(ld("#"+divid+" input[name=deploy_205]").val())==0)
        {
            //edit:can 20220615 （https://81mis.com/kfbtest/index.php）合同订单》新建》选择销售机会，POT26，客户名称和分录带出来了；点击清除销售机会，客户名称清除了，但分录没清楚
            //edit:can 20230728 kfbcrm-报价单-新建-点击销售机会的删除按钮，会把选择源单的记录一起删掉
            if(popupobj.detaildatavalue_arr!=undefined&&popupobj.detaildatavalue_arr.length>0&&popupobj.detaildatavalue_arr[0].entitytype=='Potentials')
                clearModuleProduct(this,'Potentials','');
            else
                clearModuleProduct(this,'Potentials','');
        }
    }
    //郎捷：当“服务项目”选择“报关订单”的时候，根据报关单和费用类型带出分录
    /*if((module == 'CustomForm22' || module == 'CustomForm23'  || module == 'Potentials' || module == 'CustomForm24') && frommodule == 'CustomForm18' && version_account != undefined && version_account == 'langjie'){
        var rowcnt = parseInt(CrmPopup.findHtmlobj(popupobj.divid,'rowcnt').val());
        for(var i=1;i<=rowcnt;i++){
            if(CrmPopup.findHtmlobj(popupobj.divid,'hdnProductId'+i).val() >= 1){
                fun_selectproduct.btn_clearProductInfo_Row(i);
            }
        }
    }*/

}

// lius 20230613 XUQIU1001607 圣拉维CRM项目：客户自动分配功能
function clear_relatedfielddata_special(module,input_id,input_name,fieldname,frommodule,popupselectfield){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var mid = CrmPopup.findHtmlobj(divid,input_id).val();
    var entityname = CrmPopup.findHtmlobj(divid,input_name).val();
    CrmPopup.findHtmlobj(divid,input_name).attr("disabled",false);
    CrmPopup.findHtmlobj(divid,input_name).css("cursor",'');
    CrmPopup.findHtmlobj(divid,input_id).val('');
    CrmPopup.findHtmlobj(divid,input_name).val('');
    //edit:can 20200713 用户界面选择部门(kehu001)
    CrmPopup.findHtmlobj(divid,input_name).html('');

}
function selectrelated_special(module,mid,entityname,fieldname,frommodule){
    getJsScript('include/js/popupselectfield.js',function(){
        selectrelateds_special(module,mid,entityname,fieldname,frommodule);
    });
}

function selectTabDetailRelated(obj,event){
    getJsScript('include/js/popupselectfield.js',function(){
        selectTabDetailRelateds(obj,event);
    });
}

function ShowSetUeryScop(userid){
    getJsScript('include/js/SetUeryScope.js',function(){
        ShowSetUeryScops(userid);
    });
}
function massDividends(obj,operationtype,idkey,stype){
    getJsScript('include/js/modules/DividendOrder/DividendOrder.js',function(){
        massDividend(obj,operationtype,idkey,stype);
    });
}

function InsertTemplate(obj){
    getJsScript('include/js/modules/Settings/Settings.js',function(){
        InsertTemplates(obj);
    });
}
/**
 * 判断是否允许编辑
 * @author Tujt 2015-06-26
 */
function check_edit_click(obj,module,record){
    var type = ld(obj).attr('type');
    var tag = ld(obj).attr('tag');
    var r_m = ld(obj).attr('r_m');
    var r_a = ld(obj).attr('r_a');
    var r_r = ld(obj).attr('r_r');
    var relatedid=ld(obj).attr("relatedid");//相关信息
    var isclick=ld(obj).attr("isclick");
    ld(obj).attr("isclick",'yes');
    EmptyProgressObjs();

    switch (type){
        case 'moduledetailapproves':

            var urlstring = 'module=Users&action=UsersAjax&file=callStaticMethod';
            urlstring += '&static=puyoung&method=checkEditInfo';
            urlstring += '&fld_module='+module+'&record='+record;
            RequestAjax(urlstring,function(rest){
                if(empty(rest)) return false;
                var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                if('SUCCESS' == restobj.check){
                    var url = 'module='+module+'&action=EditView&record='+record;
                    url += '&return_module='+r_m+'&return_action='+r_a+'';
                    if(r_r > 0){
                        url += '&return_id='+r_r;
                    }
                    DelProgressObjs();
                    if(module=="ServiceCharge")
                    {
                        PageRecordPopup.showpage(module,record,"");
                    }
                    else
                        redirect(url);
                }else{
                    // RemindsMsg("","LdPopWidth400px",module,"yes","yes",restobj.check);
                    MessagePopup.TipOne_warning(restobj.check);
                    DelProgressObjs();
                    return false;
                }
            });
            break;
        case 'approve'://审批
            if(isclick=='yes')
            {
                return ;
            }
            var urlstring = 'module=Users&action=UsersAjax&file=callStaticMethod';
            urlstring += '&static=puyoung&method=checkEditInfo';
            urlstring += '&fld_module='+module+'&record='+record;
            ldAjaxHtmlNoProgress('index.php',urlstring,function(ajaxhtml){
                ld(obj).attr("isclick",'no');
                if(empty(ajaxhtml)) return false;
                var restobj = eval('('+ ajaxhtml +')')?eval('('+ ajaxhtml +')'):JSON.parse(ajaxhtml);

                if(restobj.check.indexOf('SUCCESS')>=0){
                    var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
                    Popupobj.prevshow();
                    var url = 'module='+module+'&action=EditView&record='+record;
                    url += '&return_module='+r_m+'&return_action='+r_a+'';
                    if(r_r > 0){
                        url += '&return_id='+r_r;
                    }

                    //列表和相关信息编辑
                    if(relatedid>0||CrmPopup.getPopupObj("lastprev").type=='listpage'
                        ||CrmPopup.getPopupObj("lastprev").type=='relatedpagelist')
                    {
                        PageRecordPopup.params['refreshpage']='no';
                    }
                    if(CrmPopup.start_progressObjs.length<1){
                        ld('#rptContentLoading').show();
                    }
                    PageRecordPopup.showpage(module,record,"", PageRecordPopup.params);
                    //DelProgressObjs();
                }else{
                    // RemindsMsg("","LdPopWidth400px",module,"yes","yes",restobj.check);
                    MessagePopup.TipOne_warning(restobj.check);

                    DelProgressObjs();
                    return false;
                }
            });
            break;
        case 'moduledetailredirect':
            //33830: “采购订单”查看明细界面：点击“采购订单相关-采购退货单”单据操作列的“编辑”按钮，点击保存后的显示信息内容为“此记录已删除”
            var url = 'module='+module+'&action=EditView&record='+record;
            url += '&return_module='+r_m+'&return_action='+r_a+'&return_id='+r_r;
        /*var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
        Popupobj.prevshow();
        //列表和相关信息编辑
        if(relatedid>0||CrmPopup.getPopupObj("last").type=='listpage'
            ||CrmPopup.getPopupObj("last").type=='relatedpagelist'
            ||CrmPopup.getPopupObj("lastprev").type=='listpage'
            ||CrmPopup.getPopupObj("lastprev").type=='relatedpagelist')
        {
            PageRecordPopup.params['refreshpage']='no';
        }
        PageRecordPopup.showpage(module,record,"",PageRecordPopup.params);*/
        //用户列表编辑
        //  redirect(url);
        //  break;
        case 'redirect'://跳转
        case 'moduledetail'://39020: （kfbcrm）采购退款单、销售退款单编辑界面显示乱码
        case 'moduledetailapprove':

            var popupobj = CrmPopup.getPopupObj('last');

            var urlstring= '';
            //	RequestAjax(urlstring,function(rest){
            //editor:gyq_161 reason:带分录模块弹出层   2019/11/27 10:03
            var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
            Popupobj.prevshow();
            var url = 'module='+module+'&action=EditView&record='+record;
            url += '&return_module='+r_m+'&return_action='+r_a+'';
            if(module == 'Attachment'){
                var userid = ld('#userid').val();
                if(ld('#userid') != undefined){
                    url += '&swid='+userid;
                    url += '&return_id='+record;
                }
            }
            if(r_r > 0){
                //url += '&return_id='+r_r;
            }
            //列表和相关信息编辑
            if(relatedid>0||CrmPopup.getPopupObj("last").type=='listpage'
                ||CrmPopup.getPopupObj("last").type=='relatedpagelist'
                ||CrmPopup.getPopupObj("lastprev").type=='listpage'
                ||CrmPopup.getPopupObj("lastprev").type=='relatedpagelist')
            {
                PageRecordPopup.params['refreshpage']='no';
                if(relatedid > 0){
                    PageRecordPopup.params['relatedcreate']='yes';
                }
            }
            PageRecordPopup.showpage(module,record,"",PageRecordPopup.params);
            //redirect(url);
            //	});
            break;
        case 'checkstatus'://判断状态
            //先判断当前单据是否可编辑
            var urlstring = 'module=Users&action=UsersAjax&file=callStaticMethod';
            urlstring += '&static=puyoung&method=checkStatusInfo';
            urlstring += '&fld_module='+module+'&record='+record;
            RequestAjax(urlstring,function(rest){
                if(empty(rest)) return false;
                var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                if('SUCCESS' == restobj.check){
                    var url = 'module='+module+'&action=EditView&record='+record;
                    url += '&return_module='+r_m+'&return_action='+r_a+'';
                    if(r_r > 0){
                        url += '&return_id='+r_r;
                    }
                    //editor:gyq_161 reason:带分录模块弹出层   2019/11/27 9:41
                    var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
                    Popupobj.prevshow();
                    //列表和相关信息编辑
                    if(relatedid>0||CrmPopup.getPopupObj("last").type=='listpage'
                        ||CrmPopup.getPopupObj("last").type=='relatedpagelist'
                        ||CrmPopup.getPopupObj("lastprev").type=='listpage'
                        ||CrmPopup.getPopupObj("lastprev").type=='relatedpagelist')
                    {
                        PageRecordPopup.params['refreshpage']='no';
                    }
                    PageRecordPopup.showpage(module,record,"",PageRecordPopup.params);
                    DelProgressObjs();
                    //redirect(url);
                }else{
                    // RemindsMsg("","LdPopWidth400px",module,"yes","yes",restobj.check);
                    MessagePopup.TipOne_warning(restobj.check);

                    DelProgressObjs();
                    return false;
                }
            });
            break;
        case 'reply'://评论-回复
            var objparams=new CreatePagePopup.params();
            CreatePagePopup.showpage(module,"&reply_id="+record+"&topictype=reply",objparams);
            break;

    }
}


// ls 2021-09-16 【ID1001956】增加“电子签章”功能（创建电子签后台地址）
function CreateConsoleLoginUrl(module) {
    var url = 'index.php?module=Home&action=HomeAjax&file=ElectronicSignet&operation=CreateConsoleLoginUrl&frommodule='+module;
    ldAjax(url,"",function(data){
        // console.log(data);
        if(data.code == 1){
            window.open(data.result.ConsoleUrl);//跳转腾讯电子签后台后者企业认证激活开通
        }
        DelProgressObjs();
    })
}


//发起签署
//第一步：查询模板信息列表
function commonInitiateSigning(obj,record,module){//ld(obj).parents('tr').attr('record')
    var url = 'index.php?module=Home&action=HomeAjax&file=ElectronicSignet&operation=DescribeTemplates&record='+record+'&frommodule='+module;
    ldAjax(url,"",function(data){
        // console.log(data);
        if(data.code == 1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth400px",module,"","","","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,SelectFlowTemplate,"","LdPopWidth400px",module,[record,module],data.result.oktext,"",data.result.canceltext);
            // crmpopupobj.setOkfunParamObj(jspopup);
            crmPopupobj.show(data.result.content);
            // CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            return false;
        }
        DelProgressObjs();
    })
}

//选择合同模板
function SelectFlowTemplate(record,module){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var record = CrmPopup.findHtmlobj(divid,'record').val();
    var templatename = CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_flowtemplate').val();
    var templateid = CrmPopup.findHtmlobj(divid,'flowtemplate').val();
// console.log(ld("#"+divid+" [name=flowtemplate]").val());//选择的模板id
// console.log(ld("#"+divid+" [name=cmb_span_optiontext_flowtemplate]").val());//选择的模板名称

    if(templateid==''){
        var confirm_str = arrJsPopLabel['TEMPLATENAMECANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    // window.open("index.php?module=SalesOrder&action=SalesOrderAjax&file=ElectronicSignet&operation=FlowTemplateHtml&templatename="+templatename+"&templateid="+templateid+"&record="+record);
    // return;

    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
    crmPopupobj.prevshow();
    var urlstring = "index.php?module=Home&action=HomeAjax&file=ElectronicSignet&operation=FlowTemplateHtml&templatename="+templatename+"&templateid="+templateid+"&record="+record+'&frommodule='+module;
    ldAjax(urlstring,"",function(data){
        if(data.code == 1){
            // var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'SalesOrder',"","","","");
            // crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,CreateFlowsByTemplates,"","LdPopWidth800px",module,[module],data.result.oktext,"",data.result.canceltext);
            crmPopupobj.createScrollDiv();//创建滚动条
            crmPopupobj.show(data.result.content);
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            return false;
        }
        // popupobj.CancelEvent();
        DelProgressObjs();

    })

}

//创建合同
function CreateFlowsByTemplates(module){
    // var firstpopupobj = CrmPopup.getPopupObj('first');
    var prevpopupobj = CrmPopup.getPopupObj('lastprev');
    var popupobj = CrmPopup.getPopupObj("last");
    var record = CrmPopup.findHtmlobj(popupobj.divid,'record').val();

    if (empty(CrmPopup.findHtmlobj(popupobj.divid,'FlowName').val())
        || empty(CrmPopup.findHtmlobj(popupobj.divid,'Deadline').val())
    ) {
        // var confirm_str = arrJsPopLabel['TEMPLATENAMECANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",'带星号(*)为必填项，请检查');
        return false;
    }

    var formValues = ld('#' + popupobj.divid + ' [name=createflow]').serialize();
    // var ajaxurl = 'index.php?module=SalesOrder&action=SalesOrderAjax&file=ElectronicSignet&operation=CreateFlowsByTemplates&record=' + record;
    var ajaxurl = 'index.php?module=Home&action=HomeAjax&file=ElectronicSignet&operation=CreateFlowsByTemplates&frommodule='+module+'&record='+record;

    ldAjax(ajaxurl, formValues, function (data) {
        if(data.code == 1){
            popupobj.CancelEvent();
            prevpopupobj.CancelEvent();//关闭两层弹框
            // window.open(data.result.ConfirmUrl);//跳转合同确认页面。确认的回调地址为 获取跳转小程序签署链接
            audioRemindsMsg("","","","","","合同创建成功");
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            return false;
        }
        DelProgressObjs();

        //返回数据 刷新列表页和详细页
        popupobj.record = record;
        var tmparra = new Array();
        tmparra.push(popupobj.record);
        console.log('刷新数据popupobj.module：',popupobj.module);
        var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, "", tmparra);
        // var refreshlistmodules = new Array('SalesOrder');
        var refreshlistmodules = new Array(popupobj.module);
        tmpobj.eachrefreshlistbyModules(refreshlistmodules);
        // tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);   //更新合同状态的值，为腾讯电子签回调事件之后


    })
}

//预览合同--签署完成
function PreviewContract(obj,record,module){
    // var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignet&operation=CreateConsoleLoginUrl&type=PreviewContract&record='+record;
    var url = 'index.php?module=Home&action=HomeAjax&file=ElectronicSignet&operation=CreateConsoleLoginUrl&type=PreviewContract&record='+record+'&frommodule='+module;
    ldAjax(url,"",function(data){
        if(data.code == 1){
            window.open(data.result.ConsoleUrl);//跳转腾讯电子签后台预览合同
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            return false;
        }
        DelProgressObjs();
    })

}

//ls 2024-03-20 XUQIU20240315-05 契约锁接口
function commonInitiateSigningQys(obj,record,module){//ld(obj).parents('tr').attr('record')
    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetQys&operation=showHtmlByFile&record='+record+'&frommodule='+module;//createbyfile
    ldAjax(url,"",function(data){
        // console.log(data);
        if(data.code == 1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,SaveDocumentIdByFile,"","LdPopWidth600px",module,[record,module],data.result.oktext,"",data.result.canceltext);
            // crmpopupobj.setOkfunParamObj(jspopup);
            crmPopupobj.show(data.result.content);
            // CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
        }else{
            RemindsMsg("","LdPopWidth600px","","yes","yes",data.msg);
            return false;
        }
        DelProgressObjs();
    })
}
function SaveDocumentIdByFile(record,module){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var record = CrmPopup.findHtmlobj(divid,'record').val();

    var flowfile = CrmPopup.findHtmlobj(divid,'flowfile').val();
    var flowtitle = CrmPopup.findHtmlobj(divid,'flowtitle').val().trim();
    // console.log(flowfile);

    if(flowfile==''){
        // var confirm_str = arrJsPopLabel['TEMPLATENAMECANOTEMPTY'];
        var confirm_str = '请上传签署文档';
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }else if (flowtitle == '') {
        var confirm_str = '签署文档名称不能为空';
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    // window.open("index.php?module=SalesOrder&action=SalesOrderAjax&file=ElectronicSignet&operation=FlowTemplateHtml&templatename="+templatename+"&templateid="+templateid+"&record="+record);
    // return;

    var formData = new FormData();
    formData.append('flowtitle', flowtitle);
    formData.append('flowfile', ld("#"+popupobj.divid+" [name=flowfile]").get(0).files[0]);
    console.log(formData);
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
    crmPopupobj.prevshow();
    var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetQys&operation=createbyfile&record='+record+'&frommodule='+module;
    // ldAjax(urlstring,{'flowfile':flowfile,'flowtitle':flowtitle},function(data){
    ldAjax_File(urlstring,formData,function(data){
        if(data.code == 1){
            var documentId = data.result.documentId;
            crmPopupobj.setParams(data.result.title,CreateFlowsByDocumentId,"","LdPopWidth800px",module,[module,documentId],data.result.oktext,"",data.result.canceltext);
            crmPopupobj.createScrollDiv();//创建滚动条
            crmPopupobj.show(data.result.content);

            CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories[tenantType]').unbind('change').on('change', function () {
                var tenantType = ld(this).val();
                if (tenantType == 'COMPANY') {//签署方类型
                    CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories[receiverName]').closest('tr').css('display','');
                    CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories_actions_type').closest('tr').css('display','');
                }else{
                    CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories[receiverName]').closest('tr').css('display','none');
                    CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories_actions_type').closest('tr').css('display','none');
                }
            });
            CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories[tenantType]').change();

            tooltip('.tip-items-list', {transition: true, time: 200});
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            return false;
        }
        // popupobj.CancelEvent();
        DelProgressObjs();

    })

}

//创建合同通过上一步的签署文档id
function CreateFlowsByDocumentId(module,documentId){
    var prevpopupobj = CrmPopup.getPopupObj('lastprev');
    var popupobj = CrmPopup.getPopupObj("last");
    var record = CrmPopup.findHtmlobj(popupobj.divid,'record').val();

    if (empty(CrmPopup.findHtmlobj(popupobj.divid,'subject').val())
        || empty(CrmPopup.findHtmlobj(popupobj.divid,'tenantName').val())
        || empty(CrmPopup.findHtmlobj(popupobj.divid,'signatories[tenantName]').val())
        || empty(CrmPopup.findHtmlobj(popupobj.divid,'signatories[contact]').val())
    ) {
        // var confirm_str = arrJsPopLabel['TEMPLATENAMECANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",'带星号(*)为必填项，请检查');
        return false;
    }
    if (CrmPopup.findHtmlobj(popupobj.divid,'signatories[tenantType]').val() == 'COMPANY') {
        if (empty(CrmPopup.findHtmlobj(popupobj.divid,'signatories[receiverName]').val())) {
            RemindsMsg("","LdPopWidth400px","","yes","yes",'签署方为组织时，经办人姓名必填，请检查');
            return false;
        }
    }

    var formValues = ld('#' + popupobj.divid + ' [name=createflow]').serialize();
    var ajaxurl = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetQys&operation=CreateFlowsByDocumentId&frommodule='+module+'&record='+record;
    ldAjax(ajaxurl, formValues, function (data) {
        if(data.code == 1){
            popupobj.CancelEvent();
            prevpopupobj.CancelEvent();//关闭两层弹框
            // window.open(data.result.ConfirmUrl);//跳转合同确认页面。确认的回调地址为 获取跳转小程序签署链接
            audioRemindsMsg("","","","","","创建电子签约成功");
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            return false;
        }
        DelProgressObjs();

        //返回数据 刷新列表页和详细页
        popupobj.record = record;
        var tmparra = new Array();
        tmparra.push(popupobj.record);
        console.log('刷新数据popupobj.module：',popupobj.module);
        var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, "", tmparra);
        // var refreshlistmodules = new Array('SalesOrder');
        var refreshlistmodules = new Array(popupobj.module);
        tmpobj.eachrefreshlistbyModules(refreshlistmodules);
        // tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);   //更新合同状态的值，为腾讯电子签回调事件之后


    })
}

//预览合同--签署完成
function PreviewContractQys(obj,record,module){
    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetQys&operation=ContractViewurl&record='+record+'&frommodule='+module;
    ldAjax(url,"",function(data){
        if(data.code == 1){
            window.open(data.result.viewUrl);
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            return false;
        }
        DelProgressObjs();
    })

}

//创建合同 契约锁saas版
function CreateFlowSaasQys(){
    var that = this;
    //步骤一 创建草稿（生成签署页面）
    this.CreateDraftHtml = function(obj,record,module){
        var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetSaasQys&operation=createDraftHtml&record='+record+'&frommodule='+module;
        ldAjax(urlstring,'',function(data){
            if(data.code == 1){
                var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
                crmPopupobj.prevshow();
                crmPopupobj.setParams(data.result.title,that.CreateDraft,"","LdPopWidth800px",module,[record,module],data.result.oktext,"",data.result.canceltext);
                crmPopupobj.createScrollDiv();//创建滚动条
                crmPopupobj.show(data.result.content);

                CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories[tenantType]').unbind('change').on('change', function () {
                    var tenantType = ld(this).val();
                    if (tenantType == 'COMPANY') {//签署方类型
                        CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories[receiverName]').closest('tr').css('display','');
                        CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories_actions_type').closest('tr').css('display','');
                    }else{
                        CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories[receiverName]').closest('tr').css('display','none');
                        CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories_actions_type').closest('tr').css('display','none');
                    }
                });
                CrmPopup.findHtmlobj(crmPopupobj.divid,'signatories[tenantType]').change();

                tooltip(ld("#"+crmPopupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            }
            // popupobj.CancelEvent();
            DelProgressObjs();

        })
    }

    this.CreateDraft = function(record,module){
        var popupobj = CrmPopup.getPopupObj("last");
        if (empty(CrmPopup.findHtmlobj(popupobj.divid,'subject').val())
            || empty(CrmPopup.findHtmlobj(popupobj.divid,'tenantName').val())
            || empty(CrmPopup.findHtmlobj(popupobj.divid,'creatorInfo[mobile]').val())
            || empty(CrmPopup.findHtmlobj(popupobj.divid,'signatories[tenantName]').val())
            || empty(CrmPopup.findHtmlobj(popupobj.divid,'signatories[contact]').val())
        ) {
            RemindsMsg("","LdPopWidth400px","","yes","yes",'带星号(*)为必填项，请检查');
            return false;
        }
        if (CrmPopup.findHtmlobj(popupobj.divid,'signatories[tenantType]').val() == 'COMPANY') {
            if (empty(CrmPopup.findHtmlobj(popupobj.divid,'signatories[receiverName]').val())) {
                RemindsMsg("","LdPopWidth400px","","yes","yes",'签署方为公司时，经办人姓名必填，请检查');
                return false;
            }
        }

        var formValues = ld('#' + popupobj.divid + ' [name=createdraft]').serialize();

        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetSaasQys&operation=createDraft&record='+record+'&frommodule='+module;//createbyfile
        ldAjax(url,formValues,function(data){
            // console.log(data);
            if(data.code == 1){
                var contractId = data.result.contractId;
                var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
                crmPopupobj.prevshow();
                crmPopupobj.setParams(data.result.title,that.addbyfile,"","LdPopWidth600px",module,[record,module,contractId],data.result.oktext,"",data.result.canceltext);
                crmPopupobj.show(data.result.content);

                tooltip(ld("#"+crmPopupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
            }else{
                RemindsMsg("","LdPopWidth600px","","yes","yes",data.msg);
                return false;
            }

            DelProgressObjs();
        })
    }

    this.addbyfile = function(record,module,contractId){
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;

        var flowfile = CrmPopup.findHtmlobj(divid,'flowfile').val();
        // console.log(flowfile);

        if(flowfile==''){
            var confirm_str = '请上传合同文档';
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }

        var formData = new FormData();
        formData.append('contractId', contractId);
        formData.append('flowfile', ld("#"+popupobj.divid+" [name=flowfile]").get(0).files[0]);
        //console.log(formData);

        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetSaasQys&operation=addbyfile&record='+record+'&frommodule='+module;
        ldAjax_File(url,formData,function(data){
            if(data.code == 1){
                //popupobj.CancelEvent();
                //prevpopupobj.CancelEvent();//关闭两层弹框

                // var contractId = data.result.contractId;
                var documentId = data.result.documentId;
                that.ContractSend(record,module,contractId,documentId);

            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            }
            DelProgressObjs();

        })

    }

    //发起合同
    this.ContractSend = function(record,module,contractId,documentId){
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        var popupobj=CrmPopup.getPopupObj("last");

        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetSaasQys&operation=contractSend&record='+record+'&frommodule='+module+'&contractId='+contractId+'&documentId='+documentId;
        ldAjax(url,'',function(data){
            if(data.code == 1){
                popupobj.CancelEvent();
                prevpopupobj.CancelEvent();//关闭两层弹框

                audioRemindsMsg("","","","","","创建合同成功");
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            }
            DelProgressObjs();

            //返回数据 刷新列表页和详细页
            popupobj.record = record;
            var tmparra = new Array();
            tmparra.push(popupobj.record);
            console.log('刷新数据popupobj.module：',popupobj.module);
            var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, "", tmparra);
            var refreshlistmodules = new Array(popupobj.module);
            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
            // tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);   //更新合同状态的值

        })

    }
    //浏览页面
    this.PreviewContract = function(obj,record,module){
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetSaasQys&operation=ContractViewurl&record='+record+'&frommodule='+module;
        ldAjax(url,"",function(data){
            if(data.code == 1){
                OpenNewWebTab(data.result.pageUrl);
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            }
            DelProgressObjs();
        })

    }

    //下载合同
    this.DownloadContract = function(obj,record,module){
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetSaasQys&operation=downloadContract&record='+record+'&frommodule='+module;
        OpenNewWebTab(url);
    }

}

var CreateFlowSaasQysObj = new CreateFlowSaasQys();
/*CreateFlowSaasQys.getInstance = function(){
    if(CreateFlowSaasQys.CreateFlowSaasQysObj == undefined){
        CreateFlowSaasQys.CreateFlowSaasQysObj = new CreateFlowSaasQys();

    }
    return CreateFlowSaasQys.CreateFlowSaasQysObj;
}*/

//创建合同 法大大
function CreateFlowFdd(){
    var that = this;
    //步骤一 创建上传文件页面
    this.CreateUploadFileHtml = function(obj,record,module){
        var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetFdd&operation=CreateUploadFileHtml&record='+record+'&frommodule='+module;
        ldAjax(urlstring,'',function(data){
            if(data.code == 1){
                var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
                crmPopupobj.prevshow();
                crmPopupobj.setParams(data.result.title,that.UploadFile,"","LdPopWidth600px",module,[record,module],data.result.oktext,"",data.result.canceltext);
                crmPopupobj.createScrollDiv();//创建滚动条
                crmPopupobj.show(data.result.content);

                tooltip(ld("#"+crmPopupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
            }else{
                MessagePopup.TipOne_warning(data.msg);
                return false;
            }
            // popupobj.CancelEvent();
            DelProgressObjs();

        })
    }

    this.UploadFile = function(record,module){
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;

        var flowfile = CrmPopup.findHtmlobj(divid,'flowfile').val();
        // console.log(flowfile);

        if(flowfile==''){
            var confirm_str = '请上传合同文档';
            MessagePopup.TipOne_warning(confirm_str);
            return false;
        }

        var formData = new FormData();
        formData.append('flowfile', ld("#"+popupobj.divid+" [name=flowfile]").get(0).files[0]);
        //console.log(formData);

        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetFdd&operation=UploadFile&record='+record+'&frommodule='+module;
        ldAjax_File(url,formData,function(data){
            if(data.code == 1){
                //popupobj.CancelEvent();
                //prevpopupobj.CancelEvent();//关闭两层弹框

                var fddFileUrl = data.result.fddFileUrl;
                var fileId = data.result.fileId;

                var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
                crmPopupobj.prevshow();
                crmPopupobj.setParams(data.result.title,that.CreateSignTask,"","LdPopWidth800px",module,[record,module,fddFileUrl,fileId],data.result.oktext,"",data.result.canceltext);
                crmPopupobj.createScrollDiv();//创建滚动条
                crmPopupobj.show(data.result.content);


                tooltip(ld("#"+crmPopupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
            }else{
                MessagePopup.TipOne_warning(data.msg);
                return false;
            }
            DelProgressObjs();

        })

    }

    this.CreateSignTask = function(record,module,fddFileUrl,fileId){
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        var popupobj = CrmPopup.getPopupObj("last");
        if (empty(CrmPopup.findHtmlobj(popupobj.divid,'signTaskSubject').val())
            || empty(CrmPopup.findHtmlobj(popupobj.divid,'actorName').val())
            // || empty(CrmPopup.findHtmlobj(popupobj.divid,'memberId').val())
            || empty(CrmPopup.findHtmlobj(popupobj.divid,'actors[actorName]').val())
            || empty(CrmPopup.findHtmlobj(popupobj.divid,'actors[notifyAddress]').val())
        ) {
            MessagePopup.TipOne_warning('带星号(*)为必填项，请检查');
            return false;
        }

        if (!empty(CrmPopup.findHtmlobj(popupobj.divid,'expiresTime').val()) && !empty(CrmPopup.findHtmlobj(popupobj.divid,'dueDate').val())) {
            if (new Date(CrmPopup.findHtmlobj(popupobj.divid,'expiresTime').val()) >= new Date(CrmPopup.findHtmlobj(popupobj.divid,'dueDate').val())) {
                MessagePopup.TipOne_warning('合同到期日期应该大于截止日期');
                return false;
            }
        }

        var formValues = ld('#' + popupobj.divid + ' [name=createsigntask]').serialize();

        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetFdd&operation=CreateSignTask&record='+record+'&frommodule='+module+'&fddFileUrl='+fddFileUrl+'&fileId='+fileId;
        ldAjax(url,formValues,function(data){
            // console.log(data);
            if(data.code == 1){
                popupobj.CancelEvent();
                prevpopupobj.CancelEvent();//关闭两层弹框

                MessagePopup.TipZero_success("创建合同成功");
            }else{
                MessagePopup.TipOne_warning(data.msg);
                return false;
            }

            DelProgressObjs();

            //返回数据 刷新列表页和详细页
            popupobj.record = record;
            var tmparra = new Array();
            tmparra.push(popupobj.record);
            var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, "", tmparra);
            var refreshlistmodules = new Array(popupobj.module);
            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
            // tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);   //更新合同状态的值
        })
    }

    //预览合同
    this.PreviewContract = function(obj,record,module){
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=ElectronicSignetFdd&operation=ContractViewurl&record='+record+'&frommodule='+module;
        ldAjax(url,"",function(data){
            if(data.code == 1){
                OpenNewWebTab(data.result.signTaskPreviewUrl);
            }else{
                MessagePopup.TipOne_warning(data.msg);
                return false;
            }
            DelProgressObjs();
        })

    }

}
var CreateFlowFddObj = new CreateFlowFdd();
/**
 * 取消关联
 * @author Liver 2017-01-16
 */
function check_delassociated_click(obj,module,record){
    var type = ld(obj).attr('type');
    var tag = ld(obj).attr('tag');
    var r_m = ld(obj).attr('r_m');
    var r_a = ld(obj).attr('r_a');
    var r_r = ld(obj).attr('r_r');
    var relatedid = ld(obj).attr('relatedid');

    var confirm_str = arrJsPopLabel['AREYOUSUREYOUWANTTOCANCELTHECONNECTION'];//提示内容
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        if(r_r > 0){
            var url = 'module=Users&action=UsersAjax&file=delAssociated';
            url += '&record='+r_r+'&delrecord='+record;
            url += '&delmodule='+module+'&return_module='+r_m+'&return_action='+r_a+'';
            var popupobj=CrmPopup.getPopupObj("last");

            new Ajax.Request
            (
                'index.php',
                {
                    queue: {
                        position: 'end',
                        scope: 'command'
                    },
                    method: 'post',
                    postBody:url,
                    onComplete: function(response)
                    {
                        var tmparra=new Array();

                        var tmpobj= new AfterUpdatePrevPopupObjContent(module,getEmptyValueInfo(),tmparra);
                        tmparra=[module];
                        tmpobj.eachrefreshlistbyModules(tmparra);
                        //DetailViewRelation.refresh_relatedlist('Accounts');
                        //resetRelated(relatedid);
                        //set_rel_count();
                        //取消关联不要刷新界面
                        // history.go(0);

                    }
                }
            )
        }
    })
}
/**
 * 判断是否允许删除
 * @author Tujt 2015-06-26
 */
function check_del_click(obj,module,record){
    var type = ld(obj).attr('type');
    var tag = ld(obj).attr('tag');
    var r_m = ld(obj).attr('r_m');
    var r_a = ld(obj).attr('r_a');
    var r_r = ld(obj).attr('r_r');
    var attach_id = ld(obj).attr('attach_id');
    var relatedid = ld(obj).attr('relatedid');

    if(module=='CashBill'||module=='SendCashBill')
    {
        //16868: 客户>明细>收款单：已经审核的收款单，可以删除。
        type='approve';
    }
    var objdiv_content = arrJsPopLabel['SUREWANTDELETE'];//提示内容
    var popupobj=CrmPopup.getPopupObj('last');
    RemindsMsg("","LdPopWidth400px","","yes","yes",objdiv_content);


    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        switch (type){
            case 'approve'://审批

                var urlstring = 'module=Users&action=UsersAjax&file=callStaticMethod';
                urlstring += '&static=puyoung&method=checkDelInfo';
                urlstring += '&fld_module='+module+'&record='+record;

                RequestAjax(urlstring,function(rest){
                    if(empty(rest)) return false;
                    var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                    if('SUCCESS' == restobj.check){
                        var url = 'module='+module+'&action='+module+'Ajax&file=Delete';
                        url += '&record='+record+'&delrecord='+record;
                        url += '&return_module='+r_m+'&return_action='+r_a+'';
                        if(relatedid > 0){
                            url += '&relatedid='+relatedid;
                        }
                        if(r_r > 0){
                            url += '&return_id='+r_r;
                        }
                        DelProgressObjs();
                        RequestAjax(url,function(rest){
                            //wym BUG0072048 kfbcrm-客户-关联创建联系人 删除联系人报错
                            var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                            //wym BUG0073486 部分模块的delete不返回success的msg,所以改用code判断
                            if(rest.indexOf("##YES##")<0 && restobj.code!=1){
                                RemindsMsg("","LdPopWidth400px","","yes","yes",restobj.log.value);
                                DelProgressObjs();
                            }else{
                                var tmparra=new Array();

                                if(popupobj.type==RelateListPage.type&&popupobj.balanceaccountobj!=undefined){
                                    popupobj.module=module;//往来对账
                                }
                                var tmpobj= new AfterUpdatePrevPopupObjContent(module,getEmptyValueInfo(),tmparra);
                                tmparra=[popupobj.module];
                                tmpobj.eachrefreshlistbyModules(tmparra);
                                //resetRelated(relatedid);
                                DelProgressObjs();
                            }
                        });
                        ///	redirect(url);
                    }else{
                        RemindsMsg("","LdPopWidth400px","","yes","yes",restobj.check);
                        DelProgressObjs();
                        return false;
                    }
                });
                break;
            case 'redirect'://跳转

                var url = 'module='+module+'&action='+module+'Ajax&file=Delete';
                url += '&record='+record+'&delrecord='+record;
                url += '&return_module='+r_m+'&return_action='+r_a+'';
                if(module == 'Attachment'){
                    url += '&attach_detailid='+attach_id;
                }
                if(r_r > 0){
                    //服务单 - 相关信息 - 常见问题 - 删除常见问题关联关系   //case为approve的都没有这个操作，delHelpDeskFaq.php也没有删除单据
                    /*if(module=='Faq'&&(typeof(relatedid) != "undefined"&&relatedid>0)){
                        url = 'module='+module+'&action='+module+'Ajax&file=delHelpDeskFaq&record='+record+'&delrecord='+record+'&return_module='+r_m+'&return_action='+r_a+'&relatedid='+relatedid;
                    }*/
                    url += '&return_id='+r_r;
                    url += '&resetRelated=ajax';
                    RequestAjax(url,function(rest){
                        //wym BUG0072048 kfbcrm-客户-关联创建联系人 删除联系人报错
                        var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                        //wym BUG0073486 部分模块的delete不返回success的msg,所以改用code判断
                        if(rest.indexOf("##YES##")<0 && restobj.code!=1){
                            RemindsMsg("","LdPopWidth400px","","yes","yes",restobj.log.value);
                            DelProgressObjs();
                        }else{

                            if(popupobj.type==RelateListPage.type&&popupobj.balancetrobj!=undefined){
                                popupobj.module=module;//往来对账
                            }
                            //editor:gyq_20200310 reason:明细界面相关单据序时簿删除后，刷新弹出层内容
                            // 0039530: (51mis.com/kfbtest)客户模块>序列表界面>选择单据编号为“adminACC16”进入明细界面：相关点击“联系人”，操作点击“删除”按钮，提示框点击确认后，联系人单据还在此界面（实际是已经删除了的）
                            var tmparra={};
                            var tmpobj= new AfterUpdatePrevPopupObjContent(module,rest,tmparra);
                            var tmpmodules=[module];
                            tmpobj.eachrefreshlistbyModules(tmpmodules);
                            DelProgressObjs();
                        }
                    });
                    return false;
                    //}
                }
                //	redirect(url);
                break;
        }
    });
}
/**
 更新操作
 edit:andrew
 date:20131230
 reason:新增多选
 **/
function contact_btn_Email()
{

    if(document.getElementById('contactid').value>0){
        var contactid = document.getElementById('contactid').value;
    }else{
        contactid = checkbox();
        contactid = contactid.substring(0,contactid.length-1) ;
    }
    if(ld("#popup_rows_selectall").val()=='all')
    {
        //edit:can 2020-11-09 043164: (61mis.com/kfbcrm/index.php)营销-群发邮件-添加联系人（需要补丁）；在操作群发邮件选择联系人时，左侧勾选权限框后，显示所有单据的条数，但点击选择后只是显示列表中的联系人email；需选择全部联系人email
        contactid='all';
    }

    //获取所有的弹出框里选择的条目
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    prevdivid=prevpopupobj.divid;
    var popupobj=CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    var num_rows = CrmPopup.findHtmlobj(prevdivid,'row_of_checkbox_contact_pop_email').val();

    var tabid_fieldlabel ="";
    for(var i=0;i<num_rows;i++)
    {
        var id = i+'_checkbox_pop_email';
        //34911: （1.6登录）群发邮件选择联系人模块和成员管理模块接收人Email：勾选单据选择接收人Email时带不出接收人Email字段值
        var id_check = CrmPopup.findHtmlobj(divid,id).prop("checked");
        //选中的项目进行处理
        if(id_check)
        {
            tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
        }
    }
    var popup_type = '';
    if(document.getElementById('popup_type') != undefined){
        popup_type = document.getElementById('popup_type').value;
    }
    var surl = "index.php?module=Emails&action=EmailsAjax&file=checkbox_checkcontact&tabid_fieldlabel="+tabid_fieldlabel+"&allids="+contactid+"&popup_type="+popup_type;
    ldAjax(surl,"",function(data){
        if(data.code == 1){
            var popupobj=CrmPopup.getPopupObj("last");
            popupobj.CancelEvent();
            var popupobj=CrmPopup.getPopupObj("last");
            popupobj.CancelEvent();
            if(CrmPopup.getPopupObj('last') != undefined){
                var prevpopupobj=CrmPopup.getPopupObj('last');
                prevdivid=prevpopupobj.divid;
                var parent_name = CrmPopup.findHtmlobj(prevdivid,'parent_name').val();
                CrmPopup.findHtmlobj(prevdivid,'parent_name').val(parent_name+data.result.content);
            }else{
                if(ld('#parent_name') != undefined){
                    var parent_name = ld('#parent_name').val();
                    ld('#parent_name').val(parent_name+data.result.content);
                }
            }
            //用来提交的时候替换模板里面的字段的参数
            if(CrmPopup.findHtmlobj(prevdivid,'tabid_fieldlabel_btn_listview_email').val() != undefined){
                CrmPopup.findHtmlobj(prevdivid,'tabid_fieldlabel_btn_listview_email').val(data.result.content);
            }
            if(CrmPopup.findHtmlobj(prevdivid,'accountid_btn_listview_email').val() != undefined){
                CrmPopup.findHtmlobj(prevdivid,'accountid_btn_listview_email').val(tabid_fieldlabel);
            }
        }
        DelProgressObjs();
    })
    return false;
}


function show_contactEmailList(contactid)
{
    document.getElementById('contactid').value = contactid;
    var pmodule = document.selectall.pmodule.value;
    var crmPopupobj=CreatePagePopup.load("","","","LdPopWidth350px",'Emails',"","","","");
    crmPopupobj.prevshow();
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    var urlstring = 'index.php?module='+ pmodule +'&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=set_return_emails&select=enable&popup=yes&page_popup=yes&sendgroupemail=yes';
    ldAjax(urlstring,'',function(data) {
        DelProgressObjs()
        if(data.code==1)
        {
            if(data.result.mail_field <=0 || data.result.mail_field == ''){
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['themodulehasenotemailfield']);
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    cancelCrmPopup();
                });

                return false;
            }
            crmPopupobj.setParams(data.result.title,'',"","LdPopWidth350px",'Emails',"","","","");
            crmPopupobj.show(data.result.content);
        }
    })
    return false;
}

function selectprojecttask(mod){
    getJsScript('include/js/popupselectfield.js',function(){
        selectprojecttask(mod);
    });
}
//客户相关信息 - 邮件管理-发送邮件
function sendmail(module,idstrings){
    getJsScript('include/js/Mail.js',function(){
        sendmails(module,idstrings)
    });

}
// ls 2021-11-09 【ID1002161】模块相关信息邮件管理功能优化（用友-马朝军）(收取邮件)
function receivemail(){
    var popupobj = CrmPopup.getPopupObj('last');
    getJsScript('include/js/modules/Emails/EmailList.js',function(){
        email_account_id=0;
        email_listdb_type='pop';

        var url ='index.php?module=Emails&action=EmailsAjax&file=getUndownloadmail&account_id='+email_account_id;
        ldAjax(url, "", function (data) {
            if(data.code==1)
            {
                var  cur_t=0;
                var total_len=0;
                if(data.result.popusers!=undefined&& data.result.popusers.length>0)
                {
                    //获取需要下载的邮件总数量
                    for(var i=0;i<data.result.popusers.length;i++)
                    {
                        var popuser=data.result.popusers[i]['popuser'];
                        total_len=data.result[popuser].list.length+total_len;
                    }

                    for(var i=0;i<data.result.popusers.length;i++)
                    {
                        var popuser=data.result.popusers[i]['popuser'];

                        if(data.result[popuser].list.length>0)
                        {


                            for(var j=0;j<data.result[popuser].list.length;j++)
                            {
                                cur_t++;
                                seqno=data.result[popuser].list[j];
                                getUnDownLoadEmailContent(data.result.popusers[i]['account_id'],seqno);
                            }
                        }
                    }


                }

                //zsk BUG20240306-58 客户相关信息邮件管理列表，点击“收取邮件”后，提示信息中的图片显示错误
                MessagePopup.TipTwo_success("收取邮件完成");
                //点击确定  刷新邮件列表
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    DetailViewRelation.searchByPopupobj(popupobj);
                });
            }
        });
    });

}

function setDuplicate(module,frommodule){
    getJsScript('include/js/popupselectfield.js',function(){
        setDuplicates(module,frommodule);
    });
}

//获取帮助对应的链接url
function getLinksUrl(module,linktype,linklabel){
    ld.ajax('index.php?module=Users&action=UsersAjax&file=getLinksUrl&curmodule='+module+'&linktype='+linktype+'&linklabel='+linklabel+'')
        .done(function(linkurl){
            if(linkurl != ''){
                window.open(linkurl);
                return false;
            }
        })
}

/**
 更新操作
 edit:cyb
 date:2015-10-27
 reason:客户模块界面，查重按钮事件。
 **/
function look_check_repeat(obj,module)
{



    getJsScript('include/js/popupselectfield.js',function(){
            look_check_repeats(obj,module);
        }
    );

}
look_check_repeat.pagetype='editview';

/* editor:gyq_12  reason:显示列设置按钮 date:20160531*/
function button_setDuplicateColumnDisplay(module,frommodule){
    getJsScript('include/js/modules/Accounts/setDuplicateColumnDisplay.js',function(){
        setDuplicateColumnDisplay.getInstance().button_setColumnDisplay(module,frommodule);
    });
}
//客户模块界面，查重按钮。
function search_account(obj,module)
{
    getJsScript('include/js/popupselectfield.js',function(){
        search_accounts(obj,module);
    });

}


/*
*新增操作 by andy
*联系记录新增服务单字段，弹出窗
*date:20140108
*/
function selecttroubleticket(mod)
{
    // To support both B2B and B2C model
    var record_id = '';
    var parent_module = '';
    //0017453: 客户/销售机会>序时簿,关于跟进时选择服务单的问题
    if(document.QcEditView != undefined){
        var acc_element = document.QcEditView.account_id;
        var module=document.QcEditView.module.value;
    }else{
        var acc_element = document.EditView.account_id;
        var module=document.EditView.module.value;
    }
    var accountid;
    if (acc_element != null) {
        record_id= acc_element.value;
        parent_module = 'Accounts';
    }
    var urlstring = '';
    if(record_id != ''){
        urlstring = "index.php?module=HelpDesk&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&accountid="+record_id+"&parent_module="+parent_module+"&fromModule=1&frommodule="+mod;
    }else{
        urlstring = "index.php?module=HelpDesk&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&frommodule="+mod;
    }
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
    window.open(urlstring,"test","width=840,height=602,resizable=1,scrollbars=1");

}
//@edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志(保存预览日志)
function savePreviewlog(record,fileId,module,filename,lineitem_id = 0){
    ldAjaxNoProgress("index.php?module=uploads&action=Preview_now&ReportHeader=DHeader&record="+record+"&fileId="+fileId+"&frommodule="+module+"&is_target=no"+"&lineitem_id="+lineitem_id,{},function(data){
    })
}
//@edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志(预览操作日志的显示与隐藏动作)
function toggleLogShowHide(operator){
    if (ld('tr[name="fileoperationlog_'+operator+'"]') !='undefined'){
        if (ld('tr[name="fileoperationlog_'+operator+'"]').is(':hidden')) {
            ld('tr[name="fileoperationlog_'+operator+'"]').show();
        }else{
            ld('tr[name="fileoperationlog_'+operator+'"]').hide();
        }
        var popupobj = CrmPopup.getPopupObj("last"); //居中
        popupobj.center();
    }
}
// @edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志(选择操作人)FileReadHistory
function selectOperator(obj) {
    var popupobj = CrmPopup.getPopupObj("last");
    var fileId = ld("#" + popupobj.divid + " [name=fileId]").val();
    var module = ld("#" + popupobj.divid + " [name=frommodule]").val();
    var operating_type = ld("#" + popupobj.divid + " [name=operating_type]").val();
    var operator = obj.value;
    var surl = 'index.php?module=' + module + '&action='+module+'Ajax&file=FileOperationLog&ReportHeader=DHeader&ajax=yes&fileId=' + fileId + '&frommodule=' + module + '&operating_type=' + operating_type;
    if (!empty(operator)) {
        surl += '&operator=' + operator;
    }
    ldAjax(surl, "", function (data) {
        if (data.code == 1) {
            ld("#" + popupobj.divid + " [name=file_operation_log_detail]").html(data.result.content);
        }
        DelProgressObjs();
    })
}

// @edit:liushuai,2021-04-14,reason:【ID1001518】PC端，附件视频增加在线预览功能
function preview_video(fileId) {
    var popupobj = CrmPopup.getPopupObj("last"), ele,
        videoObj = ld("#" + popupobj.divid).find("#video_"+fileId);
    //zkt 20230630 BUG0069013 销售订单B 单据详细里面无法预览视频但是在列表中可以预览（TK2023063057560）建议多拿几个单据试下（附件）
    if(videoObj.length > 0){
        ele = videoObj.get(0);//video标签给个id
    }
    else{
        ele = document.getElementById('video_'+fileId);//video标签给个id
    }
    // console.log(ele);
    preview_fullscreen(ele);
    ele.play(); //播放视频

    // @edit:liushuai,2021-04-16,reason: 0045499：（61mis.com/kfbcrm）附件-单据编号ATT102，单据列表处，点击预览视频附件，没有打开视频
    // @edit:liushuai,2021-04-21,reason: 0045554: （61mis.com/kfbcrm）客户管理-跟进记录；单据编号LXJL628，相关信息附件管理列表处，点击预览附件视频，没有显示视频(模块的相关页签为附件模块)
    //edit: xll 2023/09/01 BUG0071807 销售订单/服务合同-单据详情页的单据分录中，“附件”字段内容（视频），无法预览。
    window.onresize = function() {
        if (document.fullscreenElement) {
            ele.style.display = 'block';
            // console.log('进入全屏')
        } else {
            // ele.style.display = 'none';
            //edit: xll 2023/10/06 BUG0072912 附件字段点击“预览”后，播放视频，退出或关闭视频后还有声音，增加暂停播放
            ele.pause();
            // console.log('退出全屏')
        }
    };
}

//全屏预览 ele:预览的对象
function preview_fullscreen(element) {
    // 判断各种浏览器，找到正确的方法
    var requestMethod = element.requestFullScreen || //W3C
        element.webkitRequestFullScreen || ///Webkit (works in Safari5.1 and Chrome 15)
        element.mozRequestFullScreen || //Firefox 10+
        element.msRequestFullScreen; //IE10+   msRequestFullscreen(小写s)
    if (requestMethod) {
        requestMethod.call(element);
    }
    else if (typeof window.ActiveXObject !== "undefined") { //for Internet Explorer
        var wscript = new ActiveXObject("WScript.Shell");
        if (wscript !== null) {
            wscript.SendKeys("{F11}");
        }
    }
}

// edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（音频类文件预览的方法）
function preview_audio(fileId,obj) {
    var popupobj = CrmPopup.getPopupObj("last");
    if(ld("#" + popupobj.divid + " #audio_"+fileId).length>0){
        var ele = ld("#" + popupobj.divid + " #audio_"+fileId).get(0);//video标签给个id
    }
    else{
        var ele = document.getElementById('audio_'+fileId);
    }
    ele.style.display = 'inline-block';
    ele.play();
    ld(obj).children('span').html(arrJsPopLabel['CANCELPREVIEW']);
    var onclick_str = ld(obj).attr('onclick');
    ld(obj).removeAttr('onclick');
    ld(obj).unbind('click').bind('click',function () {
        cancel_preview_audio(fileId,obj,onclick_str);
    });
    //window.open(ele.currentSrc);
}
function cancel_preview_audio(fileId,obj,onclick_str){
    var popupobj = CrmPopup.getPopupObj("last");
    if(ld("#" + popupobj.divid + " #audio_"+fileId).length>0){
        var ele = ld("#" + popupobj.divid + " #audio_"+fileId).get(0);//video标签给个id
    }
    else{
        var ele = document.getElementById('audio_'+fileId);
    }
    ele.pause();
    ele.style.display = 'none';
    ld(obj).children('span').html(arrJsPopLabel['PREVIEW']);
    ld(obj).attr('onclick',onclick_str);
    ld(obj).unbind('click').bind('click',function () {
        //preview_audio(fileId,obj);
    });
}

/**
 edit:chj
 time:2015-8-27
 reason:附件预览
 **/
//safari 中没办法在回调函数里面执行window.open
//edit:xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（非分录情况下lineitem_id为0）
function open_Attachment(record,fileId,module,filename,lineitem_id = 0){
    preview_pop(record,fileId,module,lineitem_id);//弹框式预览
}

/**
 * 弹框式预览  全屏设置
 * zxm 2021-09-13
 */
//edit:xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（非分录情况下lineitem_id为0）
function preview_pop(record,fileId,module,lineitem_id = 0){

    var url = 'index.php?module=uploads&action=Preview_now&ReportHeader=DHeader&record='+record+'&fileId='+fileId+'&frommodule='+module+"&isPop=yes"+'&Attachment_file=yes'+'&mobile=yes'+'&lineitem_id='+lineitem_id;
    ldAjaxNoProgress(url,'',function (data) {
        if(data.code==1){
            var tmpwidth = CrmPopup.getClientWidth();//浏览器宽度

            var Popupobj = CrmPopup.load("",  "","", tmpwidth, module, "",arrJsPopLabel['SAVE'],"",arrJsPopLabel['CANCEL']);

            Popupobj.prevshow();
            //Popupobj.center();
            Popupobj.setParams(data.result.title,"",'',tmpwidth,module,"" ,'保存',"", "关闭");

            CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data.result.content);

            ld('#'+Popupobj.divid+'_btnok').hide();//确认按钮隐藏

            ld("#"+Popupobj.divid+"_scroll").css("height",CrmPopup.getClientHeight());
            ld('#frame').css('height',CrmPopup.getClientHeight()+"px");
            Popupobj.center();
        }else if(data.code==2){
            var newWindowUrl = "index.php?module=uploads&action=Preview_now&ReportHeader=DHeader&record="+record+"&fileId="+fileId+"&frommodule="+module+"&lineitem_id="+lineitem_id;
            newWindowUrl= cls_encryptyurl.Puyoung_Encryptyurlhavephp(newWindowUrl,'');
            OpenNewWebTab(newWindowUrl,"","");
        }else if(data.code==3){	//PDF预览
            // var pdf = data.result.file_url;
            // pdf地址必须是线上地址
            var newWindowUrl = "index.php?module=uploads&action=Preview_now&ReportHeader=DHeader&pdfPreview=yes&record="+record+"&fileId="+fileId+"&frommodule="+module+"&lineitem_id="+lineitem_id;
            newWindowUrl= cls_encryptyurl.Puyoung_Encryptyurlhavephp(newWindowUrl,'');
            OpenNewWebTab(newWindowUrl,"PDF");
            // window.open('pdf/web/viewer.html?file=' + pdf, 'PDF');
        }
        else{
            var confirm_str = data.msg;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
    });
}
/*
by andy
reason 知识管理序时簿增加预览按钮
data 20140625
verson v5.33
*/
/*
function Preview_now(record,fileId,module){
   // fnvshobj(this,'watting');//显示加载弹出层
    new Ajax.Request("index.php",
        {
            queue:{
                position:"end",
                scope:"command"
            },
            method:"post",
            postBody:'module=uploads&action=Preview_now&ReportHeader=DHeader&record='+record+'&fileId='+fileId+'&frommodule='+module+'&Attachment_file=yes',
            onComplete:function (rest) {
                var restobj = eval('('+ rest.responseText +')')?eval('('+ rest.responseText +')'):JSON.parse(rest.responseText);
                if(!empty(restobj.error)){
                    if(restobj.error=='ok'){
                      //  fninvshnew('watting');
                        window.open("index.php?module=uploads&action=Preview_now&ReportHeader=DHeader&record="+record+"&fileId="+fileId+"&frommodule="+module,"","");
                    }else{
                      //  fninvshnew('watting');
                        var confirm_str = restobj.error;
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                    }
                }
                return false;
            }
        }
    );
    //相关信息加载数量
    if(set_rel_count != undefined){
        set_rel_count(record);
    }
}
*/
// edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（新增编辑界面的附件预览方法）
function Pre_Attachment(obj){
    var pre_type = 'now';
    var url = 'index.php?module=uploads&action=Preview_now&ReportHeader=DHeader&pre_type='+pre_type+"&isPop=yes"+'&Attachment_file=yes'+'&mobile=yes';
    var file_array = new Array('type','size','filename','path','newfile_name','cloud_path','storage_location','isEncrypt');
    var filedata_url = '',newWindowUrl;
    for(var i=0; i < file_array.length; i++){
        var tmpname = file_array[i];
        var tmpdata = ld(obj).attr('file_'+tmpname);
        filedata_url += '&' + tmpname + '=' + encodeURIComponent(tmpdata);
    }
    ldAjax(url, filedata_url, function(data){
        if(data.code==1){
            var tmpwidth = CrmPopup.getClientWidth();//浏览器宽度
            // var tmpwidth = CreatePagePopup.getWidth();

            var Popupobj = CrmPopup.load("",  "","", tmpwidth, module, "",arrJsPopLabel['SAVE'],"",arrJsPopLabel['CANCEL']);

            Popupobj.prevshow();
            //Popupobj.center();
            Popupobj.setParams(data.result.title,"",'',tmpwidth,module,"" ,'保存',"", "关闭");

            CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data.result.content);

            ld('#'+Popupobj.divid+'_btnok').hide();//确认按钮隐藏

            ld("#"+Popupobj.divid+"_scroll").css("height",CrmPopup.getClientHeight());
            ld('#frame').css('height',CrmPopup.getClientHeight()+"px");
            Popupobj.center();
        }
        else if(data.code==2){
            newWindowUrl = "index.php?module=uploads&action=Preview_now&ReportHeader=DHeader&pre_type="+pre_type+filedata_url;
            newWindowUrl= cls_encryptyurl.Puyoung_Encryptyurlhavephp(newWindowUrl,'');
            OpenNewWebTab(newWindowUrl,"","");
        }
        else if(data.code==3){	//PDF预览
            newWindowUrl = "index.php?module=uploads&action=Preview_now&ReportHeader=DHeader&pdfPreview=yes&pre_type="+pre_type+filedata_url;
            newWindowUrl= cls_encryptyurl.Puyoung_Encryptyurlhavephp(newWindowUrl,'');
            OpenNewWebTab(newWindowUrl, 'PDF');
        }
        else{
            var confirm_str = data.msg;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        ld('#rptContentLoading').hide();
    });
}

/*
列表界面关联创建
*/
function list_createRelated(module,related_module,recordid)
{
    var objparams=new CreatePagePopup.params();
    objparams.params['refreshpage']='no';
    var tmpurl="&frommodule="+module+"&fromid="+recordid+"&relatedcreate=yes";

    CreatePagePopup.showpage(related_module,tmpurl,objparams);
}
function CreatePaymentPlanfun(obj,divid,salesorderid,deployid,isImmediatelycreate,isshowPrintDiv,frommodule)
{  //edit:can 20230720  69402:出库单->相关信息->收款计划，新建收款计划应该调用合同创建收款计划那个批量创建的界面

    getJsScript('include/js/RelateCreatePaymentPlan.js',function(){
        var popupobj=CrmPopup.getPopupObj("last");
        popupobj.newpaymentplanobj=new RelateCreatePayPlan(popupobj);
        //zkt 20230808 BUG0070663 合同订单新建后，自动新建收款计划，这里不能新添加期次
        if(!empty(frommodule)){
            //zkt 20230808 自动创建收款计划，frommodule需要传参，不从界面获取。
            popupobj.newpaymentplanobj.frommodule = frommodule;
        }
        popupobj.newpaymentplanobj.NewPaymentPlan( obj,divid,salesorderid,deployid,isImmediatelycreate,isshowPrintDiv);

    });


}
//相关信息 - 新建按钮事件
function related_add_url(target_url,module,related_module,recordid){
    if(!empty(module)){
        EmptyProgressObjs();
        //edit:can 20210329 45203: （http://81.68.124.239:85/crm [^] ）（内蒙古润友科技有限公司）登录系统之后进入客户模块点击任意客户名称，进入详情界面。然后点击相关信息中收款单的快速创建，新建页面一直转圈圈
        AjaxJSPage(related_module + "_js", 'include/js/modules/' + related_module + '/' + related_module + '.js');
        var tmpurl="&fromid="+recordid+"&frommodule="+module+"&relatedcreate=yes";
        if(module=='Campaigns'&&(related_module=='Accounts'||related_module=='Contacts'))
        {
            tmpurl+="&campaignid="+recordid;
        }

        if(related_module=='Calendar')
        {
            getJsScript('include/js/modules/Calendar/TemplateCalendar/TemplateCalendar.js',function(){

                TemplateCalendar.getInstance().createCalendars(tmpurl)
            });
        }


        else
        {
            var objparams=new CreatePagePopup.params();
            objparams.params['refreshpage']='no';
            objparams.params['relatedcreate']='yes';
            //系统设置增加参数-客户最晚服务到期日到期后是否允许创建客户服务单

            if('HelpDesk' == related_module){
                //alert("index.php?action=HelpDeskAjax&module=HelpDesk&file=getAccountsForLastsevicedate&record="+recordid+'&frommodule='+module);
                ld.ajax("index.php?action=HelpDeskAjax&module=HelpDesk&file=getAccountsForLastsevicedate&record="+recordid+'&frommodule='+module)
                    .done(function(results){
                        //ls 2022-07-04 BUG0053531（广州鲲展）系统参数中“客户最晚服务到期日到期后是否允许创建服务单 ” 已设置为否，到服务到期日但仍可以创建服务单
                        results=trim(results);
                        if(results == 'error'){
                            var _msg = arrJsPopLabel['thecurstomerserviceordersarenotallowedtobe'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",_msg);
                        }else{
                            CreatePagePopup.showpage(related_module,tmpurl,objparams);
                        }
                    })
            }else{
                CreatePagePopup.showpage(related_module,tmpurl,objparams);
            }

        }

    }
    return false;
}

//相关信息 - 新建按钮事件
function moduledetail_related_add_url(target_url,module,related_module,recordid){

    var objparams=new CreatePagePopup.params();
    objparams.params['refreshpage']='no';
    CreatePagePopup.showpage(related_module,target_url,objparams);
    //36509: （1.6）电话小管家登录>合同订单明细界面>关联创建出库单：界面显示错误而且无法操作。（公司自用账套也有问题）
    /*var a = ld("<a href='"+target_url+"' target='_blank'>Apple</a>").get(0);

    var e = document.createEvent('MouseEvents');
    e.initEvent( 'click', true, true );
    a.dispatchEvent(e);*/


//	var winRef = window.open("","_blank");
    // alert('tes1t');

    //winRef.location = target_url;
    /* ld.ajax({
        type: '',
        url: '',
        data: '',
        success:function(json){
            winRef.location = target_url;
        }
    });*/
    return false;
    /*if(!empty(module)){
		var linkObj;var ids = related_module+"_"+recordid;
			if(ld('#'+ids).length == 0){

				linkObj = document.createElement('a');
				linkObj.id = ids;
				linkObj.target = '_blank';
				linkObj.style.display = "none";
				alert(123123);
				document.body.appendChild(linkObj);
			}else{
				linkObj = document.getElementById(ids);
			}
			alert(11);
			linkObj.href = target_url;
			alert(linkObj);
			linkObj.click();

			return false;
        	// 防止反复添加
        	if(!document.getElementById(related_module+"_"+recordid)) {
 	              	var a = document.createElement('a');
                	a.setAttribute('href', target_url);
                	a.setAttribute('target', '_blank');
                	a.setAttribute('id', related_module+"_"+recordid);
            	    document.body.appendChild(a);
        	}
            else
            {
                var a=document.getElementById(related_module+"_"+recordid);
            }
        	a.click();
	}*/
    return false;
}
/**
 edit:chj
 time:2015-8-27
 reason:附件下载
 **/
//Liver 增加附件主id,因为附件关联多个明细
function DownLoad(fileid,recordid){
    var isTimes = 0;
    var popupobj=CrmPopup.getPopupObj("last");

    if(popupobj!=undefined&&popupobj.module!='Attachment'&&frommodule!="Attachment")
    {
        window.location.href='index.php?module=uploads&action=downloadfile&a=1&fileid='+fileid+'&recordid='+recordid;
        return false;
    }
    if(isTimes == 0){
        isTimes = 1;
        window.location.href='index.php?module=uploads&action=downloadfileself&a=1&fileid='+fileid+'&recordid='+recordid;
        return false;
        new Ajax.Request("index.php",
            {
                queue:{
                    position:"end",
                    scope:"command"
                },
                method:"post",
                postBody:"action=downloadfileself&module=uploads&saveDownTimes=yes&fileid="+fileid+'&recordid='+recordid,
                onComplete:function (response) {

                    if(response.responseText.indexOf("##error##")>=0)
                    {
                        var confirm_str = "下载文件在服务器上不存在！";
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    }
                    else
                        window.location.href='index.php?module=uploads&action=downloadfileself&a=1&fileid='+fileid+'&recordid='+recordid;
                }
            }
        );
    }
}
// @edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志(查看文件下载或预览操作日志)
//edit: xll XUQIU1000357 单据分录定制，增加“附件”字段类型（分录附件操作日志）
function FileReadHistory(fileId,module,operating_type,lineitem_id = 0){
    //zkt 20241015 BUG20241010-72http://60.247.158.183:85/crm ；四川中卉园林；销售合同：XSHT-2409-107>附件>点击下载次数/预览次数，没有反应
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=FileOperationLog&ReportHeader=DHeader&fileId='+fileId+'&frommodule='+module+'&operating_type='+operating_type+'&lineitem_id='+lineitem_id;
    ldAjax(surl,"",function(data){
        if(data.code==1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,'',"","LdPopWidth600px",module,"","","","");
            crmPopupobj.show(data.result.content);
            // 需要去掉的给高度
            crmPopupobj.reduceBodyHeight = 46;
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
        }
        DelProgressObjs();
    })
    return false;
}

// @edit:liushuai,2021-04-14,reason: 0045462: PC端->客户模块->附件->下载、预览次数优化建议(次数+1)
function update_frequency(fileId, operating_type) {
    var popupobj = CrmPopup.getPopupObj("last");
    var frequencyobj = ld("#" + popupobj.divid + " [name=" + operating_type + "_" + fileId + "]");
    if (frequencyobj.length > 0) {  //判断有次数标签就表示有 查看下载和预览次数 的权限
        frequencyobj.text(parseInt(frequencyobj.text()) + 1);
        frequencyobj.parent('span').show();//show()既可以与display:none搭配也可以和hidden搭配
        // frequencyobj.parent('span').css('display','inline');//也可以，不过只能和display:none搭配
    }
}

//关联创建 - 发送短信
function CreateSendInform(module,obj,divid,recordid)
{

    ld('#rptContentLoading').show();
    calendarParentid="divSendInform";//该变量在jscalendar/dynamiccalendar.js/
    if(module == 'HelpDesk'){
        var action = 'SendMessage';
    }else{
        var action = 'SendInform';
    }

    ld.ajax({
        url: 'index.php?'+"module=MassSMS&action="+action+"&frommodule="+module+"&record=" +recordid+"&ReportHeader=dheader",
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 5000,

        success: function(data)
        {
            if(data.code==1)
            {

                ld('#rptContentLoading').hide();
                if(module == 'OutboundOrder'){
                    var SMSSendPopupobj=SMSSendPopup.getInstance(data.result.title,SaveSendInfo,"","LdPopWidth900px",module,"",data.result.oktext,"",data.result.canceltext,data.result.createnewtext);
                }else{
                    var SMSSendPopupobj=SMSSendPopup.getInstance(data.result.title,SaveSendMessage,"","LdPopWidth900px",module,"",data.result.oktext,"",data.result.canceltext,data.result.createnewtext);
                }

                SMSSendPopupobj.show(data.result.content);

            }

        }
    });

}


/*
 * editor:gyq_05
 * reason:改进设置信息弹框，适应审批步骤
 * date  :2016 2 23
 * */
function CreateSendInformContent(module,obj,divid,divold,outid,tabid)
{


    //  puyoungJS_DialogBox.unblock();
    ld('#rptContentLoading').show();

    //var senddiv=document.getElementById(divold);
    //senddiv.style.display="none";

    var postbody = '';
    var fromview = ld('#fromview').val();
    /*if(module == 'HelpDesk'){
        var fromview = ld('#fromview').val();
		postbody = "module=Users&action=UsersAjax&file=SendMessageContent&frommodule="+module+"&out_id="+outid+"&tabid="+tabid+"&fromview="+fromview;
    }else{*/
    postbody = "module=Users&action=UsersAjax&file=SendInformContent&frommodule="+module+"&out_id="+outid+"&tabid="+tabid+"&fromview="+fromview;
    /* }*/


    // 设置审批通知时增加审批通知类型参数
    if(divold == 'approvestep'){
        ld(obj).attr("id","div_approveRemindsContent");
        var steptype = ld(obj).parent().next().find('textarea').attr("name");
        postbody += "&approveStepType="+steptype;
    }
    else
    {

        postbody += "&smstype="+document.getElementById("sel_sms_range").options[document.getElementById("sel_sms_range").selectedIndex].value;
    }

    ld.ajax({
        url: 'index.php?'+postbody,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 5000,

        success: function(data)
        {
            if(data.code==1)
            {

                ld('#rptContentLoading').hide();
                var jspopup=[];
                if(divold != 'approvestep'){
                    var crmPopupobj=CrmPopup.load(data.result.title,SaveSendSMSContent,"","LdPopWidth950px",module,jspopup,data.result.oktext,"",data.result.canceltext);
                }
                else
                {
                    var crmPopupobj=CrmPopup.load(data.result.title,SaveSendInfoContent,"","LdPopWidth950px",module,jspopup,data.result.oktext,"",data.result.canceltext);
                }
                crmPopupobj.show(data.result.content);

                OutboundOrdermoduleSel(tabid);
                //将审批通知标签页通知内容传入弹框中
                if(divold == 'approvestep') {
                    var CKcontent = ld(obj).parent().next().find('textarea').val();
                    ld('#CKcontent').val(CKcontent);
                }
            }

        }
    });

}
/*editor:gyq_05 reason:关闭按钮适配审批通知  date:2016 2 26*/
function CloseDivSendInformContent(idname,divold){

    if(ld('#div_approveRemindsContent').attr("href") == "###"){
        divold = 'approvestep';
    }

    /*var newbox=document.getElementById(idname);
    newbox.style.display="none";
    var divold=document.getElementById(divold);
    divold.style.display="inline";*/
    //29270: 控制面板>审批流程管理：审批通知，点击审批通知的“设置提醒内容”弹出框的【取消】按钮，结果：没有显示审批步骤弹出层，而是显示了遮罩层
    fninvshnew(idname);
    fninvshnew(divold);

}
/*
edit:can
date:20130814
reason:新增和编辑模板中选择模块事件
*/
function OutboundOrdermoduleSel(obj)
{
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxHtmlNoProgress('index.php?','module=Users&action=UsersAjax&file=TemplatePrintField&printtabid='+obj,function(response) {
        if(response.indexOf("SUCCESS")>-1)
        {
            var results=response.split("##SUCCESS##");
            document.getElementById("tabField").innerHTML=results[1];
        }

        else{
            var confirm_str = alert_arr.ERROR_WHILE_EDITING;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        }
    });

}
function SaveSendInfo(obj)
{
    var textRecipient=document.getElementById("textRecipient").value;
    if(textRecipient==''){
        //接收人信息为空！
        var confirm_str = arrJsPopLabel['RECIPIENTINFOEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    var textContext=document.getElementById("textContext").value;
    if(textContext==''){
        //接收内容为空！
        var confirm_str = arrJsPopLabel['RECEIVECONTENTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    var sendaccount=document.getElementById("sendaccount").value;
    if(sendaccount==''){
        //没有设置通讯账户，请使用管理员用户到控制面板中设置！
        var confirm_str = arrJsPopLabel['COMMUNICATIONSACCOUNTNOTSET'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    var stockid=document.getElementById("outid").value;
    var form=document.forms['frmsendInfo'];
    form.submit();
    //window.location.href="index.php?action=DetailView&module=OutboundOrder&parenttab=Stock&record="+stockid;

}

/*function SaveSendInfoContent(obj)
{
    var textRecipient=document.getElementById("CKcontent").value;
    if(textRecipient==''){
        //内容模板为空！
        alert(arrJsPopLabel['CONTENTTEMPLATEEMPTY']);
        return false;
    }
   /!* var stockid=document.getElementById("outid").value;*!/
    var form=document.forms['frmsendInfoContent'];
    form.submit();
    //window.location.href="index.php?action=DetailView&module=OutboundOrder&parenttab=Stock&record="+stockid+"&salestype=yes&sendtype=yes";
}*/
/*
* editor:gyq_05
* reason:改进设置信息弹框，适应审批步骤
* date  :2016 2 23
* */
function SaveSendSMSContent()
{


    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var obj=popupobj.getbtnOkobj();

    var textRecipient=ld("#CKcontent").val();
    if(textRecipient==''){
        //内容模板为空！
        var confirm_str = arrJsPopLabel['CONTENTTEMPLATEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    var form=document.forms['frmsendInfoContent'];
    form.submit();



}
SaveSendSMSContent.funname="SaveSendSMSContent";


function getBrowserInfo()
{
    var agent = navigator.userAgent.toLowerCase() ;

    var regStr_ie = /msie [\d.]+;/gi ;
    var regStr_ff = /firefox\/[\d.]+/gi
    var regStr_chrome = /chrome\/[\d.]+/gi ;
    var regStr_saf = /safari\/[\d.]+/gi ;
    //IE
    if(agent.indexOf("msie") > 0)
    {
        return agent.match(regStr_ie) ;
    }

    //firefox
    if(agent.indexOf("firefox") > 0)
    {
        return agent.match(regStr_ff) ;
    }

    //Chrome
    if(agent.indexOf("chrome") > 0)
    {
        return agent.match(regStr_chrome) ;
    }

    //Safari
    if(agent.indexOf("safari") > 0 && agent.indexOf("chrome") < 0)
    {
        return agent.match(regStr_saf) ;
    }

}
/**
 * @reason: 项目计划模块操作列关闭按钮改变单据状态。
 * @author： cyb
 * @date  ： 2015-11-11
 */
function closeclick_update(obj,module,record,type){
    var urlstring='';
    var obj_relatedid = '';
    if(obj != undefined){
        obj_relatedid = ld(obj).attr('relatedid');//获取相关信息id。
    }
    urlstring +='module='+module+'&action='+module+'Ajax&file=Close&record='+record;
    urlstring +='&return_module='+module+'&return_action=index';
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxHtmlNoProgress('index.php?',urlstring,function(rest) {
        //chj 2021/4/28 45675: （61mis.com/kfbcrm）项目管理-项目立项-相关信息-派工单；项目单据编号PROJ41 ，相关信息派工单，操作处点击关闭按钮，没有反应；实际派工单已经关闭了，状态变为了已完成
        var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
        if(obj_relatedid > 0){//相关信息界面
            var tmparra=new Array();

            var tmpobj= new AfterUpdatePrevPopupObjContent(module,getEmptyValueInfo(),tmparra);
            tmparra=[module];
            tmpobj.eachrefreshlistbyModules(tmparra);
            //resetRelated(obj_relatedid);//刷新相关信息列表
        }else{
            if(type=='DetailView'){//详情界面
                window.location.reload();
            }
            else if(type == 'ListView'){//列表界面
                getListViewEntries_js(module,'start='+restobj.start.value);//刷新页面
            }
        }
    });

}
/**
 *edit:cyb
 *date:20151015
 *reason:联系人明细界面中点击手机图标时关联短信群发界面时，接收人手机列表显示。
 **/
function toChangeMobileStyle(id,module,fieldname){
    //没做任何处理，不知道干嘛用的
    /* var str_json={};
    ld.ajax({
            url:"",
            type:"POST",
            data:str_json,
            dataType:'html',
            async:false,
            success:function(rest)
            {
                var restarr = rest.split('#####SUCCESS#####');
                window.open("index.php?module=MassSMS&action=index&parenttab=Marketing&select_options="+id+"&return_module="+module+"&return_action=DetailView&fieldname="+fieldname,null,'1024,768,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
            }
        });  */
    //zkt 20231013 XUQIU1001341 SQL注入
    var urlsting = "index.php?module=MassSMS&action=index&parenttab=Marketing&select_options="+id+"&return_module="+module+"&return_action=DetailView&fieldname="+fieldname;
    urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
    window.open(urlstring,null,'1024,768,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');

}
//新增函數，在js里边解密php传递过来的值。


//弹出框列表选中变色
function setPopTrColor(sel_id){
    document.getElementById(sel_id).className = "lvtColDataHover";
}
function setPopTrColorOut(sel_id,type){
    if(type == 'On'){
        document.getElementById(sel_id).className = "lvtColDataBj";
    }else{
        document.getElementById(sel_id).className = "lvtColData";
    }
}
//相关信息列表选中变色
/*function relationListOnMouseOver(sel_id){
    var rows = "relation_"+sel_id;
    //edit:duan date:2021-12-16 reason:单据分录修改日志鼠标移入同时选中所有的分录
    ld('[id='+rows+']').attr('class','lvtColDataHover');
    //document.getElementById(rows).className = "lvtColDataHover";
}
function relationListOnMouseOut(sel_id,type){
    var rows = "relation_"+sel_id;
    if(type == 'On'){
        //edit:duan date:2021-12-16 reason:单据分录修改日志鼠标移出同时选中所有的分录
        ld('[id='+rows+']').attr('class','lvtColDataBj');
        //document.getElementById(rows).className = "lvtColDataBj";
    }else{
        ld('[id='+rows+']').attr('class','lvtColData');
        //document.getElementById(rows).className = "lvtColData";
    }
}*/
/*
function relationSetTrColor(row,sel_id,onlyid){
    var table = document.getElementById("relatedproducttable");
    var trs = table.getElementsByTagName('tr');
    var rowReacord = row.split(",");
    for(var i = 0; i<trs.length; i++){
        var rowTrs = trs[i].id.split(",");
        if(rowTrs[0] == rowReacord[0]){
            if(document.getElementById(sel_id)!=undefined){
                if(document.getElementById(sel_id).checked){
                    document.getElementById(trs[i].id).className = "lvtColDataSelected";
                }else{
                    document.getElementById(trs[i].id).className = "lvtColDataHover";
                }
            }else{
                if(document.getElementById(onlyid)!=undefined){
                    if(document.getElementById(onlyid).checked){
                        document.getElementById(trs[i].id).className = "lvtColDataSelected";
                    }
                    else{
                        document.getElementById(trs[i].id).className = "lvtColDataHover";
                    }
                }
                else{
                    document.getElementById(trs[i].id).className = "lvtColDataHover";
                }
            }
        }
    }
}
function relationSetTrColorOut(row,sel_id,onlyid,type){
    var table = document.getElementById("relatedproducttable");
    var trs = table.getElementsByTagName('tr');
    var rowReacord = row.split(",");
    for(var i = 0; i<trs.length; i++){
        var rowTrs = trs[i].id.split(",");
        if(rowTrs[0] == rowReacord[0]){
            if(document.getElementById(sel_id)!=undefined){
                if(document.getElementById(sel_id).checked){
                    document.getElementById(trs[i].id).className = "lvtColDataSelected";
                }else{
                    if(type == 'On'){
                        document.getElementById(trs[i].id).className = "lvtColDataBj";
                    }else{
                        document.getElementById(trs[i].id).className = "lvtColData";
                    }
                }
            }else{
                if(document.getElementById(onlyid)!=undefined){
                    if(document.getElementById(onlyid).checked){
                        document.getElementById(trs[i].id).className = "lvtColDataSelected";
                    }
                    else{
                        if(type == 'On'){
                            document.getElementById(trs[i].id).className = "lvtColDataBj";
                        }else{
                            document.getElementById(trs[i].id).className = "lvtColData";
                        }
                    }
                }
                else{
                    if(type == 'On'){
                        document.getElementById(trs[i].id).className = "lvtColDataBj";
                    }else{
                        document.getElementById(trs[i].id).className = "lvtColData";
                    }
                }
            }
        }
    }
}*/

// //控制面板列表选中变色
// function settingListOnMouseOver(sel_id,obj){
//     var rows = "setting_"+sel_id;
//     document.getElementById(rows).className = "lvtColDataHover";
//     ld(obj).find('a[name=RestoreDefaultIcon]').css('display','');
// }
// function settingListOnMouseOut(sel_id,type,obj){
//     var rows = "setting_"+sel_id;
//     if(type == 'On'){
//         document.getElementById(rows).className = "lvtColDataBj";
//     }else{
//         document.getElementById(rows).className = "lvtColData";
//     }
//     ld(obj).find('a[name=RestoreDefaultIcon]').css('display','none');
// }
// function settingListOnMouseOverTwo(sel_id){
//     document.getElementById(sel_id).className = "lvtColDataHover";
// }
// function settingListOnMouseOutTwo(sel_id,type){
//     if(type == 'On'){
//         document.getElementById(sel_id).className = "lvtColDataBj";
//     }else{
//         document.getElementById(sel_id).className = "lvtColData";
//     }
// }
//报表选中变色
/*function reportListOnMouseOver(sel_id){
    var rows = "report_"+sel_id;
    document.getElementById(rows).className = "lvtColDataHover";
}
function reportListOnMouseOut(sel_id,type){
    var rows = "report_"+sel_id;
    if(type == 'On'){
        document.getElementById(rows).className = "lvtColDataBj";
    }else{
        document.getElementById(rows).className = "lvtColData";
    }
}*/
//明细界面分录
function detailListOnMouseOver(jqueryobj){

    var rowindex=ld(jqueryobj).attr("rowindex");
    //var rows = "row"+sel_id;
    var popupobj=CrmPopup.getPopupObj('last');
    ld(jqueryobj).find("[span_seq_no=yes]").css("display",'none');
    ld(jqueryobj).find("[dv_operatetool=yes]").css("display",'block');

    // ld("#"+popupobj.divid+" [rowindex="+rowindex+"]").addClass( "lvtColDataHover");
    // document.getElementById(rows).className = "lvtColDataHover";
}
function detailListOnMouseOut(jqueryobj,type){
    // var rows = "row"+sel_id;

    var popupobj=CrmPopup.getPopupObj('last');
    var rowindex=ld(jqueryobj).attr("rowindex");

    ld(jqueryobj).find("[span_seq_no=yes]").css("display",'block');
    ld(jqueryobj).find("[dv_operatetool=yes]").css("display",'none');

    // if(type == 'On'){
    //     ld("#"+popupobj.divid+" [rowindex="+rowindex+"]").removeClass("lvtColDataHover").addClass("lvtColDataBj");// document.getElementById(rows).className = "lvtColDataBj";
    // }else{
    //     ld("#"+popupobj.divid+" [rowindex="+rowindex+"]").removeClass("lvtColDataHover").addClass("lvtColData");// document.getElementById(rows).className = "lvtColData";
    // }
}


function htmldecode(str) {
    str = str.replace(/&amp;/gi, '&');
    str = str.replace(/&nbsp;/gi, ' ');
    str = str.replace(/&quot;/gi, '"');
    str = str.replace(/&#39;/g, "'");
    str = str.replace(/&lt;/gi, '<');
    str = str.replace(/&gt;/gi, '>');
    //str = str.replace(/<br[^>]*>(?:(rn)|r|n)?/gi, 'n');
    return str;
}
/*
当前页详细信息
*/
var cur_PageInfo={
    pagetype:new Array(),//listview detailview,editview create,quickcreate，poplayerlistview,poppagelistview
    modulenames:new Array(),//模块名称数组
    pagemode:new Array(),//poplayer,wholepage,popwindow
    fieldinfoobjs:new Array(),
    clear:function()
    {
        if(cur_PageInfo.pagemode.length>0)
        {
            cur_PageInfo.pagemode.pop();
            cur_PageInfo.modulenames.pop();
            cur_PageInfo.pagetype.pop();
            cur_PageInfo.fieldinfoobjs.pop();
        }

    }

}


var Base64 = {
    // 转码表
    table : [
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
        'I', 'J', 'K', 'L', 'M', 'N', 'O' ,'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
        'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3',
        '4', '5', '6', '7', '8', '9', '+', '/'
    ],
    UTF16ToUTF8 : function(str) {
        var res = [], len = str.length;
        for (var i = 0; i < len; i++) {
            var code = str.charCodeAt(i);
            if (code > 0x0000 && code <= 0x007F) {
                // 单字节，这里并不考虑0x0000，因为它是空字节
                // U+00000000 – U+0000007F  0xxxxxxx
                res.push(str.charAt(i));
            } else if (code >= 0x0080 && code <= 0x07FF) {
                // 双字节
                // U+00000080 – U+000007FF  110xxxxx 10xxxxxx
                // 110xxxxx
                var byte1 = 0xC0 | ((code >> 6) & 0x1F);
                // 10xxxxxx
                var byte2 = 0x80 | (code & 0x3F);
                res.push(
                    String.fromCharCode(byte1),
                    String.fromCharCode(byte2)
                );
            } else if (code >= 0x0800 && code <= 0xFFFF) {
                // 三字节
                // U+00000800 – U+0000FFFF  1110xxxx 10xxxxxx 10xxxxxx
                // 1110xxxx
                var byte1 = 0xE0 | ((code >> 12) & 0x0F);
                // 10xxxxxx
                var byte2 = 0x80 | ((code >> 6) & 0x3F);
                // 10xxxxxx
                var byte3 = 0x80 | (code & 0x3F);
                res.push(
                    String.fromCharCode(byte1),
                    String.fromCharCode(byte2),
                    String.fromCharCode(byte3)
                );
            } else if (code >= 0x00010000 && code <= 0x001FFFFF) {
                // 四字节
                // U+00010000 – U+001FFFFF  11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
            } else if (code >= 0x00200000 && code <= 0x03FFFFFF) {
                // 五字节
                // U+00200000 – U+03FFFFFF  111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
            } else /** if (code >= 0x04000000 && code <= 0x7FFFFFFF)*/ {
                // 六字节
                // U+04000000 – U+7FFFFFFF  1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
            }
        }

        return res.join('');
    },
    UTF8ToUTF16 : function(str) {
        var res = [], len = str.length;
        var i = 0;
        for (var i = 0; i < len; i++) {
            var code = str.charCodeAt(i);
            // 对第一个字节进行判断
            if (((code >> 7) & 0xFF) == 0x0) {
                // 单字节
                // 0xxxxxxx
                res.push(str.charAt(i));
            } else if (((code >> 5) & 0xFF) == 0x6) {
                // 双字节
                // 110xxxxx 10xxxxxx
                var code2 = str.charCodeAt(++i);
                var byte1 = (code & 0x1F) << 6;
                var byte2 = code2 & 0x3F;
                var utf16 = byte1 | byte2;

                res.push(String.fromCharCode(utf16));
            } else if (((code >> 4) & 0xFF) == 0xE) {
                // 三字节
                // 1110xxxx 10xxxxxx 10xxxxxx
                var code2 = str.charCodeAt(++i);
                var code3 = str.charCodeAt(++i);
                var byte1 = (code << 4) | ((code2 >> 2) & 0x0F);
                var byte2 = ((code2 & 0x03) << 6) | (code3 & 0x3F);
                var utf16 = ((byte1 & 0x00FF) << 8) | byte2
                res.push(String.fromCharCode(utf16));
            } else if (((code >> 3) & 0xFF) == 0x1E) {
                // 四字节
                // 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
            } else if (((code >> 2) & 0xFF) == 0x3E) {
                // 五字节
                // 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
            } else /** if (((code >> 1) & 0xFF) == 0x7E)*/ {
                // 六字节
                // 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
            }
        }

        return res.join('');
    },
    encode : function(str) {
        if (!str) {
            return '';
        }
        var utf8    = this.UTF16ToUTF8(str); // 转成UTF8
        var i = 0; // 遍历索引
        var len = utf8.length;
        var res = [];
        while (i < len) {
            var c1 = utf8.charCodeAt(i++) & 0xFF;
            res.push(this.table[c1 >> 2]);
            // 需要补2个=
            if (i == len) {
                res.push(this.table[(c1 & 0x3) << 4]);
                res.push('==');
                break;
            }
            var c2 = utf8.charCodeAt(i++);
            // 需要补1个=
            if (i == len) {
                res.push(this.table[((c1 & 0x3) << 4) | ((c2 >> 4) & 0x0F)]);
                res.push(this.table[(c2 & 0x0F) << 2]);
                res.push('=');
                break;
            }
            var c3 = utf8.charCodeAt(i++);
            res.push(this.table[((c1 & 0x3) << 4) | ((c2 >> 4) & 0x0F)]);
            res.push(this.table[((c2 & 0x0F) << 2) | ((c3 & 0xC0) >> 6)]);
            res.push(this.table[c3 & 0x3F]);
        }

        return res.join('');
    },
    decode : function(str) {
        if (!str) {
            return '';
        }

        var len = str.length;
        var i   = 0;
        var res = [];

        while (i < len) {
            code1 = this.table.indexOf(str.charAt(i++));
            code2 = this.table.indexOf(str.charAt(i++));
            code3 = this.table.indexOf(str.charAt(i++));
            code4 = this.table.indexOf(str.charAt(i++));

            c1 = (code1 << 2) | (code2 >> 4);
            c2 = ((code2 & 0xF) << 4) | (code3 >> 2);
            c3 = ((code3 & 0x3) << 6) | code4;

            res.push(String.fromCharCode(c1));

            if (code3 != 64) {
                res.push(String.fromCharCode(c2));
            }
            if (code4 != 64) {
                res.push(String.fromCharCode(c3));
            }

        }

        return this.UTF8ToUTF16(res.join(''));
    }
};
function getSplitString(string,parameter){
    if(!empty(string)){
        var strs = string.split('&');
        if(strs.length > 0){
            for(var i= 0; i<strs.length;i++){
                var strMethod = strs[i].split('=');
                if(strMethod[0] == parameter){
                    return strMethod[1];
                }
            }
        }
    }
    return '';
}
/**
 * 选择范围（用户、部门、权限）
 * @param
 *		input_id：名称赋值的文本id
 *		hidden_input_id： 赋值id值
 *		purview_type： 选择类型
 *		isbox：单选or多选
 *		search_type：是否具有模糊匹配
 *		filterown：是否过滤自己
 *		pop_name：弹出层名字
 *		popup_scopetype：public private  zxm 20220811
 * @returns
 * @author Chj
 * 多选用户字段（例团队成员）、自定义报表（用户组件类型）
 */
function select_purview(input_id,hidden_input_id,purview_type,isbox,search_type,module,pop_name,popup_scopetype){
    // alert(purview_type);
    var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_selecttype;
    if(purview_type == 'Group'){
        popup_selecttype = 'group';
    }else{
        popup_selecttype = 'user';
    }
    var popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype='+popup_selecttype+'&fieldname='+hidden_input_id;
    //自定义统计表 移动端选用户
    if(typeof wx_userid!='undefined' && !empty(wx_userid)){
        popup_url += '&userid='+wx_userid;
    }
    //山水 选择团队成员
    if(input_id.indexOf("team_memberid") >= 0 ){
        popup_url += '&popup_scopetype=public&team_memberid1=true';
    }
    //zxm 20220811 自定义统计表 多选用户 组件
    if(popup_scopetype!=''){
        popup_url += '&popup_scopetype='+popup_scopetype;
    }
    var groupid = '';
    if(ld('#'+hidden_input_id) != undefined){
        groupid = ld('#'+hidden_input_id).val();
    }
    //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
    var popupobj = CrmPopup.getPopupObj("last");
    if(module == 'Users' && popupobj.user_type){
        popup_url += '&user_type='+popupobj.user_type;
    }

    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = pop_name;//标题title
        if(purview_type == 'Group'){
            scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
            scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
        }

        getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = groupid;
            cls_ScopePopup.prop.popup_url = popup_url;
            cls_ScopePopup.prop.reportmodule = 'ReportAnalysis'; //wym 231221 BUG0077370 自定义报表-筛选负责人查看范围，勾选显示离职成员，没有记住用户上次选择
            cls_ScopePopup.chooseInfo=[];
            //cls_ScopePopup.splice_symbol = ' & ';
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            var popupobj=CrmPopup.getPopupObj('last');
            //zxm 自定义统计表 移动端链接模块  层级问题
            if(typeof wx_userid!='undefined' && !empty(wx_userid)){
                ld('#'+popupobj.divid+'_olayernodeid').css('z-index',10000);
                ld('#'+popupobj.divid).css('z-index',10001).css('width','100%').css('left','0');
            }
            //zkt 20221010 BUG0057125在费用报销单，单据分录中，点击‘源单’之后的加号，进入搜索界面，光标应该停留在搜索框（查找内容）里面。涉及合同订单里的选择源单后的框，合同订单里的团队成员
            if(ld("#"+popupobj.divid+" [id='popup_locationdiv']").length>0){
                ld("#"+popupobj.divid+" [id='popup_locationdiv']").focus();
                cls_ScopePopups.searchTextFocus('popup_locationdiv',scopepopupobj.popup_searchvalue);
            }
            //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                    var selected_groupid = cls_ScopePopup.return_obj.return_id;//选中的部门id
                    var selected_groupname = cls_ScopePopup.return_obj.return_name;//选中的部门名称
                    if(selected_groupname.indexOf('<font') > -1){
                        var selected_groupname_arr = selected_groupname.split(',');
                        var tmp_name_arr = [];
                        ld.each(selected_groupname_arr,function (index,groupname) {
                            tmp_name_arr.push(groupname.split('<font')[0]);
                        })
                        selected_groupname = tmp_name_arr.toString();
                    }
                    if(empty(selected_groupid)){
                        if(purview_type == 'Group'){
                            confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                            return false;
                        }else if(hidden_input_id!='team_memberid'){//wyt 221123 BUG0058925 kfbcrm团队成员字段--当把已勾选的成员取消勾选---页面会至少提示一个成员---应该允许字段为空值
                            confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                            return false;
                        }
                    }
                    //wym 231221 BUG0077370 自定义报表-筛选负责人查看范围，勾选显示离职成员，没有记住用户上次选择 关联需求:XUQIU1002054
                    if(ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser')){
                        var displayinactiv=ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
                        var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule=ReportAnalysis&value='+displayinactiv;
                        ldAjaxNoProgresssync(tmpurlsting,'',function(data){})
                    }
                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();

                    var popupobj=CrmPopup.getPopupObj('last');//费用预算单》预算人员选择后提示为空
                    var curdivid = popupobj.divid;
                    if(ld('#'+curdivid+" [name="+input_id+"]").length>0){
                        ld('#'+curdivid+" [name="+input_id+"]").val(selected_groupname);	//152 选部门字段，无法带出部门名称
                        //edit:can 20210317 用户多选框
                        ld('#'+curdivid+" [name="+input_id+"]").html(selected_groupname);
                        ld('#'+curdivid+" [name="+input_id+"]").removeClass('border_red1');
                    }
                    if(ld('#'+curdivid+" [name="+hidden_input_id+"]").length>0){
                        ld('#'+curdivid+" [name="+hidden_input_id+"]").val(selected_groupid);
                        ld('#'+curdivid+" [name="+hidden_input_id+"]").removeClass('border_red1');
                        //自定义统计表 移动端选用户
                        /*if(typeof wx_userid!='undefined' && !empty(wx_userid)){return;};
						getJsScript('include/js/relatedfield.js',function(){
							getRelatedFieldData(module,selected_groupid,'',hidden_input_id,module,'select');
						});*/
                    }
                    //wym 240522 BUG20240521-08 成员管理批量编辑界面，选择部门后，字段前面的复选框没有自动勾选
                    if(ld('#'+curdivid+" [name="+hidden_input_id+"_mass_edit_check]").length>0){
                        var checkbox = document.getElementById(hidden_input_id + '_mass_edit_check');
                        if (checkbox) checkbox.checked = true;
                    }
                    //自定义统计表 移动端选用户
                    if(typeof wx_userid!='undefined' && !empty(wx_userid)){
                        return;
                    }
                    if(account_version=='shanshui'&&input_id.indexOf("team_memberid")>=0)
                    {
                        var name_arr=[];
                        var id_arr=[];


                        ld.each(cls_ScopePopups.chooseInfo,function(tmpindex,tmpitem){
                            name_arr.push(tmpitem.label);
                            id_arr.push(tmpitem.id);
                        })

                        ld('#'+popupobj.divid+" [name="+input_id+"]").val(name_arr.join(","));
                        ld('#'+popupobj.divid+" [name="+input_id+"]").html(name_arr.join(","));
                        if(ld('#'+popupobj.divid+" [name="+hidden_input_id+"]").length>0){
                            ld('#'+popupobj.divid+" [name="+hidden_input_id+"]").val(id_arr.join(","));
                        }
                    }


                    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                    {
                        //通讯录(pc端企业微信)
                        cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
                    }
                    //zxm 2021-0607费用预算单模块选择人员  需要特殊处理
                    if(module=='ExpenseBudget'&&input_id=="budget_person_name"){
                        ExpenseBudgetObj.selectedUsers();
                    }
                    //duan 20240926字段变更后触发公共变化事件
                    if(!empty(popupobj.common_field_event_obj)){
                        popupobj.common_field_event_obj.common_changefun(ld('#'+popupobj.divid+" [name="+hidden_input_id+"]"),hidden_input_id);
                    }
                    //edit:duan date:2024/10/25 reason:新建编辑界面选择部门后要更新职位级别内容
                    var cur_groupinfo = [];
                    ld.each(cls_ScopePopup.return_obj.return_array,function (tmp_index,tmp_obj) {
                        cur_groupinfo.push({'id':tmp_index,'name':tmp_obj['name']})
                    })
                    popupobj.cur_groupinfo = cur_groupinfo;
                    if(popupobj.module == 'Users' && popupobj.pagetype == CreatePagePopup.pagetype){
                        show_related_picklist_content('userlevel','yes');
                    }

                    popupobj.ChangeApprove();
                    //选择字段带出关联信息
                    getJsScript('include/js/relatedfield.js',function(){
                        //getRelatedFieldData(module,selected_groupid,'',hidden_input_id,module,'select');
                    });
                    return false;
                });
            }
        });
    });
}
/*
*@edit:cyb
*@date:2016-03-16
*@reason:相关信息--共享人列表操作按钮删除事件
**/
function DeleteShareUser(module,id,shareuserid,relatedid){
    //if(ld('.listEntries tr').length==2){//当删除当前分页最后一条记录时，界面显示上一页信息；
    //  start=start-1;
    // }
    var url='module=Users&action=DeleteShareUser&shareuserid='+shareuserid+'&id='+id;
    ldAjaxHtml('index.php?',url,function(response)
    {
        DelProgressObjs();
        var tmparra=new Array();
        // tmparra.push(popupobj.record);
        var  tmppopupobj=CrmPopup.getPopupObj('last');
        var tmpobj= new AfterUpdatePrevPopupObjContent(tmppopupobj.module,getEmptyValueInfo(),tmparra);
        tmpobj.refreshlistbyPopupobj(tmppopupobj);
        //  resetRelated(relatedid);//刷新列表及统计计数
        //   history.go(0);//Liver 2016/05/06 bug0021260: （火狐浏览器）客户>客户查看明细>相关信息>共享人， 全部删除仍显示数字1
    });

}


function ListView_Page(module,url,innerID)
{



    this.module=module;
    this.url=url;
    this.innerId=innerID;
    this.callback_fun=undefined;
    this.type=""
    //chj 2021/1/13 43348: (61mis.com/kfbcrm)链接模块-客户_客户查询；该模块是通过客户模块中数据分类中设为链接模块设置的；“数据分类”不应显示出来，且通过操作共享、批量编辑、转公海、查看范围等出现界面小刷新时会导致“管理分类”显示出来；
    //44663: （https://61mis.com/kfbcrm [^]）首页-销售漏斗，点击不同阶段没有弹出相应的数据。
    if(typeof linkmodulecustom!="undefined"&&linkmodulecustom != undefined && linkmodulecustom == true){
        this.url += "&ajaxtype=ld_linkmodulecustom";
    }

    this.jsonpage=function()
    {


        var cur_this=this;
        ld('#rptContentLoading').show();
        //zkt 20231009 XUQIU1001341 SQL注入
        ldAjaxNoProgress('index.php?'+cur_this.url,'',function(data)
        {
            if(data.code==1)
            {


                ld('#rptContentLoading').hide();

                var QcPopupobj=CrmPopup.getInstance(cur_this.type,data.result.title,"","","LdPopWidth950px",module,"",data.result.oktext,"",data.result.canceltext);
                QcPopupobj.type=cur_this.type;
                QcPopupobj.show(data.result.content);

            }

        })
        ldAjaxHtmlNoProgress('index.php?',cur_this.url,function(response) {
            ld('#rptContentLoading').hide();
            //alert(response);
            var result = response.responseText.split('&#&#&#');
            document.getElementById(cur_this.innerId).innerHTML= trim(result[2]);
            if(cur_this.callback_fun!=undefined)
            {
                cur_this.callback_fun();
            }

        });
    }
    this.page=function()
    {

        var cur_this=this;

        var iskanbanshow=ld('#iskanbanshow').val();

        if(iskanbanshow=='yes'){
            var browserwidth=window.innerWidth;
            var pageleftwidth=ld("#pageleft_unfold").css('width');
            var browserheight=window.innerHeight;
            var pagetopheight=ld("#pagehead").css('height');

            var query=cur_this.url.indexOf('query=true');
            var searchtext='';
            var viewname='';

            if(query>0){
                var searchtext_start=cur_this.url.indexOf('search_field');
                var searchtext_end=cur_this.url.indexOf('&query=true');
                searchtext=cur_this.url.substring(searchtext_start, searchtext_end);
            }else{
                var viewnameIndex_start=cur_this.url.indexOf('viewname');
                var viewnameIndex_end=cur_this.url.indexOf('&query_session');
                viewname=cur_this.url.substring(viewnameIndex_start, viewnameIndex_end);

            }

            pageleftwidth=browserwidth-parseFloat(pageleftwidth)+'px';
            pagetopheight=browserheight-parseFloat(pagetopheight)-126+'px';
            // var urlstring='index.php?module='+module+'&action='+module+'Ajax&file=ListView&'+searchtext+viewname+'&viewmode=kanban&pageleftwidth='+pageleftwidth+'&pagetopheight='+pagetopheight+'&isshowModuleListTree=yes';
            var urlstring='index.php?module='+module+'&action='+module+'Ajax&file=ListView&query=true&'+searchtext+viewname+'&viewmode=kanban&kanbanajax=true&pageleftwidth='+pageleftwidth+'&pagetopheight='+pagetopheight+'&isshowModuleListTree=yes';
            var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
            if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
                urlstring += '&ajaxtype=ld_linkmodulecustom';
            }
            ldAjax(urlstring,"",function(data){
                if(data.code==1){
                    // data.result.refreshdetailmodules.push(popupobj.module);
                    ld('#ListViewContents').html(data.result);
                    DelProgressObjs();
                }
            })
        }else {

            ldAjaxHtml("index.php?" + cur_this.url, {}, function (response) {
                var result = response.split('&#&#&#');
                if(result.length == 1){
                    ld('#' + cur_this.innerId).html(trim(result[0]));
                }else{
                    ld('#' + cur_this.innerId).html(trim(result[2]));
                }
                toggleSelectAll_Records(cur_this.module, false, 'selected_id');
                //zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
                var noAlertOfSalestage = ld('#noAlertOfSalestage').val();
                if (noAlertOfSalestage == 'yes') {
                    var PageDiv0 = ld('#' + cur_this.innerId + ' .PageDiv0')[0];
                    // hzx 翻页样式优化
                    ld('#' + cur_this.innerId + ' .main_grid_top').empty().removeClass('main_grid_top').addClass('main_grid_salestage').css('height', '0px');
                    //ld('#'+cur_this.innerId+' .PageDiv0').css('float','left');//zxm 20230113 靠右
                    ld('#' + cur_this.innerId + ' .Statistics').remove();
                }

                //edit: xll 2023/07/31 BUG0063767 标签查找，选中标签，点击下一页，标签内容被隐藏
                if(cur_this.ShowTag == 'yes'){
                    ld('#module_tag_list_search').find('a').trigger('click');
                }

                ld('#rptContentLoading').hide();
                if (cur_this.callback_fun != undefined) {
                    cur_this.callback_fun();
                }
            })
        }
        /*
          new Ajax.Request(
              'index.php',
              {
                  queue: {
                      position: 'end',
                      scope: 'command'
                  },
                  method: 'post',
                  postBody:cur_this.url,
                  onComplete: function(response) {
                      ld('#rptContentLoading').hide();

                      var result = response.responseText.split('&#&#&#');

                      ld('#'+cur_this.innerId).html(trim(result[2]))

                      if(cur_this.callback_fun!=undefined)
                      {
                          cur_this.callback_fun();
                      }

                  }
              }
          );*/

    };

    ////同步，获取模块列表数据
    this.http_page=function()
    {
        var cur_this=this;
        http_reqfield=createfieldXMLHTTP();
        //zkt 20231009 XUQIU1001341 SQL注入
        var tmpurl = 'index.php?'+cur_this.url;
        tmpurl= cls_encryptyurl.Puyoung_Encryptyurl(tmpurl,'');
        http_reqfield.open("POST",tmpurl,false);
        this.addRow_finished=false;
        http_reqfield.onreadystatechange=this.getModuleListData;
        http_reqfield.setRequestHeader("If-Modified-Since","0");
        http_reqfield.send();
        ///ShowSequence();

        if(this.addRow_finished == true)
        {
            if(cur_this.callback_fun!=undefined)
            {
                cur_this.callback_fun();
            }
        }
    };
    var that=this;
    this.getModuleListData=function(){
        if(http_reqfield.readyState == 4  && http_reqfield.status == 200)
        {
            ld('#rptContentLoading').hide();
            //alert(response);
            var result = http_reqfield.responseText.split('&#&#&#');
            // document.getElementById('ListViewContents').innerHTML= trim(result[2]);
            // @edit:dong @date:2020/08/24 @reason: 平铺查找修改为jquery 赋值
            var iskanbanshow=ld('#iskanbanshow').val();
            if(iskanbanshow=='yes'){
                var browserwidth=window.innerWidth;
                var pageleftwidth=ld("#pageleft_unfold").css('width');
                var browserheight=window.innerHeight;
                var pagetopheight=ld("#pagehead").css('height');

                pageleftwidth=browserwidth-parseFloat(pageleftwidth)+'px';
                var main_grid_topheight=0;
                if(ld("#ListViewNavBarAndBtn").length>0){
                    main_grid_topheight+=parseFloat(ld("#ListViewNavBarAndBtn").css('height'));
                }
                if(ld("#ListViewBtnAndSeach").length>0){
                    main_grid_topheight+=parseFloat(ld("#ListViewBtnAndSeach").css('height'));
                }
                var surl = '';
                //参数用与判断是否是数据分类转为模块  禁用数据分类下拉框及隐藏 数据分类设置
                var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
            	if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
                    surl += '&ajaxtype=ld_linkmodulecustom';
                }
                surl += '&viewid='+ld("#viewname").val();
                surl += '&viewname='+ld("#viewname").val();
                pagetopheight=browserheight-parseFloat(pagetopheight)-main_grid_topheight-10-50+'px';//10：头部间隔。50看板列头
                var urlstring='index.php?module='+module+'&action='+module+'Ajax&file=ListView&viewmode=kanban&kanbanajax=true&pageleftwidth='+pageleftwidth+'&pagetopheight='+pagetopheight+surl;
                ldAjax(urlstring,"",function(data){
                    if(data.code==1){
                        ld('#ListViewContents').html(data.result);
                        DelProgressObjs();
                    }
                })
            }else
                ld('#ListViewContents').html(trim(result[2]));
            that.addRow_finished=true;
        }
    }

}
ListView_Page.fullwidth_divid='hdScrolllistentries_yy';
ListView_Page.header_table_divid='resize_header_table_divid';//列头table所在div的id
ListView_Page.header_tableid='resize_header_tableid';//列头所在table的id

ListView_Page.content_tableid="resize_content_tableid";//内容所在table的id
ListView_Page.content_table_divid="resize_content_table_divid";//内容table所在div的id
/*
* editor:gyq_09
* explain:JS异步加载基类方法
* date: 2016 4 7
* */
var scriptsArray = new Array();
ld.cachedScript = function (url, options) {
//循环script标记数组
    for (var s in scriptsArray) {
//如果某个数组已经下载到了本地
        if (scriptsArray[s]==url) {
            return { //则返回一个对象字面量，其中的done之所以叫做done是为了与下面$.ajax中的done相对应
                done: function (method) {
                    if (typeof method == 'function'){ //如果传入参数为一个方法
                        method();
                    }
                }
            };
        }
    }
//这里是jquery官方提供类似getScript实现的方法，也就是说getScript其实也就是对ajax方法的一个拓展
    options = ld.extend(options || {}, {
        dataType: "script",
        url: url,
        cache:true //其实现在这缓存加与不加没多大区别
    });
    scriptsArray.push(url); //将url地址放入script标记数组中

    return ld.ajax(options);
}

//同步，获取模块列表数据

/*
edit:chj
date:2016-05-05
reason:明细字段非法判断
*/
function verifyTabDetailField()
{
    var popupobj=CrmPopup.getPopupObj('last');


    var validatasaveobj=new validatasave(popupobj.validatasave,'js');

    if(!validatasaveobj.tabdetailvalidata())
    {

        return false;
    }
    return true;
}
/*
function clearfield_special(fieldname){
    if(typeof(document.QcEditView) != 'undefined'&&ld("#qcformDiv").css('display')=='block'){
        eval("document.QcEditView."+fieldname).value = '';
        eval("document.QcEditView."+fieldname+"_name").value = '';
        eval("document.QcEditView."+fieldname+"_name").disabled=false;
        eval("document.QcEditView."+fieldname+"_name").style.cursor='';
    }

    if(typeof(document.EditView) != 'undefined'&&ld("#qcformDiv").css('display')!='block'){
        eval("document.EditView."+fieldname).value = '';
        eval("document.EditView."+fieldname+"_name").value = '';
        eval("document.EditView."+fieldname+"_name").disabled=false;
        eval("document.EditView."+fieldname+"_name").style.cursor='';
    }

    return false;
}*/
/**
 *edit:cyb
 *date:2016-05-23
 *reason:帮我吧接口设置密钥以及vendorid输入框清空；
 */
function cleanInfo(obj){
    obj.value="";
}
function js_unique(arr) {
    var result = [], hash = {};
    for (var i = 0, elem; (elem = arr[i]) != null; i++) {
        if (!hash[elem]) {
            result.push(elem);
            hash[elem] = true;
        }
    }
    return result;
//http://www.cnblogs.com/sosoft/
}
var auto;
js_autocomplete = function(obj,input_class){
    getJsScript('include/js/autocomplete.js',function(){
        if(auto instanceof Object == false){
            auto = new AutoComplete({
                // url: '/rocky/commonservice/user/find.json'
            });
        }
    });
}
autocolse = function(){
    // alert(111);
}
/*gyq_23 微信消息提醒定时器 date:20170207*/

function myIntervalForSendNews(){
    var AjaxUrl = 'WeiXinApp/modules/Reminds/SendRemindsWX.php';
    ld.ajax(
        {
            type: "get",
            contentType: "application/json; charset=utf-8",
            dataType: "jsonp",
            url: AjaxUrl
        });
}
var ld_defer = ld.Deferred();
var SaveApproveOperation = function(){SaveApproveOperation.cur_obj=null;}
//审批保存前操作
SaveApproveOperation.prototype.saveApproveBefore = function(){

}
SaveApproveOperation.prototype.before_check = function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var flag = true;
    if (popupobj.module=="Checks") {
        //zkt 20231013 XUQIU1001341 SQL注入
        var urlstring = 'index.php?module=Checks&action=ChecksAjax&file=checkProducts&recordid=' + ld("#" + popupobj.divid + " [name=record]").val();
        urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
        ld.ajax({
            url: urlstring,
            type: 'POST',
            async: false,
            dateType: 'json'
        })
            .done(function (data) {
                data = eval("(" + data + ")");
                if (data.code == -1) {
                    var confirm_str = '';

                    for (var i = 0; i < data.result.list.length; i++) {
                        confirm_str += data.result.list[i] + "\n";
                    }
                    // con = confirm(confirm_str);

                    RemindsMsg("", "LdPopWidth1100px", "", "yes", "yes", confirm_str);
                    flag = false;
                    var popupobj = CrmPopup.getPopupObj('last');
                    ld('#' + popupobj.divid + ' .msgDlg_right_text').css('overflow-y', 'auto');
                    ld('#' + popupobj.divid + ' .msgDlg_right_text').css('max-height', '250px');
                    ld('#' + popupobj.divid + ' .msgDlg_right_text').css('width', '900px');
                    return false;//已经结束了，不写return也可以
                }
            });
    }
    else if(popupobj.module=="WareHouseTransfer"){
        ldAjax("action=WareHouseTransferAjax&file=UpdateWareHouseTransfer&module=WareHouseTransfer&parenttab=Stock&record="+recordid+"&type=approvecheck","",function(response){
            var str=response.responseText;
            var results = str.split('###error###');
            if(results[1] == 1)
            {
                // 调入和调出仓库不能相同
                var confirm_str = arrJsPopLabel['INANDOUTNOTSAME'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                flag = false;
                return false;
            }
            else if(results[1] == 2)
            {
                //您对该单据的仓库没有操作权限
                var confirm_str = arrJsPopLabel['SORRYYOUDONOTHAVEPERMISSIONTOTHISDOCUMENT'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                flag = false;
                return false;
            }
            else
            {
                if(str.indexOf("$$success$$")<0&&str!=""&&str.length>5)
                {
                    var restobj = eval('('+ str +')')?eval('('+ str +')'):JSON.parse(str);

                    if(restobj!=undefined&&restobj.code==-3)
                    {
                        alert(restobj.msg);
                        flag = false;
                        return false;
                    }
                }
            }
        })
    }
    return flag;
}
//审批保存
SaveApproveOperation.prototype.saveApprove = function(){
    var popupobj=CrmPopup.getPopupObj("last");
    var result_aprove_type=getUrlParam('result_aprove');
    //判断下一步审批人是否为空

    if(ld("input[name='approvestatus']:checked") != undefined){
        var concurrentidStepCount=ld("#"+popupobj.divid+" [name=concurrentidStepCount]").val();
        if(concurrentidStepCount<=0)
        {
            concurrentidStepCount=1;
        }
        if(ld("input[name='approvestatus']:checked").val() == 1){
            for(var i=0;i<concurrentidStepCount;i++)
            {
                //duan 2022-3-30 判断并发步骤是否允许审批人为为空
                var allow_emptyapprover = ld("#"+popupobj.divid+" [name=allow_emptyapprover_"+i+"]").val();
                if(allow_emptyapprover!='yes' && (ld('#userid_'+i).val() == ''||ld('#userid_'+i).val() == ','))
                {
                    var confirm_str = arrJsPopLabel['nextstepofapproval']+arrJsPopLabel['CANOTEMPTY'] ;
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    fninvshnew('ApproveBlocks');
                    return false;
                }
            }
        }else if (ld("input[name='approvestatus']:checked").val() == 2) {
            //ls 20221201 XUQIU1000685  增加审批功能（审批成功的前置条件判断）
            if (!SaveApproveOperation.prototype.before_check()) {
                return false;
            }
        }
    }
    //edit: chj date: 2020/9/24 reason:选择“通过并增加本步骤审批人”选项时，若不选择“审批人”，则点击【确认】时，弹出提示信息“请选择审批人”，英文标签：Please set the approvers
    if(ld("input[name='approvestatus']:checked") != undefined){
        var approvestatus = ld("input[name='approvestatus']:checked").val();
        if(approvestatus == 6 && (ld('#augmentsinger_userid').val() == ''||ld('#augmentsinger_userid').val() == ',')){
            var confirm_str = arrJsPopLabel['Pleasesettheapproversjs'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }

        var module = ld("#"+popupobj.divid+" [name=fld_module]").val();
        var record = ld("#"+popupobj.divid+" [name=record]").val();
        if(approvestatus == 2 || approvestatus == 1){//审批成功
            // var con=await validatasave.CheckAllowSavePhpRule(module,record,'&application=finish');
            var tmp_application = '&application=finish';
            // var con = result;
            // if(!con)return '';
        }else if(approvestatus == 3 || approvestatus == 4){ //反审批
            // var con=await validatasave.CheckAllowSavePhpRule(module,record,'&application=cancel');
            var tmp_application = '&application=cancel';
            // var con = result;
            // if(!con)return '';
        }
    }
    var validata_url = tmp_application;

    //duan 20230718 获取需要保存的必填字段值
    var mandatoryfield_str = '';
    var mandatoryfield_json = '';
    if(!empty(popupobj.mandatory_field_arr)&&popupobj.mandatory_field_arr.length >0){
        //判断必填字段是否为空
        if(cls_approve_mandatoryfield.formValidate(popupobj)){
            //获取富文本框控件的值
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
            validata_url += mandatoryfield_str;
            var mandatoryfield_json = cls_approve_mandatoryfield.transFieldValue(mandatoryfield_str);
        }else{
            return false;
        }
    }



    validatasave.CheckAllowSavePhpRule(module,record,validata_url).then(result => {
        var con = result;
        if(!con)return '';
        if(result_aprove_type != undefined && result_aprove_type == '1'){
            ld("#"+popupobj.divid+" [name=result_aprove_step]").val(result_aprove_type);
        }
        // 2024-09-19 xxy BUG20240730-52 合同号字段设置了不允许重复 , 但是在审批过程中填写必填项时,合同号重复不提示重复,并且能保存
        if(!empty(popupobj.fields)&&popupobj.fields.length >0){
            var fieldduplicatevalidate = FieldDuplicateValidate(module, CrmPopup.findHtmlobj(popupobj.divid, "frmapproveblock"), '')
            if(!fieldduplicatevalidate){
                return false;
            }
        }

        if(!empty(popupobj.mandatory_field_arr)&&popupobj.mandatory_field_arr.length >0){
            var field_inputobj = ld("#"+popupobj.divid+" #tr_mandatory_field").find('input');
            //避免form表单取到编辑字段中input的值，影响传值
            field_inputobj.attr('before_disabled',field_inputobj.prop('disabled'));
            field_inputobj.prop('disabled',true);
        }
        popupobj.module = module;
        popupobj.record = record;
        //alert(ld("#"+popupobj.divid+".saveApproveLog").length);
        var data = new FormData(ld(" .saveApproveLog")[0]);
        //duan 20230718 获取需要保存的必填字段值
        if(!empty(mandatoryfield_str)){
            data.append('savefieldvalue','yes');
            data.append('fieldvaluejson',mandatoryfield_json);
            field_inputobj.prop('disabled',field_inputobj.attr('before_disabled'));
        }

        var surl = "";
        var newurl = 'index.php?module=Approve&action=ApproveAjax&file=SaveApproveLog';
        ld('#rptContentLoading').show();
        ld("#"+popupobj.divid+"_btnok").attr("disabled",'disabled');
        //var logconcurrentid=ld("#"+popupobj.divid+" [name=logconcurrentid]").val();
        // var approvelogid=ld("#"+popupobj.divid+" [name=approvelogid]").val();
        ldAjax_File(newurl,data,function(response, textStatus, xhr) {
            if(response.code == 1){
                ld('#rptContentLoading').hide();
                ld("#"+popupobj.divid+"_btnok").removeAttr("disabled");
                popupobj.CancelEvent();
                workflowCallApiPop(response.result);//工作流API弹窗

                var record = ld("#"+popupobj.divid+" [name=record]").val();
                var module = ld("#"+popupobj.divid+" [name=module]").val();
                var tmparra=new Array();
                tmparra.push(record);
                var tmpobj= new AfterUpdatePrevPopupObjContent(module,"",tmparra);
                //服务单保存后刷新服务单的历史记录(查看界面)
                var prevpopupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                DetailViewRelation.showpage_moduledetail(prevpopupobj);
                //tmpobj.eachrefreshDetailViewByModules(response.result.refreshdetailmodules);
                tmpobj.eachrefreshlistbyModules(response.result.refreshdetailmodules);

                if(record>0)
                {
                    tmpobj.update();//更新界面字段
                }
                //edit:can 2020-09-01 首页->待审批/审批中心，审批/反审批操作过后，右上角的“审批”和“消息”提醒数量应该同时自动更新
                ModelDataBindobj.setButtonName='approve';
                ModelDataBindobj.setpropertyname='approvesavebutton';
            }
            else{
                ld("#"+popupobj.divid+"_btnok").removeAttr("disabled");
                var result = response.result;
                ld('#rptContentLoading').hide();
                RemindsMsg("","LdPopWidth400px","","yes","yes",response.msg);
                if(!empty(result) && result.info == 'fieldrule'){
                    var remindpopupobj = CrmPopup.getPopupObj("last");
                    //点击确认
                    ld('#'+remindpopupobj.divid+'_btnok').unbind('click').on('click',function(){
                        var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",popupobj.module,"","","","",popupobj.record);
                        Popupobj.prevshow();
                        PageRecordPopup.params['refreshpage']='no';
                        PageRecordPopup.params['miniedit_fieldrule']='fromapprove';
                        var tmpurl = '&miniedit_fieldrule=fromapprove&cur_module_step='+result.stepid;
                        if(!empty(mandatoryfield_json)){
                            tmpurl += '&fieldvaluejson='+mandatoryfield_json;
                        }
                        PageRecordPopup.showpage(popupobj.module,popupobj.record,tmpurl,PageRecordPopup.params);

                    });
                }
            }
            //var json_info =  eval("("+response+")")?eval("("+response+")"):json.parse(response);
            //alert(response.code);
        });
    })
}
//审批保存后操作
SaveApproveOperation.prototype.saveApproveAfter = function(){}
/*
*edit:kevin
*date:2013-09-17
reason:保存审批历史
*/
function saveApproveLog(){
    var popupobj=CrmPopup.getPopupObj("last");
    var record = ld("#"+popupobj.divid+" [name=record]").val();
    var approveid = ld("#"+popupobj.divid+" [name=approveid]").val();
    var stepid = ld("#"+popupobj.divid+" [name=stepid]").val();
    var description = ld("#"+popupobj.divid+" [name=description]").val();
    var requiretext = ld("#"+popupobj.divid+" [name=requiretext]").val();
    if(trim(description)=="" && requiretext=="yes")//审批意见是否必填且为空
    {
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['APPROVEREMARKREQUIRE']);
        return false;
    }
    var objsave = new SaveApproveOperation();
    ld_defer.then(objsave.saveApproveBefore()).then(objsave.saveApprove()).then(objsave.saveApproveAfter());
}
saveApproveLog.funname="saveApproveLog";

//获取url中的参数，Liver 20170209 需求审批中心单据明细返回列表功能改进
function getUrlParam(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
    var r = window.location.search.substr(1).match(reg); //匹配目标参数
    if (r != null) return unescape(r[2]); return null; //返回参数值
}
function getParamByurl(url ,name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
    var r = url.substr(1).match(reg); //匹配目标参数
    if (r != null) return unescape(r[2]); return null; //返回参数值
}

//控制单据详情页 - 附件区块的帮助按钮
function setBLockForLink(){
    var span_i = 1;
    if(ld(" .attachments-padL11") != undefined){
        ld(" .attachments-padL11").each(function(){
            var span_con = ld(this).text();
            if(span_con != ''){
                //bug0035195: （1.6账套）单据明细界面>附件字段：附件字段前面的问题小图标没有显示出来。
                //确认后改为一直显示
                span_i++;
                //if(span_con.indexOf('.docx') > -1 || span_con.indexOf('.doc') > -1 || span_con.indexOf('.xls') > -1 || span_con.indexOf('.xlsx') > -1){

                //}
            }
        });
        if(span_i == 1){
            if(ld('#AttachmentBlock') != undefined){
                ld('#AttachmentBlock').hide();
            }
        }
        //产品管理-分享图片前图标隐藏
        var popupobj = CrmPopup.getPopupObj('last');
        if(popupobj.module=='Products'&&popupobj.type=='detailviewpage'){
            ld('#AttachmentBlock').hide();
        }
    }
}

//关闭当前层
function cancelCrmPopup(){
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.CancelEvent();
}

//模块表单的下拉框事件
function setFromCheckBox(fldName){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var currObj=CrmPopup.findHtmlobj(divid,'sel_'+fldName);

    if(currObj != undefined){
        if(currObj.prop("checked")){
            CrmPopup.findHtmlobj(divid,fldName).val(1);
            if(fldName == 'login_sms'){
                if(CrmPopup.findHtmlobj(divid,'sms_account_name').val() != undefined && CrmPopup.findHtmlobj(divid,'sms_account_name').val() == ''){
                    RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ifyoufailpleasesetupashort']);
                    currObj.removeAttr("checked");
                    CrmPopup.findHtmlobj(divid,fldName).val(0);
                }
            }
        }else{
            CrmPopup.findHtmlobj(divid,fldName).val(0);
        }
    }
}
//获取当前时间
function getNow(){
    var myDate = new Date();
    //获取当前年
    var year=myDate.getFullYear();
    //获取当前月
    var month=myDate.getMonth()+1;
    //获取当前日
    var date=myDate.getDate();
    var h=myDate.getHours();       //获取当前小时数(0-23)
    var m=myDate.getMinutes();     //获取当前分钟数(0-59)
    var s=myDate.getSeconds();
    var now=year+'-'+p(month)+"-"+p(date)+" "+p(h)+':'+p(m)+":"+p(s);
    return now;
}
function getNowDate(){
    var myDate = new Date();
    //获取当前年
    var year=myDate.getFullYear();
    //获取当前月
    var month=myDate.getMonth()+1;
    //获取当前日
    var date=myDate.getDate();
    var now=year+'-'+p(month)+"-"+p(date);
    return now;
}
//获得本周的开始日期
function getWeekStartDate() {
    var now = new Date(); //当前日期
    var nowDayOfWeek = now.getDay(); //今天本周的第几天
    var nowDay = now.getDate(); //当前日
    var nowMonth = now.getMonth(); //当前月
    var nowYear = now.getFullYear(); //当前年
    if(nowDayOfWeek==0)//表示周日
    {
        nowDayOfWeek=7;
    }
    var weekStartDate = new Date(nowYear, nowMonth, nowDay -nowDayOfWeek+1 );

    return formatDate(weekStartDate);
}

//获得本周的结束日期
function getWeekEndDate() {
    var now = new Date(); //当前日期
    var nowDayOfWeek = now.getDay(); //今天本周的第几天
    var nowDay = now.getDate(); //当前日
    var nowMonth = now.getMonth(); //当前月
    var nowYear = now.getFullYear(); //当前年
    if(nowDayOfWeek==0)//表示周日
    {
        nowDayOfWeek=7;
    }
    var weekEndDate = new Date(nowYear, nowMonth, nowDay + (7 - nowDayOfWeek));
    return formatDate(weekEndDate);
}
//获得上周的开始日期
function getLastWeekStartDate() {
    var datetimeobj=new DateTime(getWeekStartDate());
    return new DateTime(datetimeobj.addNumber(-7,'day')).dateStr();
}
//获得上周的结束日期
function getLastWeekEndDate() {
    var datetimeobj=new DateTime(getWeekStartDate());
    return new DateTime(datetimeobj.addNumber(-1,'day')).dateStr();
}
//获得上上周的开始日期
function getLastLastWeekStartDate() {

    var datetimeobj=new DateTime(getLastWeekStartDate());
    return new DateTime(datetimeobj.addNumber(-7,'day')).dateStr();
}
//获得上上周的结束日期
function getLastLastWeekEndDate() {
    var datetimeobj=new DateTime(getLastWeekStartDate());
    return new DateTime(datetimeobj.addNumber(-1,'day')).dateStr();
}
//获得本月的开始日期
function getMonthStartDate(){
    var now = new Date(); //当前日期
    var nowMonth = now.getMonth(); //当前月
    var nowYear = now.getFullYear(); //当前年
    var monthStartDate = new Date(nowYear, nowMonth, 1);
    return formatDate(monthStartDate);
}

//获得本月的结束日期
function getMonthEndDate(){
    var now = new Date(); //当前日期
    var nowMonth = now.getMonth(); //当前月
    var nowYear = now.getFullYear(); //当前年
    var monthEndDate = new Date(nowYear, nowMonth, getMonthDays(nowMonth));
    return formatDate(monthEndDate);
}
//获得上月的开始日期
function getLastMonthStartDate(){
    var nowdays = new Date();
    var year = nowdays.getFullYear();
    var month = nowdays.getMonth();
    if(month==0)  {
        month=12;
        year=year-1;
    }
    if (month < 10) {
        month = "0" + month;
    }
    return year + "-" + month + "-" + "01";
}
//获得上月的结束日期
function getLastMonthEndDate(){
    var nowdays = new Date();
    var year = nowdays.getFullYear();
    var month = nowdays.getMonth();
    if(month==0)  {
        month=12;
        year=year-1;
    }
    if (month < 10) {
        month = "0" + month;
    }
    var myDate = new Date(year, month, 0);  //上个月最后一天
    return year + "-" + month + "-" + myDate.getDate();
}
//获得上上月的开始日期
function getLastLastMonthStartDate(){
    var nowdays = new Date();
    var year = nowdays.getFullYear();
    var month = nowdays.getMonth();

    if(month==0)  {
        month=11;
        year=year-1;
    }else if(month==1)  {
        month=12;
        year=year-1;
    }else{
        month=month-1;
        //edit:can 20210408 0045341: （51mis.com.cn/XS/shchaolun）（上海超伦）工作汇报中，月计划，今天是4月6日，本月显示的是2021-04-01 ~ 2021-04-30，上月是2021-03-01 ~ 2021-03-31；上上月显示错误
        //	 month=11;
        // year=year-1;
    }
    if (month < 10) {
        month = "0" + month;
    }
    return year + "-" + month + "-" + "01";
}
//获得上上月的结束日期
function getLastLastMonthEndDate(){
    var nowdays = new Date();
    var year = nowdays.getFullYear();
    var month = nowdays.getMonth();
    //chj 2021/1/2 工作汇报-月计划-上上月显示错误
    if(month==0)  {
        month=11;
        year=year-1;
    }else if(month==1)  {
        month=12;
        year=year-1;
    }else{
        month=month-1;
        //edit:can 20210408 0045341: （51mis.com.cn/XS/shchaolun）（上海超伦）工作汇报中，月计划，今天是4月6日，本月显示的是2021-04-01 ~ 2021-04-30，上月是2021-03-01 ~ 2021-03-31；上上月显示错误
        //	 month=11;
        //year=year-1;
    }
    if (month < 10) {
        month = "0" + month;
    }
    var myDate = new Date(year, month, 0);  //上个月最后一天
    return year + "-" + month + "-" + myDate.getDate();
}
//获得某月的天数
function getMonthDays(myMonth){
    var now = new Date(); //当前日期
    var nowYear = now.getFullYear(); //当前年
    var monthStartDate = new Date(nowYear, myMonth, 1);
    var monthEndDate = new Date(nowYear, myMonth + 1, 1);
    var days = (monthEndDate - monthStartDate)/(1000 * 60 * 60 * 24);
    return days;
}

function formatDate(date) {
    var myyear = date.getFullYear();
    var mymonth = date.getMonth()+1;
    var myweekday = date.getDate();

    if(mymonth < 10){
        mymonth = "0" + mymonth;
    }
    if(myweekday < 10){
        myweekday = "0" + myweekday;
    }
    return (myyear+"-"+mymonth + "-" + myweekday);
}

function p(s) {
    return s < 10 ? '0' + s: s;
}

function getTime(n){
    var now=new Date();
    var year=now.getFullYear();
    //因为月份是从0开始的,所以获取这个月的月份数要加1才行
    var month=now.getMonth()+1;
    var date=now.getDate();
    var day=now.getDay();
    //判断是否为周日,如果不是的话,就让今天的day-1(例如星期二就是2-1)
    if(day!==0){
        n=n+(day-1);
    }
    else{
        n=n+day;
    }
    if(day){
        //这个判断是为了解决跨年的问题
        if(month>1){
            month=month;
        }
        //这个判断是为了解决跨年的问题,月份是从0开始的
        else{
            year=year-1;
            month=12;
        }
    }
    now.setDate(now.getDate()-n);
    year=now.getFullYear();
    month=now.getMonth()+1;
    date=now.getDate();
    s=year+"-"+(month<10?('0'+month):month)+"-"+(date<10?('0'+date):date);
    return s;
}

/**
 * 群发短信
 * @param
 * @returns
 * @author Chj
 */
function getMassSmsPopup(str,SMStype){
    getJsScript('include/js/SystemPopup/MassSmsPopup.js',function(){
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjax("index.php?module=MassSMS&action=MassSMSAjax&file=SendView&mode=yes",{'SMStype':SMStype},function(data) {
            DelProgressObjs();
            if(data.code==1)
            {
                if(SMStype=="SMS_VOICE"){
                    //zxm -2021-0908 阳光创信  语音
                    var MassSmsPopupObj=MassSmsPopup.load(data.result.title,SendMassSmsVoice,"","LdPopWidth800px",'MassSMS',"",data.result.oktext,"",data.result.canceltext);
                }else{
                    var MassSmsPopupObj=MassSmsPopup.load(data.result.title,SendMassSms,"","LdPopWidth800px",'MassSMS',"",data.result.oktext,"",data.result.canceltext);
                }
                MassSmsPopupObj.refreshpage='yes';
                MassSmsPopupObj.show(data.result.content);

                // 需要去掉的给高度
                MassSmsPopupObj.reduceBodyHeight = 0;
                // 设置内容最大高度
                MassSmsPopupObj.setPopBodyMaxHeight("#ListViewContents");

                if(!empty(str)){
                    var popupobj=CrmPopup.getPopupObj("last");
                    var divid=popupobj.divid;
                    CrmPopup.findHtmlobj(divid,'receivephone').val(str);
                }

                if (data.result.platform == 'aliyun') {
                    // ld("#"+MassSmsPopupObj.divid+" [name=smstemplatelist]").change();//默认没有选择模板 不用初始化
                }
            }
        });
    });
}
function setdupBillNoTip(modulebillduptip,fields)
{
    var popupobj=CrmPopup.getPopupObj("last");

    if(modulebillduptip=='yes')
    {

        //单据编号重复提示
        for(var i=0;i<fields.length;i++)
        {
            if(fields[i].uitype==4)
            {
                var fieldlabel=fields[i].fieldlabel;

                audioRemindsMsg("","",popupobj.module,"","",fieldlabel+arrJsPopLabel['AUTOCREATEBILLNO']);
                break;
            }
        }

    }
}

function copySelectedOptionsSettingModule(source, destination) {


    var srcObj = document.getElementById(source);//$(source);
    var destObj = document.getElementById(destination);//$(destination);
    if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    for (i=0;i<srcObj.length;i++) {
        if (srcObj.options[i].selected==true) {
            var rowFound=false;
            var existingObj=null;
            for (j=0;j<destObj.length;j++) {
                if (destObj.options[j].value==srcObj.options[i].value) {
                    srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,
                    rowFound=true
                    existingObj=destObj.options[j]
                    break
                }
            }
            if (rowFound!=true) {
                var newColObj=document.createElement("OPTION")
                newColObj.value=srcObj.options[i].value
                if (browser_ie)
                    newColObj.innerText=srcObj.options[i].innerText
                else if (browser_nn4 || browser_nn6)
                    newColObj.text=srcObj.options[i].text
                destObj.appendChild(newColObj)//右键
                srcObj.options[i].selected=false
                srcObj.options.remove(i);
                i=-1;
                newColObj.selected=true
                rowFound=false
            } else {
                if(existingObj != null)
                    existingObj.selected=true
            }
        }
    }
}

function send_EMail_popup(obj,fieldname)
{
    var prevpopupobj=CrmPopup.getPopupObj('last');
    var module=prevpopupobj.module;

    //@edit:liushuai,2020-12-21,reason: 0041875: （https://61mis.com/kfbtest/ [^]）单据列表界面，点击email字段值后，弹出层中显示异常（联系人模块测试）
    if (prevpopupobj==undefined||empty(prevpopupobj.record)) {
        var page_addurl=encodeURIComponent("&fromid="+ld(obj).attr('record')+"&fieldname="+fieldname+"&frommodule="+module);
    }else{
        var page_addurl=encodeURIComponent("&fromid="+prevpopupobj.record+"&fieldname="+fieldname+"&frommodule="+module);
    }
    var urlstring = "index.php?pageto_module=Emails&pageto_action=EditView&page_addurl="+page_addurl;
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
    window.open(urlstring);

}

// ls 2021-11-09 【ID1002161】模块相关信息邮件管理功能优化（用友-马朝军）
//客户、联系人、服务收费管理相关信息  回复邮件
function reply_EMail_popup(obj,mailrecordid)
{
    var page_addurl="index.php?pageto_module=Emails&pageto_action=WriteEmail&page_addurl="+encodeURIComponent("&mailrecordid="+mailrecordid+"&type=reply&emailpagetype=pop");
    //zkt 20231013 XUQIU1001341 SQL注入
    page_addurl= cls_encryptyurl.Puyoung_Encryptyurl(page_addurl,'');
    window.open(page_addurl);
}
//查看邮件详情 email_from表示有两个来源：为 emaildetails，来自表ld_emaildetails。为 mailmanager，来自表ld_mailmanager_mailrecord
function view_EmailContent(obj,mailrecordid,email_from)
{
    var prevpopupobj=CrmPopup.getPopupObj('last');
    var module=prevpopupobj.module;

    var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",module,"","","","");
    crmPopupobj.isShowFullscreen = true;
    crmPopupobj.setPosition(CrmPopup.Positions.center);
    crmPopupobj.prevshow();

    if (email_from == 'mailmanager'){
        var url = "index.php?module=Emails&action=EmailsAjax&file=EmailContentDetail&popup=yes&mailrecordid="+mailrecordid;
        ldAjax(url,"",function(data){
            if(data.code==1)
            {
                crmPopupobj.setParams(data.result.title,'',"","LdPopWidth1100px",module,"","","","");
                // crmPopupobj.show(data.result.content);
                CrmPopup.setPopupobjHtmlContent_scrollbyPosition(crmPopupobj,data.result.content);
                DelProgressObjs();
            }
        })
    }

}

//单据明细评论 删除
function delModComment(obj,record){
    if(!empty(record)){
        var modulename = 'ModComments';
        var confirm_str=arrJsPopLabel['SUREWANTDELETE'];
        validatasave.CheckAllowSavePhpRule(modulename,record,'&application=delete').then(result => {
            var con = result;
            if(!con)return '';
            RemindsMsg("","LdPopWidth400px",modulename,"yes","yes",confirm_str);
            //确认事件
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                var objtype = ld(obj).data("type");
                var parentid = ld(obj).data("parentid");
                if(objtype == 'reply'){
                    var deletedobj = ld("#modcomment_replyid_"+record);
                }
                else{
                    var deletedobj = ld("#modcomment_id_"+record);
                }
                var urlstring = "index.php?action=ModCommentsAjax&module=ModComments&file=DetailViewAjax&ajxaction=DELMODCOMMENT&record="+record;
                //zkt 20230410 BUG0064312 评论删除后未实时反应到页面上
                if(parentid!=undefined&&parentid!=''){
                    urlstring += "&parentid="+parentid;
                }
                if(deletedobj != undefined){
                    ldAjaxNoProgress(urlstring,{},function(data){
                        if(data.code == 1){
                            var popupobj = CrmPopup.getPopupObj('last');
                            ld(deletedobj).remove();
                            if(objtype == 'reply'){
                                if(parentid>0&&ld("#comment_"+parentid+"_reply_count") !=undefined&&ld("#comment_"+parentid+"_reply_count").length>0 ){
                                    //zkt 20230403 BUG0064037 kfbcrm-评论区-发表评论-在评论下方回复信息-点击删除回复的信息-删除选项消失并且显示“回复（）” 刷新后才能恢复
                                    var contentWrapDOM = ld('#modcomment_id_'+parentid).get(0);
                                    if(!empty(data.result.content)){
                                        contentWrapDOM.outerHTML = data.result.content;
                                    }
                                    ld("#"+popupobj.divid+" #modcomment_id_"+parentid).find('textarea').not('.proName_note').autosize();
                                    setModcommentEvent();

                                }
                            }
                            else{
                                var popuprecord = popupobj.record;
                                if(ld("#"+popupobj.divid+" #contentwrap_"+popuprecord).children('div') != undefined && ld("#"+popupobj.divid+" #contentwrap_"+popuprecord).children('div').length<=0){
                                    var tmphtml = '<div id="modcomment_nocomment_'+popuprecord+'" style="height: 40px; line-height: 40px; text-align: center;">'+arrJsPopLabel['NOCONTENT']+'</div>';
                                    ld("#"+popupobj.divid+" #contentwrap_"+popuprecord).html(tmphtml);
                                }
                            }
                        }
                        else if(data.code == -1&&!empty(data.msg)){
                            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                        }
                        else {
                            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                        }
                    })
                }
            })
        })
    }
}

//弹出层显示tips
function showPopuptips(obj,text){
    //选中状态下弹出tips提示
    if(ld(obj).is(':checked')){
        var parentID = ld('input[name="'+obj.name+'"]').parents('.dvpopupsroll').parent().attr('id');
        var content_span = '<span class="poptips">'+text+'</span>';
        ld('#'+parentID).append(content_span);
        setTimeout(function(){
            ld('#'+parentID+' .poptips').remove();
        }, 1500);
    }
}

//获取多选的值 获取多选框值
function getMultiPickListSelectValue(name)
{

    var popupobj=CrmPopup.getPopupObj('last');
    return getMultiPickListSelectValueByObj(ld("#"+popupobj.divid +" [name='"+name+"']"));
    /* var strtmp="";
     var tmp_tmp=0;
     var tmp_len=ld("#"+popupobj.divid +" [name='"+name+"'] option:selected").length-1;

     ld("#"+popupobj.divid +" [name='"+name+"'] option:selected").each(function(){
         var resultStr = ld(this).text().replace(/(^\s*)|(\s*$)/g, "");//删除左右空格
         // resultStr = resultStr.replace(/[ ]/g, "");    //去掉空格
         resultStr = resultStr.replace(/[\r\n]/g, ""); //去掉回车换行
         if(tmp_len==tmp_tmp)
         {
             strtmp+=trim(resultStr);
         }
         else
             strtmp+=trim(resultStr)+'########'; //这里得到的就是
         tmp_tmp++;
     });
     return strtmp;*/
}
function getMultiPickListSelectValueByObj(jqueryobj)
{

    var popupobj=CrmPopup.getPopupObj('last');
    var strtmp="";
    var tmp_tmp=0;
    var tmp_len=ld(jqueryobj).find("option:selected").length-1;

    ld(jqueryobj).find("option:selected").each(function(){
        var resultStr = ld(this).text().replace(/(^\s*)|(\s*$)/g, "");//删除左右空格
        // resultStr = resultStr.replace(/[ ]/g, "");    //去掉空格
        resultStr = resultStr.replace(/[\r\n]/g, ""); //去掉回车换行
        if(tmp_len==tmp_tmp)
        {
            strtmp+=trim(resultStr);
        }
        else
            strtmp+=trim(resultStr)+'########'; //这里得到的就是
        tmp_tmp++;
    });
    return strtmp;
}

/***
 日期控件
 ***/
function datePickerChanged(objname)
{
    //alert(obj.cal.getNewDateStr());
    //布局规则
    var popupobj=CrmPopup.getPopupObj("last");
    // alert(ld("#"+popupobj.divid+" [name="+objname+"]").val());
    if(popupobj.fieldruleobj != undefined){
        popupobj.fieldruleobj.CheckReLoadPopup();
    }
    //批量编辑时，修改日期值之后选中复选框
    if(popupobj.type == "masseditpopup"){
        var checkboxobj = ld('#'+popupobj.divid+' #'+objname+'_mass_edit_check');
        if (checkboxobj.length>0) checkboxobj.prop('checked',true);
    }
}

/*
保存后更新前面的popupobj的界面内容
updatemodule：被修改的单据的模块名称
records:被修改的单据内容，是一个数组因为有可能是批量修改
*/
function AfterUpdatePrevPopupObjContent(updatemodule,valueinfo,records)
{
    var that=this;
    this.module=updatemodule;
    this.valueinfo=valueinfo;
    this.records=records;
    this.refreshlistmodules=[];
    this.refreshdetailmodules=[];

    this.update=function(){

        var length=CrmPopup.global_listPopupObj.length;
        var datainfo={};
        //if(valueinfo!=undefined&& valueinfo instanceof Array )
        if(valueinfo.result==undefined)
        {
            return false;
        }
        var datainfo=valueinfo.result.datainfo;
        while(length>0)
        {
            length=length-1;
            var popupobj=CrmPopup.getPopupObj(length);

            //首页点击个人设置编辑保存时对象为空
            if (empty(popupobj.divid)) continue;


            if(popupobj.type==ListPagePopup.type&&ld.inArray(popupobj.module,that.refreshlistmodules)>=0)
            {
                continue;
            }

            if(popupobj.type==DetailViewPage.type&&ld.inArray(popupobj.module,that.refreshdetailmodules)>=0)
            {
                continue;
            }

            if(popupobj.type=='calendarview')
            {
                CalendarTabClick(0,popupobj);
                continue;
            }
            if(popupobj.type=='quicksearch')
            {
                /*  var moduleobjs=ld("#"+popupobj.divid+" [module="+updatemodule+"][record="+records[0]+"]");
                 popupobj.fields=popupobj.allfields[updatemodule]
                 that.updatesamemodule(moduleobjs,popupobj);
                  var moduleobjs=ld("#"+popupobj.divid+" [referencemodule="+updatemodule+"][referencerecord="+records[0]+"]");
                 that.updatedifferencemodule(moduleobjs,popupobj);*/
                continue;
            }
            //if(ld.inArray(popupobj.module,that.refreshlistmodules)>=0||ld.inArray)
            if(popupobj.module==updatemodule){
                if(records.length==1)
                {
                    var moduleobjs=ld("#"+popupobj.divid+" [module="+updatemodule+"][record="+records[0]+"]");
                }
                else
                {
                    var moduleobjs=ld("#"+popupobj.divid+" [module="+updatemodule+"]");
                }
            }
            else//修改的是超链接字段
            {
                if(records.length==1)
                {
                    var moduleobjs=ld("#"+popupobj.divid+" [referencemodule="+updatemodule+"][referencerecord="+records[0]+"]");
                }
                else
                {
                    var moduleobjs=ld("#"+popupobj.divid+" [referencemodule="+updatemodule+"]");
                }
            }
            if(moduleobjs.length<=0)
            {
                continue;
            }
            var tmpfields={};

            if(popupobj.module==updatemodule)
            {
                that.updatesamemodule(moduleobjs,popupobj);

            }
            else
            {
                that.updatedifferencemodule(moduleobjs,popupobj);
            }

            if(popupobj.type==DetailViewPage.type)
            {
                //查看界面//重新加载布局
                // alert('wwwww');
                popupobj.fieldruleobj.CheckReLoadPopup();

            }

        }

        //刷新详情页的进度
        if(DetailViewPage.type == 'detailviewpage'){
            //郎捷：费用单->特殊业务控制需求
            if(that.module == 'CustomForm18'){
                showReferenceModuleFieldBtn();
            }
            //	getJsScript('include/js/AdvanceStage.js',function(){AdvanceStage.refresh_detail(that.records[0],that.module)});
        }

        ld('textarea').not('.proName_note').autosize();//修改文本域的高度

    }
    this.updatedifferencemodule=function(moduleobjs,popupobj){
        var datainfo=that.valueinfo.result['datainfo'];

        var fieldhrefname=that.valueinfo.result.fieldhrefname;
        ld.each(moduleobjs,function(){

            var tmpfieldname=ld(this).attr('referencefieldname');
            var record=ld(this).attr('referencerecord');


            if(ld.inArray(record,that.records)<0)
            {
                return true;
            }

            if(ld(this).prop("tagName").toLowerCase()=='a')//超链接字段
            {
                //  alert(fieldhrefname);
                //    alert(datainfo[fieldhrefname]['value']);
                ld(this).text(datainfo[fieldhrefname]['value']);

                // ld(this).attr('referencerecord',datainfo[tmpfieldname]['secid']);

            }
            if(tmpfieldname!=undefined&&tmpfieldname!='')
            {
                if(ld(this).prop("tagName").toLowerCase()=='td'||ld(this).prop("tagName").toLowerCase()=='span')
                {
                    //收/付款单明细界面的点击源单
                    ld(this).html(datainfo[tmpfieldname]['value']);
                }
            }

            if(popupobj.type=='detailviewpage'){
                //查看界面
                //  ld("#"+popupobj.divid+' [name='+tmpfieldname+'_name]').val(datainfo[fieldhrefname]['value']);
                //this.updatecomment(popupobj,valueinfo,tmpfieldname);
            }

        })

        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {
            //通讯录(pc端企业微信)
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
        }
    }
    this.updatesamemodule=function(moduleobjs,popupobj){
        var tmpfields={};
        ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
            tmpfields[tmpfieldinfo.fieldname]=tmpfieldinfo;
        })
        var datainfo=[];
        //  if(that.valueinfo!=undefined&& that.valueinfo instanceof Array )
        var datainfo=that.valueinfo.result['datainfo'];
        ld.each(moduleobjs,function(){
            var tmpfieldname=ld(this).attr('fieldname');
            var record=ld(this).attr('record');
            if(ld.inArray(record,that.records)<0)
            {
                return true;
            }
            if(tmpfieldname==undefined)
            {
                return  true;
            }

            if(datainfo[tmpfieldname]==undefined)
            {
                //alert(tmpfieldname);
                //查看界面的小编辑
                return true;
            }
            if(tmpfields[tmpfieldname]==undefined)
            {
                return true;
            }
            var bigType = tmpfields[tmpfieldname].bigtype,
                tagName = ld(this).prop("tagName").toLowerCase();
            if(SaveDataRecord.isfileattachUitype(tmpfields[tmpfieldname].uitype))
            {
                //附件字段

                if(popupobj.type=='detailviewpage'&&popupobj.tabtype=='detailinfo')//查看界面
                {
                    //alert(datainfo[tmpfieldname]['DetailView_Attachmenthtml']);

                    if(tmpfields[tmpfieldname].uitype==1109||tmpfields[tmpfieldname].uitype==1108)
                        ld(this).html(datainfo[tmpfieldname]['DetailView_Attachmenthtml']) ;
                    else//图片
                        ld(this).html(datainfo[tmpfieldname]['value']) ;
                }
                else if(popupobj.type=='listpage')
                {
                    if(tmpfields[tmpfieldname].uitype==1109||tmpfields[tmpfieldname].uitype==1108)
                        ld(this).html(datainfo[tmpfieldname]['list_html']) ;
                    else//图片
                        ld(this).html(datainfo[tmpfieldname]['list_html']) ;
                }
                return true;
            }
            if(bigType == 'longtextarea')
            {
                var tmpvalue=datainfo[tmpfieldname]['value'];
                if(tmpvalue!=undefined)
                {
                    tmpvalue=tmpvalue.replace(/\n/g,'<br/>');
                }
                if(ld(this).prop("tagName")!=undefined&&ld(this).prop("tagName").toLocaleString()=='TEXTAREA')
                {
                    ld(this).html(datainfo[tmpfieldname]['value']);
                }
                else
                    ld(this).html(tmpvalue);
                return true;
            }
            if(ld(this).prop("tagName")!=undefined&&ld(this).prop("tagName").toLowerCase()=='a')//超链接字段
            {


                if(datainfo[tmpfieldname]['secid']>0)
                {

                    ld(this).html(escape2Html(datainfo[tmpfieldname]['value_name']));
                    ld(this).attr("href",changeHrefUrl(ld(this).attr("href"),'pageto_record',datainfo[tmpfieldname]['secid']));
                }
                else
                {
                    ld(this).text(datainfo[tmpfieldname]['value']);
                    ld(this).attr('href','javascript:void');

                }
                ld(this).attr('referencerecord',datainfo[tmpfieldname]['secid']);

            }
            if(ld(this).prop("tagName").toLowerCase()=='span')//
            {
                ld(this).html(datainfo[tmpfieldname]['value']);

            }
            // duan 20240614 小编辑更新字段值时，不能使用数字格式化后的值，要用原始值
            else if(bigType == 'number' && !empty(datainfo[tmpfieldname]['rawvalue']))
            {
                ld(this).html(datainfo[tmpfieldname]['rawvalue']);
            }
            //edit: xll 2024/10/10 日期时间字段使用 rawvalue 原始值
            else if(tagName !== 'span' && ['date','time','datetime'].includes(bigType)) {
                ld(this).val(datainfo[tmpfieldname]['rawvalue']);
            }
            else{
                ld(this).val(datainfo[tmpfieldname]['value']);
            }
            if(popupobj.type==DetailViewPage.type){
                //查看界面
                if(datainfo[tmpfieldname]['value_name'] !== undefined) {
                    ld("#"+popupobj.divid+' [name='+tmpfieldname+'_name]').val(datainfo[tmpfieldname]['value_name']);
                }
                if(tmpfields[tmpfieldname].bigtype=='reference'||tmpfields[tmpfieldname].bigtype=='users')
                    ld("#"+popupobj.divid+' [name='+tmpfieldname+']').val(datainfo[tmpfieldname]['secid']);
                else if(tmpfields[tmpfieldname].bigtype=='boolean'){
                    //复选框
                    if(datainfo[tmpfieldname]['rawvalue']==0)
                    {
                        ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").prop("checked",false);
                    }
                    else{
                        ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").prop("checked",true);
                    }

                }
            }


        })

        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {
            //通讯录(pc端企业微信)
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
        }
        if(popupobj.type==ListPagePopup.type||popupobj.type==RelateListPage.type) //列表界面
        {
            //更新列表合计
            that.updatelist(popupobj);
        }
        else if(popupobj.type==DetailViewPage.type)
        {


            if(that.valueinfo.result.DetailViewListHtml!=undefined)
            {
                //带明细的模块
                ld("#"+popupobj.divid+" [name=detailtable]").html(that.valueinfo.result.DetailViewListHtml);
                setProductDivWidth(popupobj);//设置列宽
            }
        }
    }
    this.updatelist=function(popupobj)
    {

        //有明细的模块列表
        if(that.valueinfo.result.recordlisthtml!=undefined)
        {

            ld.each(that.records,function(recordindex,tmprecord){
                var tmptrobj=ld("#"+popupobj.divid+" tr[module="+popupobj.module+"][record="+tmprecord+"]");
                //that.valueinfo.result.recordlisthtml
                ld( tmptrobj.get(0)).before(that.valueinfo.result.recordlisthtml);

                tmptrobj.remove();



            })
        }
        var curpagetotalobjs=ld("#"+popupobj.divid+" [module="+this.module+"][listcurpagetotal=yes]");
        var datainfo=that.valueinfo.result.datainfo;
        var beforedatainfo=that.valueinfo.result.beforedatainfo;

        //本页合行
        ld.each(curpagetotalobjs,function(){
            var tmpfieldname=ld(this).attr('fieldname');
            var beforevalue=0;
            var nowvalue=0;
            var htmlvalue=JsNumbertoFixed(ld(this).attr('value'),2);
            //判断明细表字段，明细表字段有数量的小数位数
            var isdetailtablefield=ld(this).attr(("detailtabblefield"));
            var decimallen=ld(this).attr(("decimallen"));
            var currency_symbol=ld(this).attr("currency_symbol");
            if(isdetailtablefield=='yes')
            {

                if(that.valueinfo.result.before_sumdetailvalues != undefined && that.valueinfo.result.before_sumdetailvalues[tmpfieldname]!=undefined)
                {
                    beforevalue=JsNumbertoFixed(that.valueinfo.result.before_sumdetailvalues[tmpfieldname],decimallen);
                    nowvalue=JsNumbertoFixed(that.valueinfo.result.after_sumdetailvalues[tmpfieldname],decimallen);
                }
            }
            else

            {
                if(beforedatainfo!=undefined&&beforedatainfo[tmpfieldname]!=undefined)
                {//获取单据保存前的值
                    beforevalue=JsNumbertoFixed(beforedatainfo[tmpfieldname].value,decimallen);//beforedatainfo[tmpfieldname].value;

                }

                if(datainfo[tmpfieldname]!=undefined)
                {//获取单据保存后的值
                    nowvalue=JsNumbertoFixed(datainfo[tmpfieldname].value,decimallen);

                }

            }

            var tmpvalue=eval(htmlvalue)+eval(nowvalue)-eval(beforevalue);
            tmpvalue=JsNumbertoFixed(tmpvalue,decimallen);
            ld(this).attr("value",tmpvalue);
            //千分位
            tmpvalue=toThousands(tmpvalue);

            ld(this).attr("title",currency_symbol+tmpvalue);
            ld(this).html(currency_symbol+tmpvalue);


        })
        //全部合计
        var totalobjs=ld("#"+popupobj.divid+" [module="+this.module+"][listtotal=yes]");
        ld.each(totalobjs,function(){
            var tmpfieldname=ld(this).attr('fieldname');
            var beforevalue=0;
            var nowvalue=0;
            if(ld(this).attr('value')=='')
            {
                //edit:can 43663: （本地8.3.4）销售管理>合同订单>详情>小编辑；在合同订单详情界面，小编辑保存后，点击空白处返回单据列表，查看全部合计的后面显示￥NAN
                return true;
            }
            var htmlvalue=JsNumbertoFixed(ld(this).attr('value'),2);
            //判断明细表字段，明细表字段有数量的小数位数
            var isdetailtablefield=ld(this).attr(("detailtabblefield"));

            var decimallen=ld(this).attr(("decimallen"));
            var currency_symbol=ld(this).attr("currency_symbol");
            if(isdetailtablefield=='yes')
            {

                if(that.valueinfo.result.before_sumdetailvalues != undefined && that.valueinfo.result.before_sumdetailvalues[tmpfieldname]!=undefined)
                {
                    beforevalue=JsNumbertoFixed(that.valueinfo.result.before_sumdetailvalues[tmpfieldname],decimallen);
                    nowvalue=JsNumbertoFixed(that.valueinfo.result.after_sumdetailvalues[tmpfieldname],decimallen);
                }
            }
            else
            {
                if(beforedatainfo!=undefined&&beforedatainfo[tmpfieldname]!=undefined)
                {//获取单据保存前的值
                    beforevalue=JsNumbertoFixed(beforedatainfo[tmpfieldname].value,decimallen);//beforedatainfo[tmpfieldname].value;

                }

                if(datainfo[tmpfieldname]!=undefined)
                {//获取单据保存后的值
                    nowvalue=JsNumbertoFixed(datainfo[tmpfieldname].value,decimallen);

                }
            }


            var tmpvalue=eval(htmlvalue)+eval(nowvalue)-eval(beforevalue);
            tmpvalue=JsNumbertoFixed(tmpvalue,decimallen);
            ld(this).attr("value",tmpvalue);
            //千分位
            tmpvalue=toThousands(tmpvalue);

            ld(this).attr("title",currency_symbol+tmpvalue);
            ld(this).html(currency_symbol+tmpvalue);


        })

        IsFrameElement();

    }
    this.updatecomment=function(popupobj,valueinfo,fieldName)
    {
        if((popupobj.module == "HelpDesk" || popupobj.module == "Faq") && fieldName == "comments") {
            //获取评论内容
            var content=valueinfo.result.comment;
            var comments =content;// response.responseText.replace(":#:SUCCESS","");
            if(getObj("comments_div") != null){getObj("comments_div").innerHTML = comments;}
            if(getObj(dtlView) != null) getObj(dtlView).innerHTML = "";
            if(getObj("comments") != null) getObj("comments").value = "";
        }
    }
    /**
     刷新查看界面
     **/
    this.eachrefreshDetailViewByModules=function(modules)
    {
        var length=CrmPopup.global_listPopupObj.length;
        this.refreshdetailmodules=modules;

        while(length>0)
        {
            length=length-1;
            var tmppopupobj=CrmPopup.getPopupObj(length);
            var  tmpmodule=tmppopupobj.module;
            //客户管理创建服务合同保存后，相关信息页签无法点击
            if(ld.inArray(tmpmodule,modules)>=0)
            {
                //duan 20240710 如果当前页页签不是详情页，则刷新头部
                if(tmppopupobj.type==DetailViewPage.type){
                    if(tmppopupobj.related_module=='detailview'){
                        DetailViewRelation.showpage_moduledetail(tmppopupobj);
                    }else{
                        tmppopupobj.refreshDetailHead();
                    }
                }
            }
        }
    }
    /**
     刷新图谱界面
     **/
    this.eachrefreshModuleMapViewByModules=function(modules)
    {
        var length=CrmPopup.global_listPopupObj.length;
        this.refreshdetailmodules=modules;

        while(length>0)
        {
            length=length-1;
            var tmppopupobj=CrmPopup.getPopupObj(length);
            var  tmpmodule=tmppopupobj.module;

            if(ld.inArray(tmpmodule,modules)>=0&&tmppopupobj.type=='editmodulemappage'&&tmppopupobj.module==tmpmodule)
            {
                var editmodulemapobj = tmppopupobj.modulemapobj;
                //刷新图谱联系人列表
                if(!empty(editmodulemapobj)){
                    editmodulemapobj.refreshdatalist();
                }
            }
        }
    }

    //modules：需要刷新的模块数组
    this.eachrefreshlistbyModules=function(modules)
    {

        var length=CrmPopup.global_listPopupObj.length;

        this.refreshlistmodules=modules;

        while(length>0)
        {
            length=length-1;
            var tmppopupobj=CrmPopup.getPopupObj(length);
            var  tmpmodule=tmppopupobj.module;

            if(tmppopupobj.type=='home'&&tmpmodule=='Home'){
                //首页
                var lasturl=tmppopupobj.lasturl;

                if(lasturl!=undefined)
                {
                    var stuffid=  getSearchString("stuffid",lasturl);

                    var  stufftype=getSearchString("stufftype",lasturl);
                    if(stuffid!=undefined&&parseInt(stuffid)>0&&stuffid==39){
                        //首页 审批中心组件 审批处理之后 刷新审批中心组件数据
                        if(tmppopupobj.divid != ''){
                            var CurTabObj = ld('#'+tmppopupobj.divid+' #stuff_' + stuffid).find('.ld-NavBarList').children('.cur');
                        } else {
                            var CurTabObj = ld('#stuff_' + stuffid).find('.ld-NavBarList').children('.cur');
                        }
                        var data_type = CurTabObj.attr('data-NavBarName');
                        loadStuff(stuffid,stufftype,data_type);//刷新组件
                    }

                }
            }
            else if(ld.inArray(tmpmodule,modules)>=0)
            {
                this.refreshlistbyPopupobj(tmppopupobj);

            }
            this.refreshlistbyPopupobjSql(tmppopupobj);
        }

    }
    this.refreshlistbyPopupobjSql=function(popupobj)
    {
        if(typeof popupobj.refresh!='undefined'&&popupobj.refresh==='yes')
        {

            if(popupobj.ajaxtype=='html')
            {

                // popupobj.ajaxparam['page_list_query']=popupobj.page_list_query;
                //popupobj.ajaxparam['listquery']=popupobj.list_query;
                var old_url=popupobj.refreshurl;
                ldAjaxHtml(old_url,popupobj.ajaxparam,function(data){
                    var str =  data.replace(popupobj.splitstr,'');

                    ld(popupobj.htmlDivid).html(str);
                    popupobj.refreshurl=old_url;
                    if(typeof popupobj.ajaxcallback!='undefined')
                        popupobj.ajaxcallback(popupobj);


                })
            }
            return 'yes';
        }
    }
    this.refreshlistbyPopupobj=function(popupobj){
        var iskanbanshow=ld('#iskanbanshow').val();
        if(iskanbanshow!='yes') {
            if(popupobj.type==ListPagePopup.type)
            {
                //列表界面刷新
                var tmprefreshurl = popupobj.url;
                ld('#rptContentLoading').show();
                // zkt 20231013 XUQIU1001341 SQL注入
                ldAjaxHtmlNoProgressobj("index.php?"+tmprefreshurl+"&query_session=1",'',function(data){
                    var str = data;
                    if (data.indexOf("&#&#&#&#&#&#") >= 0) {
                        str = data.split("&#&#&#&#&#&#");
                        str = str[1];
                    }
                    ld('#rptContentLoading').hide();
                    //hzx 刷新列表只刷新table
                    ld("#"+popupobj.divid + ' #ListViewContents').html(str);
                    toggleSelectAll_Records(popupobj.module, false, 'selected_id');

                    if(empty(popupobj.listresizeobj)){
                        var listresizeobj=new List_ResizeTable(popupobj);
                        popupobj.listresizeobj=listresizeobj;
                    }
                    popupobj.listresizeobj.setReiszeTable_Init(popupobj.module,'ajax');
                    setContentHeight(popupobj.module);//计算内容高度
                    IsFrameElement();
                    //listcontentobj.html(data);
                });
            }
            else if(popupobj.type==selectDataPopup.type&&popupobj.module=='Productbom'){
                //选择产品套餐界面的编辑和复制

                fun_setCrmPopupWindow.showData(popupobj.url);
            }
            else if(popupobj.type=='maplist')
            {
                //客户列表
                changeListMap(popupobj.module,'map',popupobj.page,popupobj);
            }
            else if(popupobj.type=='calendarview')
            {
                CalendarTabClick(0,popupobj);
            }

            else  if(popupobj.type==RelateListPage.type)
            {

                //相关信息刷新
                if(popupobj.balanceaccountobj!=undefined){
                    //往来对账

                    popupobj.balanceaccountobj.callsearch(popupobj.module);

                }
                else
                    DetailViewRelation.searchByPopupobj(popupobj);

            }
        }
        else if(iskanbanshow=='yes'){
            var browserwidth=window.innerWidth;
            var pageleftwidth=ld("#pageleft_unfold").css('width');
            var browserheight=window.innerHeight;
            var pagetopheight=ld("#pagehead").css('height');

            pageleftwidth=browserwidth-parseFloat(pageleftwidth)+'px';
            var main_grid_topheight=0;
            if(ld("#ListViewNavBarAndBtn").length>0){
                main_grid_topheight+=parseFloat(ld("#ListViewNavBarAndBtn").css('height'));
            }
            if(ld("#ListViewBtnAndSeach").length>0){
                main_grid_topheight+=parseFloat(ld("#ListViewBtnAndSeach").css('height'));
            }

            var surl = '';
            //参数用与判断是否是数据分类转为模块  禁用数据分类下拉框及隐藏 数据分类设置
            var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
            if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
                surl += '&ajaxtype=ld_linkmodulecustom';
            }
            surl += '&viewid='+ld("#viewname").val();
            surl += '&viewname='+ld("#viewname").val();

            pagetopheight=browserheight-parseFloat(pagetopheight)-main_grid_topheight-10-50+'px';//10：头部间隔。50看板列头
            var urlstring='index.php?module='+module+'&action='+module+'Ajax&file=ListView&viewmode=kanban&kanbanajax=true&pageleftwidth='+pageleftwidth+'&pagetopheight='+pagetopheight+surl;
            ldAjax(urlstring,"",function(data){
                if(data.code==1){
                    ld('#ListViewContents').html(data.result);
                    DelProgressObjs();
                }
            })
        }
    }
    this.System_deploySaveByModule=function(popupobj){
        if(this.valueinfo.result.sysdeploy!=undefined&&this.valueinfo.result.sysdeploy[popupobj.module]!=undefined)
        {
            var recordid = 0;
            // 2024-11-12 xxy 关联单选销售订单单据，快速创建完单据后，弹出层中没有record，后台需要单据id进行审批状态判断
            if(!empty(popupobj.record)){
                recordid = popupobj.record;
            }else if(!empty(that.valueinfo) && !empty(that.valueinfo.fieldvalue) && !empty(that.valueinfo.fieldvalue.record_id)) {
                recordid = that.valueinfo.fieldvalue.record_id;
            }
            if(popupobj.module=='Potentials')
                NewReceivablesforecast('','',recordid,this.valueinfo.result.sysdeploy[popupobj.module]['deploytype'],2);
            else if(popupobj.module=='SalesOrder'){
                //zkt 20221101 BUG0058180 该参数设置后不生效，麻烦检查下，应该是通用问题，着急答复客户
                //合同订单打印
                if(this.valueinfo.result.sysdeploy[popupobj.module]['deploytype'] == 57){
                    if(this.valueinfo.result.sysdeploy[popupobj.module]['deployvalue']=='0'){
                        var param = {'module':popupobj.module,'recordid':this.valueinfo.result.sysdeploy[popupobj.module]['record']};
                        getJsScript('include/js/SystemPopup/PrintPopup.js',function(){
                            PrintPopup.showpopuphaveparam(param);
                        });
                    }
                    return ;
                }
                var isshowPrintDiv = 'yes';
                isshowPrintDiv = 'yes';
                CreatePaymentPlanfun(document.getElementById("createPaymentid"),'CreatePaymentplan',recordid,0,'yes',isshowPrintDiv,popupobj.module);
            }else if(popupobj.module=='Invoice'){
                /*
                *edit: chj
                *date: 2020/7/27
                *reason: 42133: （61mis.com/kfbcrm）系统设置>系统参数设置：参数中‘销售发票保存自动创建回款计划’选了‘是’，保存销售发票的时候不会自动弹出“回款计划”创建界面。
                */
                CreatePaymentPlanfun(document.getElementById("createPaymentid"),'CreatePaymentplan',recordid,0,'yes','',popupobj.module);
            }
            else if(popupobj.module=='ServiceContracts'){
                CreatePaymentPlanfun(document.getElementById("createPaymentid"),'CreatePaymentplan',recordid,0,'yes','',popupobj.module);
            }
            else if(popupobj.module=='PurchaseOrder')
            {
                NewSendPayment(document.getElementById("createSendPaymentid"),'CreateSendPayment',recordid,0,'yes');
            }
            else if(popupobj.module=='PurchaseInvoice')
            {
                //042885: （https://61mis.com/kfbcrm/ [^]）（邬丹华客户问题）参数里设置了保存采购发票后自动创建付款计划，但实际操作中保存单据后没有弹出付款计划的页面（需要补丁）
                NewSendPayment(document.getElementById("createSendPaymentid"),'CreateSendPayment',recordid,0,'yes');
            }



        }
    }


}
function ListPagePopup(){}
ListPagePopup.type="listpage";
ListPagePopup.pagetype=ListPagePopup.type;

function RelateListPage()
{

}
RelateListPage.type='relatelistpage';
function selectDataPopup(){

}
selectDataPopup.type='selectsearchdetail';
/*
获取url参数
*/
function getSearchString(key, Url) {
    var str = Url;
    var strs=Url.split("?");
    if(strs.length>1){
        str=strs[1];
    }
    else
        str = str.substring(1, str.length); // 获取URL中?之后的字符（去掉第一位的问号）
    // 以&分隔字符串，获得类似name=xiaoli这样的元素数组
    var arr = str.split("&");
    var obj = new Object();
    // 将每一个数组元素以=分隔并赋给obj对象
    for (var i = 0; i < arr.length; i++) {
        var tmp_arr = arr[i].split("=");
        obj[decodeURIComponent(tmp_arr[0])] = decodeURIComponent(tmp_arr[1]);
    }
    return obj[key];
}

function getEmptyValueInfo()
{
    var valueinfo=[];
    valueinfo['valueinfo']={'result':''};
    return valueinfo;
}

function ChangeWebUrl(newUrl)
{
    var stateObject = {};
    //var newUrl='index.php?pageto_module=Approve&pageto_action=ApproveListViewCount';
    //var newUrl = "index.php";//修改从项目名后开始
    //zkt 20231013 XUQIU1001341 SQL注入
    newUrl= cls_encryptyurl.Puyoung_Encryptyurl(newUrl,'');
    history.pushState(stateObject,"",newUrl);
}

var DataCode={'ok':1,'error':-1,'errorhtml':-3,'errorcontinue':-2,'logincontrol':'logincontrol','Urlillegal':-100};

function getRatio() {
    var ratio = 0;
    var screen = window.screen;
    var ua = navigator.userAgent.toLowerCase();

    if (window.devicePixelRatio !== undefined) {
        ratio = window.devicePixelRatio;
    } else if (~ua.indexOf("msie")) {
        if (screen.deviceXDPI && screen.logicalXDPI) {
            ratio = screen.deviceXDPI / screen.logicalXDPI;
        }
    } else if (
        window.outerWidth !== undefined &&
        window.innerWidth !== undefined
    ) {
        ratio = window.outerWidth / window.innerWidth;
    }
    if (ratio) {
        ratio = Math.round(ratio * 100);
    }
    return ratio;
}

/*
 * reason:数据分类
 * edit:diony
 * date:2016-10-18
*/

//计算内容高度
function setContentHeight(module){
    var a = ld(' .header').outerHeight(true),//头部高度
        b = ld(' .ld-ui-tabs').outerHeight(true),//标签高度
        c = ld(' .main_grid_top').outerHeight(true),//按钮高度 和数据分类高度
        c1 =0;;// ld(' .Category-list').outerHeight(true),//数据分类高度
    d = 0;//ld(' .ld-listview-btnscontent').outerHeight(true)+10,//按钮高度
    e = ld('#resize_header_table_divid').outerHeight(true),//内容头部高度
        tag = ld('#listtag_div').outerHeight(true),//标签高度
        rp = ld(' .Statistics').outerHeight(true),//统计图表高度
        orgInfo =  40,//用户管理显示的公司信息
        h_height = 0,
        s_height = ld(window).height();
    // @edit:dong @date:2020/08/21 @reason:  平铺查找
    if(!ld('#tiledSearch').is(":hidden")){
        var tiledHight =ld('#tiledSearch').outerHeight(true);
    }
    if(ld('#listtag_div').is(":hidden")){
        tag = 0;
    }
    if(a==null) a=0;
    if(a == 0) a=topheight;
    if(b==null) b=0;//客户关闭公海参数
    if(c==null) c=0;
    if(c1==null) c1=0;
    if(d==null) d=0;
    if(e==null) e=0;
    if(rp==null) rp=0;
    if(tag==null) tag=0;
    if(orgInfo == null) orgInfo=0;
    h_height = Tools.Number.toInt(a);
    // console.log('a:'+a);
    // console.log('b:'+b);
    // console.log('c:'+c);
    // console.log('c1:'+c1);
    // console.log('d:'+d);
    // console.log('e:'+e);
    // console.log('rp:'+rp);
    // console.log('tag:'+tag);
    // console.log('orgInfoa:'+orgInfo);

    if( module==='Accounts'||module==='Calendar'|| module==='Reminds'||module=='Checks'||module=="Leads"||module=='WorkReportList'){
        h_height = Tools.Number.toInt(h_height)+Tools.Number.toInt(b);
    }
    if( module==='OutboundOrder'||module==='Stock'||module==='WorkSheet'||module==='Checks'){
        h_height = Tools.Number.toInt(h_height)+Tools.Number.toInt(48);
    }
    if(module==='Users'){
        h_height = Tools.Number.toInt(h_height) + Tools.Number.toInt(orgInfo);
    }
    if(module==='Approve'){
        h_height = Tools.Number.toInt(h_height)+Tools.Number.toInt(48);
    }
    h_height = Tools.Number.toInt(h_height)+Tools.Number.toInt(c)+Tools.Number.toInt(c1)+Tools.Number.toInt(d)+Tools.Number.toInt(e)+Tools.Number.toInt(rp)+Tools.Number.toInt(tag);
    // @edit:dong @date:2020/08/21 @reason:  平铺查找
    if(tiledHight != undefined){
        h_height += Tools.Number.toInt(tiledHight);
    }
    //统计图表开启，底部减0
    var dibu = 50;
    if(rp > 0){
        dibu = 0;
    }
    var ratio= getRatio()/100 ;

    ratio=1;


    // var height=s_height-h_height-Tools.Number.toInt(dibu);

    if(ld('#resize_content_table_divid').length > 0) {
        ld('#resize_content_table_divid').css('height', s_height - ld('#resize_content_table_divid').offset().top - dibu)
        var tablediv_height = ld('#resize_content_table_divid').outerHeight(true);
        ld('#resize_content_tdid').css('height', tablediv_height - 10)
    }



    //hzx 20240118 BUG20240117-71 客户-点击标签查找后再点击平铺查找，左侧树结构高度没有自适应
    var listpagepopupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    if(listpagepopupobj && ld("#"+listpagepopupobj.divid+" #moduletreelist").length > 0){
        var pageheadheight=ld('#pagehead').height();
        var ulmaxheight = CrmPopup.getClientHeight()-pageheadheight;
        if(ld('.ld-listview-screen').length > 0){
            ulmaxheight = ulmaxheight - ld('.ld-listview-screen').get(0).offsetHeight - 9;
        }

        ld("#"+listpagepopupobj.divid+" #moduletreelist").css('height',ulmaxheight);
    }else{
        var mappopupobj = CrmPopup.getlastPopupObjByType('maplist');
        if(mappopupobj){
            var pageheadheight=ld('#pagehead').height();
            var ulmaxheight = CrmPopup.getClientHeight()-pageheadheight;
            if(ld('.ld-listview-screen').length > 0){
                ulmaxheight = ulmaxheight - ld('.ld-listview-screen').get(0).offsetHeight - 9;
            }
            if(ld('.ld-listview-screen [name=moduletag_list]:visible').length > 0){
                ulmaxheight = ulmaxheight + ld('.ld-listview-screen [name=moduletag_list]:visible').get(0).offsetHeight;
            }

            ld("#"+mappopupobj.divid+" #divMapShow").css('height',ulmaxheight);
        }
    }
    if(listpagepopupobj && ld("#"+listpagepopupobj.divid+' #viewuserlist').length > 0){
        var pageheadheight=ld('#pagehead').height();
        var ulmaxheight = CrmPopup.getClientHeight()-pageheadheight;
        if(ld('#users_left_top_title').length > 0){
            ulmaxheight = ulmaxheight - 40;
        }
        ld("#"+listpagepopupobj.divid+" #viewuserlist").css('overflow-y','hidden');
        if(ld('.ld-listview-screen').length > 0){
            ulmaxheight = ulmaxheight - ld('.ld-listview-screen').get(0).offsetHeight - 9;
        }
        ld("#"+listpagepopupobj.divid+" #viewuserlist").css('height',ulmaxheight);
    }

}
var Tools={};
//异地登录
Tools.Relogin=function()
{
    alert(arrJsPopLabel['loginfromadifferentlocation']);
    window.location.href="index.php?action=LoginCheck&module=Users";
}
Tools.DelHtmlTag=function(text)
{
    //删除文本中的html标记
    //edit:can 2021-01-08 44174: (61mis.com/kfbcrm)客户管理-客户-新增；新增客户界面选择销售负责人，中文输入时有异常，无法正常编辑输入
    var  tmpvalue=text;
    tmpvalue = tmpvalue.replace("<script[^>]*>[\\d\\D]*?</script>","");//去script
    tmpvalue = tmpvalue.replace("<style[^>]*>[\\d\\D]*?</style>",""); //去style
    tmpvalue= tmpvalue.replace(/<[^>]+>/g,""); //正则去掉所有的html标记

    return tmpvalue;
}
Tools.DelHtmlnbsp=function(tmpvalue){
    tmpvalue=tmpvalue.replace(/&nbsp;/ig, "");
    return tmpvalue;
}
Tools.getParentobjByChild=function(childjqueryobj,parenttagname){

    var parentobj=ld(childjqueryobj).parent();

    while(ld(parentobj).prop("tagName").toLowerCase()!=parenttagname.toLowerCase())
    {
        parentobj=ld(parentobj).parent();
    }
    return parentobj;
}
Tools.Number={
    //edit：can 20200723 mm转像素
    convertmmToPx:function(mm){
        return mm*3.78;
    },
    //保留两位小数
    //制保留2位小数，如：2，会在2后面补上00.即2.00
    toDecimal : function(x,y) {
        var f = parseFloat(x);
        if (isNaN(f)) {
            return false;
        }
        var digitStr = '1';
        for(var i=0;i<y;i++){
            digitStr += '0';
        }
        digitStr = parseInt(digitStr);
        var f = Math.round(x*digitStr)/digitStr;
        var s = f.toString();
        var rs = s.indexOf('.');
        if (rs < 0) {
            rs = s.length;
            if(y>0){
                s += '.';
            }
        }
        if(y>0){
            while (s.length <= rs + y) {
                s += '0';
            }
        }
        return s;
    },
    //整数，四舍五入
    toInt : function(x) {
        return Math.round(x);
    }
};

function DocmentWriteJs(jsurl,jsfile)
{

    if(ld("#"+jsfile).length<=0)
    {
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = global_js_url+jsurl+"?v="+global_js_version;

        script.id=jsfile;
        document.body.appendChild(script);

    }
    else
    {
        ld("#"+jsfile).attr('src',global_js_url+"/"+jsurl+"?v="+global_js_version);


    }

    return ld("#"+jsfile).get(0);
}

function StopEvent(event){
    if(event!=undefined){

        // window.event? window.event.cancelBubble = true : event.stopPropagation();
        if(event.stopPropagation)
                event.stopPropagation();    //  阻止事件冒泡
        if(event.preventDefault)
             event.preventDefault();
    }
}
function escape2Html(str) {
    if (empty(str)) return '';
    var arrEntities={'lt':'<','gt':'>','nbsp':' ','amp':'&','quot':'"'};
    return str.replace(/&(lt|gt|nbsp|amp|quot);/ig,function(all,t){return arrEntities[t];});
}
function changeHrefUrl(url,arg,arg_val){
    var pattern=arg+'=([^&]*)';
    var replaceText=arg+'='+arg_val;
    if(url.match(pattern)){
        var tmp='/('+ arg+'=)([^&]*)/gi';
        tmp=url.replace(eval(tmp),replaceText);
        return tmp;
    }else{
        if(url.match('[\?]')){
            return url+'&'+replaceText;
        }else{
            return url+'?'+replaceText;
        }
    }
}

/**
 *变更创建人、负责人判断
 *andrew
 *20150929
 var mode = 'list';//类型：列表(list)详情页(detail)
 **/
function ChangeCreator(obj, module, popup_type, mode,record) {
    //获取要变更的ID
    var select_id = '';//选择的单据id
    var savefilter = '';//选择的单据个数
    var excludedRecords = '';
    if (mode == 'list') {//列表

        select_id = document.getElementById('allselectedboxes').value;
        if ('all' == select_id) {
            //获取全选数量
            selectlen = document.getElementById('numOfRows').value;
            excludedRecords = document.getElementById('excludedRecords').value;
            var objdiv_title = arrJsPopLabel['WARMPROMPT'];//标题
            if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
                savefilter += '&selectlen=' + selectlen;
                var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
                RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);

                //确定事件
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    ChangeCreators(popup_type, module, mode, select_id, excludedRecords, savefilter);
                });
            }
            else {
                ChangeCreators(popup_type, module, mode, select_id, excludedRecords, savefilter);
            }

        } else {


            var x = select_id.split(';');
            var count = x.length;
            if (0 == ld('input[name=selected_id]:checked').length) {
                // RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", "");
                MessagePopup.TipOne_warning();
                return false;
            }
            if (count - 1 > getMaxMassOperationLimit()) {
                var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', count - 1, getMaxMassOperationLimit(), '');
                //创建提示弹出层
                RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
                //确定事件
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    ChangeCreators(popup_type, module, mode, select_id, excludedRecords, savefilter);
                });
            } else {
                ChangeCreators(popup_type, module, mode, select_id, excludedRecords, savefilter);
            }
        }
    }
    else if (mode=='detail') {//详情页
        //zxm 20221227 详情页分配 单据id直接使用传过来的值
        ChangeCreators(popup_type, module, mode, record, excludedRecords, savefilter);
    }
}

/*
 *变更创建人、负责人
 *20180313 Liver
 */
function ChangeCreators(popup_type, module, mode, select_id, excludedRecords, savefilter) {
    savefilter += '&select_id=' + select_id;
    //自定义弹出层页面html，绑定事件
    //alert(popup_url);
    //var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.type);
    var popupobj=CrmPopup.getPopupObj('last');

    var scopepopupobj;
    var popup_caption_value;
    var popup_url = '';

    var popupinfo = getAllocateSharePopupInfo(popup_type, module);
    popup_caption_value = popupinfo.poptitle;
    popup_url = popupinfo.popup_url;

    getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
        if (popup_type == 'Allocate') {
            var methodObj = {'popup_check_inactiveuser': 'yes', 'popup_check_nogroupuser': 'no'};
        } else {
            var methodObj = {'popup_check_inactiveuser': 'yes'};
        }
        scopepopupobj = new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
        getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
            cls_ScopePopup.prop.popup_url = popup_url;//popup_url
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = '';
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);

            // ljj 20230904 BUG0072070 kfbcrm-弹出层的× title改为tip
            tooltip(".tip-items-pop", {transition: true, time: 200});

            //重写确认按钮事件
            scopepopupobj.setEventBtnOk = function () {
                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                    //没有选择任何用户，则给出提示
                    if (empty(cls_ScopePopup.return_obj.return_id)) {
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str);
                        return false;
                    } else {
                        ld('#' + cls_ScopePopup.popup_divid + ' .D_pbtn .D_pbtnok').attr("disabled", true);

                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        /*var viewid = getviewId();
                        var urlstring = 'module=Users&action=UsersAjax&file=ChangeCreatorInfo&setype=save';
                        urlstring += '&from_module=' + module + '&changetype=' + popup_type + '&mode=' + mode;
                        urlstring += '&select_id=' + select_id + '&caterorid=' + selected_user + '&excludedRecords=' + excludedRecords + '&viewname=' + viewid;
                        urlstring+="&username="+encodeURIComponent(cls_ScopePopup.return_obj.return_name);*/
                        // ld('#rptContentLoading').show();
                        startChangeCreator(selected_user,cls_ScopePopup.return_obj.return_name,popup_type, module, mode, select_id, excludedRecords,0);
                    }
                    //社交推广 detail页面更改负责人后 刷新页面
                    if(module == 'SocialPromotion' && mode =='detail'){
                        //  console.log(select_id)
                        afterDetailShareEvent(select_id)
                    }
                    //231031 wym XUQIU1002054 点击确认,保存当前是否勾选显示离职成员并刷新首页下拉框
                    if(ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser')){
                        var displayinactiv=ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
                        //wym 231115 BUG0075530 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054
                        var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule='+cls_ScopePopup.prop.popup_module+'&value='+displayinactiv;
                        ldAjaxNoProgresssync(tmpurlsting,'',function(data){
                        })
                    }
                });
            }
        });
    });
}
function startChangeCreator(selected_user,user_name,popup_type, module, mode, select_id, excludedRecords,startrow,join_url="")
{
    var viewid = getviewId();
    var intervalrow=4;
    var urlstring = 'module=Users&action=UsersAjax&file=ChangeCreatorInfo&setype=save';
    urlstring += '&from_module=' + module + '&changetype=' + popup_type + '&mode=' + mode;
    urlstring += '&select_id=' + select_id + '&caterorid=' + selected_user + '&excludedRecords=' + excludedRecords + '&viewname=' + viewid;

    urlstring+="&username="+encodeURIComponent(user_name)+"&startrow="+startrow+"&endrow="+(startrow+intervalrow);
    if(mode == 'list'){
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
            urlstring += '&isshowModuleListTree=yes';
        }
        if(module=='CollectionSlip'){//wym 240313 XUQIU20240218-01 新增预制表单：收款认领单
            var barobj = ld('#CollectionSlip_navbar_div').find('.cur').get(0);
            var barvalue= ld(barobj).attr('data-value');
            if(barvalue=='uncollected'){
                urlstring += '&navbar=uncollected';
            }
        }
    }
    urlstring += join_url;
    ldAjaxNoProgress('index.php?',urlstring, function (data) {
        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
        var tmpmsg = data.msg;
        var restobj = data.result;
        if(mode=='detail')
        {
            workflowCallApiPop(restobj);//工作流API弹窗
        }
        if(data.code == -1){
            if(tmpmsg.indexOf('###REACHMAXCUSTOMER###')>-1){
                var confirm_str = arrJsPopLabel['REACHMAXCUSTOMERJS'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            }
            if(tmpmsg.indexOf('###ALLOCATERREACHMAXCUSTOMERJSError###')>-1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ALLOCATERREACHMAXCUSTOMERJSError']);
                return false;
            }else if(tmpmsg.indexOf('###ALLOCATERREACHMAXCUSTOMERJSError1###')>-1){//客户启用公海时
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ALLOCATERREACHMAXCUSTOMERJSError1']);
                return false;
            }else if(tmpmsg.indexOf('###ALLOCATERREACHMAXLeadsJSError###')>-1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ALLOCATERREACHMAXLeadsJSError']);
                return false;
            }else if(tmpmsg.indexOf('###ALLOCATERREACHMAXLeadsJSError1###')>-1){//线索启用公海时
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ALLOCATERREACHMAXLeadsJSError1']);
                return false;
            }
        }
        else if(data.code == 1){
            if(mode=='list')
            {
                var tmppopupobjobj;

                if(startrow==0)
                {
                    tmppopupobjobj=ProgressPopup.load(restobj.progresstitle,"","",500,module,"","","","");
                    tmppopupobjobj.show();

                }
                else{
                    tmppopupobjobj=CrmPopup.getPopupObj('last');

                }
                var maxrows=parseInt(restobj.maxrows);
                var percent=parseInt(((startrow+intervalrow)/maxrows*100));
                //var width=parseInt((500*(startrow+intervalrow)/maxrows));

                tmppopupobjobj.setPercentWidth(percent);
                tmppopupobjobj.setTotalNum(restobj.selectrows);
                tmppopupobjobj.setCurNum(startrow);
                if(maxrows!=restobj.selectrows)
                {
                    tmppopupobjobj.setValidataNum(maxrows);
                }
                if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows))
                {
                    startChangeCreator(selected_user,user_name,popup_type, module, mode, select_id, excludedRecords,startrow+4, join_url);
                    return false;
                }
                else{
                    tmppopupobjobj.CancelEvent();
                }
            }
            if(mode=='detail')
            {
                //ls 2022-02-23 0050023: 系统设置》参数》提醒参数“客户服务单分配时是否发送短信或邮件通知客户服务单联系人” ；分配服务单单据TT10，没收到短信或邮件提醒(单据详情页分配时)
                //客户服务单分配时是否发送短信或邮件通知客户首要联系人
                if (module == 'HelpDesk') {
                    CreateSendForm(module, select_id);
                }

                if(data.result.errorcount >0){
                    MessagePopup.TipOne_warning(data.result.log.value);
                }else{
                    var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                    var tmparra=[detailviewpopupobj.record];
                    var tmpdata={};

                    var tmpobj= new AfterUpdatePrevPopupObjContent(module,restobj,tmparra);
                    tmpobj.eachrefreshDetailViewByModules([module]);
                    tmpobj.update();
                }

                return false;
            }
            if (ld('input[name=selected_id]').length == 0) {//Liver 2016/09/07 去掉&&module!='Documents'，原因是bug0024278: 知识管理明细：更多中点击-更改创建人，确定后，界面显示了更改创建人的提示消息
                puyoungJS_DialogBox.block();

                if (module == 'HelpDesk') {
                    var help_url = window.location.href;
                    help_url = help_url.replace('&sendtype=yes', '');
                    if (help_url.indexOf('&sendtype=yes') < 0 && popup_type == 'Allocate') {
                        help_url += '&sendtype=yes';
                    }
                    window.location.href = help_url;
                    return false;
                }
                puyoungJS_DialogBox.unblock();
                fninvshnew('selectpopup_1');
                if(parseInt(restobj.errorcount)>0)
                {
                    audioRemindsMsg("","",module,"","",restobj.log.value);
                    return false;
                }
                changeUser.saveretjson = restobj;

                changeUser.afterOperation(popup_type, selected_user, cls_ScopePopup.return_obj.return_name, module);
                if (popup_type == 'Allocate') {

                    var prevpopupobj = CrmPopup.getPopupObj("last");
                    prevpopupobj.smownercolumnname_value = cls_ScopePopup.return_obj.return_name;
                    PageRecordPopup.setDetailViewTitle(prevpopupobj.divid);
                }
                //window.location.reload();
                return false;
            }
            getJsScript('include/js/ldcrm.base.js', function () {
                //zkt 20230914 BUG0071724 kfbtest-产品管理-勾选一个产品，点击分配，选择成员，点击确认，此时提示信息更改负责人成功，但点击取消按钮则显示未分配，应去掉第二个弹出层的取消按钮
                resultRemindsMsg(restobj.title.value, "LdPopWidth600px", "", "yes", "yes", restobj.log.value);

                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    fninvshnew('mass_advancer');
                    puyoungJS_DialogBox.unblock();

                    if (ld('input[name=selected_id]').length > 0) {
                        if ($('basicsearchcolumns') != undefined)
                            $('basicsearchcolumns').innerHTML = '';
                        if ($('allselectedboxes') != undefined)
                            $('allselectedboxes').value = '';
                        if ($('excludedRecords') != undefined)
                            $('excludedRecords').value = '';
                        var tmparra=new Array();
                        var tmpobj= new AfterUpdatePrevPopupObjContent(module,"",tmparra);
                        //服务单保存后刷新服务单的历史记录(查看界面)
                        var refreshlistmodules = new Array(module);
                        tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                        //客户服务单分配时是否发送短信或邮件通知客户首要联系人
                        if (module == 'HelpDesk') {
                            CreateSendForm(module, select_id);
                        }
                        //window.location.reload();
                        if (document.getElementById("SmOwnerSearchScope") != undefined)
                            searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
                        var viewid = getviewId();
                    } else {
                        var tmparra=new Array();
                        var tmpobj= new AfterUpdatePrevPopupObjContent(module,"",tmparra);
                        //服务单保存后刷新服务单的历史记录(查看界面)
                        var refreshlistmodules = new Array(module);
                        tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                        // window.location.reload();

                    }
                });
                return false;

            });
        }
        else{
            return false;
        }
    });
}
//jquerynameobj:表示需要被赋名称的元素
//jqueryidobj:表示需要被赋角色id的元素
function cls_ChooseRoles(jquerynameobj,jqueryidobj)
{
    //edit:can 20200825 选择角色
    var that=this;
    this.Init=function(){

    }

    this.setEvent=function(){

    }
    that.btnok=function(){
        var popupobj=CrmPopup.getPopupObj('last');
        //获取选中的角色
        var selectoptionobjs=ld("#"+popupobj.divid+" [name=selectedAssmablyColumns]").find("option");
        //  alert(ld(selectoptionobjs).length);
        var profilename_arr=[];
        var profileid_arr=[];
        if(ld(selectoptionobjs).length>0)
        {
            ld.each(ld(selectoptionobjs),function(){
                profileid_arr.push(ld(this).val());
                profilename_arr.push(ld(this).text());
            })
        }
        if(ld(jquerynameobj).length>0)
        {
            ld(jquerynameobj).val(profilename_arr.join(","));
        }
        // alert(ld(jqueryidobj).length);
        if(ld(jqueryidobj).length>0)
        {
            ld(jqueryidobj).val(profileid_arr.join(","));
        }
        popupobj.CancelEvent();

    }
    ///获取已选择的角色
    that.setSelectProfileIds=function(selectprofileids)
    {
        that.selectprofileids=selectprofileids;
    }
    this.show=function(){

        var crmPopupobj=CrmPopup.load("","","","550",'Settings',"","","","");
        crmPopupobj.prevshow();
        ldAjax("index.php?module=Settings&action=SettingsAjax&file=getRoleListHtml&selectid="+that.selectprofileids,{},function(ajaxdata){
            crmPopupobj.setParams(ajaxdata.result.title,that.btnok,"","550",'Settings',"",ajaxdata.result.oktext,"",ajaxdata.result.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,ajaxdata.result.content);

        })
    }
}

//@edit:liushuai,2020-09-04,reason:【ID1001073】销售订单、报价单选择产品，输入数量后自动带出价格(两个地方调用该方法)
function getRelatedProductToolFieldPrice(popupobj,rowId) {
    //var popupobj=CrmPopup.getPopupObj('last');
    var tableobj=popupobj.getDetailTableObj();
    var that=this;
    var changetrobj = ld(tableobj).find('tr[rowindex='+rowId+']');
    function setRelateFieldValue(event)
    {
        var e=event||window.event;
        var new_rowid = ld(changetrobj).attr('rowindex');
        popupobj.fieldformulaobj.haveFinishedFormulaColumnsarr.push(ld(e.target).attr("name"));
        if(popupobj.fieldformulaobj.finishedcolumncount[ld(e.target).attr("name")]==undefined)
        {
            popupobj.fieldformulaobj.finishedcolumncount[ld(e.target).attr("name")]=1;
        }
        else{
            popupobj.fieldformulaobj.finishedcolumncount[ld(e.target).attr("name")]=parseInt(popupobj.fieldformulaobj.finishedcolumncount[ld(e.target).attr("name")])+1;
        }
        popupobj.CurRelatedProductToolFieldName = ld(e.target).attr("name");
        if(popupobj.RelatedProductToolFieldtriggcols[1] != undefined)
            popupobj.RelatedProductToolFieldtriggcols[1].push(ld(e.target).attr("name"));
        getRelatedProductToolFieldPriceCallBack(popupobj,new_rowid);

    }


    if (!empty(popupobj.relatedproducttoolfield) && popupobj.relatedproducttoolfield.length>0) {
        var detailfield_columninfo=[];
        ld.each(popupobj.detailfields,function(tmpindex,tmpdetailfieldinfo){
            detailfield_columninfo[tmpdetailfieldinfo.columnname]=tmpdetailfieldinfo;

        })
        var hadtriggerEvent=[];
        var typeofdata;
        ld.each(popupobj.relatedproducttoolfield,function(tmpindex,tmptrigger_columninfo){

            for(var i=0;i<tmptrigger_columninfo.trigger_columnname.length;i++)
            {
                var trigger_columnname=tmptrigger_columninfo.trigger_columnname[i];

                var trobj=ld(tableobj).find("tr[rowindex="+rowId+"]");
                var tmpobj=ld(trobj).find("#"+trigger_columnname);
                if(ld(tmpobj).length>0)
                {


                    var fieldinfo=detailfield_columninfo[trigger_columnname];
                    if(ld.inArray(trigger_columnname,hadtriggerEvent)>=0)
                    {
                        continue;
                    }

                    hadtriggerEvent.push(trigger_columnname);
                    if(fieldinfo!=undefined)
                        typeofdata=fieldinfo.typeofdata;

                    if(typeofdata==undefined||typeofdata=='')
                        continue;
                    if(typeofdata.toLocaleLowerCase().indexOf("d~")>=0||typeofdata.toLocaleLowerCase().indexOf("dt~")>=0)
                    {
                        //ld(tmpobj).unbind("blur",setRelateFieldValue);
                        //zkt 20240920 解绑事件，
                        // 获取元素上绑定的事件
                        var tmpobjevent = ld._data(tmpobj.get(0), "events");
                        if (tmpobjevent && tmpobjevent.blur) {
                            // 打印绑定的事件
                            tmpobjevent.blur.forEach(function(handler) {
                                // 检查处理程序的名称（如果是命名函数）
                                if (handler.handler.name === "setRelateFieldValue") {
                                    ld(tmpobj).off("blur", handler.handler);  // 解绑事件
                                }
                            });
                        }
                        ld(tmpobj).bind("blur",event,setRelateFieldValue);
                        continue;
                    }
                    //ld(tmpobj).unbind('change',setRelateFieldValue);
                    // 获取元素上绑定的事件
                    var tmpobjevent = ld._data(tmpobj.get(0), "events");
                    if (tmpobjevent && tmpobjevent.change) {
                        // 打印绑定的事件
                        tmpobjevent.change.forEach(function(handler) {
                            // 检查处理程序的名称（如果是命名函数）
                            if (handler.handler.name === "setRelateFieldValue") {
                                ld(tmpobj).off("change", handler.handler);  // 解绑事件
                            }
                        });
                    }
                    ld(tmpobj).bind("change",event,setRelateFieldValue);
                }


            };
            var requestvalues = getPageValueByCrmPopupFields(popupobj);//获取页面所有的值
            ld.each(tmptrigger_columninfo.effect_columnname,function(tmpindex,tmpeffect_columnname){

                var tmpobj=ld(trobj).find("#"+tmpeffect_columnname);
                if(ld(tmpobj).length>0)
                {
                    var fieldinfo=detailfield_columninfo[tmpeffect_columnname];
                    if(fieldinfo==undefined)
                        return true;

                    if(fieldinfo.uitype==60)
                    {
                        //下拉框
                        var dv_cmb_obj=ld(trobj).find('[name=dv_cmb_'+tmpeffect_columnname+"]");
                        var arrowobj=ld(dv_cmb_obj).find(" [tag=arrow]");

                        //BUG20240718-05 240718 解绑后下拉选项弹窗出不来了（暂时先不解绑）
                        ld(arrowobj).bind("click",function(){

                            var thisobj=ld(this);
                            var param = {}; //根据触发字段获取对应值组成json对象。
                            var hadtriggercolumns=[];
                            var effect_columnname=ld(this).attr("dropdownname")
                            ld.each(popupobj.relatedproducttoolfield,function(tmpindex,tmpinfo){
                                for(var i=0;i<tmpinfo.trigger_columnname.length;i++)
                                {
                                    var trigger_column=tmpinfo.trigger_columnname[i];
                                    if(ld.inArray(trigger_column,hadtriggercolumns)>=0)
                                    {
                                        continue;
                                    }
                                    hadtriggercolumns.push(trigger_column);

                                    if(ld(trobj).find(" #"+trigger_column).length>0&&ld(trobj).find(" #"+trigger_column).val()!='')
                                    {
                                        param[trigger_column]=ld(trobj).find(" #"+trigger_column).val();

                                    }
                                }

                            })

                            var ulobj=ld(trobj).find(" [name=cmb_ul_"+effect_columnname+"]");
                            var livalueobj=ld(ulobj).find(" [tag=livalue]");//点击赋值

                            if(ld(livalueobj).length>0)
                            {
                                return false;
                            }


                            //zkt 20240724 BUG20240723-75 分录加了根据产品BU带出的规则，当产品BU是"照明&创新BU"时不生效，经测试可能跟特殊符号 & 有关系
                            var surl = 'index.php?module=Settings&action=SettingsAjax&file=getRelatedPicklistByColumn&modulename='+popupobj.module+'&param='+encodeURIComponent(JSON.stringify(param))+'&requestvalues='+encodeURIComponent(requestvalues['requestvalue'])+'&sensitiverequestfield='+encodeURIComponent(requestvalues['sensitiverequestfield']);
                            surl+='&effect_columnname='+effect_columnname;

                            ldAjaxNoProgress(surl,{},function(ajaxdata){
                                if(ajaxdata.code=='1')
                                {
                                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(effect_columnname);

                                    cls_resetComboxHtmlobj.setPopupObj(popupobj);//
                                    cls_resetComboxHtmlobj.setDetailFieldRowIndex(rowId);
                                    cls_resetComboxHtmlobj.setPickListContent(ajaxdata.result.list);

                                    cls_resetComboxHtmlobj.removeAllLi(effect_columnname);
                                    cls_resetComboxHtmlobj.setEvent();
                                    cls_resetComboxHtmlobj.arrowobjClick(thisobj);
                                }
                            })


                        })
                    }
                    else if(fieldinfo.uitype==63)
                    {

                    }
                }

            })

        })

    }


}
//后台计算单价
var kl=0;
function getRelatedProductToolFieldPriceCallBack (popupobj,rowId){
    //var popupobj=CrmPopup.getPopupObj('last');
    var havefinishedcolumn='';
    if(popupobj.fieldformulaobj != undefined)
        havefinishedcolumn = popupobj.fieldformulaobj.haveFinishedFormulaColumnsarr[0];
    var havefinishedmaincolumn='';
    if(popupobj.mainfieldformulaobj != undefined)
        havefinishedmaincolumn = popupobj.mainfieldformulaobj.computerfieldnames[0];

    // console.log(popupobj.relatedproducttoolfield);
    if (!empty(popupobj.relatedproducttoolfield) && popupobj.relatedproducttoolfield.length>0&&popupobj.relatedproducttoolfield[0].trigger_columnname!='') {
        var requestvalues = getPageValueByCrmPopupFieldsNew(popupobj);//获取页面所有的值
        var rowvalueinfo = popupobj.detaildatavalue_arr[rowId-1];

        //console.log('已触发：'+rowId);
        var tableobj=popupobj.getDetailTableObj();

        var rowobj=ld(tableobj).find("tr[rowindex="+rowId+"]");

        var trigger_columnname = popupobj.relatedproducttoolfield.trigger_columnname;
        var param ={}; //根据触发字段获取对应值组成json对象。
        var hadtriggercolumns=[];

        ld.each(popupobj.relatedproducttoolfield,function(tmpindex,tmpinfo){
            for(var i=0;i<tmpinfo.trigger_columnname.length;i++)
            {
                var trigger_column=tmpinfo.trigger_columnname[i];
                if(ld.inArray(trigger_column,hadtriggercolumns)>=0)
                {
                    continue;
                }
                hadtriggercolumns.push(trigger_column);
                if(trigger_column=='hdnProductId')
                {
                    param[trigger_column]=rowvalueinfo['productid'];
                }

                else  if(rowvalueinfo[trigger_column] != undefined)
                {


                    param[trigger_column]=rowvalueinfo[trigger_column];

                }
            }

        })

        // console.log(param);
        var triggercolumn = popupobj.CurRelatedProductToolFieldName || '';
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=getRelatedDetailField&modulename='+popupobj.module+'&triggercolumn='+triggercolumn;
        if(ld("#"+popupobj.divid+' [name=inventory_currency]').length>0)
        {
            surl+='&inventory_currency='+ld("#"+popupobj.divid+' [name=inventory_currency]').val();
        }

        ldAjaxsync(surl,{"requestvalues":(requestvalues['requestvalue']),"sensitiverequestfield":(requestvalues['sensitiverequestfield']),"requestvalue_arr": requestvalues['requestvalue_arr'],"param":JSON.stringify(param)},function(data){
            if(data.code == 1){
                var detailcolumn_fields=[];

                ld.each(popupobj.detailfields,function(tmpindex,tmpfieldinfo){
                    //2022/6/8 chj 选择产品无法关联带出 选择单据 字段
                    if(tmpfieldinfo.uitype == 100){
                        detailcolumn_fields[tmpfieldinfo.columnname+'_name']=tmpfieldinfo;
                    }
                    detailcolumn_fields[tmpfieldinfo.columnname]=tmpfieldinfo;
                })
                ld.each(data.result.list,function(tmpindex,tmpeffectinfo){
                    //chj 2022/2/8 49893: （http://crm.genfine.com:85/crm/ [^]）（济凡）订单分录中做的特殊开发（组织与仓库的级联），当选好仓库之后，修改后面的数值，仓库会自动回到默认的第一个仓库
                    if(popupobj.module == 'SalesOrder' && account_version != undefined && account_version == 'jifan' && ld.inArray(popupobj.CurRelatedProductToolFieldName,tmpeffectinfo.trigger_columnname)>=0)
                    {
                        //console.log('wwww');
                    }else if (popupobj.module == 'SalesOrder' && account_version != undefined && account_version == 'jifan') {
                        return;
                    }

                    for(var i=0;i<tmpeffectinfo.effect_columnname.length;i++)
                    {
                        var effect_columnname=tmpeffectinfo.effect_columnname[i].effect_columnname;
                        if(effect_columnname=='hdnProductId')
                        {

                            ld(rowobj).find(" #"+effect_columnname).val( tmpeffectinfo.effect_columnname_value[0]['hdnproductid'] );
                            continue;
                            // ld(rowobj).find(" #"+effect_columnname).val(selected_arr);
                        }
                        var rows=tmpeffectinfo.effect_columnname[i].rows;

                        if(ld(rowobj).find(" #"+effect_columnname).length>0)
                        {

                            var detailfieldinfo=detailcolumn_fields[effect_columnname];
                            if(detailfieldinfo==undefined)
                                continue;
                            if(detailfieldinfo.uitype==60)
                            {

                                if(popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")]==undefined)
                                {
                                    popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")]=[];
                                }

                                if(ld.inArray(effect_columnname,popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")])>=0)
                                {

                                    continue;
                                }

                                //下拉框
                                var picklistcontent={};
                                //chj 20220519 下拉框级联，当下级级联为空时，没有清空上次的级联内容
                                if(rows > 0){
                                    for(var j=0;j<rows;j++)
                                    {
                                        var pickvalue= tmpeffectinfo.effect_columnname_value[j][effect_columnname];
                                        if(j == 0){
                                            ld(rowobj).find(" #"+effect_columnname).val(pickvalue);
                                            ld(rowobj).find(" [name=cmb_span_optiontext_"+effect_columnname+"]").val(pickvalue);
                                        }
                                        picklistcontent[pickvalue]=pickvalue;
                                    }
                                }else{
                                    ld(rowobj).find(" #"+effect_columnname).val('');
                                    ld(rowobj).find(" [name=cmb_span_optiontext_"+effect_columnname+"]").val('');
                                }
                                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(effect_columnname);

                                cls_resetComboxHtmlobj.setPopupObj(popupobj);//edit:can 产品多选//产品套餐选择
                                cls_resetComboxHtmlobj.setDetailFieldRowIndex(rowId);
                                cls_resetComboxHtmlobj.setPickListContent(picklistcontent);

                                cls_resetComboxHtmlobj.removeAllLi(effect_columnname);
                                cls_resetComboxHtmlobj.setEvent();
                                //console.log(popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")]);
                                if(ld.inArray(effect_columnname,popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")])>=0)
                                {

                                }
                                else
                                {


                                    if(ld.inArray(effect_columnname,hadtriggercolumns)>=0)
                                    {

                                        popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")].push(effect_columnname);
                                        //  getRelatedProductToolFieldPriceCallBack (popupobj,rowId);
                                    }

                                }
                            }
                            else if(detailfieldinfo.uitype==63)
                            {
                                //edit:can 20211126 48951: 【工程】（https://www.51mis.com/hy/jiance1122/ [^]）销售管理>>报价单单据分录中：产品同时添加废水和噪声，噪声的检测项目不显示
                                if(popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")]==undefined)
                                {
                                    popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")]=[];
                                }

                                if(ld.inArray(effect_columnname,popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")])>=0)
                                {

                                    continue;
                                }

                                var selected_arr=[];
                                ld(rowobj).find(" #"+effect_columnname).empty();
                                ld.each(tmpeffectinfo.effect_columnname_value,function(tmp_index,tmpvalueinfo){

                                    var tmpvalue=tmpvalueinfo[effect_columnname];
                                    selected_arr.push(tmpvalue);
                                    ld(rowobj).find(" #"+effect_columnname).append("<option value='"+tmpvalue+"'>"+tmpvalue+"</option>");

                                })

                                ld(rowobj).find(" #"+effect_columnname).val(selected_arr);
                                ld(rowobj).find(" #"+effect_columnname).select2({closeOnSelect: true, dropdownParent: ld("#"+popupobj.divid)});

                                if(ld.inArray(effect_columnname,popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")])>=0)
                                {

                                }
                                else
                                {

                                    if(ld.inArray(effect_columnname,hadtriggercolumns)>=0)
                                    {
                                        popupobj.RelatedProductToolFieldtriggcols[ ld(rowobj).attr("rowindex")].push(effect_columnname);
                                        getRelatedProductToolFieldPriceCallBack (popupobj,rowId);
                                    }

                                }
                            }else if(detailfieldinfo.uitype==100){
                                if(tmpeffectinfo.effect_columnname_value[0][effect_columnname] != undefined && tmpeffectinfo.effect_columnname_value[0][effect_columnname] != 'undefined'){
                                    ld(rowobj).find(" #"+effect_columnname).val(tmpeffectinfo.effect_columnname_value[0][effect_columnname]);
                                    ld(rowobj).find(" #"+effect_columnname).get(0).value = decodeURI(tmpeffectinfo.effect_columnname_value[0][effect_columnname]);
                                    ld(rowobj).find(" #"+effect_columnname).get(0).disabled  = true;
                                    ld(rowobj).find(" #"+effect_columnname).get(0).style.cursor = 'not-allowed';
                                }
                            }
                            else
                            {

                                ld(rowobj).find(" #"+effect_columnname).val(tmpeffectinfo.effect_columnname_value[0][effect_columnname]);
                                //chj 润泽 特殊开发 是否促销期=必须促销时， 实际含税单价 不可编辑
                                if(effect_columnname == 'chuxiao_date'){
                                    if(tmpeffectinfo.effect_columnname_value[0][effect_columnname] == '必须促销'){
                                        var temp_chuxiao_jia = ld(rowobj).find(" #chuxiao_jia").val();
                                        var temp_taxprice = ld(rowobj).find(" #taxprice").val();
                                        if(temp_taxprice < temp_chuxiao_jia){
                                            temp_chuxiao_jia = temp_taxprice;
                                        }
                                        var hidden_val = "<input type=\"hidden\" tag=\"money\" value=\""+temp_chuxiao_jia+"\" name=\"actualtaxprice\" detailcolumnname=\"actualtaxprice\" class=\"dropdown-toggle tip-items\" data-tip=\"0.0000\" data-direction=\"top\" data-type=\"position\"><span name=\"span_actualtaxprice\" detailcolumnname=\"span_actualtaxprice\" class=\"dropdown-toggle tip-items\" data-tip=\"0.0000\" data-direction=\"top\" data-type=\"position\">"+temp_chuxiao_jia+"</span>";
                                        ld(rowobj).find(" #actualtaxprice").html(hidden_val);
                                    }else{
                                        if(ld(rowobj).find(" #span_actualtaxprice").length>0){
                                            var temp_taxprice = ld(rowobj).find(" #taxprice").val();
                                            var hidden_val = "<input tag=\"money\" type=\"text\" detailcolumnname=\"actualtaxprice\" onkeypress=\"setKeyCode(1,'actualtaxprice',event)\" style=\"width:100%;margin-top:5px;margin-bottom:-8px;color:\" value='"+temp_taxprice+"' name=\"actualtaxprice\" class=\"dropdown-toggle tip-items\" data-tip=\"\" data-direction=\"top\" data-type=\"position\">";
                                            ld(rowobj).find(" #actualtaxprice").html(hidden_val);
                                        }
                                    }
                                }
                            }
                            if(detailfieldinfo.edit_permission==3||detailfieldinfo.edit_permission==1)
                            {
                                //edit:can 2021-01-11 44183: ld_related_producttoolfield 表通过SQL对单据分录赋值的功能，当需要赋值的字段设置为不可编辑时，无法赋值

                                ld(rowobj).find(" #span_"+effect_columnname).html(tmpeffectinfo.effect_columnname_value[0][effect_columnname]);
                            }
                        }

                        if(ld.inArray(effect_columnname,popupobj.fieldformulaobj.formulaneedColumnarr)>=0)
                        {
                            //字段公式
                            popupobj.fieldformulaobj.haveFinishedFormulaColumnsarr.push(havefinishedcolumn);
                            if(popupobj.fieldformulaobj.finishedcolumncount[havefinishedcolumn]==undefined)
                            {
                                popupobj.fieldformulaobj.finishedcolumncount[havefinishedcolumn]=1;
                            }
                            else{
                                popupobj.fieldformulaobj.finishedcolumncount[havefinishedcolumn]=parseInt(popupobj.fieldformulaobj.finishedcolumncount[havefinishedcolumn])+1;
                            }
                            popupobj.fieldformulaobj.changedatabyColumnname(effect_columnname,rowId);
                        }
                        if (ld.inArray(effect_columnname, popupobj.detail2mainformulaobj.computerdetailcolumn_arr) >= 0) {
                            //字段公式  ls 20220921 BUG0056778 单据头字段用分录函数计算时，没有计算
                            popupobj.mainfieldformulaobj.hadcomputerfieldnames.push(havefinishedmaincolumn);
                            var param = [];
                            param['data'] = {'formulacolumn': effect_columnname, rowindex: rowId};
                            popupobj.detail2mainformulaobj.startComputer(param);
                        }

                        popupobj.fieldformulaobj.haveFinishedFormulaColumnsarr=[];
                        popupobj.fieldformulaobj.finishedcolumncount=[];
                        popupobj.mainfieldformulaobj.hadcomputerfieldnames=[];
                    }
                    popupobj.fieldformulaobj.CountsubTotal();
                })
                //popupobj.RelatedProductToolFieldtriggcols=[];
                popupobj.CurRelatedProductToolFieldName='';
                DelProgressObjs();
                return true;
            }else{

                DelProgressObjs();
                return false;
            }
        })
    }

}

//获取页面所有的值通过CrmPopup.fields。
function getPageValueByCrmPopupFields(popupobj) {
    //  var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj==undefined || popupobj.fields==undefined)
    {
        return '';
    }
    var sensitiverequestfield_arr = [];
    var  requestvalues="{";
    ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
        if (typeof tmpfieldinfo.columnname == 'undefined') {
            return true;
        }
        if(tmpfieldinfo.uitype != 230){
            var tmpfieldvalue = '';
            if(tmpfieldinfo.havesensitivevalue != undefined && tmpfieldinfo.havesensitivevalue == 'yes'){
                tmpfieldvalue = tmpfieldinfo.sensitiveencryptvalue;
                sensitiverequestfield_arr.push("requestvalues-"+tmpfieldinfo.fieldname);
            }
            else{
                if(tmpfieldinfo.uitype == 33){//多选框
                    //ls 20220811 BUG0055029 多选框字段没有处理，导致requestvalues没有多选框字段值，ld_relatecreatecondition 规则不生效，变量没有被替换
                    var strtmp = getMultiPickListSelectValue(tmpfieldinfo.fieldname + "[]");
                    tmpfieldvalue = strtmp;
                }else if(tmpfieldinfo.uitype == 117){
                    tmpfieldvalue = ld("#"+popupobj.divid+" [name=inventory_currency]").val();
                }else if (tmpfieldinfo.fieldname == 'reltab') {
                    tmpfieldvalue = ld("#"+popupobj.divid+" [name=related_to_type]").val();
                }
                else if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0){
                    //BUG20240819-65 ls 240819 转义含有引号的值
                    tmpfieldvalue = ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val();
                    if(!empty(tmpfieldvalue) && tmpfieldvalue.hasOwnProperty('replaceAll')){
                        // edit:can BUG20240904-35 电话管家，客户、跟进记录保存点不动

                        tmpfieldvalue = tmpfieldvalue.replaceAll("'","\\'").replaceAll('"','\\"');
                    }
                    if(tmpfieldinfo.bigtype=='reference')
                        tmpfieldvalue += '","'+tmpfieldinfo.columnname+'_name":"'+(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"_name]").val());

                }else if (ld.inArray(tmpfieldinfo.fieldname,["hdnGrandTotal","hdnSubTotal","txtAdjustment"])>=0 && ld("#"+popupobj.divid+" [name="+tmpfieldinfo.columnname+"]").length>0){
                    //合计、小计、调整取值更改
                    tmpfieldvalue = ld("#"+popupobj.divid+" [name="+tmpfieldinfo.columnname+"]").val();
                }
            }
            requestvalues += '"'+tmpfieldinfo.columnname+'":"'+tmpfieldvalue+'",';
            if (tmpfieldinfo.bigtype == 'selectsource') {
                if(ld("#" + popupobj.divid + " [name=selectsource]").length>0){
                    requestvalues += '"selectsourcemodule":"' + ld("#" + popupobj.divid + " [name=selectsource]").val() + '",';
                }
            }
        }
    })
    requestvalues=requestvalues.substr(0,requestvalues.length-1);//删除“，”
    requestvalues+="}";

    var sensitiverequestfield = JSON.stringify(sensitiverequestfield_arr);

    return {'requestvalue':requestvalues,'sensitiverequestfield':sensitiverequestfield};
}
//edit:duan date:2024/11/26 reason:原有的方法没有处理掉特殊字符，例如双引号的情况，加个新方法获取
function getPageValueByCrmPopupFieldsNew(popupobj) {
    //  var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj==undefined || popupobj.fields==undefined)
    {
        return '';
    }
    var sensitiverequestfield_arr = [];
    var requestvalues_arr = {};
    ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
        if (typeof tmpfieldinfo.columnname == 'undefined') {
            return true;
        }
        if(tmpfieldinfo.uitype == 230 || tmpfieldinfo.uitype == 231){
            return true;
        }
        var tmpfieldvalue = '';
        if(tmpfieldinfo.havesensitivevalue != undefined && tmpfieldinfo.havesensitivevalue == 'yes'){
            tmpfieldvalue = tmpfieldinfo.sensitiveencryptvalue;
            sensitiverequestfield_arr.push("requestvalues_arr-"+tmpfieldinfo.fieldname);
        }
        else{
            if(tmpfieldinfo.uitype == 33){//多选框
                //ls 20220811 BUG0055029 多选框字段没有处理，导致requestvalues没有多选框字段值，ld_relatecreatecondition 规则不生效，变量没有被替换
                var strtmp = getMultiPickListSelectValue(tmpfieldinfo.fieldname + "[]");
                tmpfieldvalue = strtmp;
            }else if(tmpfieldinfo.uitype == 117){
                tmpfieldvalue = ld("#"+popupobj.divid+" [name=inventory_currency]").val();
            }else if (tmpfieldinfo.fieldname == 'reltab') {
                tmpfieldvalue = ld("#"+popupobj.divid+" [name=related_to_type]").val();
            }
            else if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0){
                //BUG20240819-65 ls 240819 转义含有引号的值
                tmpfieldvalue = ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val();
                if(!empty(tmpfieldvalue) && tmpfieldvalue.hasOwnProperty('replaceAll')){
                    // edit:can BUG20240904-35 电话管家，客户、跟进记录保存点不动

                    tmpfieldvalue = tmpfieldvalue.replaceAll("'","\\'").replaceAll('"','\\"');
                }
                if(tmpfieldinfo.bigtype=='reference'){
                    requestvalues_arr[tmpfieldinfo.columnname+'_name'] = ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"_name]").val();
                }

            }else if (ld.inArray(tmpfieldinfo.fieldname,["hdnGrandTotal","hdnSubTotal","txtAdjustment"])>=0 && ld("#"+popupobj.divid+" [name="+tmpfieldinfo.columnname+"]").length>0){
                //合计、小计、调整取值更改
                tmpfieldvalue = ld("#"+popupobj.divid+" [name="+tmpfieldinfo.columnname+"]").val();
            }
        }
        requestvalues_arr[tmpfieldinfo.columnname] = tmpfieldvalue;
        if (tmpfieldinfo.bigtype == 'selectsource') {
            if(ld("#" + popupobj.divid + " [name=selectsource]").length>0){
                requestvalues_arr['selectsourcemodule'] = ld("#" + popupobj.divid + " [name=selectsource]").val();
            }
        }
    })
    var requestvalues = JSON.stringify(requestvalues_arr);

    var sensitiverequestfield = JSON.stringify(sensitiverequestfield_arr);

    return {'requestvalue':requestvalues,'sensitiverequestfield':sensitiverequestfield,'requestvalue_arr':requestvalues_arr};
}


//duan 20240906 获取产品分录行的值
function getPageValueByCrmPopupProductDetailFields(popupobj,tmpvalueindex) {
    //  var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj==undefined || popupobj.fields==undefined )
    {
        return '';
    }
    var tableobj=popupobj.getDetailTableObj();
    var tmpvalueinfo = popupobj.detaildatavalue_arr[tmpvalueindex];
    var tmpdetailfield=popupobj.detailfields;
    var url = '';
    var i = tmpvalueindex+1;
    var rowindex = 0;
    var rowcount = 0;
    var value_arr = {};
    if(!empty(tmpvalueinfo)){
        var productid = tmpvalueinfo.productid;
        rowindex++;
        if (ld.trim(productid) == '' || parseInt(productid) <= 0) {
            //判断是否为空行
            return false;
        }
        rowcount++;
        var productbomid = tmpvalueinfo.productbomid;
        if (productbomid == undefined)
            productbomid = 0;
        var productbomquantity = tmpvalueinfo.productbomquantity;
        if (productbomquantity == undefined)
            productbomquantity = 0;
        var lineitem_name = "lineitem_id" + i;
        var before_lineitem_id_name = "before_lineitem_id" + i;
        var paramname = "hdnProductId" + i;

        value_arr["productbomid" + i] = productbomid;
        value_arr["productbomquantity" + i] = productbomquantity;
        value_arr[paramname] = productid;
        value_arr[lineitem_name] = tmpvalueinfo.parent_lineitem_id;
        value_arr[before_lineitem_id_name] = tmpvalueinfo.lineitem_id;

        ld.each(tmpdetailfield, function (tmpindex, tmpfieldinfo) {
            var tablename = tmpfieldinfo.tablename;
            var fieldlabel = tmpfieldinfo.fieldlabel;
            var tmpname = tmpfieldinfo.columnname;
            var paramname = tmpfieldinfo.columnname + i;
            var typeofdata = tmpfieldinfo.typeofdata;
            var value = tmpvalueinfo[tmpname];
            var typeofdatas = typeofdata.split("~");

            if(tmpfieldinfo.uitype==60 && tmpname=='wareid')
            {
                value=tmpvalueinfo[tmpname+"_rawvalue"];

            }
            else if(tmpfieldinfo.uitype == 56){
                value = (value==true||value==1)?1:0;
            }
            //多选框  多选框的uitype为63
            if (tmpfieldinfo.uitype == 63) {
                var strtmp = tmpvalueinfo[tmpname];
                value_arr[paramname] = strtmp;
            }
            else {
                if((typeofdatas[0] == 'N' || typeofdatas[0] == 'NN') && value!=undefined && value!='' && value!='undefined'){
                    value = value.toString();
                }
                if(tmpfieldinfo.columnname == 'entitytypeid'){
                    if (value === '0') {
                        value = '';
                    }
                }
                value_arr[paramname] = value;
            }
            if (tmpfieldinfo.columnname == 'entitytypeid') {
                var tmpselectSourceModuleid = "selectSourceModuleid" + i;
                value_arr[tmpselectSourceModuleid] = value;
            }
        })
    }

    return value_arr;
}

//非产品分录
function getPageValueByCrmPopupDetailFields(popupobj,rowid) {
    //  var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj==undefined || popupobj.fields==undefined || empty(rowid)||empty(popupobj.detailfields))
    {
        return '';
    }
    var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");

    var requestdetailvalues="{";
    ld.each(popupobj.detailfields,function(tmpindex,tmpfieldinfo){
        if (typeof tmpfieldinfo.columnname == 'undefined') {
            return true;
        }
        var tablename = tmpfieldinfo.tablename;
        var fieldname = tmpfieldinfo.fieldname;
        // var columnname = tmpfieldinfo.columnname;
        var tmpfieldvalue = '';
        if (tablename == popupobj.detailtablenamescf || tablename == popupobj.detailtablename) {

            if (tmpfieldinfo.fieldtype == 'SelectComBox') {

                //多选框
                var tmpobj = ld(rowobj).find(" #" + fieldname );
                if(tmpobj.attr("multiple")!=undefined) {
                    var strtmp = getMultiPickListSelectValueByObj(tmpobj);
                }else{
                    var strtmp = tmpobj.val();
                }
                tmpfieldvalue = encodeURIComponent(strtmp);
            }else if (tmpfieldinfo.fieldtype == 'entitytype') {
                tmpfieldvalue = ld(rowobj).find(" #select_entitytypeid").val();
            }
            else if (ld(rowobj).find(" #" + fieldname ).length>0) {
                tmpfieldvalue = ld(rowobj).find(" #" + fieldname ).val();
                if(!empty(tmpfieldvalue) && tmpfieldvalue.hasOwnProperty('replaceAll')){
                    tmpfieldvalue = tmpfieldvalue.replaceAll("'","\\'").replaceAll('"','\\"');
                }
            }
        }
        requestdetailvalues += '"'+fieldname+'":"'+tmpfieldvalue+'",';
    })

    requestdetailvalues=requestdetailvalues.substr(0,requestdetailvalues.length-1);//删除“，”
    requestdetailvalues+="}";

    return {'requestdetailvalue':requestdetailvalues};
}
//duan 20240906 获取单据所有行的分录值
function getPageValueByCrmPopupAllProductDetail(popupobj) {
    var url = '';
    var all_value_arr = {};
    if (popupobj.detailfieldmodule == 'Products')//产品分录保存
    {
        var rowcnt = 0;

        var productdetail_arr = {};
        var i= 0;

        ld.each(popupobj.detaildatavalue_arr, function (tmpvalueindex, tmpvalueinfo) {
            productdetail_arr = getPageValueByCrmPopupProductDetailFields(popupobj,tmpvalueindex);
            if(productdetail_arr){
                rowcnt ++;
                all_value_arr = Object.assign({}, all_value_arr, productdetail_arr);
            }
        })
        all_value_arr['rowcnt'] = rowcnt;

        if (popupobj.module == 'CashBill') {
            all_value_arr['cashbill_total'] = ld("#" + popupobj.divid + " [name=total]").val();
        } else if (popupobj.module == 'SendCashBill') {
            all_value_arr['sendcashbill_total'] = ld("#" + popupobj.divid + " [name=total]").val();
        } else{
            all_value_arr['total'] = ld("#" + popupobj.divid + " [name=total]").val();
        }
        var subtotal = 0;
        if(ld("#" + popupobj.divid + " [name=subtotal]").length >0 ){
            subtotal = ld("#" + popupobj.divid + " [name=subtotal]").val();
        }
        all_value_arr['subtotal'] = subtotal;
        all_value_arr['inventory_currency'] = ld("#" + popupobj.divid + " [name=inventory_currency]").val();
        var adjustmentobj = ld("#" + popupobj.divid + " [name=adjustment]");
        if (adjustmentobj.length > 0) {
            all_value_arr['adjustment'] = adjustmentobj.val();
            all_value_arr['adjustmentType'] = ld("#" + popupobj.divid + " [name=adjustmentType]").val();
        }
        var allSingledDiscountobj = ld("#" + popupobj.divid + " [name=allSingledDiscount]");
        if (allSingledDiscountobj.length > 0) {
            all_value_arr['allSingledDiscount'] = allSingledDiscountobj.val();
            all_value_arr['discount_amount'] = ld("#" + popupobj.divid + " [name=discount_amount]:last").val();
        }
    } else if (popupobj.hasOwnProperty('detailfieldmodule') && popupobj.detailfieldmodule !== undefined && popupobj.detailfieldmodule.indexOf('detailhtml') > -1) {
        var trobjs = popupobj.getTrObjsByDelType("no")//获取没有删除的行
        var ret = true;
        var rowcnt = ld(trobjs).length;
        all_value_arr['rowcnt'] = rowcnt;
        var tmp_arr = {};
        var tmp_value_arr = {};
        for (var i =1 ;i<=rowcnt;i++){
            tmp_arr = getPageValueByCrmPopupDetailFields(popupobj,i);

            if(tmp_arr && tmp_arr['requestdetailvalue']){
                tmp_value_arr = JSON.parse(tmp_arr['requestdetailvalue']);
                ld.each(tmp_value_arr,function (tmp_index,tmp_value) {
                    all_value_arr[tmp_index+i] = tmp_value;
                })
            }
        }

        if (popupobj.module == 'CashBill') {
            all_value_arr['cashbill_total'] = ld("#" + popupobj.divid + " [name=total]").val();
            if (ld("#" + popupobj.divid + " [name=subtotal]").length > 0 ) {
                var subtotal = 0;
                if( ld("#" + popupobj.divid + " [name=selectsource]").length > 0){
                    //未选择源单时subtotal值可能空，仅在客户预收单是才可设置值
                    if (ld("#" + popupobj.divid + " [name=selectsource]").val() == '') {
                        if (ld("#" + popupobj.divid + " [name=subtotal]").val() == 0 || ld("#" + popupobj.divid + " [name=subtotal]").val() == '') {
                            subtotal = ld("#" + popupobj.divid + " [name=total]").val();
                        } else {
                            subtotal = ld("#" + popupobj.divid + " [name=subtotal]").val();
                        }
                    }
                    all_value_arr['subtotal'] = subtotal;
                }
                else if(popupobj.cashbilltype != undefined && popupobj.cashbilltype == 'cashbill'){
                    subtotal = ld("#" + popupobj.divid + " [name=subtotal]").val();
                    all_value_arr['subtotal'] = subtotal;
                }

            }
        } else if (popupobj.module == 'SendCashBill') {
            all_value_arr['sendcashbill_total'] = ld("#" + popupobj.divid + " [name=total]").val();
            if (ld("#" + popupobj.divid + " [name=subtotal]").length > 0) {
                var subtotal = 0;
                if(ld("#" + popupobj.divid + " [name=selectsource]").length > 0){
                    if (ld("#" + popupobj.divid + " [name=selectsource]").val() == '') {
                        subtotal = ld("#" + popupobj.divid + " [name=total]").val();
                    }
                    all_value_arr['subtotal'] = subtotal;
                }
                else{
                    subtotal = ld("#" + popupobj.divid + " [name=total]").val();
                    all_value_arr['subtotal'] = subtotal;
                }
            }
        } else {
            all_value_arr['total'] = ld("#" + popupobj.divid + " [name=total]").val();
        }
    }
    return all_value_arr;
}


/**
 * @edit:dong
 * @data:2020/12/23
 * @reason:
 * @description: 新建数据分类 非公开
 */
function changeSetaslinkmodule(obj){
    var popupobj=CrmPopup.getPopupObj('last');
    if(ld(obj).is(':checked')){
        ld('#'+popupobj.divid+' [name=setStatus]').prop('checked',true);
        ld('#'+popupobj.divid+' [name=setStatus]').attr('disabled',true);
    }else{
        ld('#'+popupobj.divid+' [name=setStatus]').attr('disabled',false);
    }
}
/*
edit:chj
2021/9/22
多选模块
*/
function selectModuleForMore(mod,module,fieldname){
    var popupobj=CrmPopup.getPopupObj('last');
    var is_enable = 'select=enable';
    var surl = "module="+module+"&action=Popup&ReportHeader=dheader&html=Popup_picker&popuptype=selectsource&form=EditView&"+is_enable+"&listval=&parent_module="+module+"&frommodule="+mod+"&popup=yes&page_popup=yes&selectmoduleformore="+fieldname;
    var  requestvalues="{";
    ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
        if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0)
            requestvalues+='"'+tmpfieldinfo.columnname+'":"'+ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val()+'",';
    })
    requestvalues=requestvalues.substr(0,requestvalues.length-1);//删除“，”
    requestvalues+="}"

    surl+="&requestvalues="+encodeURIComponent(requestvalues);
    CrmPopupWindow(mod,surl,module);
}

function clearModuleMore(module,fieldname){
    var popupobj=CrmPopup.getPopupObj('last');
    ld("#"+popupobj.divid+" [name="+fieldname+"]").val('');
    ld("#"+popupobj.divid+" [name="+fieldname+"_label]").val('');
}

//客户适用范围
function setModuleScope(module,fieldname,fieldlabel,frommodule){
    var popupobj=CrmPopup.getPopupObj('last');
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=setModuleScope&fieldname='+fieldname+'&frommodule='+frommodule;
    surl += '&advft_criteria='+ld("#"+popupobj.divid+" [name="+fieldname+"_advft_criteria]").val();
    surl += '&advft_criteria_groups='+ld("#"+popupobj.divid+" [name="+fieldname+"_advft_criteria_groups]").val();
    if(popupobj.type == 'detailviewpage'){
        surl += '&record='+popupobj.record;
    }
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(fieldlabel,saveModuleScope,'',"LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
            crmPopupobj.createScrollDiv();
            crmPopupobj.show(data.result.content);
            crmPopupobj.highersearchobj=new HigherSearchGroup("adv_filter_div");
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
                        // wym 230516 为下拉框赋值
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
            else
                crmPopupobj.highersearchobj.addNewConditionGroup();
            crmPopupobj.setScrollDivMaxHeight();
            crmPopupobj.center();
        }
    })
}

//适用范围保存
function saveModuleScope(){
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj.highersearchobj.checkAdvancedFilter()==false)
    {
        return false;
    }
    var fieldname = ld("#"+popupobj.divid+" [name=fieldname]").val();
    var record = ld("#"+popupobj.divid+" [name=record]").val();
    var frommodule = ld("#"+popupobj.divid+" [name=frommodule]").val();

    var advft_criteria = ld("#"+popupobj.divid+" [name=advft_criteria]").val();
    var advft_criteria_groups = ld("#"+popupobj.divid+" [name=advft_criteria_groups]").val();
    var prev_popupobj=CrmPopup.getPopupObj('lastprev');
    ld("#"+prev_popupobj.divid+" [name="+fieldname+"_advft_criteria]").val(advft_criteria);
    ld("#"+prev_popupobj.divid+" [name="+fieldname+"_advft_criteria_groups]").val(advft_criteria_groups);
    if(record > 0){
        var surl = 'index.php?module='+frommodule+'&action='+frommodule+'Ajax&file=setModuleScope&fieldname='+fieldname+'&savemodulescope=yes&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+'&record='+record;
        ldAjaxNoProgress(surl,"",function(data){
            if(data.code==1){
                popupobj.CancelEvent();
            }
        })
    }else{
        popupobj.CancelEvent();
    }

}

function selectMoreRecord(module,fieldname,selectmodule){
    getJsScript('include/js/popupselectfield.js',function(){
        selectMoreRecords(module,fieldname,selectmodule);
    });
}

//回填主表字段至列表界面
function updateListtdFieldHtml(tdobj,module,fieldshowinfo){//record,fieldinfo
    if(!empty(fieldshowinfo.tdinnerhtml))
    {
        ld(tdobj).html(fieldshowinfo.tdinnerhtml);
        return ;
    }
    if(ld(tdobj).find(" span[type=vtlib_metainfo]").length>0)
    {

        var field_metainfoobj = ld(tdobj).find(" span[type=vtlib_metainfo]");
        var vtrecordid = ld(field_metainfoobj).attr("vtrecordid");
        var vtfieldname = ld(field_metainfoobj).attr("vtfieldname");
        var vtmodule = ld(field_metainfoobj).attr("vtmodule");
        var updatelistfieldobj = ld(field_metainfoobj).prev();

        if(ld(updatelistfieldobj).attr("module") == vtmodule && ld(updatelistfieldobj).attr("fieldname")== vtfieldname && ld(updatelistfieldobj).attr("record") == vtrecordid)
        {
            var value = fieldshowinfo.showvalue.value;
            ld(updatelistfieldobj).html(value);//更新界面显示值
            //如果有title 更新title
            if(ld(updatelistfieldobj).attr("title")!=''&&ld(updatelistfieldobj).attr("title")!=undefined){
                ld(updatelistfieldobj).attr("title",value);
            }
            if(vtfieldname== 'last_name'&&vtmodule == 'Users')
            {
                ld(updatelistfieldobj).attr("data-tip",value);
            }

        }

    }
}

//chj 20220510 云星空库存报表查询
function search_pro_stock_btn(searchtype,page){
    var search_str = ld("#search_str").val();
    var search_lists = [];
    var search_value = [];
    search_lists = search_str.split(',');
    ld.each(search_lists,function(i,colname){
        if(ld("#"+colname).val() != undefined && ld("#"+colname).val() != 'undefined'){
            var col_value = (ld("#"+colname).val());
            var col_sel = (ld("#"+colname+'_sel').val());
            if(col_value != ''){
                search_value.push(colname +'|@@|'+col_value  +'|@@|'+col_sel);
            }
        }
    });
    var search = search_value.join('|%%|');
    if(search == '')
        return false;
    var urlstring = 'module=ReportAnalysis&action=ReportAnalysisAjax&is_ajax=yes&file=stock_report&search='+encodeURIComponent(search)+'&page='+page;

    ld('#rptContentLoading').show();
    ld('#search_dd').html('数据正在查询中.....');
    //ld('#rptContentLoading').show();
    //alert(urlstring);
    new Ajax.Request(
        'index.php',
        {queue:{position:"end", scope:"command"},
            method:"post",
            postBody:urlstring,
            onComplete:function (response) {
                ld('#search_dd').html('');
                ld('#rptContentLoading').hide();
                ld("div[name=meiante_ListViewContents]").html(response.responseText);

                //var restlist = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
            }
        }
    );
    return false;
}
//chj 20220510 产品库存查询
function search_pro_stock(btn_jqueryobj,productid){

    //wyt 221124 BUG0058960 产品明细界面，总库存数量，看ERP库存时，如果没有配置，点击页面不加载内容，必须刷新，建议给出提示
    var erpview=ld(btn_jqueryobj).attr('view');
    if(erpview=='no'){
        var confirm_str = "ERP库存未配置！";
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    var popupobj=CrmPopup.getPopupObj('last');
    var stock_view = ld(btn_jqueryobj).attr('tag');
    if(empty(productid)){
        var that=this;
        var rowobj=popupobj.getTrObjByChild(btn_jqueryobj);
        var rowId=parseInt(ld(rowobj).attr("rowindex"));
        //BUG20240329-22 ls 240401 	销售订单X202403270005 下推出货申请时，分录内查询库存按钮点击没反应
        productid=popupobj.detaildatavalue_arr[rowId-1].productid;
        if(productid== undefined
            || productid == ''){
            audioRemindsMsg("","",'',"","",arrJsPopLabel['PRODUCTNAME']+arrJsPopLabel['CANOTEMPTY']);
            return false;
        }
        var module = 'Products';

    }
    if(!empty(stock_view) && !empty(productid)){
        if(stock_view == 'CRM'){
            getJsScript('include/js/modules/Products/Products.js',function(){
                product_detail_qtyinstock(productid,'detail')
            });
        }else{
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth1300px","","",'none',"","");
            crmPopupobj.prevshow();
            var url = 'module=ReportAnalysis&action=ReportAnalysisAjax&file=stock_report&record=' + productid;
            ld.ajax({
                url: 'index.php?',
                type: 'POST',
                data:url,
                dataType:'json',
                async: true,//
                timeout: 0,
                success: function(data)
                {
                    if(data.code==1){
                        var title=data.result.title;
                        var oktext=data.result.oktext;
                        var canceltext=data.result.canceltext;
                        crmPopupobj.setParams(title,"","","LdPopWidth1300px",module,"",oktext,"",canceltext);
                        crmPopupobj.show(data.result.content);
                        crmPopupobj.center();
                    }
                }
            });
        }
    }
}

//zxm 20220110 关闭浏览器保存新建页面的暂存信息
function addwindowlistener (e) {
    //不是所有浏览器都支持提示信息的修改
    var confirmationMessage = "请先保存您编辑的内容,否则您修改的信息可能会丢失。";
    e.returnValue = confirmationMessage;
    //编辑页取消时，关闭定时器
    if (isAvailablelocalStorage) {
        SaveDataRecord.cancelInterval();
        // var Popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
        var Popupobj = CrmPopup.getPopupObj("last");
        var oldStorageKey = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_old';
        // var tmpStorageKey = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_tmp';
        var newStorageKey = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_new';
        //取消时，如果新页面有缓存，则将新页面复制给旧页面，再删除新页面(此時只保留旧頁面的值)。
        var finished = 'no';
        var circle_len = 0;
        var max_circle_len = 10;
        if (!empty(localStorage.getItem(newStorageKey))) {
            while (finished == 'no' && circle_len < max_circle_len) {
                try {
                    localStorage.setItem(oldStorageKey, localStorage.getItem(newStorageKey));
                    localStorage.removeItem(newStorageKey);
                    // localStorage.removeItem(tmpStorageKey);

                    if (!empty(localStorage.getItem(newStorageKey + '_productdetail'))) {
                        localStorage.setItem(oldStorageKey + '_productdetail', localStorage.getItem(newStorageKey + '_productdetail'));
                        localStorage.removeItem(newStorageKey + '_productdetail');
                        // localStorage.removeItem(tmpStorageKey + '_productdetail');
                    }
                    finished = 'yes';
                } catch (e) {
                    if (e.name === 'QuotaExceededError') {
                        removeOldStorage(Popupobj);
                    }
                }
                circle_len++;
            }
        }
    }
    alert(confirmationMessage) ;
};
//切换页码 zxm 20230328 另外三个在tpl中的方法都注释了
function ldSelectPageNum(obj,pagenum,totalrows){
    var divobj = ld(obj).parent().parent().parent();
    divobj.find('#pagenum').val(pagenum);
    divobj.find('#pagenum_show').html(pagenum+'/'+totalrows+'&nbsp;&nbsp;<b class="down"></b><b style="visibility: hidden">'+totalrows+'</b>');
    divobj.find('#pagenum').change();
}

// 加密解密方法：string-需要解密的字段  code-约定的密钥    operation 默认false表示加密，传入true表示解密
function ld_js_secret(string, code, operation) {
    code = CryptoJS.MD5(code).toString()
    var iv = CryptoJS.enc.Utf8.parse(code.substring(0, 16))
    var key = CryptoJS.enc.Utf8.parse(code.substring(16))
    if (operation) {
        return CryptoJS.AES.decrypt(string, key, {
            iv: iv,
            padding: CryptoJS.pad.Pkcs7
        }).toString(CryptoJS.enc.Utf8)
    }
    return CryptoJS.AES.encrypt(string, key, {
        iv: iv,
        mode: CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7
    }).toString()

}

function crmcommonueditoronclick(url,path, filename) {
    var urlstr = "index.php?module=Users&action=UsersAjax&file=PreviewFileByPath&path="+encodeURIComponent(path)+"&filename="+encodeURIComponent(filename);
    OpenNewWebTab(urlstr, '_blank');  // This will open the link in a new tab
}
//liushuai  20230803 XUQIU1001688 工作流程定制->调用 API 功能优化（异步调用公共弹窗）
function workflowCallApiPop(flowinfo) {//data.result
    if (!empty(flowinfo) && flowinfo.hasOwnProperty("workflow")&& !empty(flowinfo.workflow) && flowinfo.workflow.receive_msg == 'yes') {
        //调用工作流程定制API
        var flowPopupobj=CrmPopup.load(arrJsPopLabel['APICall'],"","","LdPopWidth650px",'Settings',"",arrJsPopLabel['CONFIRMED'],"","");
        flowPopupobj.prevshow();
        var content = '<div class="qui_dialog_body ld-dialog-Boxbody" style="background-color: #fff;"><div class="ld-msgDlg-Boxbottom">'
            +'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:15px;padding-left: 0px;">'+arrJsPopLabel['CallingAPIWorkflow'] +'</div></div></div>';
        flowPopupobj.show(content);

        var surl = 'index.php?module='+flowinfo.workflow.module+'&action='+flowinfo.workflow.module+'Ajax&file=getReverseCallAPI';
        ldAjax(surl,{'workflow':flowinfo.workflow},function(flowdata){
            if(flowdata.code==1){
                setTimeout(function(){
                    flowPopupobj.setParams('','',"","LdPopWidth650px",flowinfo.workflow.module,"","","","","");
                    flowPopupobj.show(flowdata.result.content);

                    ld('#'+flowPopupobj.divid).find('.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                        flowPopupobj.CancelEvent();
                    });
                    DelProgressObjs();

                },1000);

            }
        })
    }
}

//同步调用公共弹窗（工作流删除节点）
function workflowSyncPop(flowinfo) {//data.result
    if(!empty(flowinfo)){
        if (flowinfo.hasOwnProperty("workflow")&& !empty(flowinfo.workflow) && flowinfo.workflow.receive_msg == 'yes') {
            //调用工作流程定制API
            var flowPopupobj=CrmPopup.load(arrJsPopLabel['APICall'],"","","LdPopWidth650px",'Settings',"",arrJsPopLabel['CONFIRMED'],"","");
            flowPopupobj.prevshow();
            var content = '<div class="qui_dialog_body ld-dialog-Boxbody" style="background-color: #fff;"><div class="ld-msgDlg-Boxbottom">'
                +'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:15px;padding-left: 0px;">'+arrJsPopLabel['CallingAPIWorkflow'] +'</div></div></div>';
            flowPopupobj.show(content);

            setTimeout(function(){
                flowPopupobj.setParams('','',"","LdPopWidth650px","","",arrJsPopLabel['CONFIRMED'],"","","");
                flowPopupobj.show(flowinfo.workflow.content);

                ld('#'+flowPopupobj.divid).find('.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                    flowPopupobj.CancelEvent();

                });
                DelProgressObjs();

            },1000);
        }
    }
}

//XUQIU1001933 xxy 2023-10-10 暂存功能，当localStorage超出限制时报错，捕获到这个错误并对缓存中的旧缓存进行删除
function removeOldStorage(Popupobj){
    var regex = /_.+_create_\d+_/;//暂存的缓存格式的正则
    if(localStorage.getItem('tmpStorageKey_arr') == null || empty(localStorage.getItem('tmpStorageKey_arr'))){
        localStorage.setItem('tmpStorageKey_arr','');
        var tmpStorage_arr = [];
    }else{
        var tmpStorage_arr = localStorage.getItem('tmpStorageKey_arr');
        tmpStorage_arr = tmpStorage_arr.split(',');
    }
    for (var i = 0; i < tmpStorage_arr.length; i++) {
        var tmp_elem = tmpStorage_arr[i];

        if (tmp_elem.split('_')[1] != Popupobj.module && regex.test(tmp_elem)) {//删除的缓存要匹配暂存缓存的格式且不是当前模块的
            localStorage.removeItem(tmp_elem);
            tmpStorage_arr.splice(i, 1);

            var detailIndex = tmpStorage_arr.indexOf(tmp_elem.replace('_productdetail', ''));//单据头缓存，有的话一并删除
            var productdetailIndex = tmpStorage_arr.indexOf(tmp_elem + '_productdetail');//产品分录缓存，有的话一并删除
            if (detailIndex !== -1) {
                localStorage.removeItem(tmpStorage_arr[detailIndex]);
                tmpStorage_arr.splice(detailIndex, 1);
            }
            if (productdetailIndex !== -1) {
                localStorage.removeItem(tmpStorage_arr[productdetailIndex]);
                tmpStorage_arr.splice(productdetailIndex, 1);
            }
            break;
        }
    }
}

//XUQIU1002448 日程管理->日历视图，可自定义显示字段（陈钦帅） 选择字段事件
function fieldSel(obj){
    var crmPopupobj=CrmPopup.getPopupObj("last");
    if (obj.value == '--无--' || obj.value == '--NONE--'){
        ld("#"+crmPopupobj.divid+" #selField").val('');
    }else {
        ld("#"+crmPopupobj.divid+" #selField").val("[var."+obj.value+"]");
    }
}
//XUQIU1002448 日程管理->日历视图，可自定义显示字段（陈钦帅） 变量插入textarea事件
function InsertField(obj) {
    var crmPopupobj=CrmPopup.getPopupObj("last");
    if(empty(ld("#"+crmPopupobj.divid+" #selField").val()))
    {
        //请选择字段！
        MessagePopup.TipZero_warning(arrJsPopLabel['PLEASESELECTFIELD']);
        return false;
    }
    var str=ld("#"+crmPopupobj.divid+" [name=CKcontent]").val();
    str+= ld("#"+crmPopupobj.divid+" #selField").val();
    ld("#"+crmPopupobj.divid+" [name=CKcontent]").val(str);
    ld("#"+crmPopupobj.divid+" [name=CKcontent]").focus();
}

function detail_numValidate(fldName,fldLabel,format,neg,currobjvalue) {
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;

    //editor:gyq_132 reason:库存报表高级查找的分页，此时获取的divid错误，需要特殊赋值  2019/7/18 15:43
    if(ld('#advanced_filter_mark').val()==='yes'){
        divid = 'dv_listhighersearch' ;
    }

    var val=currobjvalue.replace(/^\s+/g, '').replace(/\s+$/g, '');
    if(typeof userCurrencySeparator != 'undefined' && userCurrencySeparator != '') {
        while(val.indexOf(userCurrencySeparator) != -1) {
            val = val.replace(userCurrencySeparator,'');
        }
    }
    if(typeof userDecimalSeparator != 'undefined' && userDecimalSeparator != '') {
        if(val.indexOf(userDecimalSeparator) != -1) {
            val = val.replace(userDecimalSeparator,'.');
        }
    }
    //end
    if (format!="any") {
        if (isNaN(val)) {
            var invalid=true
        } else {
            var format=format.split(",")
            var splitval=val.split(".")
            if (neg==true) {
                if (splitval[0].indexOf("-")>=0) {
                    if (splitval[0].length-1>format[0])
                        invalid=true
                } else {
                    if (splitval[0].length>format[0])
                        invalid=true
                }
            } else {
                /*if (val<0)
					invalid=true 订单应收为0时候，无法进行小编辑
				else */
                if (format[0]==2 && splitval[0]==100 && (!splitval[1] || splitval[1]==0))
                    invalid=false
                else if (splitval[0].length>format[0])
                    invalid=true
            }
            if (splitval[1])
                if (splitval[1].length>format[1])
                    invalid=true
        }
        if (invalid==true) {
            var confirm_str = arrJsPopLabel['INVALID']+' '+fldLabel+arrJsPopLabel['ORTHENUMBERISBEYONDTHECHARACTERLENGTH'];
            audioRemindsMsg("","","","","",confirm_str);
            try {
                //currObj.focus()
            } catch(error) { }
            return false
        }else return true
    } else {
        if (isNaN(val)) {
            var confirm_str = arrJsPopLabel['INVALID']+' '+fldLabel;
            audioRemindsMsg("","","","","",confirm_str);
            return false;
        }
        // changes made -- to fix the ticket#3272
        if(fldName == "probability" || fldName == "commissionrate")
        {
            var val=currobjvalue.replace(/^\s+/g, '').replace(/\s+$/g, '');
            var splitval=val.split(".")
            var arr_len = splitval.length;
            var len = 0;

            if(arr_len > 1)
                len = splitval[1].length;
            if(isNaN(val))
            {
                var confirm_str = arrJsPopLabel['INVALID']+' '+fldLabel;
                audioRemindsMsg("","","","","",confirm_str);
                try {
                    //currObj.focus()
                }catch(error) { }
                return false
            }
            else if(splitval[0] > 100 || len > 3 || (splitval[0] >= 100 && splitval[1] > 0))
            {
                var confirm_str = fldLabel + arrJsPopLabel['EXCEEDMAXIMUMLIMIT'];
                audioRemindsMsg("","","","","",confirm_str);
                return false;
            }
        }
        else {
            var splitval=val.split(".")
            if(splitval[0]>18446744073709551615)
            {
                var confirm_str = fldLabel + arrJsPopLabel['EXCEEDMAXIMUMLIMIT'];
                audioRemindsMsg("","","","","",confirm_str);
                return false;
            }
        }

        if (neg==true)
            var re=/^(-|)(\d)*(\.)?\d+(\.\d\d*)*$/
        else
            var re=/^(\d)*(\.)?\d+(\.\d\d*)*$/
    }

    //for precision check. ie.number must contains only one "."
    var dotcount=0;
    for (var i = 0; i < val.length; i++)
    {
        if (val.charAt(i) == ".")
            dotcount++;
    }

    if(dotcount>1)
    {
        var confirm_str = arrJsPopLabel['INVALID']+' '+fldLabel;
        audioRemindsMsg("","","","","",confirm_str);
        try {
            //currObj.focus()
        }catch(error) { }
        return false;
    }


    return true
}

function detail_numConstComp(fldName,fldLabel,type,constval,val) {

    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    //var currObj=CrmPopup.findHtmlobj(divid,fldName);
    //var val=currObj.val().replace(/^\s+/g, '').replace(/\s+$/g, '');
    constval=parseFloat(constval)

    var ret=true
    switch (type) {
        case "L"  :
            if (val>=constval) {
                var confirm_str = fldLabel+arrJsPopLabel['SHOULDLESSTHAN']+constval;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ret=false
            }
            break;
        case "LE" :
            if (val>constval) {
                /*
         edit:cdw
         date:20130726
         reason:0004547: 页面设置：提示信息“length应小于或等于58”和“Decimal应小于或等于30”未汉化望修改
         */
                if(fldLabel == "Length"){
                    var confirm_str = arrJsPopLabel['LENGTH']+arrJsPopLabel['SHOULDLESSTHANOREQUAL']+constval;
                }
                if(fldLabel == "Decimal")
                {
                    var confirm_str = arrJsPopLabel['Decimal']+arrJsPopLabel['SHOULDLESSTHANOREQUAL']+constval;
                }
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ret=false
            }
            break;
        case "E"  :
            if (val!=constval) {
                var confirm_str = fldLabel+arrJsPopLabel['SHOULDBEEQUAL']+constval;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ret=false
            }
            break;
        case "NE" :
            if (val==constval) {
                var confirm_str = fldLabel+arrJsPopLabel['NOTEQUAL']+constval;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ret=false
            }
            break;
        case "G"  :
            if (val<=constval) {


                if('数量'==fldLabel || 'Quantity'==fldLabel){
                    var confirm_str = arrJsPopLabel['Thenumberofproduct'];
                }else{
                    var confirm_str = arrJsPopLabel['CHARACTERLENGTH'];
                }
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ret=false
            }
            break;
        case "GE" :
            if (val<constval) {
                var confirm_str = fldLabel+arrJsPopLabel['SHOULDGREATEROREQUAL']+constval;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ret=false
            }
            break;
    }


    if (ret==false) {
        return false
    } else return true;
}
function getKanbanView(module,showmode){
    var iskanbanshow=ld('#iskanbanshow').val();
    if(iskanbanshow=='yes'){
        ld('#iskanbanshow').val('no')
    }else{
        ld('#iskanbanshow').val('yes')
    }
    var browserwidth=window.innerWidth;
    var pageleftwidth=ld("#pageleft_unfold").css('width');
    var browserheight=window.innerHeight;
    var pagetopheight=ld("#pagehead").css('height');

    //wyt 230606 BUG0067357 kfbcrm 销售机会---开启树结构---切换到看板视图--右边划不过去 看不到了
    var treeobj=ld(".user-left-td");
    var expand = treeobj.css("display")=='none' || treeobj.css("display")==undefined ?'no':'yes';
    if (expand == 'yes') {
        browserwidth = browserwidth -structureTreeobj.treeWidth;
    }
    else{
        browserwidth = browserwidth;
    }
    pageleftwidth=browserwidth-parseFloat(pageleftwidth)+'px';
    //zkt 20240129 BUG20240129-60 商机看板视图，下面滚动条不显示了，需要浏览器缩放一下才会显示，明天下午给客户演示，希望加急处理下
    var main_grid_topheight=0;
    if(ld("#ListViewNavBarAndBtn").length>0){
        main_grid_topheight+=parseFloat(ld("#ListViewNavBarAndBtn").css('height'));
    }
    if(ld("#ListViewBtnAndSeach").length>0){
        main_grid_topheight+=parseFloat(ld("#ListViewBtnAndSeach").css('height'));
    }
    pagetopheight=browserheight-parseFloat(pagetopheight)-main_grid_topheight-10-50+'px';//10：头部间隔。50看板列头


    var surl = '';
    //参数用与判断是否是数据分类转为模块  禁用数据分类下拉框及隐藏 数据分类设置
    var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
        surl += '&ajaxtype=ld_linkmodulecustom';
    }
    surl += '&viewid='+ld("#viewname").val();
    surl += '&viewname='+ld("#viewname").val();

    if(showmode=='kanban'){
        ldAjax('index.php?module='+module+'&action='+module+'Ajax&file=ListView&kanbanajax=no&viewmode=kanban&pageleftwidth='+pageleftwidth+'&pagetopheight='+pagetopheight+surl,'',function(data)
        {
            if(data.code==1)
            {
                ld('#pagecontent1').html(data.result);
                //加载tip 20230511 diony
                tooltip('.tip-items-list', {transition: true, time: 200});
                DelProgressObjs();
            }
        });
    }else if(showmode=='ListView'){
        var urlstring="index.php?module="+module+'&action='+module+"Ajax&file=index&isshowModuleListTree=yes&viewmode=listview"+surl;
        ldAjaxHtml(urlstring,{},function(data){
            CrmPopup.global_listPopupObj=[];
            listcontentobj.html(data);
            DelProgressObjs();
        });
    }

}


var topheight=55;//快速查找所在div的高度55
var con_mt_height=10;//头部和内容中间margin距离10
var uitabsheight=50;//导航高度
var main_grid_top=60;//main_grid_top高度，报表
var main_left_width=216;//内容中左侧宽度200+内容和左右margin距离各自8
//加载右侧内容中菜单和详细内容高度
function initRightContentHeight(){
    ld('.statistic-analysis-content .statistic-analysis-sidebar').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height)+'px');
    ld('.main_grid .main_grid_box').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top) +'px');//46863
    ld('.main_grid .ld-operationlog-list-content').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top) -150 +'px');//46863
    ld('.main_grid_reportanalysis .main_grid_box').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top) +'px');//zxm 20221103 报表分析 打开新页面的常用报表 高度设置
    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
        //通讯录(pc端企业微信)
        cls_wxOpenDataobj.bindAllOpenData();
    }
}

function OpenNewWebTab(url, ...args) {
    if(typeof OpenNewWebTab.environment === "undefined") {
        if(/DingTalk/i.test(navigator.userAgent)) {
            OpenNewWebTab.environment = "dingtalk";
        }
        else if(/wxwork/i.test(navigator.userAgent)) {
            OpenNewWebTab.environment = "weixinh5";
        }
        else {
            OpenNewWebTab.environment = "other";
        }
    }
    // ld("#pagehead .detail_path").append(`<span>${navigator.userAgent}</span>`);
    if(OpenNewWebTab.environment === "dingtalk"){
        var head;
        if((/.+\?.+/).test(url)) {
            head = '&'
        }
        else if((/.+\?.*/).test(url)){
            head = ''
        }
        else {
            head = '?'
        }
        url = url + head + 'ddtab=true';
    }
    // ld("#pagehead .detail_path li").text(url);
    window.open(url,args)
}
/**
 * 系统环境：标识系统所处环境
 * 具体为：dingtalk - 钉钉 、weixinh5 - 企业微信h5 、yunzhijia - 云之家 、 app - 手机APP 、 (weixin / wxwork ) - 小程序
 * @type {undefined | 'dingtalk' | 'weixinh5' | 'weixin' | 'wxwork' | 'yunzhijia' | 'app'}
 */
OpenNewWebTab.environment = undefined

// 分配共享，根据操作类型获取弹窗标题，选人控件的url等
function getAllocateSharePopupInfo(popup_type,module,pool_id=''){
    // var popup_type = this.mode;
    // var module = this.module;

    var poptitle = '';// 标题
    var popup_url = '';
    var popupinfo = {};

    if (popup_type == 'ChangeCreator') {
        poptitle = arrJsPopLabel['CHANGECREATED'];
        if(module == 'WorkReportList'){
            poptitle = arrJsPopLabel['CHANGESPONSOR'];
        }
        popup_url = 'module=Users&action=UsersAjax&file=changecreatorPop&popup_scopetype=public&popup_module=' + module + '&popup_inputtype=radio&popup_selecttype=user&popup_type=' + popup_type;
    }
    // 共享
    else if(popup_type == 'Share' || popup_type == 'seniorShare'){
        poptitle = arrJsPopLabel['SHARE'];
        popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module=' + module + '&popup_inputtype=checkbox&popup_selecttype=user&fieldname=team_memberid';
    }
    // 平均分配
    else if(popup_type == 'averageDistribution' || popup_type == 'seniorAverageAllocate'){
        if(module=='ServiceCharge'){
            poptitle = arrJsPopLabel['AVERAGEDISTRIBUTIONSERVICECASHER'];
        }else{
            poptitle = arrJsPopLabel['AVERAGEDISTRIBUTIONASSIGNED'];
        }
        popup_url = 'module='+module+'&action='+module+'Ajax&file=allocatePop&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&popup_type='+popup_type;
    }
    // 公海分配
    else if(popup_type == 'higndistribution' || popup_type == 'seniorHigndistribution'){
        poptitle = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];
        popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&ishighseaallocate=yes&pool_id='+pool_id;
    }
    // 公海平均分配
    else if(popup_type == 'averagehigndistribution' || popup_type == 'seniorAverageHigndistribution'){
        poptitle = arrJsPopLabel['LBL_AVGDISTRIBUT_HIGHSEAS_JSOP'];
        popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popuboxp_selecttype=user&ishighseaallocate=yes&pool_id='+pool_id;
    }
    // 分配
    else if(popup_type == 'Allocate' || popup_type == 'seniorAllocate'){
        //2016-12-02 Liver bug0026267: 服务收费管理：分配弹出层的tips显示错误
        if (module == 'ServiceCharge') {
            poptitle = arrJsPopLabel['DISTRIBUTECHANGESERVICECASHER'];
        } else {
            poptitle = arrJsPopLabel['DISTRIBUTECHANGEASSIGNED'];
        }
        //024943: 控制面板 系统参数设置 分配弹出层是否显示所有用户设置为否 当我数据范围是个人的时候 点击分配还弹出全部用户
        popup_url = 'module=' + module + '&action=' + module + 'Ajax&file=allocatePop&popup_scopetype=public&popup_module=' + module + '&popup_inputtype=radio&popup_selecttype=user&popup_type=' + popup_type;
    }

    popupinfo = {
        'poptitle' : poptitle,
        'popup_url' : popup_url,
    }
    return popupinfo;
}

/**
 * 用于将源对象的所有可枚举属性复制到目标对象中（深层复制）,若源对象为 undefined则不做处理
 * - 目标对象 和 源对象必须同为数组类型或对象类型
 * @param target 目标对象
 * @param resource 源对象
 * @return target 目标对象
 */
function deepAssign(target,resource) {
    var that = this;
    this._deepAssign = function (t,r) {
        if(typeof r !== 'undefined' && (Array.isArray(t) ^ Array.isArray(r)) === 0){
            if(Array.isArray(r)){
                for (var i = 0;i < r.length; i ++){
                    that._assign(t,r,i);
                }
            }
            else{
                for (var key in r) {
                    that._assign(t,r,key);
                }
            }
        }
    }
    this._assign = function (t,r,key) {
        if(typeof r[key] !== 'object'){
            t[key] = r[key]
        }
        else{
            if (typeof t[key] === "undefined")
                t[key] = Array.isArray(r[key]) ? [] : {}
            that._deepAssign(t[key], r[key]);
        }
    }
    that._deepAssign(target,resource);
    return target;
}

//ljj 20240910 XUQIU1001487 客户增加【客户图谱】，类似于联系人图谱（戚涛） 选择相关客户
function getRelatedRecords() {
    var popupobj = CrmPopup.getPopupObj('last');
    if(popupobj != undefined && !empty(popupobj.relationshipChartobj)){
        popupobj.relationshipChartobj.getRelatedRecord()
    }
    ld('#popupdoubleclick').remove();//双击选择和反选提示
}

// 自定义按钮点击事件
function customButtonClick(position, module, record, btnid) {
    getJsScript('include/js/modules/Settings/ButtonsCustomization.js', function () {
        var buttoncustomizationObj = new ButtonsCustomization();
        buttoncustomizationObj.buttonClick(position, module, record, btnid);
    });
}
// ls 241111 XUQIU20241021-01 安付宝商务开发
function DecryptColumn(){
    var that = this;
    this.Decrypt = function(position, module, record) {
        var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=DecryptColumn&ajax=true';
        var param = {'record': record};
        ldAjax(surl,param,function (data){
            if(data.code == 1){
                if (position == 'detail') {
                    var detailviewpopupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                    ld.each(data.result.column_fields_value,function(tmpindex,tmpfieldinfo){
                        if (tmpfieldinfo.bigtype=='text' && ld("#"+detailviewpopupobj.divid+ " [name=dtlview_"+tmpfieldinfo.fieldname+"]") != undefined) {//span
                            ld("#"+detailviewpopupobj.divid+ " [name=dtlview_"+tmpfieldinfo.fieldname+"]").text(tmpfieldinfo.value);
                        }else if(tmpfieldinfo.bigtype=='reference'){
                            if(ld("#"+detailviewpopupobj.divid+ " a[fieldname="+tmpfieldinfo.fieldname+"]").length > 0) {//a  显示超链接
                                ld("#" + detailviewpopupobj.divid + " a[fieldname=" + tmpfieldinfo.fieldname + "]").text(tmpfieldinfo.value);
                                ld("#" + detailviewpopupobj.divid + " a[fieldname=" + tmpfieldinfo.fieldname + "]").attr("title",tmpfieldinfo.value);
                            } else{
                                ld("#" + detailviewpopupobj.divid + " td[name=mouseArea_" + tmpfieldinfo.fieldname + "]").text(tmpfieldinfo.value);
                            }
                        }
                    })
                }
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULOPERATION']);

                DelProgressObjs();
            }else{
                MessagePopup.TipOne_warning(data.msg);
            }
        });
    }

    this.EncryptString = function(obj) {
        if(ld('#encryptstring').length>0){
            if(ld('#encryptstring').val() == ''){
                var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            }
        }

        var surl = 'index.php?module=Accounts&action=AccountsAjax&file=DecryptColumn&ajax=true&operationtype=encryptstring';
        var param = {'encrypt_string': ld('#encryptstring').val()};
        ldAjax(surl,param,function (data){
            if(data.code == 1){
                MessagePopup.TipOne_success(data.result.encryptdata);

                DelProgressObjs();
            }else{
                MessagePopup.TipOne_warning(data.msg);
            }
        });

    }
}
DecryptColumn.curobj = '';
DecryptColumn.getInstance=function(){
    if(!empty(DecryptColumn.curobj)){
    }else{
        DecryptColumn.curobj=new DecryptColumn();
    }
    return DecryptColumn.curobj;
}

//设置短信内容
function SmsContentSetting(){
    var that = this;
    var smsTemplateList = [];//所有的短信模板
    //获取启用的短信模板
    this.getSmsTemplateList = function (callback) {
        return new Promise((resolve, reject) => {
            var surl = 'index.php?module=MassSMS&action=MassSMSAjax&file=SmsTemplate&ajax=true&operationtype=getsmstemplate';
            ldAjaxsync(surl,'',function (data){
                if(data.code == 1){
                    that.smsTemplateList = data.result.smstemplatelist;

                    if (!empty(callback)) {
                        callback(data);
                    }

                    resolve();
                }else{
                    reject();
                    return false;
                }
                DelProgressObjs();
            });
        })

    }


    /**
    * 显示已经设置过的短信模板内容
     *
     * @popupobj 短信设置弹窗
     * eg：审批提醒    tmpsmstemplateconf: 需要填充的已设置过的变量数组（自动提醒的编辑或者审批提醒的暂存）
    * */
    this.ShowSmsTemplateEvent = async function (popupobj,tmpsmstemplateconf) {
        if (empty(popupobj)) {
            popupobj = CrmPopup.getPopupObj("last");
        }

        if (empty(that.smsTemplateList)) {
            await this.getSmsTemplateList();
        }

        var templateid = ld("#"+popupobj.divid+" [name=smstemplatelist]").val();
        ld.each(that.smsTemplateList,function(tmpindex,tmpsmstemplateinfo){

            if (templateid == tmpsmstemplateinfo.templateid) {//当前所选的短信模板
                ld("#"+popupobj.divid+" [name=smstemplate_content]").text(tmpsmstemplateinfo.templatecontent);//填充短信内容

                var trhtml='';
                if (!empty(tmpsmstemplateinfo.templateparaminfo)) {
                    if (ld("#" + popupobj.divid + " #sms_reminds_content_table tr[name=variable_information]").length>0) {
                        ld("#" + popupobj.divid + " #sms_reminds_content_table tr[name=variable_information]").show();
                    }
                    if (ld("#" + popupobj.divid + " #sms_reminds_content_table tr[name=set_variable_information]").length>0) {
                        ld("#" + popupobj.divid + " #sms_reminds_content_table tr[name=set_variable_information]").show();
                    }

                    var templateparaminfo = JSON.parse(tmpsmstemplateinfo.templateparaminfo) || eval('('+tmpsmstemplateinfo.templateparaminfo+')');
                    ld.each(templateparaminfo,function(tmp_varname,tmp_vartips){
                        var tmp_crmsetvalue = '';
                        if (!empty(tmpsmstemplateconf) && typeof tmpsmstemplateconf[tmp_varname] != 'undefined') {//实际设置的crm变量得值
                            tmp_crmsetvalue = tmpsmstemplateconf[tmp_varname];
                        }

                        trhtml += '<tr>';
                        trhtml += '<td class="padT16">'+tmp_varname+'</td>';
                        trhtml += '<td class="padT16"> <input class="ld-input-inner gwidth90" type="text" name="'+tmp_varname+'" placeholder="'+tmp_vartips+'" value="'+tmp_crmsetvalue+'" /></td>';
                        trhtml += '</tr>';
                    })

                }else{
                    //BUG20241213-38 无变量模板隐藏”变量信息“行和”输入变量“行
                    if (ld("#" + popupobj.divid + " #sms_reminds_content_table tr[name=variable_information]").length>0) {
                        ld("#" + popupobj.divid + " #sms_reminds_content_table tr[name=variable_information]").hide();
                    }
                    if (ld("#" + popupobj.divid + " #sms_reminds_content_table tr[name=set_variable_information]").length>0) {
                        ld("#" + popupobj.divid + " #sms_reminds_content_table tr[name=set_variable_information]").hide();
                    }
                }
                ld("#" + popupobj.divid + " [name=smstemplateparam_table] tbody").html(trhtml);

                return false;//跳出循环
            }
        });
    }

    this.ShowMassSmsTemplateEvent = function (obj) {
        var popupobj = CrmPopup.getPopupObj("last");
        var templateid = ld(obj).val();

        if (parseInt(templateid)>0) {
            var surl = 'index.php?module=MassSMS&action=MassSMSAjax&file=SmsTemplate&ajax=true&operationtype=getmasssmsrelated&templateid='+templateid;
            ldAjax(surl,'',function (data){
                if(data.code == 1){
                    var templateparamconf_arr = data.result.templateparamconf_arr;
                    that.ShowSmsTemplateEvent(popupobj,templateparamconf_arr);//没有的也要切换

                }else{
                    return false;
                }
                DelProgressObjs();
            });
        }else{//切换到"未选择短信模板"的情况
            ld("#"+popupobj.divid+" [name=smstemplate_content]").text('');
            ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody").html("");

        }
    }

    /*this.moduleSel = function (obj) {
        var crmPopupobj=CrmPopup.getPopupObj("last");
        var tabid = obj.value;
        var urlstring = '&tabid='+tabid+'&printtabid='+tabid;
        ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField'+urlstring,{},function(data){
            ld("#"+crmPopupobj.divid+" #tabField").html(data.result.fieldsel);
            ld("#"+crmPopupobj.divid+" #selField").val('');
            ld("#"+crmPopupobj.divid+" textarea#templateTextArea").val("");
        });
    }*/

    //设置短信提醒内容相关
    this.CopySelField = function (obj) {
        var popupobj=CrmPopup.getPopupObj("last");
        var copycontent = trim(ld("#"+popupobj.divid+" #selField").val());

        if(empty(copycontent))
        {
            //请选择字段！
            MessagePopup.TipZero_warning(arrJsPopLabel['PLEASESELECTFIELD']);
            return false;
        }

        // 创建input标签，将复制内容暂存为value值
        var copy_content = document.createElement("input");
        copy_content.setAttribute("value", copycontent);
        // 将input添加到body
        document.body.appendChild(copy_content);
        // 选中input的文本内容
        copy_content.select();
        // 执行复制
        document.execCommand("copy");
        // 删除input标签
        document.body.removeChild(copy_content);

        MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYCOPIED'])
    };

}
SmsContentSetting.curobj = '';
SmsContentSetting.getInstance=function(){
    if(!empty(SmsContentSetting.curobj)){
    }else{
        SmsContentSetting.curobj=new SmsContentSetting();
    }
    return SmsContentSetting.curobj;
}

//中英文翻译替换变量{Var} 参考POPUPPRODUCTTOTALTIP
//array 替换内容 按顺序对应
function getVarJsPop(labelbol,array) {
    var jspopinfo = arrJsPopLabel[labelbol];
    ld.each(array, function (index, value) {
        jspopinfo = jspopinfo.replace('{Var}', value);
    })
    return jspopinfo;
}

/** 对象解析为 Url 参数 */
function getUrlParamsByObj(parmaArr) {
    var params = '';
    ld.each(parmaArr,function (key,val) {
        params += '&'+key+'='+encodeURIComponent(val);
    });
    return params;
}

//输入SQL的多文本域 调用插件 BUG20241226-09 系统录入SQL的地方，能否不要去掉SQL中的缩进格式：现在是把缩进的格式全部去掉了，导致可读性变差
//入参  多文本域的id
//出参  实例化的编辑器对象
function AceInitSqlEditor(codeEditorId){
    //https://ace.c9.io/build/kitchen-sink.html  这是试用界面地址
    //include/js/ace-src-min/ace.js
    //获取控件   id ：codeEditor
    var editor = ace.edit(codeEditorId);
    //设置风格和语言（更多风格和语言，请到github上相应目录查看）
    var theme = "monokai";
    //theme = "terminal";
    //语言
    var language = "sql";
    editor.setTheme("ace/theme/" + theme);
    editor.session.setMode("ace/mode/" + language);
    //字体大小
    editor.setFontSize(15);
    //设置只读（true时只读，用于展示代码）
    editor.setReadOnly(false);
    //自动换行,设置为off关闭
    editor.setOption("wrap", "free");
    //启用提示菜单
    ace.require("ace/ext/language_tools");
    editor.setOptions({
        enableBasicAutocompletion: true,
        enableSnippets: true,
        enableLiveAutocompletion: true
    });
    return editor;
}