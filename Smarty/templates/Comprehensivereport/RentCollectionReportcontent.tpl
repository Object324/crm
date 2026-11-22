	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                        <tr>
                        <td >合计（单位：元）</td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td align="right">{$listValueAll.total|@setNumberFormat:4}</td>
                        <td ></td>
                        <td ></td>
                    </tr>
                    <tr>
                        <th >序号</th>
                        <th >城市</th>
                        <th >项目名称</th>
                        <th >资产类型</th>
                        <th >租赁合同编号</th>
                        <th >权利人</th>
                        <th >客户名称</th>
                        <th >房地坐落</th>
                        <th >建筑面积/平米</th>
                        <th >服务开始日期</th>
                        <th >服务到期日</th>
                        <th >已收租金/元</th>
                        <th >开票日期</th>
                        <th >收款日期</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 == 1}
                    <tr class="Hover">
                    {else}
                    <tr class="Bj Hover">
                    {/if}
                    <td>{$smarty.foreach.countRow.index+1}</td>
                    <td>{$arr.cf_1471}</td>
                    <td>{$arr.cf_1472}</td>
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.contract_no}</td>
                    <td>{$arr.cf_1545}</td>
                    <td>{$arr.accountname}</td>
                    <td>{$arr.productname}</td>           
                    <td>{$arr.cf_1470}</td>
                    <td>{$arr.servicecontracts_start_date}</td>
                    <td>{$arr.servicecontracts_end_date}</td>
                    <td align="right">{$arr.total|@setNumberFormat:4}</td>
                    <td>{$arr.cf_1569}</td>
                    <td>{$arr.cashbilldate}</td>
                    </tr>
                    {/foreach}
               </tbody>
            </table>
            
        </div>