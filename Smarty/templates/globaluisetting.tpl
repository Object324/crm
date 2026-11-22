<style>
    .ld_uisetting_list{
        padding-left:20px;
        margin-top:32px;
    }
    .ld_uisetting_list_fst{
        margin-top: initial;
    }
    .ld_uitype_title{
        display: flex;
        align-items: center;
    }
    .ld_uitype_title_name{
        font-weight: 500;
        height:16px;
        font-size: 16px;
        color: #3B4854;
        line-height: 16px;
        text-align: left;
        font-style: normal;
        margin-left:4px;
    }
    .ld_uitype_title_colomn{
        width: 4px;
        height: 16px;
        background: #3B7CFF;
        border-radius: 2px;
    }
    .ld_uitype_subtitle{
        margin-top:8px;
    }
    .ld_uitype_description{
        font-weight: 400;
        font-size: 14px;
        color: #666666;
        line-height: 20px;
        text-align: left;
        font-style: normal;
    }
    .ld_uitype_list{
        width: 100%;
        display: flex;
        margin-top:16px;
    }
    .ld_uitype_list_item{
        padding-right: 32px;
    }
    .ld_uitype_list_item_img{
        width: 100%;
        border-radius: 8px;
        border: 1px solid #DCDEE0;
        overflow: hidden;
        position: relative;
        cursor: pointer;
    }
    .ld_uitype_list_item:hover .ld_uitype_list_item_img{
        box-shadow: 0px 2px 24px 0px rgba(200,201,204,0.5);
    }
    .uiselect.ld_uitype_list_item_img{
        border: 1px solid #3B7CFF;
    }
    .ld_leftmenu_ui_setting .ld_uitype_list_item_img img{
        width:158px
    }
    .ld_listview_top_ui_setting .ld_uitype_list_item_img img{
        width:216px
    }
    .ld_listview_tabel_ui_setting .ld_uitype_list_item_img img{
        width:160px
    }
    .ld_detailview_detail_ui_setting .ld_uitype_list_item_img img{
        width:160px
    }
    .ld_uitype_list_item_descdription{
        margin-top:8px;
    }
    .ld_uitype_list_item_descdription label{
        cursor: pointer;
        display: inline-flex;
        align-items: center;
    }
    .ld_uitype_list_item_descdription label span{
        font-weight: 400;
        font-size: 14px;
        color: #323233;
        line-height: 14px;
        text-align: left;
        font-style: normal;
        height:14px;
        white-space: normal;
        overflow-wrap: break-word;
    }
    .ld_uitype_list_item_descdription input{
        margin-right: 10px;
        vertical-align: initial;
    }
    .main_grid_box{
        cursor:default;
        padding-bottom: 20px;
    }

</style>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">{'ld_global_ui_setting'|@getFixedLabel}</span>
    </div>
