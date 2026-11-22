{*
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
* ("License"); You may not use this file except in compliance with the License
* The Original Code is:  lingdang CRM Open Source
* The Initial Developer of the Original Code is lingdang.
* Portions created by lingdang are Copyright (C) lingdang.
* All Rights Reserved.
<!--修改编码格式:统一编码：UTF-8-->
*
********************************************************************************/ *}

<form action="index.php" method="post" name="form" onsubmit="puyoungJS_DialogBox.block()">
<input type="hidden" name="fld_module" value="{$MODULE}">
<input type="hidden" name="module" value="Settings">
<input type="hidden" name="parenttab" value="Settings">
<input type="hidden" name="mode">
		
<table class="listTable" id="dv_layoutblocklist" border="0" cellpadding="3" cellspacing="0" width="100%" style="color:#666;border:none;">
	
	{foreach item=entries key=id from=$CFENTRIES name=outer}
		{if $entries.blockid ne $RELPRODUCTSECTIONID || $entries.blocklabel neq '' }
			{if $smarty.foreach.outer.first neq true}
			<tr style="display:none;"><td><img src="{'blank.gif'|@lingdang_imageurl:$THEME}" style="width:16px;height:16px;" border="0" />&nbsp;&nbsp;</td></tr>
			{/if}
			<tr style="background-color:#F7F7F7;">
				<td  class="fontbold" colspan="2" width="50%" style="border-top: 1px solid #e6e6e6;border-bottom: 1px solid #e6e6e6;">
				<select name="display_status_{$entries.blockid}" class="btn-radius-system" style="font-family:Arial, Helvetica, sans-serif;font-size:12px; width:auto" onChange="changeShowstatus('{$entries.tabid}','{$entries.blockid}','{$MODULE}')" id='display_status_{$entries.blockid}'>
            		    <option value="show" {if $entries.display_status==1}selected{/if}>{'EXPANSION'|@getFixedLabel}</option>
						<option value="hide" {if $entries.display_status==0}selected{/if}>{'COLLAPSE'|@getFixedLabel}</option>			                
				</select>
			
                  {$entries.blocklabel}
                  <a class="icon-layout icon-layout-edit" href="javascript:;" title="{'MODIFIEDBLOCKNAME'|@getFixedLabel}" onclick="Modifiedblockname(this,'{$entries.tabid}','{$entries.blockid}')"></a>
   				</td>
				<td class="ControlDiv2" id = "blockid"_{$entries.blockid} colspan="2" style="border-top: 1px solid #e6e6e6;border-bottom: 1px solid #e6e6e6;"> 
                    <div align="right">
			<div id = "hiddenfields_{$entries.blockid}" style="display:none; position:absolute;" class="E_pop_box LdPopWidth300px">
                            <div class="E_pop_tit">
                            	<strong class="E_ptita">{'HIDDENFIELDS'|@getFixedLabel}</strong>
                                <a href="javascript:fninvshnew('hiddenfields_{$entries.blockid}');" class="E_ptitc">
                                    <img class="E_ptitcimg_r" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
                                </a>
                            </div>
                        	<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="0">
                              <tr>
                                <td>
                            		<ul class="LdPop_ul6">					
                    					{if $entries.hidden_count neq '0' || $entries.hidden_count neq null}
                    						<span>{'CHOOSEHIDDENFIELD'|@getFixedLabel}</span>
                    					{/if} 
                    					<li>
                    						{if $entries.hidden_count neq '0'}
                    						<select id="hiddenfield_assignid_{$entries.blockid}"  multiple="">
                    						{foreach name=inner item=value from=$entries.hiddenfield}	
                    							<option value="{$value.fieldselect}">{$value.fieldlabel}</option>
                    						{/foreach}
                    							</select>
                    						{else}
                    						{'Nohiddenfields'|@getFixedLabel}
                    						{/if}
                    					</li>
                                	</ul>
                                </td>
                              </tr>
                            </table>
                            <div class="E_pbtn">
                                {if $entries.hidden_count neq '0'}
            	                    <input type="button" class="E_pbtnok" value="{'CANCELHIDDEN'|@getFixedLabel}" onclick="show_move_hiddenfields('{$MODULE}','{$entries.tabid}','{$entries.blockid}','showhiddenfields');"/><span>&nbsp;</span>
                                    <!-- <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('hiddenfields_{$entries.blockid}');"/> -->                                   
                                {/if}
                            </div>
						</div>						
																		
					
					<!-- for adding customfield -->
						<div id="addfield_{$entries.blockid}" style="display:none; position:absolute;" class="E_pop_box LdPopWidth450px">
                            <input type="hidden" name="mode" id="cfedit_mode" value="add"/>
                            <div class="E_pop_tit">
                            	<strong class="E_ptita">{'Add_custom_fields'|@getFixedLabel}</strong>
                                <a href="javascript:addFieldCancel('{$entries.blockid}');" class="E_ptitc">
                                    <img class="E_ptitcimg_r" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
                                </a>
                            </div>	
                            
                            <div style="max-height: 381px !important;overflow: auto;width: 100%;">
                            <table class="settingPopTable settingPopTableNoBot" border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td align="right" style="width: 145px;">{"fieldtype"|@getFixedLabel}</td>
                                    <td align="left">
                                        <select name="selectfieldtype" class="selectfieldtype" onchange="makeFieldSelected(this,0,{$entries.blockid})">
                                            <option value="0">{'Text'|@getFixedLabel}</option>
                                            <option value="10">{'TEXT_AREA'|@getFixedLabel}</option>
                                            <option value="18">{'WholeTextArea'|@getFixedLabel}</option>
                                            <option value="7">{'PickList'|@getFixedLabel}</option>
                                            <option value="11">{'SELECT_COMBO'|@getFixedLabel}</option>
                                            <option value="9">{'CHECK_BOX'|@getFixedLabel}</option>
                                            <option value="1">{'Numberc'|@getFixedLabel}</option>
                                            <option value="6">{'Phone'|@getFixedLabel}</option>
                                            <option value="15">{'Mobil'|@getFixedLabel}</option>
                                            <option value="4">{'DATE'|@getFixedLabel}</option>
                                            <option value="13">{'TIMES'|@getFixedLabel}</option>
                                            <option value="14">{'DateTime'|@getFixedLabel}</option>
                                            <option value="17">QQ</option>
                                            <option value="5">Email</option>
                                            <option value="12">Skype</option>
                                            <option value="2">{'Percents'|@getFixedLabel}</option>
                                            <option value="3"> {'Currencyc'|@getFixedLabel}</option>
                                            <option value="8">{'Website'|@getFixedLabel}</option>
                                            <option value="16">{'FAX'|@getFixedLabel}</option>
                                            {if $HandlWRITESIGNPROFILE eq 1 }
                                                   <option value="19">{'handwriting'|@getFixedLabel}</option>
                                            {/if}
                                            {if $RELATEMODULESCOUNT >0}
                                                <option value="20">{'REFERENCEFIELD'|@getFixedLabel}</option>
                                            {/if}
                                            <option value="21">{'SelectBill'|@getFixedLabel}</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr id="tr_fieldtype_{$entries.blockid}">
            						<td align="right"><font color="red">*</font>{'fieldtype'|@getFixedLabel}</td>
            						<td align="left" >
            						    <input id="fieldtype_{$entries.blockid}" name="fldLabel_{$entries.blockid}" class="detailedViewTextBox" value="" type="text"/>
            						</td>
            					</tr>
                                <tr>
            						<td align="right"><font color="red">*</font>{'CNTAG'|@getFixedLabel}</td>
            						<td align="left" >
            						    <input id="fldLabel_{$entries.blockid}" name="fldLabel_{$entries.blockid}" class="detailedViewTextBox" value="" type="text"/>
            						</td>
            					</tr>
            					<tr>
            						<td align="right"><font color="red">*</font>{'ENTAG'|@getFixedLabel}</td>
            						<td align="left">
            						    <input id="fldLabels_{$entries.blockid}" class="detailedViewTextBox" value="" type="text"/>
            						</td>
            					</tr>
                                <tr id="lengthdetails_{$entries.blockid}">
            						<td align="right"><font color="red">*</font>{'CHARACTER'|@getFixedLabel}{'Length'|@getFixedLabel}</td>
            						<td align="left">
            						    <input type="text" id="fldLength_{$entries.blockid}" name="fldLength_{$entries.blockid}" class="detailedViewTextBox" value=""/>
            						</td>
            					</tr>
            					<tr id="decimaldetails_{$entries.blockid}" style="display:none;">
            						<td align="right"><font color="red">*</font>{'Decimal'|@getFixedLabel}</td>
            						<td align="left">
            						    <input type="text" id="fldDecimal_{$entries.blockid}" name="fldDecimal_{$entries.blockid}" class="detailedViewTextBox" value=""/>
            						</td>
            					</tr>
                                <tr style="display:none" id="tr_relatedmodule_{$entries.blockid}">
            						<td align="right"><font color="red">*</font>{'RelatedModule'|@getFixedLabel}</td>
            						<td align="left">
            						<select  id="relatedmodule_{$entries.blockid}" name="relatedmodule_{$entries.blockid}" onchange="getReferencemoduleField(this,'{$entries.blockid}','{$MODULE}')">
                                    {$RELATEDMODULE}
                                    </select>
            						</td>
            					</tr>       
                                <tr style="display:none" id="tr_referencemodule_{$entries.blockid}">
            						<td align="right"><font color="red">*</font>{'RelateChoiceModule'|@getFixedLabel}</td>
            						<td align="left">
            						<select  id="referencemodule_{$entries.blockid}" name="referencemodule_{$entries.blockid}">
                                    {foreach from=$CANSELECTMODULES item=info}
                                        <option value="{$info.name}">{$info.label}</option>
                                    {/foreach}
                                    </select>
            						</td>
            					</tr>       
                                <tr style="display:none" id="tr_datarang_{$entries.blockid}">
            						<td align="right"><font color="red">*</font>{'ALLOWDataRange'|@getFixedLabel}</td>
            						<td align="left">
            						<select  id="datarange_{$entries.blockid}" name="datarange_{$entries.blockid}">
                                        <option value="all">{'ALL'|@getFixedLabel}</option>
                                        <option value="permit">{'ALLOWINQUIRE'|@getFixedLabel}</option>
                                    </select>
            						</td>
            					</tr>     
                                <tr id="tr_approvedemand_{$entries.blockid}" style="display:none">
            						<td align="right"><font color="red">*</font>{'APPROVEDEMAND'|@getFixedLabel}</td>
            						<td align="left">
            						 <select id="approve_demand_{$entries.blockid}" name="approve_demand_{$entries.blockid}">
                    					  <option value="0">{'NONE'|@getFixedLabel}</option>
                    					  <option value="1">{'Approved'|@getFixedLabel}</option>
                    				  </select>
            						</td>
            					</tr>
                                <tr id="tr_maxrowsshow_{$entries.blockid}" style="display:none">
            						<td align="right"><font color="red">*</font>{'MaxRowsShow'|@getFixedLabel}</td>
            						<td align="left">
            						<select  id="maxrowsshow_{$entries.blockid}" name="maxrowsshow_{$entries.blockid}">
                                         <option value="5">5</option>
                                         <option value="10">10</option>
                                         <option value="15">15</option>
                                         <option value="20">20</option>
                                         <option value="50">50</option>
                                         <option value="100">100</option>
                                    </select>
            						</td>
            					</tr>
                                <tr id="picklistdetails_{$entries.blockid}" style="display:none;">
            						<td align="right" valign="center"><font color="red">*</font>{'Dropdownboxlistvalues'|@getFixedLabel}</td>
            						<td valign="top">                              
                                        <select class="js-example-tags form-control" multiple="multiple" id="fldpicklist_{$entries.blockid}">
                                         
                                        </select>
            						</td>
            					</tr>
                                <tr id="tr_defaultvalue_{$entries.blockid}" style="display:none">
            						<td align="right">{'LBL_DEFAULTVALUE'|@getFixedLabel}</td>
            						<td align="left">
                                        <input type="text"  class="detailedViewTextBox" id="defaultvalue_{$entries.blockid}_name" name="defaultvalue_{$entries.blockid}_name">
                                        <input type="hidden"  id="defaultvalue_{$entries.blockid}" name="defaultvalue_{$entries.blockid}">
                                        <a class="icon-homeimg icon-select" href="javascript:;" style="float:inherit" id="defaultchoose_btn_{$entries.blockid}" title="{'SELECT'|@getFixedLabel}" onclick='setChooseDefaultvalue("{$MODULE}","{$entries.blockid}");'></a>
                                        <input class="icon-homeimg icon-clear inpb-reset" type="button"  id="defaultclear_btn_{$entries.blockid}" title="{'CLEAR'|@getFixedLabel}" onclick="clear_ChooseDefaultvalue('{$entries.blockid}');return false;"/>
                                        <input class="icon-homeimg icon-clear inpb-reset" type="button"  id="defaultclear_btn_{$entries.blockid}" title="{'CLEAR'|@getFixedLabel}" onclick="clear_ChooseDefaultvalue('{$entries.blockid}');return false;"/>
                						<input  type="checkbox" id="defaultvalue_{$entries.blockid}_chkbox" name="defaultvalue_{$entries.blockid}_chkbox" style="display:none"/>
                                    
                                        <select   id="defaultvalue_{$entries.blockid}_picklist" name="defaultvalue_{$entries.blockid}_picklist"
                                         style="display:none">
                                         </select>
                                       <select   id="defaultvalue_{$entries.blockid}_multipicklist" multiple="" name="defaultvalue_{$entries.blockid}_multipicklist"
                                         style="display:none;">
                                         </select>
                                         <select class="small" id="defaultvalue_{$entries.blockid}_date" name="defaultvalue_{$entries.blockid}_date" style='max-width:160px;'>   

                                            <option value="1" {if $value.defaultvalue.value eq 'thistoday'}selected{/if}>{'now'|@getFixedLabel}</option><!--今天-->
                                            <option value="afterday1" {if $value.defaultvalue.value eq 'afterday1'}selected{/if}>1 {'AFTERDAY'|@getFixedLabel}</option><!--1天后-->
                                        	<option value="afterday2" {if $value.defaultvalue.value eq 'afterday2'}selected{/if}>2 {'AFTERDAY'|@getFixedLabel}</option><!--2天后-->
                                        	<option value="afterday3" {if $value.defaultvalue.value eq 'afterday3'}selected{/if}>3 {'AFTERDAY'|@getFixedLabel}</option><!--3天后-->
                                        	<option value="afterday4" {if $value.defaultvalue.value eq 'afterday4'}selected{/if}>4 {'AFTERDAY'|@getFixedLabel}</option><!--4天后-->
                                        	<option value="afterday5" {if $value.defaultvalue.value eq 'afterday5'}selected{/if}>5 {'AFTERDAY'|@getFixedLabel}</option><!--5天后-->
                                        	<option value="afterday6" {if $value.defaultvalue.value eq 'afterday6'}selected{/if}>6 {'AFTERDAY'|@getFixedLabel}</option><!--6天后-->
                                        	<option value="afterday7" {if $value.defaultvalue.value eq 'afterday7'}selected{/if}>7 {'AFTERDAY'|@getFixedLabel}</option><!--7天后-->
                                        	<option value="afterday8" {if $value.defaultvalue.value eq 'afterday8'}selected{/if}>8 {'AFTERDAY'|@getFixedLabel}</option><!--8天后-->
                                        	<option value="afterday9" {if $value.defaultvalue.value eq 'afterday9'}selected{/if}>9 {'AFTERDAY'|@getFixedLabel}</option><!--9天后-->
                                        	<option value="afterday10" {if $value.defaultvalue.value eq 'afterday10'}selected{/if}>10 {'AFTERDAY'|@getFixedLabel}</option><!--10天后-->
                                        	<option value="afterday11" {if $value.defaultvalue.value eq 'afterday11'}selected{/if}>11 {'AFTERDAY'|@getFixedLabel}</option><!--11天后-->
                                        	<option value="afterday12" {if $value.defaultvalue.value eq 'afterday12'}selected{/if}>12 {'AFTERDAY'|@getFixedLabel}</option><!--12天后-->
                                        	<option value="afterday13" {if $value.defaultvalue.value eq 'afterday13'}selected{/if}>13 {'AFTERDAY'|@getFixedLabel}</option><!--13天后-->
                                        	<option value="afterday14" {if $value.defaultvalue.value eq 'afterday14'}selected{/if}>14 {'AFTERDAY'|@getFixedLabel}</option><!--14天后-->
                                        	<option value="afterday15" {if $value.defaultvalue.value eq 'afterday15'}selected{/if}>15 {'AFTERDAY'|@getFixedLabel}</option><!--15天后-->
                                        	<option value="afterday30" {if $value.defaultvalue.value eq 'afterday30'}selected{/if}>30 {'AFTERDAY'|@getFixedLabel}</option><!--30天后-->
                                        	<option value="afterday60" {if $value.defaultvalue.value eq 'afterday60'}selected{/if}>60 {'AFTERDAY'|@getFixedLabel}</option><!--60天后-->
                                        	<option value="afterday90" {if $value.defaultvalue.value eq 'afterday90'}selected{/if}>90 {'AFTERDAY'|@getFixedLabel}</option><!--90天后-->
                                        	<option value="afterday120" {if $value.defaultvalue.value eq 'afterday120'}selected{/if}>120 {'AFTERDAY'|@getFixedLabel}</option><!--120天后-->
                                        	<option value="afterday180" {if $value.defaultvalue.value eq 'afterday180'}selected{/if}>180 {'AFTERDAY'|@getFixedLabel}</option><!--180天后-->
                                        	<option value="afterday365" {if $value.defaultvalue.value eq 'afterday365'}selected{/if}>365 {'AFTERDAY'|@getFixedLabel}</option><!--365天后-->
                                        </select>
            						</td>
            					</tr>
                                <tr id="tr_relatedmodulefield_{$entries.blockid}" style="display:none">
            						<td align="right"><font color="red">*</font>{'REFERENCEFIELD'|@getFixedLabel}</td>
            						<td align="left">
            						<select  id="relatedmodulefield_{$entries.blockid}" name="relatedmodulefield_{$entries.blockid}">
                                    
                                    </select>
            						</td>
            					</tr>
                        				
                        					
    							<tr id="allow_rewriting_{$entries.blockid}" style="display:none;">
            						<td align="right">{'allowrewriting'|@getFixedLabel}</td>
            						<td align="left">
            							<input type="checkbox" id="fldallow_rewriting_{$entries.blockid}" name="fldallow_rewriting_{$entries.blockid}" class="" value=""/>
            						</td>
            					</tr>
                                <tr id="tr_activate_field_{$entries.blockid}">
            						<td align="right">{'ACTIVATE'|@getFixedLabel}</td>
            						<td align="left">
            							<input type="checkbox"  checked="" id="activate_field_{$entries.blockid}" name="activate_field_{$entries.blockid}" class="" value=""/>
            						</td>
            					</tr>
                                 <tr id="tr_savedatabase_{$entries.blockid}" style="display:none;">
            						<td align="right">{'Savetodatabase'|@getFixedLabel}</td>
            						<td align="left">
            							<input type="checkbox" id="savedatabase_{$entries.blockid}" name="savedatabase_{$entries.blockid}" class="" value=""/>
            						</td>
            					</tr>
                                 <tr id="tr_allowedit_{$entries.blockid}" style="display:none;">
            						<td align="right">{'ALLOWEDITING'|@getFixedLabel}</td>
            						<td align="left">
            							<input type="checkbox" id="allowedit_{$entries.blockid}" name="allowedit_{$entries.blockid}"/>
            						</td>
            					</tr>
                                <tr id="tr_notallowduplicate_{$entries.blockid}">
            						<td align="right">{'Allowed_to_repeat'|@getFixedLabel}</td>
            						<td align="left">
            							<input type="checkbox" id="notallowduplicate_{$entries.blockid}" name="notallowduplicate_{$entries.blockid}" class="" value=""/>
            						</td>
            					</tr>
                               
                               
                                <tr id="tr_requiredfield_{$entries.blockid}">
            						<td align="right">{'Required_fields'|@getFixedLabel}</td>
            						<td align="left">
            							<input type="checkbox" id="requiredfield_{$entries.blockid}" name="requiredfield_{$entries.blockid}" class="" value=""/>
            						</td>
            					</tr>
{*								@edit:liushuai,2020-12-28,reason: 页面设置，字段属性界面去掉【快速创建】一行【style="display: none;"】*}
                                <tr id="tr_quickcreate_{$entries.blockid}" style="display: none;">
            						<td align="right">{'Quickly_create'|@getFixedLabel}</td>
            						<td align="left">
            							<input type="checkbox" id="quickcreate_{$entries.blockid}" name="quickcreate_{$entries.blockid}" class="" value=""/>
            						</td>
            					</tr>
                                <tr id="tr_massedit_{$entries.blockid}" style="display:none;">
            						<td align="right">{'MASSEDIT'|@getFixedLabel}</td>
            						<td align="left">
            							<input type="checkbox" id="massedit_{$entries.blockid}" name="massedit_{$entries.blockid}" class="" value=""/>
            						</td>
            					</tr>
                             </table>
            				 <table border="0" cellspacing="0" cellpadding="5" width="100%" class="layerPopupTransport">
            					<tr>
            					<input type="hidden" name="fieldType_{$entries.blockid}" id="fieldType_{$entries.blockid}" value="Text">
            					<input type="hidden" name="selectedfieldtype_{$entries.blockid}" id="selectedfieldtype_{$entries.blockid}" value="Text">
            					</tr>
                            </table>
                            </div>
                            <div class="greyFont9" style="padding-bottom: 8px;clear:both;text-align:left;padding-left: 12px;"><span style="color:red">*</span>{'CHARACTER'|@getFixedLabel}{'Length'|@getFixedLabel}:{'ACHINESEACCOUNTFORCHARACTERS'|@getFixedLabel}</div>
                        	<div class="E_pbtn" style="padding-top:5px;">
                            	<input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="find_custom_fieldlabel_exists('{$MODULE}','{$entries.blockid}','add');"/><span>&nbsp;</span>
                                <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="addFieldCancel('{$entries.blockid}');"/>
                                   
                            </div>
					
					</div>	
					<!-- end custom field -->
					
					<div id = "movefields_{$entries.blockid}" style="display:none;position:absolute;" class="E_pop_box LdPopWidth300px">
                        <div class="E_pop_tit">
                        	<strong class="E_ptita">{'MOBILEFIELD'|@getFixedLabel}</strong>
                            <a href="javascript:fninvshnew('movefields_{$entries.blockid}');" class="E_ptitc">
                                <img class="E_ptitcimg_r" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
                            </a>
                        </div>
                    	<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="0">
                          <tr>
                            <td class="Note">
                		    <ul class="LdPop_ul6">					
            					<span>{'STFYWTM'|@getFixedLabel}</span>
            					<li>
            						<select id="movefield_assignid_{$entries.blockid}" multiple="">
            						{foreach name=inner item=value from=$entries.movefield}	
            							<option value="{$value.fieldid}">{$value.fieldlabel}</option>
            						{/foreach}
            						</select>
            					</li>
                        	</ul>
                            </td>
                          </tr>
                        </table>
                        <div class="E_pbtn">
                        	<input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="show_move_hiddenfields('{$MODULE}','{$entries.tabid}','{$entries.blockid}','movehiddenfields');"/><span>&nbsp;</span>
                            <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('movefields_{$entries.blockid}');"/>
                            <!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
                        </div>
					</div>						
							
					{if $smarty.foreach.outer.last}
                        <a  class="changeday" href="javascript:void(0);"  onclick="changeBlockorder('block_up','{$entries.tabid}','{$entries.blockid}','{$MODULE}') ">{'BLOCKSUPOFSETTING'|@getFixedLabel}</a>                
					{elseif $smarty.foreach.outer.first}
                        <a class="changeday" href="javascript:void(0);"  onclick="changeBlockorder('block_down','{$entries.tabid}','{$entries.blockid}','{$MODULE}') ">{'BLOCKSDOWNOFSETTING'|@getFixedLabel}</a>
					{else}
                        <a  class="changeday" href="javascript:void(0);"   onclick="changeBlockorder('block_down','{$entries.tabid}','{$entries.blockid}','{$MODULE}') ">{'BLOCKSDOWNOFSETTING'|@getFixedLabel}</a>
					   <a class="changeday" href="javascript:void(0);"  onclick="changeBlockorder('block_up','{$entries.tabid}','{$entries.blockid}','{$MODULE}') ">{'BLOCKSUPOFSETTING'|@getFixedLabel}</a>
                    {/if}
                    
					{if $entries.blockid neq $COMMENTSECTIONID && $entries.blockid neq $SOLUTIONBLOCKID}
                        <a  class="changeday" href="javascript:void(0);"  onclick="fnvshobj(this,'movefields_{$entries.blockid}');">{'MOBILEFIELD'|@getFixedLabel}</a>
					{/if}
					{if $entries.blockid neq $COMMENTSECTIONID && $entries.blockid neq $SOLUTIONBLOCKID}
                        <a   class="changeday" href="javascript:void(0);"  onclick="fnvshobj(this,'hiddenfields_{$entries.blockid}');">{'HIDDENFIELDS'|@getFixedLabel}</a>
					{/if}
					{if $entries.iscustom == 1 }
                        <a   class="changeday" href="javascript:void(0);"  onclick=" deleteCustomBlock('{$MODULE}','{$entries.blockid}','{$entries.no}')">{'DELETEBLOCK'|@getFixedLabel}</a> 
					{/if}
					{if $entries.hascustomtable && $entries.blockid neq $COMMENTSECTIONID && $entries.blockid neq $SOLUTIONBLOCKID }
                       <a  class="changeday" href="javascript:void(0);"  onclick="addField('{$entries.blockid}')">{'ADDCUSTOMFIELDS'|@getFixedLabel}</a>	
                    {/if}
				</div>	
				</td>
			</tr>
			<!--<tr class="a">-->
				{foreach name=inner item=value from=$entries.field}		
                    {if $value.no % 2 == 0}
				  		<!--</tr>-->
				  		{assign var="rightcellclass" value=""}
				  		<!--<tr class="b">-->
                        <tr bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'"  >
				 	{else}
				 		{assign var="rightcellclass" value="class='rightCell'"}
				 	{/if}
				<td width="30%" id="colourButton" >&nbsp;
                <!--
                     * 更新操作
                     * 操作人：lmx
                     * 时间：2014-02-11
                     * 说明：0006940: 控制面板->页面设置：“供应商联系人”页面设置界面，鼠标上下移动，结果页面会动，希望不要动。
                -->
			 	<!--<span onmouseover="tooltip.tip(this, showProperties('{$value.label}',{$value.mandatory},{$value.presence},{$value.quickcreate},{$value.massedit}));" onmouseout="tooltip.untip(false);" >{$value.label}</span>-->
              <span class="drag-handle" style="display:none">☰</span>
                <span>{$value.label}</span>
			 		{if $value.fieldtype eq 'M'}
			 			<font color='red'> *</font>
			 		{/if}
			 	</td>
                {if $value.no % 2 == 0}
				    <td width="19%" align = "right" class="colData" >
                {else}
                    <td width="19%" align = "right" class="colData" style="border-right:none;">
                {/if}
                    <a class="icon-layout icon-layout-edit" href="javascript:;" title="{'EDITPROPERTIES'|@getFixedLabel}" onclick="fun_editField({$value.fieldselect},{$value.uitype},'{$MODULE}');isuitypedisp({$value.fieldselect},{$value.uitype});"></a>
					{if $smarty.foreach.inner.first}
						{if $value.no % 2 != 0}
                            <span class="place marR8"></span>
						{/if}
                        <span class="place marR8"></span>
						{if $value.no != ($entries.field|@count - 2) && $entries.no!=1}
							<a class="icon-layout icon-layout-down marR8" href="javascript:;" title="{'DOWN'|@getFixedLabel}" onclick="changeFieldorder('down','{$value.fieldselect}','{$value.blockid}','{$MODULE}') " ></a>
                        {else}
                            <span class="place marR8"></span>
						{/if}
						{if $entries.no!=1}
                            <a class="icon-layout icon-layout-right marR8" href="javascript:;" title="{'RIGHT'|@getFixedLabel}" onclick="changeFieldorder('Right','{$value.fieldselect}','{$value.blockid}','{$MODULE}')"></a>
						{else}
                            <span class="place marR8"></span>
						{/if}
					{elseif $smarty.foreach.inner.last}
						{if $value.no % 2 != 0}
							<a class="icon-layout icon-layout-left marR8" href="javascript:;" title="{'LEFT'|@getFixedLabel}" onclick="changeFieldorder('Left','{$value.fieldselect}','{$value.blockid}','{$MODULE}')"></a>
                        {/if}
						{if $value.no != 1}
                            <a class="icon-layout icon-layout-up marR8" href="javascript:;" title="{'UP'|@getFixedLabel}" onclick="changeFieldorder('up','{$value.fieldselect}','{$value.blockid}','{$MODULE}') "></a>
						{else}
                            <span class="place marR8"></span>
						{/if}
                        <span class="place marR8"></span>
						{if $value.no % 2 == 0}
                            <span class="place marR8" style="width:16px;"></span>
						{/if}
					{else}
						{if $value.no % 2 != 0}
                            <a class="icon-layout icon-layout-left marR8" href="javascript:;" title="{'LEFT'|@getFixedLabel}" onclick="changeFieldorder('Left','{$value.fieldselect}','{$value.blockid}','{$MODULE}')"></a>
						{/if}
						{if $value.no != 1}
                            <a class="icon-layout icon-layout-up marR8" href="javascript:;" title="{'UP'|@getFixedLabel}" onclick="changeFieldorder('up','{$value.fieldselect}','{$value.blockid}','{$MODULE}') "></a>
						{else}
                            <span class="place marR8"></span>
						{/if}
						{if $value.no != ($entries.field|@count - 2)}
                            <a class="icon-layout icon-layout-down marR8" href="javascript:;" title="{'DOWN'|@getFixedLabel}" onclick="changeFieldorder('down','{$value.fieldselect}','{$value.blockid}','{$MODULE}') " ></a>
						{else}
                            <span class="place marR8"></span>
						{/if}
						{if $value.no % 2 == 0}
                            <a class="icon-layout icon-layout-right marR8" href="javascript:;" title="{'RIGHT'|@getFixedLabel}" onclick="changeFieldorder('Right','{$value.fieldselect}','{$value.blockid}','{$MODULE}')"></a>
						{/if}
					{/if}
				</td>
						
			{/foreach}
			</tr>
		{/if}
	{/foreach}
</table>
</form>