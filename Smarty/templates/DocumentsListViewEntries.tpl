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

{if $smarty.request.ajax neq ''}
&#&#&#{$ERROR}&#&#&#
{/if}
<div class="Category">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="middle" class="L" width="75"><div class="Title"><span>{'DATACATEGORY'|@getFixedLabel}</span></div></td>
    <td valign="middle" class="C">
    	<ul>
            {$CUSTOMVIEW_OPTION}
        </ul>
     </td>
     <td valign="middle" class="R">
    	<div class="Xl">
        	<a class="Xl_a" id="viewoperate" onclick="return false;" onmouseout="fnHideDrop('selectviewoperate');" onmouseover="ViewfnDropDown(this,'selectviewoperate');" href="javascript:void(0);">{'CREATECATEGORY'|@getFixedLabel}<span class="icon-bluetriangle"></span></a>
            <!-- Filters -->
		   {if $HIDE_CUSTOM_LINKS neq '1'}
			<ul onmouseover="fnShowDrop('selectviewoperate')" onmouseout="fnHideDrop('selectviewoperate')"  id="selectviewoperate" style="display:none;">                                           
				       <li>
						<a href="index.php?module={$MODULE}&action=CustomView&parenttab={$CATEGORY}&SearchScope={$SelectedOwner2}">{'CREATECATEGORY'|@getFixedLabel}</a>		
                       </li>
                       {if $CV_EDIT_PERMIT eq 'yes'}
							<li>
                                <a href="index.php?module={$MODULE}&action=CustomView&record={$VIEWID}&parenttab={$CATEGORY}&SearchScope={$SelectedOwner2}">{'EDIT'|@getFixedLabel}</a>
                            </li>
                       {/if}
                       {if $ALL neq 'All'}
                           {if $CV_DELETE_PERMIT eq 'yes'}
    							<li>
                                    <a href="javascript:confirmdelete('module=CustomView&action=Delete&dmodule={$MODULE}&record={$VIEWID}&parenttab={$CATEGORY}&SearchScope={$SelectedOwner2}','CustomView')">{'DELETE'|@getFixedLabel}</a>
                                </li> 
                            {/if}
                        {/if}
                   <li>
                       <a href="index.php?module={$MODULE}&action=CustomView&record={$VIEWID}&parenttab={$CATEGORY}&viewcopy=true&SearchScope={$SelectedOwner2}" >{'COPY'|@getFixedLabel}</a>                       
                   </li>
                   <!--sort view-->
                   {if $IS_ADMIN}
                        <li>
		   				<a class="drop_down" href="javascript:void(0);"  onClick="ShowSortView(this,'sortview','{$MODULE}')">{'SORT'|@getFixedLabel}</a>
                        </li>
                   {/if}
                   </ul> 
			{/if}
            <!-- Filters  END-->
        </div>
    </td>
    </tr>
  </table>
  </div>      
  <div class="clear"></div>
  <input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
<form name="massdelete" method="POST" id="massdelete">
	<input name='search_url' id="search_url" type='hidden' value='{$SEARCH_URL}'>
	<input name="idlist" id="idlist" type="hidden">
	<input name="change_owner" type="hidden">
	<input name="change_status" type="hidden">
	<input name="action" type="hidden">
	<input name="where_export" type="hidden" value="{php} echo to_html($_SESSION['export_where']);{/php}">
	<input name="step" type="hidden">
	<input name="allids" type="hidden" id="allids" value="{$ALLIDS}">
	<input name="allselectedboxes" id="allselectedboxes" type="hidden" value="">
	<input name="current_page_boxes" id="current_page_boxes" type="hidden" value="{$CURRENT_PAGE_BOXES}">
	<!-- List View Master Holder starts -->
	<table border="0" cellspacing="1" cellpadding="0" width="100%" class="lvtBg">
		<tr>
			{if $NO_FOLDERS eq 'yes'}
				<td width="100%" valign="top" height="250px;"><br><br>
					<div align="center"> <br><br><br><br><br>
						<table width="80%" cellpadding="5" cellspacing="0"  class="searchUIBasic small" align="center" border=0>
							<tr>
								<td align="center" style="padding:20px;">
									<a href="javascript:;" onclick="fnvshobj(this,'orgLay');">{$MOD.LBL_CLICK_HERE}</a>&nbsp;{$MOD.LBL_TO_ADD_FOLDER}
								</td>
							</tr>
						</table>
                    </div>
				</td>
			{else}
				<td>
					<table width="100%">
						<tr>
							<td>
								<!-- List View's Buttons and Filters starts -->
								<table border=0 cellspacing=0 cellpadding=0 width=100% class="small">
									<tr>
										<td>
										    {assign var="buttonsPosition" value='up'}
											{include file="ListViewButtons.tpl"}
											{include file='SearchScope.tpl'}	
										</td>
										<!--<td width="100%" align="right"></td>-->
									</tr>
								</table>
	                            <!-- List View's Buttons and Filters ends -->
                                {$DEAILHTML}
							</td>
						{/if}
						<!-- conditional statement for $NO_FOLDERS ends -->
					</tr>
				</table>

                <div id="emptyfolder" class="D_pop_box LdPopWidth600px" style="display:none;">
                	
                    <div class="D_pop_tit">
                    	<strong class="D_ptita">{'VIEWEMPTYFOLDER'|@getFixedLabel}</strong>
                        <a href="javascript:fninvshnew('emptyfolder');" class="D_ptitc">
                            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
                        </a>
                    </div>
                    <div class="scrollContent" style="height:auto;max-height:260px;">
                	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
                      <tr>
                        <td align="center">
                            <table class="DocumentsEmptyfolderPop" cellspacing="1" cellpadding="0" border="0" width="100%">
                            {foreach item=folder from=$EMPTY_FOLDERS}
                                <tr align="left">
               					 	<td>{$folder.foldername}</td>
    								{if $IS_ADMIN eq "on" && $folder.folderid neq "1"}
   									<td width="30">
                                       <a class="icon-homeimg icon-sdel" href="javascript:;" onclick="DeleteFolderCheck({$folder.folderid});"></a>
                                    </td>
    								{else}
    								<td>&nbsp;</td>
    								{/if}
    							 </tr>
        					{/foreach}
                            </table>
                        </td>
                      </tr>
                    </table>
                    </div>
                </div>
			</td>
		</tr>
	</table>
<div id="movefolderlist" class="D_pop_box LdPopWidth600px" style="display:none;">
	
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'Move_to'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('movefolderlist');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td>
    		<ul class="LdPop_ul1 DocumentsMovePop">
				{foreach item=folder from=$ALL_FOLDERS}
					<li>
						<a href="javascript:;" onClick="MoveFile('{$folder.folderid}','{$folder.foldername}');" > {$folder.foldername}</a>
				    </li>
				{/foreach}
			</ul>
        </td>
      </tr>
    </table>
</div>
</form>
<input type="hidden" value="{$BATCHNUM}" id='batchnum' />
{$SELECT_SCRIPT}
<div id="basicsearchcolumns" style="display:none;"><select name="search_field" id="bas_searchfield" style="width:150px">{html_options  options=$SEARCHLISTHEADER}</select></div>
<script>
	{literal}
		function showHideFolders(show_ele, hide_ele) {
			var show_obj = document.getElementById(show_ele);
			var hide_obj = document.getElementById(hide_ele);
			if (show_obj != null) {
				show_obj.style.display="block";
			}
			if (hide_obj != null) {
				hide_obj.style.display="none";
			}
		}
	{/literal}
</script>