<div class="ld-pop-container" style="max-height:400px;overflow:auto;">
    <div class="ld-pop-container-div">
        {if !empty($ModtrackerData['userfullname_getin'])}
            <div>
                <span class="ld-field-label">{'ENTERSTAGE'|getFixedLabel}{'OPERATIONER'|getFixedLabel}:</span>
                <span class="ld-field-value">{$ModtrackerData['userfullname_getin']}</span>
            </div>
        {/if}
        {if !empty($ModtrackerData['changedon_getin'])}
            <div>
                <span class="ld-field-label">{'ENTERSTAGE'|getFixedLabel}{'operatoroertime'|getFixedLabel}:</span>
                <span class="ld-field-value">{$ModtrackerData['changedon_getin']}</span>
            </div>
        {/if}
        {if !empty($ModtrackerData['userfullname'])}
            <div>
                <span class="ld-field-label">{'LEAVESTAGE'|getFixedLabel}{'OPERATIONER'|getFixedLabel}:</span>
                <span class="ld-field-value">{$ModtrackerData['userfullname']}</span>
            </div>
        {/if}
        {if !empty($ModtrackerData['changedon'])}
            <div>
                <span class="ld-field-label">{'LEAVESTAGE'|getFixedLabel}{'operatoroertime'|getFixedLabel}:</span>
                <span class="ld-field-value">{$ModtrackerData['changedon']}</span>
            </div>
        {/if}
        {if !empty($ModtrackerData['staytimecontent'])}
            <div>
                <span class="ld-field-label">{'LATESTDURATION'|getFixedLabel}:</span>
                <span class="ld-field-value">{$ModtrackerData['staytimecontent']}</span>
            </div>
        {/if}
        {if !empty($ModtrackerData['allstaytimecontent'])}
            <div>
                <span class="ld-field-label">{'TOTALDURATION'|getFixedLabel}:</span>
                <span class="ld-field-value">{$ModtrackerData['allstaytimecontent']}</span>
            </div>
        {/if}
        {if $DetailTaskinfo.tasknum>0}
            {assign var=TASKLOG value=$DetailTaskinfo['tasklog']}
            {assign var=TASKINFO value=$DetailTaskinfo['taskinfo']}
            {assign var=ALLOWEDIT value=$DetailTaskinfo['allow_edit']}
            {assign var=STAGENAME value=$DetailTaskinfo['stagename']}
            {assign var=SHOWTYPE value='showadvnacedetail'}
            <div name="DetailTaskvalue" id="DetailTaskvalue" class="ld-pop-container ld-table-container ld-table-container-lines pad0">
                {include file="Taskprogress.tpl"}
            </div>
        {/if}
    </div>
</div>