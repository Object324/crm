function checkfrom()
{
    var viewrangeone_year= document.getElementById('viewrangeone_year').value;
    var viewrangeone_month= document.getElementById('viewrangeone_month').value;
    var viewrangetwo_year= document.getElementById('viewrangetwo_year').value;
    var viewrangetwo_month= document.getElementById('viewrangetwo_month').value;
    if(eval(viewrangeone_year) == eval(viewrangetwo_year))
    {
        if(eval(viewrangeone_month) > eval(viewrangetwo_month))
        {
            alert(arrJsPopLabel['TOBESURESTRARTNEQEND']);
            return false;
        }
    }
    else
    {
        if(viewrangeone_year > viewrangetwo_year)
        {
            alert(arrJsPopLabel['THESTARTTIME']);
            return false;
        }
    }
}

/**
 *点击完成后打开新页面
 */
function openUserCompleteUrl(jqueryobj){
    let record_str = jqueryobj.attr('record_str'),
        search_date_value = jqueryobj.attr('search_date_value'),
        targetid=jqueryobj.attr('targetid'),
        ajaxurl='index.php?module=SalesGoal&action=SalesGoalAjax&file=setModuleSearchNew',
        openurl='index.php?pageto_action=index&pageto_module=',
        modules=''
    ;
    //zkt 20220424 【ID1002776】【销售目标的超链接只跳转到销售合同模块】
    var modulearr = modules.split(',');
    var module = '';
    var urlarr = [];
    var urllength = 0;
    ld.ajax({
        url:ajaxurl+"&targetid="+targetid+"&record_str="+record_str+"&search_date_value="+search_date_value,
        type:"POST",
        data:'',
        dataType:'json',
        async:false,
        timeout: 50000,
        success:function(data)
        {
            if(data.code == 1)
            {
                var module_arr = data.result.modulearr;
                var addurl=encodeURIComponent("&query_session=1");
                if(module_arr.length >0){
                    for(var i=0;i<module_arr.length;i++){
                        url = openurl+module_arr[i]+'&page_addurl='+addurl;
                        urlarr.push(url);
                    }
                }else{
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.result.remindstr);
                }
            }

        }
    });
    //zkt 20220429 防止弹窗被拦截导致点击同一链接弹出不同窗口
    if(urlarr.length>0)
    {
        for(var i=0;i<urlarr.length;i++)
        {
            if(urlarr[i]!=''){
                window.open(urlarr[i]);
            }
            
        }
    }

}

function SalesGoalTabClick(tabindex){
    var file ='';
    switch(tabindex){
        case 0:
            file ='ListView_tree_new';
            break;
        case 1:
            file ='ListViewNew';
            break;
        case 2:
            file ='ListView_edit_new';
            break;
        case 3:
            file ='ListView_chart_new';
            break;
        default:
            break;
    }
    var surl = "index.php?module=SalesGoal&file="+file+"&action=SalesGoalAjax";
    ldAjaxHtml(surl,'',function (data){
        DelProgressObjs();
        ChangeWebUrl("index.php?pageto_module=SalesGoal&pageto_action="+file);
        listcontentobj.html(data);
    })
}
//销售指标编辑弹出层
function SalesGoalEditPopup(targetid){
    ld('#TargetList').hide();
    getJsScript('include/js/modules/SalesGoal/cls_salesgoal_operation.js',function (){
        var salesgoal_operationobj = cls_salesgoal_operation.getInstance();
        salesgoal_operationobj.ShowEditView(targetid);
    })
}
//下拉框显示隐藏
function TargetListShow(){
    var labelobj = ld('#TargetListlabel');
    var allowtrigger = labelobj.attr('allowtrigger');
    var picklistobj = ld('#TargetList');
    var jspicklistobj = ld('#TargetList').get(0);
    //绑定鼠标移入移出事件
    ld("#TargetListContent").unbind('mouseover').bind('mouseover',function (){
        ld('#TargetList').attr('allowtrigger','no');
    })
    ld("#TargetListContent").unbind('mouseout').bind('mouseout',function (){
        ld('#TargetList').attr('allowtrigger','yes');
    })
    //绑定失焦事件
    picklistobj.unbind('blur').bind('blur',function (){
        if(ld(this).attr('allowtrigger') == 'yes'){
            ld(this).hide();
        }
    })
    if(jspicklistobj.style.display == 'none'){
        //展示
        labelobj.attr('allowtrigger','no');
        picklistobj.show();
        picklistobj.focus();
    }else {
        picklistobj.hide();
    }
}
//显示销售指标列表
function SalesGoalList(){
    ld('#TargetList').hide();

    var surl = "index.php?module=SalesGoal&file=SalesGoalAble&action=SalesGoalAjax&mode=list";
    var width = parseInt(CrmPopup.getClientWidth()* 0.8);
    var popupobj=CrmPopup.load("","","",width,'SalesGoal',"","","","");

    ldAjax(surl,'',function(data){
        if(data.code == 1){
            var result = data.result;
            //重写原关闭弹出层方法,增加刷新页面代码
            popupobj.SalesGoalCancelEvent = popupobj.CancelEvent;
            popupobj.CancelEvent = function (){
                this.SalesGoalCancelEvent();
                SalesGoalRefreshPicklist();
            }

            popupobj.setParams(result.title, popupobj.CancelEvent, "", width,'SalesGoal', "", result.oktext, "", "");
            CrmPopup.setPopupobjHtmlContent_scroll(popupobj,result.content);
            popupobj.pagetype = 'SalesGoalList';
            getJsScript('include/js/modules/SalesGoal/cls_salesgoal_operation.js',function (){
                cls_salesgoal_operation.ResetRowEvent();
                cls_salesgoal_operation.setTableSort();
            })
            tooltip('.tip-items-list', {transition: true, time: 200});

        }else if(data.code == -1){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg);
        }
    })
}
//销售指标下拉框选择事件
function ChangeSalesGoalFun(obj){
    ld('#TargetList').hide();
    var chooseobj = ld("#ChooseSalesGoal");
    var targetid = ld(obj).attr('targetid');
    var displayinactiv = ld(obj).attr('displayinactiv');
    var targetname = ld(obj).attr('targetname');
    var targetlabel = ld(obj).html();
    chooseobj.attr('targetid',targetid);
    chooseobj.attr('targetname',targetname);
	//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
    chooseobj.attr('displayinactiv',displayinactiv);
    chooseobj.html(targetlabel);
    SalesGoalListClickSearch();
}

