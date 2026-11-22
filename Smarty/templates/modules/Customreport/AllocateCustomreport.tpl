<!--分配-->
<div class="D_pop_tit">
	<strong id="Divtitlename" class="D_ptita">{'ALLOCATE'|@getFixedLabel} </strong>
	<a class="D_ptitc" id="report-href-allocate">
		<img class="D_ptitcimg" title="关闭" alt="关闭" src="themes/icon/pop_close.png">
	</a>
</div>
<input type="hidden" value="{$allocatetype}" id="hidden_allocatetype">
<input type="hidden" value="{$USERID}" id="hidden_selcetuser">
<div id="Divcontent" class="D_pop_content" style="max-height:200px;overflow-y:auto;">
	<div class="divPeople-Title">
		{'APPLICABLESCOPE'|@getFixedLabel}
			<div style="margin-top: 5px;">
				<input class="templateprintRadio" type="radio" {if $allocatetype eq 0}checked{/if} value="0" name="edit_radioUser" onclick="ReportAllocateUser.setalluser('edit')">
				{'ALLTHEUSERS'|@getFixedLabel}
				<input class="templateprintRadio" type="radio" {if $allocatetype eq 1}checked{/if} onclick="ReportAllocateUser.report_showgroups('edit')" value="1" name="edit_radioUser">
				{'SETBYDEPARTMENT'|@getFixedLabel}
				<input class="templateprintRadio" type="radio" {if $allocatetype eq 2}checked{/if} onclick="ReportAllocateUser.report_showusers('edit')" value="2" name="edit_radioUser">
				{'SETBYUSERS'|@getFixedLabel}
				<input id="edit_selectuser" type="hidden" value="{$USERID}" name="edit_selectuser">
			</div>
	</div>
</div>
<div class="D_pbtn">
	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" id="report-save-allocate"/><span>&nbsp;</span>
	<input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id="report-hide-allocate"/> 
</div>