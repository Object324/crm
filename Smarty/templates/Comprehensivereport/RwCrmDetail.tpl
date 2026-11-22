<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>销售统计表</title>
</head>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
{literal}
<style>
* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:5px;}
.DivBox_top { width:100%; height:30px;}
.DivBox_top h1 { float:left; font-size:20px; color:#666; line-height:30px;}

.DivBox_Center { width:100%; overflow:hidden; padding:10px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px; overflow:hidden;}
.listTableRowBlank2{text-indent:24px;}
.listTableRowBlank4{text-indent:60px;}
.listTableRowRight{text-align:right;}
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{$year}{$YEAR}销售统计表——总表: </h1>
    </div>
     <!--查找条件--> 
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList0" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th>月份</th>
                        <th>1</th>
                        <th>2</th>
                        <th>3</th>
                        <th>4</th>
                        <th>5</th>
                        <th >6</th>
                        <th >7</th>
                        <th >8</th>
                        <th >9</th>
                        <th >10</th>  
                        <th >11</th>
                        <th >12</th>  
                        <th >合计</th>
                        <th >占比累计</th>              
                    </tr>
                    <tr>
                        <td class="listTableRow">销售额(元)</td>
                        {foreach from=$SALELIST item=arr}
                           {$TDRIGHT}{$arr}</td>
                        {/foreach}
                        <td class="listTableRowRight">{$SALETOTAL}</td>
                        <td class="listTableRowRight"></td>
                        </tr>
                        <tr>
                        <td class="listTableRow">同比增长</td>
                        {foreach from=$SALEADDLIST item=arr}
                           {$TDRIGHT}{$arr}</td>
                        {/foreach}
                        <td class="listTableRowRight">{$ADDTOTAL}</td>
                        <td class="listTableRowRight"></td>
                        </tr>
                        <tr>
                        <td class="listTableRowBlank2">其中：新单</td>
                        {foreach from=$NEWSALE item=arr}
                        {if $arr!=".00"}
                           {$TDRIGHT}{$arr}</td>
                        {else}
                            {$TDRIGHT}0.00</td>
                        {/if}
                        {/foreach}
                        <td class="listTableRowRight">{$NEWSALETOTAL}</td>
                        <td class="listTableRowRight">{$NEWPERCENT}</td>
                        </tr>
                        <tr>
                        <td class="listTableRowBlank4">返单</td>
                        {foreach from=$BACKSALE item=arr}
                        {if $arr!='.00'}
                           {$TDRIGHT}{$arr}</td>
                        {else}
                            {$TDRIGHT}0.00</td>
                        {/if}
                        {/foreach}
                        <td class="listTableRowRight">{$BACKSALETOTAL}</td>
                        <td class="listTableRowRight">{$OLDPERCENT}</td>
                        </tr>
                        {foreach from=$ATYPESALE key=key1 item=arr}
                            <tr>
                            {foreach from=$arr key=key2 item=arr2}
                            {if $key2!=0}<td class="listTableRowRight">{elseif $key1==0&&$key2==0}<td class="listTableRowBlank2">{else}<td class="listTableRowBlank4">{/if}{$arr2}</td>
                            {/foreach}
                            </tr>
                        {/foreach}
                        {foreach from=$CHINAAREA key=key1 item=arr}
                            <tr>
                            {foreach from=$arr key=key2 item=arr2}
                            {if $key2!=0}<td class="listTableRowRight">{elseif $key1==0&&$key2==0}<td class="listTableRowBlank2">{else}<td class="listTableRowBlank4">{/if}{$arr2}</td>
                            {/foreach}
                            </tr>
                        {/foreach}
                        <tr>
                        <td class="listTableRow">资金回笼</td>
                        {foreach from=$CASHBILLLIST item=arr}
                           {$TDRIGHT}{$arr}</td>
                        {/foreach}
                        <td class="listTableRowRight">{$CASHBILLTOTAL}</td>
                        <td class="listTableRowRight"></td>
                        </tr>
                        <tr>
                        <td class="listTableRow">资金回笼占比</td>
                        {foreach from=$CASHP item=arr}
                           {$TDRIGHT}{$arr}</td>
                        {/foreach}
                        <td class="listTableRowRight">{$CASHBILLTOTALP}</td>
                        <td class="listTableRowRight"></td>
                        </tr>
                        {foreach from=$CHINAAREACASHBILL key=key1 item=arr}
                            <tr>
                            {foreach from=$arr key=key2 item=arr2}
                            {if $key2!=0}<td class="listTableRowRight">{elseif $key1==0&&$key2==0}<td class="listTableRowBlank2">{else}<td class="listTableRowBlank4">{/if}{$arr2}</td>
                            {/foreach}
                            </tr>
                        {/foreach}
                        <tr>
                        <td class="listTableRow">应收账款余额(元)</td>
                        {foreach from=$BALANCE item=arr}
                           {$TDRIGHT}{$arr}</td>
                        {/foreach}
                        <td class="listTableRowRight">{$BTOTAL}</td>
                        <td class="listTableRowRight"></td>
                        </tr>
                        <tr>
                </tbody>
            </table>
            
        </div>
    </div>
</div>
</body>
</html>