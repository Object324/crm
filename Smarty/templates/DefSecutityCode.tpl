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

<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
	<form action="index.php" method="post" id="form" onsubmit="puyoungJS_DialogBox.block();">
        <input type='hidden' name='module' value='Users'/>
        <input type='hidden' name='action' value='DefModuleView'/>
        <input type='hidden' name='return_action' value='ListView'/>
        <input type='hidden' name='return_module' value='Users'/>
        <input type='hidden' name='parenttab' value='Settings'/>
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">{'CONTROLPANEL'|@getFixedLabel} &gt; {'LBL_SECURITYCODE_SET'|@getFixedLabel}
                <font>（{'LBL_SECURITYCODE_SET_DESCRIPTION'|@getFixedLabel}）</font></span>
        </div>
       
        <div class="pad10" >
	       <table border=0 cellspacing=0 cellpadding=5 width=100% class="TitleHeading">
				<tr>
				<td class="big" height="20px" width="70%"><strong>{'LBL_SECURITYCODE_SET'|@getFixedLabel}</strong></td>
				<td class="small" align="center" width="30%">&nbsp;
                </td>
				</tr>
			</table>
			
			<table border=0 cellspacing=0 cellpadding=0 width=100% class="listRow">
			<tr>
         	    <td class="small" valign=top >
                  <table width="100%"  border="0" cellspacing="0" cellpadding="5">
                    <tr>
                        <td width="20%" class="small cellLabel"><strong>{'ENABLELOGINVERIFYCODE'|@getFixedLabel}</strong></td>
                        <td width="10%" class="small cellText">
                		{if $CODE eq 'true'}
                			<input type="checkbox" checked name="enable_audit" onclick="CodeCheck(this)"></input>
                		{else}
                			<input type="checkbox" name="enable_audit" onclick="CodeCheck(this)"></input>
                		{/if}
                		</td>
                        <td width="70%" align="left" class="small borderBR">
                            <span id="code_info" class="redFont" style="display:none;"></span>
                        </td>
                    </tr>
                  </table>
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
function CodeCheck(obj){
	var status=obj.checked;
	if(status){
		$('code_info').innerHTML=arrJsPopLabel['ENABLELOGINAUTHENTICATIONCODE'];
        $('code_info'). style.display='block';
	}
	else{
		$('code_info').innerHTML=arrJsPopLabel['DISABLELOGINAUTHENTICATIONCODE'];
		$('code_info'). style.display='block';
}
new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'module=Users&action=UsersAjax&file=SaveDefSecutityCode&ajax=true&audit_trail='+ status,
                        onComplete: function(response) {
                        }
                }
        );
	setTimeout("hide('code_info')",3000);//设置3秒隐藏提示 
}
</script>
{/literal}