<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="modules/Customreport/SaveIndirectReportDetail.js"></script>
<script type="text/javascript">
{literal}
function vtlib_modulemanager_toggleTab(shownode, hidenode, highlighttab, dehighlighttab) {
	if($(shownode)) $(shownode).show();
	if($(hidenode)) $(hidenode).hide();
	if($(highlighttab)) { $(highlighttab).addClassName('dvtSelectedCellCommon dvtSelectedCell'); $(highlighttab).removeClassName('dvtUnSelectedCell'); }
	if($(dehighlighttab)) { $(dehighlighttab).addClassName('dvtUnSelectedCell'); $(dehighlighttab).removeClassName('dvtSelectedCellCommon dvtSelectedCell'); }
}
{/literal}
</script>
<div id="searchAcc" class="Find_box" style='width:{$PAGEWIDTHPERCENT}%;'>
	<div class="DivC" style="border:0px;">
		<h3 style="font-size:16px;padding:0;margin:0; height:45px; line-height:45px">Indirect 项目明细表
			<span id="report_time_titme"></span>
		</h3>
	</div>
	<form class="Find_Form0" name="basicSearch"  action="index.php" method="POST" onsubmit="return CallTimeSheet(this,'BasicSearch')" >
    <input type="hidden" name="module" value="Customreport"/>
    <input type="hidden" name="action" value="IndirectReportDetail" />
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="5">
				<tr>
					<td>
						<label class="Name"><span>StartDate:&nbsp;</span></label>
						<span>
							<input id="begin_createdate" maxlength="25" name="begin_createdate"  value="{$begin_createdate}" onClick="WdatePicker()" class="Wdate" />
							<input id="b_begin_createdate" type="hidden" name="b_begin_createdate"/>
						</span>
					</td>
					<td>
						<label class="Name"><span>EndDate:&nbsp;</span></label>
						<span>
							<input id="begin_end_date" maxlength="25" name="begin_end_date"  value="{$begin_end_date}" onClick="WdatePicker()" class="Wdate" />
							<input id="b_begin_end_date" type="hidden" name="b_begin_end_date"/>
						</span>
					</td>
                    <td>
                        <label class="Name"><input name="submit" id='BasicSearchreput' type="Submit"  class="createauto b_radius3" value="生成报表"/></label>
                    </td>
                    <td>
                        <li class="D_anu_a">
                            <a href="#" title="{'EXPORT'|@getFixedLabel}" onclick="ExportReport('{$REPORTNAME}');" name="editsubmit">
                            <b class="icon-homeimg icon-signout"></b><span>{'EXPORT'|@getFixedLabel}Excel</span></a>
                        </li>
                    </td>
				</tr>
				<!--The end-->
			</table>
			</td></tr>
		</table>
	</form>
</div>
<table border="0" cellspacing="1" cellpadding="0"  width="100%" class="ControlTable1 listEntries fir-center" id="modmgr_standard" >

<tr>
    <th align="center" style="background:#99CCFF;width:80px;"><b>Name</b></th>
    <th align="center" style="background:#99CCFF;"><b>Date</b></th>
    <th align="center" style="background:#99CCFF;"><b>Indirect</b></th>
    <th align="center" style="background:#99CCFF;width:155px;"><b>Business Reason</b></th>
    <th align="center" style="background:#99CCFF;"><b>对应科目代码</b></th>
    <th align="center" style="background:#99CCFF;"><b>对应科目摘要</b></th>
    <th align="center" style="background:#99CCFF;"><b>人员类别</b></th>
    <th align="center" style="background:#99CCFF;"><b>二级科目</b></th>
    <th align="center" style="background:#99CCFF;"><b>二级科目摘要</b></th>
    <th align="center" style="background:#CC99FF;"><b>Total (in RMB)</b></th>
	<th align="center" style="background:#CC99FF;"><b>Action</b></th>
