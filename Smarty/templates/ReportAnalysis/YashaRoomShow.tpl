<!DOCTYPE html>
<html style="overflow-y: hidden;">
<head>
<script>
var global_js_url='{$JSURL}';
var global_commonurl='{$CRMCOMMONURL}';
var global_js_version='{$GLOBALMINVERSION}';
</script>
<link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/leftmenu.css?v={$GLOBALMINVERSION}">
<link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/common.css?v={$GLOBALMINVERSION}">
<link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/Control.css?v={$GLOBALMINVERSION}">
<style type="text/css">@import url("{$CSSURL}themes/{$THEME}/style.css?v={$GLOBALMINVERSION}");</style>
<link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/common-23.css?v={$GLOBALMINVERSION}">
<link rel="stylesheet" href="dataCache/tabdatas/skinset.css?v={$smarty.now}" type="text/css" />
<link rel="stylesheet" type="text/css" href="{$CRMCOMMONURL}crmcommon/css/treeview/jquery.treeview.css?v={$GLOBALMINVERSION}" /><!--选部门选用户-->
<style>
    .yasha-content{
        height:100%;
    }
    .yasha-table{
        table-layout: fixed;
        height:100%;
    }
    .yasha-table th{
        text-align: center !important;
    }
    .yasha-more-shadow {
        box-shadow: -2px 0 5px -2px rgba(0, 0, 0, 0.2),  2px 0 5px -2px rgba(0, 0, 0, 0.2), 0 -2px 5px -2px rgba(0, 0, 0, 0.2), 0 2px 5px -2px rgba(0, 0, 0, 0.2);
    }
    .yasha-droplist {
        visibility: hidden;
        width: 120px;
        background-color: #fff;
        color: #fff;
        text-align: center;
        border-radius: 6px;
        padding: 5px 0;
        position: absolute;
        z-index: 110;
    }
    .yasha-droplist  .shaya-more-li {
        padding: 0 4px 0 6px;
    }
    .yasha-droplist  .shaya-more-li:hover {
         background-color: #E4F0FF;
    }
    .yasha-droplist  .shaya-more-li .shaya-btn-more {
        background-repeat: no-repeat;
        background-size: 16px;
        background-position: left center;
        display: inline-block;
        margin: 0 4px;
        border-radius: 3px;
        vertical-align: middle;
        text-decoration: none;
        overflow: hidden;
        text-align: left;
        font-size: 12px;
        width: 100%;
        height: 42px;
        line-height: 42px;
        color: #333;
    }
    .yasha-droplist  .shaya-more-li .shaya-btn-more:hover {
        background-color: #E4F0FF;
    }
    .yasha-legend{
        height:50px;
        width:140px;
    }
</style>
</head>
<body style="height: 100%;width: 100%;overflow: hidden;">
<div class="yasha-content" id="yasha_content">
    <table class="yasha-table" border="0" cellspacing="0" cellpadding="0" width="100%" align="center">
        <tbody>
        <tr>
            <td valign="top" class="user-left-td" style="width:200px;">
                <div id="loudong_list" style="overflow-y: auto;">
                    <div class="selectPop">
                        <div style="width:100%;">
                            <ul class="filetree" id="loudong_list_content">
                                {foreach item=loupaninfo key=i from=$loupan_list}
                                    <li style="padding-top:20px;" tag="loupan_name">
                                        <span class="file" status="open" style="position: sticky;top:0;display:block">
                                            <label>{$loupaninfo.loupan_name}
                                            </label>
                                        </span>
                                        <ul>
                                            {foreach item=buildinginfo key=j from=$loupaninfo['list']}
                                                <li tag="builing_num" data-loupan="{$loupaninfo.loupan_name}" data-buildingnum="{$buildinginfo.building_num}" style="display: flex;justify-content: space-between;border-bottom: #fff;{if $loupaninfo.loupan_name==$defaultlopan&&$buildinginfo.building_num==$defaultbuildingnum}background-color:#E4F0FF;{/if}">
                                                    <span class="user">
                                                         <label>
                                                             <span>{$buildinginfo.building_num}</span>
                                                        </label>
                                                    </span>
                                                </li>
                                            {/foreach}
                                        </ul>
                                    </li>
                                {/foreach}
                            </ul>
                        </div>
                    </div>
                </div>
            </td>
            <td id="expandtd" class="tip-items-list" data-tip="{'COLLAPSE'|@getFixedLabel}" data-direction="right" data-type="position" style="width:10px;max-width: 10px;">
                <span class="tree-closeopen tree-close"></span>
            </td>
            <td valign="top">
                <div id="roomlist_content">

                </div>
            </td>
        </tr>
        </tbody>
    </table>
</div>
</body>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
<script type="text/javascript" language="JavaScript">
    var ld = $;
</script>
<script type='text/javascript' src='{$JSURL}include/js/cls_encryptyurl.js?v={$GLOBALMINVERSION}'></script>
<script type='text/javascript' src='{$JSURL}include/js/crypto-js.min.js?v={$GLOBALMINVERSION}'></script>
<script type="text/javascript" src="{$JSURL}include/language/zh.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js?v={$GLOBALMINVERSION}"></script><!--公共-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ldAjax.js?v={$GLOBALMINVERSION}"></script><!--公共-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/DetailViewTab.js?v={$GLOBALMINVERSION}"></script><!--公共-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js?v={$GLOBALMINVERSION}"></script><!--公共-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js?v={$GLOBALMINVERSION}"></script><!--公共-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script><!--公共-->
<script type="text/javascript" src="{$CRMCOMMONURL}include/js/modules/ReportAnalysis/YashaRoomShow.js"></script>
<script>
    yashaInit();
    function yashaInit(){
        var obj = new YashaRoomShow();
        obj.setEvent();
        obj.setTerminal('pc');
        obj.showRoom('{$defaultlopan}','{$defaultbuildingnum}');
    }
</script>
</html>
