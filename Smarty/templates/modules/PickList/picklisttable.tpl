{assign var="loopindex" value="5"}
{assign var="seltfldstring" value=""}
<table class="listTable" cellpadding="5" cellspacing="0" align="left" width='100%' style="margin-bottom:10px;">
	<tbody id="valueMapping">
		<tr>
			<td class=" warning fixedHeight18px borderBR" id='sourcefieldspan' style='cursor:pointer;background-color:#f1f1f1;width:90px;'>{$ALL_LISTS[$SOURCEFIELD]}</td>
			<td colspan={$loopindex} class="borderB">{$DISPLAYVALUE}</td>
		</tr>
		<tr>
		{foreach key=TARGET_INDEX item=TARGET_VALUE from=$TARGET_VALUES name=loop}
			{if $smarty.foreach.loop.first}
				<td class="warning borderR" rowspan="{$TARGET_VALUES|@count}" id='targetfieldspan' selectall='true' style='cursor:pointer;background-color:#f1f1f1;'>
					{$ALL_LISTS[$TARGETFIELD]}
				</td>
			{/if}
			{assign var="seltfldcss" value="unselectedCell"}
     
			{if $DEPENDENCY_MAP[$DISPLAYVALUE] != '' && $TARGET_VALUE|in_array:$DEPENDENCY_MAP[$DISPLAYVALUE]}
				{assign var="seltfldcss" value="selectedCell"}
					{assign var="seltfldstring" value=$seltfldstringA|cat:$TARGET_VALUE}
			{/if}
			<td class='picklistValueMapping borderBR {$seltfldcss}' style="width:18%;">
                    <span style="float:left;">{$TARGET_VALUE}</span><b {if $seltfldcss eq 'selectedCell'}class="pickList-choosed"{/if}style="float:right"></b>
			</td>
			{if $smarty.foreach.loop.iteration%$loopindex==0}
				</tr><tr>
			{/if}
		{/foreach}
		</tr>
	</tbody>
</table>
<input type="hidden" id="sourcefieldhid" value="{$SOURCEFIELD}"/>
<input type="hidden" id="targetfieldhid" value="{$TARGETFIELD}"/>

<div id="actiondiv" class="D_pop_box LdPopWidth300px" style="display:none;position:absolute;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'ADDPICKLISTVALUE'|@getFixedLabel} - {$FIELDLABEL}</strong>
        <a href="javascript:fninvshnew('actiondiv');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod D_pop_bod_line" cellspacing="0" cellpadding="1" border="0">
	   <tr>
		  <td valign=top align=left width=400 colspan="2" style="padding-left:10px;">
			 {'ONEBYONEBELOW'|@getFixedLabel}
			 <textarea id="add_picklist_values" class="addTextarea" align="left" rows="10" style="border: 1px solid #AAAAAA;padding: 5px;width:250px;"></textarea>
		  </td>
	   </tr>
	</table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" id="saveAddButton"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id='canceladdbtn'/><!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
    </div>
</div>