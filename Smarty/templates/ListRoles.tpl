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
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Roles.js?v=2"></script>
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
<form action="index.php" method="post" name="currencyForm" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="module" value="Settings"/>
	<input type="hidden" name="action" value="CurrencyEditView"/>
	<input type="hidden" name="parenttab" value="{$PARENTTAB}"/>
	<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
	<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <div class="main_grid lfloat">
        <div class="main_grid_top">
		    <div class="grid-view-title lfloat overflow-hidden">
		        <span class="grid-view-name dinline-block lfloat">
		        </span>
		    </div>
		    <div class="grid_tool">
		        <div class="create-entity-toolbar lfloat prelative">
		        	<a href="javascript:;" onclick="CreateProfile()" class="ld-button ld-button-primary" title="{'ADDLESSIONPLAN'|@getFixedLabel}{'LBL_PROFILES'|@getFixedLabel}">{'ADDLESSIONPLAN'|@getFixedLabel}{'LBL_PROFILES'|@getFixedLabel}</a>
		        </div>
		    </div>
		</div>
		<div class="main_grid_box">
		    <div class="grid-analysis-box">
		        <div class="grid-analysis-header">
		        </div>
		        <div class="cont_wrap clear_float">
		            {$ROLETREE}
		        </div>
		    </div>
		</div>
    </div>
</form>
<!--删除权限-->
<div id='delprofile'></div>
<!--中间 end-->
<div id="Drag_content">&nbsp;</div>
<div id="setmember"></div>
<script language="javascript" type="text/javascript">
	var hideAll = false;
	var parentId = "";
	var parentName = "";
	var childId ="NULL";
	var childName = "NULL";
	var oftenusereporttabid='{$OFTENUSEREPORTTABID}';
	var reportnames='{$OFTENREPORTNAMES}';
	var mobilereportnames='{$MOBILEREPORTNAMES}';
	var setmember_title = '{$setmember}'
	function get_parent_ID(obj,currObj)
	{ldelim}
			var leftSide = findPosX(obj);
    			var topSide = findPosY(obj);
			var move_Element = document.getElementById('Drag_content');
		 	childName  = document.getElementById(currObj).innerHTML;
			childId = currObj;
			move_Element.innerHTML = childName;
			move_Element.style.left = leftSide + 15 + 'px';
			move_Element.style.top = topSide + 15+ 'px';
			move_Element.style.display = 'block';
			hideAll = true;	
	{rdelim}

	function fnVisible(Obj)
	{ldelim}
			if(!hideAll)
				document.getElementById(Obj).style.visibility = 'visible';
	{rdelim}

	function fnInVisible(Obj)
	{ldelim}
		document.getElementById(Obj).style.visibility = 'hidden';
	{rdelim}

	function showhide(argg,imgId)
	{ldelim}
		var harray=argg.split(",");
		var harrlen = harray.length;	
		var i;
		for(i=0; i<harrlen; i++)
		{ldelim}
			var x=document.getElementById(harray[i]).style;
	        	if (x.display=="none")
	        	{ldelim}
	           		x.display="block";
				document.getElementById(imgId).src="{'minus.gif'|@lingdang_imageurl:$THEME}";
	         	{rdelim}
	        	else
			{ldelim}
				x.display="none";
				document.getElementById(imgId).src="{'plus.gif'|@lingdang_imageurl:$THEME}";
			{rdelim}
		{rdelim}
	{rdelim}
</script>
<script language="javascript" type="text/javascript">
{literal}
   
	var Imagid_array = new Array('img_2','img_4','img_6','img_7','img_8','img_9','img_10','img_13','img_14','img_18','img_19','img_20','img_21','img_22','img_23','img_26')
	
	//高度
	ld('.main_grid .main_grid_box').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top)+'px');
{/literal}
//角色权限拖拽排序	weiyannan BUG0075295
getJsScript('include/js/modules/Settings/Roles.js',function (){
	profileMovetable();
});
</script>