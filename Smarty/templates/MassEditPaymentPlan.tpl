<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script type='text/javascript' src='{$JSURL}include/js/user_approveby.js'></script>
<form method="post" action="index.php" name="frmpaymentplan" class="noMargin">


<div class="billdate">
    <span>{$ARRFIELDLABEL.cashbilldate}:</span>
    <select class="borderALL" name="CashBillDate" onchange="ChangeCashBilldate(this)">
       <option value="curdate">{'CURRENTDATE'|@getFixedLabel}</option>
       <option value="plandate">{$PLANDATELABEL}</option>
       <option value="customdate">{'custom'|@getFixedLabel}</option>
    </select>
    <input type='text' style="display:none" size='15' onClick="WdatePicker()" class="Wdate" readonly='true' name='cashdate' value='' id='cashdate'/>
</div>
{include file='EditViewHidden.tpl'}
<input  type="hidden" name="module" value="CashBill"/>
<input  type="hidden" name="action" value="MassAdd"/>
<input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}"/>
<div style="max-height:450px;overflow-y:auto;">
<table id="MMassCashBill" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <th align="center" valign="middle"><input name="" type="checkbox" value="" checked="checked" onclick="chkAllPayment(this)" /></th>
    <th align="center" valign="middle">{$ARRFIELDLABEL2.paymentplan_no}</th>
    <th align="center" valign="middle">{$ACCOUNTNAMELABEL}</th>
    <th align="center" valign="middle">{$AMOUNTLABEL}</th>
    <th align="center" valign="middle">{$ACTUALAMOUNTLABEL}</th>
    <th align="center" valign="middle">{'THISCOLLECTION'|@getFixedLabel}</th>
    <th align="center" valign="middle">{'Currency'|@getFixedLabel}</th>
    {*<th align="center" valign="middle">{$ARRFIELDLABEL.iscashbill}</th>*}
    <th align="center" valign="middle">{$ARRFIELDLABEL.paymentmethod}</th>
    <th align="center" valign="middle">{$ARRFIELDLABEL.bankaccountsetid}</th>
  </tr>
  
  {$MASS_EDIT}
 
</table>
</div>


</form>