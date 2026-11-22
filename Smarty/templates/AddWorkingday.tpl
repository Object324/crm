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
<!--中间-->
	<!--修改编码格式:统一编码：UTF-8-->
<div class="D_pop_box LdPopWidth400px">   
	<div class="D_pop_tit">
        {if $WORKINGDAYTYPE eq 'special'}
            <strong class="D_ptita">{'ADDSPECIALDAY'|@getFixedLabel}</strong>  
        {else} 
             <strong class="D_ptita">{'ADDHOLIDAYVACATION'|@getFixedLabel}</strong> 
        {/if}    	
		<a href="javascript:fninvshnew('addWorkingday');showPopDiv('EditWorkingSpace');" class="D_ptitc">
			<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
		</a>
	</div>
   
 	 <table class="D_pop_bod" width="100%"  border="0" cellspacing="1" cellpadding="0">    
     <tr>           
        <td align="center"><label><font color="red">*</font>{'BEIZHU'|@getFixedLabel}</label>
           <input type="text"  id="remark" title="{'BEIZHU'|@getFixedLabel}"  value="" />
           <input  id="altField" type="hidden" value=""/>
           <input type='hidden' id='attr_selectdate'  value='' />
       </td>
    </tr>
    <tr>
    <td align="center" style="padding-left:1px"><div id="calenderview" width="200px" class="datepicker"> </div> </td>
    </tr>
    </table>
    
    <div class="D_pbtn">
		<input type="button" class="D_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" onclick="SaveWorkingday('{$WORKCALENDERID}','{$WORKINGDAYTYPE}','{$OPERATETYPE}')"/><span>&nbsp;</span>
		<input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('addWorkingday');showPopDiv('EditWorkingSpace');"/> 
	</div>
</div>
<!--中间 end-->


