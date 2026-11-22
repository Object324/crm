<div class="headdiv" style="background-color: {$formheadcolor}">
    <h3 id="show_activitytitle">{$activitytitle}</h3>
    {if $activityintroduction neq ''}
        <p id="show_activityintroduction">{$activityintroduction|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}</p>
    {/if}
</div>
<div class="formdiv">
    <form id="validate" action="">
        <input type="hidden" name="mappingmodule" value="{$mappingmodule}">
        <input type="hidden" name="record" value="{$record}">
        <input type="hidden" name="uid" value="{$uid}">
        <div id="mainFieldsIphone">
            {include file='modules/SocialPromotion/SocialCustomFieldIphone.tpl'}
        </div>
        <div>
            <button style="background-color:{$buttoncolor}" class="submit">{$buttonname}</button>
            {if $form eq true}
            <span  class="submit cancel" ><a href="{$siteUrl}{$h5url}">取消</a></span>
            {/if}
        </div>
    </form>
</div>