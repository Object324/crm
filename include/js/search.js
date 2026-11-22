/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
function searchshowhide(argg,argg2)
{
	var ele_x = document.getElementById(argg);
	var ele_y = document.getElementById(argg2);
	var x, y;
    if (ele_x != null) x = ele_x.style;
    if (ele_y != null) y = ele_y.style;
    if (x != null && x.display=="none" && (y == null || y.display=="none"))
    {
        x.display="block"
		/**
		 * @reason 0012307 点击【查找】按钮，展开查找窗口后，希望光标默认显示在“查找关键字”录入框中。
		 * @author Tujt 2014-11-07
		 */
		document.basicSearch.search_text.focus();
    }
    else {
	    if (y != null) y.display="none";
        if (x != null) x.display="none";
    }
}

function searchhide(argg,argg2)
{
	var ele_x = document.getElementById(argg);
	var ele_y = document.getElementById(argg2);
	var x, y;
    if (ele_x != null) x = ele_x.style;
    if (ele_y != null) y = ele_y.style;
	if (y != null) y.display="none";
    if (x != null) x.display="none";
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
function mergehide(argg)
{
    var x=document.getElementById(argg);
	if (x != null) x.style.display = "none";
}


//保存搜索历史
function save_search_history(surl,module){
    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=SearchHistory&mode=save';
    //zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
    if(module == 'Approve'){
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        if(prevpopupobj!=undefined&&prevpopupobj.type=='listpage'){
            url += '&searchmodule='+prevpopupobj.module;
        }
    }
    ldAjax(url,surl,function(data){
        DelProgressObjs();
    });
}
//读取搜索历史
function show_history(popupobj){
    if (popupobj.searchtype == 'advance'){
        var searchfrom=CrmPopup.getPopupObj('lastprev').type;
    }else {
        var searchfrom=popupobj.type;
    }
    var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=SearchHistory&mode='+popupobj.searchmode;
    url += '&searchtype='+popupobj.searchtype+'&divid='+popupobj.divid+'&searchfrom='+searchfrom;
    //zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
    if(popupobj.module == 'Approve'){
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        if(prevpopupobj!=undefined&&prevpopupobj.type=='listpage'){
            url += '&searchmodule='+prevpopupobj.module;
        }
    }
    //清除历史记录后设rows=0
    ldAjax(url,"",function(data){
        DelProgressObjs();
        if(data.code == 1){
            if(data.result.num_rows >0){
                ld('#'+popupobj.divid+' [name=SearchHistory]').html(data.result.content);
            }else{
                ld('#'+popupobj.divid+' [name=SearchHistory]').html(data.result.emptycontent);
            }
        }
    });
}
//选择历史带出搜索条件：基本查询内容少，采用直接赋值的方式，高级查询内容多且没有上限，所以每次从后台读取数据
function searchhistory_change(obj){
    var optionvalue = ld(obj).attr('optionvalue');
    var fldname = ld(obj).attr('fldname');
    var parentdivid = ld(obj).attr('divid');
    cmb_liclick(optionvalue,fldname,parentdivid);
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj.searchtype == 'BasicSearch'){
        //为基本查询框赋值
        var searchtext = ld(obj).attr('searchtext');
        //因为存在不同数据分类的下拉框value值不同的情况，所以这里根据columnname判断
        var optionvalue_arr = optionvalue.split(':');
        if(optionvalue_arr.length<=1){
            ld('#'+popupobj.divid+' select[name=search_field]').val(optionvalue);
        }else{
            var columnname = optionvalue_arr[2];
            var checkinfoobj = CrmPopup.findHtmlobj(popupobj.divid,'search_field');
            var optionsobjs = checkinfoobj.find("option");
            var tmp_optionvalue = "";
            ld.each(optionsobjs,function(){
                tmp_optionvalue = ld(this).val();
                if(tmp_optionvalue == optionvalue){
                    ld('#'+popupobj.divid+' select[name=search_field]').val(tmp_optionvalue);
                    return false;
                }else{
                    var tmp_optionvalue_arr = tmp_optionvalue.split(':');
                    if(optionvalue_arr.length<=1){
                        var tmp_columnname = tmp_optionvalue;
                    }else{
                        var tmp_columnname = tmp_optionvalue_arr[2];
                    }
                    if(tmp_columnname == columnname){
                        ld('#'+popupobj.divid+' select[name=search_field]').val(tmp_optionvalue);
                        return false;
                    }
                }
            });
        }
        ld('#'+popupobj.divid+' input[name=search_text]').val(searchtext);
    }else if(popupobj.searchtype == 'advance'){
        //为高级查询框赋值
        var searchid = ld(obj).attr('searchid');
        popupobj.searchmode = 'choosehistory';
        var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=SearchHistory&mode='+popupobj.searchmode;
        url += '&searchtype='+popupobj.searchtype+'&divid='+popupobj.divid+'&id='+searchid;
        //zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
        if(module == 'Approve'){
            var prevpopupobj = CrmPopup.getPopupObj('lastprev');
            if(prevpopupobj!=undefined&&prevpopupobj.type=='listpage'){
                url += '&searchmodule='+prevpopupobj.module;
            }
        }
        ldAjax(url,"",function(data){
            DelProgressObjs();
            if(data.code == 1){
                var criteria_groups = data.result.criteria_groups; //所有查询条件
                // showListAdvanceSearch(criteria_groups);
            }
        });
    }
}

