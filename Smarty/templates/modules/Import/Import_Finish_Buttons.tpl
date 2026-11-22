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
<input type="button" name="next" value="{'LBL_IMPORT_MORE'|@getFixedLabel}" class="createauto"
	   onclick="location.href='index.php?module={$FOR_MODULE}&action=Import&return_module={$FOR_MODULE}&return_action=index'" />
&nbsp;&nbsp;
<input type="button" name="next" value="{'LBL_VIEW_LAST_IMPORTED_RECORDS'|@getFixedLabel}" class="cancelauto"
	   onclick="return window.open('index.php?module={$FOR_MODULE}&action={$FOR_MODULE}Ajax&file=Import&mode=listview&start=1&foruser={$OWNER_ID}','test','width=700,height=650,resizable=1,scrollbars=0,top=150,left=200');" />
&nbsp;&nbsp;
{if $MERGE_ENABLED eq '0'}
<input type="button" name="next" value="{'LBL_UNDO_LAST_IMPORT'|@getFixedLabel}" class="deleteauto"
	   onclick="location.href='index.php?module={$FOR_MODULE}&action=Import&mode=undo_import&foruser={$OWNER_ID}'" />
&nbsp;&nbsp;
{/if}
<input type="button" name="cancel" value="{'LBL_FINISH_BUTTON_LABEL'|@getFixedLabel}" class="editauto"
	   onclick="location.href='index.php?module={$FOR_MODULE}&action=index'" />