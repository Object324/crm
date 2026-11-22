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

<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<!--修改编码格式:统一编码：UTF-8-->

<!--中间-->
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form action="index.php" method="post" name="AuditTrail" id="form" onsubmit="puyoungJS_DialogBox.block();">
        <input type='hidden' name='module' value='Settings'/>
        <input type='hidden' name='action' value='AuditTrail'/>
        <input type='hidden' name='return_action' value='ListView'/>
        <input type='hidden' name='return_module' value='Settings'/>
        <input type='hidden' name='parenttab' value='Settings'/>

        
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
                {'CONTROLPANEL'|@getFixedLabel} &gt; 
                {'LBL_AUDIT_TRAIL'|@getFixedLabel}
                <font>（{'LBL_AUDIT_DESCRIPTION'|@getFixedLabel}）</font>
            </span>
        </div>
        <div class="pad10" >
            <table width="100%"  border="0" cellspacing="0" cellpadding="5">
                <tr class="TitleHeading">
				    <td height="20px" colspan="3"><strong>{'LBL_AUDIT_TRAIL'|@getFixedLabel}</strong></td>
				</tr>
                <tr>
                    <td width="20%" nowrap class="cellLabel borderT"><strong>{'ENABLEAUDITTRAILS'|@getFixedLabel} </strong></td>
                    <td width="10%" class="borderBR">
        			{if $AuditStatus eq 'enabled'}
        				<input type="checkbox" checked name="enable_audit" onclick="auditenabled(this)"/>
        			{else}
        				<input type="checkbox" name="enable_audit" onclick="auditenabled(this)"/>
        			{/if}
        			</td>
                    <td width="70%" class="borderBR">
                        <span id="audit_info" class="redFont" style="display:none;"></span>
                    </td>
                </tr>
                <tr>
                    <td nowrap class="cellLabel"><strong>{'SELECTUSER'|@getFixedLabel}</strong></td>
                    <td class="borderBR">
    				{assign var=fldname value='user_list'}
                	<select id="user_list" name="user_list" style="display:none">
                        {foreach key=User_id item=User_value from=$USERLIST}
                            {foreach key=User_name item=User_name_value from=$User_value}
                                {if $User_name_value eq 'selected'}
                                    {assign var=optText value=$User_name}
                                    <option value="{$User_id}" selected="true">{$User_name}</option>
                                {else}
                                    <option value="{$User_id}">{$User_name}</option>
                                {/if}
                            {/foreach}
                        {/foreach}
                    </select>
                    <div id="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
                     	<a style="width:110px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1"
                         id="cmb_a_{$fldname}">
							<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0" name='cmb_span_optiontext_{$fldname}' id='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" value="{$optText}">
                            <div>
                                <b></b>
                            </div>
                	    </a>
                	    <div style=" left:-9000px;width: 118px; top: 25px;" class="chzn-drop" id='dv_drop_{$fldname}' >
                			 <ul class="chzn-results" id="cmb_ul_{$fldname}">
                				{assign var="i" value=0}
                        	   {foreach key=User_id item=User_value from=$USERLIST}
                                    {foreach key=User_name item=User_name_value from=$User_value}
                 	                    <li  class="active-result" id="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$User_name}</li>
										{assign var="i" value=$i+1}   
                                    {/foreach}
                	            {/foreach}
                                   <li style="" class="" id="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                			 </ul>
                	    </div>
                    </div>	
                    
    			    </td>
    			    <td class="borderBR" align=right>
		                 <input title="{'VIEWAUTIDTRAIL'|@getFixedLabel}" class="editauto b_radius3" onclick="showAuditTrail();" style="border:none;" type="button" name="button" value="{'VIEWAUTIDTRAIL'|@getFixedLabel}" />&nbsp;&nbsp;
    				</td>	
                </tr>
                    
          </table>
	                   
        </div>         
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->


{literal}
<script>

function auditenabled(ochkbox)
{
	if(ochkbox.checked == true)
	{
	     var status='enabled';
         $('audit_info').innerHTML = arrJsPopLabel['ENABLEAUDITTRAIL'];
	     $('audit_info').style.display = 'block';	
	}
	else
	{
	    var status = 'disabled';	
	     $('audit_info').innerHTML = arrJsPopLabel['DISABLEAUDITTRAIL'];
	     $('audit_info').style.display = 'block';		
	
	}
             $("status").style.display="block";
	     new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'module=Settings&action=SettingsAjax&file=SaveAuditTrail&ajax=true&audit_trail='+status,
                        onComplete: function(response) {
                                $("status").style.display="none";
                        }
                }
        );
			
	setTimeout("hide('audit_info')",3000);
}
/*
edit:cdw
date:20130726
reason:0004506: 控制面板-操作日志中：去掉“crm”字体，IE8浏览器上最大化按钮无效置灰
*/
function showAuditTrail()
{
	
	var userid = $('user_list').options[$('user_list').selectedIndex].value;
	window.open("index.php?module=Settings&action=SettingsAjax&file=ShowAuditTrail&userid="+userid,"","width=645,height=520,resizable=yes,scrollbars=1,left=100");
	

}
</script>
{/literal}