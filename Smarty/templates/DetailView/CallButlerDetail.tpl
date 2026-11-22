<tr>
    <td style="width:100%;">  
		<!-- Detailed View Code starts here-->
		<table cellspacing="0" cellpadding="0" width="100%" border="0">			
		</table>
        <div onclick="showHideStatus('tblCallButler','aidCallButler');" class="DivCName DivCNamehover">
		     <span id="aidCallButler"></span>{'Recordfile'|@getFixedLabel}
		</div>
		<div id="tblCallButler" style="width:auto;display:block;" class="DivCNotice">
			 <table cellspacing="1" cellpadding="0" width="100%" border="0" class="DetailContentTable">
				<tbody>
                <tr>
                    <td class="DetailedTd1Label" width="20%" align="right">
                        {'Recordfile'|@getFixedLabel}
                    </td>
					<td width="80%" colspan="3" align="left" class="DetailedTd2Info">
                        {$CALLFILENAME}
                        <input type="hidden" id="callbutlername" name="callbutlername" value="{$CALLFILENAME}">
                    </td>
                </tr>
                <tr>
                    <!--TextBox-->
		            <td class="DetailedTd1Label" width="20%" align="right">
                        {'Recordnotes'|@getFixedLabel}
                    </td>
                    <td width="80%" colspan="3" align="left" {if $alloweditpage eq 'yes'}  onmouseout="fnhide('crmspanid');" onmouseover="hndMouseOver(1,'CallButlerRemarks');" {/if} id="mouseArea_CallButlerRemarks" class="DetailedTd2Info">
   			            <span id="dtlview_CallButlerRemarks" style="display: inline;">{$CALLDESCRIPTION}</span>
                        <div style="display: none;" id="editarea_CallButlerRemarks">
                            <input type="text" value="" maxlength="100" name="callButlerRemarks" id="txtbox_CallButlerRemarks" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" class="detailedViewTextBox">
                            <br><a href="javascript:;" onclick="dtlViewAjaxSave('CallButlerRemarks','{$MODULE}','','','callButlerRemarks','{$ID}');fnhide('crmspanid');" onclick='saveCall("{$MODULE}","{$ID}");fnhide("crmspanid");' name="button_CallButlerRemarks">{'SAVE'|@getFixedLabel}</a> {'OR'|@getFixedLabel}
                            <a onclick="hndCancel('dtlview_CallButlerRemarks','editarea_CallButlerRemarks','CallButlerRemarks')" href="javascript:;">{'CANCEL'|@getFixedLabel} </a>
                        </div>
                    </td>
                  </tr>
				</tbody>
                </table>
		</div>
	</td>
</tr>