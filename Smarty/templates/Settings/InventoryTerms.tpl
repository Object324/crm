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
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>


<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form action="index.php" method="post" name="tandc" onsubmit="puyoungJS_DialogBox.block();">
        <input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="action"/>
        <input type="hidden" name="inv_terms_mode"/>
        <input type="hidden" name="parenttab" value="Settings"/>
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
      <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">{'CONTROLPANEL'|@getFixedLabel} &gt; {'INVENTORYTERMSANDCONDITIONS'|@getFixedLabel}
                <font>（{'LBL_INV_TANDC_DESCRIPTION'|@getFixedLabel}）</font></span>
        </div>
        <div class="ControlDiv2">
           {if $INV_TERMS_MODE eq 'view'}
              <div class="F_r"><input class="editauto" title="{'EDIT'|@getFixedLabel}" onclick="this.form.action.value='OrganizationTermsandConditions';this.form.inv_terms_mode.value='edit'" type="submit" name="Edit" value="{'EDIT'|@getFixedLabel}"/></div>
                        {else}
                          <input title="{'SAVE'|@getFixedLabel}" class="saveauto" type="submit" name="button" value="{'SAVE'|@getFixedLabel}" onclick="this.form.action.value='savetermsandconditions';"/>
                          <input title="{'CANCEL'|@getFixedLabel}" class="cancelauto" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}"/>
                       
                        {/if}
                        
        </div>
        <div class="pad10" >
        <div class="TitleHeading noborderB">{'TERMCONDITION'|@getFixedLabel}</div>
           <!--  <table border=0 cellspacing=0 cellpadding=0 width=100% class="TitleHeading" style="border-bottom:0px;">
    			<tr>
    				<td><strong>{'TERMCONDITION'|@getFixedLabel} </strong></td>
   				</tr>
 			</table> -->
    			
    		{if $INV_TERMS_MODE eq 'view'}
   			<table border=0 cellspacing=1 cellpadding=5 width=100% class="listEntries" >
    			<tr  bgcolor="white">
    			<td class="small detailedViewTextBox" valign=top style="padding:5px 10px;border:none;text-align:left;">
    				{$INV_TERMSANDCONDITIONS} 
                </td> 
    		   </tr>
    		</table>
			{else}
				<table border=0 cellspacing=0 cellpadding=5 width=100% class="listTable">
				<!-- <tr>
					<td class="colHeader small" valign=top>{$MOD.LBL_TEXTSAVE}<!--Type the text below and click Save button </td>
		  		</tr> -->
				<tr>
					<td class="listTableRow small" valign=top>
					<textarea class="small detailedViewTextBox" name="inventory_tandc" style="width:95%; height:200px;text-align:left;">{$INV_TERMSANDCONDITIONS}</textarea>

					</td>
				</tr>
				</table>	
			{/if}
        </div>         
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->