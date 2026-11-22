<div id="picklistpresetcolor" name="picklistpresetcolor" style="height: 250px">
    {*  页签  *}
    <div id="changetab" class="ld-change-tab" >
        <ul class="ld-change-tab-ul">
            {foreach key=key item=label from=$colortab}
                <li {if $key eq $checkedcolor.type}class="ld-change-tab-active"{/if} tag="{$key}" name="tag"><a href="javascript:;">{$label}</a></li>
            {/foreach}
        </ul>
    </div>
    {*  主題色  *}
    <div class="ld-presetcolor-div" id="preset" {if $checkedcolor.type neq 'preset'}style="display: none;"{/if}>
        <ul name="presetcolor_ul">
            {foreach key=key item=value from=$presetcolor}
                <li name="presetcolor_li">
                    <a name="presetcolor" style="background-color:{$value.color};" color="{$value.color}">
                        {if $checkedcolor.color eq $value.color}
                            <b class="ld-presetcolor-checked"></b>
                        {/if}
                    </a>
                </li>
            {/foreach}
        </ul>
    </div>
    {*  自定义  *}
    <div id="custom" style="display: none">
        <link rel="stylesheet" href="themes/softed/colpick.css" type="text/css" />
        <div id="picker" name="picker" class="ld-colpick-div menu-colpick"></div>
    </div>
</div>