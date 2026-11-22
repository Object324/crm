<!--文件夹排序-->
<div class="E_pop_tit">
	<strong class="E_ptita">{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}</strong>
	<button id="report-href-sortfolder" class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></button>
</div>
<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
	<tr>	
		<td>
			<select id="select_folder" multiple="" style="border:0px #ddd solid;width: 190px; height: 200px;padding-top: 3px;" onchange="selectedColumnClick(this);" name="select_folder" size="10" >
				{foreach item=report_folder key=folder_id from=$REPORT_FOLDER}  
					<option value="{$folder_id}">{$report_folder.folder_name}</option>
				{/foreach}
			</select>
		</td>	
		<td  align='center'>
			<a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFIxedLabel}" onclick="select_moveUp('select_folder')"></a>
			<a class="icon-newhomearr icon-mdown" href="javascript:;" style="margin-top: 15px;" title="{'MOVEDOWN'|@getFIxedLabel}" onclick="select_moveDown('select_folder')"></a>
		</td>
	</tr>
</table>
<div class="E_pbtn">
	<input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" id="report-save-sortfolder"/><span>&nbsp;</span>
	<input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id="report-hide-sortfolder"/> 
</div>