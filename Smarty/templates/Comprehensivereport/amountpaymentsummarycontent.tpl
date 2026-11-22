     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="140%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
    <th>签约时间</th>
    <th>区域</th>
    <th>合同号</th>
    <th>项目名称</th>
    <th>客户名称</th>
    <th>销售</th>
    <th>服务开始时间</th>
    <th>服务结束时间</th>
    <th>服务月数</th>
    <th>合同总金额</th>
    <th>项目经理</th>
    <th>产品线A预计金额</th>
    <th>产品线B预计金额</th>
    <th>现金CP</th>
    <th>分包CP</th>
    <th>分包金额</th>
    <th>有效合同额</th>
    <th>1月份应收</th>
    <th>1月份回款</th>
    <th>1月有效回款</th>
    <th>1月回款日期</th>
    <th>2月份应收</th>
    <th>2月份回款</th>
    <th>2月有效回款</th>
    <th>2月份回款日期</th>
    <th>3月份应收</th>
    <th>3月份回款</th>
    <th>3月有效回款</th>
    <th>3月份回款日期</th>
    <th>01Q回款</th>
    <th>01Q有效回款</th>
    <th>4月份应收</th>
    <th>4月份回款</th>
    <th>4月有效回款</th>
    <th>4月份回款日期</th>
    <th>5月份应收</th>
    <th>5月份回款</th>
    <th>5月有效回款</th>
    <th>5月份回款日期</th>
    <th>6月份应收</th>
    <th>6月份回款</th>
    <th>6月有效回款</th>
    <th>6月份回款日期</th>
    <th>02Q回款</th>
    <th>02Q有效回款</th>
    <th>7月份应收</th>
    <th>7月份回款</th>
    <th>7月有效回款</th>
    <th>7月份回款日期</th>
    <th>8月份应收</th>
    <th>8月份回款</th>
    <th>8月有效回款</th>
    <th>8月份回款日期</th>
    <th>9月份应收</th>
    <th>9月份回款</th>
    <th>9月有效回款</th>
    <th>9月份回款日期</th>
    <th>03Q回款</th>
    <th>03Q有效回款</th>
    <th>10月份应收</th>
    <th>10月份回款</th>
    <th>10月有效回款</th>
    <th>10月份回款日期</th>
    <th>11月份应收</th>
    <th>11月份回款</th>
    <th>11月有效回款</th>
    <th>11月份回款日期</th>
    <th>12月份应收</th>
    <th>12月份回款</th>
    <th>12月有效回款</th>
    <th>12月份回款日期</th>
    <th>04Q回款</th>
    <th>04Q有效回款</th>
                    </tr>
                    
    {foreach key=results name=resultswork item=work from=$listValue}
    {if $smarty.foreach.countRow.iteration % 2 == 1}
    <tr class="Hover">
    {else}
    <tr class="Bj Hover">
    {/if}
      <td nowrap="nowrap">{$work.signed_data}</td>
    <td nowrap="nowrap">{$work.cf_1487}</td>
    <td nowrap="nowrap">{$work.salesorder_no}</td>
    <td nowrap="nowrap">{$work.cf_1486}</td>
    <td nowrap="nowrap">{$work.accountname}</td>
    <td nowrap="nowrap">{$work.last_name}</td>
    <td nowrap="nowrap">{$work.cf_1488}</td>
    <td nowrap="nowrap">{$work.cf_1489}</td>
    <td nowrap="nowrap">{$work.cf_1490}</td>
    <td nowrap="nowrap">{$work.total|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.smowner}</td>
    <td nowrap="nowrap">{$work.cf_1483|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.cf_1484|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.cf_1492|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.cf_1493|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.cf_1494|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.youxiaojine|@setNumberFormat:2}</td>
    
    <td nowrap="nowrap">{$work.1_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.1_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.1_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.1_cashbilldate}</td>
    
    <td nowrap="nowrap">{$work.2_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.2_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.2_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.2_cashbilldate}</td>
    
        <td nowrap="nowrap">{$work.3_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.3_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.3_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.3_cashbilldate}</td>
    
    <td nowrap="nowrap">{$work.1_shoukuan_j|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.1_youxiaohuikuan+$work.2_youxiaohuikuan+$work.3_youxiaohuikuan|@setNumberFormat:2}</td>
    
        <td nowrap="nowrap">{$work.4_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.4_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.4_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.4_cashbilldate}</td>
    
        <td nowrap="nowrap">{$work.5_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.5_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.5_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.5_cashbilldate}</td>
    
        <td nowrap="nowrap">{$work.6_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.6_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.6_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.6_cashbilldate}</td>
    
    <td nowrap="nowrap">{$work.2_shoukuan_j|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.4_youxiaohuikuan+$work.5_youxiaohuikuan+$work.6_youxiaohuikuan|@setNumberFormat:2}</td>
    
        <td nowrap="nowrap">{$work.7_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.7_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.7_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.7_cashbilldate}</td>
    
        <td nowrap="nowrap">{$work.8_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.8_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.8_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.8_cashbilldate}</td>
    
            <td nowrap="nowrap">{$work.9_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.9_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.9_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.9_cashbilldate}</td>
    
        <td nowrap="nowrap">{$work.3_shoukuan_j|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.7_youxiaohuikuan+$work.8_youxiaohuikuan+$work.9_youxiaohuikuan|@setNumberFormat:2}</td>
    
            <td nowrap="nowrap">{$work.10_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.10_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.10_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.10_cashbilldate}</td>
    
            <td nowrap="nowrap">{$work.11_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.11_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.11_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.11_cashbilldate}</td>
    
            <td nowrap="nowrap">{$work.12_huikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.12_shoukuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.12_youxiaohuikuan|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.12_cashbilldate}</td>
    
        <td nowrap="nowrap">{$work.4_shoukuan_j|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.10_youxiaohuikuan+$work.11_youxiaohuikuan+$work.12_youxiaohuikuan|@setNumberFormat:2}</td>            
                    </tr>
                    {/foreach}
               </tbody>
            </table>
            
        </div>
    </div>
    

</div>
