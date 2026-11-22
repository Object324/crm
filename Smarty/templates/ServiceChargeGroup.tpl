<form action="index.php" method="post" name="Saveresults" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="{$MODULE}"/>
<input type="hidden" name="action" value="GroupEdit"/>
<input type="hidden" name="type" value="{$TYPE}" />	

    {if $TYPE eq 'Add'  || $TYPE eq 'Edit'}
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'CREATEGROUPS'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('groupedit');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        <td style="text-align:right" width="20%"><font color="red">*</font>{'Group_name'|@getFixedLabel}：</td>
        <td width="30%">
            <input type="text" name="zhgroupname" id="zhgroupname" size="15" value="{$GROUPZHNAME}" style="border:1px solid #ccc"/>　{'20word_limit'|@getFixedLabel}
        </td>
      </tr>
      <tr>
        <td style="text-align:right" width="20%"><font color="red">*</font>{'GroupEnname'|@getFixedLabel}：</td>
    	<td width="30%">
            <input type="text" name="engroupname" id="engroupname" size="15" value="{$GROUPENNAME}" style="border:1px solid #ccc"/>　{'20word_limit'|@getFixedLabel}
        </td>
      </tr>
    </table>
    {elseif $TYPE eq 'Del'}
    <div class="D_pop_tit">
    	<strong class="D_ptita">{if $TYPE eq 'Del'}{'DELETE'|@getFixedLabel}{else}{'EDIT'|@getFixedLabel}{/if}{'Grouping'|@getFixedLabel} - {$GROUPNAME}</strong>
        <a href="javascript:fninvshnew('groupedit');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        <td style="text-align:right" width="20%">{'REPLACEWITHTHEFOLLOWINGGROUPS'|@getFixedLabel}:</td>
        <td width="30%">
            <select id="servicegroup" name="servicegroup">
            {foreach key=groupid item=groupname name=group from=$GROUP}
                <option value="{$groupid}">{$groupname}</option>
            {/foreach}
            </select>
            <input type="hidden" name="zhgroupname" id="zhgroupname" value="" size="15" />
        
        </td>
      </tr>
    </table>
    {elseif $TYPE eq 'Soft'}
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SORT'|@getFixedLabel}{'Grouping'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('groupedit');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        <td style="margin-left:5px;"><b>{'THEPROJECTANDTHEORDEROFDISPLAY'|@getFixedLabel}</b>
            <input type="hidden" value="" id="selectgroupname" name="selectgroupname">
			<select size="11" style="overflow:auto; height: 180px;width:200px;border:1px solid #CCCCCC;font-family:Arial, Helvetica, sans-serif;font-size:12px; margin-left:2px;padding-top:3px;" class="crmFormList" name="selectedSourceColumns" id="selectedSourceColumns" multiple="">                                                               
	            {foreach item=group key=groupid from=$GROUPNAME name=groupname}                                                          
                    <option value="{$groupid}">
                    {$group}
                    </option>                                                                                                                     
                {/foreach}
            </select>
		</td>
        <td align="center" width="48">
			<a class="icon-homearr icon-mup" href="javascript:;" onclick="moveSelectUp();" title="{'MOVEUP'|@getFIxedLabel}"></a>
			<a class="icon-homearr icon-mdown" href="javascript:;" onclick="moveSelectDown();" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
		</td>
      </tr>
    </table>
    {elseif $TYPE eq 'Dis'}
     {if $return_action neq ''}
        <input type="hidden" id="return_action_detail" value="{$return_action}" />
         <div class="D_pop_tit">
    	<strong class="D_ptita">{'ALLOCATE'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('smowneredit');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
        </div>
     {else}
         <div class="D_pop_tit">
    	<strong class="D_ptita">{'ALLOCATE'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('groupedit');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
         </div>
     {/if}
   
    <table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr style="height:40px;">
       {assign var=usefldlabel value='MODIFYTHESERVICECHARGEFOR'|@getFixedLabel}
        {assign var=ALLOCATEUSERS value=$USERARR}	
       	{include file='DetailView/PublicAllocateSmowner.tpl'}
        <input type="hidden" name="selusername" id="selusername" value="{$USERINFO}" />
        
      </tr>
    </table>
    {elseif $TYPE eq 'Move'}
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'MOVEGROUP'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('groupedit');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr style="height:40px;">
        <td style="text-align:right" width="20%">{'MOVEGROUP'|@getFixedLabel}</td>
        <td width="30%">
            <select id="servicegroup" name="servicegroup" style='border:1px solid #ccc;height:24px;'>
            {foreach key=groupid item=groupname name=group from=$GROUP}
                <option value="{$groupid}">{$groupname}</option>
            {/foreach}
            </select>
            <input type="hidden" name="selusername" id="selusername" value="{$USERINFO}" />   
        </td>
      </tr>
    </table>
    {/if}    	
    <div class="D_pbtn">
        {if $TYPE eq 'Add' || $TYPE eq 'Edit'}
            <input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveGroup('{$MODULE}','{$TYPE}',{$GROUPID})"/><span>&nbsp;</span>
        {elseif $TYPE eq 'Del'}
            <input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="EditGroup('{$MODULE}','{$TYPE}',{$GROUPID})"/><span>&nbsp;</span>
        {elseif $TYPE eq 'Soft'}
            <input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SubmitGroup(this,'{$MODULE}')" /><span>&nbsp;</span>
        {elseif $TYPE eq 'Dis'}
            <input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="UpdateServiceUser(this,'{$MODULE}')"/><span>&nbsp;</span>
        {elseif $TYPE eq 'Move'}
            <input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="UpdateServiceGroup(this,'{$MODULE}')"/><span>&nbsp;</span>
        {/if}
        {if $TYPE eq 'Dis'&& $return_action neq ''}
             <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('smowneredit');puyoungJS_DialogBox.unblock();"/>
        {else}
            <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('groupedit');puyoungJS_DialogBox.unblock();"/>
        {/if}
    </div>    
</form>