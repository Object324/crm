<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="modules/Settings/Settings.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/SelfServiceConfig.js"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {$CUSTOMERSELFSERVICECONFIG02}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a id="save_selfconfig_module" href="javascript:;" class="ld-button ld-button-primary" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="selfconfig_module_div" class="cont_wrap clear_float">
            <table name = "selfServiceModuleConfig" class="settingTable fir-center" width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <th align="left">#</th>
                <th align="left">{'MPMODULESET'|@getFixedLabel}</th>
                <th align="left">{'MPSELFCONFIGPLAT'|@getFixedLabel}</th>
                <th align="left">{'MPSELFCONFIGPLATEN'|@getFixedLabel}</th>
                <th align="left">{'WHETHERTOENABLE'|@getFixedLabel}</th>
                <th width="40" align="left">{'OPERATING'|@getFixedLabel}</th>
              </tr>
                {assign var="i" value=0}
              {foreach item = value from =$ENTITY name=pname}
              {assign var="j" value=$i++}
              {if $j mod 2 eq '0'}
              <tr tag="module" id="setting_{$i}" tagid="{$value.id}"  class="lvtColData ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              {else}
              <tr tag="module" id="setting_{$i}" tagid="{$value.id}"  class="lvtColDataBj ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              {/if}
                  <td>{$value.i+1}</td>
                  <td>{$value.crmmodulelabel}</td>
                  <td><input class="ld-input-inner ld-input-inner-auto" type="text" tag="mplabel" name="{$value.id}" value="{$value.mplabel}"/></td>
                  <td><input class="ld-input-inner ld-input-inner-auto" type="text" tag="mplabel_en" name="{$value.id}" value="{$value.mplabel_en}"/></td>
                  <td><input type="checkbox" onclick="SelfServiceConfig.set_ActiveOrInactive({$value.id},this)" class="second_switch"
                    {if $value.presence eq 0}checked=""{/if} />
                  </td>
                  <td>
                      {*editor:gyq_20191104 reason:初始化首尾按钮
                        0038389: （1.6）系统设置>服务小程序设置、订单小程序设置>模块设置>操作列：第一行的【上移】按钮应该去掉，第二行的【下移】按钮应该去掉。*}
                      {*<a class="Anu3_a" tag="move_up" onclick="SelfServiceConfig.set_moveupmodule(this,'up')"
                         {if $value.i eq 0}hidden{/if}>{'MOVEUP'|@getFixedLabel}</a>
                      <a class="Anu3_a" tag="move_down" onclick="SelfServiceConfig.set_moveupmodule(this,'down')"
                         {if $value.i+1 eq $ENTITYNUMROWS}hidden{/if}>{'MOVEDOWN'|@getFixedLabel}</a>*}
                      {*拖拽按钮*}
                      <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"
                         data-direction="left" data-type="position" style="display:none;cursor:move;margin-top:2px"></a>
                  </td>
              </tr>
              {/foreach}
            </table>
        </div>
    </div>
</div>
</form>
<script>
    getJsScript('include/js/SelfServiceConfig.js',function (){
        SelfServiceConfig.movetable('module');
    });
</script>