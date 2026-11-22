{*@edit:liushuai,2021-07-05,reason:【ID1001745】灵当语音盒，增加“自动拨号”功能*}
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{'AutoDial'|@getFixedLabel}</title>
    <link type="text/css" rel="stylesheet" href="themes/softed/leftmenu.css">
    <style type="text/css">@import url("themes/softed/style.css");</style>
    <style type="text/css">@import url("themes/softed/common.css");</style>
    <script src="{$JSURL}include/jquery/jquery.min.js"></script>
    <script language="JavaScript" type="text/javascript" src="include/language/{$LANUGAGETYPE}.js"></script>{*翻译*}
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/yiwei.js"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Users/AutoDial.js"></script>
    <script>
        var ld = $;
        var module = "{$module}";
        var cls_AutoDial = new AutoDial(module);

        var isAutoDial = 'yes';//是否为灵当语音盒自动拨号

        var CURRENT_USER_ID = '{$CURRENT_USER_ID}';
        var isCallErrorRemind = 'yes';

        //控制面板列表选中变色
        function settingListOnMouseOver(sel_id){
            var rows = "record_"+sel_id;
            document.getElementById(rows).className = "lvtColDataHover";
        }
        function settingListOnMouseOut(sel_id,type){
            var rows = "record_"+sel_id;
            if(type == 'On'){
                document.getElementById(rows).className = "lvtColDataBj";
            }else{
                document.getElementById(rows).className = "lvtColData";
            }
        }
    </script>
</head>
<body>
<div id="autodial" class="dvpopupsroll" style="max-height:95%;width: 100%;overflow-y:auto;">
    <div class="DivC">
        <div class="Top" style="width: 100%;">
            <div style="text-align:left;vertical-align:middle; margin: 10px 0 6px 20px;">
                <input name="button" id="actionstatus" class="E_pbtnok" value="" onclick="cls_AutoDial.changeActionStatus();" actionstatus="start" type="button">
            </div>
        </div>
        <div name="autodiallist">
            <input type="hidden" name="selectcount"  value="{$selectcount}"/>
            <input type="hidden" name="selectvalidcount"  value="{$selectvalidcount}"/>
            <input type="hidden" name="allids"  value="{$allids}"/>
            {include file="AutoDialListDetail.tpl"}
        </div>

    </div>
</div>
</body>
</html>
<script>
    ld("#actionstatus").val(arrJsPopLabel['StartDial']);
</script>