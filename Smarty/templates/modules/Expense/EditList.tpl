<script type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>

<script type="text/javascript" src="{$JSURL}include/js/FieldDependencies.js"></script>
<script type="text/javascript" src="{$JSURL}modules/Products/Products.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
<script type="text/javascript">
	ld.noConflict();
	var tabdetailfieldinfojson='{$PRODUCTFIELDSINFOJSON}';
</script>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/Expense.css">
<input  type="hidden" value="{$NOWMONTHSTART}" id="StartMonth"/>
<input type="hidden" value="{$NOWMONTHEND}" id='EndMonth'/>
<input  type="hidden" value="" name="delExpensedetail" id="delExpensedetail"/>
<div name="ExpenseTab">
{$TREXPENSE}

<input  type="hidden" id="totalMoney" name="totalMoney" value="{$TOTAL}"/>
</div>
<script type="text/javascript" src="include/js/producttool/toolField.js"></script>
<script type="text/javascript" src="include/js/producttool/TabDetailFieldFormula.js"></script>
<script language="JavaScript" type="text/javascript">
{literal}


/**�����ֶι�ʽ�¼�**/
fieldformulaobj.setAllRowEvent();
fieldformulaobj.CountFormulaColumn();
calcTotal();
{/literal}
</script>