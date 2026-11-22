<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->
<!--修改编码格式:统一编码：UTF-8-->
<!--
zyh
用户详情页增加附件
PROT197 
20150420
-->

<div class="Top" style="padding:8px 0px 8px 8px;border-top: 1px solid #ddd; border-left: 1px solid #ddd; border-right: 1px solid #ddd;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td valign="middle">
	            <ul class="D_btn_box e">
	            	<li class="D_anu_a">
						{$CUSTOM_BUTTON}
					</li>
					<li class="D_anu_a">
						<a href="javascript:void(0);" id='refresh-{$RELATED_MODULE}' onclick='resetuser({$record},{$page});return false;'><span>{'REFRESH'|@getFixedLabel}</span></a>
			        </li>
	            </ul>
			</td>
			<td class="" valign="middle">
				<div class="PageDiv0">
					<div class="ld-flex-start">
						{$NAVIGATION}
					</div>
				</div>
			</td>
		</tr>
	</table>
</div>
<table border=0 cellspacing=1 cellpadding="0" width="{if $PAGEWIDTHPERCENT eq ''}100{else}{$PAGEWIDTHPERCENT}{/if}%" class="listEntries">
	<tr>
        {foreach key=index item=_HEADER_FIELD from=$RELATEDHEADER name=relheadforeach}
            {if $smarty.foreach.relheadforeach.last}
                <th width="145">{$_HEADER_FIELD}</th>
            {else}
                <th>{$_HEADER_FIELD}</th>
            {/if}
        {/foreach}
	</tr>
	{$PROHTML}
</table>



<div id="divFileCallButlerlist" style="display:none;"></div>