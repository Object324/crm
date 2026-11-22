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
<script language="JavaScript" type="text/javascript" src="include/js/picklist.js"></script>
<script language="JAVASCRIPT" src="include/scriptaculous/scriptaculous.js" type="text/javascript"></script>
<script language="JAVASCRIPT" src="{$JSURL}modules/Home/Homestuff.js" type="text/javascript"></script>

<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">{'CONTROLPANEL'|@getFixedLabel} &gt; {'LBL_PICKLIST_EDITOR'|@getFixedLabel}
                <font>（{'LBL_PICKLIST_DESCRIPTION'|@getFixedLabel}）</font>
            </span>
        </div>
        <div id="picklist_datas">
			{include file='modules/PickList/PickListContents.tpl'}
		</div>
                 
      </div>
      		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->
<div id="actiondiv" class="D_pop_box LdPopWidth300px" style="display:none;position:absolute;"></div>
<div id="editdiv" style="display:none;position:absolute;width:510px;"></div>