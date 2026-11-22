/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

document.write("<script type='text/javascript' src='include/js/Merge.js'></"+"script>");
/*
*AUTHOR:BY LD KEVIN
*DATE:20130129
*DESCRIPTION:修改bug3194
*document.write("<script type='text/javascript' src='modules/RecycleBin/language/en_us.lang.js'></"+"script>");
*/
document.write("<script type='text/javascript' src='modules/RecycleBin/language/zh_cn.lang.js'></"+"script>");

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
        	new Ajax.Request(
		'index.php',
		{
			queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:urlstring +'&query=true&module=RecycleBin&action=RecycleBinAjax&file=index&ajax=true&mode=ajax',
			onComplete: function(response) 
			{
				$("status").style.display="none";
        $("modules_datas").innerHTML=response.responseText;
				$("search_ajax").innerHTML = '';
			}
	      }
        );

}
function changeModule(pickmodule)
{
	$("status").style.display="inline";
	var module=pickmodule.options[pickmodule.options.selectedIndex].value;
	new Ajax.Request(
                'index.php',
                {
			queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=ListView&selected_module='+module,
	                onComplete: function(response) 
					{
						$("status").style.display="none";
						$("modules_datas").innerHTML=response.responseText;
						$("searchAcc").innerHTML = $("search_ajax").innerHTML; 
						$("search_ajax").innerHTML = '';
					}
                }
        );
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

		$("status").style.display="inline";
		//alert('action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Rassdelete&idlist='+idstring+'&selectmodule='+selectmodule+'&excludedRecords='+excludedRecords);
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody: 'action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Rassdelete&idlist='+idstring+'&selectmodule='+selectmodule+'&excludedRecords='+excludedRecords,
				onComplete: function(response)
				{
					$("status").style.display="none";
					if(empty(response.responseText)) return false;
					var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
					var divobj = createElementDivs('RecycleBin_del');
					ld(divobj).css('max-height','350px');
					ld('#RecycleBin_delcontent').css('max-height','250px');
					ld('#RecycleBin_delcontent').css('overflow-y','auto');
					var submitlog = '<div style="line-height:22px;">';
					submitlog += restobj.log.value;//批量提交失败日志
					submitlog += '</div>';
					ld(divobj).find('div.D_pop_tit .D_ptita').html(restobj.title.value);
					ld('#RecycleBin_delcontent').html(submitlog);
					fnvshobj('', 'RecycleBin_del');
					ld('#RecycleBin_del .D_pbtn .D_pbtncancel').css('display','none');
					ld('#RecycleBin_del .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						fninvshnew('RecycleBin_del');lingdangJS_DialogBox.unblock();
						window.location='index.php?module=RecycleBin&action=index&selected_module='+selectmodule;
					});
					return false;
				}
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

	if(confirm_status){
		var selectmodule = $('select_module').value;
		var selectmoduletranslated =  $('selected_module_translated').value;
		//alert('action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Restoration&idlist='+idstring+'&selectmodule='+selectmodule+'&excludedRecords='+excludedRecords);
		/*if(confirm(arrJsPopLabel['SUREWANTRESTORESELECTEDCONTENT']))
		{*/
			$("status").style.display="inline";
			new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody: 'action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Restoration&idlist='+idstring+'&selectmodule='+selectmodule+'&excludedRecords='+excludedRecords,
					onComplete: function(response)
					{
						$("status").style.display="none";
						if(empty(response.responseText)) return false;
						var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
						createElementDiv('RecycleBin_hy');//创建DIV
						ld('#RecycleBin_hytitlename').html(restobj.title.value);
						sethtml(document.getElementById('RecycleBin_hycontent'),restobj.log.value);
						ld('#RecycleBin_hy .D_pbtn .D_pbtncancel').css('display','none');
						ld('#RecycleBin_hy .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
							fninvshnew('RecycleBin_hy');lingdangJS_DialogBox.unblock();
							window.location='index.php?module=RecycleBin&action=index&parenttab=Tools&selected_module='+selectmodule;
						});
						return false;
					}
				}
				);
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
		$("status").style.display="inline";
		new Ajax.Request(
			'index.php',
	        {
				queue: {position: 'end', scope: 'command'},
	            method: 'post',
	            postBody: 'action=RecycleBinAjax&module=RecycleBin&mode=ajax&file=Restoration&idlist='+entityid+'&selectmodule='+select_module,
		        onComplete: function(response) {
					$("status").style.display="none";
					if(empty(response.responseText)) return false;
					var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
					createElementDiv('RecycleBin_hy');//创建DIV
					ld('#RecycleBin_hytitlename').html(restobj.title.value);
					sethtml(document.getElementById('RecycleBin_hycontent'),restobj.log.value);
					ld('#RecycleBin_hy .D_pbtn .D_pbtncancel').css('display','none');
					ld('#RecycleBin_hy .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						fninvshnew('RecycleBin_hy');lingdangJS_DialogBox.unblock();
						window.location='index.php?module=RecycleBin&action=index&parenttab=Tools&selected_module='+select_module;
					});
					return false;
	            }
			}
		);
    });
}

function getListViewEntries_js(module,url)
{
	var all_selected = $('allselectedboxes').value;
	var excludedRecords = $('excludedRecords').value;

	$("status").show();
	var selected_module = $("select_module").value;
	var urlstring = "&selected_module=" + selected_module;
	<!-- Ticket 6330 -->
	if($('search_url').value!='')
		urlstring = $('search_url').value+"&selected_module="+selected_module;

	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody : "module=RecycleBin&action=RecycleBinAjax&file=ListView&mode=ajax&ajax=true&"+url+urlstring+"&allselobjs="+all_selected+"&excludedRecords="+excludedRecords,
			onComplete: function(response) {
				$("status").hide();
				if($("modules_datas")) {
					$("modules_datas").innerHTML = response.responseText;
				}
				if(all_selected == 'all'){
					$('linkForSelectAll').show();
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
					$('linkForSelectAll').hide();
					update_selected_checkbox();
				}
			}
		}
	);
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
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:"module="+module+"&action="+module+"Ajax&file=index&mode=ajax&ajax=true&"+url,
			onComplete: function(response) {
				$("status").style.display="none";
				$("modules_datas").innerHTML=response.responseText;
				$("search_ajax").innerHTML = '';
			}
		}
	);
}

function callEmptyRecyclebin(obj) {
	//document.getElementById('rb_empty_conf_id').style.display = 'block';
    fnvshobj(obj, 'rb_empty_conf_id'); 
}

function emptyRecyclebin(id) {
	if($(id)) $(id).hide();
	lingdangJS_DialogBox.progress();
	var pickmodule = $('select_module');
	var module=pickmodule.options[pickmodule.options.selectedIndex].value;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
            postBody:"module=RecycleBin&action=RecycleBinAjax&file=EmptyRecyclebin&mode=ajax&ajax=true&selected_module="+module,
			onComplete: function(response) {
                $("status").style.display="none";
               	$("modules_datas").innerHTML= response.responseText;
				$("searchAcc").innerHTML = $("search_ajax").innerHTML; 
				$("search_ajax").innerHTML = '';
				lingdangJS_DialogBox.hideprogress();
                fninvsh('rb_empty_conf_id');
			}
		}
	);	
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