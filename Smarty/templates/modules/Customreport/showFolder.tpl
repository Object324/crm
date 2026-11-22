<!--文件夹排序-->
<div class="E_pop_tit">
	<strong class="E_ptita">{'SHOWHIDDENFOLDER'|@getFixedLabel}</strong>
	<button id="report-href-showfolder" class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></button>
</div>
<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
	<tr>	
		<td>
			<select id="select_folder" multiple="" style="border:0px #ddd solid;width: 300px; height: 200px;padding-top: 3px;" onchange="selectedColumnClick(this);" name="select_folder" size="10" >
				{foreach item=report_folder key=folder_id from=$REPORT_FOLDER}  
					<option value="{$folder_id}">{$report_folder.folder_name}</option>
				{/foreach}
			</select>
		</td>	
	</tr>
</table>
<div class="E_pbtn">
	<input type="button" class="E_pbtnok" value="{'SHOWINGRECORDS'|@getFixedLabel}" id="report-save-showfolder"/><span>&nbsp;</span>
	<input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id="report-hide-showfolder"/> 
</div>