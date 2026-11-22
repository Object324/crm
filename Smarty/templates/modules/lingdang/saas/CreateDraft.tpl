
<form action="index.php" method="post" id="createdraft" name="createdraft" onsubmit="lingdangJS_DialogBox.block()">
{*    <input type="hidden" name="record" value="{$RECORD}"/>*}
{*    <input type="hidden" name="documentId" value="{$documentId}"/>*}

    <div id="" style="max-height: 450px;">
        <table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <th colspan="2" class="ld-from-headblock">
                    <div class="ld-from-headblock-title">电子签约基本信息</div>
                </th>
            </tr>
            <tr>
                <td class="ld-form-item-label" width="100">
                    <font color="red">*</font>合同主题
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="电子签约文件的标题，如签署劳动合同时，可设置为“劳动合同-XX公司-张三”" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input id="subject" name="subject" class="ld-input-inner" value="" type="text" required/>
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
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="即电子签约文件的发起单位，仅能传入用印流程设置的发起主体范围" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input id="tenantName" name="tenantName" class="ld-input-inner" value="{$tenantName}" type="text" required/>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">发起人姓名</td>
                <td class="ld-form-item-content">
                    <input id="creatorName" name="creatorName" class="ld-input-inner" value="{$creatorName}" type="text" required/>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>发起人手机号</td>
                <td class="ld-form-item-content">
                    <input id="creatorInfo[mobile]" name="creatorInfo[mobile]" class="ld-input-inner" value="{$creatorMobile}" type="text" required/>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>签署节点类型</td>
                <td class="ld-form-item-content">
                    <select id="creator_actions_type" name="creator_actions_type" class="ld-select-inner">
                        <option value="OPERATOR">经办人签字</option>
                        <option value="LP">法定代表人签字</option>
                        <option value="COMPANY">企业签章</option>
                    </select>
                </td>
            </tr>
            <tr>
                <th colspan="2" class="ld-from-headblock">
                    <div class="ld-from-headblock-title">签署方</div>
                </th>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>签署方类型</td>
                <td class="ld-form-item-content">
                    <select id="signatories[tenantType]" name="signatories[tenantType]" class="ld-select-inner">
                        <option value="COMPANY">公司</option>
                        <option value="PERSONAL">个人</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red">*</font>签署方名称
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="组织签署方需传入工商营业执照上的真实单位名称；个人签署方传入个人真实姓名" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input id="signatories[tenantName]" name="signatories[tenantName]" class="ld-input-inner" value="" type="text" required/>
                </td>
            </tr>
            <tr style="display: none;">
                <td class="ld-form-item-label"><font color="red">*</font>经办人姓名</td>
                <td class="ld-form-item-content">
                    <input id="signatories[receiverName]" name="signatories[receiverName]" class="ld-input-inner" value="" type="text" required/>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>经办人联系方式</td>
                <td class="ld-form-item-content">
                    <input id="signatories[contact]" name="signatories[contact]" class="ld-input-inner" value="" type="text" required/>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>签署节点类型</td>
                <td class="ld-form-item-content">
                    <select id="signatories_actions_type" name="signatories_actions_type" class="ld-select-inner">
                        <option value="OPERATOR">经办人签字</option>
                        <option value="LP">法定代表人签字</option>
                        <option value="COMPANY">企业签章</option>
                    </select>
                </td>
            </tr>
            <tr>
                <th colspan="2" class="ld-from-headblock">
                    <div class="ld-from-headblock-title">日期设置</div>
                </th>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    签署截止日期
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="若超过该日期，合同所有签署方将不能进行签署" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input type="text" name="expireTime" id="expireTime" value="" class="Wdate ld-input-inner Q_setTimeWdate" autocomplete="off" size="25" maxlength="10" value="" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',alwaysUseStartDate:true{rdelim});"/>

                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    文件到期日期
                    <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="文件履行期限的截止日期" data-direction="top" data-type="position"></b>
                </td>
                <td class="ld-form-item-content">
                    <input type="text" name="endTime" id="endTime" value="" class="Wdate ld-input-inner Q_setTimeWdate" autocomplete="off" size="25" maxlength="10" value="" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',alwaysUseStartDate:true{rdelim});"/>
                </td>
            </tr>
        </table>
    </div>
</form>