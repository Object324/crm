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
<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
    <div id="resize_header_table_divid" name="resize_header_table_divid" style="visibility: visible; top: 194px; overflow: hidden;">
        <div style="float:left;padding-right: 20px" name="listviewheader">
            <table id="resize_header_tableid" name="resize_header_tableid" class="listEntries" border="0" cellspacing="1" cellpadding="0" >
                <tbody>
                <tr>
                    {$headerHtml}
                </tr>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
    <div id="resize_content_table_divid" name="resize_content_table_divid" style="overflow: auto" >
        <table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid"  class="listEntries marT-53">
            <tbody>
            <tr>
                {$headerHtml}
            </tr>
            {$TABLE}
            </tbody>
        </table>
    </div>
</div>

{if $HAIGE_POTENTIALID_ALLOWEDIT neq 'no'}
<div class="redFont" id="redfont_tip" style="margin:10px 0 0;">{'DSFMFFQOTSTT5OTQR'|@getVarFixedLabel:$LIMITCOUNT}
{if $RULEDESCRIPTIOM eq 'yes'}
<span style="margin-left: 20px;"><a href="javascript:;" onclick="show_description()">{'RECOMMENDATIONRULES'|@getFixedLabel}</a></span>
{/if}
</div>
{/if}
<script language="JavaScript" type="text/javascript" src="include/js/cls_ModuleTree.js?v={$GLOBALMINVERSION}"></script>
<script>
    var module = '{$MODULE}'
    var tree_enable= empty('{$POPUPMODULElISTTREE.enable}')?'{$tree_enable}':'{$POPUPMODULElISTTREE.enable}';
    if(tree_enable == 'yes'){
        var popupobj=CrmPopup.getPopupObj("last");
        popupobj.module = module;
        var structureTreeobj=new structureTree();
        structureTreeobj.setEvent();
        structureTreeobj.treeWidth = empty('{$POPUPMODULElISTTREE.tree_width}')?'{$tree_width}':'{$POPUPMODULElISTTREE.tree_width}';
        // ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
        popupobj.list_TreeWhere = '{$Encrypt_TreeWhere}';
        structureTreeobj.getPopupModuleTreeCount(popupobj);
    }
</script>