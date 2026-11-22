{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}

{*<!-- buttons for the home page -->*}

		<!--修改编码格式:统一编码：UTF-8-->
        <form action="index.php" method="post" name="Quicksetactions" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="action" value="LayoutBlockList"/>
		<input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="formodule" value="{$modulename}"/>
        <input type="hidden" name="tabid" value="{$tabid}"/>
        <input type="hidden" name="sub_mode" value="QuicksetactionsSave"/>
        <input type="hidden" name="backaction" value="{$BACKACTION}"/>
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
		{assign var=entries value=$CFENTRIES}
        <div class="D_pop_tit">
        	<strong class="D_ptita">{'ASSOCIATIONTOCREATESET'|@getFixedLabel}</strong>
            <a href="javascript:fninvshnew('Quicksetactions_div');" class="D_ptitc">
                <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
            </a>
        </div>	
		<table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
            <tr>
        		<td width="200px;">
        			<span>{'AVAILABLEPROJECT'|@getFixedLabel}</span>
                    <input type="hidden" value="" id="tobeselecte_module_String" name="tobeselecte_module_String">
        			<select style="overflow:auto; height: 250px;width:200px;font-family:Arial, Helvetica, sans-serif;font-size:12px;" class="crmFormList" name="tobeselecte_module" id="tobeselecte_module" multiple="" ondblclick="addColumn('tobeselecte_module','beselected_module')"><!--ondblclick="addColumn();-->
                        {foreach item=related_module key=related_moduleid from=$actions_arr name=relinfo}                                                         
                            <option value="{$related_moduleid}">
                                {if $related_moduleid eq '-2'}
                                    {'LBL_Creates'|@getFixedLabel}{$related_module}
                                {elseif $related_moduleid eq '-3'}
                                    {'VIEW'|@getFixedLabel}{$related_module}
                                {elseif $related_moduleid eq '-1' || $related_moduleid eq '-5' || $related_moduleid eq '-6' || $related_moduleid eq '-7' || $related_moduleid eq '-8'}
                                    {$related_module}
                                {else}
                                    {$related_module}
                                {/if}
                            </option>                                                                                                                     
                        {/foreach}
                    </select> 
                    
        		</td>
        		<td width="50px;" align="center">
        			<a class="icon-newhomearr icon-mright" style="margin-top:15px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('tobeselecte_module','beselected_module');" title="{'MOVERIGHT'|@getFIxedLabel}"></a>
        			<a class="icon-newhomearr icon-mleft" style="margin-top:25px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('beselected_module','tobeselecte_module');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
        		</td>
        		<td width="220px;">
        			<span>{'THEPROJECTANDTHEORDEROFDISPLAY'|@getFixedLabel}</span>
                    <input type="hidden" value="" id="beselected_module_String" name="beselected_module_String">
        			<select size="11" style="overflow:auto; height: 250px;width:200px;font-family:Arial, Helvetica, sans-serif;font-size:12px;" class="crmFormList" name="beselected_module" id="beselected_module" multiple="" ondblclick="addColumn('beselected_module','tobeselecte_module')">                                                               
 			            {foreach item=item key=itemid from=$actions_arr_userd name=relinfo}                                                        
                             <option value="{$itemid}">
                                {if $itemid eq '-2'}
                                    {'LBL_Creates'|@getFixedLabel}{$item}
                                {elseif $itemid eq '-3'}
                                    {'VIEW'|@getFixedLabel}{$item}
                                {elseif $itemid eq '-1' || $itemid eq '-5' || $itemid eq '-6' || $itemid eq '-7' || $itemid eq '-8'}
                                    {$item}
                                {else}
                                    {$item}
                                {/if}
                             </option>                                                                                                                   
                        {/foreach}
                       
                    </select>
                    
        		</td>
        		<td align="center" width="50" style="padding-right: 16px;">
        			<a class="icon-newhomearr icon-mup" style="margin-top:15px;margin-left:-5px;" href="javascript:;" onclick="ModuleDetailmoveUp('beselected_module');" title="{'MOVEUP'|@getFIxedLabel}"></a>
        			<a class="icon-newhomearr icon-mdown" style="margin-top:25px;margin-left:-5px;" href="javascript:;" onclick="ProductDetailmoveDown('beselected_module');" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
        		</td>
            </tr>                      
        </table>	
        <div class="D_pbtn">
        	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="checkoptionvalus(this.form,2)"/><span>&nbsp;</span>
            <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('Quicksetactions_div')"/>
            <!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
        </div>
	</form>	