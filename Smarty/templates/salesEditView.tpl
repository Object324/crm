{include file='EditViewHeader.tpl'}
{*{include file='Buttons_List1.tpl'}*}

{*<!-- Contents -->*}
<table border=0 cellspacing=0 cellpadding=0 width=98% align=center>
    <tr>
        <td valign=top><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>

        <td class="showPanelBg" valign=top width=100%>
    
                <div class="small" style="padding:20px">
    
                    {assign var="SINGLE_MOD_LABEL" value=$SINGLE_MOD}
                 
                    {if $OP_MODE eq 'edit_view'} 
                        {assign var="USE_ID_VALUE" value=$MOD_SEQ_ID}
                        {if $USE_ID_VALUE eq ''} {assign var="USE_ID_VALUE" value=$ID} {/if}
                  		
                        <span class="font14 fontbold"><font color="purple">[ {$USE_ID_VALUE} ] </font>{$NAME} - {'EDIT'|@getTranstab} {$MODULE|@getTranstab} {'INFORMATION'|@getFixedLabel}</span> <br>
                        {$UPDATEINFO}	 
                    {/if}
                    {if $OP_MODE eq 'create_view'}
                        {if $DUPLICATE neq 'true'}
                                {if $MODULE eq 'Events'}
                                    <span class="font14 fontbold">{'NEW'|@getFixedLabel} {'Calendar'|@getTranstab}</span> <br>
                                {else}	
                                    <span class="font14 fontbold">{'NEW'|@getFixedLabel} {$MODULE|@getTranstab}</span> <br>
                                {/if}
                        {else}
                            <span class="font14 fontbold">{'COPY'|@getFixedLabel} "{$NAME}" </span> <br>
                        {/if}
                    {/if}

                    <hr noshade size=1>
                    <br> 
		
                    {include file='EditViewHidden.tpl'}

                    {*<!-- Account details tabs -->*}
                    <table border=0 cellspacing=0 cellpadding=0 width=95% align=center>
                        <tr>
                            <td>
                                <table border=0 cellspacing=0 cellpadding=3 width=100% class="small">
                                    <tr>
                                        <td class="dvtTabCache" style="width:10px" nowrap>&nbsp;</td>
                                        {if $MODULE eq 'Events'}
                                            <td class="dvtSelectedCellCommon dvtSelectedCell" align=center nowrap> {'Calendar'|@getTranstab} {'INFORMATION'|@getFixedLabel}</td>
                                        {else}
                                            <td class="dvtSelectedCellCommon dvtSelectedCell" align=center nowrap> {$MODULE|@getTranstab} {'INFORMATION'|@getFixedLabel}</td>
                                        {/if}
						
                                        <td class="dvtTabCache" style="width:10px">&nbsp;</td>
                                        <td class="dvtTabCache" style="width:100%">&nbsp;</td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td valign=top align=left >
                                <table border=0 cellspacing=0 cellpadding=3 width=100% class="dvtContentSpace">
                                    <tr>

                                        <td align=left>
                                            {*<!-- content cache -->*}
					
                                            <table border=0 cellspacing=0 cellpadding=0 width=100%>
                                                <tr>
                                                    <td id ="autocom"></td>
                                                </tr>
                                                <tr>
                                                    <td style="padding:10px">
								
                                                        <table border=0 cellspacing=0 cellpadding=0 width=100% class="small">
                                                            <tr>
                                                                <td  colspan=4 style="padding:5px">
                                                                    <div align="center">
                                                                    {include file='EditViewTopButton.tpl'}
                                                                    </div>
                                           
                                                                </td>
                                                            </tr>

                                                            {include file='EditViewForeach.tpl'}
                                                            <!-- Added to display the Product Details in Inventory-->
									 
                                                            {if $MODULE eq 'SalesBack'}
                                                                <tr>
                                                                    <td colspan=4>
                                                                        {include file="Inventory/ProductDetailsEditView.tpl"}
                                                                    </td>
                                                                </tr>
                                                            {/if}
                                                            {if $MODULE eq 'CashBill' }
                                                                <tr>
                                                                    <td colspan=4>
                                                                        {include file="modules/CashBill/PaymentList.tpl"}
                                                                    </td>
                                                                </tr>
                                                            {/if}
                                                            {if $MODULE eq 'SendCashBill' }
                                                                <tr>
                                                                    <td colspan=4>
                                                                        {include file="modules/SendCashBill/SendPaymentList.tpl"}
                                                                    </td>
                                                                </tr>
                                                            {/if}
                                                            {if $MODULE eq 'Expense' }
                                       
                                                                <tr>
                                                                    <td colspan=4>
                                                                        {include file="modules/Expense/EditList.tpl"}
                                                                    </td>
                                                                </tr>
                                                            {/if}
                                                       {if $MODULE eq 'Events'}                                      
                                                            {include file="ActivityEditView.tpl"}                                            
                                                       {/if}   
                                                            <tr>
                                                                <td  colspan=4 style="padding:5px">
                                                                    <div align="center">
                                                                        {include file='EditViewBottomButton.tpl'}
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                <div>
        </td>
        <td align=right valign=top><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
    </tr>
</table>
    <!--added to fix 4600-->
    <input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'>
</form>
{include file='EditViewBottom.tpl'}
<!-- END -->