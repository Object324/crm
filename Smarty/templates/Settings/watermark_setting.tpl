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
<!--
edit:杨彬阳
2022.12.10
-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/watermark_setting.js?v={$GLOBALMINVERSION}"></script>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
          {'watermark_setting'|@getFixedLabel}<font>（{'watermark_display_content'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="watermark_setting.edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
          <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr> 
              <th colspan="2">
                {'watermark_setting'|@getFixedLabel}
              </th>
            </tr>
            <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this)); " >
              <td width="20%" name="WHETHERTOENABLE" value="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</td>
              <td width="80%">
                {if $presence eq 'yes'}  <!--$presence变量从$smarty->assign("presence",$presence )传过来的-->
                <input type="checkbox"  class="second_switch" onclick="change_tablefield_presence(this,1,'watermark_presence')" checked="" />
            {else}
                <input type="checkbox"   class="second_switch" onclick="change_tablefield_presence(this,1,'watermark_presence')"/>
            {/if}
          </td>
            </tr>
            <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">      
          <td width="20%"> {'watermark_display'|@getFixedLabel}</td>
              <td width="48" height="48" border="0">
                <span id="watermark_remark" class="grid-view-name dinline-block"> {$watermark_display_comments} </span>
              </td>
            </tr>
           
          </table>
        </div>
    </div>
</div>
</form>