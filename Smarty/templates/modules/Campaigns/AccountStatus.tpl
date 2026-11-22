<div id="campaign_changeaccountstatus" name="campaign_changeaccountstatus">
  <table class="DetailContentTable" width="100%" border="0" cellspacing="1" cellpadding="0">
    <tr>
      <td align="right" width="20%" class="DetailedTd1Label">{$ACCOUNTNAMELABEL}</td> 
      <td align="left" width="30%" class="DetailedTd2Info">{$ACCOUNTNAME}</td>
    </tr>
    <tr>
      {assign var='usefldlabel' value={'STATUS'|@getFixedLabel}}
      {assign var='uitype' value=15}
      {assign var='fldname' value='campaignaccountrelstatus'}
      {assign var='MODULE' value='Accounts'}
      {assign var='fldvalue' value=$STATUSCOMBOXVALUE}
      {include file='DetailView/PickList.tpl'}
    </tr>
  </table>
</div>