</tr>
{assign var="i" value=0}
{assign var="modulenamenum" value='1'}
{foreach key=moduleid item=modinfo name=modulenamenum from=$TOGGLE_MODINFO}
{if $modinfo.customized eq false}
	{assign var="modulelabel" value=$modinfo.tablabel}
    {assign var="j" value=$i++}
    {if $j mod 2 eq '0'}
        <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
    {else}
        <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
    {/if}     
        <td title="{$modinfo.last_name}">
            {$modinfo.last_name}
        </td >
        
        <td title="{$modinfo.Startdate}">
            {$modinfo.Startdate}    
        </td >
        
        <td title="{$modinfo.indirect}">
            {$modinfo.indirect}
        </td >
        
        <td title="{$modinfo.expensetype}">
            {$modinfo.expensetype}
        </td >
        <td title="">
            <span id="span_subjectcode_{$j+1}" class="modulecontrollspan" tag="{$modinfo.expensedetailid}" title="{$modinfo.subjectcode}">{$modinfo.subjectcode}</span>
            <div id="div_subjectcode_{$j+1}" style="display:none;" class="modulecontrolldiv">
	            <input id="subjectcode_{$j+1}" class="detailedViewTextBox" style="width:150px;display:inline-block;" type="text" value="{$modinfo.subjectcode}" maxlength="100" name="modulename">
            </div>
        </td>
        <td >
            <span id="span_subjectsummary_{$j+1}" class="modulecontrollspan" tag="{$modinfo.expensedetailid}" title="{$modinfo.subjectsummary}">{$modinfo.subjectsummary}</span>
            <div id="div_subjectsummary_{$j+1}" style="display:none;" class="modulecontrolldiv">
	            <input id="subjectsummary_{$j+1}" class="detailedViewTextBox" style="width:150px;display:inline-block;" type="text" value="{$modinfo.subjectsummary}" maxlength="100" name="modulename">
            </div>
        </td>
        
        <td  title="{$modinfo.usercategory}">
            {$modinfo.usercategory}
        </td >
        
        <td >
            <span id="span_subjectcode2_{$j+1}" class="modulecontrollspan" tag="{$modinfo.expensedetailid}" title="{$modinfo.subjectcode2}">{$modinfo.subjectcode2}</span>
            <div id="div_subjectcode2_{$j+1}" style="display:none;" class="modulecontrolldiv">
	            <input id="subjectcode2_{$j+1}" class="detailedViewTextBox" style="width:150px;display:inline-block;" type="text" value="{$modinfo.subjectcode2}" maxlength="100" name="modulename">
            </div>
        </td>
        
        <td >
            <span id="span_subjectsummary2_{$j+1}" class="modulecontrollspan" tag="{$modinfo.expensedetailid}" title="{$modinfo.subjectsummary2}">{$modinfo.subjectsummary2}</span>
            <div id="div_subjectsummary2_{$j+1}" style="display:none;" class="modulecontrolldiv">
	            <input id="subjectsummary2_{$j+1}" class="detailedViewTextBox" style="width:150px;display:inline-block;" type="text" value="{$modinfo.subjectsummary2}" maxlength="100" name="modulename">
            </div>
        </td>

        <td title="{$modinfo.rmb_tota}">
            {$modinfo.rmb_tota}
        </td >                

		<td align="center">
            <div id="btn_edit_{$j+1}" style="display:;">
                <a  class="Anu3_a" href="javascript:void(0);" onclick="vtlib_showeditinput(event,{$j+1});" >{'EDIT'|@getFixedLabel}</a>
            </div>
            <div id="btn_save_{$j+1}" style="display:none;">
                <a class="Anu3_a" href="javascript:void(0);" onclick="vtlib_savemodulename({$j+1})">{'SAVE'|@getFixedLabel}</a>
                <a class="Anu3_a" href="javascript:void(0);" onclick="vtlib_cancelmodulename({$j+1});" >{'CANCEL'|@getFixedLabel}</a>
            </div>
        </td>
	</tr>
    {assign var="modulenamenum" value=$modulenamenum+1}
{/if}
{/foreach}

</table>