<!--修改编码格式:统一编码：UTF-8-->
<table class="Total" width="100%" border="0" cellspacing="0" cellpadding="2">
  <tr>
	<td rowspan="2">
        <!--来电总数/接听总数-->
        <li class="call_li">
            <div style="float:left;padding-right: 10px;"><img border="0" src="themes/icon/calling.png"></div>
            <div style="float:left;margin-top: 3px;">
                <div  class="call_title" title="{'TOTALNUMBEROFCOME'|@getFixedLabel}">{'TOTALNUMBEROFCOME'|@getFixedLabel}</div>
                <div class="call_num">
                    <span>{$INCOUNT}</span>
                </div>
            </div>
        </li>
        <!--去电总数/接通总数-->
        <li class="call_li">
            <div style="float:left;padding-right: 10px;"><img border="0" src="themes/icon/callout.png"></div>
            <div style="float:left;margin-top: 3px;">
                <div  class="call_title" title="{'TOTALNUMBEROFGO'|@getFixedLabel}">{'TOTALNUMBEROFGO'|@getFixedLabel}</div>
                <div class="call_num">
                    <span>{$OUTCOUNT}</span>
                </div>
            </div>
        </li>
        <li style="float: right;margin-top: 30px;">
            <!--分页-->
            <div class="PageDiv0">
                <ul>
                    <li>{$recordListRange}</li>
                    {$NAVIGATION}
                </ul>
            </div>
            <!--分页  end-->
        </li>
    </td>
  </tr>
 </table>
