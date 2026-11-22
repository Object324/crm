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
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script type='text/javascript' src='{$JSURL}include/js/user_approveby.js'></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>

<div class="D_pop_tit">
	<strong class="D_ptita">{'CREATE'|@getFixedLabel}{$MODULE|@getTranstab}</strong>
    <a href="javascript:fninvshnew('CreateNewBill');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>

<form name="EditView" id="massedit_form" action="index.php" onsubmit="puyoungJS_DialogBox.block();">
<input id="idstring" value="{$IDS}" type="hidden" />
<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
  <tr>
    <td style="padding:0px;">
		<table border=0 cellspacing=0 cellpadding=0 width="100%" >
			<tr>
				<td class="heigh_lineheigh_none pad0" colspan="4">
					{include file='EditViewHidden.tpl'}
					<input type="hidden" name="massedit_recordids">
					<input type="hidden" name="massedit_module">
					<input type="hidden" name="module" value="{$MODULE}">
					<input type="hidden" name="action" value="MassEditSave">
                    <input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}"/>
				</td>
			</tr>
				<tr>
					<td colspan="4" style="padding:0px;">
						<table border="0" cellpadding="0" cellspacing="0" width="100%">
							<tbody><tr><td>
                                <div class="tab_mass">
								<ul>
								{foreach key=header name=block item=data from=$BLOCKS}
								    {if $smarty.foreach.block.index eq 0}
								    <li>
                                        <a href="javascript:" class="On" id="tab{$smarty.foreach.block.index}" onclick="massedit_togglediv({$smarty.foreach.block.index},{$BLOCKS|@count});">
									     {$header}
									    </a>
								    </li>
                                    {else}
							        <li>   
                                        <a href="javascript:" id="tab{$smarty.foreach.block.index}" onclick="massedit_togglediv({$smarty.foreach.block.index},{$BLOCKS|@count});">
									     {$header}
									    </a>
								    </li>
                                    
                                    {/if}
								{/foreach}
                                </ul>
                            </div></td></tr>
							</tbody>
					    </table>		
					</td>
				</tr>
				<tr>
					<td colspan=4>                            
						{foreach key=header name=block item=data from=$BLOCKS}
						    {if $smarty.foreach.block.index eq 0}
							    <div id="massedit_div{$smarty.foreach.block.index}" style='display:block;'>
                                <div class="ld-from-headblock-mass"><div class="ld-from-headblock-title">{$header}</div></div>
								<table border=0 cellspacing=1 cellpadding=0 width=100% class='DetailContentTable'>
									{include file="DisplayFields.tpl"}
								</table>
								</div>
						    {else}
							    <div id="massedit_div{$smarty.foreach.block.index}" style='display:none;'>
								<div class="ld-from-headblock-mass"><div class="ld-from-headblock-title">{$header}</div></div>
                                <table border=0 cellspacing=1 cellpadding=0 width=100% class='DetailContentTable'>
									{include file="DisplayFields.tpl"}
								</table>
								</div>
						    {/if}
						{/foreach}
					</td>
				</tr>
		</table>
    </td>
  </tr>
</table>
<div class="D_pbtn">
	<input type="submit" name="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="this.form.action.value='MassEditSave';  return massEditFormValidate()"/><span>&nbsp;</span>
    <input type="button" name="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('CreateNewBill');"/>
    <!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
</div>

</div>
<script type="text/javascript" id="massedit_javascript">
	fieldname = new Array({$VALIDATION_DATA_FIELDNAME});
	fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
	fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
	count=0;
	massedit_initOnChangeHandlers();
</script>

{if $PICKIST_DEPENDENCY_DATASOURCE neq ''}
<script type="text/javascript">
  fielddepend=new FieldDependencies({$PICKIST_DEPENDENCY_DATASOURCE});

	fielddepend.setup();
</script>
{/if}