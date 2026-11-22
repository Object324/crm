	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th >序号</th>
                        <th >姓名</th>
                        <th >身份证号</th>
                        <th >手机号</th>
                        <th >银行全称</th>
                        <th >银行账号</th>
                        <th >理财合同号</th>
                        <th >计划名称</th>
                        <th >期限</th>
                        <th >合同金额</th><th >平台账户余额</th>
                        <th >利率</th>
                        <th >还款方式</th>
                        <th >银行到账日期</th>
                        
                        <th >充值到账户日期</th>
                        <th >对公充值金额</th>
                        <th >债权匹配日期</th>
                        
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 == 1}
                    <tr class="Hover">
                    {else}
                    <tr class="Bj Hover">
                    {/if}
                    <td>{$smarty.foreach.countRow.index+1}</td>
                    <td>{$arr.accountname}</td>
                    <td>{$arr.cf_1484}</td>
                    <td>{$arr.cf_1486}</td>
                    <td>{$arr.cf_1488}</td>
                    <td>{$arr.cf_1490}</td>
                    <td>{$arr.salesorder_no}</td>
                    <td>{$arr.productname}</td>           
                    <td>{$arr.cf_1504}</td>
                    <td align="right">{$arr.listprice|@setNumberFormat:2}</td><td>{$arr.sf998|@setNumberFormat:2}</td>
                    <td>{$arr.cf_1506}</td>
                    <td>{$arr.cf_1494}</td>
                    <td>{$arr.cf_1496}</td>
                    
                    <td>{$arr.cf_1497}</td>   
                    <td>{$arr.sf1077|@setNumberFormat:2}</td>        
                    <td>{$arr.cf_1499}</td>
                    
                    
                    </tr>
                    {/foreach}
               </tbody>
            </table>
            
        </div>