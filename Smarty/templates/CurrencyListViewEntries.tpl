{*<!--
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

-->*}
<!--修改编码格式:统一编码：UTF-8-->
<table class="settingTable fir-center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
  	<th>#</th>
    <th title="{'CURRENCYNAME'|@getFixedLabel}">{'CURRENCYNAME'|@getFixedLabel}</th>
    <th title="{'CURRENCYCODE'|@getFixedLabel}">{'CURRENCYCODE'|@getFixedLabel}</th>
    <th title="{'CURRENCYSYMBOL'|@getFixedLabel}">{'CURRENCYSYMBOL'|@getFixedLabel}</th>
    <th title="{'CONVERSIONRATE'|@getFixedLabel}">{'CONVERSIONRATE'|@getFixedLabel}</th>
    <th title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
    {if $LANUGAGETYPE eq 'en'}
        <th width="70">{'OPERATING'|@getFixedLabel}</th>
    {else}
        <th width="51">{'OPERATING'|@getFixedLabel}</th>
    {/if}
  </tr>
  {assign var="i" value=0}
  {foreach item=currencyvalues name=currlist key=id from=$CURRENCY_LIST}
    {assign var="j" value=$i++}
    {if $j mod 2 eq '0'}
        <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
    {else}
        <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
    {/if}    
    <td>{$smarty.foreach.currlist.iteration}</td>
    <td>{$currencyvalues.name}</td>
    <td><span title="{$currencyvalues.code}">{$currencyvalues.code}</span></td>
    <td><span title="{$currencyvalues.symbol}">{$currencyvalues.symbol}</span></td>
    <td><span title="{$currencyvalues.crate}">{$currencyvalues.crate}</span></td>
    <td align="left">{$currencyvalues.active_button}</td>
    <td align="left">{$currencyvalues.tool}</td>
  </tr>
  {/foreach}
  
</table>
