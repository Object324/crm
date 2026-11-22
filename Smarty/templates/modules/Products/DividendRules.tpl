{* editor:gyq_09  reason:新增文件  date:2016 4  7*}
<form action="index.php" method="post" name="dividend_rules" >
<input type="hidden" name="module" value="Products"/>
<input type="hidden" name="action" value="DividendRules"/>
<input type="hidden" name="idstring" value="{$RECORD}"/>
<input type="hidden" name="fld_module" value="{$BLOCK}"/>
<input type="hidden" name="returnmodule" value="{$RETURNMODULE}"/>
<input type="hidden" name="didvidendRules_save" value="save">
<input type="hidden" name="didvidendRules_info" value="{$DIVIDENDRULESINFO}">
<input type="hidden" name="grantdate_designated" value="">
<input type="hidden" name="productids" value="{$RECORD}">
<input type="hidden" name="fromview" value="{$FROMVIEW}">
<input type="hidden" name="hidde_float_income_chk" value="" />
<input  type="hidden" name="recal_float_income" value="no"/> 


<div id="dividendRules_contain">
    <input type="hidden" name="travelview" value="{$TREVALVIEWSMARK}">
    {$TRAVELVIEWS}
    <table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'FORMULACAPITAL'|@getFixedLabel}</td>
            <td width="40%">
                <select name="formulacapital" style="width: 350px; border:1px solid #dadada;" onchange="Products_dividendRules.getInstance().formula_capital(this)">
                    <option value="totalsubscription">{'FORMULATOTAL'|@getFixedLabel}</option>
                    <option value="everycontract">{'FORMULAEVERYCONTRACT'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'FORMULAMODE'|@getFixedLabel}</td>
            <td width="80%">
                <select name="formulamode" style="width: 350px;border:1px solid #dadada;"  onchange="Products_dividendRules.getInstance().formula_mode(this)">
                        <option value="monthly">{'DIVIDENDMONTHLY'|@getFixedLabel}</option>
                        <option value="othermonth">{'DIVIDENDOTHERMONTHLY'|@getFixedLabel}</option>
                        <option value="quarterly">{'DIVIDENDQUARTERLY'|@getFixedLabel}</option>
                        <option value="semiannual">{'DIVIDENDSEMIAN'|@getFixedLabel}</option>
                        <option value="oneoff">{'DIVIDENDONEOFF'|@getFixedLabel}</option>
                        <option value="designated">{'DIVIDENDDESIGN'|@getFixedLabel}</option>

                </select>
            </td>
        </tr>
        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'FORMULASTART'|@getFixedLabel}</td>
            <td width="80%">
                <select name="startdate" style="border:1px solid #dadada;display:none" >
                    <option value="totalsubscription">{'STARTDATETYPEONE'|@getFixedLabel}</option>
                    <option value="everycontract">{'STARTDATETYPETWO'|@getFixedLabel}</option>
                </select>
                <input type="text" name="formulacapitalsons" value=" {'STARTDATETYPEONE'|@getFixedLabel}" style="border:1px solid #dadada;width: 350px" disabled >
            </td>
        </tr>
        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'INVESTENDDAY'|@getFixedLabel}</td>
            <td width="80%">
                <select name="investendday" style="border:1px solid #dadada;display:none" >
                        <option value="totalsubscription">{'ENDDATETYPEONE'|@getFixedLabel}</option>
                        <option value="everycontract">{'ENDDATETYPETWO'|@getFixedLabel}</option>
                </select>
                <input type="text" name="formulacapitalsons" value=" {'ENDDATETYPEONE'|@getFixedLabel}" style="border:1px solid #dadada;width: 350px" disabled >
            </td>
        </tr>

        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'FIXEDINCOMERATE'|@getFixedLabel}</td>
            <td width="80%">
                <select name="fixincomerate" style="border:1px solid #dadada;display:none">
                    <option value="totalsubscription">{'DIVIDENDFIXEDRATEONE'|@getFixedLabel}</option>
                    <option value="everycontract">{'DIVIDENDFIXEDRATETWO'|@getFixedLabel}</option>
                </select>
                <input type="text" name="formulacapitalsons" value=" {'DIVIDENDFIXEDRATEONE'|@getFixedLabel}" style="border:1px solid #dadada;width: 350px" disabled >
            </td>
        </tr>

        <tr id="dividend_deadline_div">
            <td width="20%" nowrap="nowrap" align="right">{'FORMULADEADLINE'|@getFixedLabel}</td>
            <td width="80%">
                <select name="deadline" style="border:1px solid #dadada;" onchange="Products_dividendRules.getInstance().grant_rate()">
                    {$DEADLINEINFO}
                </select>
            </td>
        </tr>

        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'INTERESTPAYMENTDATE'|@getFixedLabel}</td>
            <td width="80%" class="grantdatecontent">
                {$GRANTDATEINFO}
            </td>
        </tr>

        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'INTERESTSCALCULATIONFORMULA'|@getFixedLabel}</td>
            <td width="80%">

                <select name="formulas" style="width:350px;border:1px solid #dadada;" >
                    {$FORMULASINFO}
                </select>
            </td>
        </tr>
    </table>

    <table id="dividend_floatincome_div" class="D_pop_bod" cellspacing="1" cellpadding="1" border="0" style="color:grey">
        <tr>
            <td width="20%" colspan="2" nowrap="nowrap" align="left">
                <input  type="checkbox"  name="float_switch" value="off" onclick="Products_dividendRules.getInstance().float_switch(this)">{'FORMULAFLOATINCOME'|@getFixedLabel}
            </td>
        </tr>
        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'FORMULASTART'|@getFixedLabel}</td>
            <td width="80%">
                <input name="floatstartdate" disabled="disabled" class="Wdate" type="text"
                       fieldonly="0" size="20" maxlength="10" value="" onclick="WdatePicker()" onblur="Products_dividendRules.getInstance().auto_units('onblur')">
            </td>
        </tr>
        <tr>
            <td width="20%" nowrap="nowrap" align="right">{'FORMULAINCOMERATE'|@getFixedLabel}</td>
            <td width="80%">
                <input class="borderALL" style="width: 350px" type="text" name="floatyield" disabled="disabled" fieldonly="0" onblur="Products_dividendRules.getInstance().auto_units('onblur')" placeholder="{'TIPSFORENTRYRATE'|@getFixedLabel}"  value="">
            </td>
        </tr>
    </table>
</div>

</form>



