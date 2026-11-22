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
<script>
var image_pth = '{$IMAGE_PATH}';
global_ispopup_page='yes';

function showAllRecords()
{ldelim}
        modname = document.getElementById("relmod").name;
        idname= document.getElementById("relrecord_id").name;
        var locate = location.href;
        url_arr = locate.split("?");
        emp_url = url_arr[1].split("&");
        for(i=0;i< emp_url.length;i++)
        {ldelim}
                if(emp_url[i] != '')
                {ldelim}
                        split_value = emp_url[i].split("=");
                        if(split_value[0] == modname || split_value[0] == idname )
                                emp_url[i]='';
                        else if(split_value[0] == "fromPotential" || split_value[0] == "acc_id")
                                emp_url[i]='';

                {rdelim}
        {rdelim}
        correctUrl =emp_url.join("&");
        Url = "index.php?"+correctUrl;
        return Url;
{rdelim}

//function added to get all the records when parent record doesn't relate with the selection module records while opening/loading popup.
function redirectWhenNoRelatedRecordsFound()
{ldelim}
        var loadUrl = showAllRecords();
        window.location.href = loadUrl;
{rdelim}
</script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/resizetable.js"></script>
<link rel="stylesheet" type="text/css" href="{$THEME_PATH}style.css">
<link rel="stylesheet" type="text/css" href="{$THEME_PATH}global.css">
<link rel="stylesheet" type="text/css" href="{$THEME_PATH}liststyle.css">
<style type="text/css">@import url("themes/{$THEME}/popup.css");</style>
<style type="text/css">@import url("themes/{$THEME}/PickList.css");</style>

<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
</script>

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/json.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/{$LANGUAGETYPE}.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/multipingyin.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/FieldDependencies.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/ComboxPopup.js"></script>
<!-- vtlib customization: Javascript hook -->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/vtlib.js"></script>
<!-- END -->

{if $RETURN_MODULE neq ''}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/{$RETURN_MODULE}/{$RETURN_MODULE}.js"></script>
{/if}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/{$MODULE}/{$MODULE}.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/MassSMS.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/QuickCreate.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script type='text/javascript' src='{$JSURL}include/js/Entity.js' language="javascript"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js"></script>
     <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/QcPopup.js"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchPopup.js"></script>
	<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/MsgPopup.js"></script>
<script type='text/javascript'>
	ld.noConflict();
    var gVTModule = '{$MODULE}';
</script>
<style type="text/css">
{literal}
#qcbomformDiv input[type=text]{border: 1px solid #bababa;/*background-color: #ffffff;box-shadow: inset 0 1px 3px #DDD;border-radius: 3px;padding-left: 3px;*/}
#qcbomformDiv input[type=text]:focus{border-color: #66afe9;outline: 0;
-webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6);
box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6);}
#qcbomnumberDiv input[type=text]{border: 1px solid #bababa;/*background-color: #ffffff;box-shadow: inset 0 1px 3px #DDD;border-radius: 3px;padding-left: 3px;*/}
#qcbomnumberDiv input[type=text]:focus{border-color: #66afe9;outline: 0;
-webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6);
box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6);}
{/literal}
</style>
<script type="text/javascript">
{literal}
function searchSubmit(event,searchtype){
    var e = event || window.event;
    if(e.keyCode == 13){// Enter 回车键
        if(searchtype == 'Basic')//基本
            callSearch('Basic');
        else if(searchtype == 'quickSearch')    //快速查询
            document.getElementById('UnifiedSearch').submit();
        else
            callSearch('Advanced');
    }
}
function add_data_to_relatedlist(entity_id,recordid,mod, popupmode, callback) {
	var return_module = document.getElementById('return_module').value;
	if(popupmode == 'ajax') {
		puyoungJS_DialogBox.block();
		new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
             method: 'post',
             postBody: "module="+return_module+"&action="+return_module+"Ajax&file=updateRelations&destination_module="+mod+"&entityid="+entity_id+"&parentid="+recordid+"&mode=Ajax",
             onComplete: function(response) {
				 puyoungJS_DialogBox.unblock();
					var res = JSON.parse(response.responseText);
					if(typeof callback == 'function') {
						callback(res);
					}
                }
			}
		);
		return false;
	} else {
		{/literal}
         if(empty(recordid)){
			if(document.getElementById('recordid') != undefined){
				recordid = document.getElementById('recordid').value;
			}
		 }
        opener.document.location.href="index.php?module={$RETURN_MODULE}&action=updateRelations&destination_module="+mod+"&entityid="+entity_id+"&parentid="+recordid+"&return_module={$RETURN_MODULE}&return_action={$RETURN_ACTION}&parenttab={$CATEGORY}";
		window.close();
		{literal}
	}
}
{/literal}
function set_focus() {ldelim}
	$('search_txt').focus();
{rdelim}
</script>