//销售目标查找事件
function SalesGoalListClickSearch(){
    isedit='no';
    var tableindex=ld(".ld-ui-tabs-active").attr('tabindex');
    var searchscope=ld("#SmOwnerSearchScope").val();
    var viewrangeone_year=ld("#viewrangeone_year").val();
    var viewrangeone_month=ld("#viewrangeone_month").val();
    var viewrangetwo_year=ld("#viewrangetwo_year").val();
    var viewrangetwo_month=ld("#viewrangetwo_month").val();
    var targetname = ld("#ChooseSalesGoal").attr('targetname')
    var targetid = ld("#ChooseSalesGoal").attr('targetid');
    var module_look = targetname;
    var actionname = ld('#actionname').val();
    var tmps={"SmOwnerSearchScope":searchscope,'viewrangeone_year':viewrangeone_year
        ,'viewrangeone_month':viewrangeone_month,'viewrangetwo_year':viewrangetwo_year
        ,'viewrangetwo_month':viewrangetwo_month,'module_look':module_look,'targetid':targetid,'targetname':targetname};
    var url="index.php?module=SalesGoal&file="+actionname+"&action=SalesGoalAjax&ajax=yes";

    if(searchscope=='smowner_search_senior'){
        if(global_var.salesgoal !== undefined && global_var.salesgoal[tableindex] != undefined){
            tmps.senioruserid = global_var.salesgoal[tableindex];
        }else{
            tmps.senioruserid = ld('#scope_senioruserids').val();
        }

    }

    ldAjax(url,tmps,function(data){
        //chj 2021/5/20 46003: （61mis.com/kfbcrm）工具-销售目标-目标设置，编辑目标时，切换销售指标，点击查询；“保存目标”按钮自动没有变为“编辑目标”
        if(ld("#editsalesgoal").length>0)
            ld("#editsalesgoal").val(editgoallabel);
        ld("#salesgoalajax").html(data.result.content);
        if(data.result.modulename == 'Users'){
            ld("#UserSmOwnerSearchScope").show();
        }else{
            ld("#UserSmOwnerSearchScope").hide();
        }
        ld("#CancelEdit").hide();
        tooltip('.tip-items-goal', {transition: true, time: 200});
        if(actionname == 'ListView_tree_new'){
            var a = ld(' #resize_content_table_divid').outerHeight(true);//头部高度
            var height = a-105;
            if(height <400) height = 400;
            ld('#container_treediagram').css('height',height);
            ld('#container_treediagram').show();
            ld('#container_treediagram').css('opacity',1);
            ld('#container_treediagram').css('transition-duration','0.8s');
            setTimeout(function(){
                ld('#salesgoaltips2').show();
            },800);
        }
        //edit: xll 2024/02/02 BUG20240201-40 目标管理-“完成情况统计图”页签，点击切换指标名称，统计图显示空白
        else if(actionname === 'ListView_chart_new'){
            newHighChart('container_salesGoalChart',highChartValue)
        }

        DelProgressObjs();
    })
}
//销售目标编辑
function SalesGoalEditForm(){
    var tableindex=ld(".ld-ui-tabs-active").attr('tabindex');

    var searchscope=document.getElementById('SmOwnerSearchScope').options[document.getElementById('SmOwnerSearchScope').selectedIndex].value;
    var targetname = ld("#ChooseSalesGoal").attr('targetname')
    var targetid = ld("#ChooseSalesGoal").attr('targetid');
    var module_look = targetname;

    var addurl = "&query=true&SearchScope="+searchscope+"&module_look="+module_look;
    addurl+="&viewrangeone_year="+ld("#viewrangeone_year").val()+"&viewrangeone_month="+ld("#viewrangeone_month").val();
    addurl+="&viewrangetwo_year="+ld("#viewrangetwo_year").val()+"&viewrangetwo_month="+ld("#viewrangetwo_month").val();
    var url="index.php?pageto_module=SalesGoal&pageto_action=ListView_edit_new&page_addurl="+encodeURIComponent(addurl);
    var tmps={"SmOwnerSearchScope":searchscope,'viewrangeone_year':+ld("#viewrangeone_year").val()
        ,'viewrangeone_month':ld("#viewrangeone_month").val(),'viewrangetwo_year':ld("#viewrangetwo_year").val()
        ,'viewrangetwo_month':ld("#viewrangetwo_month").val(),'module_look':module_look,'targetid':targetid,'targetname':targetname};

    if(searchscope=='smowner_search_senior'){
        if(global_var.salesgoal !== undefined && global_var.salesgoal[tableindex] != undefined){
            tmps.senioruserid = global_var.salesgoal[tableindex];
        }else{
            tmps.senioruserid = ld('#scope_senioruserids').val();
        }
    }
    var stringurl="";
    if(isedit=='no')
    {
        ld("#editsalesgoal").val(savegoallabel);
        ldAjax("index.php?module=SalesGoal&file=ListView_edit_new&action=SalesGoalAjax&query=yes",tmps,function(data){
            ld("#PrompLeftCenter").html(data.result.content);
            ld("#CancelEdit").show();
            SalesGoalSetEvent();
            DelProgressObjs();

        })
        isedit='yes';
    }
    else{
        //'RecordTarget','GroupSum','GroupTarget','RecordTargetSum','GroupTargetSum'
        stringurl="&alluserid="+document.getElementById('alluserid').value;
        stringurl+="&allmonth="+document.getElementById('allmonth').value;
        stringurl+="&modulename="+ld("#modulename").val();
        stringurl+="&record_str="+ld("#record_str").val();
        stringurl+="&groupid_str="+ld("#groupid_str").val();
        var wrong_cnt = 0;
        var tmp_value = 0;
        var tmpname = '';


        ld.each(ld("#PrompLeftCenter [tag=RecordTarget]"),function(){
            tmpname=ld(this).attr("name");
            tmp_value =ld(this).val();
            if(isNaN(tmp_value)){
                wrong_cnt ++;
            }
            tmps[tmpname]=tmp_value
        })
        ld.each(ld("#PrompLeftCenter [tag=GroupTarget]"),function(){
            tmpname=ld(this).attr("name");
            tmpname+='_group';
            tmp_value =ld(this).val();
            if(isNaN(tmp_value)){
                wrong_cnt ++;
            }
            tmps[tmpname]=tmp_value;
        })

        if(wrong_cnt > 0){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['ENTERCORRECTNUMBER']);
            return false;
        }

        ldAjax("index.php?module=SalesGoal&file=SaveNew&action=SalesGoalAjax&query=yes"+stringurl,tmps,function(data){
            ld("#PrompLeftCenter").html(data.result.content);
            ld("#editsalesgoal").val(editgoallabel);
            ld("#CancelEdit").hide();
            isedit='no';
            DelProgressObjs();
        })
    }
}

