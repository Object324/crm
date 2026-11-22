<div class="D_pop_tit">
	<strong class="D_ptita">{'Quickly_create'|@getFixedLabel} &gt; {$MODULE|@getTranstab}</strong>
    <a href="javascript:remove_div('Second_qcformDiv');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>
{assign var=SECONDEQUICKCREATE value='yes'}

{include file='QuickCreateHidden.tpl'}
<!-- quick create UI starts -->
<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
{assign var="fromlink" value="qcreate"}
{assign value='QcEditView' var='formname'}
{assign value='yes' var='POPUPBUTTON'}
{foreach item=subdata from=$QUICKCREATE}
	<tr>
		{foreach key=mainlabel item=maindata from=$subdata}
            
			{include file='DetailView/EditViewUI.tpl'}										
		{/foreach}
	</tr>
{/foreach}    	
</table>
<div class="D_pbtn">   
    {if $CTYPE eq 'gengjin'|| $CTYPE eq 'progress'}
        <input type="button" name="button" id="btn_quick_save" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="this.disabled=true; if(getFormValidate('qcform')) {ldelim} if  (FieldDuplicateValidate('{$MODULE}',this.form,this)) quick_save(); {rdelim}  else {ldelim}this.disabled=false;return false;{rdelim}"/>
    {else}
		<input type="button" name="button" class="D_pbtnok"  value="{'SAVE'|@getFixedLabel}" onclick="qcSave.second_quickcreate='yes';qcSave(this,'{$MODULE}')"/>
	{/if}
	<span>&nbsp;</span>
    <input type="button" name="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="remove_div('Second_qcformDiv');"/>
</div>

{if $QCMODULE eq 'Event'}
<SCRIPT id="Second_qcvalidate">
        var qcfieldname = new Array('subject','date_start','time_start','eventstatus','activitytype','due_date','time_end','due_date','time_end');
        var qcfieldlabel = new Array('Subject','Start Date & Time','Start Date & Time','Status','Activity Type','End Date & Time','End Date & Time','End Date & Time','End Date & Time');
        var qcfielddatatype = new Array('V~M','DT~M~time_start','T~O','V~O','V~O','D~M~OTH~GE~date_start~Start Date & Time','T~M','DT~M~time_end','T~O~OTH~GE~time_start~Start Date & Time');
</SCRIPT>
{elseif $QCMODULE eq 'Todo'}
<SCRIPT id="Second_qcvalidate">
	var qcfieldname = new Array('subject','date_start','time_start','taskstatus');
        var qcfieldlabel = new Array('Subject','Start Date & Time','Start Date & Time','Status');
        var qcfielddatatype = new Array('V~M','DT~M~time_start','T~O','V~O');
</SCRIPT>
{else}
<SCRIPT id="Second_qcvalidate">
        var qcfieldname = new Array({$VALIDATION_DATA_FIELDNAME});
        var qcfieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
        var qcfielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
        var quickcreatefieldinfojsonobj='{$FIELDINFOJSON}';
        cur_PageInfo.pagetype.push('poplayerlistview');
        cur_PageInfo.modulenames.push('{$MODULE}');
        cur_PageInfo.pagemode.push('poplayer');
        
        {literal}
         
               var popfieldinfoobjs=  eval('('+ quickcreatefieldinfojsonobj +')')?eval('('+ quickcreatefieldinfojsonobj +')'):JSON.parse(quickcreatefieldinfojsonobj);
               cur_PageInfo.fieldinfoobjs.push(popfieldinfoobjs);
        {/literal}
</SCRIPT>
{/if}