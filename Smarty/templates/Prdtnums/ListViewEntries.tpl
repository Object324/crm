{if $smarty.request.ajax neq ''}
&#&#&#{$ERROR}&#&#&#
{/if}
<div class="divButtons" style="border-top: 1px solid #e5e5e5;">
    <!--按钮-->
    <ul class="D_btn_box">
        {if $STARTED eq 1}
            <li class="D_anu_a D_menu_hova " onclick="return updateProductNum(1);">
                <a title="{'TEMPORARYTIPS'|@getFixedLabel}" >
                    <b class="icon-homeimg icon-updateNum"></b><span>{'TEMPORARY'|@getFixedLabel}</span>
                </a>
            </li>
            <li class="D_anu_a D_menu_hova " onclick="return updateProductNum(0);">
                <a title="{'Save_and_confirm_TIPS'|@getFixedLabel}" >
                    <b class="icon-homeimg icon-endNum"></b><span>{'Save_and_confirm'|@getFixedLabel}</span>
                </a>
            </li>
        {/if}    						
    </ul>
    <!--分页-->
    <div class="PageDiv0">                   	    
        <ul>
            <li>{$RECORDLISTRANGMSG}</li>
            {$NAVIGATION}
        </ul>                       
    </div>
</div>
<div class="clear"></div>
<table id="producttable" border="0" cellspacing="1" cellpadding="0" width="100%" class="listEntries">
	<tr class="windLayerHead" height="25px">
		{if $STARTED eq 1}
        <th class="firstChild">	
            <input type="checkbox" onclick="toggleSelect(this.checked,'selected_id');updateAllQtyinstock()" name="selectall"/>
        </th>
		{/if}
        <th width="30%" >{$PRODUCTFIELDLABELS.productname}</th>
        <th width="15%">{$PRODUCTFIELDLABELS.product_no}</th>
        <th width="15%">{$PRODUCTFIELDLABELS.productsheet}</th>
        <th width="18%">{'PROINITNUM'|@getFixedLabel}</th>
    </tr>
    {assign var="i" value=0}
    {foreach item=value from=$PRODUCTS}
    {assign var="j" value=$i++}
    {if $value.selected eq 0}
    {assign var=selected value='checked=true'}
    {assign var=disabled value=''}
    {else}
    {assign var=selected value=''}
    {assign var=disabled value='disabled=true'}
    {/if}
    {if $j mod 2 eq '0'}
        <tr id="row_{$value.productid}" class="lvtColData" onmouseout="setTrColorOut('row_{$value.productid}',{$value.productid},{$value.productid},'on');" onmouseover="setTrColor('row_{$value.productid}',{$value.productid},{$value.productid});">
    {else}
        <tr id="row_{$value.productid}" class="lvtColDataBj" onmouseout="setTrColorOut('row_{$value.productid}',{$value.productid},{$value.productid},'On');" onmouseover="setTrColor('row_{$value.productid}',{$value.productid},{$value.productid});">
    {/if} 
	
        {if $STARTED eq 1}
		<td align="center" onclick="toggleSelectAll_parent_td(this)">
        <input id="{$value.productid}" {$selected} type="checkbox" onclick="toggleSelectAll(this.name,'selectall','{$value.productid}_qtyinstock');updateQtyinstock('0.00','{$value.productid}_qtyinstock',this)" value="{$value.productid}" name="selected_id"/>
        </td>
		{/if}
        <td  style="text-align: left;">{$value.productname}</td>
        <td>{$value.product_no}</td>
        <td>{$value.productsheet}</td>
        <td>
		{if $STARTED eq 1}
			<input id="{$value.productid}_qtyinstock" type="text" value="{$value.qty}" {if $disabled eq 'disabled=true' } {$disabled} style="background:#FFFFFF;border:1px solid #AFAFAF;" {/if} name="{$value.productid}_qtyinstock"/>
		{else}
			{$value.qty}
        {/if}
		</td>
    </tr>
    {/foreach}
</table>