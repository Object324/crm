<!DOCTYPE html>
<html style="overflow-y: hidden;">
<head title="">
    <script>
        var CURRENT_USER_ID=1;
        var language='{$language}';
        if(language='zh')language='zh-cn';
        var account_version ='';
        var wx_userid='';
        var appusertoken='';
        var global_js_url='{$JSURL}';
        var global_commonurl='{$CRMCOMMONURL}';
        var global_js_version='{$GLOBALMINVERSION}';
        var iskehu001='no';
        var global_js_sync_id=[];
    </script>
    <link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/leftmenu.css?v={$GLOBALMINVERSION}">
    <link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/common.css?v={$GLOBALMINVERSION}">
    <link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/Control.css?v={$GLOBALMINVERSION}">
    <style type="text/css">@import url("{$CSSURL}themes/{$THEME}/style.css?v={$GLOBALMINVERSION}");</style>
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2.css?v={$GLOBALMINVERSION}" type="text/css" /><!--多选框-->
    <link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/common-23.css?v={$GLOBALMINVERSION}">
    <link rel="stylesheet" type="text/css" href="{$CRMCOMMONURL}crmcommon/css/treeview/jquery.treeview.css?v={$GLOBALMINVERSION}" /><!--选部门选用户-->
    <style>

    </style>
    <link rel="stylesheet" href="{$CSSURL}themes/softed/jquery.orgchart.css" type="text/css"/>
