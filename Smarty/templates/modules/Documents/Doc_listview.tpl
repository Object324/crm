
<div id="orgLay" class="D_pop_box LdPopWidth400px" style="display:none;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'ADDFOLDER'|@getFixedLabel}</strong>
        <a href="javascript:closeFolderCreate();" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
          <tr>
            <td align="right"><font color="red">*</font>{'Folder_name'|@getFixedLabel}:</td>
            <td>
				<input id="folder_id" name="folderId" type="hidden" value=''/>
				<input id="fldrsave_mode" name="folderId" type="hidden" value='save'/>                    
				<input id="folder_name" name="folderName"  type="text" style="border:1px solid #eee"/>
                &nbsp;&nbsp;{'20word_limit'|@getFixedLabel}
            </td>
          </tr>
          <tr>
            <td align="right">{'DESCRIPTION'|@getFixedLabel}:</span></td>
            <td>
                <input id="folder_desc" name="folderDesc" type="text" style="border:1px solid #eee"/>
                &nbsp;&nbsp;{'50word_limit'|@getFixedLabel}
            </td>
          </tr>
        </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="AddFolder();"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="closeFolderCreate();"/> 
    </div>
</div>
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