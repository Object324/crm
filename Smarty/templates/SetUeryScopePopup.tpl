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
<style>
    .ld_setuery_tr{

    }
    .ld_setuery_tr_td{

    }
    .ld_setuery_tr:hover{
        background: #F0F0FB;
    }
    .ld_setuery_tr:hover .ld_setuery_tr_td{
        background: #F0F0FB !important;
    }
</style>
<!--修改编码格式:统一编码：UTF-8-->
<!--中间-->
<div id="uery_content">
    <form action="index.php" method="post" name="def_org_share" id="form" onsubmit="puyoungJS_DialogBox.block();" style="height:100%;width: 100%;">
		<input type="hidden" name="module" value="Users">
		<input type="hidden" name="action" value="SaveOrgSharing">
        <input type="hidden" name="modulelistvar" id="modulelistvar" value="{$MODULELISTVAR}">
        <input type="hidden" name="utype" id="utype" value="{$UTYPE}">
        <div id="clearBothlabeldiv_top" style="overflow: hidden;">
   			<table id="clearBothlabel_top" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #FAFDFF;">
                <tr>
                    <td rowspan="3" width="12%" align='left' style="border-right: 1px solid #F1F1F1"><b>{'ALLMODULE'|@getFixedLabel}</b></td>
                </tr>
                <tr>
                    <td align='center' style="">{'DATARANGE'|@getfixedLabel}</td>
                    <td align='center' style="overflow:inherit;word-break:break-all;white-space:inherit;width:120px;line-height: 130%;">
                        <span>
                			<b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
                			<span id="tip_info">{'viewothers'|@getFixedLabel}</span>
                			</b><font color="red">{$mandatory_field}</font>{$usefldlabel}
                		</span> 
                        {'allowviewothers'|@getFixedLabel}
                    </td>
                    <td align='center' style="overflow:inherit;word-break:break-all;white-space:inherit;width:120px;line-height: 130%;">
                        <span>
                			<b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
                			<span id="tip_info">{'ViewCreateMeTip'|@getFixedLabel}</span>
                			</b><font color="red">{$mandatory_field}</font>{$usefldlabel}
                		</span> 
                        {'ViewCreateMe'|@getFixedLabel}
                    </td>
                    
                    <td align='center' style="overflow:inherit;word-break:break-all;white-space:inherit;width:120px;line-height: 130%;">
                        <span>
                			<b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
                			<span id="tip_info">{'editothers'|@getFixedLabel}</span>
                			</b><font color="red">{$mandatory_field}</font>{$usefldlabel}
                		</span> 
                        {'alloweditothers'|@getFixedLabel}
                    </td>
                    <td align='center' style="overflow:inherit;word-break:break-all;white-space:inherit;width:120px;line-height: 130%;">
                        <span>
                			<b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
                			<span id="tip_info">{'EditCreateMeTip'|@getFixedLabel}</span>
                			</b><font color="red">{$mandatory_field}</font>{$usefldlabel}
                		</span> 
                        {'EditCreateMe'|@getFixedLabel}
                    </td>
                    <td align='center' style="overflow:inherit;word-break:break-all;white-space:inherit;width:120px;line-height: 130%;">
                        <span>
                        	<b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
                        	<span id="tip_info" style="left: -120px;">{'delothers'|@getFixedLabel}</span>
                        	</b><font color="red">{$mandatory_field}</font>{$usefldlabel}
                        </span> 
                        {'allowdelothers'|@getFixedLabel}
                    </td>
                    <td align='center' style="overflow:inherit;word-break:break-all;white-space:inherit;width:120px;line-height: 130%;">
                        <span>
                			<b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
                			<span id="tip_info" style="left:-220px;">{'viewselfbills'|@getFixedLabel}</span>
                			</b><font color="red">{$mandatory_field}</font>{$usefldlabel}
                		</span> 
                        {'allowviewselfcreatedbill'|@getFixedLabel}
                    </td>
                </tr>
                <tr>
                    <td width="400px" align='center' style="word-break:break-all;width:280px;border-bottom: 1px solid #F1F1F1;">
                		<label><input type="radio" name="all_Scope" id="all_Scope" class="input-btn-align" onclick="changeScopeFormAll(this,{$UID})" value="0" {if $SCOPE eq 0 && $SCOPE neq false}checked{/if}/>&nbsp;{'ME'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                        <label><input type="radio" name="all_Scope" class="input-btn-align" id="all_Scope" onclick="changeScopeFormAll(this,{$UID})" value="1" {if $SCOPE eq 1}checked{/if}/>&nbsp;{'ALL'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                        <label><input type="radio" name="all_Scope" class="input-btn-align" id="all_Scope" onclick="changeScopeFormAll(this,{$UID})" value="2" {if $SCOPE eq 2}checked{/if} />&nbsp;{'BYUSERS'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                        <label><input type="radio" name="all_Scope" class="input-btn-align" id="all_Scope" onclick="changeScopeFormAll(this,{$UID})" value="3" {if $SCOPE eq 3}checked{/if} />&nbsp;{'BYDEPARTMENTS'|@getFixedLabel}</label>
						<input type="hidden" name="all_scope" id="all_scope" value="{$SCOPE}" />
                		<input type="hidden" name="all_scopeid" id="all_scopeid" value="{$SCOPEID}" />
                    </td>
                    <td width="100px" align='center' style="word-break:break-all;width:120px;border-bottom: 1px solid #F1F1F1;"><input name="viewothers" type="checkbox" onclick="changeUserScopeOperation(this,'viewothers')"/></td>
                    <td width="100px" align='center' style="word-break:break-all;width:120px;border-bottom: 1px solid #F1F1F1;"><input name="viewcreateme" type="checkbox" onclick="changeUserScopeOperation(this,'viewcreateme')"/></td>
                    <td width="100px" align='center' style="word-break:break-all;width:120px;border-bottom: 1px solid #F1F1F1;"><input name="editothers" type="checkbox" onclick="changeUserScopeOperation(this,'editothers')"/></td>
                    <td width="100px" align='center' style="word-break:break-all;width:120px;border-bottom: 1px solid #F1F1F1;"><input name="editcreateme" type="checkbox" onclick="changeUserScopeOperation(this,'editcreateme')"/></td>
                    <td width="100px" align='center' style="word-break:break-all;width:120px;border-bottom: 1px solid #F1F1F1;"><input name="delothers" type="checkbox" onclick="changeUserScopeOperation(this,'delothers')"/></td>
                    <td width="100px" align='center' style="word-break:break-all;width:120px;border-bottom: 1px solid #F1F1F1;"><input name="viewselfbills" type="checkbox" onclick="changeUserScopeOperation(this,'viewselfbills')"/></td>
                </tr>
            </table>
        </div>
        <div style="overflow: auto;height: calc(100% - 84px); width: 100%;overflow-x: hidden;">

            <table id="clearBothlabel" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0">
                {foreach key=modulename item=elements from=$MODULESCOPE}	
                <tr class="ld_setuery_tr">
                    <td align='left' class="DetailedTd1Label ld_setuery_tr_td" style="max-width: 1px;width: 12%;" title="{$elements.tabname}">{$elements.tabname}</td>
                    <td width="400px" align='center' style="word-break:break-all;width:280px">
                		<label><input type="radio" name="{$modulename}" {if $elements.scopeauthority eq 0}checked{/if} class="input-btn-align" id="{$modulename}" onclick="changeScopeForm(this,'{$modulename}',{$UID})" value="0" />&nbsp;{'ME'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                        <label><input type="radio" name="{$modulename}" {if $elements.scopeauthority eq 1}checked{/if} class="input-btn-align" id="{$modulename}" onclick="changeScopeForm(this,'{$modulename}',{$UID})" value="1" />&nbsp;{'ALL'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                        <label><input type="radio" name="{$modulename}" {if $elements.scopeauthority eq 2}checked{/if} class="input-btn-align" id="{$modulename}" onclick="changeScopeForm(this,'{$modulename}',{$UID})" value="2" />&nbsp;{'BYUSERS'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                        <label><input type="radio" name="{$modulename}" {if $elements.scopeauthority eq 3}checked{/if} class="input-btn-align" id="{$modulename}" onclick="changeScopeForm(this,'{$modulename}',{$UID})" value="3" />&nbsp;{'BYDEPARTMENTS'|@getFixedLabel}</label>
                		<input type="hidden" name="{$modulename}_scope" id="{$modulename}_scope" value="{$elements.scopeauthority}" />
                		<input type="hidden" name="{$modulename}_scopeid" id="{$modulename}_scopeid" value="{$elements.scopeviewid}" />
                    </td>
                    {if $elements.operation eq '1' || {$modulename} eq 'WorkReportList'}
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'viewothers')" {if $elements.viewothers eq '1'} checked="" {/if} name="{$modulename}_viewothers"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'viewcreateme')"{if $elements.viewcreateme eq '1'} checked="" {/if} name="{$modulename}_viewcreateme"/></td>
                        <td width="100px" align='center'  style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'editothers')" {if $elements.editothers eq '1'} checked="" {/if} name="{$modulename}_editothers"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px" ><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'editcreateme')" {if $elements.editcreateme eq '1'} checked="" {/if} name="{$modulename}_editcreateme"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'delothers')" {if $elements.delothers eq '1'} checked="" {/if} name="{$modulename}_delothers" /></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'viewselfbills')" {if $elements.viewselfbills eq '1'} checked="" {/if} name="{$modulename}_viewselfbills"/></td>
                    {else if $modulename eq 'Singin'}
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'viewothers')" {if $elements.viewothers eq '1'} checked="" {/if} name="{$modulename}_viewothers"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'viewcreateme')"{if $elements.viewcreateme eq '1'} checked="" {/if} name="{$modulename}_viewcreateme"/></td>
                        <td width="100px" align='center'  style="word-break:break-all;width:120px"><input style="display:none" type="checkbox" onclick="changeUserScopeOperation_module(this,'editothers')" {if $elements.editothers eq '1'} checked="" {/if} name="{$modulename}_editothers"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px" ><input style="display:none" type="checkbox" onclick="changeUserScopeOperation_module(this,'editcreateme')" {if $elements.editcreateme eq '1'} checked="" {/if} name="{$modulename}_editcreateme"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'delothers')" {if $elements.delothers eq '1'} checked="" {/if} name="{$modulename}_delothers" /></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input  type="checkbox" onclick="changeUserScopeOperation_module(this,'viewselfbills')" {if $elements.viewselfbills eq '1'} checked="" {/if} name="{$modulename}_viewselfbills"/></td>
                    {else}
                        <td width="100px" align='center'  style="word-break:break-all;width:120px"><input style="display:none"  type="checkbox" name="{$modulename}_viewothers"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:120px"><input style="display:none"  type="checkbox" name="{$modulename}_viewcreateme"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:100px" ><input  style="display:none" type="checkbox" name="{$modulename}_editothers"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:100px" ><input  style="display:none" type="checkbox" name="{$modulename}_editcreateme"/></td>
                        <td width="100px" align='center' style="word-break:break-all;width:100px"><input style="display:none"  type="checkbox" name="{$modulename}_delothers" /></td>
                        <td width="100px" align='center' style="word-break:break-all;width:100px"><input  style="display:none"   type="checkbox" name="{$modulename}_viewselfbills"/></td>
                    {/if}
                </tr>
                
                {/foreach}
			</table>
        </div>
      
      </form>		
</div>

<!--中间 end-->