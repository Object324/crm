<div class="divPopOverflow">
<div class="ld-pop-container-second">
<form action="index.php" method="post" name="frmColumnSet">
<input  type="hidden" value="{$modulename}" name="module"/>
<input  type="hidden" value="ListView" name="action"/>
<input  type="hidden" value="SaveColumnSet" name="submode"/>
<input  type="hidden" value="BasicSearch" name="searchtype"/>
<input  type="hidden" value="" name="smownerids"/>
<input  type="hidden" value="" name="startdate"/>
<input  type="hidden" value="" name="enddate"/>
<input  type="hidden" value="" name="coldatefindcolumn"/>
<input  type="hidden" value="" name="colotherfindcolumn"/>
<input  type="hidden" value="" name="colbasicotherfind"/>
<input  type="hidden" value="" name="UseReportadv_group"/>
<input  type="hidden" value="" name="UseReportadv"/>
<input  type="hidden" value="" name="UseReportId"/>
<input  type="hidden" value="{$SHOWCOLUMNSDISPLAYNONE}" id="UseReportShowColumnDisplayNone"/>
<input type="hidden" name="selectedAssmablyColumnsString" id="selectedAssmablyColumnsString"/>
<table class="settingPopTable lasttdbordernon" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td width="200" class="padTB10">
            <b style="color:#666;">{'Available_fields'|@getFixedLabel}</b><br>
            <select name="AssmablyList" id="AssmablyList" multiple="" ondblclick="copySelectedOptionsOftenUserReport('AssmablyList','selectedAssmablyColumns');" class="commonMultipleSelect marT10" style="-webkit-appearance: listbox;">
                {$ALLCOLUMNS}                                                                                                                       
            </select>   
        </td>
        <td align="left" width="60">
            <a class="icon-newhomearr icon-mright" href="javascript:;" onclick="copySelectedOptionsOftenUserReport('AssmablyList','selectedAssmablyColumns');" title="{'MOVERIGHT'|@getFixedLabel}"></a><br>
            <a class="icon-newhomearr icon-mleft" style="margin-top:15px;margin-right: 1px;" href="javascript:;" onclick="copySelectedOptionsOftenUserReport('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFixedLabel}"></a>
        </td>
        <td width="200" class="padTB10">
            <b style="color:#666;">{'Selected_Fields'|@getFixedLabel}</b><br>
            <select name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="copySelectedOptionsOftenUserReport('selectedAssmablyColumns','AssmablyList');" class="commonMultipleSelect marT10" style="-webkit-appearance: listbox;">
                {$SHOWCOLUMNS}
            </select>
        </td>
        <td align="left" width="60">
            <a class="icon-newhomearr icon-mup" href="javascript:;" onclick="ReportmoveUp();" title="{'MOVEUP'|@getFixedLabel}"></a><br>
            <a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" onclick="ReportmoveDown();" title="{'MOVEDOWN'|@getFixedLabel}"></a>
        </td>
    </tr>
</table>
</form>
</div>
</div>