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
<input type="submit" name="next" value="{'NEXT'|@getFixedLabel}" class="big edit"
	   onclick="return ImportJs.uploadAndParse();" />
&nbsp;&nbsp;
<input type="button" name="cancel" value="{'CANCEL'|@getFixedLabel}" class="big cancel"
	   onclick="location.href='index.php?module={$FOR_MODULE}&action=index'" />