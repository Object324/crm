{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ***********************************************************t*********************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
{*{include file="Buttons_List1.tpl"}*}
<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />
<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
<tr>
    <td class="Tdcenter" style="padding:0 15px;" valign="top">
    	<div class="DivC">     
        {foreach key=BLOCKID item=BLOCKLABEL from=$BLOCKS}
        
        {if $BLOCKLABEL neq 'LBL_MODULE_MANAGER'}				
			<div class="ControlTitle">
				<h2 class="Name">{$BLOCKLABEL|@getFixedLabel:$BLOCKLABEL}</h2>
			</div>				
			<div class="ControlDiv0">
                
                <div class="DivMenu">
                {foreach item=data from=$FIELDS.$BLOCKID name=itr}
                  {if $data.name eq ''}
					&nbsp;
			     {else}
                 {*
                    /**
                     *@edit:andy 
                     *@date:
                     *@reason:0010955: 英文版控制面板内容重叠
                     *@version:
                     */
                 *}
                {if $languageType neq 'en'}                         
                <dl class="languageType_zh">
                {else}
                <dl class="languageType_en">
                {/if}                                                
                {assign var=label value=$data.name}
                
				<dt>
                    <a {if $data.name eq 'LBL_AUTHENINFO'} target="_blank"{/if} href="{$data.link}&blockidsetting={$BLOCKID}" title="{$label|@getFixedLabel}">
                    <img src="themes/images/{$data.icon}" /></a>
                </dt>
                {*
                    /**
                     *@edit:andy 
                     *@date:
                     *@reason:0010955: 英文版控制面板内容重叠
                     *@version:
                     */
                 *}                                
                {if $languageType neq 'en'}
				<dd class="paddT5_zh">
                {else}
                <dd class="paddT5_en">
                {/if}  
                    <a href="{$data.link}&blockidsetting={$BLOCKID}&fieldidsetting={$data.fieldid}">{$label|@getFixedLabel}</a>
                </dd>
                {assign var=description value=$data.description}
				<dd class="marT10">
                    <span>
                        {$description|@getFixedLabel}
                    </span>
                </dd>
				</dl>
                {/if}
                {assign var=count value=$smarty.foreach.itr.iteration}
                  {if $count mod $NUMBER_OF_COLUMNS eq 0}
                  </div><div class="DivMenu">
			      {/if}
                  {/foreach} 
				</div>  		

            </div>
			{/if}
	   {/foreach}		
        </div>
    </td>
</tr>
</table>
</div>
<!--中间 end-->