</div>
<div class="main_grid_box" name="leftmenuuitype" style="overflow: auto;">
    {*网页菜单交互定制*}
    <div class="ld_uisetting_list ld_uisetting_list_fst ld_leftmenu_ui_setting" name="ld_leftmenu_ui_setting">
        <div class="ld_uitype_title">
            <div class="ld_uitype_title_colomn"></div>
            <span class="ld_uitype_title_name">{'ld_leftmenu_ui_setting'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_subtitle">
            <span class="ld_uitype_description">{'ld_leftmenu_uisetting_tips'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_list">
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $menutype eq 2}uiselect{/if}"  data-type="2">
                    <img src="{$IMAGEURL}themes/images/leftmenu_ui_1.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $menutype eq 2}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_leftmenu_ui_setting" {if $menutype eq 2} checked {/if}>
                        <span>{'dropdown_menu'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $menutype eq 1}uiselect{/if}" data-type="1">
                    <img src="{$IMAGEURL}themes/images/leftmenu_ui_2.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $menutype eq 1}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_leftmenu_ui_setting" {if $menutype eq 1} checked {/if}>
                        <span>{'hoverselect_menu'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
        </div>
    </div>
    {*列表页-筛选区域样式*}
    <div class="ld_uisetting_list ld_listview_top_ui_setting" name="ld_listview_top_ui_setting">
        <div class="ld_uitype_title">
            <div class="ld_uitype_title_colomn"></div>
            <span class="ld_uitype_title_name">{'ld_listview_top_ui_setting'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_subtitle">
            <span class="ld_uitype_description">{'ld_listviewtop_uisetting_tips'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_list">
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $listviewtype eq 1}uiselect{/if}"  data-type="1">
                    <img src="{$IMAGEURL}themes/images/listviewtop_ui_1.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $listviewtype eq 1}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_listview_top_ui_setting" {if $listviewtype eq 1} checked {/if}>
                        <span>{'searchleftbuttonright'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $listviewtype eq 2}uiselect{/if}" data-type="2">
                    <img src="{$IMAGEURL}themes/images/listviewtop_ui_2.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $listviewtype eq 2}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_listview_top_ui_setting" {if $listviewtype eq 2} checked {/if}>
                        <span>{'searchbuttonleft'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $listviewtype eq 3}uiselect{/if}" data-type="3">
                    <img src="{$IMAGEURL}themes/images/listviewtop_ui_3.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $listviewtype eq 3}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_listview_top_ui_setting" {if $listviewtype eq 3} checked {/if}>
                        <span>{'searchrightbuttonleft'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
        </div>
    </div>
    {*列表页-表格显示样式*}
    <div class="ld_uisetting_list ld_listview_tabel_ui_setting" name="ld_listview_tabel_ui_setting">
        <div class="ld_uitype_title">
            <div class="ld_uitype_title_colomn"></div>
            <span class="ld_uitype_title_name">{'ld_listview_tabel_ui_setting'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_subtitle">
            <span class="ld_uitype_description">{'ld_listviewtable_uisetting_tips'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_list">
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $listviewtabletype eq 1}uiselect{/if}"  data-type="1">
                    <img src="{$IMAGEURL}themes/images/listviewtabel_ui_1.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $listviewtabletype eq 1}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_listview_tabel_ui_setting" {if $listviewtabletype eq 1} checked {/if}>
                        <span>{'splitline'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $listviewtabletype eq 2}uiselect{/if}" data-type="2">
                    <img src="{$IMAGEURL}themes/images/listviewtabel_ui_2.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $listviewtabletype eq 2}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_listview_tabel_ui_setting" {if $listviewtabletype eq 2} checked {/if}>
                        <span>{'splitcolor'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $listviewtabletype eq 3}uiselect{/if}" data-type="3">
                    <img src="{$IMAGEURL}themes/images/listviewtabel_ui_3.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $listviewtabletype eq 3}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_listview_tabel_ui_setting" {if $listviewtabletype eq 3} checked {/if}>
                        <span style="max-width:120px;">{'splitcolorandline'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
        </div>
    </div>
    {*详情页-详细信息中字段排列样式*}
    <div class="ld_uisetting_list ld_detailview_detail_ui_setting" name="ld_detailview_detail_ui_setting">
        <div class="ld_uitype_title">
            <div class="ld_uitype_title_colomn"></div>
            <span class="ld_uitype_title_name">{'ld_detailview_detail_ui_setting'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_subtitle">
            <span class="ld_uitype_description">{'ld_detailview_uisetting_tips'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_list">
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $detailviewtype eq 1}uiselect{/if}"  data-type="1">
                    <img src="{$IMAGEURL}themes/images/detailviewl_ui_1.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $detailviewtype eq 1}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_detailview_detail_ui_setting" {if $detailviewtype eq 1} checked {/if}>
                        <span>{'detailsplitline'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $detailviewtype eq 2}uiselect{/if}" data-type="2">
                    <img src="{$IMAGEURL}themes/images/detailviewl_ui_2.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $detailviewtype eq 2}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_detailview_detail_ui_setting" {if $detailviewtype eq 2} checked {/if}>
                        <span>{'detailsplitcolor'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
        </div>
    </div>
    {*弹出层-按钮位置*}
    <div class="ld_uisetting_list ld_detailview_detail_ui_setting" name="ld_popup_button_ui_setting">
        <div class="ld_uitype_title">
            <div class="ld_uitype_title_colomn"></div>
            <span class="ld_uitype_title_name">{'ld_popup_button_ui_setting'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_subtitle">
            <span class="ld_uitype_description">{'allpopupbottontypelabel'|@getFixedLabel}</span>
        </div>
        <div class="ld_uitype_list">
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $popupbuttontype eq 1}uiselect{/if}"  data-type="1">
                    <img src="{$IMAGEURL}themes/images/popupbotton_ui_1.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $popupbuttontype eq 1}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_popup_button_ui_setting" {if $popupbuttontype eq 1} checked {/if}>
                        <span>{'popupbuttonright'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
            <div class="ld_uitype_list_item">
                <div class="ld_uitype_list_item_img {if $popupbuttontype eq 2}uiselect{/if}" data-type="2">
                    <img src="{$IMAGEURL}themes/images/popupbotton_ui_2.png?v={$GLOBALMINVERSION}"/>
                    <span class="bingo" {if $popupbuttontype eq 2}style="display: block;" {/if}><i class="bingocheck"></i></span>
                </div>
                <div class="ld_uitype_list_item_descdription">
                    <label>
                        <input type="radio" name="ld_popup_button_ui_setting" {if $popupbuttontype eq 2} checked {/if}>
                        <span>{'popupbuttoncenter'|@getFixedLabel}</span>
                    </label>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    {literal}
    ld('.ld_uisetting_list').each(function(){
        var that=this;
        ld(that).find('.ld_uitype_list_item_img').unbind('click').bind('click',function(){
            saveuitype(that,this);
        })
        ld(that).find('.ld_uitype_list_item input[type="radio"]').unbind('click').bind('click',function() {
            if(ld(this).is(':checked')){
                ld(this).parents('.ld_uitype_list_item').find('.ld_uitype_list_item_img').trigger('click');
            }else{
                //阻止主动取消勾选
                ld(this).prop('checked',true)
            }
        });
    })
    function saveuitype(that,clickedElement){
        var uitype = ld(clickedElement).data('type');
        if(ld(clickedElement).hasClass('uiselect')){
        }else{
            ld(that).find('.ld_uitype_list .ld_uitype_list_item_img').removeClass('uiselect');
            ld(that).find('span.bingo').hide();
            ld(that).find('input[type=radio]:checked').prop('checked', false);
            ld(clickedElement).addClass('uiselect');
            ld(clickedElement).find('span.bingo').show();
            ld(clickedElement).siblings('.ld_uitype_list_item_descdription').find('input[type=radio]').prop('checked', true);
            var surl = 'index.php?module=Settings&action=SettingsAjax&file=globaluisetting&mode=save&uisetting='+ld(that).attr('name')+'&uitype='+uitype;
            ldAjaxNoProgress(surl,'',function () {
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
            });
        }
    }
    {/literal}
</script>