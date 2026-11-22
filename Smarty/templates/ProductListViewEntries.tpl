{if $smarty.request.ajax neq ''}
&#&#&#{$ERROR}&#&#&#
{/if}
<!-- 查找 begin -->
{if $SEATCH_INPUT.searchtype == 'BasicSearch'}
<div id="searchAcc" style="display: inline;/*position:relative;*/padding-bottom:5px;">
{else}
<div id="searchAcc" style="display: none;/*position:relative;*/padding-bottom:5px;">
{/if}
<form name="basicSearch" method="post" action="index.php" onSubmit="return callSearch('Basic');">
<input type="hidden" name="searchtype" value="BasicSearch">
<input type="hidden" name="module" value="{$MODULE}" id="curmodule">
<input name="maxrecords" type="hidden" value="{$MAX_RECORDS}" id='maxrecords'>
<input type="hidden" name="parenttab" value="{$CATEGORY}">
<input type="hidden" name="action" value="index">
<input type="hidden" name="query" value="true">
<input type="hidden" name="search_cnt">
{if $MODULE eq 'Accounts'}
	<input name="publicaccountstatus" id="publicaccountstatus" type="hidden" value="{$PUBLICACCOUNTSTATUS}">
	<input name="buttontype" id="buttontype" type="hidden" value="{$BUTTONTYPE}">
{/if}
</form>
</div>
<!-- 查找 end -->
<form name="massdelete" method="POST" id="massdelete" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="publicaccounttype" value="{$ACCOUNTTYPE}" />
    <input name='search_url' id="search_url" type='hidden' value='{$SEARCH_URL}'>
    <input name="idlist" id="idlist" type="hidden">
    <input name="change_owner" type="hidden">
    <input name="change_status" type="hidden">
    <input name="action" type="hidden">
    <input name="step" type="hidden">
    <input name="excludedRecords" type="hidden" id="excludedRecords" value="">
    <input name="numOfRows" id="numOfRows" type="hidden" value="{$NUMOFROWS}">
    <input name="allids" type="hidden" id="allids" value="{$ALLIDS}">
    <input name="selectedboxes" id="selectedboxes" type="hidden" value="{$SELECTEDIDS}">
    <input name="allselectedboxes" id="allselectedboxes" type="hidden" value="{$ALLSELECTEDIDS}">
    <input name="current_page_boxes" id="current_page_boxes" type="hidden" value="{$CURRENT_PAGE_BOXES}">
    <input name="assign_name" id="assign_name" type="hidden" value="{$id}">
    <input name="row_of_checkbox_account" id="row_of_checkbox_account" type="hidden" value="{$num_rows_contact}">
    <input name="row_of_checkbox_contact_email" id="row_of_checkbox_contact_email" type="hidden" value="{$num_rows_Email}">
    <input type="hidden" id="publicaccount_count" name="publicaccount_count" value="{$PUBLICKACCOUNTCOUNT}"/>
    <input type="hidden" id="have_publicaccount" name="have_publicaccount" value="{$HAVEPUBLICACCOUNT}"/>
    <input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
	<input type="hidden" id="pool_id" name="pool_id" value="{$POOL_ID}"/>
    <div class="main_grid lfloat main_grid_list">
        <div class="main_grid_top">
			<!--44265: 如果用户不是任何一个公海池的“公海成员”，也不是“公海管理员”，也不是公海“超级管理员”或者系统管理员-->
			{*{if $PUBLICACCOUNTSTATUS eq 'yes' && $PUBLIC_ACCOUNT_POOL_LABEL|@count neq 0 && $LINKMODULECUSTOM neq 'true'}
				<div name="div_public_account" id="div_public_account">
					{include file='PublicAccount.tpl'}
				</div>
			{/if}*}
        	{if $MODULE eq 'Approve'}
        		 <input name="fromapprovemodule" id="fromapprovemodule" type="hidden" value="{$FROMAPPROVEMODULE}">
        		 <input name="approvestatus" id="approvestatus" type="hidden" value="{$APPROVESTATUS}">
        	{/if}
        </div>
        <div class="main_grid_box">
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float">
                	<div id="divMapShow" class="divMapShow" style="width:100%; display:none;" >
                		<div class="divMapLeft" id="divMapLeft">
                			
                		</div>
                		<div class="divMapRight">
                			<div id="map_div" name="map_div" style="width:100%;">
                		
                			</div>
                		</div>
                	 </div>
                    {assign var=operating value='OPERATING'|@getFixedLabel}
                    {assign var=listtable_ui_type value=484|@getSys_deploy}
                    <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;"><!-- style="width:100%;" -->
                        <div style=" visibility: visible; top: 194px;overflow: hidden;" id="resize_header_table_divid" name="resize_header_table_divid">
                            <div style="float:left; padding-right:20px">
                                <table border="0" cellspacing="0" cellpadding="0" name="resize_header_tableid" id="resize_header_tableid" style="width:{$TOTALWIDTH}px" class="listEntries {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if} {if $TableLineHightSet=='compact'}listEntriesCompact{elseif $TableLineHightSet=='spacious' }listEntriesSpacious{/if}">
                                    <tr>
                						{if $LIST_NOCHECKBOX neq 'no'}
                                        <th class="firstChild" style="width:{$CHKBOXWIDTH}px;" tag="0" headermodule="{$MODULE}" headername='chkbox'>
                                            <input class="checkbox-item j-all-checkbox" type="checkbox" name="selectall" id="selectCurrentPageRec" onClick="toggleSelect_ListView(this.checked,'selected_id')" />
                                        </th>
                						{/if}
                                        {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                            {if $header neq $operating || $LIST_NOOPERATING eq 'no'}
                                                <th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
                                            {else}
                                                <th width="{$OPERATIONWIDTH}" tag="{$i+1}">{$header}</th>
                                            {/if}
                                        {/foreach}
                                    </tr>
                                </table>                        
                            </div>
                        </div>
                        <div style="overflow:auto;height:300px;" id="resize_content_table_divid" name="resize_content_table_divid">
                            <table border="0" cellspacing="0" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid" style="width:{$TOTALWIDTH}px" class="listEntries {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if} {if $TableLineHightSet=='compact'}marT-45 listEntriesCompact{elseif $TableLineHightSet=='spacious' }marT-58 listEntriesSpacious{else}marT-53{/if}">
                                <tr name="tr_header">          
                					{if $LIST_NOCHECKBOX neq 'no'}
                                    <th class="firstChild" style="width:{$CHKBOXWIDTH}px;" tag="0" headermodule="{$MODULE}" headername='chkbox'>
                                        <input type="checkbox"  name="selectall" id="selectCurrentPageRec" onClick="toggleSelect_ListView(this.checked,'selected_id')" headermodule="{$MODULE}" headername='chkbox' />
                                    </th>
                					{/if}
                                    {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                        {if $header neq $operating || $LIST_NOOPERATING eq 'no'}
                                            <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}'>{$header}</th>
                                        {else}
                                            <th width="{$OPERATIONWIDTH}" tag="{$i+1}">{$header}</th>
                                        {/if}
                                    {/foreach}
                                </tr>                            
                                <tr>
                                    {*<td id="linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="{$LISTHEADERCOUNT}" onclick="toggleSelectAll_parent_td(this)">
                                        <span id="selectAllRec" class="selectall" style="display:inline;" onClick="toggleSelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
                                        <span id="deSelectAllRec" class="selectall" style="display:none;" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
                                    </td>*}
                                </tr>
                                {* 产品明细序时簿*}
                                {$PROHTML}
                                {if $fromtype!='salesfunnel'}

                                    {if $TOTALFLDHTML != ''}
                                    {$TOTALFLDHTML}
                                {/if}
                                {/if}
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div name="listviewpagination" id="listviewpagination" style="display: flex;align-items: center;height: 50px;width: 100%;">
        </div>
    </div>
</form>
{$SELECT_SCRIPT}
{if $MODULE eq 'ServiceCharge' && $ISADMIN eq true}
<div id="SMSedit" class="D_pop_box  LdPopWidth300px" style="position: absolute; z-index:9999; left: 300px; top: 350px;display:none;">

</div>
<div id="Emailedit" class="D_pop_box  LdPopWidth300px" style="position: absolute; z-index:9999; left: 300px; top: 350px;display:none;">
    
</div>
{/if}
<div id="basicsearchcolumns" style="display:none;"><select name="search_field" id="bas_searchfield" style="width:150px">{html_options  options=$SEARCHLISTHEADER}</select></div>

<!--同步库存，弹出框-->
<div id="synchronousInventoryDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
	<div class="D_pop_tit">
    	<strong class="D_ptita">{'DATAEXCHANGE'|@getFixedLabel}——{'SYNCHRONOUSINVENTORY'|@getFixedLabel}</strong>
        <a class="D_ptitc" href="javascript:hideOptions('synchronousInventoryDiv');puyoungJS_DialogBox.unblock();">
            <img title="关闭" alt="关闭" src="themes/icon/pop_close.png" class="D_ptitcimg">
        </a>
    </div>

	<table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0">
	  <tr><td class="Note">{'SYNCHRONOUSINVENTORYNOTE'|@getFixedLabel}</td></tr>
	  <tr><td><input type="radio" id="synchronousOne" name="Synchronous" checked="true">{'SYNCHRONOUSINVENTORYNOTEONE'|@getFixedLabel}</td></tr>
	  <tr><td><input type="radio" id="synchronousTwo" name="Synchronous">{'SYNCHRONOUSINVENTORYNOTETWO'|@getFixedLabel}</td></tr>
	</table>

    <div class="D_pbtn">
        <input class="D_pbtnok" type="button" value="{'SAVE'|@getFixedLabel}" onclick="disableStyle();synchronousInventory()"/><span>&nbsp;</span>
            <input type="button" onclick="fninvshnew('synchronousInventoryDiv');" value="{'CANCEL'|@getFixedLabel}" class="D_pbtncancel">   

    </div>
</div>

<div id="SMSedit" class="D_pop_box LdPopWidth300px" style="position: absolute; z-index:9999; left: 300px; top: 350px;display:none;">

</div>
<!--
更新操作
edit：cdw
date：20131205
reason：客户联系人序时簿群发短信，邮件改进
-->

<div id="Emailedit" class="E_pop_box LdPopWidth300px" style="position: absolute; z-index:9999; left: 300px; top: 350px;display:none;">
    
</div>
{include file="basicSearch.tpl"}

<div id="SubmitApprove" class="D_pop_box LdPopWidth500px" style="display:none;"></div>
<script id="listajaxentries">
var popupobj=CrmPopup.getPopupObj("last");
if(popupobj.divid == 'dv_listhighersearch'){
    popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    if(popupobj){

    }else{
        popupobj = CrmPopup.getPopupObj('lastprev');
    }
}
if(ld('.listviewsecond #tip_list').length > 0 && ld('.listviewsecond #tip_list').get(0).style.display == 'block'){
    ld('.listviewsecond #tip_list').css('display','none');
    ld('.listviewsecond #tip_map').css('display','block');
    ld('.listviewsecond #tip_map').find('span.cur').removeClass('cur');
}
popupobj.url='{$LISTPAGEURL}';
popupobj.page_list_query='{$Encrypt_page_list_query}';
popupobj.list_query='{$Encrypt_list_query}';

//duan  20240801 BUG20240731-02 记录高级查询的Json内容，在切换页签的时候重新生成高级查询条件
var CRITERIA_GROUPS_JSON = '{$CRITERIA_GROUPS_JSON}';
if(!empty(CRITERIA_GROUPS_JSON)){
    popupobj.list_criterid_groups_json = CRITERIA_GROUPS_JSON;
}
/*标签*/
if(Listpagepopupobj != undefined && Listpagepopupobj.fields != undefined){
	ld.each(Listpagepopupobj.fields,function(ikey,tag){
		if(tag.uitype == 301){
			ld('#module_tag_list_search').show();
			return false; 
		}
	});
}
{if $VERSION_ACCOUNT eq 'kfbcrm81'}
ld(function () {
    //抽屉设置事件
    ld(".first-listset-drawer").click(function(){
        initDrawer();//Leftmenu.js
        initDrawerListpage();//Leftmenu.js
    });
});
{/if}

var module = '{$MODULE}';
var isstructuretree=ld(" #structuretree");
if (isstructuretree.length>0){
    // ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
    popupobj.list_TreeWhere = '{$Encrypt_TreeWhere}';
    if (typeof structureTreeobj == "undefined" || structureTreeobj == undefined){
        var structureTreeobj=new structureTree();
    }
    structureTreeobj.getModuleTreeCount(popupobj);
}

//hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化

var tabname = '{$TABNAME}';
var tmp_pagedata = {
    'currentpage': {$STARTPAGE},
    'count': {$LISTVIEWRECORDCOUNT},
    'pagecount': {$LISTVIEWPAGECOUNT},
    'language': language,
    'changepage': function (pagenum) {
        if (module == 'Documents') {
            getListViewEntries_js(module, 'parenttab=' + tabname + '&start=' + pagenum + '&folderid=index');
        } else {
            getListViewEntries_js(module, 'parenttab=' + tabname + 's&start=' + pagenum);
        }
    },
    'pagepernumarr': {$LISTVIEWPERPAGENUM},
    'changepagecount': function (evt){
        var pagecount=evt.NavBarItem.value;
        setMaxEntriesPerPage(module,pagecount,tabname);
    }
}
var jumpbtn = '{$PAGEJUMPBTN}';
if(jumpbtn == 'yes'){
    tmp_pagedata['jumpbutton'] = true;
}
AjaxJSPage('ld_Pagination','include/js/component/ld_Pagination.js');
var last_crmpopup = CrmPopup.getPopupObj("last");
var tmp_divid = '';
if(last_crmpopup.pagetype == 'advance_stage_chuantou'){
    tmp_divid = last_crmpopup.divid;
}
else if(last_crmpopup.pagetype == 'detailview_modulepage' || last_crmpopup.type == 'relatelistpage'){
    var prevpopup = CrmPopup.getPopupObj("lastprev");
    if(prevpopup.pagetype == 'advance_stage_chuantou' || prevpopup.pagetype == ListPagePopup.type) {
        tmp_divid = prevpopup.divid;
    }else if(prevpopup.pagetype = 'detailview_modulepage'){
        tmp_divid = CrmPopup.getlastPopupObjByType('listpage').divid;
    }
}
else if(last_crmpopup.type == 'CreatePaymentplan' || last_crmpopup.type == 'CreateSendPaymentplan'){
    var prevpopup = CrmPopup.getPopupObj("lastprev");
    if(prevpopup.pagetype != 'listpage'){
        prevpopup = CrmPopup.getlastPopupObjByType('listpage');
    }
    tmp_divid = prevpopup.divid;
}
else{
    if(last_crmpopup.type == 'none'){
        tmp_divid = CrmPopup.getlastPopupObjByType('listpage').divid;
    }else{
        if(popupobj.module == module){
            tmp_divid = popupobj.divid;
        }
        else{
            tmp_divid = CrmPopup.getlastPopupObjByPageType('listpage').divid
        }
    }

}
var listviewpagination = ld('#'+tmp_divid+' #listviewpagination');
var listviewpaginationobj = ld_Pagination.showPagination(listviewpagination.get(0), tmp_pagedata);

var pagecount = {$LISTVIEWPAGECOUNT};
if(pagecount>1){
    ld('.ld_listviewchooseall').show();
}else{
    ld('.ld_listviewchooseall').hide();
}
ld('#selectAllRec span#count').html({$LISTVIEWRECORDCOUNT});
if(last_crmpopup.pagetype && last_crmpopup.pagetype == 'advance_stage_chuantou'){
    ld("#"+last_crmpopup.divid+' #resize_header_tableid').css('width',ld("#"+last_crmpopup.divid).width()+'px');
    ld("#"+last_crmpopup.divid+' #resize_content_tableid').css('width',ld("#"+last_crmpopup.divid).width()+'px');
    var listresizeobj=new List_ResizeTable(last_crmpopup);
    last_crmpopup.listresizeobj=listresizeobj;
    last_crmpopup.listresizeobj.setReiszeTable_Init(last_crmpopup.module,'ajax');
    var icon_obj = ld('#'+last_crmpopup.divid+' #'+last_crmpopup.divid+'_fullscreen');
    if(icon_obj.length > 0){
        var switchtype = 'fullscreen';
        if(icon_obj.attr('switchtotype') == 'recovery'){
            switchtype = 'fullscreen';
        }else {
            switchtype = 'recovery';
        }
        last_crmpopup.Fullscreencallback(switchtype);
    }
}
</script>
