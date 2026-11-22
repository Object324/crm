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
    <input type="hidden" id="pool_id" name="pool_id" value="{$POOL_ID}"/>
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
    <input name="workreport_logtype" id="workreport_logtype" type="hidden" value="{$workreport_logtype}">
    <div class="main_grid lfloat main_grid_list">
        <div class="main_grid_top">
            {*{if $PUBLICLeadsSTATUS eq 'yes' && $PUBLIC_Leads_POOL_LABEL|@count neq 0 && $LINKMODULECUSTOM neq 'true'}
				<div name="div_public_account" id="div_public_account">
					{include file='PublicLeads.tpl'}
				</div>
			{/if}*}
        	{if $MODULE eq 'Approve'}
                <input name="fromapprovemodule" id="fromapprovemodule" type="hidden" value="{$FROMAPPROVEMODULE}">
                <input name="approvestatus" id="approvestatus" type="hidden" value="{$APPROVESTATUS}">
        	{/if}
            <!--切换导航-->
            {if $MODULE eq 'Users'}
                <!--
                    diony 2021-05-19
                    【成员管理界面，右边成员列表上方的公司名称和已用用户数去掉，增加到左侧显示】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001649 -->
                <!-- <div class="user-abutton">
                    <div style="float:left;margin-left:8px;padding-top: 10px;padding-bottom: 10px;line-height: 20px;"><span style="font-size: 16px;float:left;padding-right:5px;"> <b style="font-weight: normal;">{$GROUPUSERCOUNTINFO}</b></span>
                    <b id="askgreyHelp" style="float:left;margin-top: 2px;cursor: pointer;" class="icon-homeimg icon-askgrey"><span id="tip_info">{$REGISTERINFO}</span> </b></div>
                </div>
                <div class="clear"></div> -->
                <script>
                    if(ld(" .detail_path li.detail_path_users").find("span").length <= 0){
                        ld(" .detail_path li.detail_path_users").append('<span>'+'{$REGISTERINFO}'+'</span>');
                    }
                </script>
            {/if}
{*            {include file='ListViewBtnAndSeach.tpl'}*}

            {*zxm 20221202老的代码挪到了这里*}
            {*{include file='ListViewBtnAndSeachEntries.tpl'}*}
            <div class="clear"></div>
        </div>
        <div class="main_grid_box">
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div id="divCalendarShow" class="divCalendarShow" style="width:100%;" >
                    {if $VERSION_ACCOUNT eq 'shenglawei' && $MODULE eq 'CustomForm01' && $customform01_type eq  'calendar'}
                        {include file="CustomForm01Calendar.tpl"}
                    {/if}
                </div>
                <div class="cont_wrap clear_float">
                    {if $isShowMap eq 'yes'}
                    <div id="divMapShow" class="divMapShow" style="width:100%; display:none;" >
                        <div class="divMapLeft" id="divMapLeft">

                        </div>
                        <div class="divMapRight">
                            <div id="map_div" name="map_div" style="width:100%;">

                            </div>
                        </div>
                    </div>
                    {/if}
                    {assign var=operating value='OPERATING'|@getFixedLabel}
                    {assign var=listtable_ui_type value=484|@getSys_deploy}
                    <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
                        {if $MODULE eq 'ShoppingMall' }
                            {*zxm @date:2024/10/18 @reason: 订货商城 列表页面显示*}
                            {include file="ShoppingMall/ListView.tpl"}
                        {else}
                        <div style=" visibility: visible; top: 194px;overflow: hidden;" id="resize_header_table_divid" name="resize_header_table_divid">
                            <div  style="float:left; padding-right:20px">
                                <table class="listEntries {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}  {if $TableLineHightSet=='compact'}listEntriesCompact{elseif $TableLineHightSet=='spacious' }listEntriesSpacious{/if}" id="resize_header_tableid" name="resize_header_tableid" border="0" cellspacing="0" cellpadding="0" style="width:{$TOTALWIDTH}px">
                                    <tr>
                                        {if $LIST_NOCHECKBOX neq 'no'}
                                            <th class="firstChild" style="text-align:center;width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'>
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
                            {*wym 231225 BUG0077447 行高保存后没有刷新，要小圈转完了等2s才会刷新（改成了tpl加载对应class）*}
                            <table class="listEntries {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}  {if $TableLineHightSet=='compact'}marT-45 listEntriesCompact{elseif $TableLineHightSet=='spacious' }marT-58 listEntriesSpacious{else}marT-53{/if}" id="resize_content_tableid" name="resize_content_tableid" style="width:{$TOTALWIDTH}px;" border="0" cellspacing="0" cellpadding="0" >
                                <tbody>
                                <tr name="tr_header">
                                    {if $LIST_NOCHECKBOX neq 'no'}
                                        <th class="firstChild" style="width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'></th>
                                    {/if}
                                    {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                        {if $header neq $operating || $LIST_NOOPERATING eq 'no'}
                                            <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$HEADERNAME.module[$i]}' headername="{$HEADERNAME.fieldname[$i]}">{$header}</th>
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
                                    {$DEAILHTML}
                                    {if $fromtype!='salesfunnel'}
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
                                    {/if}
                                </tbody>
                            </table>
                        </div>
                        {/if}
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
<!--同步库存，弹出框-->
<div id="synchronousInventoryDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
	<div class="D_pop_tit">
    	<strong class="D_ptita">{'DATAEXCHANGE'|@getFixedLabel}——{'SYNCHRONOUSINVENTORY'|@getFixedLabel}</strong>
        <a class="D_ptitc" href="javascript:hideOptions('synchronousInventoryDiv');puyoungJS_DialogBox.unblock();">
            <img title="关闭" alt="关闭" src="{$IMAGEURL}themes/icon/pop_close.png?v={$GLOBALMINVERSION}" class="D_ptitcimg">
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

