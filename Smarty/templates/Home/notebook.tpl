{*<!--/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/notebook.js"></script>
<div class="notebook-con" id="notebook_contents_{$NOTEBOOKID}" ondblclick="editContents(this, {$NOTEBOOKID})" title="{$MOD.LBL_NOTEBOOK_TITLE}">	
	<pre {if $NOTEBOOK_CONTENTS eq ''}style="display:none;"{/if}>{$NOTEBOOK_CONTENTS}</pre>	
</div>
	<div class="notebook-con" id="notebook_div_{$NOTEBOOKID}" style="display:none;">
        <textarea class="notebook_tex" id='notebook_textarea_{$NOTEBOOKID}' onfocus='this.className="notebook_tex"' rows="18" onblur='saveContents(this, {$NOTEBOOKID})' title="{$MOD.LBL_NOTEBOOK_SAVE_TITLE}"></textarea>
    </div>
<div style="padding-left: 10px;display: none;" id="notebook_save_message">
	<font color="grey">
		{$MOD.LBL_NOTEBOOK_SAVE_TITLE}
	</font>
</div>