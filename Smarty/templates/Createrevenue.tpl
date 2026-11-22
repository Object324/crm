<div>
    <form action="index.php" method="post" name="form" id="form">
    <input type="hidden" value="{$MODULE}" name="frommodule" />
      <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            {assign var = 'listvalue_year'  value = $listvalue.year}
            {assign var = 'listvalue_mouth'  value = $listvalue.mouth}
            <tr>
                <td width="20%" align="right">
                <font color="red">*</font>
                {$YEAR}</td>
                <td width="20%" align="left">
                <select name="revenueyear" class="commonSelect" style="width:90%;" >
                {foreach item =years from = $listvalue_year}
                    <option value="{$years.value}" {if $years.value eq $FIELDVALUES.cf_4288}selected{/if} >{$years.value}</option>
                {/foreach}
                </select>
                </td>
                <td width="40%" align="left"></td>
            </tr>
            <tr>
                <td width="30%" align="right">
                <font color="red">*</font>
                {$MOUTH}</td>
                <td width="30%" align="left">
                <select name="revenuemouth" class="commonSelect" style="width:90%;"  >
                    <option value="" selected></option>
                {foreach item =mouths from = $listvalue_mouth}
                    <option value="{$mouths.value}" {if $mouths.value eq $FIELDVALUES.cf_4285}selected{/if} >{$mouths.value}</option>
                {/foreach}
                </select>
                </td>
                <td width="40%" align="left"></td>
            </tr>
            <tr>
                <td width="30%" align="right">
                <font color="red">*</font>
                {$AMOUNT}</td>
                <td width="30%" align="left">
                <select name="amount" class="commonSelect" style="width:90%;" onchange="input_money()" >  
                    <option value="module_amount" >{$LABEL}</option>
                    <option value="input_amount" selected>{'MANUALINPUTMONEY'|@getFixedLabel}</option>
                </td>
                <td width="40%" align="left">
                <input id="name" name="revenuemoney" type="text" style="display:inline;"  class="detailedViewTextBox" placeholder="{'INPUTMONEY'|@getFixedLabel}" value="{$FIELDVALUES.cf_4284}"/>
                </td>
            </tr>
      </table>
    </form>
</div>
