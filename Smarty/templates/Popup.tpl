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
//function searchSubmit(event,searchtype){
//    var e = event || window.event;
//    if(e.keyCode == 13){// Enter 回车键
//        if(searchtype == 'Basic')//基本
//            callSearch('Basic');
//        else if(searchtype == 'quickSearch')    //快速查询
//            document.getElementById('UnifiedSearch').submit();
//        else
//            callSearch('Advanced');
//    }
//}
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
    	<div id="probom_div" name="probom_div" class="probom_tab">
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
					<input  type="hidden" value="{$VERSIONACCOUNT}" name="version_account"/>
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
                    <td>
                        <div class="DivSearch">
                        <ul>
                            <!-- <li class="searctype">{'SEARCH'|@getFixedLabel}</li> -->
                            <li class="padL8">{'Find_field'|@getFixedLabel}</li>
                            <li id="basicsearchcolumns_real" name="basicsearchcolumns_real">
                                <select name ="search_field" class="marL10" style="width:164px;margin-top: -3px;">
				                   {html_options  options=$SEARCHLISTHEADER selected=$SEARCHFIELDNAME}
								</select>
                            </li>
                            <li>
                                {'Find_Keyword'|@getFixedLabel}
                                <!---36451: （1.6）附件管理新增界面>添加相关对象弹出层>输入关键字：点击回车键进行查找，结果直接把选择相关对象弹出层关闭了。-->
                                <input type="text" value="{$SEARCHVALUE}" name="search_text" id="search_txt" class="btn-radius-system" style="width:120px;margin-top: -3px;" onkeyup="fun_setCrmPopupWindow.searchSubmit(event,'Basic')" />
                            </li>
                            <li>
                                <!--<input type="button" name="search" value="{'FINDNOW'|@getFixedLabel}" onClick="callSearch('Basic');" class="createauto"/>-->
                                <input type="button" name="search" onClick="fun_setCrmPopupWindow.callSearch('Basic');" class="saveauto" value="{'FINDNOW'|@getFixedLabel}" />
                            </li>
							{if $MODULE eq 'Products' && isPermitted($MODULE, 'Create', '') == 'yes'}
								<li>
									<!--<input type="button" name="search" value="{'FINDNOW'|@getFixedLabel}" onClick="callSearch('Basic');" class="createauto"/>-->
									<input class="createauto" name="search" value="{'Quickly_create'|@getFixedLabel}" onclick="QCreate('Products','select')" type="button">
								</li>
							{/if}
                            <li>
                                <!--快速创建-->
                                {if $MODULE eq 'AAccounts' || $MODULE eq 'CContacts' || $MODULE eq 'PProducts' || $MODULE eq 'VVendors'|| $MODULE eq 'VVendorContact'}
                                {*yyx 2015-4-23 在判断条件中添加VendorContact模块的判断条件*}
                                    {if (isPermitted($MODULE, 'Create', '') == 'yes')}
                                        <!--<input type="button" name="search" value="{'Quickly_create'|@getFixedLabel}" onClick="QCreate('{$MODULE}');" class="createauto">-->
                                        <div name="search" onClick="QCreate('{$MODULE}');" class="saveauto">{'Quickly_create'|@getFixedLabel}</div>
                                    {/if}
                                {/if}
                                <!--end-->
								<!-- 产品套餐快速创建 -->
								{if $MODULE eq 'Productbom'}
									{if (isPermitted($MODULE, 'Create', '') == 'yess')}
										<!--<input type="button" name="search" value="{'Quickly_create'|@getFixedLabel}" onClick="bom_edit('','create');" class="createauto">-->
                                         <div name="search" onClick="bom_edit('','create');" class="saveauto">{'Quickly_create'|@getFixedLabel}</div>
									{/if}
								{/if}
                            </li>
							
                        </ul>
                        </div>
                        
					</td>
                </tr>
                </tr> 
                <!-- 界面优化 去掉拼音搜索 全部注释，查找会报错，先隐藏-->                   
				 <tr style="display:none;">
					<td colspan="4" align="center" style="padding:5px;">
						<table width="100%" class="small" cellpadding="0" cellspacing="0">
						<tr>	
							{$ALPHABETICAL}
						</tr>
						</table>
					</td>
				</tr>
				</table>
				
				</form>
			</td>
		</tr>
		{if $recid_var_value neq '' && $MODULE!='Contacts' && 1 eq 2}
        <tr>
                <td align="right"><input id="all_contacts" alt="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" title="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" class="edit autoWidth marR8" value="{'DISPLAYALL'|@getFixedLabel}{$MODULE|@getTranstab}" LANGUAGE=javascript onClick="window.location.href=showAllRecords();" type="button"  name="button"></td>
        </tr>
        {/if}
	</table>

	<div style="display: flex">
		{if $POPUPMODULElISTTREE.enable eq 'yes'}
			<div class="marL10" id="popupListViewModuleListTree" name="popupListViewModuleListTree">
				<table class="ld-drag-area" border=0 cellspacing=0 cellpadding=0 style="height: 100%" >
					<tr>
						<td valign="top" class="user-left-td user-left-td-{$CURRENT_USER_ID}" name="popupmoduletreelist_td" id="popupmoduletreelist_td">
							{include file="PopupModuleListTree.tpl"}
							<div class="sidebar-drag"></div>
						</td>
						{*<td class="tip-items-list " data-tip="" data-direction="right" data-type="position">
							<span class="tree-closeopen tree-close"></span>
						</td>*}
						<td valign="top" name="popuptreereightcontent"></td>
					</tr>
				</table>
			</div>
		{/if}
		<div id="ListViewContents" name="ListViewContents">

			{if $MODULE|@get_file_address:'ProductDetails' == true || get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml')}

				{include file="PopupProductContents.tpl"}
			{elseif $MODULE|@get_file_address:'ContactsDetails' == true || $MODULE|@get_file_address:'VendorsDetails' == true}
				{include file="ListPopupContents.tpl"}
			{else}
				{include file="PopupContents.tpl"}
			{/if}

		</div>
	</div>
</div>
<!--快速创建-->
<div id="qcformDiv" class="D_pop_box LdPopWidth800px" style="position:absolute;display:none;top:50%;left:40%;z-index:999;">
   <div id="qcform"></div>
</div>
{if $MODULE == 'Productbom'}
<!-- 产品套餐 -->
<div id="qcbomformDiv" class="D_pop_box LdPopWidth800px" style="position:absolute;display:none;top:30%;left:10%;z-index:999;"></div>

<!-- 套餐份数 -->
<div id="qcbomnumberDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
	<div id="qcbomnumber">
		<div class="D_pop_tit">
			<strong class="D_ptita">{'NUMBEROFCOPIES'|@getFixedLabel}</strong>
			<a href="javascript:fninvshnew('qcbomnumberDiv');" class="D_ptitc">
				<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOESE'|@getFixedLabel}" title="{'CLOESE'|@getFixedLabel}">
			</a>
		</div>
		<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1" width="100%"><tbody>
			<tr align="left" style='display:none;' id='numberCopies_radiotr'>
				<td>
    					<input class="input-btn-align" type="radio" id="numberCopies_radio_1" value="1" checked/>{'SAMENUMBEROFCOPIES'|@getFixedLabel}
    					<input class="input-btn-align" type="radio" id="numberCopies_radio_2" value="0" />{'NUMBEROFDIFFERENT'|@getFixedLabel}
                </td>
			</tr>
			<tr>
				<td width="20%" style='padding:10px;'>
					<div id='numberCopies_div_1'>
                        <font color="red">*</font>
						{'NUMBEROFCOPIES'|@getFixedLabel}: 
						<input type="text" id="numberCopies_number" autocomplete='off' 
						onkeyup="this.value=this.value.replace(/\D/g,'');" maxlength='11'>
					</div>
					<div id='numberCopies_div_2' style='display:none;max-height:250px;overflow-y:auto;'>
						<table cellspacing="0" cellpadding="0" border="0" width="100%">
							<tr>
								<td>{'PRODUCTPACKAGE'|@getFixedLabel}</td>
								<td><font color="red">*</font>&nbsp;{'NUMBEROFCOPIES'|@getFixedLabel}</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
		  </tbody>
        </table>
        <div class="D_pbtn">
            <input name="button" class="D_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" onclick="bom_selectProductList();" type="button"/>
			<span>&nbsp;</span>
			<input name="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="bom.selectcancel();" type="button"/>
            <input type="hidden" id="numberCopies_bomid"/>
			<input type="hidden" id="numberCopies_prodid"/>
			<input type="hidden" id="numberCopies_bomprod"/>
        </div>
	</div>
</div>
{/if}
</body>
{$JS_SCRIPT}
<script type="text/javascript">
	/**
	 * 切换标签事件
	 * @project PROT127 爱哆哆需求1：产品套餐
	 * @author Tujt 2014-11-26
	 */
	var j = ld;
    var module = '{$MODULE}';
	{literal}
	ld(function(){
		var issubmit = 1;
       
		ld('.prodbomtag li').click(function(){
	      
            if(ld(this).prop('tagName')!="LI")
            {
                
                return false;
            }
            
			var tag = ld(this).attr('tag');
            
			var url = window.location.search;
          
			$("status").style.display="inline";
			ld('.prodbomtag li').each(function(){
				if(ld(this).attr('tag') == tag){
					ld(this).attr('class','On');
				}else{
					ld(this).attr('class','');
				}
			});
            //alert('index.php'+url+'&prodbomtag_d='+tag);
			location.href = 'index.php'+url+'&prodbomtag_d='+tag;
		});
	});
	function setPopContentHeight(module){
		
		var s_height = ld(window).height();
		var a = ld('#popup_width').outerHeight();//头部高度
		var b = 0;
		if(ld('.prodbomtag') != undefined){
			b = ld('.prodbomtag').outerHeight();
		}
		var c = ld('.Category').outerHeight();//分类
		var d = ld('.homePageMatrixHdr').outerHeight();//查询
		var e = ld('.Paging_div').outerHeight();//分页
		var f = ld('.saveauto').outerHeight();	//选择按钮
		if(a == null)a = 0;
		if(c == null)c = 0;
		if(d == null)d = 0;
		if(e == null)e = 0;
		if(f == null)f = 0;
		var c_height = s_height - a - b- c - d- e -f - 37 - 20; 
		if(module == 'Products'){
			ld('#listEntries_div').css('height',c_height);
			
		}else{
			ld('#resize_content_table_divid').css('height',c_height-20);
		}
	}
	setPopContentHeight(module);//计算内容高度 
	{/literal}
</script>