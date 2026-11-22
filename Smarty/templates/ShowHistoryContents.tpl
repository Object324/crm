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
<div id="login_history_cont" style="overflow: auto">
    <table class="settingTable fir-center" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr style="position: sticky; top:0px;z-index:1;">
            {assign var="k" value=0}
            <th>#</th>
            {foreach item=header from=$LIST_HEADER}
                {assign var="p" value=$k++}
                <th {if $p eq 9}width="12%"{elseif $p eq 0 || $p eq 3||  $p eq 4}width="13%" {else}width="11%"{/if}><span title="{$header}">{$header}</span></th>
            {/foreach}

        </tr>
        {assign var="i" value=0}
        {foreach item=entity key=entity_id from=$LIST_ENTRIES}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
            <td>{$i}</td>
            {foreach item=data from=$entity}
                {if $data neq "0000-00-00 00:00:00"}
                    <td><span title="{$data}">{$data}</span></td>
                {else}
                    <td>---</td>
                {/if}
            {/foreach}
            </tr>
            {foreachelse}
            <tr>
                <td colspan="11" height="100" align="center" style="height:0px;padding: 0;">
                    {* <div class="warningTableContent" style="z-index:600;">
                        <div class="wtc_img"><img src="themes/icon2023/ld-no-records.png"></div>
                        <div class="wtc_content">{'NOTFOUNDANYRECORD'|@getFixedLabel}</div>
                        <div class="wtc_content"></div>
                    </div> *}
                    {include file="NoRecords.tpl"}
                </td>
            </tr>
        {/foreach}
    </table>

</div>
<div name="listviewpagination" id="listviewpagination" style="display: flex;align-items: center;height: 50px;position: fixed;bottom: 0px;right: 20px;">
</div>


<script>
    CrmPopup.global_listPopupObj=[];
    var popupobj=new Object();
    popupobj.divid="SettingRightContent";
    CrmPopup.global_listPopupObj.push(popupobj);
    popupobj.CancelEvent=function(){
        return false;
    }
    AjaxJSPage('ld_Pagination','include/js/component/ld_Pagination.js');
    var tmp_pagedata = {
        'currentpage': {$STARTPAGE},
        'count': {$LISTVIEWRECORDCOUNT},
        'pagecount': {$LISTVIEWPAGECOUNT},
        'language': language,
        'changepage': function (pagenum){
            geShowHistorySearchEntries_js('Users','parenttab=Settings&start='+pagenum+'');;
        },
        'pagepernumarr': {$LISTVIEWPERPAGENUM},
        'changepagecount': function (evt){
            var pagecount=evt.NavBarItem.value;
            geShowHistorySearchEntries_js('Users','parenttab=Settings&pagecount='+pagecount+'');;
        }
    }
    var popupobj = CrmPopup.getPopupObj('last');
    var listviewpagination = ld('#'+popupobj.divid+' #listviewpagination');
    var listviewpaginationobj = ld_Pagination.showPagination(listviewpagination.get(0), tmp_pagedata);
    popupobj.listviewpaginationobj = listviewpaginationobj;

    function setHistoryListHeight(){
        var topheight=55;//快速查找所在div的高度55
        var con_mt_height=8;//头部和内容中间margin距离10
        var uitabsheight=50;//导航高度
        var main_grid_top=60;//main_grid_top高度
        var listviewpagination_height = ld('#'+popupobj.divid+' #listviewpagination').height();
        var table_height = ld(window).height()-topheight-con_mt_height-uitabsheight-main_grid_top-listviewpagination_height;
        console.log(table_height);
        ld('#'+popupobj.divid+' #login_history_cont').css('height',table_height);
    }
    setHistoryListHeight();


</script>


