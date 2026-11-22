<style>
    .setting_listviewtopui{
        width: 100%;
    }
    .setting_listviewtopui .setting_listviewtopui_img{
        margin: 50px 50px;
        position: relative;
        width: 100%;
        min-width: 650px;
        max-width: 900px;
        cursor: pointer;
    }
    .setting_listviewtopui .setting_listviewtopui_img img{
        width: 100%;
    }
    .listviewtype_active{
        box-shadow: 1px 2px 10px 6px rgba(56, 92, 141, 0.2);
    }

</style>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">{'ld_listviewview_topui_setting'|@getFixedLabel}</span>
    </div>
</div>
<div class="main_grid_box" name="listviewtopuitype" style="overflow: auto;">
    <div class="setting_listviewtopui">
        <div class="setting_listviewtopui_img" data-type="1">
            <img {if $listviewtype eq 1}class="listviewtype_active"{/if} src="{$IMAGEURL}themes/images/listviewtype1.png?v={$GLOBALMINVERSION}"/>
            <span class="bingo" {if $listviewtype eq 1}style="display: block;" {/if}><i class="bingocheck"></i></span>
        </div>
    </div>
    <div class="setting_listviewtopui">
        <div class="setting_listviewtopui_img" data-type="2">
            <img {if $listviewtype eq 2}class="listviewtype_active"{/if} src="{$IMAGEURL}themes/images/listviewtype2.png?v={$GLOBALMINVERSION}"/>
            <span class="bingo" {if $listviewtype eq 2}style="display: block;" {/if}><i class="bingocheck"></i></span>
        </div>
    </div>
    <div class="setting_listviewtopui">
        <div class="setting_listviewtopui_img" data-type="3">
            <img {if $listviewtype eq 3}class="listviewtype_active"{/if} src="{$IMAGEURL}themes/images/listviewtype3.png?v={$GLOBALMINVERSION}"/>
            <span class="bingo" {if $listviewtype eq 3}style="display: block;" {/if}><i class="bingocheck"></i></span>
        </div>
    </div>
</div>
<script>
    ld('.setting_listviewtopui_img').unbind('click').bind('click',function(){
        var listview_type = ld(this).data('type');
        if(ld(this).find('img.listviewtype_active').length > 0){

        }else{
            ld('.main_grid_box[name=listviewtopuitype]').find('img.listviewtype_active').removeClass('listviewtype_active');
            ld('.main_grid_box[name=listviewtopuitype]').find('span.bingo').hide();
            ld(this).find('img').addClass('listviewtype_active');
            ld(this).find('span.bingo').show();
            var surl = 'index.php?module=Settings&action=SettingsAjax&file=listviewtopuisetting&mode=save&listviewtype='+listview_type;
            ldAjaxNoProgress(surl,'',function (data) {
                if (data.code == 1){
                    MessagePopup.TipZero_success(data.msg);
                }
            });
        }

    });
</script>