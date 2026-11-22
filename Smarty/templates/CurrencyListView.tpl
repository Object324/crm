{*<!--
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="currencyForm" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="CurrencyEditView"/>
<input type="hidden" name="parenttab" value="{$PARENTTAB}"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_CURRENCY_SETTINGS'|@getFixedLabel}<font>（{'LBL_CURRENCY_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="editCurreny('','create')" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="CurrencyListViewContents" class="cont_wrap clear_float">
            {include file="CurrencyListViewEntries.tpl"}
        </div>
    </div>
</div>
</form>

<div id="currencydiv" class="D_pop_box LdPopWidth350px" style="display:none;position:absolute;"></div>

{literal}
<script>
	function deleteCurrency(currid)
	{
	   	$("status").style.display="inline";
		//zkt 20231013 XUQIU1001341 SQL注入
		ldAjaxHtmlNoProgress('index.php?','action=SettingsAjax&file=CurrencyDeleteStep1&return_action=CurrencyListView&return_module=Settings&module=Settings&parenttab=Settings&id='+currid,function(response) {
			$("status").style.display="none";
			$("currencydiv").innerHTML= response;
			Drag.init(document.getElementById("currencydivheading"),document.getElementById("currencydiv"));
		});
	}
	function InactivateCurrency(currencyid,checked_status){
	   if(checked_status){
	       var currency_status = 'ACTIVATE';
	   }else{
	       var currency_status = 'INACTIVATE';
	   }
	   //alert('action=SettingsAjax&file=CurrencyDelete&return_action=CurrencyListView&return_module=Settings&module=Settings&parenttab=Settings&cur_type='+currency_status+'&currencyid='+currencyid);
		//zkt 20231013 XUQIU1001341 SQL注入
		ldAjaxHtmlNoProgress('index.php?','action=SettingsAjax&file=CurrencyDelete&return_action=CurrencyListView&return_module=Settings&module=Settings&parenttab=Settings&cur_type='+currency_status+'&currencyid='+currencyid,function(response) {
			var surl = "index.php?module=Settings&action=SettingsAjax&file=CurrencyListView&ReportHeader=dheader&ajax=true";
			//alert(surl);
			ldAjax(surl,"",function(data){
				if(data.code==1){
					ld('#CurrencyListViewContents').html(data.result.content);
					DelProgressObjs();
				}
			})

		});
	}
	function transferCurrency(del_currencyid)
	{
		$("status").style.display="inline";
		$("CurrencyDeleteLay").style.display = "none";
		var trans_currencyid=$("transfer_currency_id").options[$("transfer_currency_id").options.selectedIndex].value;
		//zkt 20231013 XUQIU1001341 SQL注入
		ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=CurrencyDelete&ajax=true&delete_currency_id='+del_currencyid+'&transfer_currency_id='+trans_currencyid,function(response) {
			puyoungJS_DialogBox.unblock();
			$("status").style.display="none";//
			fninvshnew('currencydiv')
			$("CurrencyListViewContents").innerHTML= response;
		});
	}
</script>

{/literal}