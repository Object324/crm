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
<script language="javascript" src='include/js/ajax.js'></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/LoginPolicy.js?v=2"></script>

<form action="index.php" method="post" name="LoginPolicy_currencyForm" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="module" value="Settings"/>
	<input type="hidden" name="action" value="LoginPolicy"/>
	<input type="hidden" name="parenttab" value="Settings"/>
	<!-- <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/> -->
	<!-- <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/> -->
    <div class="main_grid lfloat">
        <div class="main_grid_top">
		    <div class="grid-view-title lfloat overflow-hidden">
		        <span class="grid-view-name dinline-block lfloat">
		        </span>
		    </div>
		    <div class="grid_tool">
		        <div class="create-entity-toolbar ld-listview-btnscontent">
		        	<a href="javascript:;" onclick="LoginPolicy.create(0,'create')" class="ld-button ld-button-primary" title="{'ADDRULES'|@getFixedLabel}">{'ADDRULES'|@getFixedLabel}</a>
		        </div>
		    </div>
		</div>
		<div class="main_grid_box">
		    <div class="grid-analysis-box">
		        <div class="grid-analysis-header">
		        </div>
		        <div class="cont_wrap clear_float" name="LoginPolicy">
		            {$TABLEINFO}
		        </div>
		    </div>
		</div>
    </div>
</form>
<script>
	// const loginpolicy = LoginPolicy();
	LoginPolicy.movetable();
	
    //修改左上角名称
    ld("title").html("{'LOGINPOLICY'|@getFixedLabel}");
    ld(".detail_path li").html("{'LOGINPOLICY'|@getFixedLabel}");
</script>