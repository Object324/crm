<div class="ld-flex-between gwidth100 ld-flex-wrap" id="ListViewBtnAndSeach">
    <div class="ld-flex-start ld-flex-wrap">
        {* BUG20240516-02 去掉这个查询分类的显示*}
        {*{if $MODULE neq 'Reminds' && $MODULE neq 'Approve'}
        <!--数据分类-->
            <div class="Category_New">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td valign="middle" class="C">
                            <span class="category_span">{'DATACATEGORY'|@getFixedLabel} : {'ALL'|@getFixedLabel}</span>
                        </td>
                    </tr>
                </table>
            </div>
        {/if}*}
        {* 查看范围*}
        {*BUG20240826-52 	首页简报或其他组件穿透后，不显示查看范围*}
        {*{if $showSearchScopeChuantou eq 'yes'}
        <div class="ld-listview-chooseusers">
            {include file='SearchScopeChuantou.tpl'}
        </div>
        {/if}*}
        <div class="marL15 marR10 ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
            {*基本查找组件 zxm 20221212*}
            {include file='ListViewBasicSearch_Chuantou.tpl'}
        </div>
        <div class="Category Category_New" style="width:auto;">
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td valign="middle" class="C">
                        <ul>
                            <li id="categoryAdvsear" tag="firstnode"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);"><b class="icon-categorybtn categoryAdvsear-search"></b>{'CUSTOMIZESEARCH'|@getFixedLabel}</a></div></li>
                            {if $export_display=='yes'}
                                <li id="categoryExport"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);"><b class="ld-fonticon ld-fonticon-export"></b>{'EXPORT'|@getFixedLabel}</a></div></li>
                            {/if}
                        </ul>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div class="ld-flex-end ld-flex-wrap" style="margin-left: auto;">
        <!--分页-->
        <div class="PageDiv0">
            <div class="ld-flex-start" style="position: relative;">
                <div class="ld-pagenum-div">{$recordListRange}</div>
                {$NAVIGATION}
            </div>
        </div>
    </div>
</div>

