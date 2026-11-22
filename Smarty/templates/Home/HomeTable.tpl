<!--修改编码格式:统一编码：UTF-8-->
<input type=hidden id="test_{$HOME_STUFFID}" value = {$HOME_STUFFTYPE}/>
	<input type=hidden id=more_{$HOME_STUFFID} value="{$HOME_STUFF.Details.ModuleName}"/>
	<table class="E_stripe" width="100%" cellspacing="1" cellpadding="1" border="0">
	<tr>
	{foreach item=header from=$HOME_STUFF.Details.Header}
		<th class='etit_ch'  colspan="4" style="text-align:center;">{$header}</th>
	{/foreach}
	</tr>
	{if $HOME_STUFF.Details.Entries|@count > 0}
        {assign var="i" value=0}
		{foreach item=row key=crmid from=$HOME_STUFF.Details.Entries name=entitylist}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if} 
        		<td>{$row[0]}</td>
                <td>{$row[1]}</td>
        		<td>{$row[2]}</td>
                <td>{$row[3]}</td>
    	   </tr>
		{/foreach}
        </table>
	{else}
    </table>
        <div class="home_nomsg_div">
            <div>
                <img class="icon-empty" alt="{'NOTFOUNDANYRECORD'|@getFixedLabel}" src="themes/images/emptyinfo.png"/>
                <span>{'NOTFOUNDANYRECORD'|@getFixedLabel}</span>
            </div>
        </div>
	{/if}
{if $HOME_STUFF.Details|@is_array == 'true'}
<input id='search_qry_{$HOME_STUFFID}' name='search_qry_{$HOME_STUFFID}' type='hidden' value='{$HOME_STUFF.Details.search_qry}' />
{/if}