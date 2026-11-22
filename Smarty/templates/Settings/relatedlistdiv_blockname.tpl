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

<form action="index.php" method="post" id="Saveresults_blocks" name="Saveresults_blocks" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="action" value="LayoutBlockList">
	<input type="hidden" name="module" value="Settings">
  <input type="hidden" name="formodule" value="{$modulename}">
  <input type="hidden" name="tabid" value="{$tabid}">
  <input type="hidden" name="blockid" value="{$blockid}">
  <input type="hidden" name="sub_mode" value="relatedlist_blocknameSave">
  {assign var=entries value=$CFENTRIES}
  
  <table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="ld-form-item-label">
        <font color="red">*</font>{'CNTAG'|@getFixedLabel}
      </td>
			<td class="ld-form-item-content">
        <input value="{$fildlable_zh}" type="text" name="fildlable_zh" id='fildlable_zh' class="ld-input-inner" />
        <input value="{$fildlable_zh}" type="hidden" name="fildlable_zh_old" />
      </td>
    </tr>
    <tr>
			<td class="ld-form-item-label">
        <font color="red">*</font>{'ENTAG'|@getFixedLabel}
      </td>
			<td class="ld-form-item-content">
        <input value="{$fildlable_en}" type="text" name='fildlable_en' id="fildlable_en" class="ld-input-inner"/>
        <input value="{$fildlable_en}" type="hidden" name="fildlable_en_old" class="ld-input-inner" />
      </td>
    </tr>	
  </table>
  <!--<div class="E_pbtn">
  	 <input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveresultsForlabel()"/><span>&nbsp;</span>
    <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="msgConfirm()"/> 
  </div> -->
  <!--BUG0066295: 模块管理>页面设置>编辑属性弹出框可以进行拖拽  余俊  2023/5/15-->
</form>