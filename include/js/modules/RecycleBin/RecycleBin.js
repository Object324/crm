/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
function callRBSearch(searchtype)
{
	for(i=1;i<=26;i++)
    {
		var data_td_id = 'alpha_'+ eval(i);
        getObj(data_td_id).className = 'searchAlph';
    }
    gPopupAlphaSearchUrl = '';
	search_fld_val= $('bas_searchfield').options[$('bas_searchfield').selectedIndex].value;
	search_txt_val=document.basicSearch.search_text.value;
	var urlstring = '';
	if(searchtype == 'Basic')
	{
		urlstring = 'search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val+'&';
	}
	var selectedmodule = $('select_module').options[$('select_module').selectedIndex].value 
	urlstring += 'selected_module='+selectedmodule;
	ldAjaxHtml('index.php?',urlstring +'&query=true&module=RecycleBin&action=RecycleBinAjax&file=index&ajax=true&mode=ajax',function(ajaxhtml) {
		DelProgressObjs();
		$("modules_datas").innerHTML=ajaxhtml;
		$("search_ajax").innerHTML = '';

	});

}
function changeModule(pickmodule)
{
	ld('#rptContentLoading').show();
	var module=pickmodule.options[pickmodule.options.selectedIndex].value;
	ldAjaxHtmlNoProgress('index.php?','action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=ListView&selected_module='+module,function(ajaxhtml)
	{
		ld('#rptContentLoading').hide();
		//	$("modules_datas").innerHTML=response.responseText;
		ld("#modules_datas").html(ajaxhtml);
		// $("searchAcc").innerHTML = $("search_ajax").innerHTML;
		// $("search_ajax").innerHTML = '';
		// ljj 20240129 BUG20240129-68 kfbcrm -回收站-基本查找搜索框内的提示信息与选择字段不符（切换模块后显示错误）
		changeBasicFieldplaceholder(ld('#bas_searchfield'));
	});
}
// ljj 20240129 BUG20240129-68 kfbcrm -回收站-基本查找搜索框内的提示信息与选择字段不符（切换模块后显示错误）
//原方法listviewBasicSearch.tpl：替换回收站搜索框提示信息
function changeBasicFieldplaceholder(obj){
	var selected_field_label = ld(obj).find('option:selected').text();
	var placehoder_text = arrJsPopLabel['SEARCHCAPITAL']+selected_field_label;
	ld('#ListViewBtnAndSeach [name=search_text]').attr('placeholder',placehoder_text);
}
/*
*新增操作by andy ,
*回收站增加删除按钮
*20140103 
*reason:6517;刘总建议：因为回收站序时簿界面无法单独删除一条或者2条数据，建议把清空回收站按钮功能更改为删除按钮功能
*/
function Rassdelete(){
    var excludedRecords = document.getElementById('excludedRecords').value;
	var select_options  =  document.getElementById('allselectedboxes').value;
	var searchurl = document.getElementById('search_url').value;
	var numOfRows = document.getElementById('numOfRows').value;
	var idstring = "";
	if(select_options=='all'){
		idstring = select_options;
		var skiprecords = excludedRecords.split(";");
		var count = skiprecords.length;
		if(count > 1){
			count = numOfRows - count + 1;
		}
		else{
			count = numOfRows;
		}
	} else {
		var x = select_options.split(";");
        //alert(x)
		var count=x.length
		if (count > 1)
		{
			document.getElementById('idlist').value=select_options;
			idstring = select_options;
		} else{
			var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		count = count-1;
	}
    //删除
    var selectmodule = $('select_module').value;
	var selectmoduletranslated =  $('selected_module_translated').value; 
	var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
	if(count > getMaxMassOperationLimit())
	{
		//var confirm_str = arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'];
		confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
	}

	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		//zkt 20231012 XUQIU1001341 SQL注入
		ldAjaxHtml('index.php?','action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Rassdelete&idlist='+idstring+'&selectmodule='+selectmodule+'&excludedRecords='+excludedRecords,function(response) {
			DelProgressObjs();
			if(empty(response)) return false;
			var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
			var divobj = createElementDivs('RecycleBin_del');
			var submitlog = '<div style="background-color: #fff;max-height: 400px;overflow-y: auto;">';
			submitlog += restobj.log.value;//批量提交失败日志
			submitlog += '</div>';
			ld(divobj).find('div.E_pop_tit .E_ptita').html(restobj.title.value);
			ld('#RecycleBin_delcontent').html(submitlog);
			fnvshobj('', 'RecycleBin_del');
			//ld('#RecycleBin_del .E_pbtn .E_pbtncancel').css('display','none');
			ld('#RecycleBin_del .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
				fninvshnew('RecycleBin_del');puyoungJS_DialogBox.unblock();
				var select_module = document.getElementById('select_module');
				changeModule(select_module);
				//window.location='index.php?module=RecycleBin&action=index&selected_module='+selectmodule;
			});
			return false;
		});
	})
}



