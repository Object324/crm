{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ***********************************************************************************+*}
<!--修改编码格式:统一编码：UTF-8-->
<div id="status" style="position: absolute; display: none; left: 850px; top: 95px; height: 27px; white-space: nowrap;">
<img src="themes/softed/images/status.gif">
</div>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/inputAddSubNumberBox.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/SystemSet.js?v={$GLOBALMINVERSION}"></script>
<div class="main_grid_top">
	<input type="hidden" name="max_deploytype" value="{$MAX_DEPLOYTYPE}" id="max_deploytype" />
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_SYSTEM_SET'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="SystemSet.save()" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
	<input type="hidden" id="allsystemcount" value="{$ALLSYSTEMROOTCOUNT}" />
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
          <div class="D_Tab_div tabHieght fixedHead bgwhite">
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td valign="top" class="L" style="border-bottom: 1px solid #ddd;">
                  <ul id="one_li">
					{foreach key=key item=item from=$ALLSYSTEMROOT}
						<li onclick="SystemSet.showSystem_parameters(this,{$item})" class="showSystem_parameters">
							{if $item eq 1}
								<a style="font-size:13px;">{'SYSTEMPARAMETERS'|@getFixedLabel}</a>
							{elseif $item eq 2}
								<a style="font-size:13px;">{'Businessparameters'|@getFixedLabel}</a>
							{*{elseif $item eq 3}
								<a style="font-size:13px;">{'THEAPPROVALPARAMENTERS'|@getFixedLabel}</a>*}
							{elseif $item eq 3}
								<a style="font-size:13px;">{'REMINDERPARAMENERS'|@getFixedLabel}</a>
							{elseif $item eq 4 && $VersionNo neq 55 &&$VersionNo neq 56 && $VersionNo neq 57 && $VersionNo neq 58}{*BUG0069537 ls 20230810 客户001隐藏库存参数*}
								<a style="font-size:13px;">{'THEINVENTORYPARAMENTERS'|@getFixedLabel}</a>
							{elseif $item eq 5}
								<a style="font-size:13px;">{'THEPRINTPARAMENTERS'|@getFixedLabel}</a>
							{elseif $item eq 6}
								<a style="font-size:13px;">{'THEINTERFACEPARAMENTERS'|@getFixedLabel}</a>
							{elseif $item eq 7}
								<a style="font-size:13px;">{'THEAPPPARAMENTERS'|@getFixedLabel}</a>
							{/if}
						</li>
					{/foreach}
                    {if $WARNING}
                    <li>
                      <div style='background-color: #FFFABF; padding: 2px; margin: 0 0 2px 0; border: 1px solid yellow'>
                        <b style='color: red'>{$WARNING}</b>
                      </div>
                    </li>
                    {/if}
                  </ul>
                </td>
              </tr>
            </table>
          </div>
          <div class="clear"></div>
          <!--参数页面-->
          {include file="SystemSetEntries.tpl"}
        </div>
    </div>
</div>


{literal}
<script type='text/javascript'>

</script>
{/literal}