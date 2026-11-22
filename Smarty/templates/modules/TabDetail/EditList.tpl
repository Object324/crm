
<script type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>

<script type="text/javascript" src="{$JSURL}include/js/FieldDependencies.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Products/Products.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
<script type="text/javascript">
	var module = '{$MODULE}';
	var rowcnt = ld('#rowcnt').val();
	ld.noConflict();
	var tabdetailfieldinfojson='{$PRODUCTFIELDSINFOJSON}';
</script>
<div name="ExpenseTab">
{$TREXPENSE}
</div>
<script type="text/javascript" src="{$JSURL}include/js/producttool/toolField.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/producttool/TabDetailFieldFormula.js"></script>

<script language="JavaScript" type="text/javascript">

var rowcnt = ld('#rowcnt').val();
var version_account = '{$UTRC_TYPE}';
var mode = '{$MODE}';
{literal}
ld(document).ready(function(){setProductDivWidth();});

/**���ϼ���MER�������**/
if(version_account != 'MileageReimbursement' && mode !='Details'){
	/**�����ֶι�ʽ�¼�**/
	fieldformulaobj.setAllRowEvent();
	fieldformulaobj.CountFormulaColumn();
	/*��������Direct��Indirect - ������Ŀ�Ƿ��ѡ*/
	if(module.toLowerCase() == 'expense' || module.toLowerCase() == 'timesheet'){
		for(var k = 1; k<=rowcnt;k++){
			if(ld('#timetype'+k) != undefined){
				fieldformulaobj.setSpecialFieldEvent(k,'timetype'+k);
			}
		}
	}
}


{/literal}


</script>