function massRestore()
{
	var excludedRecords = document.getElementById('excludedRecords').value;
	var select_options  =  document.getElementById('allselectedboxes').value;
	var searchurl = document.getElementById('search_url').value;
	var numOfRows = document.getElementById('numOfRows').value;
	var idstring = "";
    //0047804 edit:duan reason:单据还原之后，选择框中的内容没有清除，导致上一次还原的单据也显示了
    document.getElementById('allselectedboxes').value="";
    
	if(select_options=='all'){
		idstring = select_options;
		var skiprecords = excludedRecords.split(";");
		var count = skiprecords.length;
		if(count > 1){
			count = numOfRows - count + 1;
		}
		else{
			count = numOfRows;
		}
	} else {
		var x = select_options.split(";");
		var count=x.length
		if (count > 1)
		{
			document.getElementById('idlist').value=select_options;
			idstring = select_options;
		} else{
			var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		count = count-1;
	}
	if(count > getMaxMassOperationLimit())
	{
		//var confirm_str = arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'];
		var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
		if(confirm(confirm_str)) var confirm_status = true;
		else return false;
	}
	else confirm_status = true;

	guanbi=function(){
		var crmPopupobj=CrmPopup.getPopupObj('last');
		crmPopupobj.CancelEvent();
		puyoungJS_DialogBox.unblock();
		getListViewEntries_js('RecycleBin','&selected_module='+selectmodule);//刷新页面
	}

	if(confirm_status){
		var selectmodule = $('select_module').value;
		var selectmoduletranslated =  $('selected_module_translated').value;

		// alert('action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Restoration&idlist='+idstring+'&selectmodule='+selectmodule+'&excludedRecords='+excludedRecords);

		/*if(confirm(arrJsPopLabel['SUREWANTRESTORESELECTEDCONTENT']))
		{*/
		//zkt 20231012 XUQIU1001341 SQL注入
		// wjw20240123 回收站还原弹窗改为可拖动
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px","selectmodule","",'none',"","");
		crmPopupobj.prevshow();
		ldAjaxHtml('index.php?','action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Restoration&idlist='+idstring+'&selectmodule='+selectmodule+'&excludedRecords='+excludedRecords,function(response) {
			DelProgressObjs();
			if(empty(response)) return false;
			var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
			crmPopupobj.setParams(restobj.title.value,guanbi,"","LdPopWidth720px",module,"",restobj.download.value,"","");
			// console.log(restobj)
			crmPopupobj.quickcreatehtml=restobj.log.value;
			crmPopupobj.show(restobj.log.value);
			crmPopupobj.center();
			return false;
		});
		/*}*/
	}
}
function restore(entityid,select_module)
{
    /**
     * bug:0022812: 回收站：选择模块供应商，还原单据后，点击单据操作列后的【还原】按钮，单据没有还原成功
     * Liver 2016/06/01  增加 var select_module = document.getElementById('select_module').value; 
     */      
    var select_module = document.getElementById('select_module').value; 
    var confirm_str = arrJsPopLabel['SUREWANTRESTORESELECTEDCONTENT'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		//zkt 20231012 XUQIU1001341 SQL注入
		ldAjaxHtml('index.php?','action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Restoration&idlist='+entityid+'&selectmodule='+select_module,function(response) {
			DelProgressObjs();
			if(empty(response)) return false;
			var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
			createElementDiv('RecycleBin_hy');//创建DIV
			ld('#RecycleBin_hytitlename').html(restobj.title.value);
			sethtml(document.getElementById('RecycleBin_hycontent'),restobj.log.value);
			ld('#RecycleBin_hy .E_pbtn .E_pbtncancel').css('display','none');
			ld('#RecycleBin_hy .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
				fninvshnew('RecycleBin_hy');puyoungJS_DialogBox.unblock();
				Recyle_getListViewEntries_js('RecycleBin','');
				//window.location='index.php?module=RecycleBin&action=index&parenttab=Tools&selected_module='+select_module;
			});
			return false;
		});
    });
}