function clearhistory(obj){
    var searchtype = ld(obj).attr('searchtype');
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.searchtype = searchtype;
    popupobj.searchmode = 'clearhistory';
    show_history(popupobj);//清除历史记录后，再访问一次数据库刷新
}

function search_chosen(event,fldname,parentdivid){
    var clearname = 'clear_'+fldname;
    CrmPopup.findHtmlobj(parentdivid,clearname).attr("class","");
    com_chosen(event,fldname,parentdivid);
}
//duan  20240801 BUG20240731-02 记录高级查询的Json内容，在切换页签的时候重新生成高级查询条件
function showListAdvanceSearch(criteria_groups) {
    var groupid; //查询组编号
    var groups_criteria; //查询组信息
    var group_columns; //组内查询字段信息
    var column_index; //每行的编号
    var column_criteria; //每行查询条件信息
    var columnvalue; //查询内容
    var fori = 0; //'且'、'或'条件编号
    var conditionColumnRowElement; //每行对象
    //清空原有条件
    ld('#dv_listhighersearch [name=conditionGroup]').remove();
    if(empty(criteria_groups) || criteria_groups.length == 0){
        return
    }

    //重置已有查询条件数量
    advft_column_index_count = -1;
    advft_group_index_count = 0;
    column_index_array = [];
    group_index_array = [];
    //遍历所有查询条件
    for(groupid in criteria_groups){
        groups_criteria = criteria_groups[groupid];
        group_columns = groups_criteria['columns'];
        addConditionGroup('adv_filter_div');//添加查询组
        for(column_index=0;column_index < group_columns.length;column_index++){ //这里直接用遍历会有问题(循环长度为2的数组，会出现第三个参数‘each’)
            column_criteria = group_columns[column_index];
            addConditionRow(groupid);//添加查询行
            conditionColumnRowElement = document.getElementById('fcol'+advft_column_index_count); //获取行对象
            conditionColumnRowElement.value = column_criteria['columnname']; //为查询字段赋值
            // wym 230516 为下拉框赋值
            var text = ld("#fcol" + advft_column_index_count +" option:selected").text();
            if(document.getElementById("cmb_span_optiontext_fcol"+advft_column_index_count)){
                document.getElementById("cmb_span_optiontext_fcol"+advft_column_index_count).value=text;
            }

            updatefOptions(conditionColumnRowElement, 'fop'+advft_column_index_count); //控制'且'、'或'条件显示
            document.getElementById('fop'+advft_column_index_count).value = column_criteria['search_comparator']; //查询类型(包含、不包含等)
            addRequiredElements(advft_column_index_count); //特殊查询类型控制，如日期等;
            //设置关键字
            columnvalue = column_criteria['value'];
            if(column_criteria['comparator'] == 'bw' && columnvalue != '') { //特殊类型：日期
                var values = columnvalue.split(",");
                document.getElementById('fval'+advft_column_index_count).value = values[0];
                if(values.length == 2 && document.getElementById('fval_ext'+advft_column_index_count))
                    document.getElementById('fval_ext'+advft_column_index_count).value = values[1];
            }else{
                //特殊翻译
                if(columnvalue =='Accepted')
                    document.getElementById('fval'+advft_column_index_count).value = alert_arr.Accepted;
                else if(columnvalue =='Rejected')
                    document.getElementById('fval'+advft_column_index_count).value = alert_arr.Rejected;
                else{
                    var values = columnvalue.split(",");
                    document.getElementById('fval'+advft_column_index_count).value = values[0];
                }
            }
        }
        //设置每行的'且'、'或'条件
        for(column_index=0;column_index < group_columns.length;column_index++){//直接用遍历会有问题
            column_criteria = group_columns[column_index];
            if(document.getElementById('fcon'+fori))
            {
                ld("[name=fcon"+fori).val(column_criteria['column_condition']);
            }
            fori += 1;
        }
    }
    //设置查询组之间的'且'、'或'条件
    for(groupid in criteria_groups){
        groups_criteria = criteria_groups[groupid];
        if(document.getElementById('gpcon'+groupid))
            document.getElementById('gpcon'+groupid).value = groups_criteria['condition'];
    }
}
function showListAdvanceSearchJson(criteria_groups_json) {
    var criteria_groups = JSON.parse(criteria_groups_json);
    showListAdvanceSearch(criteria_groups)
}
