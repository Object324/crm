{*@edit:liushuai,2020-12-29,reason:【ID1001225】快速创建增加设置按钮，可设置快速创建显示的模块*}
{*右上角快速创建设置保存后更新页面*}
{foreach item=details from=$QUICKMODULE}
    {if $details.module neq "PaymentPlan"&& $details.module neq "SendPayment"}
        <div class="quicklymodule" tag="{$details.module}" edit="{$details.edit}">
            <div class="quicklyimgdiv">
                <img src="{$details.img}"/>
                <div>
                    <p data-fieldtable="{$details.label}">{$details.label}</p>
                </div>
            </div>
        </div>
    {/if}
{/foreach}