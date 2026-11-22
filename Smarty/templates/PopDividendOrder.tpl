<form name="frmdividenorderdetail" method="post" action="index.php" id="frmdividenorderdetail"">
        <input  type="hidden" name="module" value="DividendOrder"/>
        <input  type="hidden" name="action" value="DividendOrderAjax" />
		 <input  type="hidden" name="file" value="saveDetail" />
        <input  type="hidden" name="dividend_salesorderid" value="{$SALESORDERID}"/>
        <input  type="hidden" name="dividend_accountid" value="{$ACCOUNTID}"/>
        <input  type="hidden" name="dividend_productid" value="{$PRODUCTID}" />
        <input  type="hidden" name="pagetype" value="detail"/>
        <input  type="hidden" id="hidden_dividend_Princial" value="{$INVENSTAMOUNT}"/>
        <input  type="hidden" value="{$currencyid}" name="hidden_currency_id"/>
        <input  type="hidden" value="{$SMOWNERID}" name="hidden_smowner_id"/>
        <div class="D_pop_tit">
        	<strong class="D_ptita">{'LBL_Creates'|@getFixedLabel}{'DividendOrder'|@getTranstab}</strong>
        	<a href="###" id="colose_create_dividend" class="D_ptitc" onclick="javascript:fun_Dividend.getInstance().cancel()">
        		<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        	</a>
        </div>
        <table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
        	<tr>
        		<td width="120" align="right" class="DetailedTd1Label">
        			<span>{'FORMULACAPITAL'|@getFixedLabel}</span><!--本金计算方法-->
        		</td>
        		<td>
				
                    <span>{$DIVIDENDRULES.FORMULACAPITAL|@getFixedLabel}</span>
        		
        		</td>
        		<td width="120" align="right" class="DetailedTd1Label">
        			<span>{'Currency'|@getFixedLabel}</span><!--币种-->
        		</td>
        		<td>
        			<select name="currency_id" id="currency_id" disabled>
        				{foreach item=currency_info from=$CURRENCY}
        					<option value="{$currency_info.curid}" currate="{$currency_info.conversionrate}" {if $currencyid eq $currency_info.curid} selected="true" {/if}>{$currency_info.currencylabel|@getTranslatedCurrencyString}</option>
        				{/foreach}
        			</select>
        		</td>
        	</tr>
        	 
        	<tr>
        		<td width="120" align="right" class="DetailedTd1Label">
        			<span>{'FORMULAMODE'|@getFixedLabel}</span><!--利息计算方式-->
        		</td>
        		<td>
                    <span>{$DIVIDENDRULES.FORMULAMODE|@getFixedLabel}</span>
        		</td>
        		<td width="120" align="right" class="DetailedTd1Label">
        			<span>{'INVESTMENT'|@getFixedLabel}</span><!--投资金额-->
        		</td>
        		<td>
        			<input  type="text" readonly="true" style="border:1px solid #ccc" name="Princial" value="{$SALESTOTAL}"/>
        		</td>
        	</tr>
        	 
        	<tr>
        		<td width="120" align="right" class="DetailedTd1Label">
        			<span>{'FORMULASTART'|@getFixedLabel}</span><!--计息起始日-->
        		</td>
        		<td>
        		{$START_RATE_DATE}
        		</td>
        		<td width="120" align="right" class="DetailedTd1Label">
        			<span>{'INVESTENDDAY'|@getFixedLabel}</span><!--投资到期日-->
        		</td>
        		<td>
        			<input  type="text" readonly="true" style="border:1px solid #ccc" name="salesorderamount1" value="{$INVESTMENT_ENDDATE}"/>
        		</td>
        	</tr>
        	 
        	<tr>
				<td width="120" align="right" class="DetailedTd1Label">
					<span>{'INTERESTSCALCULATIONFORMULA'|@getFixedLabel}</span><!--利息计算公式-->
				</td>
				<td>
                    <span>{$DIVIDENDRULES.INTERESTSCALCULATIONFORMULA}</span>
				</td>
        	
        		<td width="120" align="right" class="DetailedTd1Label">
        			<span>{'DividendOrder'|@getTranstab}{'ASSIGNEDTO'|@getFixedLabel}</span><!--派息单负责人-->
        		</td>
        		<td>
        			<select name="sel_smownerid" id="smownerid">
        				{foreach key=userid item=userinfo from=$USERS}
        					{foreach key=username item=sel from=$userinfo}
        						<option value="{$userid}" {$sel}>{$username}</option>
        					{/foreach}
        				{/foreach}
        			</select>
        		</td>
        	</tr>
        	 

            <tr>
                <td colspan="4" style="padding:0;">
                    <div id="dividendOrder_show_Table">{$HTML}</div>
                </td>
            </tr>
        </table>
        
        <div class="D_pbtn">
            <a style="float: left;margin-left: 22px; cursor:pointer;" onclick="fun_Dividend.getInstance().Buttons_dividendRules(this,'SalesOrder',{$PRODUCTID});">{'DIVIDENDRULES'|@getFixedLabel}</a>
        	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}"  onclick="fun_Dividend.getInstance().save_dividendorder_detail(this)"/><span>&nbsp;</span>
        	<input type="button" class="D_pbtncancel" value="{'RECALCULATE'|@getFixedLabel}" onclick="fun_Dividend.getInstance().Recalculate('detail','{$SALESORDERID}')"/> <span>&nbsp;</span>
            <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fun_Dividend.getInstance().cancel()" id="D_pbtncancel"/> 
        </div>
        
        <div id="dividendOrder_hide_Table" style="display:none">{$HIDE_HTML}</div>
        <script type="text/javascript">
        var dividend_money_change_tip="{'DIVIDENDMONEYCHANGESAVE'|@getFixedLabel}";//派息金额变动的tip提示
        var dividend_recalculate_save_tip="{'DIVIDENDORDERCHANGEDMUSTSAVE'|@getFixedLabel}";
        var pointjson='{$HIDE_DIVIDENDOBJS}';

       fun_Dividend.prototype.hide_dividendorder_obj=eval('('+ pointjson +')')?eval('('+ pointjson +')'):JSON.parse(pointjson);;
    
       var header_detail_table='{$DETAIL_TABLE_HEADER}';
       fun_Dividend.prototype.detail_table_header=eval('('+ header_detail_table +')')?eval('('+ header_detail_table +')'):JSON.parse(header_detail_table);
    </script>
</form>

<div id="show_dividendorder_detail" class="D_pop_box LdPopWidth900px" style="display:none;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'VIEW'|@getFixedLabel}</strong>
    	<a class="D_ptitc" href="javascript:fninvshnew('show_dividendorder_detail');" href="###">
    		<img title="{'CLOSE'|@getFixedLabel}" alt="{'CLOSE'|@getFixedLabel}" src="themes/icon/pop_close.png" class="D_ptitcimg">
    	</a>
    </div>
    <div id="DividendOrder_detail_div" style="margin:10px;max-height:270px;overflow-y:auto;"></div>
</div>