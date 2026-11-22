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
    <div class="main_grid lfloat main_grid_list">
        <div class="main_grid_top">
        	
            {if $MODULE neq 'Calendar'}
                <input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
            {/if}
            <div class="ld-listview-screen-content">
                <div class="ListViewNavBarAndBtn" id="ListViewNavBarAndBtn">
                    {if $Merge_SmOwner!=""&&$MODULE neq 'InventoryAccount' && $MODULE neq 'InventoryQuery' && $MODULE neq 'BankAccountSet' &&$MODULE neq 'Reminds'}
                        <div class="ld-listview-chooseusers">
                            {include file='SearchScope_New.tpl'}
                        </div>
                    {else}
                        <select onchange="SmOwnerSearchScopeChange(this,'{$MODULE}','{$CATEGORY}')" id="SmOwnerSearchScope" name="SmOwnerSearchScope" style="display:none">
                            <option value="SmOwner_Search_All" selected="true">全部</option>
                        </select>
                    {/if}
                    <div class="ld-flex-start ld-flex-wrap ld-listview-btnscontent listview_toprightbox">
                        <div class="ld-button" title="{'CREATE'|@getFixedLabel}" tag="" onclick="channelcode_add(0);return false;">{'CREATE'|@getFixedLabel}</div>
                    </div>
                </div>
                <div class="ld-flex-between gwidth100 ld-flex-wrap" id="ListViewBtnAndSeach" style="height: 50px;position: relative;padding: 0 15px 12px;">
                    <div class="ld-flex-start ld-flex-wrap">
                        <!--按钮、查看范围-->
                        {assign var="buttonsPosition" value='up'}
                        <div class="ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
                            {*基本查找组件 zxm 20221212*}
                            {include file='ListViewBasicSearch.tpl'}
                        </div>
                        
                        {if $MODULEADVANCESTAGESTATUS eq 'yes'}
                            <div class="list-item">
                                <span class="" title="{'PropelledFunnel'|@getFixedLabel}"><i class="list-item-btn funnel-btn" onclick="AdvanceStageHighcharts('{$MODULE}')"></i></span>
                            </div>
                        {/if}
                    </div>
                    
                    <div class="ld_listviewabtnrely" id="ld_listviewabtnrely">
                        <div class="ld_listviewchosenum">{'choose'|@getFixedLabel} <span class="chosenum">0</span> {'numbill'|@getFixedLabel}</div>
                        <div class="ld_listviewchooseall" {if isset($LISTVIEWPAGECOUNT) && $LISTVIEWPAGECOUNT > 1}{else}style="display: none;"{/if}>
                                <span id="selectAllRec" class="selectall" style="display:inline;" onClick="toggleSelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
                        <span id="deSelectAllRec" class="selectall" style="display:none;" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
                    </div>
                    <div class="ld_listviewabtnrelylist">
                        <ul>
                            <li class="listviewbtnrely" title="{'DELETE'|@getFixedLabel}" onclick="listviewbutton_click(this,'ChannelCode','Delete',event);return false;"><img class="relybtnicon" src="themes/icon/button/Delete.png"><span>{'DELETE'|@getFixedLabel}</span></li>
                        </ul>
                    </div>
                    <div class="ld_btnrelycancel" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')"><i class="btncloseicon"></i></div>
                </div>
            </div>
        </div>
        {assign var=listtable_ui_type value=484|@getSys_deploy}
        <div class="main_grid_box">
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float">
                    {assign var=operating value='OPERATING'|@getFixedLabel}
                    <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position:relative;">
                        <div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid" name="resize_header_table_divid">
                            <div  style="float:left; padding-right:20px">
                                {if $LIST_NOCHECKBOX neq 'no'}
                                <table class="listEntries fir-center {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}" id="resize_header_tableid" name="resize_header_tableid" border="0" cellspacing="0" cellpadding="0" style="width:{$TOTALWIDTH}px">
                                {else}
                                <table class="listEntries fir-center {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}" id="resize_header_tableid" name="resize_header_tableid"  border="0" cellspacing="0" cellpadding="0" style="width:{$TOTALWIDTH}px">
                                {/if}
                                    <tr>
                                        {if $LIST_NOCHECKBOX neq 'no'}
                                            <th style="text-align:center;width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'>
                                                <input class="checkbox-item j-all-checkbox" type="checkbox" name="selectall" id="selectCurrentPageRec" onClick=toggleSelect_ListView(this.checked,"selected_id")>
                                            </th>
                                        {/if}

                                        {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                            {if $header neq $operating || $LIST_NOOPERATING eq 'no'}
                                                <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule="{$HEADERNAME.module[$i]}" headername="{$HEADERNAME.fieldname[$i]}" >{$header}</th>
                                            {else}
                                                <th width="{$OPERATIONWIDTH}" tag="{$i+1}">{$header}</th>
                                            {/if}
                                        {/foreach}
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div style="overflow:auto;height:300px;" id="resize_content_table_divid">
                            {if $LIST_NOCHECKBOX neq 'no'}
                            <table class="listEntries {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if} fir-center marT-53" id="resize_content_tableid" name="resize_content_tableid" style="width:{$TOTALWIDTH}px" border="0" cellspacing="0" cellpadding="0" >
                            {else}
                            <table class="listEntries {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if} marT-53" id="resize_content_tableid" name="resize_content_tableid" style="width:{$TOTALWIDTH}px" border="0" cellspacing="0" cellpadding="0" >
                            {/if}
                                <tr name="tr_header">
                                    {if $LIST_NOCHECKBOX neq 'no'}
                                        <th class="firstChild" style="width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'></th>
                                    {/if}
                                    {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                        {if $header neq $operating || $LIST_NOOPERATING eq 'no'}
                                            <th class="firstChild" style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$HEADERNAME.module[$i]}' headername="{$HEADERNAME.fieldname[$i]}">{$header}</th>
                                        {else}
                                            <th width="{$OPERATIONWIDTH}" tag="{$i+1}">{$header}</th>
                                        {/if}
                                    {/foreach}
                                </tr>
                                <tbody>
                                    <tr>
                                        {*<td id="linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="{$LISTHEADERCOUNT}" onclick="toggleSelectAll_parent_td(this)">
                                            <span id="selectAllRec" class="selectall" style="display:inline;" onClick="toggleSelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
                                            <span id="deSelectAllRec" class="selectall" style="display:none;" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
                                        </td>*}
                                    </tr>
                                    {$DEAILHTML}
                                    {if $MODULE == 'InventoryQuery'}
                                        {if $NUMOFROWS > 0}
                                            <tr bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'" id="row_{$entity_id}">
                                                {*<td colspan="" align="right">∑&nbsp;{'TOTALTHIS'|@getFixedLabel}</td>*}
                                                {foreach item=value key=entity_id from=$INVENTORYCOUNT}
                                                    <td align="right">{$value}</td>
                                                {/foreach}
                                            </tr>
                                            <tr bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'" id="row_{$entity_id}">
                                                {*<td colspan="" align="right">∑&nbsp;{'TOTALALL'|@getFixedLabel}</td>*}
                                                {foreach item=value key=entity_id from=$INVENTORYSUM}
                                                    <td align="right">{$value}</td>
                                                {/foreach}
                                            </tr>
                                        {/if}
                                    {else}
                                        {if $TOTALFLDHTML != ''}
                                            {$TOTALFLDHTML}
                                        {/if}
                                    {/if}
                                </tbody>
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

<div id="basicsearchcolumns" style="display:none;"><select name="search_field" id="bas_searchfield" style="width:150px">{html_options  options=$SEARCHLISTHEADER}</select></div>
<div id="SMSedit" class="D_pop_box LdPopWidth300px" style="position: absolute; z-index:9999; left: 300px; top: 350px;display:none;">
</div>
<!--
更新操作
edit：cdw
date：20131205
reason：客户联系人序时簿群发短信，邮件改进
-->
<div id="Emailedit" class="D_pop_box LdPopWidth300px" style="position: absolute; z-index:9999; left: 300px; top: 350px;display:none;">
</div>

{if $MODULE eq 'Documents'}
    {include file='modules/Documents/Doc_listview.tpl'}
{/if}

<!--基本查询-->
{include file="basicSearch.tpl"}
<div id="SubmitApprove" class="D_pop_box LdPopWidth500px" style="display:none;"></div>

<script id="listajaxentries">
  var popupobj=CrmPopup.getPopupObj("last");

    popupobj.url='{$LISTPAGEURL}';
</script>

<script>
    //hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
    var module = '{$MODULE}';
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
    AjaxJSPage('ld_Pagination','include/js/component/ld_Pagination.js');
    var last_crmpopup = CrmPopup.getPopupObj("last");
    var tmp_divid = '';
    if(last_crmpopup.pagetype == 'advance_stage_chuantou'){
        tmp_divid = last_crmpopup.divid;
    }else{
        tmp_divid = popupobj.divid;
    }
    var listviewpagination = ld('#'+tmp_divid+' #listviewpagination');
    var listviewpaginationobj = ld_Pagination.showPagination(listviewpagination.get(0), tmp_pagedata);
    popupobj.listviewpaginationobj = listviewpaginationobj;
</script>