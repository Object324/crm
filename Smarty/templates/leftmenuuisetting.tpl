<style>
    .ld_menu_uitype_list{
        width: 100%;padding-right: 16px;display: flex;
    }
    .ld_menu_uitype_list_item{
        flex: 1;padding-left: 16px;
    }
    .ld_menu_uitype_list_item_img{
        height: 100%;width: 100%;
        border-radius: 8px;
        border: 1px solid #DCDEE0;
        overflow: hidden;
        position: relative;
        cursor: pointer;
    }
    .ld_menu_uitype_list_item:hover .ld_menu_uitype_list_item_img{
        box-shadow: 0px 2px 24px 0px rgba(200,201,204,0.5);
    }
    .menuuiselect.ld_menu_uitype_list_item_img{
        border: 1px solid #3B7CFF;
    }
    .ld_menu_uitype_list_item img{
        height: 100%;width: 100%;
    }
</style>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">{'ld_leftmenu_ui_setting'|@getFixedLabel}</span>
    </div>
</div>
<div class="main_grid_box" name="leftmenuuitype" style="overflow: auto;margin-top: 20px;">
    <div class="ld_menu_uitype_list">
        <div class="ld_menu_uitype_list_item">
            <div class="ld_menu_uitype_list_item_img {if $menutype eq 1}menuuiselect{/if}"  data-type="1">
                <img src="{$IMAGEURL}themes/images/leftmenu_ui_old.png?v={$GLOBALMINVERSION}"/>
                <span class="bingo" {if $menutype eq 1}style="display: block;" {/if}><i class="bingocheck"></i></span>
            </div>
        </div>
        <div class="ld_menu_uitype_list_item">
            <div class="ld_menu_uitype_list_item_img {if $menutype eq 2}menuuiselect{/if}" data-type="2">
                <img src="{$IMAGEURL}themes/images/leftmenu_ui_dropdown.png?v={$GLOBALMINVERSION}"/>
                <span class="bingo" {if $menutype eq 2}style="display: block;" {/if}><i class="bingocheck"></i></span>
            </div>
        </div>
    </div>
</div>

<script>
    ld('.ld_menu_uitype_list').find('.ld_menu_uitype_list_item_img').unbind('click').bind('click',function(){
        var menutype = ld(this).data('type');
        if(ld(this).hasClass('menuuiselect')){

        }else{
            ld('.main_grid_box[name=leftmenuuitype]').find('.ld_menu_uitype_list .ld_menu_uitype_list_item_img').removeClass('menuuiselect');
            ld('.main_grid_box[name=leftmenuuitype]').find('span.bingo').hide();
            ld(this).addClass('menuuiselect');
            ld(this).find('span.bingo').show();
            var surl = 'index.php?module=Settings&action=SettingsAjax&file=leftmenuuisetting&mode=save&menutype='+menutype;
            ldAjaxNoProgress(surl,'',function () {
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
                //LeftMenu_functionobj=LeftMenu_function.getInstance();
                //LeftMenu_functionobj.LeftMenu_flesh();//加载左边的菜单
            });
        }

    });
</script>