<body  onload="set_focus()" class="small" marginwidth="0" marginheight="0" leftmargin=0 topmargin=0 bottommargin=0 rightmargin=0>
<div class="mailClientBg D_pop_content bgwhite">

	<!--{*
		选择产品弹出框添加套餐、产品标签
		@project PROT127 爱哆哆需求1：产品套餐
		@author tujt 2014-11-26
	*}-->
	{if $PRODBOMTAGARR && $PRODBOMTAGARR != ''}
    	<div id="probom_div" class="probom_tab">
    		<ul class='prodbomtag' style="margin-bottom:1px;">
    		{foreach key=key item=item from=$PRODBOMTAGARR}
    			<li {if $PRODBOMTAG_D == $key}class='On'{/if} tag='{$key}'>{$item}</li>
    		{/foreach}
    		</ul>
    	</div>
    	
			
    		<script language="JavaScript" type="text/javascript" src="modules/Products/Products.js"></script>
    	
	{/if}
	<table id="popup_width" name="popup_width" width="100%" border="0" cellpadding="0" cellspacing="0"></table>
    <!--
    edit:andrew;
    date:20140214
    reason:添加数据分类
    -->
    {if $CUSTOMVIEW_OPTION neq ''}
     <div class="Category Category_New">
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
         <td valign="middle" class="C">
        	<ul>
                <span class="category_span">{'DATACATEGORY'|@getFixedLabel}</span>
                <li style="padding: 6px 20px 0px 10px;">
                    {include file='SelectCustomView.tpl'}
                </li>
            </ul>
          </td>
        </tr>
      </table>
    </div>
    {/if}
	<div id="status" style="position:absolute;display:none;right:135px;top:15px;height:27px;white-space:nowrap;"><img src="{'status.gif'|@lingdang_imageurl:$THEME}"></div>
	<table  align="center" width="100%" cellpadding="0" cellspacing="0" border="0"  class="homePageMatrixHdr">
		<tr>
			<td>
				<form name="basicSearch" action="index.php" onSubmit="callSearch('Basic');return false;">
					<input type="hidden" name="searchtype" value="BasicSearch">
					<input type="hidden" id="returnmodule" name="returnmodule" value="{$RETURNMODULE}" />
					<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}" />
					<input type="hidden" name="module" id="module" value="{$MODULE}">
					<input type="hidden" name="action" value="Popup">
					<input type="hidden" name="query" value="true">
					<input type="hidden" name="select_enable" id="select_enable" value="{$SELECT}">
					<input type="hidden" name="curr_row" id="curr_row" value="{$CURR_ROW}">
					<input type="hidden" name="fldname_pb" value="{$FIELDNAME}">
					<input type="hidden" name="productid_pb" value="{$PRODUCTID}">
					<input name="popup_type" id="popup_type" type="hidden" value="{$POPUPTYPE}">
					<input name="recordid" id="recordid" type="hidden" value="{$RECORDID}">
					<input name="record_id" id="record_id" type="hidden" value="{$RECORD_ID}">
					<input name="return_module" id="return_module" type="hidden" value="{$RETURN_MODULE}">
					<input name="from_link" id="from_link" type="hidden" value="{$smarty.request.fromlink.value|@vtlib_purify}">
					<input name="maintab" id="maintab" type="hidden" value="{$MAINTAB}">
					<input type="hidden" id="relmod" name="relmod" tag="{$mod_var_name}" value="{$mod_var_value}">
					<input type="hidden" id="relrecord_id" name="relrecord_id" tag="{$recid_var_name}" value="{$recid_var_value}">
					<input name="popupform"  id="popupform" type="hidden" value="{$smarty.request.form|@vtlib_purify}">
					<input  name="warehouse" id="warehouse" type="hidden" value="{$WAREHOUSEID}"/>
					<input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
					<input type="hidden" name="publicaccounttype" value="{$ACCOUNTTYPE}" />
					<input  id="popupselect" type="hidden" value="{$SELECT}"/>
					<input type="hidden" value="{$ACCOUNTID}" id="account_id"  name="account_id"/>
					<input  type="hidden" value="{$VENDORID}" id="vendor_id" name="vendor_id"/>
					<input  type="hidden" value="{$POPUPMODE}" name="popupmode"/>
					<input  type="hidden" value="{$CALLBACK}" name="callback"/>
                    {if $smarty.request.form eq 'vtlibPopupView'}
						<input name="forfield"  id="forfield" type="hidden" value="{$smarty.request.forfield|@vtlib_purify}">
						<input name="srcmodule"  id="srcmodule" type="hidden" value="{$smarty.request.srcmodule|@vtlib_purify}">
						<input name="forrecord"  id="forrecord" type="hidden" value="{$smarty.request.forrecord|@vtlib_purify}">
					{/if}
					{if $smarty.request.currencyid neq ''}
						<input type="hidden" name="currencyid" id="currencyid" value="{$smarty.request.currencyid|@vtlib_purify}">
					{/if}
                    <input type="hidden" name='listval' id="listval" value="{$LISTVAL}" />
					{* END *}
                    <input type="hidden" name="allotaccount" id="allotaccount" value="{$ALLOTACCOUNT}" />
					<input type="hidden" name="selectSourcePopup" id="selectSourcePopup" value="yes" />
					<input type="hidden" name="withproductdetail" id="withproductdetail" value="{$WITHPRODUCTDETAIL}" />
                <table  align="center" width="100%"  cellpadding="0" cellspacing="0">
				<tr  class="basicsearchfield">
                    <td class="height25 padT10">
                        <div class="DivSearch">
                        <ul>
                            <!-- <li class="searctype">{'SEARCH'|@getFixedLabel}</li> -->
                            <li class="padL8" style="float: left;height: 34px;padding-right:0px;">采购清单编号：<input type="text" value="" name="purchaseinquiryorder_no" id="purchaseinquiryorder_no" class="btn-radius-system" style="width:80px;"/></li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">销售合同：<input type="text" name="salesorder_no" id="salesorder_no" class="btn-radius-system" style="width:80px;" onkeyup="fun_setCrmPopupWindow.searchSubmit(event,'Basic')" /></li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">采购清单主题：<input type="text" name="subject" id="subject" class="btn-radius-system" style="width:80px;" onkeyup="fun_setCrmPopupWindow.searchSubmit(event,'Basic')" /></li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">批次备注：<input type="text" name="remark" id="remark" class="btn-radius-system" style="width:80px;" onkeyup="fun_setCrmPopupWindow.searchSubmit(event,'Basic')" /></li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">清单负责人：<input type="text" name="user_name" id="user_name" class="btn-radius-system" style="width:80px;" onkeyup="fun_setCrmPopupWindow.searchSubmit(event,'Basic')" /></li>
                            
                            <li>
                                <!--<input type="button" name="search" value="{'FINDNOW'|@getFixedLabel}" onClick="callSearch('Basic');" class="createauto"/>-->
                                <input type="button" name="search" onClick="callSearchNew({$START});" class="searchbtn-btn" value="{'FINDNOW'|@getFixedLabel}" />
                            </li>
                        </ul>
                        </div>
                        
					</td>
                </tr>
                </tr> 
				</table>
				
				</form>
			</td>
		</tr>
	</table>

	<div id="ListViewContents" name="ListViewContents">
        
       {include file="PopupNewContents.tpl"}
      
	</div>
</div>
</body>