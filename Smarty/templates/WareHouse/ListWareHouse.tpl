<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" value="Settings" name="module"/>
<input type="hidden" value="EditWareHouse" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_WASEHOUSE'|@getFixedLabel}<font>（{'LBL_WASEHOUSE_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" title="{'CREATE'|@getFixedLabel}" onclick="EditWareHouse('')">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <table class="settingTable fir-center" width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <th>#</th>
                <th align="left" width="150" title="{'WAREHOUSENAME'|@getFixedLabel}">{'WAREHOUSENAME'|@getFixedLabel}</th>
                <th align="left" title="{'WAREHOUSEADMIN'|@getFixedLabel}">{'WAREHOUSEADMIN'|@getFixedLabel}</th>
                <th width="{if $LANGUAGETYPE eq 'en'}130{else}100{/if}" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
                {if $LANGUAGETYPE eq 'en'}
                <th width="121">{'OPERATING'|@getFixedLabel}</th>
                {else}
                <th width="101">{'OPERATING'|@getFixedLabel}</th>
                {/if}
            </tr>
            {assign var="i" value=0}
            {foreach key=index item=values from=$WAREHOUSES}
                {assign var="j" value=$i++}
                {if $j mod 2 eq '0'}
                    <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                {else}
                    <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                {/if} 
                {foreach item=value from=$values.k}
                <td>{$values.k}</td>
                <td><span title="{$values.name}">{$values.name}</span></td>
                <td><span title="{$values.last_name}">{$values.last_name}</span></td>
                <input type="hidden" name="id" value="{$values.id}"/>
                <td>
                    {if $values.status eq 0}
                        <input type="checkbox" onclick="warehouse_active_checked(this,'{$values.name}',{$values.id});" class="second_switch" checked="" />
                    {else}
                        <input type="checkbox" onclick="warehouse_active_checked(this,'{$values.name}',{$values.id});" class="second_switch" />
                    {/if}
                </td>
               <td align="left">
                {if $values.status eq 0}
                    <a class="Anu3_a" href="javascript:void(0)" onclick="EditWareHouse({$values.id})">
                        {'EDIT'|@getFixedLabel}
                    </a>
					<a class="Anu3_a" href="javascript:void(0);" title="{'ALLOCATE'|@getFixedLabel} {'APPLICABLESCOPE'|@getFixedLabel}" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,0,'{$values.id}','{$values.userids}','{$values.allocatetype}','ListWareHouse');">{'ALLOCATE'|@getFixedLabel}</a>
                {/if} 
                </td>
                {/foreach}
              </tr>
            {/foreach}                  
            </table>
        </div>
    </div>
</div>
</form>

<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
<script>
{literal}
function forbiddenwarehouse(obj,warehousename,record){
    var confirm_str = arrJsPopLabel['SUREDISABLEWAREHOUSE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        ld(obj).prop('checked',false);
        new Ajax.Request("index.php",
        {
            queue:{
                position:"end",
                scope:"command"
            },
            method:"post",
            postBody:"module=Settings&action=SettingsAjax&file=IsOrNotStartWareHouse&status=forbidden&record="+record,
            onComplete:function (response) {
              if(response.responseText.indexOf('Used')>-1){
                ld(obj).prop('checked',true);
                var str = warehousename+arrJsPopLabel['PRODUCTSEXISTSEMPTYWAREHOUSE'];
                RemindsMsg("","LdPopWidth400px","","yes","",str);          
              }else{                    
				var surl = "index.php?module=Settings&action=ListWareHouse&parenttab=Settings&ReportHeader=dheader";
				//alert(surl);
				ldAjax(surl,"",function(data){
					if(data.code==1){
						ld(" [name=SettingRightContent]").html(data.result.content);
                        initRightContentHeight();
						DelProgressObjs();
					}
				})
              }      
            }
        });
    });
}
function startusing(obj,record,BLOCKIDSETTING,FIELDIDSETTING){
    var confirm_str = arrJsPopLabel['ENABLEDISABLEWAREHOUSE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        ld(obj).prop('checked',true);
        new Ajax.Request("index.php",
        {
            queue:{
                position:"end",
                scope:"command"
            },
            method:"post",
            postBody:"module=Settings&action=SettingsAjax&file=IsOrNotStartWareHouse&status=startusing&record="+record,
            onComplete:function (response) {          
                var surl = "index.php?module=Settings&action=ListWareHouse&parenttab=Settings&ReportHeader=dheader";
				//alert(surl);
				ldAjax(surl,"",function(data){
					if(data.code==1){
						ld(" [name=SettingRightContent]").html(data.result.content);
                        initRightContentHeight();
						DelProgressObjs();
					}
				})
            }
        });
    });
}

function warehouse_active_checked(obj,warehousename,record){
    if(ld(obj).is(':checked')){
        ld(obj).prop('checked',false);
        startusing(obj,record);
    }else{
        ld(obj).prop('checked',true);
        forbiddenwarehouse(obj,warehousename,record);
    }
}

{/literal}
</script>