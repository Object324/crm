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
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_PHONESTEWARD_SET'|@getFixedLabel}{if $HelpHtml.PhoneSteward neq '' }{$HelpHtml.PhoneSteward}{/if}<font>（{'LBL_PHONESTEWARD_SET_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="EditPhoneSteward()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
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
                    <th colspan="2">{'LBL_PHONESTEWARD_SET'|@getFixedLabel}</th>
                </tr>
                <tr id="phonesteward_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'InterfaceType'|@getFixedLabel} </td>
                    <td width="80%">{$CALLCENTERVALUE}</td>
                </tr>
                <tr id="interfaceurl" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '苏州九维'}none{/if}">
                    <td>{$JIUWEIURLNAME}</td>
                    <td>{$JIUWEIURL}</td>
                </tr>
                <tr id="interfaceprefix" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '苏州九维'}none{/if}">
                    <td>{'CALLCENTERPREFIX'|@getFixedLabel}</td>{*gyq_25*}
                    <td>{$CALLCENTERPREFIX}</td>
                </tr>
                <tr id="interfaceurl_sopho" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '苏州思孚'}none{/if}">
                    <td>{$JIUWEIURLNAME_sopho}</td>
                    <td>{$JIUWEIURL_sopho}</td>
                </tr>
                <tr id="interfaceurl_sopho2" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '苏州思孚'}none{/if}">
                    <td>WebSocket{'COMPANYADDRESS'|@getTranstab}</td>
                    <td>{$JIUWEIURL_sopho2}</td>
                </tr>
                <tr id="interfaceurl_sopho3" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '汉天EC2'}none{/if}">
                    <td>{$HANTIANURLNAME}</td>
                    <td>{$HANTIANURL}</td>
                </tr>
                <tr id="interfaceurl_sopho4" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '汉天EC2'}none{/if}">
                    <td>{$HANTIANRELATENAME}</td>
                    <td>{if $HANTIANRELVALUE eq 1}{'NO'|getFixedLabel}{else}{'YES'|getFixedLabel}{/if}</td>
                </tr>
                {*// @edit:dong @date:2020/09/07 @reason:  天润融通旧*}
                <tr id="interface_enterpriseId_tianrun" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '天润融通旧'}none{/if}">
                    <td>{$TIANRUNENTERPRISEID}</td>
                    <td>{$TIANRUNENTERPRISEIDVALUE}</td>
                </tr>
                <tr id="interface_enterpriseId_tianrun" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '天润融通旧'}none{/if}">
                    <td>{$TIANRUNZHANGHAO}</td>
                    <td>{$TIANRUNZHANGHAOVALUE}</td>
                </tr>
                <tr id="interface_enterpriseId_tianrun" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '天润融通旧'}none{/if}">
                    <td>{$TIANRUNPASSWORD}</td>
                    <td>{if $TIANRUNPASSWORDVALUE}******{/if}</td>
                </tr>
                {*// @edit:dong @date:2020/11/11 @reason: 天润融通新*}
                <tr id="interface_enterpriseId_tianrunnew" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '天润融通新'}none{/if}">
                    <td>{$NEWTIANRUNINTERFACEADDRESS}</td>
                    <td>{$NEWTIANRUNURLVALUE}</td>
                </tr>
                <tr id="interface_enterpriseId_tianrunnew" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '天润融通新'}none{/if}">
                    <td>{$NEWTIANRUNACCESSKEYID}</td>
                    <td>{$NEWTIANRUNKEYIDVALUE}</td>
                </tr>
                <tr id="interface_enterpriseId_tianrunnew" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" style="display:{if $CALLCENTERVALUE neq '天润融通新'}none{/if}">
                    <td>{$NEWTIANRUNSECRET}</td>
                    <td>{if $NEWTIANRUNSECRETVALUE}******{/if}</td>
                </tr>
            </table>
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">{'PHONECALLINFIELDS'|@getFixedLabel}</th>
                </tr>
                {assign var="i" value=0}
                {foreach key=results name=resultswork item=list from=$RESULTLIST}
                    {assign var="j" value=$i++}
                    {if $j mod 2 eq '0'}
                        <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    {else}
                        <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    {/if}
                        <td width="20%">{$list.tabname|@getTranstab}</td>
                        <td width="80%">{$list.fieldlabel}</td>
                    </tr>
                {/foreach}
            </table>
        </div>
    </div>
</div>
</form>