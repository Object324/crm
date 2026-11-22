            {if $SWIPERRATIO == '1:2' && $reglogin_check != 'yes'}
                <div class="ld-loginform-afterdiv">
                    {if $LOGININFO.autheninfo.isshow eq 'yes' || 'isshow'|@array_key_exists:$LOGININFO.autheninfo}
                        <a href="javascript:void(0);" onclick="getRootPath();">{if $LANGUAGETYPE eq 'zh'}{$LOGININFO.autheninfo.zh}{else}{$LOGININFO.autheninfo.en}{/if}</a>
                    {/if}
                    {if $ENORZH eq 'no'}{else}
                        <div class="ld-container-form-language" name="ld-container-form-language"></div>
                    {/if}

                </div>
            {/if}
        </div>
        <div class="ld-crm-container-footer">
            {if $SWIPERRATIO == '2:1' && $reglogin_check != 'yes'}
                <div class="ld-loginform-afterdiv">
                    {if $LOGININFO.autheninfo.isshow eq 'yes' || 'isshow'|@array_key_exists:$LOGININFO.autheninfo}
                        <a href="javascript:void(0);" onclick="getRootPath();">{if $LANGUAGETYPE eq 'zh'}{$LOGININFO.autheninfo.zh}{else}{$LOGININFO.autheninfo.en}{/if}</a>
                    {/if}
                    {if $ENORZH eq 'no'}{else}
                        <div class="ld-container-form-language" name="ld-container-form-language" style="margin-bottom: 20px;"s></div>
                    {/if}
                </div>
            {/if}

            {if $LINGDANG eq 'yes'}

            {else}
                {if $COMMON_VERSIONINFO.iosdownload neq ''}
                    <img src="dataCache/test/logo/iPhone.png" class="val_m" /><a href="{$COMMON_VERSIONINFO.iosdownload}" target="_blank">iPhone</a>
                {/if}
                {if $COMMON_VERSIONINFO.androiddownload neq ''}
                    <img src="dataCache/test/logo/android_img.jpg" class="val_m" /><a href="{$COMMON_VERSIONINFO.androiddownload}">Android</a>
                {/if}
            {/if}

            {*{if $LOGININFO.resolution.isshow eq 'yes'}
                <a href="javascript:void(0);" >{if $LANGUAGETYPE eq 'zh'}{$LOGININFO.resolution.zh}{else}{$LOGININFO.resolution.en}{/if}</a>
            {/if}*}
            <div class="ld-crm-container-footer-content">
                {if $LOGININFO.copyrightinfo.isshow neq 'no'}
                    <a style="color: #666 !important;">
                        {if $LANGUAGETYPE eq 'zh'} 版权所有{else}Copyright{/if}
                        &nbsp;
                        上海灵当信息科技有限公司
                    </a>
                {/if}
                {if $LOGININFO.clearCache.isshow eq 'yes'}
                    <a href="javascript:void(0);" onclick="clearcache('{$TOKEN}');">{if $LANGUAGETYPE eq 'zh'}{$LOGININFO.clearCache.zh}{else}{$LOGININFO.clearCache.en}{/if}</a>
                {/if}
            </div>
        </div>
    </section>
</main>