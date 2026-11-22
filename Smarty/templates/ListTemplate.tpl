<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings">
<input type="hidden" name="action" value="createtemplate">
<input type="hidden" name="mode" value="create">
<input type="hidden" name="parenttab" value="Settings">
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
{*    @edit:liushuai,2020-09-08,reason:【ID1000285】PC端：首页增加首页视图设置*}
    {if $from_module neq 'home'}{*首页里的首页模板定制*}
        {*系统设置里的首页模板定制*}
        <div class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                {'LBL_TEMPLATES'|@getFixedLabel}<font>（{'LBL_TEMPLATES_DESCRIPTION'|@getFixedLabel}）</font>
            </span>
        </div>
    {/if}
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="settings_listtemplate.editListTemplate('','{$from_module}')" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
                <tr>
                    <th>#</th>
                    <th align="left" title="{$LIST_HEADER.1}">{$LIST_HEADER.1}</th>
                    <th align="left" title="{$LIST_HEADER.2}">{$LIST_HEADER.2}</th>
                    <th align="left" title="{$LIST_HEADER.3}">{$LIST_HEADER.3}</th>
                    <th align="left" title="{$LIST_HEADER.4}">{$LIST_HEADER.4}</th>
                    {if $LANGUAGETYPE  eq 'en'}
                    <th width="110">{'OPERATING'|@getFixedLabel}</th>
                    {else}
                    <th width="90">{'OPERATING'|@getFixedLabel}</th>
                    {/if}
                </tr>
                {if $LIST_ENTRIES|@count gte 1}
                    {assign var="i" value=0}
                    {foreach name=templatelist item=templatevalues from=$LIST_ENTRIES}
                    {assign var="j" value=$i++}
                    {if $j mod 2 eq '0'}
                        <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    {else}
                        <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    {/if}
                        <td>{$smarty.foreach.templatelist.iteration}</td>
                        <td>
                            <a href="#" onclick="settings_listtemplate.editListTemplate('{$templatevalues.templateid}','{$from_module}')"><span title="{$templatevalues.templatename}">{$templatevalues.templatename}</span></a>
                        </td>
                        <td><span title="{$templatevalues.rolename}">{$templatevalues.rolename}</span></td>
                        <td>{$templatevalues.modifiedname}</td>
                        <td><span title="{$templatevalues.modifiedtime}">{$templatevalues.modifiedtime}</span></td>
                        <td>
                            <a class="Anu3_a" href="javascript:void(0)" onclick="settings_listtemplate.editListTemplate({$templatevalues.templateid},'{$from_module}')">{'EDIT'|@getFixedLabel}</a>    
                            <a class="Anu3_a redFont" href="javascript:void(0)" onclick="return settings_listtemplate.deletetemplate(this,'{$templatevalues.templateid}','{$templatevalues.deleted}');">{'DELETE'|@getFixedLabel}</a>
                        </td>
                    </tr>
                    {/foreach}
                {else}
                    <tr class="lvtColData">
                        <td colspan="6" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
                    </tr>
                {/if}
            </table>
        </div>
    </div>
</div>
</form>

<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>