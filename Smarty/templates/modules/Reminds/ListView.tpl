{*<!--
/*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<div style="display: flex;">
    <div class="ld-listview-left-categorytree" id="ld-listview-left-categorytree" style="width: 10%;min-width: 200px;">
        {include file="modules/Reminds/ListViewCategoryTree.tpl"}
    </div>
    <div style="width: 90%;">
        {include file="ListView.tpl"}
    </div>
</div>
<script>

    var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    listpage_popupobj.clsremindsobj = new cls_Reminds();
    // 将消息分类的id存在列表界面的popupobj上
    listpage_popupobj.remindscategoryid = '{$selected_remindscategoryid}';
        
</script>