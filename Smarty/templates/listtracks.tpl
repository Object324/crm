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
<script src="MultiDatesPicker/js/jquery-ui-1.11.1.js" type="text/javascript"></script> 
<link href="MultiDatesPicker/css/jquery-ui.css" type="text/css" rel="stylesheet"/>
<script src="MultiDatesPicker/js/prettify.js" type="text/javascript"></script> 
<script src="MultiDatesPicker/js/lang-css.js" type="text/javascript"></script> 
<script src="MultiDatesPicker/jquery-ui.multidatespicker.js" type="text/javascript"></script> 
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="javascript" src='include/js/ajax.js'></script>
<script language="javascript" src='{$JSURL}include/js/SetUeryScope.js'></script>
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js"></script>
<script>
  function CopyRole(obj,roleid)
  {ldelim}
    window.location.href="index.php?module=Settings&action=createrole&mode=edit&parenttab=Settings&roleid="+roleid+"&copyRole=copyRole";
  {rdelim}
   function displayCoords(event) 
	 {ldelim}
				var move_Element = document.getElementById('Drag_content').style;
				if(!event){ldelim}
						move_Element.left = e.pageX +'px' ;
						move_Element.top = e.pageY+10 + 'px';	
				{rdelim}
				else{ldelim}
						move_Element.left = event.clientX +'px' ;
					    move_Element.top = event.clientY+10 + 'px';	
				{rdelim}
	{rdelim}
  
	  function fnRevert(e)
	  {ldelim}
		  	if(e.button == 2){ldelim}
				document.getElementById('Drag_content').style.display = 'none';
				hideAll = false;
				parentId = "Head";
	    		parentName = "DEPARTMENTS";
			    childId ="NULL";
	    		childName = "NULL";
			{rdelim}
	{rdelim}

</script>


<!--中间-->
<div class="List3Box" ><!-- style="background-color:blue;width:1264px;overflow:hidden;" -->
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols" style="">
	<tr>
		<td class="TdLeft" valign="top" style="width:200px;">
		{include file='SetMenuNew.tpl'}
		</td>
		<td class="Tdcenter" valign="top" style="padding: 0 15px;">
		 <form action="index.php" method="post" name="currencyForm" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Settings"/>
		<input type="hidden" name="action" value="CurrencyEditView"/>
		<input type="hidden" name="parenttab" value="{$PARENTTAB}"/>
		<input type="hidden" id="blockidsetting" value="{$BLOCKIDSETTING}"/>
		<input type="hidden" id="fieldidsetting" value="{$FIELDIDSETTING}"/>
        
		<div class="DivCR">       
			<div class="ControlDiv1">
				<span class="Url fontbold">
				{'CONTROLPANEL'|@getFixedLabel} &gt; {'TRACKPOSITONINGGROUP'|@getFixedLabel}
				<font>（{'DEFINEWORKTRACKPOSITIONINGTIMEANDMEMBERS'|@getFixedLabel}）</font>
				</span>
			</div>
			<div class="ControlDiv2">
				<div class="F_r">
					<input type="button" value="{'ADDLESSIONPLAN'|@getFixedLabel}"  onclick="CreateTracks('','')" class="createauto" />
				</div>
			</div>

            <div class="pad10 nopadding mar-1" >
					{include file='TrackTree.tpl'}			
			</div> 
		</div>
	</form>		
	</td>
  </tr>
</table>
</div>
<!--编辑权限-->
<div id="EditTrackProfile"></div>
<!--分配权限-->
<div id="AllocateTrackProfile"></div>
<!--中间 end-->
<!--生成工作日历列表弹出层-->
<div id="listworkcalender"></div>
<div id="EditWorkingSpace"></div>
<div id="addWorkingday"></div>