{if $MODULE eq 'Documents'}
    {include file='modules/Documents/Doc_listview.tpl'}
{/if}

<!--基本查询-->
{include file="basicSearch.tpl"}
<div id="SubmitApprove" class="D_pop_box LdPopWidth500px" style="display:none;"></div>

<script id="listajaxentries">
	//var popupobj=CrmPopup.getPopupObj("last");
    var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    popupobj.url='{$LISTPAGEURL}';
    popupobj.page_list_query='{$Encrypt_page_list_query}';
    popupobj.list_query='{$Encrypt_list_query}';
    var module = '{$MODULE}';
	/*标签*/
	if(Listpagepopupobj != undefined && Listpagepopupobj.fields != undefined){
		ld.each(Listpagepopupobj.fields,function(ikey,tag){
			if(tag.uitype == 301){
				ld('#module_tag_list_search').show();
				return false;
			}
		});
	}
    if ('{$VERSION_ACCOUNT}' == 'shenglawei' && '{$MODULE}' == 'CustomForm01' && '{$customform01_type}' =='calendar'){

				var CustomForm01_calendar_obj = new CustomForm01_calendar();
                CustomForm01_calendar_obj.setclickDate('{$clickDate}');
				CustomForm01_calendar_obj.intStart();

                CustomForm01_calendar_obj.setDateCount(JSON.parse('{$daterowcount}'))
                CustomForm01_calendar_obj.setColor(JSON.parse('{$shenglaweiColor}'));
				ld('#hdScrolllistentries_yy').hide();
				ld('#tip_calendar').hide();
				ld('#divCalendarShow').show();
				ld('#tip_list_calendar').show();
                setContentHeight('{$MODULE}');//计算内容高度
    }
    popupobj.list_TreeWhere = '{$Encrypt_TreeWhere}';
    //duan  20240801 BUG20240731-02 记录高级查询的Json内容，在切换页签的时候重新生成高级查询条件
    var CRITERIA_GROUPS_JSON = '{$CRITERIA_GROUPS_JSON}';
    if(!empty(CRITERIA_GROUPS_JSON)){
        popupobj.list_criterid_groups_json = CRITERIA_GROUPS_JSON;
    }

    {literal}
    // wym 230731 BUG0070334 圣拉维-档期预约-点进日历视图后，列表按钮没有浮显了
    tooltip('.tip-items-list', {transition: true, time: 200});
    {/literal}
    // ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
    if (typeof structureTreeobj == "undefined" || structureTreeobj == undefined){
        var structureTreeobj=new structureTree();
    }
    structureTreeobj.getModuleTreeCount(popupobj);

    //hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
    var tabname = '{$TABNAME}';
    var tmp_pagedata = {
        'currentpage': {$STARTPAGE},
        'count': {$LISTVIEWRECORDCOUNT},
        'pagecount': {$LISTVIEWPAGECOUNT},
        'language': language,
        'changepage': function (pagenum){
            if(module == 'Documents'){
                getListViewEntries_js(module,'parenttab='+tabname+'&start='+pagenum+'&folderid=index');
            }else {
                getListViewEntries_js(module,'parenttab='+tabname+'s&start='+pagenum);
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
    else{
        if(last_crmpopup.type == 'none'){
            tmp_divid = CrmPopup.getlastPopupObjByType('listpage').divid;
        }else{
            tmp_divid = popupobj.divid;
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