//设置销售目标编辑界面变化事件
function SalesGoalSetEvent(){
    //对象、部门目标变化事件
    ld("#PrompLeftCenter [tag=RecordTarget],[tag=GroupTarget]")
        .on('focus',function (){
            var cur_value = ld(this).val();
            ld(this).css('border','1px solid #dbdbdb');
            ld(this).css('text-align','left');
            ld(this).val('');
            ld(this).val(cur_value);
        })
        .on('blur',function (){
            ld(this).css('border','none');
            ld(this).css('text-align','right');
        })  ;
    //合计选项不允许编辑
    ld("#PrompLeftCenter [tag=GroupSum]").attr('disabled','yes');
    ld("#PrompLeftCenter [tag=RecordTargetSum]").attr('disabled','yes');
    ld("#PrompLeftCenter [tag=GroupTargetSum]").attr('disabled','yes');
    //绑定数字变化事件
    ld("#PrompLeftCenter [tag=RecordTarget],[tag=GroupTarget],[tag=GroupSum],[tag=RecordTargetSum],[tag=GroupTargetSum]")
        .on('change',function (){
            TargetValueChange(this);
        });
}
//目标设定值变化事件
function TargetValueChange(obj){
    var tag = ld(obj).attr('tag');
    var record = ld(obj).attr('record');
    var groupid = ld(obj).attr('groupid');
    var month = ld(obj).attr('month');
    var tmp_value =ld(obj).val();
    var updateall = ld(obj).attr('updateall');
    //检查输入的数字是否正确
    if(tag == 'RecordTarget' || tag == 'GroupTarget' ){
        if((empty(tmp_value))){
            tmp_value = 0;
            ld(obj).val(0);
        }
        if(isNaN(tmp_value)){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['ENTERCORRECTNUMBER']);
            ld(obj).addClass('border_red1');
            return false;
        }else{
            ld(obj).removeClass('border_red1');
        }
    }
    var tmp_sum = 0;
    var decimal = ld('#decimal').val();
    if(tag == 'RecordTarget' && groupid>0){
        //同一个用户的目标同步变化
        if(updateall != 'no'){
            ld("#PrompLeftCenter input[tag="+tag+"][record="+record+"][month="+month+"]").val(tmp_value);
            ld("#PrompLeftCenter input[tag="+tag+"][record="+record+"][month="+month+"]").attr('updateall','no');
            ld("#PrompLeftCenter input[tag="+tag+"][record="+record+"][month="+month+"]").change();
            ld("#PrompLeftCenter input[tag="+tag+"][record="+record+"][month="+month+"]").attr('updateall','yes');
        }
        var valueobjs =  ld("#PrompLeftCenter input[tag="+tag+"][record="+record+"][groupid="+groupid+"]");
    }else{
        var valueobjs =  ld("#PrompLeftCenter input[tag="+tag+"][record="+record+"]");
    }
    //计算每一行的合计
    ld.each(valueobjs,function (){
        tmp_value = ld(this).val();
        if(empty(tmp_value) || isNaN(tmp_value)) tmp_value = 0;
        tmp_sum += parseFloat(tmp_value);
    })
    if(decimal >0){
        tmp_sum =  tmp_sum.toFixed(decimal);
    }
    ld("#PrompLeftCenter #TargetValueSum[tag="+tag+"Row][record="+record+"]").html(tmp_sum);
    //所有的tag名称:'RecordTarget','GroupSum','GroupTarget','RecordTargetSum','GroupTargetSum'
    if(tag == 'RecordTarget'){

        //计算部门小计
        var GroupSumobj = ld("#PrompLeftCenter input[tag=GroupSum][groupid="+groupid+"][month="+month+"]");
        if(GroupSumobj.length >0){
            valueobjs = ld("#PrompLeftCenter input[tag="+tag+"][groupid="+groupid+"][month="+month+"]");
            tmp_sum = 0;
            ld.each(valueobjs,function (){
                tmp_value = ld(this).val();
                if(empty(tmp_value) || isNaN(tmp_value)) tmp_value = 0;
                tmp_sum += parseFloat(tmp_value);
            })
            if(decimal >0){
                tmp_sum =  tmp_sum.toFixed(decimal);
            }
            GroupSumobj.val(tmp_sum);
            GroupSumobj.trigger('change');
        }
        //计算所有成员合计
        var RecordSumobj = ld("#PrompLeftCenter input[tag=RecordTargetSum][month="+month+"]");
        if(RecordSumobj.length >0){
            valueobjs = ld("#PrompLeftCenter input[tag="+tag+"][month="+month+"]");
            tmp_sum = 0;
            var used_record_arr = [];
            ld.each(valueobjs,function (){
                var tmp_record = ld(this).attr('record');
                if(used_record_arr.includes(tmp_record)){
                    return true;
                }else{
                    used_record_arr.push(tmp_record);
                }
                tmp_value = ld(this).val();
                if(empty(tmp_value) || isNaN(tmp_value)) tmp_value = 0;
                tmp_sum += parseFloat(tmp_value);
            })
            if(decimal >0){
                tmp_sum =  tmp_sum.toFixed(decimal);
            }
            RecordSumobj.val(tmp_sum);
            RecordSumobj.trigger('change');
        }
    }else if(tag == 'GroupTarget'){
        //计算所有部门合计
        var GroupTargetSumobj = ld("#PrompLeftCenter input[tag=GroupTargetSum][month="+month+"]");
        if(GroupTargetSumobj.length >0){
            valueobjs = ld("#PrompLeftCenter input[tag="+tag+"][month="+month+"]");
            tmp_sum = 0;
            var used_record_arr = [];
            ld.each(valueobjs,function (){
                var tmp_record = ld(this).attr('record');
                if(used_record_arr.includes(tmp_record)){
                    return true;
                }else{
                    used_record_arr.push(tmp_record);
                }
                tmp_value = ld(this).val();
                if(empty(tmp_value) || isNaN(tmp_value)) tmp_value = 0;
                tmp_sum += parseFloat(tmp_value);
            })
            if(decimal >0){
                tmp_sum =  tmp_sum.toFixed(decimal);
            }
            GroupTargetSumobj.val(tmp_sum);
            GroupTargetSumobj.trigger('change');
        }
    }
}

