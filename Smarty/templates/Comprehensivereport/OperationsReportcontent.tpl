	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th >序号</th>
                        <th >姓名</th>
                        <th >身份证号</th>
                        <th >银行全称</th>
                        <th >银行账号</th>
                        <th >理财师姓名</th>
                        <th >财富中心</th>
                        <th >财富地区</th>
                        <th >财富部门</th>
                        <th >手机号</th>
                        <th >电子邮件</th>
                        <th >通讯地址</th>
                        <th >合同编码</th>
                        <th >计划名称</th>
                        <th >期限</th>
                        <th >合同金额</th>
                        
                        <th >平台账户余额</th><th >对公充值</th>
                        <th >利率</th>
                        <th >还款方式</th>
                        <th >银行到账日期</th>
                        <th >充值到账户日期</th>
                        <th >债权匹配状态</th>
                        <th >债权匹配日期</th>
                        <th >合同收到时间</th>
                        <th >纸质回执寄送时间</th>
                        <th >审批状态</th>
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
                    <td>{$arr.cf_1488}</td>
                    <td>{$arr.cf_1490}</td>
                    <td>{$arr.last_name}</td>
                    <td>{$arr.zhongxin}</td>
                    <td>{$arr.diqu}</td> 
                    <td>{$arr.groupname}</td>
                    <td>{$arr.phone_mobile}</td>           
                    <td>{$arr.email1}</td>
                    <td>{$arr.address_street}</td>
                    <td>{$arr.salesorder_no}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.cf_1504}</td>
                    <td align="right">{$arr.listprice|@setNumberFormat:2}</td>
                    
                    <td>{$arr.sf998|@setNumberFormat:2}</td><td>{$arr.sf1077|@setNumberFormat:2}</td>
                    <td>{$arr.cf_1506}</td>
                    <td>{$arr.cf_1494}</td>
                    <td>{$arr.cf_1496}</td>
                    <td>{$arr.cf_1497}</td>           
                    <td>{$arr.cf_1498}</td>
                    <td>{$arr.cf_1499}</td>
                    <td>{$arr.cf_1500}</td>
                    <td>{$arr.cf_1501}</td>
                    <td>{$arr.approvestatus}</td>
                    </tr>
                    {/foreach}
               </tbody>
            </table>
            
        </div>