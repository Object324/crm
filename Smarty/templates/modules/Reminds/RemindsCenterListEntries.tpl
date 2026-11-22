<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/component/ld_NavBar.js?v={$GLOBALMINVERSION}"></script>
<div id="RemindsCenterSearcharea" class="ld-remindscenter-list-searcharea">
    <!--基本查找-->
    {if $listviewtopuitype neq 3}
        <div class="marR10 ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
            {*基本查找组件 zxm 20221212*}
            {include file='ListViewBasicSearch.tpl'}
        </div>
    {/if}
    <!--高级查找-->
    <div class="Category Category_New" style="width:auto;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td valign="middle" class="C">
                    <ul>
                        {* {if $HIGBTNSTATUS neq 'no'} *}
                            <li id="categoryAdvsear" tag="firstnode"><div style="padding: 0 6px;">
                                <a href="javascript:void(0);"><b class="icon-categorybtn categoryAdvsear-search tip-items-list" data-tip="{'CUSTOMIZESEARCH'|@getFixedLabel}" data-direction="top" data-type="position"></b></a>
                            </li>
                        {* {/if} *}
                    </ul>
                </td>
            </tr>
        </table>
    </div>
</div>
<div id="RemindsCenterListSection">
    {include file="modules/Reminds/RemindsCenterList.tpl"}
</div>