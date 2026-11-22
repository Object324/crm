<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
{*<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">*}
    <div class="main_grid_top">
        <span class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                专题板块设置
            </span>
            <span class="grid-view-choose dinline-block lfloat">选择专题</span>
            <select fieldtype="select" id="pick_topic" name="pick_topic" class="btn-radius-system width150" onchange="CardSettingsobj.getTopicBlockLists(this);" style="display:none;">
                {foreach item=TopicList from=$TopicLists}
                    <option value="{$TopicList.topicid}" {if $TopicList.topicid eq $TOPICID}selected{/if}>{$TopicList.topiclabel}</option>
                {/foreach}
            </select>
            <span class="rfloat" style="margin-top: 21px;">
                <a href="javascript:;" title="设置" onclick="CardSettingsobj.topicSet()"><b class="icon-homeimg icon-set"></b></a>
            </span>
        </span>
    </div>
    
    


    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float" name="topicblocklist">
                {include file="modules/CardSettings/MultiTopicBlock.tpl"}
            </div>
        </div>
    </div>
{*</form>*}

