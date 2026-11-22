{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/AutomaticReminds.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Approve/Approve.js?v={$GLOBALMINVERSION}"></script>

<script>
/*
var fLabels = new Array();

fLabels['e'] = '{'EQ'|@getFixedLabel}';
fLabels['n'] = '{'NEQ'|@getFixedLabel}';
fLabels['c'] = '{'IN'|@getFixedLabel}';
fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
fLabels['l'] = '{'LT'|@getFixedLabel}';
fLabels['g'] = '{'GT'|@getFixedLabel}';
fLabels['m'] = '{'LE'|@getFixedLabel}';;
fLabels['h'] = '{'GE'|@getFixedLabel}';
fLabels['bw'] = '{'Interval'|@getFixedLabel}';
fLabels['b'] = '{'Before'|@getFixedLabel}';
fLabels['a'] = '{'After'|@getFixedLabel}';
fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
var tmpstr='{$DATETIMESTR}';

 var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
*/
</script>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_AUTOMATICREMINDS_SET'|@getFixedLabel}{if $HelpHtml.AutomaticReminds neq '' }{$HelpHtml.AutomaticReminds}{/if}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" style="display:none;" id="reminds_module" name="reminds_module" class="btn-radius-system width150" onchange="getRemindsModule(this,'{$BLOCKIDSETTING}','{$FIELDIDSETTING}');">
            {foreach item=tab from=$TAB}
                {if $tab.tabid eq $BLOCKID}
                    <option value="{$tab.tabid}" selected>{$tab.tabname}</option>
                {else}
                    <option value="{$tab.tabid}">{$tab.tabname}</option>
                {/if}                
            {/foreach}
        </select>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="AutomaticReminds.createRemindsRule(0,'{$BLOCKID}')" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" class="cont_wrap clear_float" name="automaticremindslists">
            {include file="AutomaticReminds/AutomaticRemindsLists.tpl"}
        </div>
    </div>
</div>
</form>
<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
<script>
    //拖拽排序 weiyannan 20231121 XUQIU1002038 后台设置列表界面可以做排序（仿照单据分录定制那样，可以通过拖拽排序）后台设置--参数设置-自动提醒设置
    function autoRemindMovetable(){
        ld('[name=autoRemindSetTable] tr').hover(function(){
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });
        var dragobj = ld("table[name=autoRemindSetTable]").find("tbody").get(0);
        Sortable.create(dragobj, {
            draggable: ".ld-category-draggable",
            handle: ".drag-handle",
            onEnd: function (evt){
                var sortfield_arr='';
                var fieldid = '';
                var tabid='';
                tableobj = ld('table[name=autoRemindSetTable]').find("tr");
                tableobj.attr('onmouseover','');
                tableobj.attr('onmouseout','');
                tableobj.removeClass('lvtColData');
                tableobj.removeClass('lvtColDataBj');
                tableobj.removeClass('lvtColDataHover');
                ld.each(tableobj,function(index,tmpobj){
                    console.log(tmpobj)
                    if(index>0){
                        if(index%2==0){
                            ld(tmpobj).addClass('lvtColDataBj');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                            ld(tmpobj.childNodes[1]).html(index);
                            fieldid=ld(tmpobj).attr('tagid');
                            tabid=ld(tmpobj).attr('tabid');
                            sortfield_arr+=fieldid+",";
                        }else{
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[1]).html(index);
                            fieldid=ld(tmpobj).attr('tagid');
                            tabid=ld(tmpobj).attr('tabid');
                            sortfield_arr+=fieldid+",";
                        }
                    }
                });
                if (sortfield_arr != '') {
                    var update_url = 'index.php?module=Settings&action=SettingsAjax&file=AutomaticReminds&type=saveAutoRemindTableSort&ajax=true&tagids=' + sortfield_arr + '&tabid=' + tabid;
                    ldAjax(update_url, '', function (data) {
                        if (data.code == 1) {
                            DelProgressObjs();
                        }
                    })
                }
            }
        })
    }
    autoRemindMovetable();
</script>