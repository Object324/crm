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
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js?v={$GLOBALMINVERSION}" type="text/javascript"></script>
<!-- <script src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/scriptaculous.js" type="text/javascript"></script> -->
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/general.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/dtlviewajax.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="ListLoginHistory" id="form" onsubmit="puyoungJS_DialogBox.block();">
<input type='hidden' name='module' value='Users'/>
<input type='hidden' name='action' value='ListLoginHistory'/>
<input type='hidden' name='record' id='record' value="{$ID}"/>
<input type='hidden' name='parenttab' value='Settings'/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_LOGIN_HISTORY_DETAILS'|@getFixedLabel}<font>（{'LBL_LOGIN_HISTORY_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
    </div>
</div>
<div class="main_grid_set select-input ld-wordwrap-listcontent" style="height: 50px;align-items: center;display: flex">
    <div style="display: flex;align-items: center;line-height: 30px;" class="">
        <label class="">{'SELECTUSER1'|@getFixedLabel}</label>
        <div class="ld-form-item-content" style="width: 160px;">
            {assign var=fldname value='user_list'}
            <select id="user_list" name="user_list" onchange="get_new_loginlog();" style="display:none" value="">
                <option value="none" selected="true">{'ALL'|@getFixedLabel}</option>
                {foreach key=User_id item=User_value from=$USERLIST}
                    {foreach key=User_name item=User_name_value from=$User_value}
                        <option value="{$User_id}" {if $LASt_SEARCH_USER_VALUE == $User_id}selected{/if}>{$User_name}</option>
                    {/foreach}
                {/foreach}
            </select>
        </div>
        <label style="margin-left: 100px !important;">{'LOGINMODE'|@getFixedLabel}</label>
        <div class="ld-form-item-content" style="width: 160px;">
            {*//editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/20 17:19*}
            {assign var=fldname value='login_type'}
            <select id="login_type" name="login_type" onchange="get_new_loginlog()"  class="detailedViewSelect bgwhite" style="display:none">
                {* <option value="all">{'ALL'|@getFixedLabel}</option> *}
                {foreach item=reallabel key=realvalue from=$LOGINMETHOD}
                    <option value="{$realvalue}" {if $LASt_LOGIN_TYPE_VALUE == $realvalue}selected{/if}>{$reallabel}</option>
                {/foreach}
            </select>
        </div>
    </div>
</div>

<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">

        </div>
        <div id="div_loginhistory_select" class="cont_wrap clear_float">
            {include file='ShowHistoryContents.tpl'}
        </div>
    </div>
</div>
</form>

<script>
    /*editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/20 17:19*/
function geShowHistorySearchEntries_js(module,url)
{ldelim}
    get_new_loginlog(url);return false;
{rdelim}
function getListViewEntries_js(module,url)
{ldelim}
    get_new_loginlog(url);return false;
{rdelim}

    {*function ldSelectPageNum(obj,pagenum,totalrows){ldelim}*}
    {*    var divobj = ld(obj).parent().parent().parent();*}
    {*    divobj.find('#pagenum').val(pagenum);*}
    {*    divobj.find('#pagenum_show').html(pagenum+'/'+totalrows+'&nbsp;&nbsp;<b class="down"></b><b style="visibility: hidden">'+totalrows+'</b>');*}
    {*    divobj.find('#pagenum').change();*}
    {*{rdelim}*}
    
    // 可搜索下拉框
    var popupobj = CrmPopup.getPopupObj('last'); 
    console.log('popupobj: ', popupobj);
    var selectobj_field = ld("#"+popupobj.divid).find("select[name=user_list]");// 选择单选用户字段
    var cls_resetComboxHtmlobj=new cls_resetComboxHtml("user_list");
    cls_resetComboxHtmlobj.setComboxObjHtml();
    var selectwidth = Tools.getParentobjByChild(selectobj_field,'div').width();
    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_field,selectwidth+10);
    var selectobj_field = ld("#"+popupobj.divid).find("select[name=login_type]");// 登录方式
    var cls_resetComboxHtmlobj=new cls_resetComboxHtml("login_type");
    cls_resetComboxHtmlobj.setComboxObjHtml();
    var selectwidth = Tools.getParentobjByChild(selectobj_field,'div').width();
    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_field,selectwidth+10);
</script>