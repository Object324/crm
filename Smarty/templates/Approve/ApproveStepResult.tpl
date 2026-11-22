
<div class="D_pop_tit">
	<strong class="D_ptita">{'APPROVALPROCDETAIL'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('approvestepresult');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>		

<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0" style="color:#666">
    <tr>
    <td>
    <table width="100%" class="listdata" cellspacing="1" cellpadding="0" border="0" style="margin-top:3px;">
    <tr>
    <th title="{'SEQUENCE'|@getFixedLabel}">{'SEQUENCE'|@getFixedLabel}</th>
    <th title="{'APPROVVALNAME'|@getFixedLabel}">{'APPROVVALNAME'|@getFixedLabel}</th>
    <th title="{'APPROVER'|@getFixedLabel}">{'APPROVER'|@getFixedLabel}</th>
    <th title="{'APPROVALENDPROCESS'|@getFixedLabel}">{'APPROVALENDPROCESS'|@getFixedLabel}</th>
    <th title="{'APPROVALENDSTEP'|@getFixedLabel}">{'APPROVALENDSTEP'|@getFixedLabel}</th>
	<th title="{'specifytheapproval'|@getFixedLabel}">{'specifytheapproval'|@getFixedLabel}</th>
    </tr>
	{foreach item=step key=index from=$APPROVESTEP}
	<tr>
		{if $step.STEPID eq $STEPID}
		<td>{$index+1}</td>
		<td title="{$step.STEPNAME}">{$step.STEPNAME}</td>
		<td title="{$step.APPROVEBYNAME}">{$step.APPROVEBYNAME}</td>
	    <td>
    		{if $step.ENDED}
    		{'NO'|@getFixedLabel}
    		{else}
    		{'YES'|@getFixedLabel}
    		{/if}
		</td>
		<td>     
    		{if $step.STEP}
    		{'NO'|@getFixedLabel}
    		{else}
    		{'YES'|@getFixedLabel}
    		{/if}
		</td>
		<td>
			{if $step.specifyapproverid eq 0}
				{'YES'|@getFixedLabel}
			{else}
				{'NO'|@getFixedLabel}
			{/if}
		</td>
		{else}
		<td title="{$index+1}"></td>
		<td title="{$step.STEPNAME}">{$step.STEPNAME}</td>
		<td title="{$step.APPROVEBYNAME}">{$step.APPROVEBYNAME}</td>
		<td>
		{if $step.ENDED}
		{'NO'|@getFixedLabel}
		{else}
		{'YES'|@getFixedLabel}
		{/if}
		</td>
		<td>     
		{if $step.STEP}
		{'NO'|@getFixedLabel}
		{else}
		{'YES'|@getFixedLabel}
		{/if}
		</td>
		<td>
			{if $step.specifyapproverid eq 0}
				{'YES'|@getFixedLabel}
			{else}
				{'NO'|@getFixedLabel}
			{/if}
		</td>
		{/if}
	</tr>
	{/foreach}
</table>
</td>
</tr>
</table>
</div>