<div class="clear"></div>	
<table class="listEntries" width="100%" border="0" cellspacing="1" cellpadding="0">
  <tr>
    <th><span title="{'USERS'|@getFixedLabel}">{'USERS'|@getFixedLabel}</span></th>
    <th width="10%"><span title="{'TIMES'|@getFixedLabel}">{'TIMES'|@getFixedLabel}</span></th>
    <th width="10%"><span title="{'Accounts'|@getFixedLabel}">{'Accounts'|@getTranstab}</span></th>
    <th width="10%"><span title="{'Contacts'|@getFixedLabel}">{'Contacts'|@getTranstab}</span></th>
      {*editor:gyq_79 reason:系统右上角呼叫中心报表优化 2018/9/10 14:16 *}
      <th><span title="{'ContactRecords'|@getFixedLabel}">{'ContactRecords'|@getTranstab}</span></th>
      <th width="10%"><span title="{'Potentials'|@getFixedLabel}">{'Potentials'|@getTranstab}</span></th>
      <th><span title="{'HelpDesk'|@getFixedLabel}">{'HelpDesk'|@getTranstab}</span></th>
    <th><span title="{'Vendors'|@getFixedLabel}">{'Vendors'|@getTranstab}</span></th>
    <th><span title="{'VendorContact'|@getFixedLabel}">{'VendorContact'|@getTranstab}</span></th>
    <th><span title="{'VendorContactRecords'|@getFixedLabel}">{'VendorContactRecords'|@getTranstab}</span></th>
    <th><span title="{'SERVICECONTRACTSTYPE'|@getFixedLabel}">{'SERVICECONTRACTSTYPE'|@getFixedLabel}</span></th>
    <th><span title="{'PhoneNumber'|@getFixedLabel}">{'PhoneNumber'|@getFixedLabel}</span></th>
   <th><span title="{'DURATION'|@getFixedLabel}">{'DURATION'|@getFixedLabel}</span></th>
     {* <th><span title="{'Recordfile'|@getFixedLabel}">{'Recordfile'|@getFixedLabel}</span></th>*}{*Liver 201611-10 原因是手机号码不能显示*号 bug:0025836: *}
    <th width="110px"><span >{'OPERATING'|@getFixedLabel}</span></th>
  </tr>
  {assign var=havarows value='no'}
  {foreach key=results name=resultslist item=call from=$RESULTLIST}
  {assign var=havarows value='yes'}
    {if $smarty.foreach.resultslist.iteration mod 2 eq '0'}
    <tr bgcolor="white" class="lvtColDataBj Hover" >
    {else}
    <tr bgcolor="white" class="Hover">
    {/if}
        <td nowrap="nowrap">
        <span title="{$call.UserName}">{$call.UserName}</span></td>
        <td nowrap="nowrap">
        <span title="{$call.BeginTime}">{$call.BeginTime}</span></td>
        <td>
        <span title="{$call.AccountName}">{$call.AccountName}</span></td>
        <td nowrap="nowrap">
		<span title="{$call.ContactName}">{$call.ContactName}</span></td>
        
        <td nowrap="nowrap">
            <a href="index.php?module=ContactRecords&parenttab=Parent Accounts&action=DetailView&record={$call.ContactrecordID}" title="{$call.ContactSubject}">{$call.ContactSubject}</a></td>
      <td nowrap="nowrap">
          <span title="{$call.PotentialNo}">{$call.PotentialNo}</span></td>
      <td nowrap="nowrap">
        <a href="index.php?module=HelpDesk&parenttab=Service&action=DetailView&record={$call.TicketID}" title="{$call.TicketNo}">{$call.TicketNo}</a></td>
        <td nowrap="nowrap">
        <a href="index.php?module=Vendors&parenttab=Purchase&action=DetailView&record={$call.VendorID}" title="{$call.VendorName}">{$call.VendorName}</a></td>
        <td nowrap="nowrap">
        <a href="index.php?module=VendorContact&parenttab=Purchase&action=DetailView&record={$call.VendorcontactsID}" title="{$call.VendorcontactsName}">{$call.VendorcontactsName}</a></td>
        <td nowrap="nowrap">

        <a href="index.php?module=VendorContactRecords&parenttab=Purchase&action=DetailView&record={$call.VendorContactRecordsID}" title="{$call.VendorContactrSubject}">{$call.VendorContactrSubject}</a></td>
        <td nowrap="nowrap">
        <span title="{$call.CallType}">{$call.CallType}</span></td>
        <td nowrap="nowrap">
        <span title="{$call.Phone}">{$call.Phone}</span></td>
         <td nowrap="nowrap">
        <span title="{$call.Time}">{$call.Time}</span></td>
        {*<td nowrap="nowrap">
        <span title="{$call.Soundrecordingfile}">{$call.Soundrecordingfile}</span></td>*}
        <td nowrap="nowrap">
            {*电话语音盒走原来的方法，其他走新方法*}
            {if $CENTERTYPE=='电话录音盒'}
            <a class="Anu3_a"  href="javascript:void(0);" onclick="play_click(this,'{$call.SoundrecordingfileNew}')">{'PLAYER'|@getFixedLabel}</font></font></a>
            {else}
            <a class="Anu3_a"  href ="{$call.SoundrecordingfileNew}"  title="{'PLAYER'|@getFixedLabel}"  target = "_blank">{'PLAYER'|@getFixedLabel}</a>
            {/if}
            <a class="Anu3_a"  href="javascript:void(0);" onclick="connect_record(this,'{$call.orign_id}')">{'CALLBUTLERCONNECTRECORD'|@getFixedLabel}</font></font></a>
        </td>
    </tr>
   {/foreach}
   {if $havarows eq 'yes'}
       <tr class="lvtColData" onmouseover="this.className='lvtColDataHover'" onmouseout="this.className='lvtColData'" style="color:#333" bgcolor="white">
           <td>&nbsp;</td>
       <td colspan="11" align="right">{"CURTOTALPAGE"|@getFixedLabel}</td>
       <td>{$SUBTOTALTIME}</td>
       <td></td>
       </tr>
        <tr class="lvtColData" onmouseover="this.className='lvtColDataHover'" onmouseout="this.className='lvtColData'" style="color:#333" bgcolor="white">
            <td>&nbsp;</td>
       <td colspan="11" align="right">{"ALLTOTALPAGE"|@getFixedLabel}</td>
       <td>{$TOTALTIME}</td>

       <td></td>
       </tr>
   {/if}
</table>
<div id="divFileCallButlerlist" style="display:none;">

</div>