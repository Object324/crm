/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//16222: 评论>新增,关于选择相关对象的问题
function setAccountInfo(account_id, account_name)
{
    
    document.getElementById('related_to').value=account_id;
    document.getElementById('related_to_name').value=account_name;
}