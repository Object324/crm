
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                <tr>
                        <th rowspan='2' >合同名称</th>
                        <th colspan='8'>材料成本明细金额</th>
                        <th colspan='3'>人工费申请明细金额</th>
                        <th colspan='2'>费用报销明细金额</th>
                        <th colspan='2'>其他费用单明细金额</th>
                    </tr>
                    <tr>
                        <th >产品名称</th>
                        <th >产品编号</th>
                        <th >产品类别</th>
                        <th >规格型号</th>
                        <th >出库数量</th>
                        <th >出库单价</th>
                        <th >出库金额</th>
                        <th >计量单位</th>
                        <th >施工说明</th>
                        <th >人工费金额</th>
                        <th >人工费用未付金额</th>
                        <th >报销人</th>
                        <th >报销金额合计</th>
                        <th >其他费用类别</th>
                        <th >金额</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 == 1}
                    <tr class="Hover">
                    {else}
                    <tr class="Bj Hover">
                    {/if}
                    <td>{$arr.SUBJECT}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.product_no}</td>
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.productsheet}</td>
                    <td>{$arr.quantity}</td>
                    <td align="right">{$arr.outboundorder_taxprice}</td>
                    <td align="right">{$arr.taxprice}</td>
                    <td>{$arr.usageunit}</td>
                    <td>{$arr.solution}</td>
                    <td align="right">{$arr.fees}</td>
                    <td align="right">{$arr.rengongweifu}</td>  
                    <td>{$arr.last_name}</td>
                    <td align="right">{$arr.expense_total}</td>  
                    <td>{$arr.commissiontype}</td>   
                    <td align="right">{$arr.commisson_taxprice}</td>          
                        
                    </tr>
                    {/foreach}
               </tbody>
            </table>
            
        </div>
    </div>
