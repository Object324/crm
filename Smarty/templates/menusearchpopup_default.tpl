<div class="menusearchpopup_div">
    {if $HISTORY_ARR|@count > 0}
        <div class="menusearch_block menusearch_history">
            <div class="menusearch_blocktitle">
                <span>{'SEARCHHISTORY'|@getFixedLabel}</span>
                <div class="menu_deletehistory" title="{'DELETE'|@getFixedLabel}"></div>
            </div>
            <div class="menusearch_blockcontent">
                {foreach key=index item=text from=$HISTORY_ARR}
                    <div class="menuhistory_tag" data-searchtext="{$text}">{$text}</div>
                {/foreach}
            </div>
        </div>
    {/if}
    {foreach key=parenttabname item=parenttabrelarr from=$PARENTTABLIST}
        <div class="menusearch_block ">
            <div class="menusearch_blocktitle">
                <span>{$PARENTTAB_LABEL[$parenttabname]}</span>
            </div>
            <div class="menusearch_blockcontent">
                {foreach key=index item=parenttabrel from=$parenttabrelarr}
                    {assign var="parenttabname" value=$parenttabrel['parenttabname']}
                    {assign var="relid" value=$parenttabrel['id']}
                    {assign var="label" value=$parenttabrel['modulename']}
                    {assign var="tmpmodulename" value=$parenttabrel['tablabel']}
                    {assign var="type" value=$parenttabrel['tab_tablename']}
                    {assign var="tabid" value=$parenttabrel['tabid']}
                    {if $type == 'ld_linkmodulecustom'}
                        {assign var="entitytype" value=$parenttabrel['entitytype']}
                        {assign var="linkurl" value=$parenttabrel['linkurl']}
                        {assign var="checkphp" value=$parenttabrel['checkphp']}
                        {assign var="isopeninblank" value=$parenttabrel['isopeninblank']}
                        {if $isopeninblank == ''}{assign var="isopeninblank" value='no'}{/if}
                        {assign var="linkcivid" value=$parenttabrel['linkcvid']}
                        {assign var="specialcheck" value=$checkphp|cat:'::'|cat:$isopeninblank|cat:'::'|cat:$linkcivid}

                        {if $tmpmodulename == 'CustomEcharts' || $tmpmodulename == 'CustomTables'}
                            <div class="menucontent_item" tabid="{$tabid}" parenttab="{$parenttabname}" relid="{$relid}" title="{$label}" type="{$type}" linkurl="{$linkurl}" module="{$tmpmodulename}" entitytype="{$entitytype}" specialcheck="{$specialcheck}">
                                <a target="_blank" href="{$linkurl}">{$label}<i class="moduleblank" title="打开新页签"></i></a>
                            </div>
                        {elseif $entitytype == 'category'}
                            {assign var="newUrl" value=$linkurl|substr:$linkurl|strpos:'&start'}
                            <div class="menucontent_item" tabid="{$tabid}" parenttab="{$parenttabname}" relid="{$relid}" title="{$label}" type="{$type}" linkurl="{$linkurl}" module="{$tmpmodulename}" entitytype="{$entitytype}" specialcheck="{$specialcheck}">
                                <a target="_blank" href="index.php?pageto_module={$tmpmodulename}&pageto_action=index&page_addurl={$newUrl|urlencode}">{$label}<i class="moduleblank" title="打开新页签"></i></a>
                            </div>
                        {else}
                            {if $linkurl|strpos:'CustomReport/JsReport/index.php?' >= 0}
                                {assign var="linkurl" value=$cls_UrlEncryptyJudgeobj->EncryptyBynosorturlparseQueryParams($linkurl)}
                            {/if}
                            <div class="menucontent_item" tabid="{$tabid}" parenttab="{$parenttabname}" relid="{$relid}" title="{$label}" type="{$type}" linkurl="{$linkurl}" entitytype="{$entitytype}" specialcheck="{$specialcheck}">
                                <a target="_blank" href="{$linkurl}">{$label}<i class="moduleblank" title="打开新页签"></i></a>
                            </div>
                        {/if}
                    {else}
                        <div class="menucontent_item" tabid="{$tabid}" parenttab="{$parenttabname}" relid="{$relid}" title="{$label}" type="{$type}" module="{$tmpmodulename}">
                            <a target="_self" href="index.php?pageto_module={$tmpmodulename}&pageto_action=index">{$label}<i class="moduleblank" title="打开新页签"></i></a>
                        </div>
                    {/if}
                {/foreach}
            </div>
        </div>
    {/foreach}
    {if $PARENTTABLIST|@count == 0 && $HISTORY_ARR|@count == 0}
        <div class="menusearch_nonecontent">
            <img src="themes/icon2023/ld-no-records.png">
            <div>{'NOCONTENT'|@getFixedLabel}</div>
        </div>
    {/if}
</div>