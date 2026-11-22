<script language="JavaScript" type="text/javascript" src="include/js/advancefilter.js"></script>
<input type="hidden" name="fieldname" value="{$FIELDNAME}">
<div name="adv_filter_div">
    <div style="width: 100%;">
        <ul class="test_ul" name="datacategory_tabletitle">
            <li style="width: 40%;">满</li>
            <li style="width: 40%;">减</li>
            <li style=""></li>
            <li style="float:right;width: 150px;display:none"></li>
        </ul>
    </div>
	<div name="conditiongroup_1">
		<table class="settingPopTable" name="table_moduleminus" width="100%" cellspacing="1" cellpadding="0" border="0">
			<tbody>
			<tr name="groupheader_1"><td colspan="5" style="height:24px;" align="right"></td></tr>
			{if $MINUSNUM gt 0}
				{foreach item=arr from=$MINUSDATA}
					<tr name="conditioncolumn_1_0" class="minus">
						<td width="40%" align="left">
							<input name="man" id="man" class="width150 commonTextBoxPop" type="text" value="{$arr.man}" oninput="value=value.replace(/[^\d]/g,'')">
						</td>
						<td width="40%" align="left">
							<input name="jian" id="jian" class="width150 commonTextBoxPop" type="text" value="{$arr.jian}" oninput="value=value.replace(/[^\d]/g,'')">
						</td>
						<td name="columnconditionglue_0" width="60px" align="left"></td>
						<td width="30px" align="left">
							<a href="javascript:;" onclick="delModuleMinus(event,ld(this))" title="删除">删除</a>
						</td>
					</tr>
				{/foreach}
			{else}
				<tr name="conditioncolumn_1_0" class="minus">
					<td width="40%" align="left">
						<input name="man" id="man" class="width150 commonTextBoxPop" type="text" value="" oninput="value=value.replace(/[^\d]/g,'')">
					</td>
					<td width="40%" align="left">
						<input name="jian" id="jian" class="width150 commonTextBoxPop" type="text" value="" oninput="value=value.replace(/[^\d]/g,'')">
					</td>
					<td name="columnconditionglue_0" width="60px" align="left"></td>
					<td width="30px" align="left">
						<a href="javascript:;" onclick="delModuleMinus(event,ld(this))" title="删除">删除</a>
					</td>
				</tr>
			{/if}
			<tr name="groupfooter_1">
				<td colspan="5" align="left"><a href="javascript:void(0);" onclick="addModuleMinus(event)">新条件</a></td>
			</tr>
			</tbody>
		</table>
		<table class="settingPopTable" width="100%" cellspacing="0" cellpadding="0" border="0"><tbody><tr><td name="groupconditionglue_1" align="center"></td></tr></tbody></table></div></div>
	</div>
</div>