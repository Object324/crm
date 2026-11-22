<!--修改编码格式:统一编码：UTF-8-->
<input type=hidden id="test_{$HOME_STUFFID}" value = {$HOME_STUFFTYPE}/>
	<input type=hidden id=more_{$HOME_STUFFID} value="{$HOME_STUFF.Details.this.ModuleName}"/>
    {foreach item=header from=$HOME_STUFF.Details.this.Header}
		{$header}
	{/foreach}
    <div id="getmonthweekreport1" >   
    {if is_array($HOME_STUFF.Details.this.Entries) && $HOME_STUFF.Details.this.Entries|@count > 0}
        <table class="E_stripe" width="100%" cellspacing="1" cellpadding="1" border="0">
            {foreach item=rowlist key=crmid from=$HOME_STUFF.Details.this.Entries name=entitylist}
                <tr>
                    <th class='etit_ch'  colspan="4" style="text-align:left;">{$crmid|getTranstab}
                        <a class="icon-homeview p-hr icon-moreh" title="{'MORE'|@getFixedLabel}" target="_blank" href="{$HOME_STUFF.Details.this.Link.$crmid}"></a>
                    </th>
                </tr>
                {assign var="i" value=0}
                {foreach item=row key=module from=$rowlist name=entitylist}
                    {assign var="j" value=$i++}
                    {if $j mod 2 eq '0'}
                        <tr id="setting_{$crmid}_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    {else}
                        <tr id="setting_{$crmid}_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    {/if}  
                        <td >{$row.No}</td>
                        <td >{$row.LBL_ACCOUNTCOUNT}</td>
                        <td >{$row.LBL_SALESORDERTOTAL}</td>
                </tr>
                {/foreach}
            {/foreach}
        </table>
	{else}
        <div class="home_nomsg_div">
            <div>
                <img class="icon-empty" alt="{'NOTFOUNDANYRECORD'|@getFixedLabel}" src="themes/images/emptyinfo.png"/>
                <span>{'NOTFOUNDANYRECORD'|@getFixedLabel}</span>
            </div>
        </div>
	{/if}
    
    </div>
    
    <div id="getmonthweekreport2" style="display:none">   
    {if is_array($HOME_STUFF.Details.last.Entries) && $HOME_STUFF.Details.last.Entries|@count > 0}
        <table class="E_stripe" width="100%" cellspacing="1" cellpadding="1" border="0">
       	{foreach item=rowlist key=crmid from=$HOME_STUFF.Details.last.Entries name=entitylist}
			<tr>
				<th class='etit_ch'  colspan="4" style="text-align:left;">{$crmid|getTranstab}
                    <a class="icon-homeview p-hr icon-moreh" title="{'MORE'|@getFixedLabel}" target="_blank" href="{$HOME_STUFF.Details.last.Link.$crmid}"></a>
	            </th>
			</tr>
            {assign var="i" value=0}
            {foreach item=row key=module from=$rowlist name=entitylist}
				{assign var="j" value=$i++}
                {if $j mod 2 eq '0'}
                    <tr id="setting_{$crmid}_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                {else}
                    <tr id="setting_{$crmid}_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                {/if}  
            		<td >{$row.No}</td>
                    <td >{$row.LBL_ACCOUNTCOUNT}</td>
            		<td >{$row.LBL_SALESORDERTOTAL}</td>
        	   </tr>
            {/foreach}
		{/foreach}
        </table>
	{else}
        <div class="home_nomsg_div">
            <div>
                <img class="icon-empty" alt="{'NOTFOUNDANYRECORD'|@getFixedLabel}" src="themes/images/emptyinfo.png"/>
                <span>{'NOTFOUNDANYRECORD'|@getFixedLabel}</span>
            </div>
        </div>
	{/if}
    
    </div> 
{if $HOME_STUFF.Details.last|@is_array == 'true'}
<input id='search_qry_{$HOME_STUFFID}' name='search_qry_{$HOME_STUFFID}' type='hidden' value='{$HOME_STUFF.Details.last.search_qry}' />
{/if}