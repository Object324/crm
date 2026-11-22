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
<input type='hidden' name='reporttype' id="reporttype" value="{$REPORTTYPE}"/>
<table align="center" width="99%">
    <tr>
      {if $WM_STAT eq 0}
        <td align="center">
            <div class="MatrixLayer MatrixLayer_row f-l autoHeight" style="width:99.5%;">
            	<table width="100%" cellpadding="0" cellspacing="0" class="E_stripe" >
            		<tr>
                        <th class="N_con_tit">
                            <span class="icon-bluelt"></span>
                            {if $REPORTTYPE eq 'month'}
                                {'THESTATICOFTHISMONTH'|@getFixedLabel}
                            {elseif $REPORTTYPE eq 'lastmonth'}
                                {'LASTSTATICOFTHISMONTH'|@getFixedLabel}
                            {elseif $REPORTTYPE eq 'week'}
                                {'THESTATICOFTHISWEEK'|@getFixedLabel}
                            {else}
                                {'LASTSTATICOFTHISWEEK'|@getFixedLabel}
                            {/if}
                                                        
                        	<span id="vtbusy_info" valign="bottom" style="display: none;position:relative;">
                                <img border="0" src="themes/images/vtbusy.gif" />
                            </span>
                        </th>
                        <th colspan="2" class="N_con_tit" align="right" style="text-align: right;padding-right: 10px;">
                            {if $OFTENHREF eq 'yes'}
                            {*判断权限，模块是否开启OftenUseReport*}
                        	<a class="" title="{'MORE'|@getFixedLabel}" href="index.php?module=OftenUseReport&action=ListView&UseReport=8" target="_blank">
            			         {'MORE'|@getFixedLabel}
                        	</a>
                            {/if}
                            <a  title="{'REFRESH'|@getFixedLabel}"  onclick="return refreshreport()" href='javascript:;'>
                            </a>            
                        </th>
            		</tr>
            	</table>
            	<table width="100%" cellpadding="0" cellspacing="0" class="small" style="margin-top:9px;" >
            		<tr class=''>
            			<td>
                            <div class="switch-time">
                                <a href="" class="{if $REPORTTYPE eq 'week'}onselected_A{/if} changeday" onclick="getreport(this,'week');return false;">{'thisweek'|@getFixedLabel}</a>
                                <a href="" class="{if $REPORTTYPE eq 'lastweek'}onselected_A{/if} changeday" onclick="getreport(this,'lastweek');return false;">{'lastweek'|@getFixedLabel}</a>
                                <a href="" class='{if $REPORTTYPE eq 'month'}onselected_A{/if} changeday' onclick="getreport(this,'month');return false;">{'thismonth'|@getFixedLabel}</a>                               
                                <a href="" class='{if $REPORTTYPE eq 'lastmonth'}onselected_A{/if} changeday' onclick="getreport(this,'lastmonth');return false;">{'lastmonth'|@getFixedLabel}</a>
                            </div>
            				<div style="overflow-y: auto; overflow-x:hidden;width:100%;cursor:auto;"> 
            				    <div style="width:98%;margin:0 auto;">
                                    <div>
                                        <div class="datalist" style="padding: 10px 0 6px;" >
                                            <ul style="padding:0;margin:0;">
                                              {if $OFTENACCHREF eq 'yes'} {*判断权限，模块是否开启Accounts*}
                                                <li style="float: left;text-align: center;width: {$WIDTH}%;">                                                
                                                    <h3>
                                                        {if $REPORTTYPE eq 'month'}{'THISMONTHTHENUMBEROFNEWACCOUNTS'|@getFixedLabel}
                                                        {elseif $REPORTTYPE eq 'lastmonth' }{'LASTMONTHTHENUMBEROFNEWACCOUNTS'|@getFixedLabel}
                                                        {elseif $REPORTTYPE eq 'week' }{'THISWEEKTHENUMBEROFNEWACCOUNTS'|@getFixedLabel}
                                                        {else}{'LASTWEEKTHENUMBEROFNEWACCOUNTS'|@getFixedLabel}
                                                        {/if}
                                                    </h3>
                                                    <h5 class="up">{$NOWACCNUM}</h5>
                                                    <div class="data">
                                                        <p>
                                                            <span>{if $REPORTTYPE eq 'month'}{'lastmonth'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'beflastmonth'|@getFixedLabel}
                                                            {elseif $REPORTTYPE eq 'week'}{'lastweek'|@getFixedLabel}{else}{'beflastweek'|@getFixedLabel}{/if}：{$LASTACCNUM}</span>
                                                            <span class="chainnnumspan">
                                                                {if $REPORTTYPE eq 'month'}
                                                                    {'CHAINHOMEMONTH'|@getFixedLabel}
                                                                {else}
                                                                    {'CHAINHOMEWEEK'|@getFixedLabel}
                                                                {/if}
                                                                ：
                                                                {if $LASTACCNUM eq 0}
                                                                    —
                                                                {else}                                                                
                                                                    {if $CHAINACCNUM ge 0}
                                                                    <b class="red">
                                                                    {else}
                                                                    <b class="green">-
                                                                    {/if}
                                                                    {$CHAINACCNUM|@dateformat}
                                                                    </b>
                                                                {/if}
                                                            </span>
                                                        </p>
                                                    </div>                                                
                                                </li>
                                             {/if}
                                             {if $OFTENCONHREF eq 'yes'}{*判断权限，模块是否开启ContactRecords*}
                                                <li style="float: left;text-align: center;width: {$WIDTH}%;">                                                
                                                    <h3>{if $REPORTTYPE eq 'month'}{'THISMONTHTHENUMBEROFCONTACTRECORDS'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'LASTMONTHTHENUMBEROFCONTACTRECORDS'|@getFixedLabel}
                                                    {elseif $REPORTTYPE eq 'week'}{'THISWEEKTHENUMBEROFCONTACTRECORDS'|@getFixedLabel}{else}{'LASTWEEKTHENUMBEROFCONTACTRECORDS'|@getFixedLabel}{/if}</h3>
                                                    <h5 class="up">{$NOWCONTRECORDSNUM}</h5>
                                                    <div class="data">
                                                        <p>
                                                            <span>{if $REPORTTYPE eq 'month'}{'lastmonth'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'beflastmonth'|@getFixedLabel}
                                                            {elseif $REPORTTYPE eq 'week'}{'lastweek'|@getFixedLabel}{else}{'beflastweek'|@getFixedLabel}{/if}：{$LASTCONTRECORDSNUM}</span>
                                                            <span class="chainnnumspan">
                                                                {if $REPORTTYPE eq 'month'}
                                                                    {'CHAINHOMEMONTH'|@getFixedLabel}
                                                                {else}
                                                                    {'CHAINHOMEWEEK'|@getFixedLabel}
                                                                {/if}
                                                                ：
                                                                {if $LASTCONTRECORDSNUM eq 0}
                                                                    —
                                                                {else}
                                                                    {if $CHAINCONTACTRECORDSNUM ge 0}
                                                                     <b class="red">
                                                                    {else}
                                                                     <b class="green">-
                                                                    {/if}
                                                                    {$CHAINCONTACTRECORDSNUM|@dateformat}
                                                                    </b>
                                                                {/if}
                                                            </span>
                                                        </p>
                                                    </div>                                                
                                                </li>
                                             {/if}
                                             {if $OFTENSALHREF eq 'yes'}{*判断权限，模块是否开启SalesOrder*}
                                                <li style="float: left;text-align: center;width: {$WIDTH}%;">                                                
                                                    <h3>{if $REPORTTYPE eq 'month'}{'THISMONTHTHENUMBEROFNEWCONTRACTS'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'LASTMONTHTHENUMBEROFNEWCONTRACTS'|@getFixedLabel}
                                                    {elseif $REPORTTYPE eq 'week'}{'THISEEKTHENUMBEROFNEWCONTRACTS'|@getFixedLabel}{else}{'LASTWEEKTHENUMBEROFNEWCONTRACTS'|@getFixedLabel}{/if}</h3>
                                                    <h5 class="up">{$SIGNINGNOWNUM}</h5>
                                                    <div class="data">
                                                        <p>
                                                            <span>{if $REPORTTYPE eq 'month'}{'lastmonth'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'beflastmonth'|@getFixedLabel}
                                                            {elseif $REPORTTYPE eq 'week'}{'lastweek'|@getFixedLabel}{else}{'beflastweek'|@getFixedLabel}{/if}：{$SIGNINLASTNUM}</span>
                                                            <span class="chainnnumspan">
                                                                {if $REPORTTYPE eq 'month'}
                                                                    {'CHAINHOMEMONTH'|@getFixedLabel}
                                                                {else}
                                                                    {'CHAINHOMEWEEK'|@getFixedLabel}
                                                                {/if}
                                                                ：
                                                                {if $SIGNINLASTNUM eq 0}
                                                                   —
                                                                {else} 
                                                                    {if $CHAINSIGNINGNUM ge 0}
                                                                     <b class="red">
                                                                    {else}
                                                                     <b class="green">-
                                                                    {/if}
                                                                    {$CHAINSIGNINGNUM|@dateformat}
                                                                    </b>
                                                                {/if}
                                                            </span>
                                                        </p>
                                                    </div>                                                
                                                </li> 
                                             {/if}  
                                             {if $OFTENSALHREF eq 'yes'}{*判断权限，模块是否开启SalesOrder*}
                                                <li style="float: left;text-align: center;width: {$WIDTH}%;">                                                
                                                    <h3>{if $REPORTTYPE eq 'month'}{'THISMONTHTHEAMOUNTOFNEWCONTRACTS'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'LASTMONTHTHEAMOUNTOFNEWCONTRACTS'|@getFixedLabel}
                                                    {elseif $REPORTTYPE eq 'week'}{'THISWEEKTHEAMOUNTOFNEWCONTRACTS'|@getFixedLabel}{else}{'LASTWEEKTHEAMOUNTOFNEWCONTRACTS'|@getFixedLabel}{/if}</h3>
                                                    <h5 class="up">¥{$TOTALNOW}</h5>
                                                    <div class="data">
                                                        <p>
                                                            <span>{if $REPORTTYPE eq 'month'}{'lastmonth'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'beflastmonth'|@getFixedLabel}
                                                            {elseif $REPORTTYPE eq 'week'}{'lastweek'|@getFixedLabel}{else}{'beflastweek'|@getFixedLabel}{/if}：{$TOTALLAST}</span>
                                                            <span class="chainnnumspan">
                                                                {if $REPORTTYPE eq 'month'}
                                                                    {'CHAINHOMEMONTH'|@getFixedLabel}
                                                                {else}
                                                                    {'CHAINHOMEWEEK'|@getFixedLabel}
                                                                {/if}
                                                                ：
                                                                {if $TOTALLAST eq 0}
                                                                    —
                                                                {else}
                                                                    {if $CHAINTOTALNUM ge 0}
                                                                    <b class="red">
                                                                    {else}
                                                                    <b class="green">-
                                                                    {/if}
                                                                    {$CHAINTOTALNUM|@dateformat}
                                                                    </b>
                                                                {/if}
                                                            </span>
                                                        </p>
                                                    </div>                                                
                                                </li>
                                             {/if}
                                             {if $OFTENCASHREF eq 'yes'}{*判断权限，模块是否开启CashBill*}
                                                <li style="float: left;text-align: center;width: {$WIDTH}%;">                                                
                                                    <h3>{if $REPORTTYPE eq 'month'}{'THISMONTHTHERECEIVEDAMOUNT'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'LASTMONTHTHERECEIVEDAMOUNT'|@getFixedLabel}
                                                    {elseif $REPORTTYPE eq 'week'}{'THISWEEKTHERECEIVEDAMOUNT'|@getFixedLabel}{else}{'LASTWEEKTHERECEIVEDAMOUNT'|@getFixedLabel}{/if}</h3>
                                                    <h5 class="up">¥{$CASHBILLNOW}</h5>
                                                    <div class="data">
                                                        <p>
                                                            <span>{if $REPORTTYPE eq 'month'}{'lastmonth'|@getFixedLabel}{elseif $REPORTTYPE eq 'lastmonth'}{'beflastmonth'|@getFixedLabel}
                                                            {elseif $REPORTTYPE eq 'week'}{'lastweek'|@getFixedLabel}{else}{'beflastweek'|@getFixedLabel}{/if}：{$CASHBILLLAST}</span>
                                                            <span class="chainnnumspan">
                                                                {if $REPORTTYPE eq 'month'}
                                                                    {'CHAINHOMEMONTH'|@getFixedLabel}
                                                                {else}
                                                                    {'CHAINHOMEWEEK'|@getFixedLabel}
                                                                {/if}
                                                                ：
                                                                {if $CASHBILLLAST eq 0}
                                                                    —
                                                                {else}
                                                                    {if $CHAINCASHBILLNUM ge 0}
                                                                     <b class="red">
                                                                    {else}
                                                                     <b class="green">-
                                                                    {/if}
                                                                    {$CHAINCASHBILLNUM|@dateformat}
                                                                {/if}
                                                            </span>
                                                        </p></div></li>{/if}</ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
            			</td>
            	    </tr>
            	</table>
            </div>
        </td>
      {/if}
    </tr>
</table>
