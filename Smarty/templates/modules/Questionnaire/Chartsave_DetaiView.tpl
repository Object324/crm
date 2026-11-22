<input type="hidden" name="description" value="{$description}">
<link rel="stylesheet" type="text/css" href="./themes/softed/Questionnaire.css">
<link rel="stylesheet" type="text/css" href="./themes/softed/base.css">
<link rel="stylesheet" type="text/css" href="./themes/softed/Questionnaire.css">
<link rel="stylesheet" type="text/css" href="./themes/softed/common.css">
<link rel="stylesheet" type="text/css" href="./themes/softed/style.css">
<div class="container">
    <div class="headdiv">
        <h1 id="show_activitytitle">{$name}</h1>
        {if $description neq ''}
            <p id="show_activityintroduction">
                {$description|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}
            </p>
        {/if}
    </div>
    <div class="formdiv">
        <form id="validate" action="">
            <input type="hidden" name="record" value="{$record}">
            <div id="mainFieldsIphone" style="margin-top: 20px;">
                {include file='modules/Questionnaire/Chartsave_DetaiView_content.tpl'}
            </div>
{*            <div class="Q_Submit">*}
{*                <button class="submit">提交</button>*}
{*            </div>*}
        </form>
    </div>
</div>