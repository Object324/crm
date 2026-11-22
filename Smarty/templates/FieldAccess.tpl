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
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>

<!--中间-->
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Settings">
		<input type="hidden" name="parenttab" value="Settings">
		<input type="hidden" name="fld_module" id="fld_module" value="{$DEF_MODULE}">
		{if $MODE neq 'view'}
			<input type="hidden" name="action" value="UpdateDefaultFieldLevelAccess">
		{else}
			<input type="hidden" name="action" value="EditDefOrgFieldLevelAccess">
		{/if}	
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
      <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
                {'CONTROLPANEL'|@getFixedLabel} &gt;
                 {'LBL_FIELDS_ACCESS'|@getFixedLabel}
                <font>（{'LBL_SHARING_FIELDS_DESCRIPTION'|@getFixedLabel}）</font>
            </span>
            
        </div>
        <div class="ControlDiv2">
            <div class="F_l">
                <label>{'SELECTMODULE'|@getFixedLabel}&nbsp;&nbsp;</label>
                <select name="Screen"   onChange="changemodules(this)">
			     {foreach item=modinfo key=module from=$FIELD_INFO}
				{assign var="MODULELABEL" value=$modinfo|@getTranstab}
				{if $module == $DEF_MODULE}
					<option selected value='{$module}'>{$MODULELABEL}</option>
                <!--
                **新增判断，附件和日程管理字段不做权限控制
                **bu andy 
                **20140103
                **can 日程管理添加字段权限 bug:13162" 控制面板--页面设置and字段权限缺少"日程管理"模块"
                -->
				{ $module eq 'Attachment'}		
					
                {else}
                    <option value='{$module}' >{$MODULELABEL}</option>
				{/if}
		  	   {/foreach}
			    </select>
            </div>
       	    <!--<span class="F_l"><font size='2'>{'GLOBALFIELDSMANAGER'|@getFixedLabel}</font></span>-->
            {if $MODE neq 'edit'}
				<input name="Edit" type="submit" class="editauto" value="{'EDIT'|@getFixedLabel}" >									
			{else}
                <input name="{'CANCEL'|@getFixedLabel}" value="{'CANCEL'|@getFixedLabel}" class="cancelauto" type="button" onClick="window.history.back();">
			    <input title="{'SAVE'|@getFixedLabel}" class="saveauto" type="submit" name="Save" value="{'SAVE'|@getFixedLabel}">
			
            {/if}
        	
        </div>
        <div class="pad10" >
            
            {foreach key=module item=info name=allmodules from=$FIELD_LISTS}
      
			{assign var="MODULELABEL" value=$module|@getTranstab}
	
    		{if $module eq $DEF_MODULE}
    			<div id="{$module}_fields" style="display:block">	
    		{else}
    			<div id="{$module}_fields" style="display:none">	
    		{/if}
    	 	<table cellspacing="0" cellpadding="0" width="100%">
           		<tr>
         	        <td valign="top" width="25%" >
    		     	<table class="listEntries" border="0" cellspacing="0" cellpadding="0" width="100%">
    				{foreach item=elements name=groupfields from=$info}
                    {if ($smarty.foreach.groupfields.index+1)%2 == 1}
                    	<tr  class="lvtColDataBj">
                    {else}
                        <tr bgcolor="white">
                    {/if}
                        {foreach item=elementinfo name=curvalue from=$elements}
                       		<td style="width:20px">&nbsp;</td>
                       		<td width="5%" id="{$smarty.foreach.allmodules.iteration}_{$smarty.foreach.groupfields.iteration}_{$smarty.foreach.curvalue.iteration}">{$elementinfo.1}</td>
                       		<td width="20%" nowrap>{$elementinfo.0|@getTranslatedString:$elementinfo.0}</td>
				        {/foreach}
                        {if !$smarty.foreach.groupfields.last}                                                
                     	  </tr>
                        {/if}
                    {/foreach}
                    {if $smarty.foreach.curvalue.iteration neq '4'}
                        {assign var='loopcount' value=4}
                        {assign var='loopcount' value=$loopcount-$smarty.foreach.curvalue.iteration}
                        {section name='loop1' loop=$loopcount}
                            <td style="width:20px">&nbsp;</td>
                       		<td width="5%">&nbsp;</td>
                       		<td width="20%" nowrap>&nbsp;</td>
                        {/section}
                    {/if}
                    </tr>
                 	</table>
    			   </td>
                </tr>
                </table>
    		</div>
    		{/foreach}
            
        </div>         
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->


<script>
var def_field='{$DEF_MODULE}_fields';
{literal}
function changemodules(selectmodule)
{
	hide(def_field);
	module=selectmodule.options[selectmodule.options.selectedIndex].value;
	document.getElementById('fld_module').value = module; 
	def_field = module+"_fields";
	show(def_field);
}
</script>
{/literal}