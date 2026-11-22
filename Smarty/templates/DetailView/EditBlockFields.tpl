<table class="ld-createedit-tablecontent" cellspacing="0" cellpadding="0" border="0" style="width:100%;table-layout: fixed;">
  <tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>
  {assign var='basicinfocount' value=1}
  {foreach key=header item=data from=$BLOCKS name=blocknames}
    {if $header eq 'show_origin_information'}
      <tr>
        <td class="entryContentPad" colspan="4" style="padding:0px;width:100%;">
          <input name="relateOrderIdString" id="relateOrderId" value="{$RELATEDORDERIDSTRING}" type="hidden"/>
          <div class="" id="relatedorder_div" name="relatedorder_div">
            {$RELATEDORDERINFORMATION}
          </div>
        </td>
      </tr>
    {else}
      <tr>
        {assign var=addressinfo value='ADDRESSINFO'|@getFixedLabel}
        {if $basicinfocount == 1 && ($MODULE eq 'Accounts'||$MODULE eq 'Leads')}
          <td colspan=4 class="ld-from-headblock a">
            <div class="ld-from-headblock-title" tag="headblock-title">{$header}</div>
            {if $PUBLICACCOUNT eq 1 }<!--未分配公海-->
              {assign var=count value=1}
              <div class="rfloat padR100">
                  {if $LANGUAGETYPE eq 'en'}
                  <img src='themes/images/nodistribution_en.png' />
                  {else}
                  <img src='themes/images/nodistribution.png' />
                  {/if}
              </div>
            {elseif $PUBLICACCOUNT eq 2 || $PUBLICACCOUNT eq 3}<!--已分配公海-->
              {assign var=count value=1}
              <div class="rfloat padR100">
                  {if $LANGUAGETYPE eq 'en'}
                  <img src='themes/images/distribution_en.png' />
                  {else}
                  <img src='themes/images/distribution.png' />
                  {/if}
              </div>
            {/if}
          </td>
        {else}
          {if $header eq $addressinfo && $MODULE eq 'Accounts'}
            <td colspan=4 class="ld-from-headblock b">
              <div class="ld-from-headblock-title" tag="headblock-title">{$header}</div>
            </td>
          {elseif $header eq $addressinfo && $MODULE eq 'Contacts'}
            <td colspan=4 class="ld-from-headblock c">
              <div class="ld-from-headblock-title" tag="headblock-title">{$header}</div>
            </td>
          {elseif $MODULE eq 'CashBill'}
            <td colspan=4 class="ld-from-headblock d">
              <div class="ld-from-headblock-title" tag="headblock-title">{$header}
                {if $CashBillType eq 'cashbill'&&$basicinfocount eq 1}
                  <div class="rfloat padR100">
                    {if $LANGUAGETYPE eq 'en'}
                      <img src='themes/images/shoukuan.png'/>
                    {else}
                      <img src='themes/images/cashbill.png'/>
                    {/if}
                  </div>
                {else if $CashBillType eq 'debuction'&&$basicinfocount eq 1}
                  <div class="rfloat padR100">
                    {if $LANGUAGETYPE eq 'en'}
                      <img src='themes/images/yushou.png'/>
                    {else}
                      <img src='themes/images/debuction.png'/>
                    {/if}
                  </div>
                {/if}
              </div>
            </td>
          {else}
            <td colspan=4 class="ld-from-headblock e">
              <div class="ld-from-headblock-title" tag="headblock-title">{$header}</div>
              {if $sostatusImg neq ''&& $basicinfocount == 1}
                <div class="rfloat padT7 padR100" style="z-index:650;">
                  <img src='themes/images/{$sostatusImg}'/>
                </div>
              {elseif $cf_2444_image neq ''&&$basicinfocount == 1}
                <div class="rfloat padT7 padR100" style="z-index:650;">
                  <img src='themes/images/{$cf_2444_image}'/>
                </div>
              {/if}
            </td>
          {/if}
        {/if}
      </tr>
      {include file="DetailView/DisplayFields.tpl"}
      <!-- 赛克特殊处理： -->
			{if $header eq '进线信息' && $MODULE eq 'Accounts' && $VERSIONACCOUNT eq 'saic'}
				<tr>
					<td colspan=4 class="ld-from-headblock f" style="padding:0">
						{include file='saic/saic_log.tpl'}
					</td>
				</tr>
			{/if}
    {/if}
    {assign var="basicinfocount" value=$basicinfocount+1}
  {/foreach}
</table>