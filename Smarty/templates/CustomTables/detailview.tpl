<title>{$report_info['report_name']}</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link type="text/css" rel="stylesheet" href="{$CSSURL}themes/softed/CustomTable.css?v={$GLOBALMINVERSION}">
<script type="text/javascript" language="JavaScript">
    var frommobile = '{$frommobile}';
    var homefile = '{$homefile}';
</script>
{if $frommobile=='yes'}
    {*//移动端  zxm20221019*}
    <link href="{$CSSURL}themes/softed/common.css" rel="stylesheet">
    <link href="{$CSSURL}themes/softed/style.css" rel="stylesheet">
    <link href="{$CSSURL}themes/softed/leftmenu.css" rel="stylesheet">
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2.css" type="text/css" /><!--多选框-->
    <script type="text/javascript" src="{$JSURL}include/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/jquery/jquery-migrate.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/language/zh.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/Sortable.min.js"></script>
    <script type="text/javascript" language="JavaScript">
        var ld = $;
        var language='{$LANGUAGETYPE}';
        var CURRENT_USER_ID=1;
        var wx_userid='{$wx_userid}';
        var appusertoken='{$appusertoken}';
        var global_js_url='{$JSURL}';
        var global_commonurl='{$CRMCOMMONURL}';
        var global_js_version='{$GLOBALMINVERSION}';
        var iskehu001='{$iskehu001}';
        var global_js_sync_id=[];
    </script>

    <script type='text/javascript' src='{$JSURL}include/js/cls_encryptyurl.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/crypto-js.min.js?v={$GLOBALMINVERSION}'></script>
    <script type="text/javascript" language="javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/echarts.min.js"></script><!--报表-->
    <script type="text/javascript" src="{$JSURL}include/js/general.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/menucommon.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldAjaxMobile.js"></script><!--移动端的ajax请求-->
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/select2.min.js?v={$GLOBALMINVERSION}"></script><!--多选框-->
    <script language="javascript" type="text/javascript" src="{$JSURL}crmcommon/js/My97DatePicker/WdatePicker.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/CustomTables/CustomTables.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/CustomTables/CustomTablesResize.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/freezecolumns.js"></script>
{else}
    <script type="text/javascript" src="include/js/modules/CustomTables/CustomTablesResize.js"></script>
    <script type="text/javascript" src="include/js/freezecolumns.js"></script>
{/if}
<div class="customtable-content" id="customtable_content">
    <form id="chartInfoForm">
    <div style="display:block;min-height:45px" name='dvcondition'>
        <div style="display: flex;justify-content: flex-end;width:80%;margin:5px auto;">
            <label>
                {'ShowFilterCriteria'|@getFixedLabel}
                <input type="checkbox" id="toggleSearch" class="second_switch" {if $report_info['isshow_search']=='yes'}checked=""{/if}>
            </label>
        </div>

        <div id="searchList" style="{if $report_info['isshow_search']=='no'}display:none;{/if} {if $frommobile=='yes'}width:calc(100% - 20px);{else}width:80%;{/if}margin:0 auto;background-color: #transparent;padding: 10px;box-shadow: 0px 1px 2px 2px rgb(0 0 0 / 10%);">
            <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed" id="conditionColumnList">
                <thead>
                <tr tag="">
                    <td align="right" colspan="5" style="border-bottom: none;">
                        <a title="{'NEWCOMBINATION'|@getFixedLabel}" class="pg-btn-blue dinline-block rfloat" data-groupid="1" tag="addgroupcondition">
                            <span>{'NEWCOMBINATION'|@getFixedLabel}</span>
                        </a>
                        <a style="margin-right:10px;"  title="{'CLEAR'|@getFixedLabel}" class="pg-btn-blue dinline-block rfloat" tag="clearAll">
                            <span>{'CLEAR'|@getFixedLabel}</span>
                        </a>
                    </td>
                </tr>
                <tr>
                    <td width="20%" align="center">{'Select_field'|@getFixedLabel}</td>
                    <td width="20%" align="center">{'SelectCon'|@getFixedLabel}</td>
                    <td width="40%" align="center">{'Keyword2'|@getFixedLabel}</td>
                    <td width="10%" align="center">{'SELECT'|@getFixedLabel}{'relationship'|@getFixedLabel}</td>
                    <td width="10%" align="center">{'Operation2'|@getFixedLabel}</td>
                </tr>
                </thead>
                <tbody id="conditionColumnBody">
                </tbody>
            </table>
            <div class="ld-flex-end">
                <a id="toSearch" class="pg-btn-blue dinline-block">{'SEARCHNEW'|@getFixedLabel}</a>
            </div>
        </div>

        <!--分页-->
        <div  style="display:block;height:42px;margin: 10px 0;">
            <div class="PageDiv0">
                <ul>
                    <li name='totaldescription'>{$RECORDLISTRANGMSG}</li>
                    <li><span id="goleft" class="no-icon-prevpage"></span></li>{*左边箭头*}
                    <li class="Input" id="pageoftotalpages">1/1</li>
                    <li><span id="goright" class="no-icon-nextpage"></span></li>
                    <li>{'GoTo'|@getFixedLabel}<input class="txtBox btn-radius-system pagenum_system search_bg marLR5" value="1" id="changePageCount" name='pagenum' type="text"/>{'PAGE'|@getFixedLabel}</li>
                    <li >
                        <select class="detailedViewTextBox" name="limitrecord" id="limitrecord">
                            <option value="20" {if $LimitRecord eq '20'} selected=""{/if}>20 {'ItemPage'|@getFixedLabel}</option>
                            <option value="50" {if $LimitRecord eq '50'} selected=""{/if}>50 {'ItemPage'|@getFixedLabel}</option>
                            <option value="100" {if $LimitRecord eq '100'} selected=""{/if}>100 {'ItemPage'|@getFixedLabel}</option>
                            <option value="200" {if $LimitRecord eq '200'} selected=""{/if}>200 {'ItemPage'|@getFixedLabel}</option>
                            <option value="500" {if $LimitRecord eq '500'} selected=""{/if}>500 {'ItemPage'|@getFixedLabel}</option>
                            <option value="1000" {if $LimitRecord eq '1000'} selected=""{/if}>1000 {'ItemPage'|@getFixedLabel}</option>
                            <option value="2000" {if $LimitRecord eq '2000'} selected=""{/if}>2000 {'ItemPage'|@getFixedLabel}</option>
                        </select>
                    </li>
                </ul>
            </div>
        </div>
    </div>
        {include file="CustomTables/detailtable.tpl"}
  </form>
</div>
{if $isAjax=="no"}
    <script>
        getScriptBackWithURL('include/js/modules/CustomTables/CustomTablesDetail.js',function() {
            var popupobj = CrmPopup.getPopupObj("last");
            if(popupobj){
                var divid = popupobj.divid;//链接模块
            }else{
                popupobj = new CrmPopup();
                var divid = "customtable_content";//链接模块
                popupobj.divid = divid;
                CrmPopup.global_listPopupObj.push(popupobj);
            }
            var CustomTablesDetailObj = new CustomTablesDetail();
            CustomTablesDetailObj.setPopupobj(popupobj);
            CustomTablesDetailObj.setDivid(divid);
            CustomTablesDetailObj.setReportId('{$report_info['report_id']}');
            CustomTablesDetailObj.init();
        });
    </script>
{/if}
<script type="text/javascript" src="{$JSURL}include/js/modules/CustomTables/CustomTablesColumns.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/CustomTables/CustomTablesConditions.js"></script>

