<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/InventoryLedger/InventoryLedger.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script type="text/javascript">
function submitfrom()
{ldelim}
    if(document.getElementById("jscal_field_createdate").value > document.getElementById("jscal_field_enddate").value)
    {ldelim}
        var confirm_str = arrJsPopLabel['OPENINGDATECANOTGREATEENDDATE'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    {rdelim}    
{rdelim}
function displaycondtype_click(keys)
{ldelim}
        var obj = document.getElementById(keys+'_div');
	obj.style.display = (obj.style.display == 'none')?'':'none';
{rdelim}

function setcondtype_click(objid,objname,keys)
{ldelim}	
	document.getElementById('set'+keys).innerHTML = objname+"&nbsp;&nbsp;<img border=0 src='themes/softed/images/arrow_down.gif'>";
	if(keys == 'searchcol')
    {ldelim}
		document.basicSearch.searchcol.value = objid;
	{rdelim}
	document.getElementById(keys+'_div').style.display = 'none';
{rdelim}
function returnSubmit(event)
{ldelim}
    var e = event || window.event;
    if(e.keyCode == 13)
    {ldelim}
        massdelete.submit();
    {rdelim}
{rdelim}
</script>
{*{include file='Buttons_List.tpl'}*}
<div id="ledger">
<!--切换导航-->
	<div class="D_Tab_div_more tabHieght" id="tabWareHouse">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td valign="top" class="L">
			<ul class="Tab_div_more_ul">
				<li><a onclick="getWarehouse(0,this);return false;" {if $WAREHOUSEID eq 0} class="On on" {else} class="on" {/if} >{'ALLWAREHOUSE'|@getFixedLabel}</a></li>
			{foreach item=value from=$WAREHOUSES} 
				{if $value.id eq $WAREHOUSEID}
					<li><a  onclick="getWarehouse({$value.id},this);return false;" class="On" >{$value.name}</a></li>
				{else}
					<li><a  onclick="getWarehouse({$value.id},this);return false;">{$value.name}</a></li>
				{/if}
			{/foreach}
			{if $MOREWAREHOUSES|@count gt 0}
				{if $WAREHOUSEID neq ''}
					{assign var=c value='On'}
				{else}
					{assign var=c value='on'}
				{/if} 
				<li>        
				<a id="morewarehouseid" class="{$c}">
				{'MORE'|@getFixedLabel}:
				</a>
				</li>	
			{/if}
			</ul>
			{if $MOREWAREHOUSES|@count gt 0}
				<div id="ware_select_more" class="tab-more">
					{include file='MoreWareHouseSelect.tpl'}
				</div>
			{/if}
		</td>
	  </tr>
	</table>
	</div>
</div>
<div class="clear"></div>
<div id="divInital" class="LdPop_box LdPopWidth500px" style="display:none;width:800px;position:absolute;z-index: 2147483647;"></div>
<!--切换导航  end-->

<form name="massdelete" method="POST" id="massdelete" onsubmit=" return submitfrom();">
<input id="excludedRecords" type="hidden" value="" name="excludedRecords" />
<input id="allselectedboxes" type="hidden" value="" name="allselectedboxes" />
<input id="numOfRows" type="hidden" value="" name="numOfRows" />
<input id="warehouseid" type="hidden" value="{$WAREHOUSEID}" name="warehouseid" />
<input type="hidden" id="idlist" name="idlist" value="" />    
    <div class="D_search">
        <ul>
            <li><span><font style="font-size:14px; font-weight:bold;">{'SEARCH'|@getFixedLabel}</font></span></li>
            <li>
                {'PRICEBASIS'|@getFixedLabel}
				{if $PRODUCTFIELDLABELS.unit_price eq '' && $PRODUCTFIELDLABELS.procostprice eq ''}

				{else}
                <select style="width:70px;height:25px;" name="unprice">
					{if $PRODUCTFIELDLABELS.unit_price neq ''}
						<option value="0" {if $UNPRICE eq 0} selected="selected" {/if}>{$PRODUCTFIELDLABELS.unit_price}</option>
					{/if}
					{if $PRODUCTFIELDLABELS.procostprice neq ''}
						<option value="1" {if $UNPRICE eq 1} selected="selected" {/if}>{$PRODUCTFIELDLABELS.procostprice}</option>
					{/if}
                </select>
				{/if}
            
            </li>
            <li>
				{if $PRODUCTFIELDLABELS.productname eq '' && $PRODUCTFIELDLABELS.product_no eq '' && $PRODUCTFIELDLABELS.productsheet eq '' && $PRODUCTFIELDLABELS.productcategory eq ''}
				{else}
                &nbsp;
                <select name="productinfo" style="height:25px;">
					{if $PRODUCTFIELDLABELS.productname neq ''}
						<option value="0" {if $PRODUCTINFO == 0} selected="selected" {/if}>{$PRODUCTFIELDLABELS.productname}</option>
					{/if}
					{if $PRODUCTFIELDLABELS.product_no neq ''}
						<option value="1" {if $PRODUCTINFO == 1} selected="selected" {/if}>{$PRODUCTFIELDLABELS.product_no}</option>
					{/if}
					{if $PRODUCTFIELDLABELS.productsheet neq ''}
						<option value="2" {if $PRODUCTINFO == 2} selected="selected" {/if}>{$PRODUCTFIELDLABELS.productsheet}</option>
					{/if}
					{if $PRODUCTFIELDLABELS.productcategory neq ''}
						<option value="3" {if $PRODUCTINFO == 3} selected="selected" {/if}>{$PRODUCTFIELDLABELS.productcategory}</option>
					{/if}
                </select>
				{/if}
            </li>
            <li>
                &nbsp;<input type="text" style="height:18px;margin-top: -1px;" value="{$PRODUCTDETAIL}" name="productdetail" id="productdetail" size="20" onkeyup="returnSubmit(event)" />
            </li>
            <li>
                <span style="padding-right: 5px;">{'BEGINNING'|@getFixedlabel}</span>
                <span><input name="createdate" tabindex="" id="jscal_field_createdate" type="text" style="border:1px solid #bababa;margin-top:5px;height: 21px;"  fieldonly='0'  size="15" maxlength="11" value="{$FIRSTDAY}" onClick="WdatePicker()" class="Wdate"/></span>
                
            </li>
            <li>
                <span style="padding-right: 5px;">{'CLOSING'|@getFixedLabel}</span>
                <span><input name="enddate" tabindex="" id="jscal_field_enddate" type="text" style="border:1px solid #bababa;margin-top:5px;height: 21px;"  fieldonly='0'  size="15" maxlength="11" value="{$LASTDAY}" onClick="WdatePicker()" class="Wdate"/></span>
              
            </li>
            
            <li style="margin-top: -2px;">
                <input type="hidden" value="1" id="hiddenledger" name="hiddenledger" />
                <input class="saveauto" type="submit" value="{'GEMERATEINLEDGER'|@getFixedLabel}" name="button" >
                {if $isExport eq 'yes'}
                <input class="saveauto" type="button" value="{'EXPORT'|@getFixedLabel}" name="button" onclick="return exportInventoryLedger('{$FIRSTDAY}','{$LASTDAY}','{$UNPRICE}','{$PRODUCTINFO}','{$PRODUCTDETAIL}','{$LEDGER}')">
                {/if}
            </li>
        </ul>
    </div>
   <div class="clear"></div>
    <div id="ListViewContents" style="width:100%;position:relative;">
    {if $smarty.request.ajax neq ''}
    &#&#&#{$ERROR}&#&#&#
    {/if}
    <table id="producttable" class="listEntries fir-center" border="0" cellspacing="1" cellpadding="0" width="100%">
    <tr>
        <th>#</th>
        <th>{'WAREHOUSE'|@getFixedLabel}</th>
        <th>{$PRODUCTFIELDLABELS.productname}</th>
        <th>{$PRODUCTFIELDLABELS.product_no}</th>
        <th>{$PRODUCTFIELDLABELS.productsheet}</th>
        <th>{$PRODUCTFIELDLABELS.productcategory}</th>
        <th>{'OPENNUMBER'|@getFixedLabel}</th>
        <th>{'OPENAMOUNT'|@getFixedLabel}</th>
        <th>{'DURINGSTORAGE'|@getFixedLabel}</th>
        <th>{'AMOUNTSTORAGE'|@getFixedLabel}</th>
        <th>{'DURINGLIBRARY'|@getFixedLabel}</th>
        <th>{'AMOUNTLIBRARY'|@getFixedLabel}</th>
        <th>{'ENDNUMBER'|@getFixedlabel}</th>
        <th>{'ENDAMOUNT'|@getFixedLabel}</th>
    </tr>
    {assign var="i" value=0}
    {foreach item=warevalue key=id from=$InventoryInfo name=inventoryinfoloop}
            {assign var="j" value=$i++}
            {foreach item=value name=warevalues key=ware_id from=$warevalue}
            {if $smarty.foreach.warevalues.iteration mod 2 eq '1'}
              <tr id="row_{$j}_{$value.id}" class="lvtColData" onmouseout="setTrColorOut('row_{$j}_{$value.id}','{$j}_{$value.id}','{$j}_{$value.id}','on');" onmouseover="setTrColor('row_{$j}_{$value.id}','{$j}_{$value.id}','{$j}_{$value.id}');">
            {else}
              <tr id="row_{$j}_{$value.id}" class="lvtColDataBj" onmouseout="setTrColorOut('row_{$j}_{$value.id}','{$j}_{$value.id}','{$j}_{$value.id}','On');" onmouseover="setTrColor('row_{$j}_{$value.id}','{$j}_{$value.id}','{$j}_{$value.id}');">
            {/if}
                <td><span title="{$value.id}">{$value.id}</span></td>
                <td><span title="{$value.name}">{$value.name}</td>
                <td><span title="{$value.productname}"><a href="index.php?module=Products&parenttab=Tools&action=DetailView&record={$value.productid}" target="_blank">{$value.productname}</a></span></td>
                <td><span title="{$value.product_no}">{$value.product_no}</span></td>
                <td><span title="{$value.productcode}">{$value.productcode}</span></td>
                <td><span title="{$value.productcategory}">{$value.productcategory}</span></td>
                <td align="right"><span title="{$value.initalnum}">{$value.initalnum}</span></td>
                <td align="right"><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span> <span title="{$value.initalprice}">{$value.initalprice}</span></td>
                <td align="right"><span title="{$value.beginingnum}">{$value.beginingnum}</span></td>
                <td align="right"><span style="color:#000000" title="{$value.beginingprice}">{''|@getDefaultCurrecySymbol}</span> <span title="{$value.beginingprice}">{$value.beginingprice}</span></td>
                <td align="right"><span title="{$value.outputnum}">{$value.outputnum}</span></td>
                <td align="right"><span style="color:#000000" title="{$value.outputprice}">{''|@getDefaultCurrecySymbol}</span> <span title="{$value.outputprice}">{$value.outputprice}</span></td>
                <td align="right"><span title="{$value.endnum}">{$value.endnum}</span></td>
                <td align="right"><span style="color:#000000" title="{$value.endprice}">{''|@getDefaultCurrecySymbol}</span> <span title="{$value.endprice}">{$value.endprice}</span></td>
            </tr>
            {/foreach}
        {if $WAREHOUSEID == 0}
        <tr bgcolor="white" class="Subtotal" align="right">
            <td colspan="2" align="left">{'SUBTOTAL'|@getFixedLabel}:</td>
            <td colspan="4">&nbsp;</td>
            <td>{$COUNTARRAY[$id].initalnumCount}</td>
            <td><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span> {$COUNTARRAY[$id].initalpriceCount}</td>
            <td>{$COUNTARRAY[$id].beginingnumCount}</td>
            <td><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span> {$COUNTARRAY[$id].beginingpriceCount}</td>
            <td>{$COUNTARRAY[$id].outputnumCount}</td>
            <td><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span> {$COUNTARRAY[$id].outputpriceCount}</td>
            <td>{$COUNTARRAY[$id].endnumCount}</td>
            <td><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span> {$COUNTARRAY[$id].endpriceCount}</td>
        </tr>
        {/if}
    {/foreach}
	<!--{*
	    判断list列表循环次数，如果循环了0次，则表明没有数据，不显示总计行
	    @reason 0011711 库存台账界面：当序列表中没有任何信息时，不应该显示“合计行”
	    @author tujt 2014-09-24
	*}-->
	{if $smarty.foreach.inventoryinfoloop.iteration > 0}
		<tr class="ALLTotal fontbold" align="right" bgcolor="white">
			<td colspan="2" align="left">{'TOTAL'|@getFixedLabel}:</td>
			<td colspan="4">&nbsp;</td>
			<td>{$SUM[0]}</td>
			<td><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span> {$SUM[1]}</td>
			<td>{$SUM[2]}</td>
			<td><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span>{$SUM[3]}</td>
			<td>{$SUM[4]}</td>
			<td><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span>{$SUM[5]}</td>
			<td>{$SUM[6]}</td>
			<td><span style="color:#000000">{''|@getDefaultCurrecySymbol}</span>{$SUM[7]}</td>
		</tr>
	{else}
		<tr>
		   <td style="background-color:#FFF;height:340px" align="center" colspan="14">
				<div class='noResultBG' >   		 
				   <div class='noResultContent'> 
						<div  class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</div>
				   </div>      
				</div>
			</td>
		</tr>
	{/if}
    
    </table>
 </div>
    
</form>

</td>
</tr>
</table>
</div>