</head>
<body style="height: 100%;width: 100%;overflow: hidden;">
<div class="ld-gzYinhe-content" id="ld_gzyinhe_content">
    {*筛选:部门筛选 人员筛选 时间筛选 品牌筛选(字段的下拉框)*}
    <div id="searchList" style="margin:10px;background-color: #transparent;padding: 10px;box-shadow: 0px 1px 2px 2px rgb(0 0 0 / 10%);">
        <table border="0" cellspacing="0" cellpadding="0" width="100%" style="table-layout: fixed;padding-right: 80px;" id="conditionColumnList">
            <thead>
            <tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red"></font>选部门
                </td>
                <td class="ld-form-item-content">
                    {assign var=usefldlabel value='选部门'}
                    {assign var=fldname value='selectbumen'}
                    {assign var=MODULE value='SalesOrder'}
                    {assign var=secondvalue value=$bumenids}
                    {assign var=fldvalue value=$bumennames}

                    <div id="{$fldname}_name" class="ld-input-inner-div ld-input-inner-add" name="{$fldname}_name" readonly="" style="text-overflow: ellipsis;overflow: hidden;">{$fldvalue}</div>
                    <a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","sqlvar_{$fldname}","Group","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","private")' draggable="false">+</a>
                    <input type="hidden" value="{$secondvalue}" id="sqlvar_{$fldname}" name="sqlvar_{$fldname}">

                    {*<div class="commonDetailedTextBox gwidth70 bgwhite lfloat" id="{$fldname}_name" name="{$fldname}_name" style="padding-left: 8px;overflow: hidden;text-overflow: ellipsis;">{$fldvalue}</div>
                    <a class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","sqlvar_{$fldname}","Group","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","private")'></a>
                    <input type="hidden" value="{$secondvalue}" id="sqlvar_{$fldname}" name="sqlvar_{$fldname}" />*}
                </td>
                <td  class="ld-form-item-label">
                    <font color="red"></font>选人员
                </td>
                <td class="ld-form-item-content">
                    {assign var=usefldlabel value='选人员'}
                    {assign var=fldname value='selectuser'}
                    {assign var=MODULE value='SalesOrder'}
                    {assign var=secondvalue value=$userids}
                    {assign var=fldvalue value=$usernames}
                    <div id="{$fldname}_name" class="ld-input-inner-div ld-input-inner-add" name="{$fldname}_name" readonly="" style="text-overflow: ellipsis;overflow: hidden;">{$fldvalue}</div>
                    <a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","sqlvar_{$fldname}","Users","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","private")' draggable="false">+</a>
                    <input type="hidden" value="{$secondvalue}" id="sqlvar_{$fldname}" name="sqlvar_{$fldname}">

                    {*<div class="commonDetailedTextBox gwidth70 bgwhite lfloat" id="{$fldname}_name" name="{$fldname}_name" style="padding-left: 8px;overflow: hidden;text-overflow: ellipsis;">{$fldvalue}</div>
                    <a class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","sqlvar_{$fldname}","User","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","private")'></a>
                    <input type="hidden" value="{$secondvalue}" id="sqlvar_{$fldname}" name="sqlvar_{$fldname}" />*}
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red"></font>目标年度
                </td>
                <td class="ld-form-item-content">
                    <select class="ld-select-inner" id="sqlvar_targetyear">
                        {foreach $targetYearList as $i=>$targetyearinfo}
                            <option {if $i eq 0}selected{/if} value="{$targetyearinfo['targetyear']}" data-start="{$targetyearinfo['startdate']}" data-end="{$targetyearinfo['enddate']}" data-pinpai="{$targetyearinfo['pinpai']}">{$targetyearinfo['targetyear']}</option>
                        {/foreach}
                    </select>
                </td>
                <td class="ld-form-item-label">
                    <font color="red"></font>日期(起)
                </td>
                <td class="ld-form-item-content" id="sqlvar_startdate_td">
                    <input readonly type="text" class="Wdate ld-input-inner" name="sqlvar_startdate" autocomplete="off" value="{$startdate}" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',minDate:'{$startdate}',maxDate:'{$enddate}'{rdelim})">
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red"></font>选品牌
                </td>
                <td class="ld-form-item-content">
                    <select multiple class="ld-select-inner" id="sqlvar_pinpai" name="sqlvar_pinpai">
                        {foreach $cf_7872 as $pinpai}
                            {if $pinpai!=''}
                        <option selected value="{$pinpai}">{$pinpai}</option>
                            {/if}
                        {/foreach}
                    </select>
                </td>
                <td class="ld-form-item-label">
                    <font color="red"></font>日期(止)
                </td>
                <td class="ld-form-item-content" id="sqlvar_enddate_td">
                    <input readonly type="text" class="Wdate ld-input-inner" name="sqlvar_enddate" autocomplete="off" value="{$enddate}" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',minDate:'{$startdate}',maxDate:'{$enddate}'{rdelim})">
                </td>

            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <div class="ld-button ld-button-primary" tag="search">查询</div>
                </td>
                <td class="ld-form-item-content">
                </td>
                <td  class="ld-form-item-label">
                </td>
                <td class="ld-form-item-content">
                </td>
            </tr>
            </thead>
        </table>
    </div>
    <div id="ld_gzyinhe_reportcontent">

    </div>
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
<script language="javascript" type="text/javascript" src="{$JSURL}crmcommon/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/menucommon.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/MsgPopup.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/select2.min.js?v={$GLOBALMINVERSION}"></script><!--多选框-->
<script type="text/javascript" src="{$JSURL}include/js/modules/SalesGoal/jquery.orgchart.d.js?v={$GLOBALMINVERSION}"></script><!--多选框-->
<script type="text/javascript" src="{$JSURL}include/js/select2.min.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/ReportAnalysis/gzYinheSalesGoalReport.js"></script>
<script>
    var Listpagepopupobj=new CrmPopup();
    Listpagepopupobj.divid='ld_gzyinhe_content';
    Listpagepopupobj.type="gzYinheSalesGoalReport";
    Listpagepopupobj.refreshpage='no';
    Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
    Listpagepopupobj.module='SalesOrder';
    CrmPopup.global_listPopupObj.push(Listpagepopupobj);
    gzYinheInit();
    function gzYinheInit(){
        var obj = new gzYinheSalesGoalReport();
        obj.setPopupObj(Listpagepopupobj,Listpagepopupobj.divid);
        obj.setEvent();
        obj.showList();
    }
    //穿透
    function openUserCompleteUrl111(jqueryobj){
        var popupJqObj = ld('#'+Listpagepopupobj.divid);
        var record_str = jqueryobj.attr('record_str');//用户ID
        var pinpai = jqueryobj.data('pinpai');
        var params = {};
        params['pinpai'] = pinpai;
        params['selectuserid'] = record_str;
        params['sqlvar_selectbumen'] = popupJqObj.find('#sqlvar_selectbumen').val();
        params['sqlvar_selectuser'] = popupJqObj.find('#sqlvar_selectuser').val();
        params['sqlvar_startdate'] = popupJqObj.find('[name=sqlvar_startdate]').val();
        params['sqlvar_startend'] = popupJqObj.find('[name=sqlvar_startend]').val();

        var ChartChuantouObj = new HomeStuffChuantou();
        ChartChuantouObj.YinheSalesGoalChuantou(params);
    }
    function openUserCompleteUrl(jqueryobj){
        var popupJqObj = ld('#'+Listpagepopupobj.divid);
        var sqlvar_startdate = popupJqObj.find('[name=sqlvar_startdate]').val();
        var sqlvar_startend = popupJqObj.find('[name=sqlvar_startend]').val();

        let record_str = jqueryobj.attr('record_str'),
            search_date_value = sqlvar_startdate+'~'+sqlvar_startend,
            targetid=jqueryobj.attr('targetid'),
            pinpai=jqueryobj.data('pinpai'),
            ajaxurl='index.php?module=SalesOrder&action=SalesOrderAjax&file=gzYinheSalesGoalReport&function_name=setModuleSearchNew',
            openurl='index.php?pageto_action=index&pageto_module=',
            modules=''
        ;
        //zkt 20220424 【ID1002776】【销售目标的超链接只跳转到销售合同模块】
        var modulearr = modules.split(',');
        var module = '';
        var urlarr = [];
        var urllength = 0;
        ldAjaxNoProgress(ajaxurl+"&targetid="+targetid+"&record_str="+record_str+"&search_date_value="+search_date_value+"&pinpai="+pinpai,'',function(data) {
            if(data.code == 1)
            {
                var addurl=encodeURIComponent("&query_session=1");
                window.open(openurl+'SalesOrder'+'&page_addurl='+addurl);
            }
        });
    }


</script>
</html>
