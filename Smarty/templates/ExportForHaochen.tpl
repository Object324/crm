<form name="menu" action="index.php" method="post" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
    <input type="hidden" name="parenttabid" value="{$PARENTTABID}"/>	
    <table class="settingPopTable settingPopTableNoBot" border="0" cellpadding="0" cellspacing="0" width="100%">
      	<tr>
			<td width="40%" align="right">起始日期：</td>
			<td width="60%" align="left">{$start_date}</td>
		</tr>
		<tr>
			<td width="40%" align="right">结束日期：</td>
			<td width="60%" align="left">{$end_date}</td>
		</tr>
		<tr>
			<td width="40%" align="right">合同总数：</td>
			<td width="60%" align="left">{$count}</td>
		</tr>
		<tr>
			<td width="40%" align="right">拆分前合同总额（不含税）：</td>
			<td width="60%" align="left">{$before_amount}</td>
		</tr>
		<tr>
			<td width="40%" align="right">拆分后合同总额（不含税）：</td>
			<td width="60%" align="left">{$after_amount}</td>
		</tr>
		<input type="hidden" name="search_type" value="{$search_type}">
		<input type="hidden" name="exportformat" value="{$exportformat}"> 
    </table>
	
  </form>
