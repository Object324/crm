 <table class="D_pop_bod" border="0" cellpadding="1" name='reversetable' cellspacing="1" style="font-size:13px;">
    

    <tr id='definingDiv'>
    	<td align="left" class="editrelhead" colspan='2'>
    		<b style="font-size:13px;">{'DEFININGVARUABLE'|@getFixedLabel}</b>
    	</td>
    </tr>
    <tr id='definingContentDiv'>
    	<td align="left" colspan='2'>
    		  
        		<table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" name="reversetoolfieldFormula" class="toolfield formual_td">
                    {$FORMULAHTML}
        		</table>
    	  	
    	</td>
    </tr>
     <tr><td colspan="2" ><input  type="button" value="新变量" onclick="addReverseFormulavar('reversetoolfieldFormula')"/></td></tr>
    {*定义公式*}
    <tr id='mulaDiv'>
    	<td align="left" class="editrelhead" colspan='2'>
    		<b>{'DEFINITIONFORMULA'|@getFixedLabel}</b>
    	</td>
    </tr>
    
    <tr id='mulaContentDiv'>
    	<td align="left" colspan='2'>
    		<input type="text" name="definitionformula" value="{$formulastring}" class="detailedViewTextBox" /><br />
    		<span style="line-height:45px;height:45px;display:block">1.{'ALLTHENUMBERORDATEOFFIELDTYPESCANCALCULATE'|@getFixedLabel}</span>
    		<span style="margin-bottom:20px;display:block;">2.{'CANHAVEATMOST10VARIABLES'|@getFixedLabel}</span>
    	</td>
    </tr>
    </table>