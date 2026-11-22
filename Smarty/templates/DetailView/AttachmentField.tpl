<div>


    {if $keyid eq 1108} {*附件模块*}
        {foreach item=item key=kid from=$keyval}
            {foreach item=attval key=fid from=$item}
                {if isset($attval.name) && $attval.name neq ''}
                    {if $attval.file_type eq 'img'}
                        <span id="dtlview_{$fid}" name="dtlview_{$fid}" class="listattachment">
                        {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && $attval.fileAllowed.Preview eq 'yes'}
                            <img src="{$attval.httppath}" onclick="savePreviewlog({$ID},{$fid},'{$MODULE}','{$values}');update_frequency('{$fid}','preview');"   alt=""/>
                        {/if}
                        <span  class="attachments-padL11">{$attval.name}&nbsp;<span style="color:#798699;padding-left:5px">({$attval.imagefromtype}  {$attval.size})</span>

                            {if $ID|@IsDownLoadProfile:$MODULE eq 'yes' && $attval.fileAllowed.Download eq 'yes'}
                                <span>
                                    <a download="" href="javascript:DownLoad({$fid},{$RECORD});"
                                       onclick="update_frequency('{$fid}','download');" title="{'DOWNLOADFILE'|@getFixedLabel}"><span>
                                    {'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;
                                    {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.download_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);"  download="" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
                                </span>
                            {/if}

                            {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && {$attval.storage_location neq 'awsserver'}  && $attval.fileAllowed.Preview eq 'yes'}
                                <span>
                                    {*img标签有点击事件，则这里不能在写事件了，否则ld('#dtlview_{$fid}>img').click()会导致重复*}
                                    {* <a href="javascript:void(0);" onclick="ld('#dtlview_{$fid}>img').click();savePreviewlog({$ID},{$fid},'{$MODULE}','{$values}');update_frequency('{$fid}','preview');" title="{'PREVIEW'|@getFixedLabel}{'Attachment'|@getFixedLabel}"><span>{'PREVIEW'|@getFixedLabel}</span></a> *}
                                    <a href="javascript:void(0);" onclick="ld('#dtlview_{$fid}>img').click();" title="{'PREVIEW'|@getFixedLabel}{'Attachment'|@getFixedLabel}"><span>{'PREVIEW'|@getFixedLabel}</span></a>
                                    {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.preview_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
                                </span>
                            {/if}

                        </span>
                    </span>
                    {elseif $attval.file_type eq 'video'}
                        {*@edit:liushuai,2021-04-14,reason:【ID1001518】PC端，附件视频增加在线预览功能*}
                        <span id="dtlview_{$fid}" name="dtlview_{$fid}" class="listattachment">
                        {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && $attval.fileAllowed.Preview eq 'yes'}
                            <video id="video_{$fid}"> {*附件模块的序时簿列表的预览是代码生成的，比较特殊，需要获取到video标签，故添加此id*}
                                <source src="{$attval.httppath}" type="video/mp4">
                                <source src="{$attval.httppath}" type="video/webm">
                                <source src="{$attval.httppath}" type="video/ogg">
                                nonsupport video
                            </video>
                        {/if}
                        <span  class="attachments-padL11">{$attval.name}&nbsp;<span style="color:#798699;padding-left:5px">({$attval.imagefromtype}  {$attval.size})</span>

                            {if $ID|@IsDownLoadProfile:$MODULE eq 'yes' && $attval.fileAllowed.Download eq 'yes'}
                                <span>
                                    <a  download="" href="javascript:DownLoad({$fid},{$RECORD});"  onclick="update_frequency('{$fid}','download');" title="{'DOWNLOADFILE'|@getFixedLabel}"><span>{'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;
                                    {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.download_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
                                </span>
                            {/if}

                            {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && {$attval.storage_location neq 'awsserver'}  && $attval.fileAllowed.Preview eq 'yes'}
                                <video controls="controls" id="video_{$fid}" style="display: none;">
                                    <source src="{$attval.httppath}" type="video/mp4">
                                    <source src="{$attval.httppath}" type="video/webm">
                                    <source src="{$attval.httppath}" type="video/ogg">
                                    nonsupport video
                                </video>
                                <span>
                                    <a href="javascript:void(0);" onclick="preview_video({$fid});savePreviewlog({$ID},{$fid},'{$MODULE}','{$values}');update_frequency('{$fid}','preview');" title="{'PREVIEW'|@getFixedLabel}{'Attachment'|@getFixedLabel}"><span>{'PREVIEW'|@getFixedLabel}</span></a>
                                    {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.preview_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
                                </span>
                            {/if}

                        </span>
                    </span>
                    {else}
                        <span id="dtlview_{$fid}" name="dtlview_{$fid}" class="listattachment">
                        <span class="attachments-padL11 clearBoth">{$attval.name}&nbsp;<span style="color:#798699;">({$attval.imagefromtype}  {$attval.size})</span>



                            {if $ID|@IsDownLoadProfile:$MODULE eq 'yes' && $attval.fileAllowed.Download eq 'yes'}
                                <span >
                                    <a download=""  href="javascript:DownLoad({$fid},{$RECORD});"
                                       onclick="update_frequency('{$fid}','download');" download="" title="{'DOWNLOADFILE'|@getFixedLabel}">
                                    <span>{'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;
                                    {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.download_times} eq 0}style = "display: none;"{/if}>(  <a href="javascript:void(0);" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
                                </span>
                            {/if}
                            {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && {$attval.storage_location neq 'awsserver'} && $attval.fileAllowed.Preview eq 'yes'}
                                <span>
                                    <a href="javascript:void(0);" onclick="update_frequency('{$fid}','preview');open_Attachment({$RECORD},{$fid},'{$MODULE}','{$items}');" title="{'PREVIEW'|@getFixedLabel}{'Attachment'|@getFixedLabel}">
                                        <span>{'PREVIEW'|@getFixedLabel}</span></a>
                                    {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.preview_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
                                </span>

                            {/if}

                        </span>
                    </span>
                    {/if}

                {/if}
            {/foreach}
        {/foreach}
    {elseif $keyid eq 69}



        {foreach item=item key=keysid from=$keyval}

            {foreach item=attval key=fid from=$item}

                {if isset($attval.name) && $attval.name neq ''}

                    <span id="dtlview_{$fid}" name="dtlview_{$fid}" class="listattachment">

                                  {assign var="previewprofile" value='yes'}
                                   <img src="{$attval.httppath}" onclick="savePreviewlog({$ID},{$fid},'{$MODULE}','{$values}');update_frequency('{$fid}','preview');" alt="" />


                                <span  class="attachments-padL11 {if $previewprofile neq 'yes'} clearBoth{/if}">{$attval.name}&nbsp;<span style="color:#798699;padding-left:5px">({$attval.imagefromtype}  {$attval.size})</span>



                                    {if $ID|@IsDownLoadProfile:$MODULE eq 'yes' && $attval.fileAllowed.Download eq 'yes'}
                                        <a download="" href="index.php?module=uploads&action=downloadfile&return_module={$MODULE}&fileid={$fid}&entityid={$keysid}" onclick="update_frequency('{$fid}','download');"><span>{'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;
                                        {*@edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志（除了附件模块之外的其它模块）*}
                                        {*@edit:liushuai,2021-04-14,reason:0045462: PC端->客户模块->附件->下载、预览次数优化建议*}
                                        {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.download_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
                                    {/if}

                                    {*                                    // @edit:dong @date:2020/07/22 @reason: 模块明细界面，附件字段，点击查看图片附件，增加图片预览插件；*}
                                    {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && {$attval.storage_location neq 'awsserver'} && $attval.fileAllowed.Preview eq 'yes'}
                                        {*                                       <a href="javascript:void(0);" onclick="open_Attachment({$ID},{$fid},'{$MODULE}','{$values}')"><span>{'PREVIEW'|@getFixedLabel}</span></a></span>*}
                                        <a href="javascript:void(0);" onclick="ld('#dtlview_{$fid}>img').click();"><span>{'PREVIEW'|@getFixedLabel}</span></a>
                                        {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.preview_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}

                                    {/if}
                            </span>
                        </span>

                {/if}

            {/foreach}

        {/foreach}

    {else}
        {assign var="isshow" value="0"}
        {if $MODULE eq "Documents"}
            {if $FILE_STATUS eq 1 && $keyval neq "" && $DLD_TYPE neq "E"}
                {assign var="isshow" value="1"}
            {/if}
        {elseif $keyval neq ""}
            {assign var="isshow" value="1"}
        {/if}

        {if $DLD_TYPE eq 'E'}

            <a href="{$FILENAME}" target="_blank">{$FILENAME}</a>
        {else}
            {foreach item=item key=keysid from=$keyval}

                {foreach item=attval key=fid from=$item}

                    {if isset($attval.name) && $attval.name neq ''}
                        {if $attval.file_type eq 'img'}
                            <span id="dtlview_{$fid}" name="dtlview_{$fid}" class="listattachment">
                            {*
                            {if $keyid eq 1109}
                            *}
                                {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && $attval.fileAllowed.Preview eq 'yes'}
                                    {assign var="previewprofile" value='yes'}
                                    <img src="{$attval.httppath}" onclick="savePreviewlog({$ID},{$fid},'{$MODULE}','{$values}');update_frequency('{$fid}','preview');" alt="" />
                                {/if}
                                {*
                                {else}
                                      {assign var="previewprofile" value='yes'}
                                       <img src="{$attval.httppath}" onclick="savePreviewlog({$ID},{$fid},'{$MODULE}','{$values}');update_frequency('{$fid}','preview');" alt="" />
                                {/if}
                                *}

                            <span  class="attachments-padL11 {if $previewprofile neq 'yes'} clearBoth{/if}">{$attval.name}&nbsp;<span style="color:#798699;padding-left:5px">({$attval.imagefromtype}  {$attval.size})</span>

                                {if $keyid eq 1109 ||($DLD_TYPE eq 'I' &&($ADMIN eq 'yes' || $FILE_STATUS eq 1 || $ISASSIGNED eq 'yes'))}

                                    {if $ID|@IsDownLoadProfile:$MODULE eq 'yes' && $attval.fileAllowed.Download eq 'yes'}
                                        <a download="" href="index.php?module=uploads&action=downloadfile&return_module={$MODULE}&fileid={$fid}&entityid={$keysid}" onclick="update_frequency('{$fid}','download');"><span>{'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;
                                        {*@edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志（除了附件模块之外的其它模块）*}
                                        {*@edit:liushuai,2021-04-14,reason:0045462: PC端->客户模块->附件->下载、预览次数优化建议*}
                                        {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.download_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
                                    {/if}


{*                                    // @edit:dong @date:2020/07/22 @reason: 模块明细界面，附件字段，点击查看图片附件，增加图片预览插件；*}
                                     {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && {$attval.storage_location neq 'awsserver'} && $attval.fileAllowed.Preview eq 'yes'}
                                    {*                                       <a href="javascript:void(0);" onclick="open_Attachment({$ID},{$fid},'{$MODULE}','{$values}')"><span>{'PREVIEW'|@getFixedLabel}</span></a></span>*}
                                    <a href="javascript:void(0);" onclick="ld('#dtlview_{$fid}>img').click();"><span>{'PREVIEW'|@getFixedLabel}</span></a>
                                        {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.preview_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}

                                {/if}

                                {/if}

                            </span>
                        </span>
                        {elseif $attval.file_type eq 'video'}
                            {*@edit:liushuai,2021-04-14,reason:【ID1001518】PC端，附件视频增加在线预览功能*}
                            <span id="dtlview_{$fid}" name="dtlview_{$fid}" class="listattachment">
                            {if $keyid eq 1109}
                                {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && $attval.fileAllowed.Preview eq 'yes'}
                                    {assign var="previewprofile" value='yes'}
                                    {*<video controls controlslist="nodownload">*}
                                    <video id="video_{$fid}">
                                        <source src="{$attval.httppath}" type="video/mp4">
                                        <source src="{$attval.httppath}" type="video/webm">
                                        <source src="{$attval.httppath}" type="video/ogg">
                                        nonsupport video
                                    </video>
                                {/if}
                            {else}
                                  {assign var="previewprofile" value='yes'}
                                   <video id="video_{$fid}">
                                        <source src="{$attval.httppath}" type="video/mp4">
                                        <source src="{$attval.httppath}" type="video/webm">
                                        <source src="{$attval.httppath}" type="video/ogg">
                                        nonsupport video
                                    </video>
                            {/if}

                            <span  class="attachments-padL11 {if $previewprofile neq 'yes'} clearBoth{/if}">{$attval.name}&nbsp;<span style="color:#798699;padding-left:5px">({$attval.imagefromtype}  {$attval.size})</span>

                            {if $keyid eq 1109 ||($DLD_TYPE eq 'I' &&($ADMIN eq 'yes' || $FILE_STATUS eq 1 || $ISASSIGNED eq 'yes'))}

                                {if $ID|@IsDownLoadProfile:$MODULE eq 'yes' && $attval.fileAllowed.Download eq 'yes'}
                                    <a  download="" href ="index.php?module=uploads&action=downloadfile&return_module={$MODULE}&fileid={$fid}&entityid={$keysid}" onclick="update_frequency('{$fid}','download');"><span>{'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;
                                    {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                    <span {if {$attval.download_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                {/if}
                            {/if}

                            {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && {$attval.storage_location neq 'awsserver'} && $attval.fileAllowed.Preview eq 'yes'}
                                <video controls="controls" id="video_{$fid}" style="display: none;">
                                    <source src="{$attval.httppath}" type="video/mp4">
                                    <source src="{$attval.httppath}" type="video/webm">
                                    <source src="{$attval.httppath}" type="video/ogg">
                                    nonsupport video
                                </video>
                                <a href="javascript:void(0);" onclick="preview_video({$fid});savePreviewlog({$ID},{$fid},'{$MODULE}','{$values}');update_frequency('{$fid}','preview');">
                                    <span>{'PREVIEW'|@getFixedLabel}</span>
                                </a>
                                {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                    <span {if {$attval.preview_times} eq 0}style = "display: none;"{/if}>
                                        (<a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})
                                    </span>&nbsp;&nbsp;
                                {/if}
                            {/if}
                        {/if}
                            </span>
                        </span>
                        {else}
                            <span id="dtlview_{$fid}" name="dtlview_{$fid}" class="listattachment">
                            <span class="attachments-padL11 clearBoth">{$attval.name}&nbsp;<span style="color:#798699;">({$attval.size})</span>

                                {if $keyid eq 1109 ||($DLD_TYPE eq 'I' &&($ADMIN eq 'yes' || $FILE_STATUS eq 1 || $ISASSIGNED eq 'yes'))}
                                    <span {$attval.storage_location}>
                                        {if $ID|@IsDownLoadProfile:$MODULE eq 'yes' && $attval.fileAllowed.Download eq 'yes'}
                                            <a download="" href = "index.php?module=uploads&action=downloadfile&return_module={$MODULE}&fileid={$fid}&entityid={$keysid}" onclick="update_frequency('{$fid}','download');" {*onclick="javascript:dldCntIncrease('{$keysid}');"*}><span>{'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;
                                            {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                            <span {if {$attval.download_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                        {/if}
                                        {/if}

                                        {if $ID|@IsPreviewProfile:$MODULE eq 'yes' && {$attval.storage_location neq 'awsserver'} && $attval.fileAllowed.Preview eq 'yes'}
                                            <a href="javascript:void(0);" onclick="update_frequency('{$fid}','preview');open_Attachment({$ID},{$fid},'{$MODULE}','{$values}');"><span>{'PREVIEW'|@getFixedLabel}</span></a>
                                            {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                            <span {if {$attval.preview_times} eq 0}style = "display: none;"{/if}>( <a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                        {/if}
                                        {/if}
                                    </span>
                                {/if}

                            </span>
                        </span>
                        {/if}
                    {/if}

                {/foreach}

            {/foreach}
        {/if}
    {/if}
</div>