
<form action="index.php" method="post" id="createsigntask" name="createsigntask">

    <div id="" style="max-height: 450px;">
        <table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <th colspan="2" class="ld-from-headblock">
                    <div class="ld-from-headblock-title">合同信息</div>
                </th>
            </tr>
            <tr>
                <td class="ld-form-item-label" width="100">
                    <font color="red">*</font>合同主题
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="如签署劳动合同时，可设置为“劳动合同-XX公司-张三”" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input id="signTaskSubject" name="signTaskSubject" class="ld-input-inner" value="" type="text" required/>
                </td>
            </tr>
            {*<tr>
                <td class="ld-form-item-label" width="100">合同描述</td>
                <td class="ld-form-item-content">
                    <textarea id="description" name="description"></textarea>
                </td>
            </tr>*}
            <tr>
                <th colspan="2" class="ld-from-headblock">
                    <div class="ld-from-headblock-title">发起方</div>
                </th>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red">*</font>发起主体名称
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="即电子签约文件的发起单位" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
{*                    <input id="actorName" name="actorName" class="ld-input-inner" value="{$actorName}" type="text" required/>*}
                    <select id="actorName" name="actorName" class="ld-select-inner">
                        {foreach item=corp from=$corplists}
                            {if $corp.identStatus eq 'identified'} {*企业已认证*}
                                <option value="{$corp.corpName}">{$corp.corpName}</option>
                            {/if}
                        {/foreach}
                    </select>

                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>发起人</td>
                <td class="ld-form-item-content">
                    <select id="notifyAddress" name="notifyAddress" class="ld-select-inner">
                        {foreach item=member from=$memberlists}
                            {if $member.memberStatus eq 'activated'}
                            <option value="{$member.memberMobile}" memberId="{$member.memberId}">{$member.memberName}</option>
                            {/if}
                        {/foreach}
                    </select>
                </td>
            </tr>
            {*<tr>
                <td class="ld-form-item-label"><font color="red">*</font>发起人手机号</td>
                <td class="ld-form-item-content">
                    <input id="notifyAddress" name="notifyAddress" class="ld-input-inner" value="{$creatorMobile}" type="text" required/>
                </td>
            </tr>*}
            {*<tr>
                <td class="ld-form-item-label"><font color="red">*</font>签署节点类型</td>
                <td class="ld-form-item-content">
                    <select id="creator_actions_type" name="creator_actions_type" class="ld-select-inner">
                        <option value="OPERATOR">经办人签字</option>
                        <option value="LP">法定代表人签字</option>
                        <option value="COMPANY">企业签章</option>
                    </select>
                </td>
            </tr>*}
            <tr>
                <th colspan="2" class="ld-from-headblock">
                    <div class="ld-from-headblock-title">签署方</div>
                </th>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>签署方类型</td>
                <td class="ld-form-item-content">
                    <select id="actors[actorType]" name="actors[actorType]" class="ld-select-inner">
                        <option value="corp">企业</option>
                        <option value="person">个人</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red">*</font>签署方名称
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="企业署方需传入工商营业执照上的真实单位名称；个人签署方传入个人真实姓名" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input id="actors[actorName]" name="actors[actorName]" class="ld-input-inner" value="" type="text" required/>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>经办人联系方式</td>
                <td class="ld-form-item-content">
                    <input id="actors[notifyAddress]" name="actors[notifyAddress]" class="ld-input-inner" value="" type="text" required/>
                </td>
            </tr>
            {*<tr>
                <td class="ld-form-item-label"><font color="red">*</font>签署节点类型</td>
                <td class="ld-form-item-content">
                    <select id="signatories_actions_type" name="signatories_actions_type" class="ld-select-inner">
                        <option value="OPERATOR">经办人签字</option>
                        <option value="LP">法定代表人签字</option>
                        <option value="COMPANY">企业签章</option>
                    </select>
                </td>
            </tr>*}
            <tr>
                <th colspan="2" class="ld-from-headblock">
                    <div class="ld-from-headblock-title">日期设置</div>
                </th>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    签署截止日期
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="到期后未完成的签署任务将会逾期作废" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input type="text" name="expiresTime" id="expiresTime" value="" class="Wdate ld-input-inner Q_setTimeWdate" autocomplete="off" size="25" maxlength="10" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',alwaysUseStartDate:true{rdelim});"/>

                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    合同到期日期
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="表示该合同内各方约定的生效到期时间" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input type="text" name="dueDate" id="dueDate" value="" class="Wdate ld-input-inner Q_setTimeWdate" autocomplete="off" size="25" maxlength="10" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',alwaysUseStartDate:true{rdelim});"/>
                </td>
            </tr>
        </table>
    </div>
</form>