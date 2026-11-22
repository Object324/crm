<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script>
{*<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">*}
    <div class="main_grid_top">
        <span class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                首页专题设置<font>（每个专题仅可选择20条产品）</font>
            </span>
            <span class="grid-view-choose dinline-block lfloat">选择专题</span>
            <select fieldtype="select" id="pick_topic" name="pick_topic" class="btn-radius-system width150" onchange="ShopSettingsobj.getTopicProductLists(this);" style="display:none;">
                {foreach item=TopicList from=$TopicLists}
                    <option value="{$TopicList.topicid}" {if $TopicList.topicid eq $TOPICID}selected{/if}>{$TopicList.topic_name}</option>
                {/foreach}
            </select>
            <span class="rfloat" style="margin-top: 19px;">
                <a href="javascript:;" title="设置" onclick="ShopSettingsobj.topicSet()"><b class="ld-icon-set"></b></a>
            </span>
        </span>
        <div class="grid_tool">
            <div class="create-entity-toolbar lfloat prelative">
                <a class="ld-button ld-button-primary" title="选择产品" href="javascript:void(0);"
                   onclick="CrmPopupWindow('ShopSettings','module=Products&action=ProductsAjax&file=AddProductsToTopic&popup=yes&page_popup=yes','Products');">
                    <span>选择产品</span>
                </a>
                <a class="ld-button ld-button-cancel" title="取消产品" href="javascript:void(0);" onclick="ShopSettingsobj.deleteTopicProductRel()">
                    <span>取消产品</span>
                </a>
            </div>
        </div>
    </div>
{*
    <div class="DivC">
        <div class="Top">
            <table class="bgwhite" width="100%" border="0" cellspacing="0" cellpadding="0" style="100%">
                <tbody>
                <tr>
                    <td class="DivCL b" style="width: 70%;">
                        <ul class="D_btn_box b">
                            <li class="D_anu_a">
                                <a title="选择产品" href="javascript:void(0);"
                                   onclick="CrmPopupWindow('ShopSettings','module=Products&action=ProductsAjax&file=AddProductsToTopic&popup=yes&page_popup=yes','Products');">
                                    <span>选择产品</span>
                                </a>
                            </li>
                            <li class="D_anu_a" style="float: left;">
                                <a title="取消产品" href="javascript:void(0);" onclick="ShopSettingsobj.deleteTopicProductRel()">
                                    <span>取消产品</span>
                                </a>
                            </li>
                            <li class="D_anu_a">
                                <input type="text" fieldlabel="产品编号" name="searchvalue" placeholder="请输入产品名称按回车进行查询"
                                        value="" size="30px" style="border-radius:4px;border:1px solid #C5C5C5;height:25px"
                                        onkeypress="fun_ProductTopic.getInstance().searchrelateproducts(event)" />
                            </li>
                        </ul>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
*}
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float" name="multitopiclist">
                {include file="modules/ShopSettings/MultiTopicLists.tpl"}
            </div>
        </div>
    </div>
{*</form>*}