//列表选中变色
function SalesGoallistOnMouseOver(sel_id){
    var rows = "row_"+sel_id;
    if(document.getElementById(sel_id)!=undefined){
        if(document.getElementById(sel_id).checked){
            ld("#"+rows).removeClass("lvtColDataHover") ;
            ld("#"+rows).addClass("lvtColDataSelected") ;
        }else{
            ld("#"+rows).removeClass("lvtColDataSelected") ;
            ld("#"+rows).addClass("lvtColDataHover") ;

        }
    }
    else{
        ld("#"+rows).removeClass("lvtColDataSelected") ;
        ld("#"+rows).addClass("lvtColDataHover") ;
    }
}

function SalesGoallistOnMouseOut(sel_id,type){
    var rows = "row_"+sel_id;
    ld("#"+rows).removeClass("lvtColDataSelected");
    ld("#"+rows).removeClass("lvtColDataHover") ;
    if(document.getElementById(sel_id)!=undefined){
        if(document.getElementById(sel_id).checked){
            ld("#"+rows).addClass("lvtColDataSelected");
            //document.getElementById(rows).className = "lvtColDataSelected";
        }else{
            ld("#"+rows).removeClass("lvtColDataSelected");
            if(type == 'On'){
                ld("#"+rows).addClass("lvtColDataBj");
            }else{
                ld("#"+rows).addClass("lvtColData");

            }
        }

    }
    else{
        if(type == 'On'){
            ld("#"+rows).addClass("lvtColDataBj");
        }else{
            ld("#"+rows).addClass("lvtColData");
        }
    }
}
//刷新销售指标下拉框
function SalesGoalRefreshPicklist(){
    //edit: xll 2023/08/15 XUQIU1001400 近六个月目标完成情况及目标完成率仪表盘打开目标管理弹窗,关闭刷新需要重写
    var module = getUrlParam("pageto_module");
    if(module == 'SalesGoal'){
        var targetid = ld("#ChooseSalesGoal").attr('targetid');
        ldAjax("index.php?module=SalesGoal&file=SalesGoalAble&action=SalesGoalAjax&mode=refreshpicklist&targetid="+targetid,"",function(data){
            ld('#TargetListContent').html(data.result.content);
            DelProgressObjs();
        });
    } else {
        //edit:xll 2023/09/02 BUG0071957 单独刷新组件：“最近六个月目标完成情况”和“目标完成率仪表盘”组件中，目标管理的保存，刷新的是整个界面（包括菜单栏）
        var stuff_arr = {
            '40': {
                stuffid:'40',
                stufflisttype : 'defaultstuff',
                stufftype : 'chart',
            },
            '101':{
                stuffid:'101',
                stufflisttype : 'defaultstuff',
                stufftype : 'chart',
            },
        };
        ld.each(stuff_arr,function (stuffid,stuffinfo){
            if(ld(' #stuff_'+stuffid+' #sales_target_tab').length > 0)
                newChart_class.refresh_stuff(stuffid,stuffinfo);
        });
    }
}







 