function Recyle_getListViewEntries_js(module,url)
{
	var all_selected = $('allselectedboxes').value;
	var excludedRecords = $('excludedRecords').value;

	//$("status").show();
	ld('#rptContentLoading').show();
	var selected_module = $("select_module").value;
	var urlstring = "&selected_module=" + selected_module;
	//  Ticket 6330 
	if($('search_url').value!='')
		urlstring = $('search_url').value+"&selected_module="+selected_module;

	//ls 20230403 BUG0063854 “回收站”，输入关键字进行搜索，点击下一页，数据变成全部数据 (点击下一页条件丢失)
	var search_field= ld('#basicSearchNewDiv').find('[name=search_field]').val();
	var search_text= ld('#basicSearchNewDiv').find('[name=search_text]').val();
	if(ld.trim(search_text)!='')
	{
		search_text= encodeURIComponent(search_text);
		urlstring+="&searchtype=BasicSearch&search_field="+search_field+"&search_text="+search_text+"&query=true&SearchScope=SmOwner_Search_All";
	}
	ldAjaxHtmlNoProgress('index.php?',"module=RecycleBin&action=RecycleBinAjax&file=ListView&mode=ajax&ajax=true"+url+urlstring+"&allselobjs="+all_selected+"&excludedRecords="+excludedRecords,function(ajaxhtml) {
		//$("status").hide();
		ld('#rptContentLoading').hide();
		if($("modules_datas")) {
			ld("#modules_datas").html(ajaxhtml);
		}
		if(all_selected == 'all'){
			if(ld('#linkForSelectAll').length > 0){
				$('linkForSelectAll').show();
			}

			$('selectAllRec').style.display='none';
			$('deSelectAllRec').style.display='inline';
			var exculdedArray=excludedRecords.split(';');
			var obj = document.getElementsByName('selected_id');
			if (obj) {
				var viewForSelectLink = showSelectAllLink(obj,exculdedArray);
				$('selectCurrentPageRec').checked = viewForSelectLink;
				$('allselectedboxes').value='all';
				$('excludedRecords').value = $('excludedRecords').value+excludedRecords;
			}
		}else{
			if(ld('#linkForSelectAll').length > 0){
				$('linkForSelectAll').hide();
			}
			update_selected_checkbox();
		}
	});
}

function alphabetic(module,url,dataid)
{
        for(i=1;i<=26;i++)
        {
                var data_td_id = 'alpha_'+ eval(i);
                getObj(data_td_id).className = 'searchAlph';

        }
	var selectedmodule = $('select_module').options[$('select_module').selectedIndex].value 
	url += '&selected_module='+selectedmodule;
	getObj(dataid).className = 'searchAlphselected';
	ldAjaxHtml('index.php',"module="+module+"&action="+module+"Ajax&file=index&mode=ajax&ajax=true&"+url,function(ajaxhtml){
		DelProgressObjs();
		$("modules_datas").innerHTML=ajaxhtml;
		$("search_ajax").innerHTML = '';
	})
}

function callEmptyRecyclebin(obj) {
	//document.getElementById('rb_empty_conf_id').style.display = 'block';
    fnvshobj(obj, 'rb_empty_conf_id'); 
}

function emptyRecyclebin(id) {
	if($(id)) $(id).hide();
	puyoungJS_DialogBox.progress();
	var pickmodule = $('select_module');
	var module=pickmodule.options[pickmodule.options.selectedIndex].value;
	ldAjaxHtml('index.php?',"module=RecycleBin&action=RecycleBinAjax&file=EmptyRecyclebin&mode=ajax&ajax=true&selected_module="+module,function(ajaxhtml) {
		DelProgressObjs();
		$("modules_datas").innerHTML= ajaxhtml;
		$("searchAcc").innerHTML = $("search_ajax").innerHTML;
		$("search_ajax").innerHTML = '';
		puyoungJS_DialogBox.hideprogress();
		fninvsh('rb_empty_conf_id');
	});
}
/*
*edit:diony
*time:2014-08-07
*reason:列表选中变色
*/
function listOnMouseOver(sel_id)
{
    var rows = "row_"+sel_id;
    if(document.getElementById(sel_id).checked)
    {
        document.getElementById(rows).className = "lvtColDataSelected";
    }
    else
    {
        document.getElementById(rows).className = "lvtColDataHover";
    }
    
}
function listOnMouseOut(sel_id,type)
{
    var rows = "row_"+sel_id;
    if(document.getElementById(sel_id).checked)
    {
        document.getElementById(rows).className = "lvtColDataSelected";
    }
    else
    {
        if(type == 'On')
        {
            document.getElementById(rows).className = "lvtColDataBj"; 
   
        }
        else
        {
            document.getElementById(rows).className = "lvtColData";
        }
    }
}