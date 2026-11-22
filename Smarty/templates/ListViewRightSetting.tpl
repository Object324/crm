
<input type="hidden" id="customview_record" value="{$customview_record}"/>
<div class="first-drawer-header" id="first-drawer-header">
    <span class="first-drawer-title">{'SETTINGS'|@getFixedLabel}</span>
    <div class="first-drawer-headerbtn">
        <button type="button"><i class="ld-fonticon ld-fonticon-close"></i></button>
    </div>
</div>
<div class="ld-listview-right-setting-content" id="ld-listview-right-setting-content">
    {if $is_set eq 'yes'}
        {*gxj 230713 BUG0069420 kfbcrm-单据序时簿列表界面-列表设置-不是管理员账号也会显示表格设置区块*}
        <div class="DivCName DivCNamehover" data-blocktype="tabsetting">
            <label class="cursorPointer" style="display:inline-block;">
                <span class="" id="aid102" name="aid102"></span>{'TABLESETTINGS'|@getFixedLabel}
            </label>
        </div>
        <div id="ld-listview-right-setting-tabsetting" class="first-drawer-content-items" style="padding: 0;">
            {*txy BUG0069081 kfbcrm英文版-列表界面-表格设置-组件错位*}
            <div class="first-drawer-content-item {if $languageType == 'en'}ld-listview-right-setting-tabsetting-en{/if}" style="margin: 0px;padding: 16px;">
                <label class="drawer-content-item-title sort-tip-items" data-tip="{'Rowheightsetting'|@getFixedLabel}" data-direction="top" data-type="position">{'Rowheightsetting'|@getFixedLabel}</label>
                <div role="radiogroup" class="el-radio-group el-radio-group-listpageheight">
                    <label role="radio" class="el-radio-button el-radio-button--mini">
                        <input name="listpageheight" type="radio" class="el-radio-button__orig-radio" value="compact">
                        <span class="el-radio-button__inner overflow-space" style="max-width: 84px;">{'compact'|@getFixedLabel}</span>
                    </label>
                    <label role="radio" class="el-radio-button el-radio-button--mini">
                        <input name="listpageheight" type="radio" class="el-radio-button__orig-radio" value="comfortable" checked>
                        <span class="el-radio-button__inner overflow-space" style="max-width: 84px;">{'comfortable'|@getFixedLabel}</span>
                    </label>
                    <label role="radio" class="el-radio-button el-radio-button--mini">
                        <input name="listpageheight" type="radio" class="el-radio-button__orig-radio" value="spacious">
                        <span class="el-radio-button__inner overflow-space" style="max-width: 84px;">{'spacious'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
        </div>
        {*//@edit:ljj,2023-08-09,reason: XUQIU1001644 单据序时簿列表界面，快速设置弹出层中增加“设置模块超链接字段”区块*}
        <div class="DivCName DivCNamehover" data-blocktype="entity">
            <label class="cursorPointer" style="display:inline-block;">
                <span></span>{'SetModuleHyperlinkFields'|@getFixedLabel}
            </label>
        </div>
        <div class="ld-listview-right-setting-entity" id="ld-listview-right-setting-entity">
                <div class="ld_combobox-components" style="padding: 10px 20px;overflow: hidden">
                    <select name="entitiy-select" fieldtype="selectentityname" style="width: 100%" >
                        <option value="" ></option>
                        {foreach key=number item=assmablys from=$entitylist}
                            <option value="{$number}" {if $assmablys[1] eq 'selected'}selected{/if}>{$assmablys[0]}</option>
                        {/foreach}
                    </select>
                </div>
        </div>

        {*gxj 230714 BUG0069551 kfbcrm-列表操作按钮设置-区块应默认隐藏*}
        <div class="DivCName DivCNamehover ld-shadow-first" data-blocktype="pagesetting">
            <label class="cursorPointer" style="display:inline-block;">
                <span class="On" id="" name=""></span>{'Listtool'|@getFixedLabel}
            </label>
        </div>
        <div id="ld-listview-right-setting-pagesetting" style="display: none">
            <div class="first-drawer-content-item ld-listview-right-setting-btnsetting" style="margin: 0px;padding:0px 16px">
                <label class="drawer-content-item-title">{'CUSTOMIZESEARCH'|@getFixedLabel}</label>
                <input type="checkbox" class="second_switch" name="Highersearch" {if $HIGBTNSTATUS eq 'yes'}checked{/if} style="float:left;margin: 10px;"/>

            </div>

{*            //@edit:ljj,2023-08-10,reason:XUQIU1001663 单据序时簿列表界面，“操作按钮设置”区块，高级查找下方增加“平铺查找”开启、关闭参数*}
{*            <div class="first-drawer-content-item ld-listview-right-setting-btnsetting" style="margin: 0px;padding: 0 16px;">*}
{*                <label class="drawer-content-item-title">{'TILEDSEARCH'|@getFixedLabel}</label>*}
{*                    <input type="checkbox" class="second_switch" name="Tiledsearch" {if $TILEDBTNSTATUS eq 'yes'}checked{/if} style="float:left;margin: 10px;"/>*}
{*            </div>*}
            {*wym BUG0076164 客户管理--将标签查找也纳入可设置隐藏*}
            {*wym BUG0077371 工作汇报（列表）-没有页面设置 没有标签功能，应不显示该操作按钮 数组是从ModuleManager.php中复制过来的*}
            {*wym BUG0078305 成员管理-页面设置 没有标签区块，在列表设置中应不显示该操作按钮*}
            {if !in_array($moudlename,array('BankAccountSet','Tooltip','ModTracker','lingdangBackup','Emails','OftenUseReport','SocialPromotion','WorkReportList','Users'))}
            <div class="first-drawer-content-item ld-listview-right-setting-btnsetting" style="margin: 0px;padding: 0 16px;">
                <label class="drawer-content-item-title">{'Tag'|@getFixedLabel}{'SEARCH'|@getFixedLabel}</label>
                <input type="checkbox" class="second_switch" name="Tagsearch" {if $TAGBTNSTATUS eq 'yes'}checked{/if} style="float:left;margin: 10px;"/>
            </div>
            {/if}
            {*wym BUG0076167 客户管理--地图和漏斗加入设置，可设置显示或隐藏*}
            {if $moudlename eq 'Accounts'}
            <div class="first-drawer-content-item ld-listview-right-setting-btnsetting" style="margin: 0px;padding: 0 16px;">
                <label class="drawer-content-item-title">{'MAP'|@getFixedLabel}</label>
                <input type="checkbox" class="second_switch" name="Mapsearch" {if $MAPBTNSTATUS eq 'yes'}checked{/if} style="float:left;margin: 10px;"/>
            </div>
            {/if}
            {if $chartsearch_display eq 'yes'}
                <div class="first-drawer-content-item ld-listview-right-setting-btnsetting" style="margin: 0px;padding: 0 16px;">
                    <label class="drawer-content-item-title">{'CURQUERYCHART'|@getFixedLabel}</label>
                    <input type="checkbox" class="second_switch" name="Chartsearch" {if $CHARTBTNSTATUS eq 'yes'}checked{/if} style="float:left;margin: 10px;"/>
                </div>
            {/if}
        </div>
        <div class="DivCName DivCNamehover ld-shadow-first" data-blocktype="btnsettingself">
            <label class="cursorPointer" style="display:inline-block;">
                <span class="On" id="" name=""></span>{'Generalbuttonsorting'|@getFixedLabel}
            </label>
        </div>
        <div id="ld-listview-right-setting-btnsettingself" style="display: none">
            <div class="first-drawer-content-item ld-listview-right-setting-btnsetting"  style="margin: 0px;padding: 16px;">
                <p class="sort-tip-items" data-tip="{'OPERATIONBUTTONNUM'|@getFixedLabel}" data-direction="top" data-type="position">{'OPERATIONBUTTONNUM'|@getFixedLabel}</p>
                <div class="settingTable fir-center">
                    <div class="inputnumbox btn-radius-system"  id="inputnumbox btn-radius-system-btnsetting" style="width:90px;">
                        <a id="dwbtn" >-</a><input type="text" id="" name="shownum" maxlength="1" value="{$SHOWNUM}"><a id="upbtn" >+</a>
                    </div>
                </div>
            </div>
            <div class="ld-listview-right-setting-btnsetting" >
                <div class="ld-listview-right-setting-field" id="ld-listview-right-setting-btn-self">
                    <ul>
                        {foreach key=btnkey item=btnlabel from=$LISTBTNSELFARR}
                            <li data-value="{$btnkey}" class="drag-handle">
                                <p class="sort-tip-items" data-tip="{$btnlabel.label}" data-direction="top" data-type="position">{$btnlabel.label}</p>
                                <div class="ld-listview-right-setting-field_set">
                                    <i class="ld-field_set-top sort-tip-items" data-tip="{'Topping'|@getFixedLabel}"  data-direction="left" data-type="position"></i>
                                    <i class="ld-field_set-drog sort-tip-items" data-tip="{'drag'|@getFixedLabel}"  data-direction="left" data-type="position"></i>
                                </div>
                            </li>
                        {/foreach}
                    </ul>
                </div>
            </div>
        </div>
        <div class="DivCName DivCNamehover ld-shadow-first" data-blocktype="btnsettingrely">
            <label class="cursorPointer" style="display:inline-block;">
                <span class="On" id="" name=""></span>{'Batchoperationbuttonsorting'|@getFixedLabel}
            </label>
        </div>
        <div id="ld-listview-right-setting-btnsettingrely" style="display: none">
            <div class="ld-listview-right-setting-btnsetting" >
                <div class="ld-listview-right-setting-field" id="ld-listview-right-setting-btn-rely">
                    <ul>
                        {foreach key=btnkey item=btnlabel from=$LISTBTNRELYARR}
                            <li data-value="{$btnkey}" class="drag-handle">
                                <p class="sort-tip-items" data-tip="{$btnlabel.label}" data-direction="top" data-type="position">{$btnlabel.label}</p>
                                <div class="ld-listview-right-setting-field_set">
                                    <i class="ld-field_set-top sort-tip-items" data-tip="{'Topping'|@getFixedLabel}"  data-direction="left" data-type="position"></i>
                                    <i class="ld-field_set-drog sort-tip-items" data-tip="{'drag'|@getFixedLabel}"  data-direction="left" data-type="position"></i>
                                </div>
                            </li>
                        {/foreach}
                    </ul>
                </div>
            </div>
        </div>
        <div class="DivCName DivCNamehover ld-shadow-first" data-blocktype="actionlink">
            <label class="cursorPointer" style="display:inline-block;">
                <span class="On" id="" name=""></span>{'Actionlinksetting'|@getFixedLabel}
            </label>
        </div>
        <div class="ld-listview-right-setting-field" id="ld-listview-right-setting-actionlink" style="display: none">
            <ul>
                {foreach key=number item=assmablys from=$HAVEACTIONLINK name=pname}
                    <li data-fieldtable="{$assmablys}" class="ld-category-draggable">
                        <input type="checkbox" class="second_switch" checked data-value="{$number}" style="float:left;margin: 10px;"/>
                        <p class="sort-tip-items" data-tip="{$assmablys}" data-direction="top" data-type="position">{$assmablys}</p>
                        <div class="ld-listview-right-setting-field_set">
                            <i class="ld-field_set-top sort-tip-items" data-tip="{'Topping'|@getFixedLabel}" data-direction="top" data-type="position"></i>
                            <i class="ld-field_set-drog sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"  data-direction="left" data-type="position" style="cursor: move;" ></i>
                        </div>
                    </li>
                {/foreach}

                {foreach key=number item=assmablys from=$ACTIONLINK name=pname}
                    <li data-fieldtable="{$assmablys}">
                        <input type="checkbox" class="second_switch" data-value="{$number}" style="float:left;margin: 10px;"/>
                        <p class="sort-tip-items" data-tip="{$assmablys}" data-direction="top" data-type="position">{$assmablys}</p>
                        <div class="ld-listview-right-setting-field_set">
                            <i class="ld-field_set-top sort-tip-items" data-tip="{'Topping'|@getFixedLabel}" data-direction="top" data-type="position"></i>
                            <i class="ld-field_set-drog sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"  data-direction="left" data-type="position" style="display: none;"></i>
                        </div>
                    </li>
                {/foreach}
            </ul>
        </div>
    {/if}
    <div class="DivCName DivCNamehover" data-blocktype="field">
        <label class="cursorPointer" style="display:inline-block;">
            <span class="" id="aid102" name="aid102"></span>{'ACTIVITYFIELDSETTINGS'|@getFixedLabel}
        </label>
    </div>
    {if $edit_permit == 'yes'}
        <div class="ld-listview-right-setting-field" id="ld-listview-right-setting-field">
            <div class="ld_search_option">
                <div class="ld_search-components">
                    <input type="text" class="ld-input-inner ld-input-inner-add" id="search_field" placeholder="{'SEARCHNEW'|@getFixedLabel}{' '|@getFixedLabel}{'FIELDS'|@getFixedLabel}" value="" style="padding: 0 30px !important;">
                    <b class="ld-icon-search" style="left: 0;"></b>
                </div>
            </div>
            <ul>
                {foreach key=number item=assmablys from=$HAVEPRODUCTLISTVIEWALL name=pname}
                    <li data-fieldtable="{$assmablys}" class="ld-category-draggable">
                        <input type="checkbox" class="second_switch" checked data-value="{$number}" checked_value="yes" style="float:left;margin: 10px;"/>
                        <p class="sort-tip-items" data-tip="{$assmablys}" data-direction="top" data-type="position">{$assmablys}</p>
                        <div class="ld-listview-right-setting-field_set">
                            <i class="ld-field_set-top sort-tip-items" data-tip="{'Topping'|@getFixedLabel}" data-direction="top" data-type="position"></i>
                            <i class="ld-field_set-drog sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"  data-direction="left" data-type="position" style="cursor: move;" ></i>
                        </div>
                    </li>
                {/foreach}
                {*gxj 230713 BUG0069439 kfbcrm-客户管理-列表设置-开启一个字段后，点击拖动字段顺序，没反应*}
                {foreach key=number item=assmablys from=$PRODUCTLISTVIEWALL name=pname}
                    <li data-fieldtable="{$assmablys}">
                        <input type="checkbox" class="second_switch" data-value="{$number}" checked_value="no" style="float:left;margin: 10px;"/>
                        <p class="sort-tip-items" data-tip="{$assmablys}" data-direction="top" data-type="position">{$assmablys}</p>
                        <div class="ld-listview-right-setting-field_set">
                            <i class="ld-field_set-top sort-tip-items" data-tip="{'Topping'|@getFixedLabel}" data-direction="top" data-type="position"></i>
                            <i class="ld-field_set-drog sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"  data-direction="left" data-type="position" style="display: none;"></i>
                        </div>
                    </li>
                {/foreach}
            </ul>
        </div>
    {else}
        <div style="height: 50px;line-height: 50px;text-align: center;color: #777;" id="ld-listview-right-setting-field">
        {'NONE'|@getFixedLabel}{'managecustomview'|@getFixedLabel}{'LBL_PROFILES'|@getFixedLabel}
        </div>
    {/if}
</div>
<div class="ld-listview-right-setting-bottombtn" id="ld-listview-right-setting-bottombtn">
    <div style="margin: 9px auto;">
        <input type="button" id="ld-listview-right-setting-application" class="ld-button ld-button-primary" value="{'SAVE'|@getFixedLabel}"/>
        <input type="button" id="ld-listview-right-setting-resetting" class="ld-button" value="{'RESETTING'|@getFixedLabel}"/>
    </div>
</div>

<script>
    {literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});
    //txy BUG0069081 kfbcrm英文版-列表界面-表格设置-组件错位 加浮现
    tooltip('.el-radio-button__inner', {transition: true, time: 200});
    {/literal}
</script>