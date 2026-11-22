
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th >合同签约日期</th>
                        <th >合同名称</th>
                        <th >合同金额</th>
                        <th >已收款</th>
                        <th >未收款</th>
                        <th >材料成本汇总金额</th>
                        <th >人工费金额</th>
                        <th >人工费用未付金额</th>
                        <th >费用报销金额</th>
                        <th >其他费用单金额</th>
                        <th >费用合计金额</th>
                        <th >税金</th>
                        <th >毛利</th>
                        <th >毛利率%</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 == 1}
                    <tr class="Hover">
                    {else}
                    <tr class="Bj Hover">
                    {/if}
                    <td>{$arr.signed_data}</td>
                    <td>{$arr.SUBJECT}</td>
                    <td align="right">{$arr.total|@setNumberFormat}</td>
                    <td align="right">{$arr.yishou|@setNumberFormat}</td>
                    <td align="right">{$arr.weishou|@setNumberFormat}</td>
                    <td align="right">
                    <a onclick="yijiapopup1({$arr.salesorderid},1);">
					{$arr.taxprice|@setNumberFormat}</a></td>
                    <td align="right"><a onclick="yijiapopup1({$arr.salesorderid},2);">
                    {$arr.fees|@setNumberFormat}</a></td>
                    <td align="right">{$arr.rengongweifu|@setNumberFormat}</td>
                    <td align="right"><a onclick="yijiapopup1({$arr.salesorderid},3);">
                    {$arr.expense_total|@setNumberFormat}</a></td>
                    <td align="right"><a onclick="yijiapopup1({$arr.salesorderid},4);">
                    {$arr.commisson_taxprice|@setNumberFormat}</a></td>
                    <td align="right">{$arr.feiyongheji|@setNumberFormat}</td>
                    <td align="right">{$arr.taxamount|@setNumberFormat}</td>
                    <td align="right">{$arr.maoli|@setNumberFormat}</td>
                    {if $arr.signed_data eq '合计金额'}
                    <td align="right"></td>  
                    {else}
                    <td align="right">{$arr.maolilv|@setNumberFormat}%</td>           
                    {/if}  
                    </tr>
                    {/foreach}
               </tbody>
            </table>
            
        </div>
