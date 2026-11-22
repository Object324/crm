{*页签*}
<div class="ld_listviewnavbar" style="width: 100%;">{include file='ListViewNavBar.tpl'}</div>
{*wym 240206 BUG20240204-15 审批去除这一行的查看范围和按钮*}
{*duan 240419 BUG20240418-32 审批中心页面中，新版本没有“恢复预设列宽”和“查看范围”麻烦恢复一下(?)*}
<div class="ListViewNavBarAndBtn" id="ListViewNavBarAndBtn" {if $MODULE eq 'Reminds' && $listviewtopuitype neq 3}style="display:none;"{/if}>
    {if $MODULE neq 'Reminds' && $MODULE neq 'Approve' && $MODULE neq 'ShoppingMall'}
        <div id="customListSequence">
        {include file='SelectCustomView_Group.tpl'}
        </div>
        {if $NO_CUSTOMVIEW eq 'sdw12122121312312'}
            <li id="createCategory" tag="firstnode" class="D_menu_hova Xl" onclick="createCategory();">
                <div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="DataCategoryListPopup.add()"><b class="icon-categorybtn icon-categoryAdd"></b>{'CREATECATEGORIES'|@getFixedLabel}</a></div>
            </li>
        {/if}
    {/if}
    <!--按钮、查看范围-->
    {assign var="buttonsPosition" value='up'}
    {include file='SearchScope_New.tpl'}
    {if $listviewtopuitype eq 3}
        <div class="marL15 marR10 ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
            {*基本查找组件 zxm 20221212*}
            {include file='ListViewBasicSearch.tpl'}
        </div>
    {/if}
    <!--列表按钮-->
    {if $listviewtopuitype eq 1}
        {include file='ListViewNavBtn.tpl'}
    {/if}
</div>
