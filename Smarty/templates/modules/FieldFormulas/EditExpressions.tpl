{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ******************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script src="modules/FieldFormulas/resources/functional.js" type="text/javascript" charset="utf-8"></script>
<script src="modules/FieldFormulas/resources/json2.js" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript" charset="utf-8">
	var strings = {$JS_STRINGS};
	var meta_fieldnames = new Array({$VALIDATION_DATA_FIELDNAME})
	var meta_fieldlabels = new Array({$VALIDATION_DATA_FIELDLABEL});
	var meta_fielddatatypes = new Array({$VALIDATION_DATA_FIELDDATATYPE});
</script>
<script src="modules/FieldFormulas/resources/editexpressionscript.js" type="text/javascript" charset="utf-8"></script>


<!--中间-->
<div class="List3Box" id="view">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold"><a href="index.php?module=Settings&action=ModuleSettings&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}">{'LBL_PAGE_SET'|@getFixedLabel}</a> 
                &gt; {$FORMODULE|@getTranstab} &gt;{'Field_formulas'|@getFixedLabel}
                <font>（{'Addingcustomfieldformula'|@getFixedLabel}）</font></span>
        </div>
        <div class="ControlDiv2">
            <input type="hidden" id="pick_module" name="pick_module" value={$FORMODULE} />
        	<span class="F_l"><font>{'Field_formulas'|@getFixedLabel} "{$FORMODULE|@getTranstab}"</font></span> 
            <span style="display: none;float:right; margin:5px 13px; ">
            <span id="new_field_expression_busyicon"><b>{'Inspection'|@getFixedLabel}</b><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
			<span id="status_message" class="helpmessagebox" style='font-weight: bold; display: none;'></span>
            </span>
            <input type="button" class="createauto" value="{'LBL_NEW_FIELD_EXPRESSION_BUTTON'|@getFixedLabel}" id='new_field_expression' style="display: none;"/>
		
        </div>
        <div id='editpopup' class='D_pop_box LdPopWidth650px' style='display:none;' >

        <div class="D_pop_tit">
        	<strong class="D_ptita">{'FIELDFORMULAS'|@getFixedLabel}</strong>
            <a href="javascript:fninvshnew('editpopup');" class="D_ptitc">
                <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
            </a>
        </div>
		<table width="100%" align="center" class="D_pop_bod" border="0" cellspacing="1" cellpadding="5">
			<tr>
				<td  align="right">
					<b>{'TARGETFIELD'|@getFixedLabel}</b>
				</td>
				<td >
					<select id='editpopup_field' style="margin-left:10px;" class='small'><option></option></select>
					<span id="popupfldtitle" style='color:red;'></span>
				</td>
			</tr>
			<tr valign="top">
				<td  align="right">
					<b>{'LBL_EXPRESSION'|@getFixedLabel}</b>
				</td>
				<td  align="left">
					<table width="100%" border="0" cellspacing="0" cellpadding="2" align="center">
						<tr valign="top">
							<td>
								<select id='editpopup_functions' class='small'>
									<option value="">{'USINGFUNCTIONS'|@getFixedLabel}</option>
								</select>
                                <select id='editpopup_fieldnames' class='small'></select>
					            
							</td>
						</tr>
						<tr valign="top">
							<td>
								<textarea name="Name" rows="3" cols="50" id='editpopup_expression'></textarea>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
        <div class="D_pbtn">
        	<input type="button" name="save" id='editpopup_save' class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" /><span>&nbsp;</span>
            <input type="button" name="cancel" id='editpopup_cancel' class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('editpopup')"/>
            <!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
        </div>
		<table width="100%" cellspacing="1" cellpadding="5" border="0" class="helpmessagebox">
			<tr valign="top">
				<td><b>{'TARGETFIELD'|@getFixedLabel}</b></td>
				<td><b>{'LBL_EXPRESSION'|@getFixedLabel}</b></td>
			</tr>
			<tr valign="top">
				<td>Custom Revenue</td>			
				<td><i>annual_revenue</i> / 12</td>
			</tr>			
			<tr valign="top">
				<td>Full Name</td>
				<td>
					<font color=blue>if</font> <i>mailingcountry</i> == "India" <font color=blue>then</font> <font color=blue>concat</font>(<i>firstname</i>," ",<i>lastname</i>) <font color=blue>else</font> <font color=blue>concat</font>(<i>lastname</i>," ",<i>firstname</i>) <font color=blue>end</font>
				</td>
			</tr>			
		</table>
        
        </div>
        <div class="pad10" >

            <table id='expressionlist' class="ControlTable1" width="100%" border="0" cellspacing="0" cellpadding="0" >
			<tr>
              	
                <th align="left">{'LBL_Field'|@getFixedLabel}</th>
                <th align="left">{'LBL_EXPRESSION'|@getFixedLabel}</th>
               {if $LANUGAGETYPE eq 'zh'}
                    <th width="85">{'OPERATING'|@getFixedLabel}</th>
               {else}
                    <th width="95">{'OPERATING'|@getFixedLabel}</th>
               {/if}
                
            </tr>
            </table>
        	<div align='right' style='padding-right: 5px;' id="expressionlist_busyicon"><b>{'Inspection'|@getFixedLabel}</b><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></div>
        </div>         
                 
      </div>	
    </td>
  </tr>
</table>
</div>
<!--中间 end-->