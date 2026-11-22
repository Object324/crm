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
<input type="hidden" name="faq_page" id="faq_page" value="{$PAGE}" />
<table border="0" cellpadding="0" cellspacing="1" width="100%">
<tbody>
	<tr>
		<td align="left" width="50%">
			<input placeholder="{'SEARCHTHROGHPROBLEM'|@getFixedLabel}" type="text" onkeypress="EnterPress(event,'{$FROMMODULE}','{$SELECTMODULE}')" onkeydown="EnterPress()" name="keywords" id="keywords" value="{$KEYWORDS}" class="detailedViewTextBox" style="width:180px;float: left;" /> &nbsp;
      <!-- <input type="button" value="{'SEARCH'|@getFixedLabel}" onclick="getListViewFaqType('{$FROMMODULE}','{$SELECTMODULE}')"> -->
      <div class="btn_check_repeat">
        <b class="icon-homeimg icon-searchgrey" onclick="getListViewFaqType('{$FROMMODULE}','{$SELECTMODULE}');"></b>
        <a title="{'SEARCH'|@getFixedLabel}" onclick="getListViewFaqType('{$FROMMODULE}','{$SELECTMODULE}');">{'SEARCH'|@getFixedLabel}</a>
      </div>
		</td>
		<td align="right">
			<div class="PageDiv0" style="padding:3px 5px;margin-top:0px; ">
				<div class="ld-flex-start">
					<div class="ld-pagenum-div">{$recordListRange}</div>
					{$NUMOFROWS}
				</div>
			</div>
		</td>
	</tr>
</tbody>
</table>

<div class="clear"></div>
{$TABLE}