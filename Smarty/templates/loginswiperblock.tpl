<script>
    $(document).ready(function () {
        if(ld('#ld_login_swiper-container .swiper-slide').length>1){
            var mySwiper = new Swiper('#ld_login_swiper-container', {
                autoplay: {
                    delay: 3000,
                    disableOnInteraction: false
                },
                loop : true,//循环
                pagination: {
                    el: '.swiper-pagination',
                    clickable :true,
                },
            });
        }else{
            ld('#ld_login_swiper-container .swiper-pagination').hide();
        }

    })
</script>
<main class="ld-login-main" {if $SPSEXPIREDTIP eq 'yes' || $SPSEXPIRINGTIP eq 'yes' || $WEIXINLOGINERROR neq '' || $LOGIN_ERROR neq '' || $EXPIRINGTIP  eq  'yes' || $EXPIREDTIP eq 'yes' || $REGTESTTIP eq 'yes' || (isset($NOREGISTER) && $NOREGISTER eq 0)}style="height: calc(100% - 48px)" {/if}>
    <section class="ld-login-section-left" style="{if $SWIPERRATIO == '1:2'}width:32%;{elseif $SWIPERRATIO == '2:1'}width:70%;{/if}">
        <div class='swiper-container' id="ld_login_swiper-container">
            <div class='swiper-wrapper'>
                {foreach from=$LOGINSWIPERARR item=swiperinfo key=key}
                    <div class='swiper-slide' style="background-image: url('{$swiperinfo['content']}')">
                        {*{if !empty($swiperinfo['url'])}
                            <a style="display: block;height: 100%;width: 100%;" href="{$swiperinfo['url']}" target="_blank" rel="noopener noreferrer" ></a>
                        {/if}*}
                    </div>
                {/foreach}
            </div>
            <div class="swiper-pagination" style="{if count($LOGINSWIPERARR) <= 1}display:none;{/if}"></div>
        </div>
    </section>
    <section class="ld-login-section-right" style="{if $SWIPERRATIO == '1:2'}width:68%;{elseif $SWIPERRATIO == '2:1'}width:30%;{/if}">
        <div class="ld-crm-container-topright">
            {if $LOGININFO.companyurllabel.isshow  eq 'yes' && $LOGININFO.companyurllabel.content neq ''}

                <a href="{$LOGININFO.companyurllabel.content}" target="_blank" rel="noopener noreferrer" style="color: #3B7CFF;">
                    {if $LANGUAGETYPE eq 'zh'}{$LOGININFO.companyurllabel.zh}{else}{$LOGININFO.companyurllabel.en}{/if}
                </a>

            {/if}

            {if $LOGININFO.apptellabel.content neq ''&& $LOGININFO.apptellabel.isshow eq 'yes'}
                <a href="javascript:void(0);">{if $LANGUAGETYPE eq 'zh'}{$LOGININFO.apptellabel.zh}{else}{$LOGININFO.apptellabel.en}{/if} :{$LOGININFO.apptellabel.content}</a>
            {/if}
            {if $COMMON_VERSIONINFO.QQ neq '' }
                <a>
                    <!-- WPA Button Begin -->
                    <script charset="utf-8" type="text/javascript" src="http://wpa.b.qq.com/cgi/wpa.php?key=XzkzODA3MTY5Nl80Nzk4MjlfNDAwODg4NTExMF8"></script>
                    <!-- WPA Button End -->
                </a>
                <style type="text/css">
                    {literal}
                    .rig_bar span iframe {margin-bottom: -6px;}
                    {/literal}
                </style>
            {/if}
            {if $loginpage_url_num > 0}
                <a id="moresetselect" name="moresetselect" class="moresetselect" style="height: 20px;float: left;"></a>
            {/if}
        </div>
        <div class="ld-container-form">
