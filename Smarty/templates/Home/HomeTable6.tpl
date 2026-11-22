<input type=hidden id="test_{$HOME_STUFFID}" value = {$HOME_STUFFTYPE}/>
<input type=hidden id=more_{$HOME_STUFFID} value="{$HOME_STUFF.Details.ModuleName}"/>
<input type=hidden id=parent_{$HOME_STUFFID} value="{$HOME_STUFF.Details.ParentTab}"/>
<table class="D_home_table" width="100%" cellspacing="0" cellpadding="0" border="0">
    {if $HOME_STUFF.Details.Header|@count > 0}
        <tr style="position: sticky; top:0px;z-index:1;padding-left: 25px;">
            {foreach item=header from=$HOME_STUFF.Details.Header }
                <th class="ld-stuff-secondtit">{$header}</th>
            {/foreach}
        </tr>
    {/if}

    {if $HOME_STUFF.Details.Entries|@count > 0}
    {assign var="m" value=0}
    {foreach item=row key=crmid from=$HOME_STUFF.Details.Entries name=entitylist}
        {if $m mod 2 eq '0'}
            <tr class="lvtColData" onmouseover="listOnMouseOver(ld(this),'On')"  onmouseout="listOnMouseOut(ld(this))">
                {else}
            <tr class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'On')">
        {/if}
        {assign var="i" value=0}
    		{foreach item=element from=$row}
          {assign var="j" value=$i++}
          {if $j eq 0 || $j eq 1}
            <td align="left" style="max-width: 300px;">{$element}</td>
          {else}
            <td align="left">{$element}</td>
          {/if}
  			{/foreach}
      </tr>
        {$m=$m+1}
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